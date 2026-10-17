--!strict
-- src/Track1_WaveSystem/Maps/Builders/VolcanicCitadel.luau
-- Anime Limitless Tower Defense — Phase 6 Map Builder: Volcanic Basalt Citadel

local Lighting = game:GetService("Lighting")

local VolcanicCitadelBuilder = {}

function VolcanicCitadelBuilder.Build(mapFolder: Folder, mapDef: any)
	-- 1. Main Volcanic Fortress Ground (Basalt & Obsidian)
	local ground = Instance.new("Part")
	ground.Name = "VolcanicCitadelPlaza"
	ground.Size = Vector3.new(220, 2, 180)
	ground.Position = Vector3.new(0, 0, 0)
	ground.Anchored = true
	ground.Material = Enum.Material.Slate
	ground.Color = Color3.fromRGB(30, 28, 32)
	ground.Parent = mapFolder

	-- 2. Glowing Magma Conduits along Perimeter (strictly outside combat lane)
	local magmaNorth = Instance.new("Part")
	magmaNorth.Name = "MagmaConduitNorth"
	magmaNorth.Size = Vector3.new(220, 2.2, 8)
	magmaNorth.Position = Vector3.new(0, 0.2, -88)
	magmaNorth.Anchored = true
	magmaNorth.CanCollide = false
	magmaNorth.Material = Enum.Material.Neon
	magmaNorth.Color = Color3.fromRGB(255, 75, 15)
	magmaNorth.Parent = mapFolder

	local magmaSouth = Instance.new("Part")
	magmaSouth.Name = "MagmaConduitSouth"
	magmaSouth.Size = Vector3.new(220, 2.2, 8)
	magmaSouth.Position = Vector3.new(0, 0.2, 88)
	magmaSouth.Anchored = true
	magmaSouth.CanCollide = false
	magmaSouth.Material = Enum.Material.Neon
	magmaSouth.Color = Color3.fromRGB(255, 75, 15)
	magmaSouth.Parent = mapFolder

	-- 3. Basalt Crags & Obsidian Obelisks
	for i = -2, 2 do
		local obelisk = Instance.new("Part")
		obelisk.Name = "ObsidianObelisk_" .. tostring(i)
		obelisk.Size = Vector3.new(6, 20, 6)
		obelisk.Position = Vector3.new(i * 46, 10, -78)
		obelisk.Anchored = true
		obelisk.Material = Enum.Material.Basalt
		obelisk.Color = Color3.fromRGB(22, 20, 25)
		obelisk.Parent = mapFolder
	end

	-- 4. Magma Forge Base Core
	local baseCore = Instance.new("Part")
	baseCore.Name = "PoneglyphBase"
	baseCore.Size = Vector3.new(14, 16, 14)
	baseCore.Position = mapDef.baseCFrame.Position + Vector3.new(8, 6, 0)
	baseCore.Anchored = true
	baseCore.Material = Enum.Material.Neon
	baseCore.Color = Color3.fromRGB(255, 95, 25)
	baseCore.Parent = mapFolder

	-- 5. Lighting Atmosphere
	pcall(function()
		Lighting.Brightness = mapDef.ambientLighting.Brightness
		Lighting.OutdoorAmbient = mapDef.ambientLighting.OutdoorAmbient
		Lighting.TimeOfDay = mapDef.ambientLighting.TimeOfDay
	end)
end

return table.freeze(VolcanicCitadelBuilder)
