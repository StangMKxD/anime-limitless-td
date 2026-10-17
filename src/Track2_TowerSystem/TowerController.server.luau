--!strict
-- src/Track2_TowerSystem/TowerController.server.luau
-- Anime Limitless Tower Defense — Phase 3: Grand Line Tower System with Masterpiece One Piece VFX, Tactical Pads, Gacha & Combat Engine
-- Complies with Modular Zero-Conflict Architecture & Canonical Rules R01-R08

local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(SharedFolder:WaitForChild("GameConfig")) :: any

-- =============================================================================
-- TYPE DEFINITIONS
-- =============================================================================

type BagUnit = {
	Uid: string,
	HeroId: string,
	Name: string,
	Rarity: string,
	SellValue: number,
}

-- =============================================================================
-- REMOTE EVENTS INITIALIZATION (IDEMPOTENT BOOTSTRAP)
-- =============================================================================

local function getOrCreateRemote(remoteName: string): RemoteEvent
	local existing = ReplicatedStorage:FindFirstChild(remoteName)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local rem = Instance.new("RemoteEvent")
	rem.Name = remoteName
	rem.Parent = ReplicatedStorage
	return rem
end

local SummonRerollRemote = getOrCreateRemote(GameConfig.REMOTES.TOWER_SUMMON_REROLL)
local PlacementActionRemote = getOrCreateRemote(GameConfig.REMOTES.TOWER_PLACEMENT_ACTION)
local CameraShakeRemote = getOrCreateRemote(GameConfig.REMOTES.VFX_CAMERA_SHAKE)
local TowerPresentationRemote = getOrCreateRemote("TowerPresentationEvent")

-- =============================================================================
-- WORKSPACE CONTAINERS (ZERO INITIAL TOWERS CONTRACT)
-- =============================================================================

local towersFolder = Workspace:FindFirstChild("AnimeTowers") :: Folder?
if not towersFolder then
	towersFolder = Instance.new("Folder")
	towersFolder.Name = "AnimeTowers"
	towersFolder.Parent = Workspace
else
	towersFolder:ClearAllChildren()
end

local padsFolder = Workspace:FindFirstChild("TowerPlacementPads") :: Folder?
if not padsFolder then
	padsFolder = Instance.new("Folder")
	padsFolder.Name = "TowerPlacementPads"
	padsFolder.Parent = Workspace
end

local slotOccupants: { [string]: Model? } = {}
local slotPadParts: { [string]: Part } = {}
local lastAttackTime: { [Model]: number } = {}

type LimbRig = {
	Head: Motor6D?,
	RightArm: Motor6D?,
	RightWeapon: Motor6D?,
	LeftArm: Motor6D?,
	LeftLeg: Motor6D?,
	RightLeg: Motor6D?,
	Aura: Motor6D?,
}
local towerRigs: { [Model]: LimbRig } = {}

-- =============================================================================
-- RIGGING & PHYSICS CONSTRAINT HELPERS (F-01 WELDCONSTRAINTS)
-- =============================================================================

local function weldToRoot(childPart: BasePart, rootPart: BasePart): WeldConstraint
	local weld = Instance.new("WeldConstraint")
	weld.Name = childPart.Name .. "WeldConstraint"
	weld.Part0 = rootPart
	weld.Part1 = childPart
	weld.Parent = childPart
	childPart.Anchored = false
	return weld
end

-- =============================================================================
-- DATA LOOKUP & INVENTORY SERIALIZATION HELPERS
-- =============================================================================

local STRAW_HAT_FALLBACKS: { [string]: any } = {
	Tower_Nami_Zeus = {
		Id = "Tower_Nami_Zeus",
		Name = "NAMI",
		Subtitle = "WEATHER EMPRESS [ZEUS]",
		Rarity = "LEGENDARY HAKI",
		Weight = 14,
		DamageMult = 1.70,
		RangeBonus = 12,
		CooldownMult = 0.82,
		SplashBonus = 6,
		SellValue = 260,
		AttackStyle = "ZeusBreezeTempo",
		Onomatopoeia = "ZEUS!! (สายฟ้าพิโรธ!!)",
		PrimaryColor = Color3.fromRGB(255, 160, 30),
		SecondaryColor = Color3.fromRGB(255, 230, 80),
	},
	Tower_Usopp_Kabuto = {
		Id = "Tower_Usopp_Kabuto",
		Name = "USOPP",
		Subtitle = "GOD USOPP [KURO KABUTO]",
		Rarity = "LEGENDARY HAKI",
		Weight = 14,
		DamageMult = 1.65,
		RangeBonus = 18,
		CooldownMult = 0.90,
		SplashBonus = 5,
		SellValue = 250,
		AttackStyle = "FirebirdStar",
		Onomatopoeia = "FIREBIRD!! (วิหคเพลิงสไนเปอร์!!)",
		PrimaryColor = Color3.fromRGB(215, 140, 45),
		SecondaryColor = Color3.fromRGB(50, 215, 120),
	},
	Tower_Chopper_Monster = {
		Id = "Tower_Chopper_Monster",
		Name = "TONY TONY CHOPPER",
		Subtitle = "MONSTER POINT",
		Rarity = "EPIC HAKI",
		Weight = 22,
		DamageMult = 1.85,
		RangeBonus = 2,
		CooldownMult = 1.05,
		SplashBonus = 7,
		SellValue = 150,
		AttackStyle = "MonsterPoint",
		Onomatopoeia = "MONSTER!! (ฝ่ามืออสูรยักษ์!!)",
		PrimaryColor = Color3.fromRGB(240, 110, 150),
		SecondaryColor = Color3.fromRGB(255, 215, 120),
	},
	Tower_Robin_Demonio = {
		Id = "Tower_Robin_Demonio",
		Name = "NICO ROBIN",
		Subtitle = "DEMONIO FLEUR",
		Rarity = "LEGENDARY HAKI",
		Weight = 14,
		DamageMult = 1.80,
		RangeBonus = 8,
		CooldownMult = 0.85,
		SplashBonus = 6,
		SellValue = 260,
		AttackStyle = "DemonioFleur",
		Onomatopoeia = "CLAP!! (มือปีศาจทมิฬ!!)",
		PrimaryColor = Color3.fromRGB(130, 40, 185),
		SecondaryColor = Color3.fromRGB(25, 15, 45),
	},
}

local function getHeroSpec(heroId: string): any
	for _, spec in ipairs(GameConfig.HERO_CATALOG) do
		if spec.Id == heroId then
			return spec
		end
	end
	if STRAW_HAT_FALLBACKS[heroId] then
		return STRAW_HAT_FALLBACKS[heroId]
	end
	return GameConfig.HERO_CATALOG[1]
end

local function decodeBag(player: Player): { BagUnit }
	local raw = (player:GetAttribute(GameConfig.PLAYER_ATTRS.INVENTORY_JSON) :: string?) or "[]"
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if ok and type(decoded) == "table" then
		return decoded :: { BagUnit }
	end
	return {}
end

local function encodeBag(player: Player, bag: { BagUnit })
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(bag)
	end)
	if ok then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.INVENTORY_JSON, encoded)
	end
end

local function rollWeightedHero(): any
	local totalWeight = 0
	for _, h in ipairs(GameConfig.HERO_CATALOG) do
		totalWeight += h.Weight
	end
	local pick = math.random() * totalWeight
	local cumulative = 0
	for _, h in ipairs(GameConfig.HERO_CATALOG) do
		cumulative += h.Weight
		if pick <= cumulative then
			return h
		end
	end
	return GameConfig.HERO_CATALOG[1]
end

local function recountPlayerTowers(player: Player)
	local count = 0
	for _, tower in ipairs((towersFolder :: Folder):GetChildren()) do
		if tower:GetAttribute("OwnerUserId") == player.UserId then
			count += 1
		end
	end
	player:SetAttribute(GameConfig.PLAYER_ATTRS.PLACED_TOWERS_COUNT, count)
end

local function updatePadVisual(slotId: string)
	local pad = slotPadParts[slotId]
	if not pad then
		return
	end
	local occupant = slotOccupants[slotId]
	local bb = pad:FindFirstChild("PadBillboard")
	local lbl = bb and bb:FindFirstChild("Label") :: TextLabel?
	if occupant and occupant.Parent then
		pad.Color = Color3.fromRGB(255, 200, 50)
		if lbl then
			local heroId = (occupant:GetAttribute("HeroId") :: string?) or ""
			local spec = getHeroSpec(heroId)
			lbl.Text = string.format("%s\n[%s]\n(คลิกเพื่อสลับตัว/จัดการ)", slotId, spec.Name)
		end
	else
		pad.Color = Color3.fromRGB(45, 235, 130)
		if lbl then
			lbl.Text = string.format("%s [EMPTY]\nคลิกเพื่อวางตัวละคร", slotId)
		end
	end
end

-- =============================================================================
-- AUTHENTIC ASSETKIT ALIASES & PROCEDURAL HELPERS
-- =============================================================================

local HERO_ALIASES: { [string]: string } = {
	Tower_Luffy_G5 = "Luffy",
	Tower_Shanks_Kamusari = "Shanks",
	Tower_Whitebeard_Gura = "Whitebeard",
	Tower_Zoro_KingOfHell = "Zoro",
	Tower_Ace_Entei = "Ace",
	Tower_Law_KRoom = "Law",
	Tower_Kizaru_Pika = "Kizaru",
	Tower_Sanji_Ifrit = "Sanji",
	Tower_Nami_Zeus = "Nami",
	Tower_Usopp_Kabuto = "Usopp",
	Tower_Chopper_Monster = "Chopper",
	Tower_Robin_Demonio = "Robin",
	Luffy = "Luffy",
	MonkeyDLuffy = "Luffy",
	MonkeyDLuffyModel = "Luffy",
	Zoro = "Zoro",
	RoronoaZoro = "Zoro",
	RoronoaZoroModel = "Zoro",
	Sanji = "Sanji",
	VinsmokeSanji = "Sanji",
	Shanks = "Shanks",
	RedHairedShanks = "Shanks",
	Whitebeard = "Whitebeard",
	EdwardNewgate = "Whitebeard",
	Ace = "Ace",
	PortgasDAce = "Ace",
	Law = "Law",
	TrafalgarLaw = "Law",
	Kizaru = "Kizaru",
	Borsalino = "Kizaru",
	Nami = "Nami",
	Usopp = "Usopp",
	Chopper = "Chopper",
	Robin = "Robin",
}

local function sanitizeImportedModel(model: Model)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("Script") or part:IsA("LocalScript") then
			part:Destroy()
		end
	end
end

local function attachHakiAuraEmitter(rootPart: BasePart, primaryColor: Color3, secondaryColor: Color3): ParticleEmitter
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "HakiAuraParticles"
	emitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, primaryColor),
		ColorSequenceKeypoint.new(1, secondaryColor),
	})
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4),
		NumberSequenceKeypoint.new(1, 1.8),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1.0),
	})
	emitter.Rate = 28
	emitter.Lifetime = NumberRange.new(0.4, 0.8)
	emitter.Speed = NumberRange.new(4, 9)
	emitter.SpreadAngle = Vector2.new(45, 45)
	emitter.Parent = rootPart
	return emitter
end

-- =============================================================================
-- PROCEDURAL R6 RIG BUILDER & DISTINCT ONE PIECE HERO ACCESSORIES (F-01 RIGGED)
-- =============================================================================

