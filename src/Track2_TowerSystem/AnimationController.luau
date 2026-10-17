--!strict
-- src/Track2_TowerSystem/AnimationController.luau
-- Anime Limitless Tower Defense — Phase 5 Core Procedural Animation Controller
-- Implements Idempotent Semantic Rigging (P5-08) & Deterministic Procedural Player (P5-09)
-- Complies with AnimationContract v5.0.0, MEM-FIX-0003, and Canonical Rules R01-R08

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local AnimationContract = require(SharedFolder:WaitForChild("AnimationContract")) :: any

local AnimationController = {}
AnimationController.__index = AnimationController

type AnimationState = AnimationContract.AnimationState
type JointName = AnimationContract.JointName
type CharacterAnimationProfile = AnimationContract.CharacterAnimationProfile
type RigContext = AnimationContract.RigContext
type RigValidationReport = AnimationContract.RigValidationReport
type RestPoseSnapshot = AnimationContract.RestPoseSnapshot

-- Sibling references (safe lazy require to prevent cycle during bootstrap)
local AnimationRegistry: any = nil
local VFXDispatcher: any = nil

local function getRegistry(): any
	if not AnimationRegistry then
		local regInst = script.Parent:FindFirstChild("AnimationRegistry")
		if regInst and regInst:IsA("ModuleScript") then
			AnimationRegistry = require(regInst)
		end
	end
	return AnimationRegistry
end

local function getVFXDispatcher(): any
	if not VFXDispatcher then
		local vfxInst = script.Parent:FindFirstChild("VFXDispatcher")
		if vfxInst and vfxInst:IsA("ModuleScript") then
			VFXDispatcher = require(vfxInst)
		end
	end
	return VFXDispatcher
end

-- Storage for active model contexts
local activeContexts: { [Model]: RigContext } = {}
local heartbeatConn: RBXScriptConnection? = nil

-- =============================================================================
-- STATIC ASSET RECOGNITION
-- =============================================================================

local STATIC_MAP_ASSETS: { [string]: boolean } = {
	AnimeBaseCrystal = true,
	EnemySpawnGate = true,
	PlacementPadTemplate = true,
}

local function isStaticMapAsset(model: Model): boolean
	local name = model.Name
	for mapName in pairs(STATIC_MAP_ASSETS) do
		if string.find(name, mapName, 1, true) then
			return true
		end
	end
	return model:GetAttribute("IsStaticMapAsset") == true
end

-- =============================================================================
-- 1. UTILITY & MATH HELPERS
-- =============================================================================

local function getCFrameDelta(cfA: CFrame, cfB: CFrame): number
	local posDiff = (cfA.Position - cfB.Position).Magnitude
	local _, rotDiff = (cfA * cfB:Inverse()):ToAxisAngle()
	return math.max(posDiff, math.abs(rotDiff))
end

local function getOrCreateSemanticAnchor(
	model: Model,
	name: string,
	size: Vector3,
	targetCFrame: CFrame
): BasePart
	local existing = model:FindFirstChild(name)
	if existing and existing:IsA("BasePart") then
		existing.Anchored = false
		existing.CanCollide = false
		existing.CanTouch = false
		existing.CanQuery = false
		existing.Massless = true
		return existing
	end

	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Transparency = 1
	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.CFrame = targetCFrame
	part.Parent = model
	return part
end

local function getOrCreateMotor6D(
	parent: Instance,
	name: JointName,
	part0: BasePart,
	part1: BasePart,
	c0: CFrame,
	c1: CFrame
): Motor6D
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("Motor6D") and child.Name == name then
			child.Part0 = part0
			child.Part1 = part1
			child.C0 = c0
			child.C1 = c1
			return child
		end
	end

	local motor = Instance.new("Motor6D")
	motor.Name = name
	motor.Part0 = part0
	motor.Part1 = part1
	motor.C0 = c0
	motor.C1 = c1
	motor.Parent = parent
	return motor
end

local function getOrCreateAttachment(
	model: Model,
	parent: BasePart,
	name: string,
	offset: CFrame
): Attachment
	local existing = model:FindFirstChild(name, true)
	if existing and existing:IsA("Attachment") then
		return existing
	end

	local att = Instance.new("Attachment")
	att.Name = name
	att.CFrame = offset
	att.Parent = parent
	return att
end

local function getOrCreatePartAttachment(
	parent: BasePart,
	name: string,
	offset: CFrame
): Attachment
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("Attachment") then
		return existing
	end

	local att = Instance.new("Attachment")
	att.Name = name
	att.CFrame = offset
	att.Parent = parent
	return att
end

