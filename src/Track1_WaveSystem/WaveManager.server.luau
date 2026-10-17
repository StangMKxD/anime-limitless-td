--!strict
-- src/Track1_WaveSystem/WaveManager.server.luau
-- Phase 3: Grand Line Wave System with First-Summon Prep Window, R6 Walk Animation & Bounty Multiplier
-- Milestone 2 Production Code: Zero-Conflict Architecture

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(SharedFolder:WaitForChild("GameConfig")) :: any
local MapCatalog = require(SharedFolder:WaitForChild("MapCatalog")) :: any

local MapsFolder = script.Parent:FindFirstChild("Maps")
local MapService = MapsFolder and require(MapsFolder:WaitForChild("MapService")) :: any or nil
local MapSelectionService = MapsFolder and require(MapsFolder:WaitForChild("MapSelectionService")) :: any or nil


local WAYPOINT_COORDS: { Vector3 } = {
	Vector3.new(-65, 3, -42),
	Vector3.new(-22, 3, -42),
	Vector3.new(-22, 3, 22),
	Vector3.new(22, 3, 22),
	Vector3.new(22, 3, -32),
	Vector3.new(65, 3, -32),
}

export type EnemySpec = {
	Name: string,
	BaseHP: number,
	Speed: number,
	Cash: number,
	Scale: number,
	Color: Color3,
}

local ENEMY_TYPES: { [string]: EnemySpec } = {
	PirateGrunt = { Name = "Pirate Grunt", BaseHP = 450, Speed = 11.4, Cash = 25, Scale = 1.0, Color = Color3.fromRGB(55, 95, 65) },
	SoruAssassin = { Name = "Soru Assassin", BaseHP = 337, Speed = 18.8, Cash = 32, Scale = 0.95, Color = Color3.fromRGB(30, 95, 190) },
	HakiBrute = { Name = "Armored Haki Brute", BaseHP = 1260, Speed = 8.9, Cash = 50, Scale = 1.35, Color = Color3.fromRGB(22, 20, 28) },
	YonkoBoss = { Name = "Yonko Calamity Boss", BaseHP = 3600, Speed = 8.2, Cash = 550, Scale = 2.2, Color = Color3.fromRGB(130, 18, 35) },
	ThrillerZombie = { Name = "Thriller Bark Zombie", BaseHP = 120, Speed = 10.5, Cash = 22, Scale = 1.0, Color = Color3.fromRGB(95, 135, 105) },
	GeneralZombie = { Name = "General Zombie", BaseHP = 420, Speed = 7.2, Cash = 55, Scale = 1.25, Color = Color3.fromRGB(75, 60, 110) },
	CommandGeneral = { Name = "Command General", BaseHP = 280, Speed = 14.5, Cash = 70, Scale = 1.1, Color = Color3.fromRGB(185, 45, 55) },
	YonkoKaido = { Name = "YONKO KAIDO [DRAGON EMPEROR]", BaseHP = 2600, Speed = 6.0, Cash = 550, Scale = 1.85, Color = Color3.fromRGB(45, 125, 220) },
}

