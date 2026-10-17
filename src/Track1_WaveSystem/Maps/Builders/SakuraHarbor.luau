--!strict
-- src/Track1_WaveSystem/Maps/Builders/SakuraHarbor.luau
-- Anime Limitless Tower Defense — Phase 6 Map Builder: Sakura Harbor Port

local Lighting = game:GetService("Lighting")

local SakuraHarborBuilder = {}

function SakuraHarborBuilder.Build(mapFolder: Folder, mapDef: any)
	-- 1. Main Harbor Ground (Wood Planks & Stone Wharf)
	local ground = Instance.new("Part")
	ground.Name = "SakuraHarborWharf"
	ground.Size = Vector3.new(220, 2, 180)
	ground.Position = Vector3.new(0, 0, 0)
	ground.Anchored = true
	ground.Material = Enum.Material.WoodPlanks
	ground.Color = Color3.fromRGB(115, 80, 55)
	ground.Parent = mapFolder

	-- 2. Torii Gate Landmark at Entrance
	local toriiBeam = Instance.new("Part")
	toriiBeam.Name = "ToriiBeam"
	toriiBeam.Size = Vector3.new(24, 3, 3)
	toriiBeam.Position = mapDef.spawnCFrame.Position + Vector3.new(0, 15, 0)
	toriiBeam.Anchored = true
	toriiBeam.Material = Enum.Material.SmoothPlastic
	toriiBeam.Color = Color3.fromRGB(200, 35, 30)
	toriiBeam.Parent = mapFolder

	local toriiPostLeft = Instance.new("Part")
	toriiPostLeft.Name = "ToriiPostLeft"
	toriiPostLeft.Size = Vector3.new(3, 16, 3)
	toriiPostLeft.Position = toriiBeam.Position + Vector3.new(-10, -7.5, 0)
	toriiPostLeft.Anchored = true
	toriiPostLeft.Material = Enum.Material.SmoothPlastic
	toriiPostLeft.Color = Color3.fromRGB(200, 35, 30)
	toriiPostLeft.Parent = mapFolder

	local toriiPostRight = Instance.new("Part")
	toriiPostRight.Name = "ToriiPostRight"
	toriiPostRight.Size = Vector3.new(3, 16, 3)
	toriiPostRight.Position = toriiBeam.Position + Vector3.new(10, -7.5, 0)
	toriiPostRight.Anchored = true
	toriiPostRight.Material = Enum.Material.SmoothPlastic
	toriiPostRight.Color = Color3.fromRGB(200, 35, 30)
	toriiPostRight.Parent = mapFolder

	-- 3. Decorative Stone Lanterns along Harbor
	for i = -2, 2 do
		local lantern = Instance.new("Part")
		lantern.Name = "StoneLantern_" .. tostring(i)
		lantern.Size = Vector3.new(3, 8, 3)
		lantern.Position = Vector3.new(i * 45, 4, -80)
		lantern.Anchored = true
		lantern.Material = Enum.Material.Cobblestone
		lantern.Color = Color3.fromRGB(150, 150, 150)
		lantern.Parent = mapFolder

		local light = Instance.new("Part")
		light.Name = "LanternLight"
		light.Size = Vector3.new(1.5, 1.5, 1.5)
		light.Position = lantern.Position + Vector3.new(0, 3, 0)
		light.Anchored = true
		light.Material = Enum.Material.Neon
		light.Color = Color3.fromRGB(255, 180, 80)
		light.Parent = lantern
	end

	-- 4. Sakura Shrine Base Core
	local baseCore = Instance.new("Part")
	baseCore.Name = "PoneglyphBase"
	baseCore.Size = Vector3.new(14, 16, 14)
	baseCore.Position = mapDef.baseCFrame.Position + Vector3.new(8, 6, 0)
	baseCore.Anchored = true
	baseCore.Material = Enum.Material.Neon
	baseCore.Color = Color3.fromRGB(255, 120, 180)
	baseCore.Parent = mapFolder

	-- 5. Lighting Atmosphere
	pcall(function()
		Lighting.Brightness = mapDef.ambientLighting.Brightness
		Lighting.OutdoorAmbient = mapDef.ambientLighting.OutdoorAmbient
		Lighting.TimeOfDay = mapDef.ambientLighting.TimeOfDay
	end)
end

return table.freeze(SakuraHarborBuilder)