-- =============================================================================
-- 2. RIG SANITIZATION & ASSEMBLY (P5-08)
-- =============================================================================

function AnimationController.GetRigContext(model: Model): RigContext?
	return activeContexts[model]
end

function AnimationController.GetContext(model: Model): RigContext?
	return activeContexts[model]
end

function AnimationController.SanitizeAndRigModel(
	model: Model,
	customProfile: CharacterAnimationProfile?
): (RigContext?, RigValidationReport)
	-- Check cache for idempotent return
	if activeContexts[model] and not activeContexts[model].isDestroyed then
		local report: RigValidationReport = {
			isValid = true,
			code = "VALID",
			message = "Model already rigged (cached RigContext returned)",
			missingJoints = {},
			conflictingWelds = {},
			limbPartCounts = {},
		}
		return activeContexts[model], report
	end

	-- Check for static map assets
	if isStaticMapAsset(model) then
		local report: RigValidationReport = {
			isValid = false,
			code = "STATIC_MAP_ASSET",
			message = "Model is a static map asset; procedural humanoid rig not applicable",
			missingJoints = {},
			conflictingWelds = {},
			limbPartCounts = {},
		}
		return nil, report
	end

	-- Resolve HumanoidRootPart
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart? or model.PrimaryPart
	if not root or not root:IsA("BasePart") then
		local report: RigValidationReport = {
			isValid = false,
			code = "MISSING_ROOT",
			message = "Model is missing a valid HumanoidRootPart or PrimaryPart",
			missingJoints = {},
			conflictingWelds = {},
			limbPartCounts = {},
		}
		return nil, report
	end

	-- Tag Rig Ownership immediately
	model:SetAttribute(AnimationContract.ATTRIBUTES.TRACK2_RIG_OWNED, true)
	model:SetAttribute(AnimationContract.ATTRIBUTES.VISUAL_SOURCE, "Track2")
	model:SetAttribute(AnimationContract.ATTRIBUTES.RIG_VERSION, AnimationContract.VERSION)

	-- Rule: HumanoidRootPart remains Anchored=true; all children Anchored=false, Massless=true, CanCollide=false
	root.Anchored = true
	root.CanCollide = false
	model.PrimaryPart = root

	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") and desc ~= root then
			desc.Anchored = false
			desc.CanCollide = false
			desc.CanTouch = false
			desc.CanQuery = false
			desc.Massless = true
		end
	end

	-- 1. Semantic Limbs Resolution
	local torso = getOrCreateSemanticAnchor(model, "Torso", Vector3.new(2.1, 2.08, 1.04), root.CFrame * CFrame.new(0, 0.12, 0))
	local head = getOrCreateSemanticAnchor(model, "Head", Vector3.new(1.56, 1.54, 1.52), root.CFrame * CFrame.new(0, 1.92, 0))
	local rightArm = getOrCreateSemanticAnchor(model, "RightArm", Vector3.new(0.9, 2.2, 0.9), root.CFrame * CFrame.new(1.39, 0.75, 0))
	local leftArm = getOrCreateSemanticAnchor(model, "LeftArm", Vector3.new(0.9, 2.2, 0.9), root.CFrame * CFrame.new(-1.39, 0.75, 0))
	local rightLeg = getOrCreateSemanticAnchor(model, "RightLeg", Vector3.new(0.9, 2.0, 0.9), root.CFrame * CFrame.new(0.53, -0.60, 0))
	local leftLeg = getOrCreateSemanticAnchor(model, "LeftLeg", Vector3.new(0.9, 2.0, 0.9), root.CFrame * CFrame.new(-0.53, -0.60, 0))

	-- 2. Build 6-Joint Body Rig
	local motors: { [JointName]: Motor6D } = {}
	motors.RootJoint = getOrCreateMotor6D(root, "RootJoint", root, torso, CFrame.identity, CFrame.identity)
	motors.Neck = getOrCreateMotor6D(torso, "Neck", torso, head, CFrame.new(0, 1.89, 0), CFrame.identity)
	motors.RightShoulder = getOrCreateMotor6D(torso, "RightShoulder", torso, rightArm, CFrame.new(1.39, 0.75, 0), CFrame.identity)
	motors.LeftShoulder = getOrCreateMotor6D(torso, "LeftShoulder", torso, leftArm, CFrame.new(-1.39, 0.75, 0), CFrame.identity)
	motors.RightHip = getOrCreateMotor6D(torso, "RightHip", torso, rightLeg, CFrame.new(0.53, -0.60, 0), CFrame.identity)
	motors.LeftHip = getOrCreateMotor6D(torso, "LeftHip", torso, leftLeg, CFrame.new(-0.53, -0.60, 0), CFrame.identity)

	-- 3. Build Weapon Rig if applicable (Zoro / Weapon Profile)
	local isWeaponRig = (customProfile and customProfile.rigType == "ArticulatedWeaponRig") or string.find(model.Name, "Zoro", 1, true) ~= nil
	local weaponR: BasePart? = nil
	local weaponL: BasePart? = nil
	local weaponM: BasePart? = nil
	if isWeaponRig then
		weaponR = getOrCreateSemanticAnchor(model, "SignatureWeapon", Vector3.new(0.5, 3.0, 0.5), rightArm.CFrame * CFrame.new(0.24, -1.66, -0.50))
		weaponL = getOrCreateSemanticAnchor(model, "LeftWeapon", Vector3.new(0.5, 3.0, 0.5), leftArm.CFrame * CFrame.new(-0.24, -1.66, -0.50))
		weaponM = getOrCreateSemanticAnchor(model, "MouthWeapon", Vector3.new(0.5, 3.0, 0.5), head.CFrame * CFrame.new(0, -0.25, -0.55))

		motors.WeaponRight = getOrCreateMotor6D(rightArm, "WeaponRight", rightArm, weaponR, CFrame.new(0.24, -1.66, -0.50), CFrame.identity)
		motors.WeaponLeft = getOrCreateMotor6D(leftArm, "WeaponLeft", leftArm, weaponL, CFrame.new(-0.24, -1.66, -0.50), CFrame.identity)
		motors.WeaponMouth = getOrCreateMotor6D(head, "WeaponMouth", head, weaponM, CFrame.new(0, -0.25, -0.55), CFrame.identity)
	end

	-- 3.5 Dynamic Semantic Attachment Injection (Tasks L-01 & Z-01)
	getOrCreateAttachment(model, root, "RootAttachment", CFrame.new(0, -1.0, 0))
	local rightFist = model:FindFirstChild("Fist_2") :: BasePart? or rightArm
	getOrCreateAttachment(model, rightFist, "RightArmAttachment", CFrame.new(0, -0.28, 0))
	local leftFist = model:FindFirstChild("Fist") :: BasePart? or leftArm
	getOrCreateAttachment(model, leftFist, "LeftArmAttachment", CFrame.new(0, -0.28, 0))
	getOrCreateAttachment(model, head, "HeadAttachment", CFrame.new(0, 0.77, 0))
	getOrCreateAttachment(model, torso, "HakiCloudAttachment", CFrame.new(0, 2.40, 0.62))
	getOrCreateAttachment(model, torso, "BajrangAnchorAttachment", CFrame.new(0, 5.50, -1.20))

	-- Zoro Semantic Attachments (Task Z-01)
	getOrCreateAttachment(model, rightFist, "RightSwordAttachment", CFrame.new(-0.126, -0.269, -0.014))
	getOrCreateAttachment(model, leftFist, "LeftSwordAttachment", CFrame.new(0.126, -0.269, -0.014))
	getOrCreateAttachment(model, head, "MouthSwordAttachment", CFrame.new(0, -0.293, -0.883))
	getOrCreateAttachment(model, rightArm, "EnmaAuraAttachment", CFrame.new(1.382, 0.772, -1.484))
	getOrCreateAttachment(model, torso, "KingOfHellAttachment", CFrame.new(0, 0.20, -0.40))

	-- Blade Trail Attachments for 3 Swords (Task Z-01)
	local wadoGuard = model:FindFirstChild("WadoIchimonji_TsubaGuard") :: BasePart?
	if wadoGuard then
		getOrCreatePartAttachment(wadoGuard, "BladeBase", CFrame.identity)
	end
	local wadoTip = model:FindFirstChild("WadoIchimonji_Blade_Seg4") :: BasePart?
	if wadoTip then
		getOrCreatePartAttachment(wadoTip, "BladeTip", CFrame.new(0, 0.315, 0))
	end

	local enmaGuard = model:FindFirstChild("Enma_TsubaGuard") :: BasePart?
	if enmaGuard then
		getOrCreatePartAttachment(enmaGuard, "BladeBase", CFrame.identity)
	end
	local enmaTip = model:FindFirstChild("Enma_Blade_Seg4") :: BasePart?
	if enmaTip then
		getOrCreatePartAttachment(enmaTip, "BladeTip", CFrame.new(0, 0.408, 0))
	end

	local sandaiGuard = model:FindFirstChild("SandaiKitetsu_TsubaGuard") :: BasePart?
	if sandaiGuard then
		getOrCreatePartAttachment(sandaiGuard, "BladeBase", CFrame.identity)
	end
	local sandaiTip = model:FindFirstChild("SandaiKitetsu_Blade_Seg4") :: BasePart?
	if sandaiTip then
		getOrCreatePartAttachment(sandaiTip, "BladeTip", CFrame.new(0, 0.408, 0))
	end

	-- Ace Semantic Attachments (Tasks A-01 & A-03)
	getOrCreateAttachment(model, rightFist, "RightFingerAttachment", CFrame.new(0, -0.28, -0.15))
	getOrCreateAttachment(model, rightFist, "RightHandFlameAtt", CFrame.new(0, -0.28, -0.15))
	getOrCreateAttachment(model, leftFist, "LeftHandAttachment", CFrame.new(0, -0.28, -0.15))
	getOrCreateAttachment(model, leftFist, "LeftHandFlameAtt", CFrame.new(0, -0.28, -0.15))
	getOrCreateAttachment(model, torso, "FlameAuraAttachment", CFrame.new(0, 0.95, 0.0))
	getOrCreateAttachment(model, torso, "EnteiAnchorAttachment", CFrame.new(0.60, 5.80, -0.40))
	getOrCreateAttachment(model, torso, "OverheadEnteiAtt", CFrame.new(0.60, 5.80, -0.40))

	-- Hat Tip Attachment (prefer AceHatBrim, fallback to Head)
	local aceHatBrim = model:FindFirstChild("AceHatBrim", true)
		or model:FindFirstChild("CowboyHat_Brim", true)
		or model:FindFirstChild("HatBrim", true)
	if aceHatBrim and aceHatBrim:IsA("BasePart") then
		getOrCreatePartAttachment(aceHatBrim, "HatTipAttachment", CFrame.new(0, 0, -1.25))
	else
		getOrCreateAttachment(model, head, "HatTipAttachment", CFrame.new(0, 0.94, -1.25))
	end

	-- 4. Dynamic Accessory & Sub-part Clustering (Anti-Lock Rigid Weld Protocol)
	local limbCounts: { [string]: number } = {
		Torso = 0,
		Head = 0,
		RightArm = 0,
		LeftArm = 0,
		RightLeg = 0,
		LeftLeg = 0,
		Weapons = 0,
	}

	local semanticParts: { [Instance]: boolean } = {
		[root] = true,
		[torso] = true,
		[head] = true,
		[rightArm] = true,
		[leftArm] = true,
		[rightLeg] = true,
		[leftLeg] = true,
	}
	if weaponR then semanticParts[weaponR] = true end
	if weaponL then semanticParts[weaponL] = true end
	if weaponM then semanticParts[weaponM] = true end
	if motors.WeaponRight and motors.WeaponRight.Part1 then semanticParts[motors.WeaponRight.Part1] = true end
	if motors.WeaponLeft and motors.WeaponLeft.Part1 then semanticParts[motors.WeaponLeft.Part1] = true end
	if motors.WeaponMouth and motors.WeaponMouth.Part1 then semanticParts[motors.WeaponMouth.Part1] = true end

	local conflictingWeldsList: { string } = {}

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and not semanticParts[part] then
			local pName = part.Name
			local relX = part.Position.X - root.Position.X
			local targetLimb: BasePart = torso

			-- 1. Explicit Torso exclusions: Chest scar, slung-back straw hat & weave parts
			if string.find(pName, "ChestScar") then
				targetLimb = torso
				limbCounts.Torso += 1
			elseif string.find(pName, "StrawWeave") or string.find(pName, "StrawHat") then
				targetLimb = torso
				limbCounts.Torso += 1

			-- 1.5 Zoro Torso Accessories & Scabbards (Task Z-01)
			elseif string.find(pName, "Scabbard") or string.find(pName, "Sheath")
				or string.find(pName, "Haramaki") or string.find(pName, "PurpleObiSash")
				or string.find(pName, "GreenCoatSkirt") or string.find(pName, "PelvisBelt")
				or string.find(pName, "BareChest") then
				targetLimb = torso
				limbCounts.Torso += 1

			-- 1.6 Floor / Ground Aura Parts (Ace + Zoro: bind to root so they stay horizontal on floor)
			elseif string.find(pName, "HakiGround") or string.find(pName, "FlameGround") or string.find(pName, "GroundRing")
				or string.find(pName, "AuraBurst") or string.find(pName, "HakiLightning") or string.find(pName, "FlameGroundRing") then
				targetLimb = root
				limbCounts.Torso += 1

			-- 1.7 Ace Torso Accessories: Red Bead Necklace, Belt, Hip Dagger (Task A-01)
			elseif string.find(pName, "RedNeckBead") or string.find(pName, "RedBead") or string.find(pName, "Necklace")
				or string.find(pName, "Dagger") or string.find(pName, "Holster")
				or string.find(pName, "AceBelt") or string.find(pName, "BeltBuckle") then
				targetLimb = torso
				limbCounts.Torso += 1

			-- 2. Explicit Arm overrides: Haki glow, knuckles, shoulder caps (Spatial X routing)
			elseif string.find(pName, "HakiCrimsonGlow") or string.find(pName, "BlackHakiFist") or string.find(pName, "HakiBusoFist") then
				targetLimb = rightArm
				limbCounts.RightArm += 1
			elseif string.find(pName, "Knuckle") or string.find(pName, "ShoulderCap") then
				if relX > 0.8 then
					targetLimb = rightArm
					limbCounts.RightArm += 1
				else
					targetLimb = leftArm
					limbCounts.LeftArm += 1
				end

			-- 2.5 Ace Arm Accessories: Elbow Guard / Pad & Log Pose (Task A-01)
			elseif string.find(pName, "LogPose") then
				targetLimb = leftArm
				limbCounts.LeftArm += 1
			elseif string.find(pName, "Elbow") or string.find(pName, "ArmBand") then
				if relX > 0.2 then
					targetLimb = rightArm
					limbCounts.RightArm += 1
				else
					targetLimb = leftArm
					limbCounts.LeftArm += 1
				end

			-- 3. Head & Face features (Including Freckle, CowboyHat, AceHat)
			elseif string.find(pName, "HeadTopBevel") or string.find(pName, "Smile")
				or string.find(pName, "Hair") or string.find(pName, "Hat") or string.find(pName, "CowboyHat") or string.find(pName, "AceHat")
				or string.find(pName, "Eye") or string.find(pName, "Ear") or string.find(pName, "Nose") or string.find(pName, "Mouth")
				or string.find(pName, "Jaw") or string.find(pName, "Teeth") or string.find(pName, "Freckle")
				or (string.find(pName, "Scar") and not string.find(pName, "Chest"))
				or string.find(pName, "Bandana") or string.find(pName, "Antler")
				or (string.find(pName, "Cap") and not string.find(pName, "Shoulder"))
				or string.find(pName, "Spike") or string.find(pName, "Smirk") or string.find(pName, "Bevel") then
				targetLimb = head
				limbCounts.Head += 1

			-- 4. Standard Arm Limbs
			elseif (string.find(pName, "_2") and (string.find(pName, "Arm") or string.find(pName, "Forearm") or string.find(pName, "Fist") or string.find(pName, "Shoulder") or string.find(pName, "Sleeve")))
				or ((string.find(pName, "Arm") or string.find(pName, "Forearm") or string.find(pName, "Fist") or string.find(pName, "Shoulder") or string.find(pName, "Sleeve")) and relX > 0.8) then
				targetLimb = rightArm
				limbCounts.RightArm += 1
			elseif (string.find(pName, "Arm") or string.find(pName, "Forearm") or string.find(pName, "Fist") or string.find(pName, "Shoulder") or string.find(pName, "Sleeve")) and not string.find(pName, "_2") then
				targetLimb = leftArm
				limbCounts.LeftArm += 1

			-- 5. Leg Limbs
			elseif (string.find(pName, "_2") and (string.find(pName, "Thigh") or string.find(pName, "Shin") or string.find(pName, "Boot") or string.find(pName, "Leg") or string.find(pName, "Toe")))
				or (string.find(pName, "ShortsCuff") and part.Position.X >= root.Position.X) then
				targetLimb = rightLeg
				limbCounts.RightLeg += 1
			elseif (string.find(pName, "Thigh") or string.find(pName, "Shin") or string.find(pName, "Boot") or string.find(pName, "Leg") or string.find(pName, "Toe")) and not string.find(pName, "_2")
				or (string.find(pName, "ShortsCuff") and part.Position.X < root.Position.X) then
				targetLimb = leftLeg
				limbCounts.LeftLeg += 1

			-- 6. Weapon Limbs (Task Z-01: Disambiguate Wado, Enma, Sandai, Swords)
			elseif string.find(pName, "Wado") or string.find(pName, "MouthSword") then
				targetLimb = weaponM or head
				limbCounts.Weapons += 1
			elseif string.find(pName, "Enma") or string.find(pName, "Sandai") or string.find(pName, "Sword")
				or string.find(pName, "Blade") or string.find(pName, "Hilt") or string.find(pName, "Tsuba")
				or string.find(pName, "Pommel") or string.find(pName, "Handle") then
				-- Taking into account negative/positive X geometry:
				-- In Zoro.rbxmx: SandaiKitetsu is at X > 0 (right hand), Enma is at X < 0 (left hand)
				if relX > 0.2 then
					targetLimb = weaponR or rightArm
				elseif relX < -0.2 then
					targetLimb = weaponL or leftArm
				elseif string.find(pName, "Sandai") or string.find(pName, "Left") then
					targetLimb = weaponL or leftArm
				else
					targetLimb = weaponR or rightArm
				end
				limbCounts.Weapons += 1

			-- 7. Torso default
			else
				targetLimb = torso
				limbCounts.Torso += 1
			end

			-- Check for conflicting cross-joint welds and remove them
			for _, child in ipairs(part:GetChildren()) do
				if child:IsA("WeldConstraint") or child:IsA("Weld") then
					table.insert(conflictingWeldsList, child.Name)
					child:Destroy()
				end
			end

			local weld = Instance.new("WeldConstraint")
			weld.Name = "ClusterWeld_" .. pName
			weld.Part0 = targetLimb
			weld.Part1 = part
			weld.Parent = part
		end
	end

	-- 5. Capture Immutable RestPoseSnapshot
	local baseC0: { [JointName]: CFrame } = {}
	local baseC1: { [JointName]: CFrame } = {}
	local basePartSizes: { [string]: Vector3 } = {}
	local baseAttachmentCFrames: { [string]: CFrame } = {}
	local basePartPositions: { [string]: Vector3 } = {}

	for jName, motor in pairs(motors) do
		baseC0[jName] = motor.C0
		baseC1[jName] = motor.C1
	end

	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			basePartSizes[desc.Name] = desc.Size
			basePartPositions[desc.Name] = desc.Position
		elseif desc:IsA("Attachment") then
			baseAttachmentCFrames[desc.Name] = desc.CFrame
		end
	end

	local restSnapshot: RestPoseSnapshot = {
		baseC0 = baseC0,
		baseC1 = baseC1,
		basePartSizes = basePartSizes,
		baseAttachmentCFrames = baseAttachmentCFrames,
		basePartPositions = basePartPositions,
	}

	-- 6. Construct and Cache RigContext
	local context: RigContext = {
		model = model,
		rootPart = root,
		torso = torso,
		limbs = {
			Torso = torso,
			Head = head,
			RightArm = rightArm,
			LeftArm = leftArm,
			RightLeg = rightLeg,
			LeftLeg = leftLeg,
		},
		motors = motors,
		restPose = restSnapshot,
		activeState = "Idle",
		playbackSpeed = 1.0,
		isPaused = false,
		elapsedInState = 0,
		cancelToken = 0,
		currentScaleMultiplier = Vector3.new(1, 1, 1),
		isDestroyed = false,
	}

	activeContexts[model] = context
	model:SetAttribute(AnimationContract.ATTRIBUTES.RIG_READY, true)

	model.Destroying:Connect(function()
		AnimationController.DestroyContext(model)
	end)

	local report: RigValidationReport = {
		isValid = true,
		code = "VALID",
		message = "Model successfully articulated with semantic joints and cluster welds",
		missingJoints = {},
		conflictingWelds = conflictingWeldsList,
		limbPartCounts = limbCounts,
	}

	return context, report