-- ============================================================================
-- 1. เสกสมรภูมิ Marineford & Poneglyph Base อัตโนมัติ (Map Bootstrap)
-- ============================================================================
local function ensureMapAndWaypoints(): (Folder, Folder)
	local mapFolderName = GameConfig.FOLDERS.MAP or "GrandLineMap"
	local wpFolderName = GameConfig.FOLDERS.WAYPOINTS or "Waypoints"
	local mapFolder = Workspace:FindFirstChild(mapFolderName) :: Folder?
	local wpFolder = Workspace:FindFirstChild(wpFolderName) :: Folder?

	if MapService and (not mapFolder or not wpFolder or not MapService.IsMapReady()) then
		pcall(function()
			MapService.BuildMap(MapCatalog.DEFAULT_MAP_ID)
		end)
		mapFolder = Workspace:FindFirstChild(mapFolderName) :: Folder?
		wpFolder = Workspace:FindFirstChild(wpFolderName) :: Folder?
	end

	if not mapFolder then
		mapFolder = Instance.new("Folder")
		mapFolder.Name = mapFolderName
		mapFolder.Parent = Workspace

		local ground = Instance.new("Part")
		ground.Name = "MarinefordPlaza"
		ground.Size = Vector3.new(220, 2, 180)
		ground.Position = Vector3.new(0, 0, 0)
		ground.Anchored = true
		ground.Material = Enum.Material.Cobblestone
		ground.Color = Color3.fromRGB(48, 52, 62)
		ground.Parent = mapFolder

		local baseCore = Instance.new("Part")
		baseCore.Name = "PoneglyphBase"
		baseCore.Size = Vector3.new(14, 16, 14)
		baseCore.Position = WAYPOINT_COORDS[#WAYPOINT_COORDS] + Vector3.new(8, 6, 0)
		baseCore.Anchored = true
		baseCore.Material = Enum.Material.Neon
		baseCore.Color = Color3.fromRGB(55, 185, 255)
		baseCore.Parent = mapFolder
	end

	local wpFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.WAYPOINTS or "Waypoints") :: Folder?
	if not wpFolder then
		wpFolder = Instance.new("Folder")
		wpFolder.Name = GameConfig.FOLDERS.WAYPOINTS or "Waypoints"
		wpFolder.Parent = Workspace

		for idx, pos in ipairs(WAYPOINT_COORDS) do
			local wp = Instance.new("Part")
			wp.Name = "Waypoint_" .. tostring(idx)
			wp.Size = Vector3.new(4, 1, 4)
			wp.Position = pos
			wp.Anchored = true
			wp.CanCollide = false
			wp.Transparency = 0.5
			wp.Material = Enum.Material.Neon
			wp.Color = Color3.fromRGB(255, 200, 60)
			wp.Parent = wpFolder
		end
	end

	local enemiesFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.ENEMIES or "Enemies") :: Folder?
	if not enemiesFolder then
		enemiesFolder = Instance.new("Folder")
		enemiesFolder.Name = GameConfig.FOLDERS.ENEMIES or "Enemies"
		enemiesFolder.Parent = Workspace
	end

	local towersFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.TOWERS or "AnimeTowers") :: Folder?
	if not towersFolder then
		towersFolder = Instance.new("Folder")
		towersFolder.Name = GameConfig.FOLDERS.TOWERS or "AnimeTowers"
		towersFolder.Parent = Workspace
	end

	return mapFolder :: Folder, wpFolder :: Folder
end

-- ============================================================================
-- 2. แจกเงินรางวัลคูณด้วย BountyMultiplierStat ให้ผู้เล่นทุกคน
-- ============================================================================
local function awardCashToAllPlayers(baseAmount: number): ()
	for _, player in ipairs(Players:GetPlayers()) do
		local mult = (player:GetAttribute(GameConfig.PLAYER_ATTRS.BOUNTY_MULT) :: number?) or 1.0
		local finalCash = math.floor(baseAmount * mult)
		local ls = player:FindFirstChild("leaderstats")
		if not ls then
			local newLs = Instance.new("Folder")
			newLs.Name = "leaderstats"
			newLs.Parent = player
			ls = newLs
		end
		local cashVal = ls:FindFirstChild("Cash") :: IntValue?
		if not cashVal then
			cashVal = Instance.new("IntValue")
			cashVal.Name = "Cash"
			cashVal.Value = (GameConfig.INITIAL_PLAYER_STATS and GameConfig.INITIAL_PLAYER_STATS.CASH) or 500
			cashVal.Parent = ls
		end
		cashVal.Value += finalCash
	end
end