local function buildDetailedOnePieceModel(
	heroSpec: any,
	slotPos: Vector3,
	ownerUserId: number,
	unitUid: string,
	slotId: string
): Model
	local model = Instance.new("Model")
	model.Name = heroSpec.Id .. "_" .. slotId
	model:SetAttribute("HeroId", heroSpec.Id)
	model:SetAttribute("UnitUid", unitUid)
	model:SetAttribute("OwnerUserId", ownerUserId)
	model:SetAttribute("SlotId", slotId)
	model:SetAttribute("BaseY", slotPos.Y + 2.5)
	model:SetAttribute("IsAttacking", false)
	model:SetAttribute("Track2RigOwned", true)
	model:SetAttribute("RigReady", true)
	model:SetAttribute("VisualSource", "Track2")
	model:SetAttribute("RigVersion", "5.0.0")

	-- 1. HumanoidRootPart (Anchored = true, CanCollide = false)
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2.2, 2.4, 1.2)
	root.Position = slotPos + Vector3.new(0, 2.5, 0)
	root.Anchored = true
	root.CanCollide = false
	root.Material = Enum.Material.SmoothPlastic
	root.Color = heroSpec.PrimaryColor
	root.Parent = model
	attachHakiAuraEmitter(root, heroSpec.PrimaryColor, heroSpec.SecondaryColor)

	-- 2. Peach Skin Head (Rigged via WeldConstraint to Root)
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.5, 1.5, 1.5)
	head.Position = root.Position + Vector3.new(0, 1.95, 0)
	head.Anchored = true
	head.CanCollide = false
	head.Color = Color3.fromRGB(255, 222, 185)
	head.Parent = model
	weldToRoot(head, root)

	-- 3. Right Arm (Signature Secondary Neon, Rigged to Root)
	local rightArm = Instance.new("Part")
	rightArm.Name = "RightArm"
	rightArm.Size = Vector3.new(0.9, 2.2, 0.9)
	rightArm.Position = root.Position + Vector3.new(1.55, 0, 0)
	rightArm.Anchored = true
	rightArm.CanCollide = false
	rightArm.Material = Enum.Material.Neon
	rightArm.Color = heroSpec.SecondaryColor
	rightArm.Parent = model
	weldToRoot(rightArm, root)

	-- 4. Left Arm (Primary Color, Rigged to Root)
	local leftArm = Instance.new("Part")
	leftArm.Name = "LeftArm"
	leftArm.Size = Vector3.new(0.9, 2.2, 0.9)
	leftArm.Position = root.Position + Vector3.new(-1.55, 0, 0)
	leftArm.Anchored = true
	leftArm.CanCollide = false
	leftArm.Color = heroSpec.PrimaryColor
	leftArm.Parent = model
	weldToRoot(leftArm, root)

	-- 5. Continuous Rotating Neon Aura Ring at Base (Anchored to Pad)
	local auraRing = Instance.new("Part")
	auraRing.Name = "AuraRing"
	auraRing.Shape = Enum.PartType.Cylinder
	auraRing.Size = Vector3.new(0.35, 6.5, 6.5)
	auraRing.CFrame = CFrame.new(slotPos + Vector3.new(0, 0.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
	auraRing.Anchored = true
	auraRing.CanCollide = false
	auraRing.Material = Enum.Material.Neon
	auraRing.Color = heroSpec.SecondaryColor
	auraRing.Transparency = 0.35
	auraRing.Parent = model

	-- 6. Signature Weapon Tracking Right Arm (Rigged via WeldConstraint)
	local weapon = Instance.new("Part")
	weapon.Name = "SignatureWeapon"
	weapon.Size = Vector3.new(0.4, 0.4, 4.8)
	weapon.Position = rightArm.Position + Vector3.new(0, 0.5, -1.8)
	weapon.Anchored = true
	weapon.CanCollide = false
	weapon.Material = Enum.Material.Neon
	weapon.Color = heroSpec.SecondaryColor
	weapon.Parent = model
	weldToRoot(weapon, root)

	-- 7. Highlight Aura Shell
	local auraHighlight = Instance.new("Highlight")
	auraHighlight.Name = "AnimeAura"
	auraHighlight.FillColor = heroSpec.PrimaryColor
	auraHighlight.OutlineColor = heroSpec.SecondaryColor
	auraHighlight.FillTransparency = 0.55
	auraHighlight.Parent = model

	-- 8. Zero-Clutter Status BillboardGui on Head (TowerStatGui)
	local statusBb = Instance.new("BillboardGui")
	statusBb.Name = "TowerStatGui" -- statusBb.Name = "TowerStatusGui"
	statusBb.Size = UDim2.new(0, 90, 0, 22)
	statusBb.StudsOffset = Vector3.new(0, 2.6, 0)
	statusBb.AlwaysOnTop = false
	statusBb.MaxDistance = 38
	statusBb.Enabled = false
	statusBb.Parent = head

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Name = "InfoText"
	titleLbl.Size = UDim2.fromScale(1, 1)
	titleLbl.BackgroundTransparency = 0.35
	titleLbl.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
	titleLbl.TextColor3 = heroSpec.PrimaryColor
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextScaled = true
	titleLbl.Text = string.format("[%s] %s", heroSpec.Rarity, heroSpec.Name)
	titleLbl.Parent = statusBb

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 4)
	titleCorner.Parent = titleLbl

	-- 9. Procedural Signature Accessories for each of the 8 One Piece Heroes (Rigged via WeldConstraint)
	local style = heroSpec.AttackStyle

	if style == "BajrangFist" then
		-- Luffy: Floating Nika Cloud Scarf + Straw Hat
		local cloudScarf = Instance.new("Part")
		cloudScarf.Name = "Gear5CloudScarf"
		cloudScarf.Size = Vector3.new(3.4, 0.6, 1.8)
		cloudScarf.Position = root.Position + Vector3.new(0, 1.2, -0.6)
		cloudScarf.Anchored = true
		cloudScarf.CanCollide = false
		cloudScarf.Material = Enum.Material.Neon
		cloudScarf.Color = Color3.fromRGB(255, 255, 255)
		cloudScarf.Parent = model
		weldToRoot(cloudScarf, root)

		local strawHat = Instance.new("Part")
		strawHat.Name = "StrawHat"
		strawHat.Shape = Enum.PartType.Cylinder
		strawHat.Size = Vector3.new(0.2, 2.6, 2.6)
		strawHat.CFrame = CFrame.new(root.Position + Vector3.new(0, 1.1, -0.9)) * CFrame.Angles(0, 0, math.rad(90))
		strawHat.Anchored = true
		strawHat.CanCollide = false
		strawHat.Color = Color3.fromRGB(245, 205, 70)
		strawHat.Parent = model
		weldToRoot(strawHat, root)

	elseif style == "Kamusari" then
		-- Shanks: Charcoal Yonko Cape + Crimson Hair
		local cape = Instance.new("Part")
		cape.Name = "YonkoBlackCape"
		cape.Size = Vector3.new(2.8, 3.8, 0.35)
		cape.CFrame = CFrame.new(root.Position + Vector3.new(0, -0.2, -0.75)) * CFrame.Angles(math.rad(12), 0, 0)
		cape.Anchored = true
		cape.CanCollide = false
		cape.Color = Color3.fromRGB(22, 22, 28)
		cape.Parent = model
		weldToRoot(cape, root)

		local hair = Instance.new("Part")
		hair.Name = "ShanksRedHair"
		hair.Size = Vector3.new(1.6, 0.7, 1.6)
		hair.Position = head.Position + Vector3.new(0, 0.5, 0)
		hair.Anchored = true
		hair.CanCollide = false
		hair.Color = Color3.fromRGB(200, 25, 35)
		hair.Parent = model
		weldToRoot(hair, root)

	elseif style == "GuraQuake" then
		-- Whitebeard: Crescent Mustache + Broad Captain Coat
		local mustache = Instance.new("Part")
		mustache.Name = "CrescentMustache"
		mustache.Size = Vector3.new(1.8, 0.35, 0.3)
		mustache.Position = head.Position + Vector3.new(0, -0.2, 0.8)
		mustache.Anchored = true
		mustache.CanCollide = false
		mustache.Material = Enum.Material.SmoothPlastic
		mustache.Color = Color3.fromRGB(255, 255, 255)
		mustache.Parent = model
		weldToRoot(mustache, root)

		local coat = Instance.new("Part")
		coat.Name = "CaptainCoat"
		coat.Size = Vector3.new(3.4, 4.2, 0.5)
		coat.Position = root.Position + Vector3.new(0, -0.1, -0.8)
		coat.Anchored = true
		coat.CanCollide = false
		coat.Color = Color3.fromRGB(240, 245, 255)
		coat.Parent = model
		weldToRoot(coat, root)

	elseif style == "KingOfHell360" then
		-- Zoro: Sandai Kitetsu & Wado Ichimonji on hips + Green Hair
		local katanaLeft = Instance.new("Part")
		katanaLeft.Name = "SandaiKitetsu"
		katanaLeft.Size = Vector3.new(0.2, 0.25, 4.2)
		katanaLeft.CFrame = CFrame.new(root.Position + Vector3.new(-1.25, -0.4, 0)) * CFrame.Angles(math.rad(25), 0, 0)
		katanaLeft.Anchored = true
		katanaLeft.CanCollide = false
		katanaLeft.Color = Color3.fromRGB(180, 30, 40)
		katanaLeft.Parent = model
		weldToRoot(katanaLeft, root)

		local zoroHair = Instance.new("Part")
		zoroHair.Name = "ZoroHair"
		zoroHair.Size = Vector3.new(1.6, 0.65, 1.6)
		zoroHair.Position = head.Position + Vector3.new(0, 0.5, 0)
		zoroHair.Anchored = true
		zoroHair.CanCollide = false
		zoroHair.Color = Color3.fromRGB(50, 210, 85)
		zoroHair.Parent = model
		weldToRoot(zoroHair, root)

	elseif style == "Entei" then
		-- Ace: Flame Cowboy Hat + Red Bead Necklace
		local aceHat = Instance.new("Part")
		aceHat.Name = "AceCowboyHat"
		aceHat.Shape = Enum.PartType.Cylinder
		aceHat.Size = Vector3.new(0.3, 2.8, 2.8)
		aceHat.CFrame = CFrame.new(head.Position + Vector3.new(0, 0.75, 0)) * CFrame.Angles(0, 0, math.rad(90))
		aceHat.Anchored = true
		aceHat.CanCollide = false
		aceHat.Color = Color3.fromRGB(255, 115, 20)
		aceHat.Parent = model
		weldToRoot(aceHat, root)

		local beads = Instance.new("Part")
		beads.Name = "RedBeadNecklace"
		beads.Size = Vector3.new(1.6, 0.25, 1.3)
		beads.Position = head.Position + Vector3.new(0, -0.75, 0)
		beads.Anchored = true
		beads.CanCollide = false
		beads.Material = Enum.Material.Neon
		beads.Color = Color3.fromRGB(240, 25, 35)
		beads.Parent = model
		weldToRoot(beads, root)

	elseif style == "GammaKnife" then
		-- Law: Spotted Fur Hat
		local furHat = Instance.new("Part")
		furHat.Name = "LawFurHat"
		furHat.Size = Vector3.new(1.55, 1.0, 1.55)
		furHat.Position = head.Position + Vector3.new(0, 0.65, 0)
		furHat.Anchored = true
		furHat.CanCollide = false
		furHat.Color = Color3.fromRGB(240, 240, 245)
		furHat.Parent = model
		weldToRoot(furHat, root)

	elseif style == "YasakaniLight" then
		-- Kizaru: Marine Justice Admiral Cape + Tinted Glasses
		local justiceCape = Instance.new("Part")
		justiceCape.Name = "JusticeCape"
		justiceCape.Size = Vector3.new(3.0, 3.8, 0.4)
		justiceCape.Position = root.Position + Vector3.new(0, -0.15, -0.8)
		justiceCape.Anchored = true
		justiceCape.CanCollide = false
		justiceCape.Color = Color3.fromRGB(245, 245, 250)
		justiceCape.Parent = model
		weldToRoot(justiceCape, root)

		local glasses = Instance.new("Part")
		glasses.Name = "TintedGlasses"
		glasses.Size = Vector3.new(1.1, 0.25, 0.35)
		glasses.Position = head.Position + Vector3.new(0, 0.15, 0.8)
		glasses.Anchored = true
		glasses.CanCollide = false
		glasses.Material = Enum.Material.Neon
		glasses.Color = Color3.fromRGB(255, 215, 30)
		glasses.Parent = model
		weldToRoot(glasses, root)

	elseif style == "BoeufBurst" then
		-- Sanji: Sleek Blonde Hair + Golden Chest Tie
		local blondeHair = Instance.new("Part")
		blondeHair.Name = "BlondeHair"
		blondeHair.Size = Vector3.new(1.55, 0.7, 1.55)
		blondeHair.Position = head.Position + Vector3.new(0, 0.5, 0)
		blondeHair.Anchored = true
		blondeHair.CanCollide = false
		blondeHair.Color = Color3.fromRGB(255, 220, 60)
		blondeHair.Parent = model
		weldToRoot(blondeHair, root)

		local tie = Instance.new("Part")
		tie.Name = "GoldenTie"
		tie.Size = Vector3.new(0.35, 1.3, 0.15)
		tie.Position = root.Position + Vector3.new(0, 0.35, 0.65)
		tie.Anchored = true
		tie.CanCollide = false
		tie.Color = Color3.fromRGB(240, 205, 50)
		tie.Parent = model
		weldToRoot(tie, root)
	end

	-- Zero-Leak Garbage Collection Cleanup Guard (F-02)
	model.Destroying:Connect(function()
		lastAttackTime[model] = nil
	end)

	model.PrimaryPart = root
	model.Parent = towersFolder
	return model
end

-- =============================================================================
-- 3-TIER HYBRID MODEL LOADER (P1: RBXMX -> P2: R6 RIG -> P3: CLI FALLBACK)
-- =============================================================================

local function tryLoadFromHeroModels(
	heroSpec: any,
	slotPos: Vector3,
	ownerUserId: number,
	unitUid: string,
	slotId: string
): Model?
	local heroFolder = ReplicatedStorage:FindFirstChild("HeroModels")
	if not heroFolder then
		return nil
	end
	local templateName = HERO_ALIASES[heroSpec.Id] or heroSpec.Id
	local template = heroFolder:FindFirstChild(templateName) or heroFolder:FindFirstChild(heroSpec.Id)
	if not template or not template:IsA("Model") then
		for _, child in ipairs(heroFolder:GetChildren()) do
			if child:IsA("Model") and (child.Name == templateName or string.find(string.lower(child.Name), string.lower(templateName), 1, true)) then
				template = child
				break
			end
		end
	end
	if not template or not template:IsA("Model") then
		return nil
	end

	local model = template:Clone()
	model.Name = heroSpec.Id .. "_" .. slotId
	sanitizeImportedModel(model)

	-- Resolve or create HumanoidRootPart
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	if not root or not root:IsA("BasePart") then
		root = Instance.new("Part")
		root.Name = "HumanoidRootPart"
		root.Size = Vector3.new(2.2, 2.4, 1.2)
		root.Position = slotPos + Vector3.new(0, 2.5, 0)
		root.Anchored = true
		root.CanCollide = false
		root.Material = Enum.Material.SmoothPlastic
		root.Color = heroSpec.PrimaryColor
		root.Parent = model
	else
		root.Anchored = true
		root.CanCollide = false
		model:PivotTo(CFrame.new(slotPos + Vector3.new(0, 2.5, 0)))
	end

	-- 8-Joint Skeletal Limb Articulation Engine (Anchors & Motor6Ds)
	local rightArmAnchor = Instance.new("Part")
	rightArmAnchor.Name = "RightArm"
	rightArmAnchor.Size = Vector3.new(0.9, 2.2, 0.9)
	rightArmAnchor.Transparency = 1
	rightArmAnchor.CanCollide = false
	rightArmAnchor.CanTouch = false
	rightArmAnchor.CanQuery = false
	rightArmAnchor.Massless = true
	rightArmAnchor.CFrame = root.CFrame * CFrame.new(1.39, 0.75, 0)
	rightArmAnchor.Parent = model

	local rightShoulder = Instance.new("Motor6D")
	rightShoulder.Name = "RightShoulder"
	rightShoulder.Part0 = root
	rightShoulder.Part1 = rightArmAnchor
	rightShoulder.C0 = CFrame.new(1.39, 0.75, 0)
	rightShoulder.C1 = CFrame.new(0, 0, 0)
	rightShoulder.Parent = root

	local leftArmAnchor = Instance.new("Part")
	leftArmAnchor.Name = "LeftArm"
	leftArmAnchor.Size = Vector3.new(0.9, 2.2, 0.9)
	leftArmAnchor.Transparency = 1
	leftArmAnchor.CanCollide = false
	leftArmAnchor.CanTouch = false
	leftArmAnchor.CanQuery = false
	leftArmAnchor.Massless = true
	leftArmAnchor.CFrame = root.CFrame * CFrame.new(-1.39, 0.75, 0)
	leftArmAnchor.Parent = model

	local leftShoulder = Instance.new("Motor6D")
	leftShoulder.Name = "LeftShoulder"
	leftShoulder.Part0 = root
	leftShoulder.Part1 = leftArmAnchor
	leftShoulder.C0 = CFrame.new(-1.39, 0.75, 0)
	leftShoulder.C1 = CFrame.new(0, 0, 0)
	leftShoulder.Parent = root

	local signatureWeapon = Instance.new("Part")
	signatureWeapon.Name = "SignatureWeapon"
	signatureWeapon.Size = Vector3.new(0.5, 3.0, 0.5)
	signatureWeapon.Transparency = 1
	signatureWeapon.CanCollide = false
	signatureWeapon.CanTouch = false
	signatureWeapon.CanQuery = false
	signatureWeapon.Massless = true
	signatureWeapon.CFrame = root.CFrame * CFrame.new(1.63, -0.91, -0.50)
	signatureWeapon.Parent = model

	local rightWrist = Instance.new("Motor6D")
	rightWrist.Name = "RightWrist"
	rightWrist.Part0 = rightArmAnchor
	rightWrist.Part1 = signatureWeapon
	rightWrist.C0 = CFrame.new(0.24, -1.66, -0.50) * CFrame.Angles(math.rad(-65), 0, 0)
	rightWrist.C1 = CFrame.new(0, 0, 0)
	rightWrist.Parent = rightArmAnchor

	local leftLegAnchor = Instance.new("Part")
	leftLegAnchor.Name = "LeftLegAnchor"
	leftLegAnchor.Size = Vector3.new(0.9, 2.0, 0.9)
	leftLegAnchor.Transparency = 1
	leftLegAnchor.CanCollide = false
	leftLegAnchor.CanTouch = false
	leftLegAnchor.CanQuery = false
	leftLegAnchor.Massless = true
	leftLegAnchor.CFrame = root.CFrame * CFrame.new(-0.53, -0.60, 0)
	leftLegAnchor.Parent = model

	local leftHip = Instance.new("Motor6D")
	leftHip.Name = "LeftHip"
	leftHip.Part0 = root
	leftHip.Part1 = leftLegAnchor
	leftHip.C0 = CFrame.new(-0.53, -0.60, 0)
	leftHip.C1 = CFrame.new(0, 0, 0)
	leftHip.Parent = root

	local rightLegAnchor = Instance.new("Part")
	rightLegAnchor.Name = "RightLegAnchor"
	rightLegAnchor.Size = Vector3.new(0.9, 2.0, 0.9)
	rightLegAnchor.Transparency = 1
	rightLegAnchor.CanCollide = false
	rightLegAnchor.CanTouch = false
	rightLegAnchor.CanQuery = false
	rightLegAnchor.Massless = true
	rightLegAnchor.CFrame = root.CFrame * CFrame.new(0.53, -0.60, 0)
	rightLegAnchor.Parent = model

	local rightHip = Instance.new("Motor6D")
	rightHip.Name = "RightHip"
	rightHip.Part0 = root
	rightHip.Part1 = rightLegAnchor
	rightHip.C0 = CFrame.new(0.53, -0.60, 0)
	rightHip.C1 = CFrame.new(0, 0, 0)
	rightHip.Parent = root

	local headPart = model:FindFirstChild("Head") :: BasePart?
	local neckJoint: Motor6D? = nil
	if headPart then
		neckJoint = Instance.new("Motor6D")
		neckJoint.Name = "NeckJoint"
		neckJoint.Part0 = root
		neckJoint.Part1 = headPart
		neckJoint.C0 = CFrame.new(0, 1.89, 0)
		neckJoint.C1 = CFrame.new(0, 0, 0)
		neckJoint.Parent = root
	end

	local auraAnchor = Instance.new("Part")
	auraAnchor.Name = "AuraAnchor"
	auraAnchor.Size = Vector3.new(1, 0.1, 1)
	auraAnchor.Transparency = 1
	auraAnchor.CanCollide = false
	auraAnchor.CanTouch = false
	auraAnchor.CanQuery = false
	auraAnchor.Massless = true
	auraAnchor.CFrame = root.CFrame * CFrame.new(0, -2.35, 0)
	auraAnchor.Parent = model

	local auraMotor = Instance.new("Motor6D")
	auraMotor.Name = "AuraMotor"
	auraMotor.Part0 = root
	auraMotor.Part1 = auraAnchor
	auraMotor.C0 = CFrame.new(0, -2.35, 0)
	auraMotor.C1 = CFrame.new(0, 0, 0)
	auraMotor.Parent = root

	-- Unanchor and weld all constituent parts via WeldConstraint ("AssetKitRootWeld")
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part ~= root and part ~= rightArmAnchor and part ~= leftArmAnchor and part ~= signatureWeapon and part ~= leftLegAnchor and part ~= rightLegAnchor and part ~= auraAnchor and part ~= headPart then
			part.Anchored = false
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true

			local pName = part.Name
			local parentPart: BasePart = root

			if headPart and (pName == "Neck" or string.find(pName, "Nose") or string.find(pName, "Ear") or string.find(pName, "Eye") or string.find(pName, "Pupil") or string.find(pName, "Teeth") or string.find(pName, "Mouth") or string.find(pName, "Smile") or string.find(pName, "Smirk") or string.find(pName, "Jaw") or string.find(pName, "Chin") or string.find(pName, "Fang") or string.find(pName, "Bevel") or string.find(pName, "Hair") or string.find(pName, "Spike") or string.find(pName, "Bang") or string.find(pName, "Curtain") or string.find(pName, "Sweep") or string.find(pName, "Lock") or string.find(pName, "Afro") or string.find(pName, "Hat") or string.find(pName, "Straw") or string.find(pName, "Scar") or string.find(pName, "Glass") or string.find(pName, "Muzzle") or string.find(pName, "Antler") or string.find(pName, "Mustache") or string.find(pName, "Bandana") or string.find(pName, "Mask") or string.find(pName, "Horn") or pName == "MouthSword") then
				parentPart = headPart
			elseif string.find(pName, "SwordRight") or string.find(pName, "Gryphon") or string.find(pName, "Naginata") or string.find(pName, "Kikoku") or string.find(pName, "LightSword") or string.find(pName, "Slingshot") or string.find(pName, "FlameOrb") or pName == "Bone" or pName == "ClawBlade_2" or string.find(pName, "Kanabo") or string.find(pName, "Hilt") or string.find(pName, "Tsuba") or string.find(pName, "Pommel") or string.find(pName, "Blade") or string.find(pName, "Staff") or string.find(pName, "Sheath") or string.find(pName, "HakiFlame") then
				parentPart = signatureWeapon
			elseif string.find(pName, "SwordLeft") or string.find(pName, "ClimaTact") or pName == "TactTop" or (string.find(pName, "ClawBlade") and not string.find(pName, "_2")) then
				parentPart = leftArmAnchor
			elseif string.find(pName, "_2") and (string.find(pName, "Shoulder") or string.find(pName, "Arm") or string.find(pName, "Forearm") or string.find(pName, "Fist") or string.find(pName, "Knuckle") or string.find(pName, "Sleeve") or string.find(pName, "Hand")) or string.find(pName, "BlackHakiFist") then
				parentPart = rightArmAnchor
			elseif (string.find(pName, "Shoulder") or string.find(pName, "Arm") or string.find(pName, "Forearm") or string.find(pName, "Fist") or string.find(pName, "Knuckle") or string.find(pName, "Sleeve") or string.find(pName, "Hand")) and not string.find(pName, "_2") then
				parentPart = leftArmAnchor
			elseif string.find(pName, "_2") and (string.find(pName, "Thigh") or string.find(pName, "Shin") or string.find(pName, "Leg") or string.find(pName, "Boot") or string.find(pName, "Toe") or string.find(pName, "IfritFlame")) or (string.find(pName, "ShortsCuff") and part.Position.X >= root.Position.X) then
				parentPart = rightLegAnchor
			elseif (string.find(pName, "Thigh") or string.find(pName, "Shin") or string.find(pName, "Leg") or string.find(pName, "Boot") or string.find(pName, "Toe")) and not string.find(pName, "_2") or (string.find(pName, "ShortsCuff") and part.Position.X < root.Position.X) then
				parentPart = leftLegAnchor
			elseif string.find(pName, "Aura") or string.find(pName, "HakiGround") or string.find(pName, "Lightning") or string.find(pName, "Shard") or string.find(pName, "EnergyOrb") or string.find(pName, "ZeusCloud") or string.find(pName, "CloudPuff") or string.find(pName, "CloudEye") then
				parentPart = auraAnchor
			else
				parentPart = root
			end

			local weld = Instance.new("WeldConstraint")
			weld.Name = "AssetKitRootWeld"
			weld.Part0 = root
			weld.Part1 = part
			weld.Parent = part
			if parentPart ~= root then
				weld.Part0 = parentPart
			end
		end
	end

	towerRigs[model] = {
		Head = neckJoint,
		RightArm = rightShoulder,
		RightWeapon = rightWrist,
		LeftArm = leftShoulder,
		LeftLeg = leftHip,
		RightLeg = rightHip,
		Aura = auraMotor,
	}

	model:SetAttribute("HeroId", heroSpec.Id)
	model:SetAttribute("UnitUid", unitUid)
	model:SetAttribute("OwnerUserId", ownerUserId)
	model:SetAttribute("SlotId", slotId)
	model:SetAttribute("BaseY", slotPos.Y + 2.5)
	model:SetAttribute("IsAttacking", false)
	model:SetAttribute("AssetKitSkinned", true)
	model:SetAttribute("IsArticulatedRig", true)
	model:SetAttribute("Track2RigOwned", true)
	model:SetAttribute("RigReady", true)
	model:SetAttribute("VisualSource", "Track2")
	model:SetAttribute("RigVersion", "5.0.0")

	attachHakiAuraEmitter(root, heroSpec.PrimaryColor, heroSpec.SecondaryColor)

	-- Zero-Clutter Tower Head Nameplate (TowerStatGui)
	local statusBb = Instance.new("BillboardGui")
	statusBb.Name = "TowerStatGui" -- statusBb.Name = "TowerStatusGui"
	statusBb.Size = UDim2.new(0, 90, 0, 22)
	statusBb.StudsOffset = Vector3.new(0, 2.6, 0)
	statusBb.AlwaysOnTop = false
	statusBb.MaxDistance = 38
	statusBb.Enabled = false
	statusBb.Parent = root

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Name = "InfoText"
	titleLbl.Size = UDim2.fromScale(1, 1)
	titleLbl.BackgroundTransparency = 0.35
	titleLbl.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
	titleLbl.TextColor3 = heroSpec.PrimaryColor
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextScaled = true
	titleLbl.Text = string.format("[%s] %s", heroSpec.Rarity, heroSpec.Name)
	titleLbl.Parent = statusBb

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 4)
	titleCorner.Parent = titleLbl

	-- Aura ring & Highlight
	local auraRing = Instance.new("Part")
	auraRing.Name = "AuraRing"
	auraRing.Shape = Enum.PartType.Cylinder
	auraRing.Size = Vector3.new(0.35, 6.5, 6.5)
	auraRing.CFrame = CFrame.new(slotPos + Vector3.new(0, 0.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
	auraRing.Anchored = true
	auraRing.CanCollide = false
	auraRing.Material = Enum.Material.Neon
	auraRing.Color = heroSpec.SecondaryColor
	auraRing.Transparency = 0.35
	auraRing.Parent = model

	local auraHighlight = Instance.new("Highlight")
	auraHighlight.Name = "AnimeAura"
	auraHighlight.FillColor = heroSpec.PrimaryColor
	auraHighlight.OutlineColor = heroSpec.SecondaryColor
	auraHighlight.FillTransparency = 0.55
	auraHighlight.Parent = model

	model.Destroying:Connect(function()
		lastAttackTime[model] = nil
		towerRigs[model] = nil
	end)

	model.PrimaryPart = root
	model.Parent = towersFolder
	return model
end

local function tryLoadFromHumanoidDescription(
	heroSpec: any,
	slotPos: Vector3,
	ownerUserId: number,
	unitUid: string,
	slotId: string
): Model?
	local ok, model = pcall(function()
		local desc = Instance.new("HumanoidDescription")
		return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
	end)
	if not ok or not model or not model:IsA("Model") then
		return nil
	end

	model.Name = heroSpec.Id .. "_" .. slotId
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	if not root or not root:IsA("BasePart") then
		model:Destroy()
		return nil
	end

	root.Anchored = true
	root.CanCollide = false
	model:PivotTo(CFrame.new(slotPos + Vector3.new(0, 2.5, 0)))

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") and part ~= root then
			part.Anchored = false
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true
			local weld = Instance.new("WeldConstraint")
			weld.Name = "AssetKitRootWeld"
			weld.Part0 = root
			weld.Part1 = part
			weld.Parent = part
		end
	end

	model:SetAttribute("HeroId", heroSpec.Id)
	model:SetAttribute("UnitUid", unitUid)
	model:SetAttribute("OwnerUserId", ownerUserId)
	model:SetAttribute("SlotId", slotId)
	model:SetAttribute("BaseY", slotPos.Y + 2.5)
	model:SetAttribute("IsAttacking", false)
	model:SetAttribute("AssetKitSkinned", true)
	model:SetAttribute("Track2RigOwned", true)
	model:SetAttribute("RigReady", true)
	model:SetAttribute("VisualSource", "Track2")
	model:SetAttribute("RigVersion", "5.0.0")

	attachHakiAuraEmitter(root, heroSpec.PrimaryColor, heroSpec.SecondaryColor)

	local statusBb = Instance.new("BillboardGui")
	statusBb.Name = "TowerStatGui" -- statusBb.Name = "TowerStatusGui"
	statusBb.Size = UDim2.new(0, 90, 0, 22)
	statusBb.StudsOffset = Vector3.new(0, 2.6, 0)
	statusBb.AlwaysOnTop = false
	statusBb.MaxDistance = 38
	statusBb.Enabled = false
	statusBb.Parent = root

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Name = "InfoText"
	titleLbl.Size = UDim2.fromScale(1, 1)
	titleLbl.BackgroundTransparency = 0.35
	titleLbl.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
	titleLbl.TextColor3 = heroSpec.PrimaryColor
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextScaled = true
	titleLbl.Text = string.format("[%s] %s", heroSpec.Rarity, heroSpec.Name)
	titleLbl.Parent = statusBb

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0, 4)
	titleCorner.Parent = titleLbl

	local auraRing = Instance.new("Part")
	auraRing.Name = "AuraRing"
	auraRing.Shape = Enum.PartType.Cylinder
	auraRing.Size = Vector3.new(0.35, 6.5, 6.5)
	auraRing.CFrame = CFrame.new(slotPos + Vector3.new(0, 0.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
	auraRing.Anchored = true
	auraRing.CanCollide = false
	auraRing.Material = Enum.Material.Neon
	auraRing.Color = heroSpec.SecondaryColor
	auraRing.Transparency = 0.35
	auraRing.Parent = model

	local auraHighlight = Instance.new("Highlight")
	auraHighlight.Name = "AnimeAura"
	auraHighlight.FillColor = heroSpec.PrimaryColor
	auraHighlight.OutlineColor = heroSpec.SecondaryColor
	auraHighlight.FillTransparency = 0.55
	auraHighlight.Parent = model

	model.Destroying:Connect(function()
		lastAttackTime[model] = nil
	end)

	model.PrimaryPart = root
	model.Parent = towersFolder
	return model
end

local function loadAuthenticHeroModel(
	heroSpec: any,
	slotPos: Vector3,
	ownerUserId: number,
	unitUid: string,
	slotId: string
): Model
	-- Priority 1: Clone authentic .rbxmx XML model from ReplicatedStorage.HeroModels
	local m1 = tryLoadFromHeroModels(heroSpec, slotPos, ownerUserId, unitUid, slotId)
	if m1 then
		return m1
	end

	-- Priority 2: Authentic Players:CreateHumanoidModelFromDescription R6 rig
	local m2 = tryLoadFromHumanoidDescription(heroSpec, slotPos, ownerUserId, unitUid, slotId)
	if m2 then
		return m2
	end

	-- Priority 3: Headless CLI procedural fallback (buildDetailedOnePieceModel)
	return buildDetailedOnePieceModel(heroSpec, slotPos, ownerUserId, unitUid, slotId)
end

-- =============================================================================
-- 3D MANGA ONOMATOPOEIA BILLBOARD SYSTEM (GOTHAM BLACK & BACK.OUT TWEEN)
-- =============================================================================

local function spawnMangaBillboard(pos: Vector3, text: string, color: Color3)
	local anchor = Instance.new("Part")
	anchor.Name = "MangaBillboardAnchor"
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Position = pos + Vector3.new(0, 4, 0)
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Transparency = 1
	anchor.Parent = Workspace

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(240, 72)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.Parent = anchor

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = color
	lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	lbl.TextStrokeTransparency = 0
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextScaled = true
	lbl.Text = text
	lbl.Parent = bb

	TweenService:Create(anchor, TweenInfo.new(0.85, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = pos + Vector3.new(0, 12, 0),
	}):Play()

	task.delay(0.45, function()
		if lbl.Parent then
			TweenService:Create(lbl, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 1,
				TextStrokeTransparency = 1,
			}):Play()
		end
	end)

	Debris:AddItem(anchor, 0.95)
end

-- =============================================================================
-- RADIAL CONQUEROR'S HAKI LIGHTNING BOLTS (JAGGED NEON ARCS)
-- =============================================================================

local function spawnHakiLightningBolts(origin: Vector3, color: Color3, boltCount: number)
	for i = 1, boltCount do
		local angle = math.rad((360 / boltCount) * i + math.random(-15, 15))
		local boltLength = math.random(8, 16)
		local offset = Vector3.new(math.cos(angle) * 5, math.random(1, 7), math.sin(angle) * 5)
		local target = origin + offset

		if (target - origin).Magnitude >= 0.05 then
			local bolt = Instance.new("Part")
			bolt.Name = "HakiLightningBolt"
			bolt.Size = Vector3.new(0.45, 0.45, boltLength)
			bolt.CFrame = CFrame.lookAt(origin, target) * CFrame.new(0, 0, -boltLength * 0.5)
			bolt.Anchored = true
			bolt.CanCollide = false
			bolt.Material = Enum.Material.Neon
			bolt.Color = color
			bolt.Parent = Workspace

			TweenService:Create(bolt, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = Vector3.new(0.05, 0.05, boltLength * 1.3),
			}):Play()

			Debris:AddItem(bolt, 0.35)
		end
	end
end

-- =============================================================================
-- 8 SIGNATURE ONE PIECE ULTIMATE VFX IMPLEMENTATIONS (MASTERPIECE QUALITY)
-- =============================================================================

local function playOnePieceUltimateVFX(heroModel: Model, heroSpec: any, targetPos: Vector3)
	local root = heroModel.PrimaryPart
	if not root then
		return
	end
	local style = heroSpec.AttackStyle
	local startPos = root.Position

	-- 1. Dynamic PointLight Injection
	local impactLight = Instance.new("PointLight")
	impactLight.Name = "ImpactFlashLight"
	impactLight.Color = heroSpec.SecondaryColor
	impactLight.Brightness = 8
	impactLight.Range = 40
	impactLight.Shadows = false

	local lightAnchor = Instance.new("Part")
	lightAnchor.Name = "LightAnchor"
	lightAnchor.Size = Vector3.new(0.5, 0.5, 0.5)
	lightAnchor.Position = targetPos + Vector3.new(0, 3, 0)
	lightAnchor.Anchored = true
	lightAnchor.CanCollide = false
	lightAnchor.Transparency = 1
	lightAnchor.Parent = Workspace
	impactLight.Parent = lightAnchor

	TweenService:Create(impactLight, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = 0,
	}):Play()
	Debris:AddItem(lightAnchor, 0.40)

	-- -------------------------------------------------------------------------
	-- STYLE 1: BAJRANG FIST (MONKEY D. LUFFY - SUN GOD NIKA GEAR 5)
	-- -------------------------------------------------------------------------
	if style == "BajrangFist" then
		local portal = Instance.new("Part")
		portal.Name = "NikaSkyPortal"
		portal.Shape = Enum.PartType.Cylinder
		portal.Size = Vector3.new(1.2, 36, 36)
		portal.CFrame = CFrame.new(targetPos + Vector3.new(0, 34, 0)) * CFrame.Angles(0, 0, math.rad(90))
		portal.Anchored = true
		portal.CanCollide = false
		portal.Material = Enum.Material.Neon
		portal.Color = Color3.fromRGB(25, 20, 35)
		portal.Parent = Workspace

		local giantFist = Instance.new("Part")
		giantFist.Name = "BajrangGiantFist"
		giantFist.Shape = Enum.PartType.Ball
		giantFist.Size = Vector3.new(26, 26, 26)
		giantFist.Position = targetPos + Vector3.new(0, 34, 0)
		giantFist.Anchored = true
		giantFist.CanCollide = false
		giantFist.Material = Enum.Material.Neon
		giantFist.Color = Color3.fromRGB(255, 248, 255)
		giantFist.Parent = Workspace

		local shockwave = Instance.new("Part")
		shockwave.Name = "BajrangShockwave"
		shockwave.Shape = Enum.PartType.Cylinder
		shockwave.Size = Vector3.new(0.5, 4, 4)
		shockwave.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
		shockwave.Anchored = true
		shockwave.CanCollide = false
		shockwave.Material = Enum.Material.Neon
		shockwave.Color = Color3.fromRGB(255, 45, 95)
		shockwave.Parent = Workspace

		local shockwave2 = Instance.new("Part")
		shockwave2.Name = "ShockwaveRing_2"
		shockwave2.Shape = Enum.PartType.Cylinder
		shockwave2.Size = Vector3.new(0.4, 4, 4)
		shockwave2.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.6, 0)) * CFrame.Angles(0, 0, math.rad(90))
		shockwave2.Anchored = true
		shockwave2.CanCollide = false
		shockwave2.Material = Enum.Material.Neon
		shockwave2.Color = Color3.fromRGB(255, 120, 150)
		shockwave2.Parent = Workspace

		local shockwave3 = Instance.new("Part")
		shockwave3.Name = "ShockwaveRing_3"
		shockwave3.Shape = Enum.PartType.Cylinder
		shockwave3.Size = Vector3.new(0.3, 4, 4)
		shockwave3.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.7, 0)) * CFrame.Angles(0, 0, math.rad(90))
		shockwave3.Anchored = true
		shockwave3.CanCollide = false
		shockwave3.Material = Enum.Material.Neon
		shockwave3.Color = Color3.fromRGB(255, 255, 255)
		shockwave3.Parent = Workspace

		TweenService:Create(portal, TweenInfo.new(0.35), {
			Size = Vector3.new(0.1, 44, 44),
			Transparency = 1,
		}):Play()

		TweenService:Create(giantFist, TweenInfo.new(0.28, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			Position = targetPos + Vector3.new(0, 2, 0),
			Color = Color3.fromRGB(255, 35, 85),
		}):Play()

		TweenService:Create(shockwave, TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.2, 35, 35),
			Transparency = 1,
		}):Play()
		TweenService:Create(shockwave2, TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.15, 28, 28),
			Transparency = 1,
		}):Play()
		TweenService:Create(shockwave3, TweenInfo.new(0.46, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, 20, 20),
			Transparency = 1,
		}):Play()

		Debris:AddItem(portal, 0.45)
		Debris:AddItem(giantFist, 0.55)
		Debris:AddItem(shockwave, 0.45)
		Debris:AddItem(shockwave2, 0.50)
		Debris:AddItem(shockwave3, 0.52)
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(255, 20, 65), 10)

	-- -------------------------------------------------------------------------
	-- STYLE 2: KAMUSARI (RED-HAIRED SHANKS - DIVINE DEPARTURE)
	-- -------------------------------------------------------------------------
	elseif style == "Kamusari" then
		local forwardDir = (targetPos - startPos).Unit
		local crescent = Instance.new("Part")
		crescent.Name = "KamusariCrescentSlash"
		crescent.Size = Vector3.new(42, 1.4, 9)
		crescent.CFrame = CFrame.lookAt(startPos, targetPos) * CFrame.Angles(0, 0, math.rad(35))
		crescent.Anchored = true
		crescent.CanCollide = false
		crescent.Material = Enum.Material.Neon
		crescent.Color = Color3.fromRGB(225, 20, 48)
		crescent.Parent = Workspace

		local destCF = CFrame.lookAt(targetPos + forwardDir * 10, targetPos + forwardDir * 18)
			* CFrame.Angles(0, 0, math.rad(35))

		TweenService:Create(crescent, TweenInfo.new(0.30, Enum.EasingStyle.Linear), {
			CFrame = destCF,
			Size = Vector3.new(48, 2.2, 14),
			Transparency = 1,
		}):Play()

		local shockwave = Instance.new("Part")
		shockwave.Name = "KamusariShockRing"
		shockwave.Shape = Enum.PartType.Cylinder
		shockwave.Size = Vector3.new(0.4, 4, 4)
		shockwave.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
		shockwave.Anchored = true
		shockwave.CanCollide = false
		shockwave.Material = Enum.Material.Neon
		shockwave.Color = Color3.fromRGB(235, 20, 50)
		shockwave.Parent = Workspace

		TweenService:Create(shockwave, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, 32, 32),
			Transparency = 1,
		}):Play()

		for i = 1, 12 do
			local angle = math.rad((360 / 12) * i + math.random(-10, 10))
			local strikePos = targetPos + Vector3.new(math.cos(angle) * math.random(4, 16), 0, math.sin(angle) * math.random(4, 16))
			local strike = Instance.new("Part")
			strike.Name = "VerticalHakiStrike"
			strike.Size = Vector3.new(0.5, 24, 0.5)
			strike.Position = strikePos + Vector3.new(0, 12, 0)
			strike.Anchored = true
			strike.CanCollide = false
			strike.Material = Enum.Material.Neon
			strike.Color = Color3.fromRGB(255, 25, 55)
			strike.Parent = Workspace
			TweenService:Create(strike, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = Vector3.new(0.05, 24, 0.05),
			}):Play()
			Debris:AddItem(strike, 0.35)
		end

		Debris:AddItem(crescent, 0.38)
		Debris:AddItem(shockwave, 0.40)
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(255, 25, 55), 12)

	-- -------------------------------------------------------------------------
	-- STYLE 3: GURA QUAKE (EDWARD NEWGATE - WHITEBEARD)
	-- -------------------------------------------------------------------------
	elseif style == "GuraQuake" then
		-- Mid-Air Glass Shatter Cracks (7 Fracture Beams)
		for c = 1, 7 do
			local crack = Instance.new("Part")
			crack.Name = "TremorGlassCrack"
			crack.Size = Vector3.new(0.35, 0.35, math.random(10, 18))
			crack.CFrame = CFrame.new(targetPos + Vector3.new(0, 3.5, 0))
				* CFrame.Angles(math.rad(math.random(-65, 65)), math.rad(c * 51), math.rad(math.random(-25, 25)))
			crack.Anchored = true
			crack.CanCollide = false
			crack.Material = Enum.Material.Neon
			crack.Color = Color3.fromRGB(245, 252, 255)
			crack.Parent = Workspace

			TweenService:Create(crack, TweenInfo.new(0.48), {
				Transparency = 1,
			}):Play()
			Debris:AddItem(crack, 0.52)
		end

		-- Expanding Tremor ForceField Dome
		local tremorDome = Instance.new("Part")
		tremorDome.Name = "TremorDome"
		tremorDome.Shape = Enum.PartType.Ball
		tremorDome.Size = Vector3.new(4, 4, 4)
		tremorDome.Position = targetPos
		tremorDome.Anchored = true
		tremorDome.CanCollide = false
		tremorDome.Material = Enum.Material.ForceField
		tremorDome.Color = Color3.fromRGB(110, 200, 255)
		tremorDome.Transparency = 0.25
		tremorDome.Parent = Workspace

		TweenService:Create(tremorDome, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new(28, 28, 28),
			Transparency = 1,
		}):Play()

		-- Ground Shockwave Ring
		local seaRing = Instance.new("Part")
		seaRing.Name = "SeaQuakeRing"
		seaRing.Shape = Enum.PartType.Cylinder
		seaRing.Size = Vector3.new(0.4, 4, 4)
		seaRing.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
		seaRing.Anchored = true
		seaRing.CanCollide = false
		seaRing.Material = Enum.Material.Neon
		seaRing.Color = Color3.fromRGB(110, 200, 255)
		seaRing.Parent = Workspace

		TweenService:Create(seaRing, TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, 32, 32),
			Transparency = 1,
		}):Play()

		Debris:AddItem(tremorDome, 0.48)
		Debris:AddItem(seaRing, 0.48)
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(140, 220, 255), 8)

	-- -------------------------------------------------------------------------
	-- STYLE 4: KING OF HELL 360 (RORONOA ZORO - ENMA TORNADO)
	-- -------------------------------------------------------------------------
	elseif style == "KingOfHell360" then
		-- Triple emerald/purple dragon tornados 38 studs tall
		for t = 1, 3 do
			local offsetAngle = math.rad((360 / 3) * t)
			local tOffset = Vector3.new(math.cos(offsetAngle) * 5, 0, math.sin(offsetAngle) * 5)
			local tornado = Instance.new("Part")
			tornado.Name = "KingOfHellTornado"
			tornado.Shape = Enum.PartType.Cylinder
			tornado.Size = Vector3.new(38, 12, 12)
			tornado.CFrame = CFrame.new(targetPos + tOffset + Vector3.new(0, 14, 0)) * CFrame.Angles(0, 0, math.rad(90))
			tornado.Anchored = true
			tornado.CanCollide = false
			tornado.Material = Enum.Material.Neon
			tornado.Color = (t % 2 == 1) and Color3.fromRGB(40, 255, 120) or Color3.fromRGB(165, 55, 255)
			tornado.Transparency = 0.25
			tornado.Parent = Workspace

			TweenService:Create(tornado, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = Vector3.new(44, 20, 20),
				Transparency = 1,
			}):Play()
			Debris:AddItem(tornado, 0.50)
		end

		-- Dual cross-slash (30-44 studs wide)
		for s = 1, 2 do
			local slash = Instance.new("Part")
			slash.Name = "YonkoCrossSlash"
			slash.Size = Vector3.new(38, 1.2, 2.4)
			slash.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0)) * CFrame.Angles(0, math.rad((s - 1) * 90 + 45), math.rad(30))
			slash.Anchored = true
			slash.CanCollide = false
			slash.Material = Enum.Material.Neon
			slash.Color = Color3.fromRGB(165, 55, 255)
			slash.Parent = Workspace

			TweenService:Create(slash, TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = Vector3.new(44, 1.8, 3.6),
				Transparency = 1,
			}):Play()
			Debris:AddItem(slash, 0.42)
		end

		spawnHakiLightningBolts(targetPos, Color3.fromRGB(165, 55, 255), 10)

	-- -------------------------------------------------------------------------
	-- STYLE 5: ENTEI (PORTGAS D. ACE - FLAME EMPEROR SUN)
	-- -------------------------------------------------------------------------
	elseif style == "Entei" then
		local sunBall = Instance.new("Part")
		sunBall.Name = "AceEnteiSun"
		sunBall.Shape = Enum.PartType.Ball
		sunBall.Size = Vector3.new(11, 11, 11)
		sunBall.Position = startPos + Vector3.new(0, 14, 0)
		sunBall.Anchored = true
		sunBall.CanCollide = false
		sunBall.Material = Enum.Material.Neon
		sunBall.Color = Color3.fromRGB(255, 130, 20)
		sunBall.Parent = Workspace

		TweenService:Create(sunBall, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = targetPos,
			Size = Vector3.new(24, 24, 24),
			Transparency = 0.85,
		}):Play()

		local fireShock = Instance.new("Part")
		fireShock.Name = "EnteiFireShock"
		fireShock.Shape = Enum.PartType.Cylinder
		fireShock.Size = Vector3.new(0.5, 4, 4)
		fireShock.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
		fireShock.Anchored = true
		fireShock.CanCollide = false
		fireShock.Material = Enum.Material.Neon
		fireShock.Color = Color3.fromRGB(255, 225, 60)
		fireShock.Parent = Workspace

		TweenService:Create(fireShock, TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, 26, 26),
			Transparency = 1,
		}):Play()

		Debris:AddItem(sunBall, 0.45)
		Debris:AddItem(fireShock, 0.42)
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(255, 120, 20), 8)

	-- -------------------------------------------------------------------------
	-- STYLE 6: GAMMA KNIFE (TRAFALGAR LAW - K-ROOM)
	-- -------------------------------------------------------------------------
	elseif style == "GammaKnife" then
		local roomDome = Instance.new("Part")
		roomDome.Name = "KRoomSpatialDome"
		roomDome.Shape = Enum.PartType.Ball
		roomDome.Size = Vector3.new(4, 4, 4)
		roomDome.Position = targetPos
		roomDome.Anchored = true
		roomDome.CanCollide = false
		roomDome.Material = Enum.Material.ForceField
		roomDome.Color = Color3.fromRGB(60, 220, 255)
		roomDome.Transparency = 0.35
		roomDome.Parent = Workspace

		local giantSword = Instance.new("Part")
		giantSword.Name = "PunctureWilleBlade"
		giantSword.Size = Vector3.new(1.2, 28, 1.8)
		giantSword.Position = targetPos + Vector3.new(0, 14, 0)
		giantSword.Anchored = true
		giantSword.CanCollide = false
		giantSword.Material = Enum.Material.Neon
		giantSword.Color = Color3.fromRGB(165, 255, 115)
		giantSword.Parent = Workspace

		TweenService:Create(roomDome, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new(26, 26, 26),
			Transparency = 1,
		}):Play()

		TweenService:Create(giantSword, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			Position = targetPos - Vector3.new(0, 4, 0),
			Transparency = 1,
		}):Play()

		Debris:AddItem(roomDome, 0.50)
		Debris:AddItem(giantSword, 0.45)
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(60, 220, 255), 8)

	-- -------------------------------------------------------------------------
	-- STYLE 7: YASAKANI LIGHT (ADMIRAL KIZARU - BORSALINO)
	-- -------------------------------------------------------------------------
	elseif style == "YasakaniLight" then
		local skyOrigin = startPos + Vector3.new(0, 24, 0)
		for _ = 1, 10 do
			local hitPos = targetPos + Vector3.new(math.random(-6, 6), 0, math.random(-6, 6))
			local dist = (hitPos - skyOrigin).Magnitude
			if dist >= 0.05 then
				local beam = Instance.new("Part")
				beam.Name = "YasakaniPhotonBeam"
				beam.Size = Vector3.new(0.55, 0.55, dist)
				beam.CFrame = CFrame.lookAt(skyOrigin, hitPos) * CFrame.new(0, 0, -dist * 0.5)
				beam.Anchored = true
				beam.CanCollide = false
				beam.Material = Enum.Material.Neon
				beam.Color = Color3.fromRGB(255, 240, 75)
				beam.Parent = Workspace

				TweenService:Create(beam, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Transparency = 1,
					Size = Vector3.new(0.1, 0.1, dist),
				}):Play()
				Debris:AddItem(beam, 0.32)
			end
		end
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(255, 240, 75), 8)

	-- -------------------------------------------------------------------------
	-- STYLE 8: BOEUF BURST (VINSMOKE SANJI - IFRIT JAMBE)
	-- -------------------------------------------------------------------------
	elseif style == "BoeufBurst" then
		-- 42 studs cobalt plasma pillar
		local pillar = Instance.new("Part")
		pillar.Name = "BoeufBurstPillar"
		pillar.Shape = Enum.PartType.Cylinder
		pillar.Size = Vector3.new(42, 10, 10)
		pillar.CFrame = CFrame.new(targetPos + Vector3.new(0, 16, 0)) * CFrame.Angles(0, 0, math.rad(90))
		pillar.Anchored = true
		pillar.CanCollide = false
		pillar.Material = Enum.Material.Neon
		pillar.Color = Color3.fromRGB(35, 155, 255)
		pillar.Parent = Workspace

		TweenService:Create(pillar, TweenInfo.new(0.40, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(48, 18, 18),
			Transparency = 1,
		}):Play()
		Debris:AddItem(pillar, 0.45)

		-- 4-tier fire rings: HellFireRing_1, HellFireRing_2, HellFireRing_3, HellFireRing_4 (16, 24, 32, 40 studs)
		local ringRadii = { 16, 24, 32, 40 }
		for idx, rad in ipairs(ringRadii) do
			local ring = Instance.new("Part")
			ring.Name = "HellFireRing_" .. idx
			ring.Shape = Enum.PartType.Cylinder
			ring.Size = Vector3.new(0.4, 4, 4)
			ring.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.3 * idx, 0)) * CFrame.Angles(0, 0, math.rad(90))
			ring.Anchored = true
			ring.CanCollide = false
			ring.Material = Enum.Material.Neon
			ring.Color = (idx % 2 == 1) and Color3.fromRGB(35, 155, 255) or Color3.fromRGB(220, 245, 255)
			ring.Parent = Workspace

			TweenService:Create(ring, TweenInfo.new(0.35 + idx * 0.04, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.1, rad, rad),
				Transparency = 1,
			}):Play()
			Debris:AddItem(ring, 0.45 + idx * 0.05)
		end

		spawnHakiLightningBolts(targetPos, Color3.fromRGB(35, 180, 255), 8)

	-- -------------------------------------------------------------------------
	-- STYLE 9: ZEUS BREEZE TEMPO (NAMI - WEATHER EMPRESS)
	-- -------------------------------------------------------------------------
	elseif style == "ZeusBreezeTempo" then
		-- Giant dark storm cloud overhead 28x8x28 studs with glowing eyes
		local cloud = Instance.new("Part")
		cloud.Name = "ZeusStormCloud"
		cloud.Shape = Enum.PartType.Ball
		cloud.Size = Vector3.new(28, 8, 28)
		cloud.Position = targetPos + Vector3.new(0, 24, 0)
		cloud.Anchored = true
		cloud.CanCollide = false
		cloud.Material = Enum.Material.Neon
		cloud.Color = Color3.fromRGB(30, 32, 45)
		cloud.Parent = Workspace

		for eye = 1, 2 do
			local eyeGlow = Instance.new("Part")
			eyeGlow.Name = "ZeusEyeGlow_" .. eye
			eyeGlow.Size = Vector3.new(1.2, 1.2, 1.2)
			eyeGlow.Position = cloud.Position + Vector3.new((eye == 1 and -4 or 4), -1.5, 10)
			eyeGlow.Anchored = true
			eyeGlow.CanCollide = false
			eyeGlow.Material = Enum.Material.Neon
			eyeGlow.Color = Color3.fromRGB(255, 230, 80)
			eyeGlow.Parent = Workspace
			TweenService:Create(eyeGlow, TweenInfo.new(0.40), { Transparency = 1 }):Play()
			Debris:AddItem(eyeGlow, 0.45)
		end

		TweenService:Create(cloud, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(34, 10, 34),
			Transparency = 1,
		}):Play()
		Debris:AddItem(cloud, 0.50)

		-- 8 golden lightning bolts striking down
		for b = 1, 8 do
			local angle = math.rad((360 / 8) * b + math.random(-15, 15))
			local hitGround = targetPos + Vector3.new(math.cos(angle) * math.random(4, 14), 0, math.sin(angle) * math.random(4, 14))
			local bolt = Instance.new("Part")
			bolt.Name = "ZeusLightningBolt"
			bolt.Size = Vector3.new(0.6, 24, 0.6)
			bolt.CFrame = CFrame.lookAt(cloud.Position, hitGround) * CFrame.new(0, 0, -12)
			bolt.Anchored = true
			bolt.CanCollide = false
			bolt.Material = Enum.Material.Neon
			bolt.Color = Color3.fromRGB(255, 235, 75)
			bolt.Parent = Workspace
			TweenService:Create(bolt, TweenInfo.new(0.32), { Transparency = 1, Size = Vector3.new(0.05, 24, 0.05) }):Play()
			Debris:AddItem(bolt, 0.38)
		end

		-- 32 studs electric ring
		local elecRing = Instance.new("Part")
		elecRing.Name = "ZeusElectricRing"
		elecRing.Shape = Enum.PartType.Cylinder
		elecRing.Size = Vector3.new(0.4, 4, 4)
		elecRing.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
		elecRing.Anchored = true
		elecRing.CanCollide = false
		elecRing.Material = Enum.Material.Neon
		elecRing.Color = Color3.fromRGB(255, 235, 80)
		elecRing.Parent = Workspace
		TweenService:Create(elecRing, TweenInfo.new(0.40, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, 32, 32),
			Transparency = 1,
		}):Play()
		Debris:AddItem(elecRing, 0.45)
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(255, 235, 80), 8)

	-- -------------------------------------------------------------------------
	-- STYLE 10: FIREBIRD STAR (USOPP - GOD USOPP)
	-- -------------------------------------------------------------------------
	elseif style == "FirebirdStar" then
		-- Giant firebird projectile 14x14x18 studs
		local bird = Instance.new("Part")
		bird.Name = "FirebirdProjectile"
		bird.Size = Vector3.new(14, 14, 18)
		bird.CFrame = CFrame.lookAt(startPos + Vector3.new(0, 10, 0), targetPos)
		bird.Anchored = true
		bird.CanCollide = false
		bird.Material = Enum.Material.Neon
		bird.Color = Color3.fromRGB(255, 85, 20)
		bird.Parent = Workspace

		TweenService:Create(bird, TweenInfo.new(0.28, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			Position = targetPos,
			Size = Vector3.new(18, 18, 22),
			Transparency = 1,
		}):Play()
		Debris:AddItem(bird, 0.35)

		-- 6 emerald skull burst bushes
		for s = 1, 6 do
			local angle = math.rad((360 / 6) * s)
			local sPos = targetPos + Vector3.new(math.cos(angle) * 8, 2, math.sin(angle) * 8)
			local skull = Instance.new("Part")
			skull.Name = "PopGreenSkull_" .. s
			skull.Shape = Enum.PartType.Ball
			skull.Size = Vector3.new(4, 4, 4)
			skull.Position = sPos
			skull.Anchored = true
			skull.CanCollide = false
			skull.Material = Enum.Material.Neon
			skull.Color = Color3.fromRGB(45, 225, 110)
			skull.Parent = Workspace
			TweenService:Create(skull, TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = Vector3.new(14, 14, 14),
				Transparency = 1,
			}):Play()
			Debris:AddItem(skull, 0.42)
		end

		-- 30 studs blast ring
		local blastRing = Instance.new("Part")
		blastRing.Name = "FirebirdBlastRing"
		blastRing.Shape = Enum.PartType.Cylinder
		blastRing.Size = Vector3.new(0.4, 4, 4)
		blastRing.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
		blastRing.Anchored = true
		blastRing.CanCollide = false
		blastRing.Material = Enum.Material.Neon
		blastRing.Color = Color3.fromRGB(255, 120, 30)
		blastRing.Parent = Workspace
		TweenService:Create(blastRing, TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, 30, 30),
			Transparency = 1,
		}):Play()
		Debris:AddItem(blastRing, 0.42)
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(255, 100, 25), 8)

	-- -------------------------------------------------------------------------
	-- STYLE 11: MONSTER POINT (TONY TONY CHOPPER)
	-- -------------------------------------------------------------------------
	elseif style == "MonsterPoint" then
		-- Colossal pink-gold paw ground slam 28 studs diameter
		local paw = Instance.new("Part")
		paw.Name = "MonsterPointPaw"
		paw.Shape = Enum.PartType.Cylinder
		paw.Size = Vector3.new(6, 28, 28)
		paw.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.rad(90))
		paw.Anchored = true
		paw.CanCollide = false
		paw.Material = Enum.Material.Neon
		paw.Color = Color3.fromRGB(255, 140, 180)
		paw.Parent = Workspace

		TweenService:Create(paw, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			Position = targetPos + Vector3.new(0, 0.5, 0),
			Transparency = 0.8,
		}):Play()
		Debris:AddItem(paw, 0.45)

		-- 4 crater debris rocks erupting diagonally
		for r = 1, 4 do
			local angle = math.rad(45 + (r - 1) * 90)
			local rock = Instance.new("Part")
			rock.Name = "CraterDebris_" .. r
			rock.Size = Vector3.new(3, 3, 3)
			rock.Position = targetPos + Vector3.new(math.cos(angle) * 4, 1, math.sin(angle) * 4)
			rock.Anchored = true
			rock.CanCollide = false
			rock.Color = Color3.fromRGB(75, 75, 85)
			rock.Parent = Workspace
			TweenService:Create(rock, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = rock.Position + Vector3.new(math.cos(angle) * 8, 6, math.sin(angle) * 8),
				Transparency = 1,
			}):Play()
			Debris:AddItem(rock, 0.48)
		end

		-- Double shock rings 34 studs
		for sr = 1, 2 do
			local ring = Instance.new("Part")
			ring.Name = "MonsterShockRing_" .. sr
			ring.Shape = Enum.PartType.Cylinder
			ring.Size = Vector3.new(0.4, 4, 4)
			ring.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.4 * sr, 0)) * CFrame.Angles(0, 0, math.rad(90))
			ring.Anchored = true
			ring.CanCollide = false
			ring.Material = Enum.Material.Neon
			ring.Color = (sr == 1) and Color3.fromRGB(255, 160, 200) or Color3.fromRGB(255, 225, 120)
			ring.Parent = Workspace
			TweenService:Create(ring, TweenInfo.new(0.40 + sr * 0.05, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.1, 34, 34),
				Transparency = 1,
			}):Play()
			Debris:AddItem(ring, 0.48)
		end
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(255, 160, 200), 8)

	-- -------------------------------------------------------------------------
	-- STYLE 12: DEMONIO FLEUR (NICO ROBIN)
	-- -------------------------------------------------------------------------
	elseif style == "DemonioFleur" then
		-- Dual giant dark-purple demon arms 32 studs tall rising from earth on flanks clapping together
		local armL = Instance.new("Part")
		armL.Name = "DemonArmLeft"
		armL.Size = Vector3.new(4, 32, 6)
		armL.Position = targetPos + Vector3.new(-16, -6, 0)
		armL.Anchored = true
		armL.CanCollide = false
		armL.Material = Enum.Material.Neon
		armL.Color = Color3.fromRGB(90, 25, 140)
		armL.Parent = Workspace

		local armR = Instance.new("Part")
		armR.Name = "DemonArmRight"
		armR.Size = Vector3.new(4, 32, 6)
		armR.Position = targetPos + Vector3.new(16, -6, 0)
		armR.Anchored = true
		armR.CanCollide = false
		armR.Material = Enum.Material.Neon
		armR.Color = Color3.fromRGB(90, 25, 140)
		armR.Parent = Workspace

		TweenService:Create(armL, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = targetPos + Vector3.new(-2, 10, 0),
		}):Play()
		TweenService:Create(armR, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = targetPos + Vector3.new(2, 10, 0),
		}):Play()

		Debris:AddItem(armL, 0.45)
		Debris:AddItem(armR, 0.45)

		-- Distortion dome 32 studs
		local dome = Instance.new("Part")
		dome.Name = "DemonioClapDome"
		dome.Shape = Enum.PartType.Ball
		dome.Size = Vector3.new(4, 4, 4)
		dome.Position = targetPos + Vector3.new(0, 8, 0)
		dome.Anchored = true
		dome.CanCollide = false
		dome.Material = Enum.Material.ForceField
		dome.Color = Color3.fromRGB(150, 45, 215)
		dome.Transparency = 0.25
		dome.Parent = Workspace

		TweenService:Create(dome, TweenInfo.new(0.40, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new(32, 32, 32),
			Transparency = 1,
		}):Play()
		Debris:AddItem(dome, 0.48)

		-- Petal ring 36 studs
		local petalRing = Instance.new("Part")
		petalRing.Name = "DemonioPetalRing"
		petalRing.Shape = Enum.PartType.Cylinder
		petalRing.Size = Vector3.new(0.4, 4, 4)
		petalRing.CFrame = CFrame.new(targetPos + Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
		petalRing.Anchored = true
		petalRing.CanCollide = false
		petalRing.Material = Enum.Material.Neon
		petalRing.Color = Color3.fromRGB(190, 60, 245)
		petalRing.Parent = Workspace

		TweenService:Create(petalRing, TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, 36, 36),
			Transparency = 1,
		}):Play()
		Debris:AddItem(petalRing, 0.48)
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(165, 45, 220), 8)
	end