end

-- =============================================================================
-- 3. DETERMINISTIC PROCEDURAL PLAYER CONTROLS (P5-09)
-- =============================================================================

function AnimationController.Play(
	model: Model,
	state: AnimationState,
	loopOverride: boolean?,
	speedOverride: number?
): number
	local context = activeContexts[model]
	if not context then
		local newCtx, _ = AnimationController.SanitizeAndRigModel(model)
		if not newCtx then
			warn("[AnimationController] Cannot play: model rigging failed")
			return -1
		end
		context = newCtx
	end

	context.cancelToken += 1
	context.activeState = state
	context.elapsedInState = 0
	context.isPaused = false

	if speedOverride then
		context.playbackSpeed = math.clamp(speedOverride, 0.1, 2.0)
	end
	if loopOverride ~= nil then
		model:SetAttribute("AnimationLoopedOverride", loopOverride)
	end

	-- Evaluate and apply immediately at t = 0
	AnimationController.EvaluateAtTime(model, state, 0)

	return context.cancelToken
end

function AnimationController.Pause(model: Model): boolean
	local context = activeContexts[model]
	if not context or context.isDestroyed then
		return false
	end
	context.isPaused = true
	return true
end

function AnimationController.Resume(model: Model): boolean
	local context = activeContexts[model]
	if not context or context.isDestroyed then
		return false
	end
	context.isPaused = false
	return true
