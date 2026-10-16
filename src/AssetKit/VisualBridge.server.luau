--!strict
-- Anime Limitless TD Asset Kit V2 — High-Detail One Piece Visual Adapter.
-- Does not replace game-owned root parts, attributes, combat, rewards, or ClickDetectors.
-- Generated XML assets contain only Parts; no untrusted Toolbox scripts.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local heroFolder = ReplicatedStorage:WaitForChild("HeroModels", 10)
local enemyFolder = ReplicatedStorage:WaitForChild("EnemyModels", 10)
local mapFolder = ReplicatedStorage:WaitForChild("MapModels", 10)

-- Canonical IDs & Direct Names verified against src/Shared/GameConfig.luau
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
	Nami = "Nami",
	Usopp = "Usopp",
	Sanji = "Sanji",
	VinsmokeSanji = "Sanji",
	VinsmokeSanjiModel = "Sanji",
	Chopper = "Chopper",
	Robin = "Robin",
	NicoRobin = "Robin",
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
}

-- WaveManager uses display names on spawned enemy models
local ENEMY_ALIASES: { [string]: string } = {
	["Thriller Bark Zombie"] = "PirateGrunt",
	["General Zombie"] = "HakiBrute",
	["Command General"] = "SoruAssassin",
	["YONKO KAIDO [DRAGON EMPEROR]"] = "YonkoBoss",
	PirateGrunt = "PirateGrunt",
	SoruAssassin = "SoruAssassin",
	HakiBrute = "HakiBrute",
	YonkoBoss = "YonkoBoss",
}

local installed = setmetatable({}, { __mode = "k" }) :: { [Instance]: boolean }

local function findTemplate(libraryFolder: Instance?, skinName: string): Model?
	if not libraryFolder then
		return nil
	end
	local targetName = HERO_ALIASES[skinName] or skinName
	local direct = libraryFolder:FindFirstChild(targetName) or libraryFolder:FindFirstChild(skinName)
	if direct and direct:IsA("Model") then
		return direct
	end
	for _, child in ipairs(libraryFolder:GetChildren()) do
		if child:IsA("Model") and (child.Name == targetName or child.Name == skinName or string.find(string.lower(child.Name), string.lower(targetName), 1, true)) then
			return child
		end
	end
	return nil
end

local function hideLegacyParts(model: Model, cosmeticModel: Model)
	-- Hide all legacy BaseParts & Decals (except Range/Aura indicators and the new AssetKitVisuals)
	for _, desc in ipairs(model:GetDescendants()) do
		if not desc:IsDescendantOf(cosmeticModel) then
			if desc:IsA("BasePart") and desc.Name ~= "AuraRing" and desc.Name ~= "RangeIndicator" then
				desc.Transparency = 1
			elseif desc:IsA("Decal") or desc:IsA("Texture") then
				desc.Transparency = 1
			end
		end
	end
end

local function attachSkin(model: Model, libraryFolder: Instance?, skinName: string)
	if installed[model] or model:GetAttribute("AssetKitSkinned") then
		return
	end
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	local template = findTemplate(libraryFolder, skinName)
	if not root or not root:IsA("BasePart") or not template or not template:IsA("Model") then
		warn("[AssetKit] Missing root or model template:", model:GetFullName(), skinName)
		return
	end

	-- Stage off-tree. A failed skin does not damage the original game model.
	local cosmetic = template:Clone()
	cosmetic.Name = "AssetKitVisuals"

	-- Strip untrusted toolbox scripts
	for _, desc in ipairs(cosmetic:GetDescendants()) do
		if desc:IsA("Script") or desc:IsA("LocalScript") then
			desc:Destroy()
		end
	end

	cosmetic:PivotTo(root.CFrame)
	local count = 0
	for _, part in ipairs(cosmetic:GetDescendants()) do
		if part:IsA("BasePart") then
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
			count += 1
		end
	end
	if count == 0 then
		cosmetic:Destroy()
		warn("[AssetKit] Template contains no BaseParts:", skinName)
		return
	end

	cosmetic.Parent = model
	hideLegacyParts(model, cosmetic)
	installed[model] = true
	model:SetAttribute("AssetKitSkinned", true)
	model:SetAttribute("AssetKitSkinName", skinName)
end