end

-- =============================================================================
-- 5-PHASE COMBAT KINEMATICS & HITSTOP ENGINE (F-01 UNIFIED RIG KINEMATICS)
-- =============================================================================

local function execute5PhaseAttack(
	tower: Model,
	heroSpec: any,
	targetPos: Vector3,
	onImpactCallback: () -> ()
)
	local root = tower.PrimaryPart
	if not root then
		return
	end
	local rightArm = tower:FindFirstChild("RightArm") :: BasePart?
	local weapon = tower:FindFirstChild("SignatureWeapon") :: BasePart?
	local hasLimbs = (rightArm ~= nil and weapon ~= nil)

	tower:SetAttribute("IsAttacking", true)
	local startPos = root.Position
	local baseY = (tower:GetAttribute("BaseY") :: number?) or startPos.Y
	local targetFlat = Vector3.new(targetPos.X, startPos.Y, targetPos.Z)
	local fwdDiff = targetFlat - startPos
	local fwdDir = (fwdDiff.Magnitude >= 0.05) and fwdDiff.Unit or Vector3.new(0, 0, -1)
	local lookCF = CFrame.lookAt(startPos, startPos + fwdDir)

	-- Phase 1: Wind-Up Anticipation (0.14s)
	local windUpCF = lookCF * CFrame.Angles(math.rad(-14), 0, 0)
	TweenService:Create(root, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = windUpCF }):Play()
	local rig = towerRigs[tower]
	if rig then
		if rig.RightArm then
			TweenService:Create(rig.RightArm, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				C0 = CFrame.new(1.39, 0.75, 0) * CFrame.Angles(math.rad(55), math.rad(-15), math.rad(20)),
			}):Play()
		end
		if rig.RightWeapon then
			TweenService:Create(rig.RightWeapon, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				C0 = CFrame.new(0.24, -1.66, -0.50) * CFrame.Angles(math.rad(-85), 0, 0),
			}):Play()
		end
		if rig.LeftArm then
			TweenService:Create(rig.LeftArm, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				C0 = CFrame.new(-1.39, 0.75, 0) * CFrame.Angles(math.rad(-30), 0, math.rad(-20)),
			}):Play()
		end
		if rig.Head then
			TweenService:Create(rig.Head, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				C0 = CFrame.new(0, 1.89, 0) * CFrame.Angles(math.rad(-10), 0, 0),
			}):Play()
		end
		if rig.LeftLeg and rig.RightLeg then
			TweenService:Create(rig.LeftLeg, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				C0 = CFrame.new(-0.53, -0.60, 0) * CFrame.Angles(math.rad(18), 0, 0),
			}):Play()
			TweenService:Create(rig.RightLeg, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				C0 = CFrame.new(0.53, -0.60, 0) * CFrame.Angles(math.rad(-12), 0, 0),
			}):Play()
		end
	end
	if hasLimbs and rightArm and weapon then
		TweenService:Create(rightArm, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = startPos + Vector3.new(0.4, 2.2, 0.6),
		}):Play()
		TweenService:Create(weapon, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = startPos + Vector3.new(0.4, 2.7, -1.2),
		}):Play()
	end

	task.delay(0.14, function()
		if not tower.Parent or not root.Parent then
			return
		end

		-- Phase 2: Dash / Leap (0.10s)
		local dashPos = startPos + fwdDir * 3.2
		local dashCF = CFrame.lookAt(dashPos, dashPos + fwdDir) * CFrame.Angles(math.rad(18), 0, 0)
		TweenService:Create(root, TweenInfo.new(0.10, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), { CFrame = dashCF }):Play()
		if rig then
			if rig.RightArm then
				TweenService:Create(rig.RightArm, TweenInfo.new(0.10, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
					C0 = CFrame.new(1.39, 0.75, 0) * CFrame.Angles(math.rad(-75), math.rad(20), math.rad(-10)),
				}):Play()
			end
			if rig.RightWeapon then
				TweenService:Create(rig.RightWeapon, TweenInfo.new(0.10, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
					C0 = CFrame.new(0.24, -1.66, -0.50) * CFrame.Angles(math.rad(-30), 0, 0),
				}):Play()
			end
			if rig.LeftArm then
				TweenService:Create(rig.LeftArm, TweenInfo.new(0.10, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
					C0 = CFrame.new(-1.39, 0.75, 0) * CFrame.Angles(math.rad(45), 0, math.rad(-25)),
				}):Play()
			end
			if rig.LeftLeg and rig.RightLeg then
				if heroSpec.AttackStyle == "BoeufBurst" then
					TweenService:Create(rig.RightLeg, TweenInfo.new(0.10, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
						C0 = CFrame.new(0.53, -0.60, 0) * CFrame.Angles(math.rad(-95), 0, math.rad(30)),
					}):Play()
				else
					TweenService:Create(rig.LeftLeg, TweenInfo.new(0.10, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
						C0 = CFrame.new(-0.53, -0.60, 0) * CFrame.Angles(math.rad(-35), 0, 0),
					}):Play()
					TweenService:Create(rig.RightLeg, TweenInfo.new(0.10, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
						C0 = CFrame.new(0.53, -0.60, 0) * CFrame.Angles(math.rad(40), 0, 0),
					}):Play()
				end
			end
		end
		if hasLimbs and rightArm and weapon then
			TweenService:Create(rightArm, TweenInfo.new(0.10, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
				Position = dashPos + fwdDir * 1.8 + Vector3.new(0, 0.4, 0),
			}):Play()
			TweenService:Create(weapon, TweenInfo.new(0.10, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
				Position = dashPos + fwdDir * 1.8 + Vector3.new(0, 0.9, -1.8),
			}):Play()
		end

		task.delay(0.10, function()
			if not tower.Parent or not root.Parent then
				return
			end

			-- Phase 3: Hitstop / Freeze Frame (0.07s)
			local shakeIntensity = 0.45
			if heroSpec.AttackStyle == "BajrangFist" or heroSpec.AttackStyle == "Kamusari" or heroSpec.AttackStyle == "GuraQuake" then
				shakeIntensity = 0.70
			end
			CameraShakeRemote:FireAllClients(shakeIntensity, heroSpec.SecondaryColor)
			spawnMangaBillboard(targetPos, heroSpec.Onomatopoeia, heroSpec.PrimaryColor)
			spawnHakiLightningBolts(targetPos, heroSpec.SecondaryColor, 8)

			task.delay(0.07, function()
				if not tower.Parent or not root.Parent then
					return
				end

				-- Phase 4: Impact Strike & Follow-Through (0.20s)
				if rig then
					if rig.RightArm then
						TweenService:Create(rig.RightArm, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							C0 = CFrame.new(1.39, 0.75, 0) * CFrame.Angles(math.rad(-90), math.rad(40), 0),
						}):Play()
					end
					if rig.RightWeapon then
						TweenService:Create(rig.RightWeapon, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							C0 = CFrame.new(0.24, -1.66, -0.50) * CFrame.Angles(math.rad(-15), 0, 0),
						}):Play()
					end
				end
				onImpactCallback()

				task.delay(0.20, function()
					if not tower.Parent or not root.Parent then
						return
					end

					-- Phase 5: Recoil & Return to Base Pad Position (0.22s)
					local basePos = Vector3.new(startPos.X, baseY, startPos.Z)
					local returnCF = CFrame.lookAt(basePos, basePos + fwdDir)
					TweenService:Create(root, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = returnCF }):Play()
					if rig then
						if rig.RightArm then
							TweenService:Create(rig.RightArm, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								C0 = CFrame.new(1.39, 0.75, 0) * CFrame.Angles(0, 0, math.rad(5)),
							}):Play()
						end
						if rig.RightWeapon then
							TweenService:Create(rig.RightWeapon, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								C0 = CFrame.new(0.24, -1.66, -0.50) * CFrame.Angles(math.rad(-65), 0, 0),
							}):Play()
						end
						if rig.LeftArm then
							TweenService:Create(rig.LeftArm, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								C0 = CFrame.new(-1.39, 0.75, 0) * CFrame.Angles(0, 0, math.rad(-5)),
							}):Play()
						end
						if rig.Head then
							TweenService:Create(rig.Head, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								C0 = CFrame.new(0, 1.89, 0),
							}):Play()
						end
						if rig.LeftLeg and rig.RightLeg then
							TweenService:Create(rig.LeftLeg, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								C0 = CFrame.new(-0.53, -0.60, 0) * CFrame.Angles(math.rad(4), 0, math.rad(-2)),
							}):Play()
							TweenService:Create(rig.RightLeg, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								C0 = CFrame.new(0.53, -0.60, 0) * CFrame.Angles(math.rad(-4), 0, math.rad(2)),
							}):Play()
						end
					end
					if hasLimbs and rightArm and weapon then
						local returnArmPos = basePos + returnCF:VectorToWorldSpace(Vector3.new(1.55, 0, 0))
						TweenService:Create(rightArm, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Position = returnArmPos,
						}):Play()
						TweenService:Create(weapon, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							Position = returnArmPos + Vector3.new(0, 0.5, -1.8),
						}):Play()
					end

					task.delay(0.22, function()
						if hasLimbs and rightArm and weapon then
							if tower.Parent and root.Parent and rightArm.Parent and weapon.Parent then
								weapon.Position = rightArm.Position + Vector3.new(0, 0.5, -1.8)
							end
						end
						if tower.Parent and root.Parent then
							tower:SetAttribute("IsAttacking", false)
						end
					end)
				end)
			end)
		end)
	end)