end

function AnimationController.Stop(model: Model): boolean
	local context = activeContexts[model]
	if not context or context.isDestroyed then
		return false
	end
	context.isPaused = true
	context.cancelToken += 1
	AnimationController.ResetRestPose(model)
	context.activeState = "Idle"
	context.elapsedInState = 0
	return true
end

function AnimationController.Replay(model: Model): boolean
	local context = activeContexts[model]
	if not context or context.isDestroyed then
		return false
	end
	context.elapsedInState = 0
	context.isPaused = false
	AnimationController.ResetRestPose(model)
	AnimationController.EvaluateAtTime(model, context.activeState, 0)
	return true
end

function AnimationController.SetLoop(model: Model, looped: boolean): boolean
	local context = activeContexts[model]
	if not context or context.isDestroyed then
		return false
	end
	model:SetAttribute("AnimationLoopedOverride", looped)
	return true
end

function AnimationController.SetPlaybackSpeed(model: Model, speed: number): boolean
	local context = activeContexts[model]
	if not context or context.isDestroyed then
		return false
	end
	context.playbackSpeed = math.clamp(speed, 0.1, 2.0)
	return true
end

function AnimationController.SetSpeed(model: Model, speed: number): boolean
	return AnimationController.SetPlaybackSpeed(model, speed)