local function watchActiveModels(workspaceFolderName: string, library: Instance, resolve: (Model) -> string?)
	task.spawn(function()
		local container = Workspace:WaitForChild(workspaceFolderName, 30)
		if not container then
			return
		end
		local function process(child: Instance)
			if not child:IsA("Model") then
				return
			end
			task.defer(function()
				if not child.Parent then
					return
				end
				local skinName = resolve(child)
				if skinName then
					attachSkin(child, library, skinName)
				end
			end)
		end
		container.ChildAdded:Connect(process)
		for _, child in ipairs(container:GetChildren()) do
			process(child)
		end
	end)
end

watchActiveModels("AnimeTowers", heroFolder, function(model: Model): string?
	local heroId = model:GetAttribute("HeroId")
	if type(heroId) == "string" and HERO_ALIASES[heroId] then
		return HERO_ALIASES[heroId]
	end
	for key, val in pairs(HERO_ALIASES) do
		if string.find(model.Name, key, 1, true) then
			return val
		end
	end
	return nil
end)

watchActiveModels("Enemies", enemyFolder, function(model: Model): string?
	if ENEMY_ALIASES[model.Name] then
		return ENEMY_ALIASES[model.Name]
	end
	local enemyClass = model:GetAttribute("EnemyClass")
	if type(enemyClass) == "string" and ENEMY_ALIASES[enemyClass] then
		return ENEMY_ALIASES[enemyClass]
	end
	if string.find(model.Name, "Kaido", 1, true) or string.find(model.Name, "Boss", 1, true) then
		return "YonkoBoss"
	end
	return "PirateGrunt"
end)

watchActiveModels("ActiveEnemies", enemyFolder, function(model: Model): string?
	if ENEMY_ALIASES[model.Name] then
		return ENEMY_ALIASES[model.Name]
	end
	local enemyClass = model:GetAttribute("EnemyClass")
	if type(enemyClass) == "string" and ENEMY_ALIASES[enemyClass] then
		return ENEMY_ALIASES[enemyClass]
	end
	if string.find(model.Name, "Kaido", 1, true) or string.find(model.Name, "Boss", 1, true) then
		return "YonkoBoss"
	end
	return "PirateGrunt"
end)

-- Scene cosmetics are anchored and do not replace existing gameplay triggers.
local function placeScene(templateName: string, parent: Instance, worldCFrame: CFrame): Model?
	local source = mapFolder:FindFirstChild(templateName)
	if not source or not source:IsA("Model") then
		warn("[AssetKit] Missing scene template:", templateName)
		return nil
	end
	local copy = source:Clone()
	copy:PivotTo(worldCFrame)
	for _, p in ipairs(copy:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = true
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
		end
	end
	copy.Parent = parent
	return copy
end

task.spawn(function()
	local gameMap = Workspace:WaitForChild("GrandLineMap", 15) or Workspace
	local waypoints = Workspace:WaitForChild("Waypoints", 15)
	local pads = Workspace:FindFirstChild("TowerPlacementPads")
	local decoration = gameMap:FindFirstChild("AssetKitDecoration")
	if decoration then
		return
	end
	local f = Instance.new("Folder")
	f.Name = "AssetKitDecoration"
	f.Parent = gameMap

	if waypoints then
		local spawnPart = waypoints:FindFirstChild("Waypoint_1") or waypoints:FindFirstChild("1")
		if spawnPart and spawnPart:IsA("BasePart") then
			placeScene("EnemySpawnGate", f, CFrame.new(spawnPart.Position - Vector3.new(0, 0.5, 0)))
		end
	end

	local basePart = gameMap:FindFirstChild("PoneglyphBase") or Workspace:FindFirstChild("AnimeBaseCrystal")
	if basePart and basePart:IsA("BasePart") then
		local visual = placeScene("AnimeBaseCrystal", f, CFrame.new(basePart.Position - Vector3.new(0, 4, 0)))
		if visual then
			basePart.Transparency = 1
		end
	end

	if pads then
		for _, pad in ipairs(pads:GetChildren()) do
			if pad:IsA("BasePart") then
				local visual = placeScene("PlacementPadTemplate", f, CFrame.new(pad.Position))
				if visual then
					visual.Name = "PlacementPad_" .. pad.Name
					pad.Transparency = 0.75
				end
			end
		end
	end
end)