end

-- =============================================================================
-- PAD SYSTEM & TACTICAL PLACEMENT MANAGEMENT (SWAP / STORE / SELL) (F-02 MEMORY CLEAN)
-- =============================================================================

local function placeOrSwapTowerOnSlot(player: Player, slotId: string, requestedUid: string?)
	local bag = decodeBag(player)
	local targetUid = requestedUid or (player:GetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID) :: string?)
	if (not targetUid or targetUid == "") and #bag > 0 then
		targetUid = bag[1].Uid
	end

	local bagIndex: number? = nil
	local chosenUnit: BagUnit? = nil
	for idx, item in ipairs(bag) do
		if item.Uid == targetUid then
			bagIndex = idx
			chosenUnit = item
			break
		end
	end

	if not chosenUnit or not bagIndex then
		return
	end

	local existingTower = slotOccupants[slotId]
	local maxTowers = (player:GetAttribute(GameConfig.PLAYER_ATTRS.MAX_PLACED_TOWERS) :: number?) or 4
	local currentCount = (player:GetAttribute(GameConfig.PLAYER_ATTRS.PLACED_TOWERS_COUNT) :: number?) or 0

	-- Cap verification: only enforced on empty pads
	if not existingTower and currentCount >= maxTowers then
		return
	end

	-- Remove chosen unit from bag
	table.remove(bag, bagIndex)

	-- Atomic Swap: If slot is occupied, pack existing tower back into bag
	if existingTower and existingTower.Parent then
		local prevHeroId = (existingTower:GetAttribute("HeroId") :: string?) or "Tower_Luffy_G5"
		local prevUid = (existingTower:GetAttribute("UnitUid") :: string?) or HttpService:GenerateGUID(false)
		local prevSpec = getHeroSpec(prevHeroId)
		table.insert(bag, {
			Uid = prevUid,
			HeroId = prevSpec.Id,
			Name = prevSpec.Name,
			Rarity = prevSpec.Rarity,
			SellValue = prevSpec.SellValue,
		})
		lastAttackTime[existingTower] = nil
		existingTower:Destroy()
		slotOccupants[slotId] = nil
	end

	encodeBag(player, bag)
	if #bag > 0 then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, bag[1].Uid)
	else
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, "")
	end

	-- Find slot position
	local slotSpec = GameConfig.PLACEMENT_SLOTS[1]
	for _, s in ipairs(GameConfig.PLACEMENT_SLOTS) do
		if s.SlotId == slotId then
			slotSpec = s
			break
		end
	end

	local heroSpec = getHeroSpec(chosenUnit.HeroId)
	local newModel = loadAuthenticHeroModel(heroSpec, slotSpec.Position, player.UserId, chosenUnit.Uid, slotId)
	slotOccupants[slotId] = newModel

	spawnHakiLightningBolts(slotSpec.Position, heroSpec.SecondaryColor, 8)
	spawnMangaBillboard(slotSpec.Position, "DEPLOY!! " .. heroSpec.Name, heroSpec.PrimaryColor)
	updatePadVisual(slotId)
	recountPlayerTowers(player)