end

function AnimationController.Step(model: Model, deltaSeconds: number): boolean
	local context = activeContexts[model]
	if not context or context.isDestroyed then
		return false
	end
	context.elapsedInState = math.max(0, context.elapsedInState + deltaSeconds)
	AnimationController.EvaluateAtTime(model, context.activeState, context.elapsedInState, true)
	return true
end

function AnimationController.StepFrame(model: Model, deltaFrames: number): boolean
	local deltaSeconds = deltaFrames * (1.0 / 60.0)
	return AnimationController.Step(model, deltaSeconds)
end

function AnimationController.Seek(model: Model, targetSeconds: number): boolean
	local context = activeContexts[model]
	if not context or context.isDestroyed then
		return false
	end
	context.elapsedInState = math.max(0, targetSeconds)
	-- Seek deterministically updates joint poses WITHOUT emitting VFX cues (suppresses cue replay spam)
	AnimationController.EvaluateAtTime(model, context.activeState, context.elapsedInState, true)
	return true
end

function AnimationController.EvaluateAtTime(
	model: Model,
	state: AnimationState,
	t: number,
	suppressCue: boolean?
): (AnimationContract.JointPoseMap, AnimationContract.ScaleTarget?, string?)
	local context = activeContexts[model]
	if not context or context.isDestroyed then
		return {}, nil, nil
	end

	local reg = getRegistry()
	local heroId = (model:GetAttribute(AnimationContract.ATTRIBUTES.HERO_ID) :: string?) or model.Name
	local profile = if reg and reg.GetAnimationProfile then reg.GetAnimationProfile(heroId) else nil
	if not profile or not profile.states then
		return {}, nil, nil
	end

	local track = profile.states[state]
	if not track then
		track = profile.states.Idle
		if not track then
			return {}, nil, nil
		end
	end

	-- Deterministic keyframe interpolation from AnimationContract
	local jointPoses, scaleTarget, cue = AnimationContract.EvaluatePoseAtTime(track, t)

	-- Apply motor transforms relative to baseC0 (Zero-Drift Invariant)
	for jointName, poseOffset in pairs(jointPoses) do
		local motor = context.motors[jointName]
		local baseC0 = context.restPose.baseC0[jointName]
		if motor and baseC0 then
			motor.C0 = baseC0 * poseOffset
		end
	end

	-- Apply limb scale targets if specified by profile
	if scaleTarget then
		local limbPart = context.limbs[scaleTarget.targetLimb] or model:FindFirstChild(scaleTarget.targetLimb, true) :: BasePart?
		local baseSize = limbPart and context.restPose.basePartSizes[limbPart.Name]
		if limbPart and baseSize then
			limbPart.Size = baseSize * scaleTarget.scaleFactor
		end
	end

	-- Dispatch visual cue if emitted and not suppressed by scrub/seek
	if cue and not suppressCue then
		local vfx = getVFXDispatcher()
		if vfx and vfx.TriggerCue then
			vfx.TriggerCue({
				sourceModel = model,
				cueType = cue,
				heroId = heroId,
				originCFrame = context.rootPart.CFrame,
				targetPosition = context.rootPart.Position + context.rootPart.CFrame.LookVector * 15,
			})
		end
	end

	return jointPoses, scaleTarget, cue
