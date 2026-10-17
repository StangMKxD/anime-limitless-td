--!strict
-- src/Shared/MapCatalog.luau
-- Anime Limitless Tower Defense — Phase 6 Map Catalog
-- Immutable metadata definitions for all 4 battlefield themes.
-- Preserves 100% gameplay balance with layout-equivalent waypoints and placement slots.

export type MapDefinition = {
	schemaVersion: number,
	id: string,
	displayName: string,
	theme: string,
	description: string,
	isDefault: boolean,
	orderedWaypoints: { Vector3 },
	placementSlots: { [string]: Vector3 },
	baseCFrame: CFrame,
	spawnCFrame: CFrame,
	ambientLighting: {
		Brightness: number,
		OutdoorAmbient: Color3,
		TimeOfDay: string,
		FogColor: Color3?,
		FogEnd: number?,
	},
	cameraFocus: CFrame,
	builderKey: string,
}

local BASELINE_WAYPOINTS: { Vector3 } = {
	Vector3.new(-65, 3, -42),
	Vector3.new(-22, 3, -42),
	Vector3.new(-22, 3, 22),
	Vector3.new(22, 3, 22),
	Vector3.new(22, 3, -32),
	Vector3.new(65, 3, -32),
}

local BASELINE_SLOTS: { [string]: Vector3 } = {
	Slot_1 = Vector3.new(-45, 1.5, -55),
	Slot_2 = Vector3.new(-45, 1.5, -28),
	Slot_3 = Vector3.new(-10, 1.5, -10),
	Slot_4 = Vector3.new(-10, 1.5, 35),
	Slot_5 = Vector3.new(10, 1.5, 35),
	Slot_6 = Vector3.new(10, 1.5, -10),
	Slot_7 = Vector3.new(45, 1.5, -18),
	Slot_8 = Vector3.new(45, 1.5, -45),
}

local MAP_INVENTORY: { [string]: MapDefinition } = {
	Marineford = {
		schemaVersion = 1,
		id = "Marineford",
		displayName = "Marineford Naval Fortress",
		theme = "NavalFortress",
		description = "The historic Marineford plaza surrounded by defensive sea walls and navy banners.",
		isDefault = true,
		orderedWaypoints = BASELINE_WAYPOINTS,
		placementSlots = BASELINE_SLOTS,
		baseCFrame = CFrame.new(65, 3, -32),
		spawnCFrame = CFrame.new(-65, 3, -42),
		ambientLighting = {
			Brightness = 2.0,
			OutdoorAmbient = Color3.fromRGB(110, 120, 135),
			TimeOfDay = "14:00:00",
			FogColor = Color3.fromRGB(180, 200, 220),
			FogEnd = 500,
		},
		cameraFocus = CFrame.new(0, 30, 0),
		builderKey = "Marineford",
	},

	SakuraHarbor = {
		schemaVersion = 1,
		id = "SakuraHarbor",
		displayName = "Sakura Harbor Port",
		theme = "CherryBlossomPort",
		description = "A serene coastal harbor adorned with pink cherry blossoms, wooden docks, and paper lanterns.",
		isDefault = false,
		orderedWaypoints = BASELINE_WAYPOINTS,
		placementSlots = BASELINE_SLOTS,
		baseCFrame = CFrame.new(65, 3, -32),
		spawnCFrame = CFrame.new(-65, 3, -42),
		ambientLighting = {
			Brightness = 2.2,
			OutdoorAmbient = Color3.fromRGB(150, 120, 130),
			TimeOfDay = "17:30:00",
			FogColor = Color3.fromRGB(240, 200, 215),
			FogEnd = 450,
		},
		cameraFocus = CFrame.new(0, 30, 0),
		builderKey = "SakuraHarbor",
	},

	SkySanctuary = {
		schemaVersion = 1,
		id = "SkySanctuary",
		displayName = "Sky Island Sanctuary",
		theme = "CloudIslands",
		description = "An ancient temple resting above the clouds with pristine white marble pillars and golden sunbeams.",
		isDefault = false,
		orderedWaypoints = BASELINE_WAYPOINTS,
		placementSlots = BASELINE_SLOTS,
		baseCFrame = CFrame.new(65, 3, -32),
		spawnCFrame = CFrame.new(-65, 3, -42),
		ambientLighting = {
			Brightness = 2.8,
			OutdoorAmbient = Color3.fromRGB(140, 155, 185),
			TimeOfDay = "12:00:00",
			FogColor = Color3.fromRGB(220, 235, 255),
			FogEnd = 600,
		},
		cameraFocus = CFrame.new(0, 30, 0),
		builderKey = "SkySanctuary",
	},

	VolcanicCitadel = {
		schemaVersion = 1,
		id = "VolcanicCitadel",
		displayName = "Volcanic Basalt Citadel",
		theme = "BasaltFortress",
		description = "A fiery obsidian fortress bordered by glowing magma conduits and volcanic crags.",
		isDefault = false,
		orderedWaypoints = BASELINE_WAYPOINTS,
		placementSlots = BASELINE_SLOTS,
		baseCFrame = CFrame.new(65, 3, -32),
		spawnCFrame = CFrame.new(-65, 3, -42),
		ambientLighting = {
			Brightness = 1.8,
			OutdoorAmbient = Color3.fromRGB(135, 90, 80),
			TimeOfDay = "19:00:00",
			FogColor = Color3.fromRGB(80, 35, 25),
			FogEnd = 400,
		},
		cameraFocus = CFrame.new(0, 30, 0),
		builderKey = "VolcanicCitadel",
	},
}

local MapCatalog = {
	DEFAULT_MAP_ID = "Marineford",
	MAP_ORDER = { "Marineford", "SakuraHarbor", "SkySanctuary", "VolcanicCitadel" },
	BASELINE_WAYPOINTS = BASELINE_WAYPOINTS,
	BASELINE_SLOTS = BASELINE_SLOTS,
}

function MapCatalog.GetMap(mapId: string): MapDefinition?
	return MAP_INVENTORY[mapId]
end

function MapCatalog.GetDefaultMap(): MapDefinition
	return MAP_INVENTORY[MapCatalog.DEFAULT_MAP_ID]
end

function MapCatalog.GetAllMaps(): { MapDefinition }
	local list: { MapDefinition } = {}
	for _, id in ipairs(MapCatalog.MAP_ORDER) do
		local m = MAP_INVENTORY[id]
		if m then
			table.insert(list, m)
		end
	end
	return list
end

function MapCatalog.GetAllMapIds(): { string }
	return table.clone(MapCatalog.MAP_ORDER)
end

function MapCatalog.ValidateMapId(mapId: string): boolean
	return MAP_INVENTORY[mapId] ~= nil
end

return table.freeze(MapCatalog)
