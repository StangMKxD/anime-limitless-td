--!strict
-- src/Presentation/RigBinder.luau
-- Anime Limitless Tower Defense — Phase 6 Neutral Presentation Rig Binder
-- Idempotent multi-part semantic rig construction and rest-pose snapshot restoration.
-- Works seamlessly across Client, Server, and DevTools/AnimationLab.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationContract = (function()
	local ok, mod = pcall(function()
		return require(SharedFolder:WaitForChild("AnimationContract"))
	end)
	if ok and mod then return mod end
	local ok2, mod2 = pcall(require, "./AnimationContract")
	if ok2 and mod2 then return mod2 end
	local ok3, mod3 = pcall(require, "../Shared/AnimationContract")
	if ok3 and mod3 then return mod3 end
	local ok4, mod4 = pcall(require, "../src/Shared/AnimationContract")
	if ok4 and mod4 then return mod4 end
	error("Failed to resolve AnimationContract")
end)()

export type JointName = string

export type RestSnapshot = {
	c0: { [JointName]: CFrame },
	c1: { [JointName]: CFrame },
	partSizes: { [BasePart]: Vector3 },
	attachmentCFrames: { [Attachment]: CFrame },
}

export type RigContext = {
	model: Model,
	heroId: string,
	logicalRoot: BasePart,
	visualRoot: BasePart,
	torso: BasePart,
	head: BasePart,
	rightArm: BasePart,
	leftArm: BasePart,
	rightLeg: BasePart,
	leftLeg: BasePart,
	motors: { [JointName]: Motor6D },
	semanticParts: { [string]: { BasePart } },
	attachments: { [string]: Attachment },
	restSnapshot: RestSnapshot,
	isZoroSantoryu: boolean,
	isDestroyed: boolean,
}

export type RigValidationReport = {
	isValid: boolean,
	code: string,
	message: string,
	missingJoints: { string },
	conflictingWelds: { string },
	limbPartCounts: { [string]: number },
}

local activeContexts: { [Model]: RigContext } = {}

local function isStaticMapAsset(model: Model): boolean
	local name = model.Name
	return name == "AnimeBaseCrystal" or name == "EnemySpawnGate" or name == "PlacementPadTemplate"
end