end

function AnimationController.ResetRestPose(model: Model): boolean
	local context = activeContexts[model]
	if not context or context.isDestroyed then
		return false
	end

	local maxDelta = 0.0

	-- Restore motors
	for jointName, motor in pairs(context.motors) do
		local baseC0 = context.restPose.baseC0[jointName]
		local baseC1 = context.restPose.baseC1[jointName]
		if baseC0 and motor then
			motor.C0 = baseC0
			local d = getCFrameDelta(motor.C0, baseC0)
			if d > maxDelta then maxDelta = d end
		end
		if baseC1 and motor then
			motor.C1 = baseC1
		end
	end

	-- Restore part sizes
	for partName, baseSize in pairs(context.restPose.basePartSizes) do
		local part = model:FindFirstChild(partName, true) :: BasePart?
		if part and part:IsA("BasePart") then
			part.Size = baseSize
			local d = (part.Size - baseSize).Magnitude
			if d > maxDelta then maxDelta = d end
		end
	end

	-- Restore attachment CFrames
	for attName, baseCF in pairs(context.restPose.baseAttachmentCFrames) do
		local att = model:FindFirstChild(attName, true) :: Attachment?
		if att and att:IsA("Attachment") then
			att.CFrame = baseCF
		end
	end

	context.currentScaleMultiplier = Vector3.new(1, 1, 1)
	return maxDelta < 0.001