-- ============================================================================
-- 3. คำนวณสเตตัสความโหดระดับ Nightmare & เสกศัตรู R6 4 ระดับ (PLAN-0007)
-- ============================================================================
local function calculateEnemyStats(wave: number, enemyClass: string)
	local rawHp = 450 * (1.58 ^ (wave - 1)) * (1 + math.floor(wave / 3) * 0.75)
	local baseSpeed = math.min(24.0, 11.0 + (wave * 0.40))
	local armorReduction = math.min(0.65, (wave - 1) * 0.03)

	local canonicalClass = enemyClass
	if enemyClass == "ThrillerZombie" then
		canonicalClass = "PirateGrunt"
	elseif enemyClass == "CommandGeneral" then
		canonicalClass = "SoruAssassin"
	elseif enemyClass == "GeneralZombie" then
		canonicalClass = "HakiBrute"
	elseif enemyClass == "YonkoKaido" then
		canonicalClass = "YonkoBoss"
	end

	local classSpec = (GameConfig.ENEMY_CLASSES and GameConfig.ENEMY_CLASSES[canonicalClass])

	local hpMult = (classSpec and classSpec.HpMult) or (if canonicalClass == "SoruAssassin" then 0.75 elseif canonicalClass == "HakiBrute" then 2.8 elseif canonicalClass == "YonkoBoss" then 8.0 else 1.0)
	local speedMult = (classSpec and classSpec.SpeedMult) or (if canonicalClass == "SoruAssassin" then 1.65 elseif canonicalClass == "HakiBrute" then 0.78 elseif canonicalClass == "YonkoBoss" then 0.72 else 1.0)
	local scale = (classSpec and classSpec.Scale) or (if canonicalClass == "SoruAssassin" then 0.95 elseif canonicalClass == "HakiBrute" then 1.35 elseif canonicalClass == "YonkoBoss" then 2.2 else 1.0)
	local rewardMult = (classSpec and classSpec.RewardMult) or (if canonicalClass == "SoruAssassin" then 1.3 elseif canonicalClass == "HakiBrute" then 2.0 elseif canonicalClass == "YonkoBoss" then 6.0 else 1.0)
	local regenPerSec = (classSpec and classSpec.RegenPerSec) or (if canonicalClass == "YonkoBoss" then 0.025 else 0.0)
	local isBoss = (classSpec and (classSpec.BossFlag or classSpec.IsBoss)) or (canonicalClass == "YonkoBoss" or enemyClass == "YonkoKaido")

	local maxHp = math.floor(rawHp * hpMult)
	local speed = baseSpeed * speedMult
	if canonicalClass == "SoruAssassin" then
		speed = math.min(34.0, speed)
	elseif canonicalClass == "HakiBrute" then
		speed = math.max(8.0, speed)
	elseif canonicalClass == "YonkoBoss" then
		speed = math.max(7.5, speed)
	end

	local armor = armorReduction
	if canonicalClass == "SoruAssassin" then
		armor = math.min(0.35, armorReduction * 0.5)
	elseif canonicalClass == "HakiBrute" then
		armor = math.min(0.75, armorReduction + 0.30)
	elseif canonicalClass == "YonkoBoss" then
		armor = math.min(0.70, armorReduction + 0.25)
	else
		armor = math.min(0.65, armorReduction)
	end

	local baseKillCash = (GameConfig.WAVE_SETTINGS and GameConfig.WAVE_SETTINGS.BASE_CASH_REWARD) or 25
	local cashReward = math.floor(baseKillCash * rewardMult)

	local name = (classSpec and classSpec.Name) or (if canonicalClass == "SoruAssassin" then "Soru Assassin" elseif canonicalClass == "HakiBrute" then "Armored Haki Brute" elseif canonicalClass == "YonkoBoss" then "Yonko Calamity Boss" else "Pirate Grunt")
	local bodyColor = (classSpec and classSpec.BodyColor) or (if canonicalClass == "SoruAssassin" then Color3.fromRGB(30, 95, 190) elseif canonicalClass == "HakiBrute" then Color3.fromRGB(22, 20, 28) elseif canonicalClass == "YonkoBoss" then Color3.fromRGB(130, 18, 35) else Color3.fromRGB(55, 95, 65))
	local auraColor = (classSpec and classSpec.AuraColor) or (if canonicalClass == "SoruAssassin" then Color3.fromRGB(0, 225, 255) elseif canonicalClass == "HakiBrute" then Color3.fromRGB(165, 40, 255) elseif canonicalClass == "YonkoBoss" then Color3.fromRGB(255, 20, 60) else Color3.fromRGB(90, 40, 140))

	return {
		CanonicalClass = canonicalClass,
		Name = name,
		MaxHP = maxHp,
		Speed = speed,
		Armor = armor,
		Scale = scale,
		RegenPerSec = regenPerSec,
		Cash = cashReward,
		BodyColor = bodyColor,
		AuraColor = auraColor,
		IsBoss = isBoss,
	}
end

