--!strict
-- src/Track1_WaveSystem/Maps/MapService.luau
-- Anime Limitless Tower Defense — Phase 6 Server Map Management Service
-- Controls map lifecycle, environmental building, waypoints, and pad setup.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(SharedFolder:WaitForChild("GameConfig")) :: any
local MapCatalog = require(SharedFolder:WaitForChild("MapCatalog")) :: any

local function loadBuilder(builderName: string): any
	if typeof(script) ~= "nil" and script.Parent then
		local bFolder = script.Parent:FindFirstChild("Builders")
		if bFolder and bFolder:FindFirstChild(builderName) then
			return require(bFolder:WaitForChild(builderName))
		end
	end
	local ok, mod = pcall(require, "./Builders/" .. builderName)
	if ok and mod then return mod end
	local ok2, mod2 = pcall(require, "../src/Track1_WaveSystem/Maps/Builders/" .. builderName)
	if ok2 and mod2 then return mod2 end
	local ok3, mod3 = pcall(require, "./src/Track1_WaveSystem/Maps/Builders/" .. builderName)
	if ok3 and mod3 then return mod3 end
	error("Failed to load builder: " .. builderName)
end

local MarinefordBuilder = loadBuilder("Marineford")
local SakuraHarborBuilder = loadBuilder("SakuraHarbor")
local SkySanctuaryBuilder = loadBuilder("SkySanctuary")
local VolcanicCitadelBuilder = loadBuilder("VolcanicCitadel")

local BUILDERS: { [string]: any } = {
	Marineford = MarinefordBuilder,
	SakuraHarbor = SakuraHarborBuilder,
	SkySanctuary = SkySanctuaryBuilder,
	VolcanicCitadel = VolcanicCitadelBuilder,
}

local activeMapId: string = MapCatalog.DEFAULT_MAP_ID
local isMapReady: boolean = false

local MapService = {}

function MapService.GetActiveMapId(): string
	return activeMapId
end

function MapService.IsMapReady(): boolean
	return isMapReady
end

function MapService.GetActiveMapDefinition(): any
	return MapCatalog.GetMap(activeMapId) or MapCatalog.GetDefaultMap()
end

function MapService.GetActiveWaypoints(): { Vector3 }
	local def = MapService.GetActiveMapDefinition()
	return def.orderedWaypoints
end

function MapService.GetActivePlacementSlots(): { [string]: Vector3 }
	local def = MapService.GetActiveMapDefinition()
	return def.placementSlots
end

function MapService.BuildMap(mapId: string): boolean
	local def = MapCatalog.GetMap(mapId)
	if not def then
		warn(string.format("[MapService] Unknown mapId '%s', falling back to default '%s'", tostring(mapId), MapCatalog.DEFAULT_MAP_ID))
		def = MapCatalog.GetDefaultMap()
	end

	local targetMapId = def.id
	local builder = BUILDERS[def.builderKey]
	if not builder then
		warn(string.format("[MapService] Missing builder for key '%s'", def.builderKey))
		builder = MarinefordBuilder
	end

	-- 1. Ensure or Clean Map Folder
	local mapFolderName = (GameConfig.FOLDERS and GameConfig.FOLDERS.MAP) or "GrandLineMap"
	local mapFolder = Workspace:FindFirstChild(mapFolderName) :: Folder?
	if not mapFolder then
		mapFolder = Instance.new("Folder")
		mapFolder.Name = mapFolderName
		mapFolder.Parent = Workspace
	else
		-- Clean existing environment parts (preserving towers / pads if required)
		for _, child in ipairs(mapFolder:GetChildren()) do
			if not string.find(child.Name, "PlacementPad") then
				child:Destroy()
			end
		end
	end

	-- 2. Execute Theme Builder
	local ok, err = pcall(function()
		builder.Build(mapFolder, def)
	end)
	if not ok then
		warn("[MapService] Builder encountered error:", err)
		return false
	end

	-- 3. Ensure Waypoints Folder Matches Active Map
	local wpFolderName = (GameConfig.FOLDERS and GameConfig.FOLDERS.WAYPOINTS) or "Waypoints"
	local wpFolder = Workspace:FindFirstChild(wpFolderName) :: Folder?
	if not wpFolder then
		wpFolder = Instance.new("Folder")
		wpFolder.Name = wpFolderName
		wpFolder.Parent = Workspace
	else
		wpFolder:ClearAllChildren()
	end

	for idx, pos in ipairs(def.orderedWaypoints) do
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

	-- 4. Ensure Placement Pads
	for slotName, slotPos in pairs(def.placementSlots) do
		local existingPad = mapFolder:FindFirstChild(slotName)
		if not existingPad then
			local pad = Instance.new("Part")
			pad.Name = slotName
			pad.Size = Vector3.new(6, 1, 6)
			pad.Position = slotPos
			pad.Anchored = true
			pad.CanCollide = false
			pad.Material = Enum.Material.Neon
			pad.Color = Color3.fromRGB(80, 160, 255)
			pad.Transparency = 0.3
			pad.Parent = mapFolder
		else
			(existingPad :: BasePart).Position = slotPos
		end
	end

	activeMapId = targetMapId
	isMapReady = true
	Workspace:SetAttribute("ActiveMapId", activeMapId)
	Workspace:SetAttribute("MapReady", true)

	return true
end

return table.freeze(MapService)