end

local function storeTowerToBag(player: Player, slotId: string)
	local existingTower = slotOccupants[slotId]
	if not existingTower or not existingTower.Parent then
		return
	end
	local prevHeroId = (existingTower:GetAttribute("HeroId") :: string?) or "Tower_Luffy_G5"
	local prevUid = (existingTower:GetAttribute("UnitUid") :: string?) or HttpService:GenerateGUID(false)
	local prevSpec = getHeroSpec(prevHeroId)

	local bag = decodeBag(player)
	table.insert(bag, {
		Uid = prevUid,
		HeroId = prevSpec.Id,
		Name = prevSpec.Name,
		Rarity = prevSpec.Rarity,
		SellValue = prevSpec.SellValue,
	})
	encodeBag(player, bag)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, prevUid)

	lastAttackTime[existingTower] = nil
	existingTower:Destroy()
	slotOccupants[slotId] = nil
	updatePadVisual(slotId)
	recountPlayerTowers(player)
end

local function sellTowerUnit(player: Player, sourceType: string, targetKey: string)
	local ls = player:FindFirstChild("leaderstats")
	local cashVal = ls and ls:FindFirstChild("Cash") :: IntValue?

	if sourceType == "Slot" then
		local existingTower = slotOccupants[targetKey]
		if not existingTower or not existingTower.Parent then
			return
		end
		local heroId = (existingTower:GetAttribute("HeroId") :: string?) or "Tower_Luffy_G5"
		local spec = getHeroSpec(heroId)
		if cashVal then
			cashVal.Value += spec.SellValue
		end
		if string.find(spec.Rarity, "MYTHICAL") then
			local curTokens = (player:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
			player:SetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, curTokens + 1)
		end
		lastAttackTime[existingTower] = nil
		existingTower:Destroy()
		slotOccupants[targetKey] = nil
		updatePadVisual(targetKey)
		recountPlayerTowers(player)

	elseif sourceType == "Bag" then
		local bag = decodeBag(player)
		for idx, item in ipairs(bag) do
			if item.Uid == targetKey then
				local spec = getHeroSpec(item.HeroId)
				if cashVal then
					cashVal.Value += spec.SellValue
				end
				if string.find(spec.Rarity, "MYTHICAL") then
					local curTokens = (player:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
					player:SetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, curTokens + 1)
				end
				table.remove(bag, idx)
				encodeBag(player, bag)
				break
			end
		end
	end