local function createEnemyR6Model(wave: number, enemyClass: string, stats: any): (Model, Part, Part, BillboardGui, Frame?)
	local customTemplates = ReplicatedStorage:FindFirstChild("EnemyModels")
	local model: Model? = nil

	-- Tier 1: Check ReplicatedStorage.EnemyModels for Rojo-mounted .rbxmx models
	if customTemplates and customTemplates:FindFirstChild(stats.CanonicalClass or enemyClass) then
		local tmpl = customTemplates:FindFirstChild(stats.CanonicalClass or enemyClass)
		if tmpl and tmpl:IsA("Model") then
			model = tmpl:Clone() :: Model
			model:SetAttribute("AssetKitSkinned", true)
		end
	end

	-- Tier 2: Create authentic Roblox R6 Humanoid rig with HumanoidDescription
	if not model then
		local ok, rig = pcall(function()
			local desc = Instance.new("HumanoidDescription")
			desc.HeadColor = stats.BodyColor
			desc.TorsoColor = Color3.fromRGB(30, 32, 42)
			desc.LeftArmColor = stats.BodyColor
			desc.RightArmColor = stats.BodyColor
			desc.LeftLegColor = Color3.fromRGB(25, 25, 30)
			desc.RightLegColor = Color3.fromRGB(25, 25, 30)
			return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
		end)
		if ok and rig and rig:IsA("Model") then
			model = rig
		end
	end

	-- Tier 3: Procedural Model Fallback for Headless CLI Unit Tests
	if not model then
		model = Instance.new("Model")
		local root = Instance.new("Part")
		root.Name = "HumanoidRootPart"
		root.Size = Vector3.new(2, 2, 1) * stats.Scale
		root.Position = WAYPOINT_COORDS[1]
		root.Anchored = true
		root.CanCollide = false
		root.Color = stats.BodyColor
		root.Parent = model

		local head = Instance.new("Part")
		head.Name = "Head"
		head.Size = Vector3.new(1.2, 1.2, 1.2) * stats.Scale
		head.Position = root.Position + Vector3.new(0, 2.0 * stats.Scale, 0)
		head.Anchored = true
		head.CanCollide = false
		head.Color = stats.BodyColor
		head.Parent = model

		local hum = Instance.new("Humanoid")
		hum.Parent = model
		model.PrimaryPart = root
	end

	model.Name = stats.Name

	-- Ensure PrimaryPart and RootPart exist
	local root = model:FindFirstChild("HumanoidRootPart") :: Part? or model.PrimaryPart :: Part?
	if not root then
		root = Instance.new("Part")
		root.Name = "HumanoidRootPart"
		root.Size = Vector3.new(2, 2, 1) * stats.Scale
		root.Position = WAYPOINT_COORDS[1]
		root.Anchored = true
		root.CanCollide = false
		root.Parent = model
	end
	root.Parent = model
	model.PrimaryPart = root

	local head = model:FindFirstChild("Head") :: Part? or root

	-- Anchor all parts & disable collisions
	pcall(function()
		model:ScaleTo(stats.Scale)
	end)
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			desc.Anchored = true
			desc.CanCollide = false
			desc.CanTouch = false
		end
	end

	-- Multi-layered visual auras
	if stats.IsBoss then
		local aura = Instance.new("Part")
		aura.Name = "KaidoDragonAura"
		aura.Shape = Enum.PartType.Ball
		aura.Size = Vector3.new(10, 10, 10)
		aura.Position = root.Position
		aura.Anchored = true
		aura.CanCollide = false
		aura.Material = Enum.Material.Neon
		aura.Color = stats.AuraColor
		aura.Transparency = 0.72
		aura.Parent = model

		local hl = Instance.new("Highlight")
		hl.Name = "YonkoHighlight"
		hl.FillColor = stats.BodyColor
		hl.OutlineColor = stats.AuraColor
		hl.FillTransparency = 0.60
		hl.OutlineTransparency = 0.05
		hl.Adornee = model
		hl.Parent = model

		local light = Instance.new("PointLight")
		light.Name = "YonkoLight"
		light.Color = stats.AuraColor
		light.Brightness = 3.5
		light.Range = 22
		light.Parent = root

		local particles = Instance.new("ParticleEmitter")
		particles.Name = "ConquerorLightningSparks"
		particles.Rate = 18
		particles.Lifetime = NumberRange.new(0.3, 0.6)
		particles.Color = ColorSequence.new(Color3.fromRGB(255, 40, 70), Color3.fromRGB(30, 5, 10))
		particles.Parent = root
	elseif stats.CanonicalClass == "SoruAssassin" then
		local hl = Instance.new("Highlight")
		hl.Name = "SoruHighlight"
		hl.FillColor = Color3.fromRGB(0, 190, 255)
		hl.OutlineColor = Color3.fromRGB(150, 240, 255)
		hl.FillTransparency = 0.72
		hl.OutlineTransparency = 0.20
		hl.Adornee = model
		hl.Parent = model

		local light = Instance.new("PointLight")
		light.Name = "SoruLight"
		light.Color = stats.AuraColor
		light.Brightness = 1.8
		light.Range = 10
		light.Parent = root

		local particles = Instance.new("ParticleEmitter")
		particles.Name = "SoruSpeedParticles"
		particles.Rate = 14
		particles.Lifetime = NumberRange.new(0.2, 0.4)
		particles.Speed = NumberRange.new(4, 9)
		particles.SpreadAngle = Vector2.new(15, 15)
		particles.Color = ColorSequence.new(Color3.fromRGB(0, 225, 255), Color3.fromRGB(220, 255, 255))
		particles.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
		particles.EmissionDirection = Enum.NormalId.Back
		particles.Parent = root
	elseif stats.CanonicalClass == "HakiBrute" then
		local hl = Instance.new("Highlight")
		hl.Name = "HakiHighlight"
		hl.FillColor = Color3.fromRGB(35, 15, 55)
		hl.OutlineColor = Color3.fromRGB(180, 50, 255)
		hl.FillTransparency = 0.65
		hl.OutlineTransparency = 0.10
		hl.Adornee = model
		hl.Parent = model

		local light = Instance.new("PointLight")
		light.Name = "HakiLight"
		light.Color = stats.AuraColor
		light.Brightness = 2.2
		light.Range = 14
		light.Parent = root

		local particles = Instance.new("ParticleEmitter")
		particles.Name = "HakiSmokeParticles"
		particles.Rate = 8
		particles.Lifetime = NumberRange.new(0.5, 0.9)
		particles.Speed = NumberRange.new(2, 5)
		particles.SpreadAngle = Vector2.new(45, 45)
		particles.Color = ColorSequence.new(Color3.fromRGB(165, 40, 255), Color3.fromRGB(20, 10, 30))
		particles.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
		particles.Parent = root
	end

	-- Micro Health Bar & BillboardGui (PLAN-0007)
	local bb = Instance.new("BillboardGui")
	bb.Name = "HPBarGui"
	bb.Size = stats.IsBoss and UDim2.new(0, 96, 0, 16) or UDim2.new(0, 52, 0, 6)
	bb.StudsOffset = Vector3.new(0, (stats.IsBoss and 3.2 or 2.4) * stats.Scale, 0)
	bb.AlwaysOnTop = false
	bb.MaxDistance = stats.IsBoss and 90 or 85
	bb.Adornee = head
	bb.Parent = root

	local bg = Instance.new("Frame")
	bg.Name = "Bg"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	bg.BackgroundTransparency = stats.IsBoss and 0.20 or 0.25
	bg.BorderSizePixel = 0
	bg.Parent = bb

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, stats.IsBoss and 3 or 2)
	bgCorner.Parent = bg

	if stats.IsBoss then
		local bgStroke = Instance.new("UIStroke")
		bgStroke.Color = Color3.fromRGB(90, 20, 30)
		bgStroke.Thickness = 1
		bgStroke.Parent = bg
	end

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = stats.IsBoss and Color3.fromRGB(255, 45, 70) or Color3.fromRGB(50, 230, 110)
	fill.BorderSizePixel = 0
	fill.Parent = bg

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, stats.IsBoss and 3 or 2)
	fillCorner.Parent = fill

	if stats.IsBoss then
		local title = Instance.new("TextLabel")
		title.Name = "BossTitle"
		title.Size = UDim2.new(1, 0, 0, 11)
		title.Position = UDim2.new(0, 0, 0, -12)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBold
		title.TextSize = 10
		title.TextColor3 = Color3.fromRGB(255, 220, 80)
		title.TextStrokeTransparency = 0.5
		title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		title.Text = "[BOSS] YONKO CALAMITY"
		title.Parent = bb
	end

	return model, root, head, bb, fill