end

function AnimationController.ResetPose(model: Model): boolean
	return AnimationController.ResetRestPose(model)
end

function AnimationController.PlayAttack(
	model: Model,
	onImpact: (() -> ())?
): number
	local context = activeContexts[model]
	if not context then
		local newCtx, _ = AnimationController.SanitizeAndRigModel(model)
		if not newCtx then return -1 end
		context = newCtx
	end

	context.cancelToken += 1
	local currentToken = context.cancelToken

	-- Visual-only attack sequence; combat loop maintains independent 0.31s timer
	AnimationController.Play(model, "Windup")

	task.delay(0.14, function()
		if context.cancelToken ~= currentToken or context.isDestroyed then return end
		AnimationController.Play(model, "Attack")

		task.delay(0.10, function()
			if context.cancelToken ~= currentToken or context.isDestroyed then return end
			AnimationController.Play(model, "Impact")
			if onImpact then
				pcall(onImpact)
			end

			task.delay(0.07, function()
				if context.cancelToken ~= currentToken or context.isDestroyed then return end
				AnimationController.Play(model, "Recovery")

				task.delay(0.20, function()
					if context.cancelToken ~= currentToken or context.isDestroyed then return end
					AnimationController.Play(model, "Idle")
				end)
			end)
		end)
	end)

	return currentToken