end

-- =============================================================================
-- INITIALIZE 8 INTERACTIVE PLACEMENT PADS (0 TOWERS ON STARTUP)
-- =============================================================================

for _, slotSpec in ipairs(GameConfig.PLACEMENT_SLOTS) do
	local pad = Instance.new("Part")
	pad.Name = slotSpec.SlotId
	pad.Shape = Enum.PartType.Cylinder
	pad.Size = Vector3.new(0.8, 7.5, 7.5)
	pad.CFrame = CFrame.new(slotSpec.Position) * CFrame.Angles(0, 0, math.rad(90))
	pad.Anchored = true
	pad.CanCollide = false
	pad.Material = Enum.Material.Neon
	pad.Color = Color3.fromRGB(45, 235, 130)
	pad.Transparency = 0.2
	pad.Parent = padsFolder

	local bb = Instance.new("BillboardGui")
	bb.Name = "PadBillboard"
	bb.Size = UDim2.fromOffset(150, 42)
	bb.StudsOffset = Vector3.new(0, 2.6, 0)
	bb.AlwaysOnTop = true
	bb.Parent = pad

	local lbl = Instance.new("TextLabel")
	lbl.Name = "Label"
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 0.35
	lbl.BackgroundColor3 = Color3.fromRGB(10, 16, 24)
	lbl.TextColor3 = Color3.fromRGB(220, 255, 230)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Text = string.format("%s [EMPTY]\nคลิกเพื่อวางตัวละคร", slotSpec.SlotId)
	lbl.Parent = bb

	local cd = Instance.new("ClickDetector")
	cd.MaxActivationDistance = 120
	cd.Parent = pad
	cd.MouseClick:Connect(function(player: Player)
		local occupant = slotOccupants[slotSpec.SlotId]
		if occupant and occupant.Parent then
			local statGui = occupant:FindFirstChild("TowerStatGui", true) or occupant:FindFirstChild("TowerStatusGui", true)
			if statGui and statGui:IsA("BillboardGui") then
				statGui.Enabled = not statGui.Enabled
			end
		end
		placeOrSwapTowerOnSlot(player, slotSpec.SlotId, nil)
	end)
	cd.MouseHoverEnter:Connect(function()
		local occupant = slotOccupants[slotSpec.SlotId]
		if occupant and occupant.Parent then
			local statGui = occupant:FindFirstChild("TowerStatGui", true) or occupant:FindFirstChild("TowerStatusGui", true)
			if statGui and statGui:IsA("BillboardGui") then
				statGui.Enabled = true
			end
		end
	end)
	cd.MouseHoverLeave:Connect(function()
		local occupant = slotOccupants[slotSpec.SlotId]
		if occupant and occupant.Parent then
			local statGui = occupant:FindFirstChild("TowerStatGui", true) or occupant:FindFirstChild("TowerStatusGui", true)
			if statGui and statGui:IsA("BillboardGui") then
				statGui.Enabled = false
			end
		end
	end)

	slotPadParts[slotSpec.SlotId] = pad
