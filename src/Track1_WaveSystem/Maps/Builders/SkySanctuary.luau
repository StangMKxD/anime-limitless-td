--!strict
-- src/Track1_WaveSystem/Maps/Builders/SkySanctuary.luau
-- Anime Limitless Tower Defense — Phase 6 Map Builder: Sky Sanctuary Island

local Lighting = game:GetService("Lighting")

local SkySanctuaryBuilder = {}

function SkySanctuaryBuilder.Build(mapFolder: Folder, mapDef: any)
	-- 1. Main Floating Island Foundation (White Marble & Sun Stone)
	local ground = Instance.new("Part")
	ground.Name = "SkySanctuaryPlaza"
	ground.Size = Vector3.new(220, 2, 180)
	ground.Position = Vector3.new(0, 0, 0)
	ground.Anchored = true
	ground.Material = Enum.Material.Marble
	ground.Color = Color3.fromRGB(240, 240, 245)
	ground.Parent = mapFolder

	-- 2. Cloud Buffer Platform Underneath
	local cloudBottom = Instance.new("Part")
	cloudBottom.Name = "CloudFoundation"
	cloudBottom.Size = Vector3.new(260, 10, 220)
	cloudBottom.Position = Vector3.new(0, -6, 0)
	cloudBottom.Anchored = true
	cloudBottom.Material = Enum.Material.Sand
	cloudBottom.Color = Color3.fromRGB(255, 255, 255)
	cloudBottom.Transparency = 0.35
	cloudBottom.Parent = mapFolder

	-- 3. Ancient Sundial & Celestial Pillars
	for i = -2, 2 do
		local pillar = Instance.new("Part")
		pillar.Name = "MarblePillar_" .. tostring(i)
		pillar.Size = Vector3.new(5, 22, 5)
		pillar.Position = Vector3.new(i * 48, 11, -85)
		pillar.Anchored = true
		pillar.Material = Enum.Material.Marble
		pillar.Color = Color3.fromRGB(250, 245, 235)
		pillar.Parent = mapFolder

		local capital = Instance.new("Part")
		capital.Name = "PillarCapital"
		capital.Size = Vector3.new(7, 2, 7)
		capital.Position = pillar.Position + Vector3.new(0, 11, 0)
		capital.Anchored = true
		capital.Material = Enum.Material.Marble
		capital.Color = Color3.fromRGB(255, 215, 100)
		capital.Parent = pillar
	end

	-- 4. Celestial Sun Stone Base Core
	local baseCore = Instance.new("Part")
	baseCore.Name = "PoneglyphBase"
	baseCore.Size = Vector3.new(14, 16, 14)
	baseCore.Position = mapDef.baseCFrame.Position + Vector3.new(8, 6, 0)
	baseCore.Anchored = true
	baseCore.Material = Enum.Material.Neon
	baseCore.Color = Color3.fromRGB(255, 230, 80)
	baseCore.Parent = mapFolder

	-- 5. Lighting Atmosphere
	pcall(function()
		Lighting.Brightness = mapDef.ambientLighting.Brightness
		Lighting.OutdoorAmbient = mapDef.ambientLighting.OutdoorAmbient
		Lighting.TimeOfDay = mapDef.ambientLighting.TimeOfDay
	end)
end

return table.freeze(SkySanctuaryBuilder)