end

-- ============================================================================
-- 4. เสกศัตรูเข้าสู่สนามรบพร้อมลูปฟื้นเลือดและระบบสโลว์หนวดขาว
-- ============================================================================
local function spawnEnemy(enemyKey: string, waveNum: number, enemiesFolder: Folder): ()
	local stats = calculateEnemyStats(waveNum, enemyKey)
	local spec = {
		Name = stats.Name,
		BaseHP = stats.MaxHP,
		Speed = stats.Speed,
		Cash = stats.Cash,
		Scale = stats.Scale,
		Color = stats.BodyColor,
	}

	local model, root, head, bb, fill = createEnemyR6Model(waveNum, enemyKey, stats)

	model:SetAttribute("HP", stats.MaxHP)
	model:SetAttribute("MaxHP", stats.MaxHP)
	model:SetAttribute("Speed", stats.Speed)
	model:SetAttribute("ArmorReduction", stats.Armor)
	model:SetAttribute("EnemyClass", stats.CanonicalClass or enemyKey)
	model:SetAttribute("CashReward", spec.Cash)
	model:SetAttribute("SlowUntil", 0)
	model:SetAttribute("RegenPerSec", stats.RegenPerSec)
	model:SetAttribute("IsBoss", stats.IsBoss)

	model.PrimaryPart = root
	model.Parent = enemiesFolder

	local isDead = false

	model:GetAttributeChangedSignal("HP"):Connect(function()
		local currentHp = (model:GetAttribute("HP") :: number?) or 0
		local maxHp = (model:GetAttribute("MaxHP") :: number?) or stats.MaxHP
		if fill then
			local ratio = math.clamp(currentHp / math.max(1, maxHp), 0, 1)
			fill.Size = UDim2.new(ratio, 0, 1, 0)
		end
		if currentHp <= 0 and not isDead and model.Parent then
			isDead = true
			awardCashToAllPlayers(spec.Cash)
			model:Destroy()
		end
	end)

	if stats.RegenPerSec and stats.RegenPerSec > 0 then
		task.spawn(function()
			while model.Parent and not isDead do
				task.wait(1.0)
				if not model.Parent or isDead then
					break
				end
				local curHp = (model:GetAttribute("HP") :: number?) or 0
				local maxHp = (model:GetAttribute("MaxHP") :: number?) or stats.MaxHP
				if curHp > 0 and curHp < maxHp then
					local heal = math.floor(maxHp * stats.RegenPerSec)
					local newHp = math.min(maxHp, curHp + heal)
					model:SetAttribute("HP", newHp)
				end
			end
		end)
	end

	task.spawn(function()
		local stepTick = 0

		-- Cache relative offsets for articulated walking locomotion
		local headRelOffsets: { [BasePart]: CFrame } = {}
		local leftLegOffsets: { [BasePart]: CFrame } = {}
		local rightLegOffsets: { [BasePart]: CFrame } = {}
		local leftArmOffsets: { [BasePart]: CFrame } = {}
		local rightArmOffsets: { [BasePart]: CFrame } = {}

		local hipLPos = root.CFrame * CFrame.new(-0.53 * stats.Scale, -0.60 * stats.Scale, 0)
		local hipRPos = root.CFrame * CFrame.new(0.53 * stats.Scale, -0.60 * stats.Scale, 0)
		local shLPos = root.CFrame * CFrame.new(-1.39 * stats.Scale, 0.75 * stats.Scale, 0)
		local shRPos = root.CFrame * CFrame.new(1.39 * stats.Scale, 0.75 * stats.Scale, 0)

		for _, desc in ipairs(model:GetDescendants()) do
			if desc:IsA("BasePart") and desc ~= root then
				local pName = desc.Name
				if head and head ~= root and (pName == "Neck" or string.find(pName, "Nose") or string.find(pName, "Ear") or string.find(pName, "Eye") or string.find(pName, "Pupil") or string.find(pName, "Teeth") or string.find(pName, "Mouth") or string.find(pName, "Smile") or string.find(pName, "Smirk") or string.find(pName, "Jaw") or string.find(pName, "Chin") or string.find(pName, "Fang") or string.find(pName, "Bevel") or string.find(pName, "Hair") or string.find(pName, "Spike") or string.find(pName, "Bandana") or string.find(pName, "Mask") or string.find(pName, "Horn")) then
					headRelOffsets[desc] = head.CFrame:ToObjectSpace(desc.CFrame)
				elseif (string.find(pName, "_2") and (string.find(pName, "Thigh") or string.find(pName, "Shin") or string.find(pName, "Leg") or string.find(pName, "Boot") or string.find(pName, "Toe"))) or (string.find(pName, "ShortsCuff") and desc.Position.X >= root.Position.X) then
					rightLegOffsets[desc] = hipRPos:ToObjectSpace(desc.CFrame)
				elseif ((string.find(pName, "Thigh") or string.find(pName, "Shin") or string.find(pName, "Leg") or string.find(pName, "Boot") or string.find(pName, "Toe")) and not string.find(pName, "_2")) or (string.find(pName, "ShortsCuff") and desc.Position.X < root.Position.X) then
					leftLegOffsets[desc] = hipLPos:ToObjectSpace(desc.CFrame)
				elseif (string.find(pName, "_2") and (string.find(pName, "Shoulder") or string.find(pName, "Arm") or string.find(pName, "Forearm") or string.find(pName, "Fist") or string.find(pName, "Knuckle") or string.find(pName, "Sleeve") or string.find(pName, "Hand"))) or string.find(pName, "Bone") or string.find(pName, "ClawBlade_2") or string.find(pName, "Kanabo") or string.find(pName, "BlackHakiFist") then
					rightArmOffsets[desc] = shRPos:ToObjectSpace(desc.CFrame)
				elseif ((string.find(pName, "Shoulder") or string.find(pName, "Arm") or string.find(pName, "Forearm") or string.find(pName, "Fist") or string.find(pName, "Knuckle") or string.find(pName, "Sleeve") or string.find(pName, "Hand")) and not string.find(pName, "_2")) or (string.find(pName, "ClawBlade") and not string.find(pName, "_2")) then
					leftArmOffsets[desc] = shLPos:ToObjectSpace(desc.CFrame)
				end
			end
		end

		for i = 2, #WAYPOINT_COORDS do
			local targetPos = WAYPOINT_COORDS[i]
			while model.Parent and not isDead and ((model:GetAttribute("HP") :: number?) or 0) > 0 do
				local curPos = root.Position
				local diff = targetPos - curPos
				local dist = diff.Magnitude
				if dist <= 1.2 then
					break
				end
				local slowUntil = (model:GetAttribute("SlowUntil") :: number?) or 0
				local speedMult = (os.clock() < slowUntil) and 0.45 or 1.0
				local stepDist = math.min(dist, spec.Speed * speedMult * 0.05)
				local nextPos = curPos + diff.Unit * stepDist
				stepTick += 1
				local bobOffset = math.sin(stepTick * 0.6) * 0.35
				root.CFrame = CFrame.lookAt(nextPos + Vector3.new(0, bobOffset, 0), targetPos)
				if head and head ~= root then
					head.CFrame = root.CFrame * CFrame.new(0, 2.0 * stats.Scale, 0)
				end
				local kaidoAura = model:FindFirstChild("KaidoDragonAura") :: BasePart?
				if kaidoAura then
					kaidoAura.Position = root.Position
				end
				model:PivotTo(root.CFrame)

				-- Articulated Limb Locomotion Stride & Synchronized Accessories
				if head and head ~= root then
					for p, relCF in pairs(headRelOffsets) do
						if p.Parent then
							p.CFrame = head.CFrame * relCF
						end
					end
				end

				local walkAngle = math.sin(stepTick * 0.6)
				local legSwing = walkAngle * 0.42
				local armSwing = -walkAngle * 0.35

				if stats.CanonicalClass == "SoruAssassin" then
					armSwing = math.rad(-45) + math.sin(stepTick * 0.8) * 0.15
					legSwing = math.sin(stepTick * 0.9) * 0.52
				elseif stats.CanonicalClass == "HakiBrute" then
					legSwing = walkAngle * 0.32
					armSwing = math.sin(stepTick * 0.5) * 0.40
				elseif stats.CanonicalClass == "YonkoBoss" then
					legSwing = walkAngle * 0.28
					armSwing = math.sin(stepTick * 0.4) * 0.25
				end

				local curHipL = root.CFrame * CFrame.new(-0.53 * stats.Scale, -0.60 * stats.Scale, 0) * CFrame.Angles(legSwing, 0, 0)
				local curHipR = root.CFrame * CFrame.new(0.53 * stats.Scale, -0.60 * stats.Scale, 0) * CFrame.Angles(-legSwing, 0, 0)
				local curShL = root.CFrame * CFrame.new(-1.39 * stats.Scale, 0.75 * stats.Scale, 0) * CFrame.Angles(armSwing, 0, 0)
				local curShR = root.CFrame * CFrame.new(1.39 * stats.Scale, 0.75 * stats.Scale, 0) * CFrame.Angles(-armSwing, 0, 0)

				for p, relCF in pairs(leftLegOffsets) do
					if p.Parent then
						p.CFrame = curHipL * relCF
					end
				end
				for p, relCF in pairs(rightLegOffsets) do
					if p.Parent then
						p.CFrame = curHipR * relCF
					end
				end
				for p, relCF in pairs(leftArmOffsets) do
					if p.Parent then
						p.CFrame = curShL * relCF
					end
				end
				for p, relCF in pairs(rightArmOffsets) do
					if p.Parent then
						p.CFrame = curShR * relCF
					end
				end

				task.wait(0.05)
			end
		end

		if model.Parent and not isDead and ((model:GetAttribute("HP") :: number?) or 0) > 0 then
			isDead = true
			local curBaseHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) :: number?) or 1000
			local dmgToBase = (enemyKey == "YonkoKaido" or stats.IsBoss) and 180 or 35
			local newBaseHp = math.max(0, curBaseHp - dmgToBase)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, newBaseHp)
			if newBaseHp <= 0 then
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, true)
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, "MARINEFORD FALLEN - GAME OVER")
			end
			model:Destroy()
		end
	end)
