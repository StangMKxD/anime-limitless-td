--!strict
-- src/Presentation/BossPresentation.luau
-- Anime Limitless Tower Defense — Phase 6 Boss Presentation Engine
-- Manages cosmetic boss entry cues, glowing auras, and base impact visuals without locking player input.

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VFXDispatcher = (function()
	local ok, mod = pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local pres = rs:WaitForChild("Presentation")
		return require(pres:WaitForChild("VFXDispatcher"))
	end)
	if ok and mod then return mod end
	if typeof(script) ~= "nil" and script.Parent then
		local ok2, mod2 = pcall(function()
			return require(script.Parent:WaitForChild("VFXDispatcher"))
		end)
		if ok2 and mod2 then return mod2 end
	end
	local ok3, mod3 = pcall(require, "./VFXDispatcher")
	if ok3 and mod3 then return mod3 end
	local ok4, mod4 = pcall(require, "../src/Presentation/VFXDispatcher")
	if ok4 and mod4 then return mod4 end
	error("Failed to resolve VFXDispatcher")
end)()

local BossPresentation = {}

function BossPresentation.TriggerBossSpawnPresentation(bossModel: Model, bossName: string)
	local root = bossModel:FindFirstChild("HumanoidRootPart") :: BasePart? or bossModel.PrimaryPart
	if not root then
		return
	end

	-- Create cosmetic ominous aura ring
	local aura = Instance.new("Part")
	aura.Name = "BossAuraRing"
	aura.Shape = Enum.PartType.Cylinder
	aura.Size = Vector3.new(0.5, 12, 12)
	aura.CFrame = root.CFrame * CFrame.Angles(0, 0, math.rad(90))
	aura.Anchored = true
	aura.CanCollide = false
	aura.Material = Enum.Material.Neon
	aura.Color = Color3.fromRGB(160, 25, 45)
	aura.Transparency = 0.4
	aura.Parent = Workspace

	local tw = TweenService:Create(aura, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.5, 24, 24),
		Transparency = 1,
	})
	tw:Play()

	task.delay(1.3, function()
		if aura.Parent then
			aura:Destroy()
		end
	end)
end

function BossPresentation.TriggerBaseImpactPresentation(impactPosition: Vector3)
	local shock = Instance.new("Part")
	shock.Name = "BossBaseImpactShockwave"
	shock.Shape = Enum.PartType.Ball
	shock.Size = Vector3.new(4, 4, 4)
	shock.Position = impactPosition
	shock.Anchored = true
	shock.CanCollide = false
	shock.Material = Enum.Material.Neon
	shock.Color = Color3.fromRGB(255, 60, 60)
	shock.Transparency = 0.2
	shock.Parent = Workspace

	local tw = TweenService:Create(shock, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(20, 20, 20),
		Transparency = 1,
	})
	tw:Play()

	task.delay(0.5, function()
		if shock.Parent then
			shock:Destroy()
		end
	end)
end

BossPresentation.CosmeticBossSpawnAura = BossPresentation.TriggerBossSpawnPresentation
BossPresentation.CosmeticBossImpactShockwave = BossPresentation.TriggerBaseImpactPresentation

return table.freeze(BossPresentation)
