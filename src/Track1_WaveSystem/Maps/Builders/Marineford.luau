--!strict
-- src/Track1_WaveSystem/Maps/Builders/Marineford.luau
-- Anime Limitless Tower Defense — Phase 6 Map Builder: Marineford Naval Fortress

local Lighting = game:GetService("Lighting")

local MarinefordBuilder = {}

function MarinefordBuilder.Build(mapFolder: Folder, mapDef: any)
	-- 1. Main Plaza Ground
	local ground = Instance.new("Part")
	ground.Name = "MarinefordPlaza"
	ground.Size = Vector3.new(220, 2, 180)
	ground.Position = Vector3.new(0, 0, 0)
	ground.Anchored = true
	ground.Material = Enum.Material.Cobblestone
	ground.Color = Color3.fromRGB(48, 52, 62)
	ground.Parent = mapFolder

	-- 2. Perimeter Sea Wall Barrier
	local seaWallNorth = Instance.new("Part")
	seaWallNorth.Name = "NavySeaWallNorth"
	seaWallNorth.Size = Vector3.new(220, 8, 4)
	seaWallNorth.Position = Vector3.new(0, 4, -90)
	seaWallNorth.Anchored = true
	seaWallNorth.Material = Enum.Material.Concrete
	seaWallNorth.Color = Color3.fromRGB(80, 85, 95)
	seaWallNorth.Parent = mapFolder

	local seaWallSouth = Instance.new("Part")
	seaWallSouth.Name = "NavySeaWallSouth"
	seaWallSouth.Size = Vector3.new(220, 8, 4)
	seaWallSouth.Position = Vector3.new(0, 4, 90)
	seaWallSouth.Anchored = true
	seaWallSouth.Material = Enum.Material.Concrete
	seaWallSouth.Color = Color3.fromRGB(80, 85, 95)
	seaWallSouth.Parent = mapFolder

	-- 3. Navy Headquarters Landmark Pillars
	for i = -2, 2 do
		local pillar = Instance.new("Part")
		pillar.Name = "NavyPillar_" .. tostring(i)
		pillar.Size = Vector3.new(4, 18, 4)
		pillar.Position = Vector3.new(i * 45, 9, -82)
		pillar.Anchored = true
		pillar.Material = Enum.Material.Concrete
		pillar.Color = Color3.fromRGB(180, 190, 205)
		pillar.Parent = mapFolder
	end

	-- 4. Poneglyph / Headquarters Base Core
	local baseCore = Instance.new("Part")
	baseCore.Name = "PoneglyphBase"
	baseCore.Size = Vector3.new(14, 16, 14)
	baseCore.Position = mapDef.baseCFrame.Position + Vector3.new(8, 6, 0)
	baseCore.Anchored = true
	baseCore.Material = Enum.Material.Neon
	baseCore.Color = Color3.fromRGB(55, 185, 255)
	baseCore.Parent = mapFolder

	-- 5. Lighting Atmosphere
	pcall(function()
		Lighting.Brightness = mapDef.ambientLighting.Brightness
		Lighting.OutdoorAmbient = mapDef.ambientLighting.OutdoorAmbient
		Lighting.TimeOfDay = mapDef.ambientLighting.TimeOfDay
	end)
end

return table.freeze(MarinefordBuilder)