end

-- ============================================================================
-- 4. ลูปควบคุมเวฟ + ช่วงเตรียมตัว 15 วิ + รางวัลการ์ด & เหรียญสุ่มทุกเวฟ
-- ============================================================================
local function startWaveLoop(): ()
	if MapSelectionService then
		pcall(function()
			MapSelectionService.Init()
		end)
	end
	local _, _ = ensureMapAndWaypoints()
	local enemiesFolder = Workspace:WaitForChild(GameConfig.FOLDERS.ENEMIES or "Enemies") :: Folder
	local towersFolder = Workspace:WaitForChild(GameConfig.FOLDERS.TOWERS or "AnimeTowers") :: Folder

	while true do
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE, 1)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, 1000)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP, 1000)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, 0)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, false)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PENDING_CARD_DRAWS, 0)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN, 15)
		Workspace:SetAttribute("EarlyStartTriggered", false)

		if MapSelectionService then
			pcall(function()
				MapSelectionService.StartSelectionWindow(15)
			end)
		end

		-- Phase 3 Preparation Phase: Wait up to 15s or until player summons & places their first tower
		for prepSec = 15, 1, -1 do
			local curPrep = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN) :: number?) or prepSec
			local earlyTriggered = (Workspace:GetAttribute("EarlyStartTriggered") :: boolean?) or false
			if curPrep <= 0 or earlyTriggered then
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN, 0)
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, "HERO DEPLOYED! STARTING WAVE 1...")
				if MapSelectionService then
					pcall(function()
						MapSelectionService.LockSelection()
					end)
				end
				task.wait(1.5)
				break
			end
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN, prepSec)
			if #towersFolder:GetChildren() > 0 then
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN, 0)
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, "HERO DEPLOYED! STARTING WAVE 1...")
				if MapSelectionService then
					pcall(function()
						MapSelectionService.LockSelection()
					end)
				end
				task.wait(1.5)
				break
			end
			if ((Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN) :: number?) or prepSec) <= 0 or (Workspace:GetAttribute("EarlyStartTriggered") :: boolean?) then
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN, 0)
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, "HERO DEPLOYED! STARTING WAVE 1...")
				if MapSelectionService then
					pcall(function()
						MapSelectionService.LockSelection()
					end)
				end
				task.wait(1.5)
				break
			end
			Workspace:SetAttribute(
				GameConfig.WORKSPACE_ATTRS.WAVE_STATUS,
				string.format("PREP PHASE (%ds): กดปุ่ม SUMMON กลางจอเพื่อสุ่มและวางตัวละคร!", prepSec)
			)
			task.wait(1)
		end
		if MapSelectionService then
			pcall(function()
				MapSelectionService.LockSelection()
			end)
		end
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN, 0)

		local wave = 1
		while not (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) :: boolean) do
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE, wave)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, string.format("WAVE %d IN PROGRESS", wave))

			-- Update player leaderstats Wave if present
			for _, player in ipairs(Players:GetPlayers()) do
				local ls = player:FindFirstChild("leaderstats")
				local waveVal = ls and ls:FindFirstChild("Wave") :: IntValue?
				if waveVal then
					waveVal.Value = wave
				end
			end

			-- Dynamic high-density swarm count & interval (PLAN-0007)
			local count = 8 + math.floor(wave * 3.5)
			local spawnInterval = math.max(0.35, 0.85 - (wave - 1) * 0.035)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, count)

			local isBossWave = (wave % 3 == 0) or (wave >= 10)

			for i = 1, count do
				if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) then
					break
				end
				local key = "PirateGrunt"
				if wave % 5 == 0 and i == count then
					key = "YonkoKaido"
				elseif isBossWave and i == count then
					key = "YonkoBoss"
				elseif wave >= 3 and (i % 4 == 0) then
					key = "HakiBrute"
				elseif wave >= 2 and (i % 3 == 0) then
					key = "SoruAssassin"
				else
					key = "PirateGrunt"
				end
				spawnEnemy(key, wave, enemiesFolder)
				task.wait(spawnInterval)
			end

			while #enemiesFolder:GetChildren() > 0 and not (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) :: boolean) do
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, #enemiesFolder:GetChildren())
				task.wait(0.3)
			end
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, 0)

			if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) then
				break
			end

			-- Wave Cleared: Grant wave clear cash + trigger Roguelike Card Draft for all players
			awardCashToAllPlayers(90 + wave * 25)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, string.format("WAVE %d CLEARED! SELECT YOUR UPGRADE CARD!", wave))

			for _, player in ipairs(Players:GetPlayers()) do
				local pending = (player:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) :: number?) or 0
				player:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, pending + 1)
				local curTokens = (player:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
				player:SetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, curTokens + 1)
			end

			task.wait(4)
			wave += 1
		end

		-- Game Over Cleanup: Clear remaining enemies and wait before restart
		enemiesFolder:ClearAllChildren()
		task.wait(5)
	end
end

task.spawn(startWaveLoop)