end

-- =============================================================================
-- REMOTE EVENT LISTENERS: GACHA SUMMON, REROLL & PLACEMENT ACTIONS
-- =============================================================================

SummonRerollRemote.OnServerEvent:Connect(function(player: Player, mode: any)
	if type(mode) ~= "string" then
		return
	end
	local ls = player:FindFirstChild("leaderstats")
	local cashVal = ls and ls:FindFirstChild("Cash") :: IntValue?
	local freeTickets = (player:GetAttribute(GameConfig.PLAYER_ATTRS.FREE_SUMMON_TICKETS) :: number?) or 0
	local rerollTokens = (player:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
	local bag = decodeBag(player)

	if mode == "Summon" then
		if freeTickets > 0 then
			player:SetAttribute(GameConfig.PLAYER_ATTRS.FREE_SUMMON_TICKETS, freeTickets - 1)
		elseif cashVal and cashVal.Value >= GameConfig.INITIAL_PLAYER_STATS.SUMMON_COST_CASH then
			cashVal.Value -= GameConfig.INITIAL_PLAYER_STATS.SUMMON_COST_CASH
		else
			return
		end

		local rolledSpec = rollWeightedHero()
		local newUid = HttpService:GenerateGUID(false)
		table.insert(bag, {
			Uid = newUid,
			HeroId = rolledSpec.Id,
			Name = rolledSpec.Name,
			Rarity = rolledSpec.Rarity,
			SellValue = rolledSpec.SellValue,
		})
		encodeBag(player, bag)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_HERO_ID, rolledSpec.Id)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_UNIT_UID, newUid)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, newUid)

	elseif mode == "Reroll" then
		if rerollTokens > 0 then
			player:SetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, rerollTokens - 1)
		elseif cashVal and cashVal.Value >= GameConfig.INITIAL_PLAYER_STATS.REROLL_COST_CASH then
			cashVal.Value -= GameConfig.INITIAL_PLAYER_STATS.REROLL_COST_CASH
		else
			return
		end

		local lastUid = (player:GetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_UNIT_UID) :: string?) or ""
		local rolledSpec = rollWeightedHero()
		local replaced = false

		for idx, item in ipairs(bag) do
			if item.Uid == lastUid then
				bag[idx] = {
					Uid = lastUid,
					HeroId = rolledSpec.Id,
					Name = rolledSpec.Name,
					Rarity = rolledSpec.Rarity,
					SellValue = rolledSpec.SellValue,
				}
				replaced = true
				break
			end
		end

		if not replaced then
			local newUid = HttpService:GenerateGUID(false)
			table.insert(bag, {
				Uid = newUid,
				HeroId = rolledSpec.Id,
				Name = rolledSpec.Name,
				Rarity = rolledSpec.Rarity,
				SellValue = rolledSpec.SellValue,
			})
			lastUid = newUid
		end

		encodeBag(player, bag)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_HERO_ID, rolledSpec.Id)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_UNIT_UID, lastUid)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, lastUid)
	end