end

function AnimationController.DestroyContext(model: Model): boolean
	local context = activeContexts[model]
	if not context then
		return false
	end
	context.isDestroyed = true
	context.cancelToken += 1
	AnimationController.ResetRestPose(model)
	activeContexts[model] = nil
	return true
end

function AnimationController.CleanupAll()
	for model, _ in pairs(activeContexts) do
		AnimationController.DestroyContext(model)
	end
	table.clear(activeContexts)
end

-- =============================================================================
-- 4. REAL-TIME ENGINE PLAYBACK STEP
-- =============================================================================

local function onHeartbeat(dt: number)
	debug.profilebegin("ALT_Phase5_AnimationStep")

	for model, context in pairs(activeContexts) do
		if context.isDestroyed or not model.Parent or not context.rootPart.Parent then
			AnimationController.DestroyContext(model)
		elseif not context.isPaused then
			local reg = getRegistry()
			local heroId = (model:GetAttribute(AnimationContract.ATTRIBUTES.HERO_ID) :: string?) or model.Name
			local profile = if reg and reg.GetAnimationProfile then reg.GetAnimationProfile(heroId) else nil

			if profile and profile.states then
				local track = profile.states[context.activeState] or profile.states.Idle
				local duration = if track then track.duration else 1.0

				context.elapsedInState += dt * context.playbackSpeed

				local isLooped = if track then track.looped else true
				local loopOverride = model:GetAttribute("AnimationLoopedOverride") :: boolean?
				if loopOverride ~= nil then
					isLooped = loopOverride
				end

				if context.elapsedInState >= duration then
					if isLooped then
						context.elapsedInState = context.elapsedInState % math.max(0.001, duration)
					else
						context.elapsedInState = duration
						-- Auto-transition out of transient states
						if context.activeState == "Spawn" or context.activeState == "Recovery" or context.activeState == "SpecialIdle" then
							context.activeState = "Idle"
							context.elapsedInState = 0
						end
					end
				end

				AnimationController.EvaluateAtTime(model, context.activeState, context.elapsedInState)
			end
		end
	end

	debug.profileend()
end

-- Start Heartbeat loop
if not heartbeatConn then
	heartbeatConn = RunService.Heartbeat:Connect(onHeartbeat)
end

return AnimationController