local function getOrCreateSemanticAnchor(
	model: Model,
	name: string,
	defaultSize: Vector3,
	defaultCFrame: CFrame
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
	part.Size = defaultSize
	part.CFrame = defaultCFrame
	part.Transparency = 1
	part.Anchored = false
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Parent = model
	return part
end

local function getOrCreateMotor6D(
	parent: Instance,
	name: string,
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

local RigBinder = {}

function RigBinder.GetContext(model: Model): RigContext?
	return activeContexts[model]
end

function RigBinder.Bind(
	model: Model,
	heroId: string?
): (RigContext?, RigValidationReport)
	local resolvedHeroId = heroId or model.Name

	-- Idempotent check
	if activeContexts[model] and not activeContexts[model].isDestroyed then
		return activeContexts[model], {
			isValid = true,
			code = "VALID",
			message = "Model already bound (cached RigContext returned)",
			missingJoints = {},
			conflictingWelds = {},
			limbPartCounts = {},
		}
	end

	-- Check for static map asset
	if isStaticMapAsset(model) then
		return nil, {
			isValid = false,
			code = "STATIC_MAP_ASSET",
			message = "Model is a static map asset; procedural humanoid rig not applicable",
			missingJoints = {},
			conflictingWelds = {},
			limbPartCounts = {},
		}
	end

	-- Resolve HumanoidRootPart
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart? or model.PrimaryPart
	if not root or not root:IsA("BasePart") then
		return nil, {
			isValid = false,
			code = "MISSING_ROOT",
			message = "Model is missing a valid HumanoidRootPart or PrimaryPart",
			missingJoints = {},
			conflictingWelds = {},
			limbPartCounts = {},
		}
	end

	-- Set attributes
	model:SetAttribute(AnimationContract.ATTRIBUTES.TRACK2_RIG_OWNED, true)
	model:SetAttribute("PresentationBound", true)

	root.Anchored = true
	root.CanCollide = false
	model.PrimaryPart = root

	-- Ensure child parts are unanchored and massless
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") and desc ~= root then
			desc.Anchored = false
			desc.CanCollide = false
			desc.CanTouch = false
			desc.CanQuery = false
			desc.Massless = true
		end
	end

	-- Resolve semantic anchors
	local torso = getOrCreateSemanticAnchor(model, "Torso", Vector3.new(2.1, 2.08, 1.04), root.CFrame * CFrame.new(0, 0.12, 0))
	local head = getOrCreateSemanticAnchor(model, "Head", Vector3.new(1.56, 1.54, 1.52), root.CFrame * CFrame.new(0, 1.92, 0))
	local rightArm = getOrCreateSemanticAnchor(model, "RightArm", Vector3.new(0.9, 2.2, 0.9), root.CFrame * CFrame.new(1.39, 0.75, 0))
	local leftArm = getOrCreateSemanticAnchor(model, "LeftArm", Vector3.new(0.9, 2.2, 0.9), root.CFrame * CFrame.new(-1.39, 0.75, 0))
	local rightLeg = getOrCreateSemanticAnchor(model, "RightLeg", Vector3.new(0.9, 2.0, 0.9), root.CFrame * CFrame.new(0.53, -0.60, 0))
	local leftLeg = getOrCreateSemanticAnchor(model, "LeftLeg", Vector3.new(0.9, 2.0, 0.9), root.CFrame * CFrame.new(-0.53, -0.60, 0))

	-- Build 6-Joint Body Rig
	local motors: { [JointName]: Motor6D } = {}
	motors["RootJoint"] = getOrCreateMotor6D(
		root,
		"RootJoint",
		root,
		torso,
		CFrame.new(0, 0.12, 0),
		CFrame.identity
	)
	motors["Neck"] = getOrCreateMotor6D(
		torso,
		"Neck",
		torso,
		head,
		CFrame.new(0, 1.80, 0),
		CFrame.identity
	)
	motors["RightShoulder"] = getOrCreateMotor6D(
		torso,
		"RightShoulder",
		torso,
		rightArm,
		CFrame.new(1.39, 0.63, 0),
		CFrame.identity
	)
	motors["LeftShoulder"] = getOrCreateMotor6D(
		torso,
		"LeftShoulder",
		torso,
		leftArm,
		CFrame.new(-1.39, 0.63, 0),
		CFrame.identity
	)
	motors["RightHip"] = getOrCreateMotor6D(
		torso,
		"RightHip",
		torso,
		rightLeg,
		CFrame.new(0.53, -0.72, 0),
		CFrame.identity
	)
	motors["LeftHip"] = getOrCreateMotor6D(
		torso,
		"LeftHip",
		torso,
		leftLeg,
		CFrame.new(-0.53, -0.72, 0),
		CFrame.identity
	)

	-- Zoro 9-joint weapon rig detection
	local isZoro = (string.find(resolvedHeroId, "Zoro") ~= nil or model.Name == "Zoro")
	if isZoro then
		local swordRight = getOrCreateSemanticAnchor(model, "SwordRight", Vector3.new(0.4, 3.6, 0.4), rightArm.CFrame * CFrame.new(0, -1.8, -0.5))
		local swordLeft = getOrCreateSemanticAnchor(model, "SwordLeft", Vector3.new(0.4, 3.6, 0.4), leftArm.CFrame * CFrame.new(0, -1.8, -0.5))
		local swordMouth = getOrCreateSemanticAnchor(model, "SwordMouth", Vector3.new(0.4, 3.6, 0.4), head.CFrame * CFrame.new(0, -0.3, -1.0))

		motors["WeaponRight"] = getOrCreateMotor6D(
			rightArm,
			"WeaponRight",
			rightArm,
			swordRight,
			CFrame.new(0, -1.5, -0.5),
			CFrame.identity
		)
		motors["WeaponLeft"] = getOrCreateMotor6D(
			leftArm,
			"WeaponLeft",
			leftArm,
			swordLeft,
			CFrame.new(0, -1.5, -0.5),
			CFrame.identity
		)
		motors["WeaponMouth"] = getOrCreateMotor6D(
			head,
			"WeaponMouth",
			head,
			swordMouth,
			CFrame.new(0, -0.2, -0.8),
			CFrame.identity
		)

		getOrCreateAttachment(swordRight, "BladeBase", CFrame.new(0, -0.5, 0))
		getOrCreateAttachment(swordRight, "BladeTip", CFrame.new(0, 2.5, 0))
		getOrCreateAttachment(swordLeft, "BladeBase", CFrame.new(0, -0.5, 0))
		getOrCreateAttachment(swordLeft, "BladeTip", CFrame.new(0, 2.5, 0))
		getOrCreateAttachment(swordMouth, "BladeBase", CFrame.new(-1.5, 0, 0))
		getOrCreateAttachment(swordMouth, "BladeTip", CFrame.new(1.5, 0, 0))
	end

	-- Bind multi-part mesh parts and accessories into limb groups
	local semanticParts: { [string]: { BasePart } } = {
		Torso = {},
		Head = {},
		RightArm = {},
		LeftArm = {},
		RightLeg = {},
		LeftLeg = {},
		Weapon = {},
	}

	local conflictingWelds: { string } = {}
	local limbCounts: { [string]: number } = {
		Torso = 0,
		Head = 0,
		RightArm = 0,
		LeftArm = 0,
		RightLeg = 0,
		LeftLeg = 0,
		Weapon = 0,
	}

	-- Purge cross-joint rigid weld cycles that lock Motor6D articulation
	local anchorsSet: { [Instance]: BasePart } = {
		[torso] = torso,
		[head] = head,
		[rightArm] = rightArm,
		[leftArm] = leftArm,
		[rightLeg] = rightLeg,
		[leftLeg] = leftLeg,
		[root] = root,
	}

	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("WeldConstraint") or desc:IsA("Weld") then
			local p0 = (desc :: any).Part0
			local p1 = (desc :: any).Part1
			if p0 and p1 and anchorsSet[p0] and anchorsSet[p1] and anchorsSet[p0] ~= anchorsSet[p1] then
				table.insert(conflictingWelds, desc:GetFullName())
				desc:Destroy()
			end
		end
	end

	-- Map parts to appropriate semantic limb anchor
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and not anchorsSet[part] then
			local pName = part.Name
			local targetAnchor: BasePart = torso
			local groupKey = "Torso"

			if string.find(pName, "Head") or string.find(pName, "Hair") or string.find(pName, "Hat") or string.find(pName, "Face") or string.find(pName, "CloudScarf") or string.find(pName, "CowboyHat") then
				targetAnchor = head
				groupKey = "Head"
			elseif string.find(pName, "RightArm") or string.find(pName, "Right_Arm") or string.find(pName, "RightHand") or string.find(pName, "RightForearm") or (string.find(pName, "Arm") and string.find(pName, "_2")) then
				targetAnchor = rightArm
				groupKey = "RightArm"
			elseif string.find(pName, "LeftArm") or string.find(pName, "Left_Arm") or string.find(pName, "LeftHand") or string.find(pName, "LeftForearm") then
				targetAnchor = leftArm
				groupKey = "LeftArm"
			elseif string.find(pName, "RightLeg") or string.find(pName, "Right_Leg") or string.find(pName, "RightFoot") or (string.find(pName, "Leg") and string.find(pName, "_2")) then
				targetAnchor = rightLeg
				groupKey = "RightLeg"
			elseif string.find(pName, "LeftLeg") or string.find(pName, "Left_Leg") or string.find(pName, "LeftFoot") then
				targetAnchor = leftLeg
				groupKey = "LeftLeg"
			elseif string.find(pName, "Sword") or string.find(pName, "Weapon") or string.find(pName, "Blade") or string.find(pName, "Naginata") or string.find(pName, "Kikoku") then
				targetAnchor = rightArm
				groupKey = "Weapon"
			end

			table.insert(semanticParts[groupKey], part)
			limbCounts[groupKey] += 1

			-- Ensure part is rigidly locked to its parent semantic anchor
			local existingWeld = part:FindFirstChild("LimbSemanticWeld")
			if not existingWeld then
				local weld = Instance.new("WeldConstraint")
				weld.Name = "LimbSemanticWeld"
				weld.Part0 = targetAnchor
				weld.Part1 = part
				weld.Parent = part
			end
		end
	end

	-- Attachments resolution
	local attachments: { [string]: Attachment } = {}
	attachments["RootAttachment"] = getOrCreateAttachment(root, "RootAttachment", CFrame.identity)
	attachments["RightHandFlameAtt"] = getOrCreateAttachment(rightArm, "RightHandFlameAtt", CFrame.new(0, -1.1, 0))
	attachments["LeftHandFlameAtt"] = getOrCreateAttachment(leftArm, "LeftHandFlameAtt", CFrame.new(0, -1.1, 0))
	attachments["OverheadEnteiAtt"] = getOrCreateAttachment(rightArm, "OverheadEnteiAtt", CFrame.new(0, 3.5, 0))

	-- Rest snapshot capture
	local restSnapshot: RestSnapshot = {
		c0 = {},
		c1 = {},
		partSizes = {},
		attachmentCFrames = {},
	}

	for jName, motor in pairs(motors) do
		restSnapshot.c0[jName] = motor.C0
		restSnapshot.c1[jName] = motor.C1
	end

	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			restSnapshot.partSizes[desc] = desc.Size
		elseif desc:IsA("Attachment") then
			restSnapshot.attachmentCFrames[desc] = desc.CFrame
		end
	end

	local ctx: RigContext = {
		model = model,
		heroId = resolvedHeroId,
		logicalRoot = root,
		visualRoot = root,
		torso = torso,
		head = head,
		rightArm = rightArm,
		leftArm = leftArm,
		rightLeg = rightLeg,
		leftLeg = leftLeg,
		motors = motors,
		semanticParts = semanticParts,
		attachments = attachments,
		restSnapshot = restSnapshot,
		isZoroSantoryu = isZoro,
		isDestroyed = false,
	}

	activeContexts[model] = ctx

	local report: RigValidationReport = {
		isValid = true,
		code = "VALID",
		message = "Model successfully bound with semantic Motor6Ds and accessories",
		missingJoints = {},
		conflictingWelds = conflictingWelds,
		limbPartCounts = limbCounts,
	}

	return ctx, report
end

function RigBinder.Reset(ctx: RigContext)
	if ctx.isDestroyed or not ctx.model.Parent then
		return
	end

	-- Restore Motor6D transforms
	for jName, motor in pairs(ctx.motors) do
		local defaultC0 = ctx.restSnapshot.c0[jName]
		local defaultC1 = ctx.restSnapshot.c1[jName]
		if defaultC0 and motor.Parent then
			motor.C0 = defaultC0
			motor.C1 = defaultC1 or CFrame.identity
			motor.Transform = CFrame.identity
		end
	end

	-- Restore part sizes
	for part, origSize in pairs(ctx.restSnapshot.partSizes) do
		if part.Parent and (part.Size - origSize).Magnitude > 0.0001 then
			part.Size = origSize
		end
	end

	-- Restore attachment transforms
	for att, origCF in pairs(ctx.restSnapshot.attachmentCFrames) do
		if att.Parent then
			att.CFrame = origCF
		end
	end
end

function RigBinder.GetActiveContext(model: Model): RigContext?
	return activeContexts[model]
end

function RigBinder.BindSemanticRig(model: Model, options: any?): { [JointName]: Motor6D }
	local heroId = (options and options.heroId) or model.Name
	local isLab = (options and options.isLabDummy) or false
	local ctx, _ = RigBinder.Bind(model, heroId, isLab)
	return ctx.motors
end

function RigBinder.CaptureRestPose(model: Model): any
	local ctx = activeContexts[model]
	if not ctx then
		local newCtx, _ = RigBinder.Bind(model, model.Name, false)
		ctx = newCtx
	end
	return {
		joints = {
			RightShoulder = { C0 = ctx.motors.RightShoulder and ctx.motors.RightShoulder.C0 or CFrame.identity },
		},
		snapshot = ctx.restSnapshot,
	}
end

function RigBinder.RestoreRestPose(model: Model, snapshot: any?)
	local ctx = activeContexts[model]
	if ctx then
		if snapshot and snapshot.snapshot then
			ctx.restSnapshot = snapshot.snapshot
		end
		RigBinder.Reset(ctx)
		if snapshot and snapshot.joints and snapshot.joints.RightShoulder and ctx.motors.RightShoulder then
			ctx.motors.RightShoulder.C0 = snapshot.joints.RightShoulder.C0
		end
	end
end

return table.freeze(RigBinder)