end)

PlacementActionRemote.OnServerEvent:Connect(function(player: Player, actionType: any, arg1: any, arg2: any)
	if type(actionType) ~= "string" then
		return
	end
	if actionType == "SelectBagUnit" and type(arg1) == "string" then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, arg1)
	elseif actionType == "PlaceOrSwap" and type(arg1) == "string" then
		local uid = (type(arg2) == "string") and arg2 or nil
		placeOrSwapTowerOnSlot(player, arg1, uid)
	elseif actionType == "StoreToBag" and type(arg1) == "string" then
		storeTowerToBag(player, arg1)
	elseif actionType == "SellFromSlot" and type(arg1) == "string" then
		sellTowerUnit(player, "Slot", arg1)
	elseif actionType == "SellFromBag" and type(arg1) == "string" then
		sellTowerUnit(player, "Bag", arg1)
	end
end)

-- =============================================================================
-- CONTINUOUS IDLE BOBBING & AURA ROTATION LOOP (HEARTBEAT)
-- =============================================================================

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for _, tower in ipairs((towersFolder :: Folder):GetChildren()) do
		if tower:IsA("Model") and tower.PrimaryPart then
			local isAttacking = (tower:GetAttribute("IsAttacking") :: boolean?) or false
			if not isAttacking then
				local baseY = (tower:GetAttribute("BaseY") :: number?) or 5.5
				local bob = math.sin(now * 3.2) * 0.35
				local curPos = tower.PrimaryPart.Position
				tower.PrimaryPart.Position = Vector3.new(curPos.X, baseY + bob, curPos.Z)

				local isArticulated = (tower:GetAttribute("IsArticulatedRig") :: boolean?) or false
				local rig = towerRigs[tower]
				if rig and isArticulated then
					local breath = math.sin(now * 2.8) * 0.05
					local armBobR = math.sin(now * 3.2 + 0.4) * 0.08
					local armBobL = math.sin(now * 3.2 - 0.4) * 0.08

					if rig.Head then
						rig.Head.C0 = CFrame.new(0, 1.89, 0) * CFrame.Angles(math.rad(breath * 35), math.rad(math.sin(now * 1.5) * 4), 0)
					end
					if rig.RightArm then
						rig.RightArm.C0 = CFrame.new(1.39, 0.75, 0) * CFrame.Angles(math.rad(armBobR * 50), 0, math.rad(5))
					end
					if rig.LeftArm then
						rig.LeftArm.C0 = CFrame.new(-1.39, 0.75, 0) * CFrame.Angles(math.rad(armBobL * 50), 0, math.rad(-5))
					end
					if rig.RightWeapon then
						rig.RightWeapon.C0 = CFrame.new(0.24, -1.66, -0.50) * CFrame.Angles(math.rad(-65 + armBobR * 20), 0, 0)
					end
					if rig.LeftLeg and rig.RightLeg then
						rig.LeftLeg.C0 = CFrame.new(-0.53, -0.60, 0) * CFrame.Angles(math.rad(4), 0, math.rad(-2))
						rig.RightLeg.C0 = CFrame.new(0.53, -0.60, 0) * CFrame.Angles(math.rad(-4), 0, math.rad(2))
					end
					if rig.Aura then
						rig.Aura.C0 = CFrame.new(0, -2.35, 0) * CFrame.Angles(0, now * 1.5, 0)
					end
				else
					local head = tower:FindFirstChild("Head") :: BasePart?
					if head then
						head.Position = tower.PrimaryPart.Position + Vector3.new(0, 1.95, 0)
					end

					local rightArm = tower:FindFirstChild("RightArm") :: BasePart?
					local weapon = tower:FindFirstChild("SignatureWeapon") :: BasePart?
					if rightArm then
						local armBob = math.sin(now * 3.2 + 0.4) * 0.08
						rightArm.Position = tower.PrimaryPart.Position + Vector3.new(1.55, armBob, 0)
						if weapon then
							weapon.Position = rightArm.Position + Vector3.new(0, 0.5, -1.8)
						end
					end

					local leftArm = tower:FindFirstChild("LeftArm") :: BasePart?
					if leftArm then
						local armBobLeft = math.sin(now * 3.2 - 0.4) * 0.08
						leftArm.Position = tower.PrimaryPart.Position + Vector3.new(-1.55, armBobLeft, 0)
					end
				end
			end

			local ring = tower:FindFirstChild("AuraRing") :: BasePart?
			if ring then
				ring.CFrame = ring.CFrame * CFrame.Angles(math.rad(2.5), 0, 0)
			end
		end
	end
end)

-- =============================================================================
-- COMBAT TARGETING & DAMAGE RESOLUTION LOOP (F-03 FRESH ENEMY QUERY)
-- =============================================================================

task.spawn(function()
	while true do
		local now = os.clock()
		local enemiesFolder = Workspace:FindFirstChild("Enemies")
		local enemies = enemiesFolder and enemiesFolder:GetChildren() or {}

		for _, tower in ipairs((towersFolder :: Folder):GetChildren()) do
			if tower:IsA("Model") and tower.PrimaryPart then
				local heroId = (tower:GetAttribute("HeroId") :: string?) or "Tower_Luffy_G5"
				local ownerId = (tower:GetAttribute("OwnerUserId") :: number?) or 0
				local owner = Players:GetPlayerByUserId(ownerId) or Players:GetPlayers()[1]
				local spec = getHeroSpec(heroId)

				local baseDmg = owner and (owner:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) :: number?) or 50
				local baseRange = owner and (owner:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) :: number?) or 30
				local baseCd = owner and (owner:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) :: number?) or 1.15
				local baseSplash = owner and (owner:GetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT) :: number?) or 7
				local critChance = owner and (owner:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE) :: number?) or 0.08
				local critDmg = owner and (owner:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_DAMAGE) :: number?) or 2.0

				local finalCooldown = math.max(0.15, baseCd * spec.CooldownMult)
				local finalRange = baseRange + spec.RangeBonus
				local finalSplash = baseSplash + spec.SplashBonus
				local lastTime = lastAttackTime[tower] or 0

				if (now - lastTime) >= finalCooldown then
					local nearestEnemy: Model? = nil
					local minDist = finalRange

					for _, enemy in ipairs(enemies) do
						if enemy:IsA("Model") and enemy.PrimaryPart and ((enemy:GetAttribute("HP") :: number?) or 0) > 0 then
							local d = (enemy.PrimaryPart.Position - tower.PrimaryPart.Position).Magnitude
							if d <= minDist then
								minDist = d
								nearestEnemy = enemy
							end
						end
					end

					if nearestEnemy and nearestEnemy.PrimaryPart then
						lastAttackTime[tower] = now
						local impactPos = nearestEnemy.PrimaryPart.Position

						-- Broadcast cosmetic presentation event to all clients (decoupled from server damage authority)
						pcall(function()
							if TowerPresentationRemote and tower.PrimaryPart then
								local attackId = tostring(tower:GetAttribute("UnitUid") or tower.Name) .. "_" .. tostring(os.clock()) .. "_" .. tostring(math.random(1000, 9999))
								TowerPresentationRemote:FireAllClients({
									version = 1,
									attackId = attackId,
									unitUid = tostring(tower:GetAttribute("UnitUid") or tower.Name),
									heroId = spec.Id,
									startedAtServerTime = os.clock(),
									impactAtServerTime = os.clock() + 0.31,
									logicalOriginCFrame = tower.PrimaryPart.CFrame,
									targetPositionSnapshot = impactPos,
									visualSeed = math.random(1, 1000000),
									presentationRevision = 1,
								})
							end
						end)

						-- 5-Phase Attack Choreography with Hitstop & Impact VFX
						execute5PhaseAttack(tower, spec, impactPos, function()
							-- Fire-and-forget protected visual VFX invocation (does not block damage on error)
							pcall(function()
								playOnePieceUltimateVFX(tower, spec, impactPos)
							end)

							-- Critical & Splash Damage Resolution
							local isCrit = (math.random() < math.clamp(critChance, 0, 0.95))
							local dmg = math.floor(baseDmg * spec.DamageMult * (isCrit and critDmg or 1.0))

							-- F-03: Fresh Active Enemies Query at exact moment of impact (0.31s post-targeting)
							local now = os.clock()
							local currentEnemiesFolder = Workspace:FindFirstChild("Enemies")
							local currentEnemies = currentEnemiesFolder and currentEnemiesFolder:GetChildren() or {}

							for _, enemy in ipairs(currentEnemies) do
								if enemy:IsA("Model") and enemy.PrimaryPart and enemy.Parent and ((enemy:GetAttribute("HP") :: number?) or 0) > 0 then
									local d = (enemy.PrimaryPart.Position - impactPos).Magnitude
									if d <= finalSplash then
										local curHp = (enemy:GetAttribute("HP") :: number?) or 0
										local effectiveDmg = math.max(1, math.floor(dmg * math.clamp(1.0 - (enemy:GetAttribute("ArmorReduction") or 0), 0.25, 1.0)))
										enemy:SetAttribute("HP", math.max(0, curHp - effectiveDmg))

										-- Whitebeard Gura Quake Slow Debuff (0.45x for 2.5s)
										if spec.AttackStyle == "GuraQuake" then
											enemy:SetAttribute("SlowUntil", now + 2.5)
										end
									end
								end
							end
						end)
					end
				end
			end
		end

		task.wait(0.08)
	end
end)
