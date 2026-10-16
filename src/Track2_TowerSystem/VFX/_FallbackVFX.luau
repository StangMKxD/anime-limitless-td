--!strict
-- src/Track2_TowerSystem/VFX/_FallbackVFX.luau
-- Anime Limitless Tower Defense — Phase 5 Canonical Fallback VFX Module
-- Handles all 7 common cues and extension cues with full ledger tracking & quality scaling.

local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local VFXContract = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("VFXContract")) :: any

local _FallbackVFX: VFXContract.CharacterVFXModule = {
	heroId = "_Fallback",
	maxConcurrentVFXInstances = 25,
	startPassiveAura = function(ctx: VFXContract.VFXExecutionContext) end,
	stopPassiveAura = function(sourceModel: Model) end,
	triggerCue = function(ctx: VFXContract.VFXExecutionContext) end,
	cleanupAllForModel = function(sourceModel: Model) end,
}

local auraParts: { [Model]: BasePart } = {}

function _FallbackVFX.startPassiveAura(ctx: VFXContract.VFXExecutionContext)
	if not ctx.layerFlags.enableAura then return end

	local root = ctx.rootPart
	local existingRing = auraParts[ctx.sourceModel]
	if existingRing and (not existingRing.Parent or not existingRing:IsDescendantOf(game)) then
		auraParts[ctx.sourceModel] = nil
		existingRing = nil
	end
	if not root or existingRing then return end

	local ring = Instance.new("Part")
	ring.Name = "FallbackPassiveAuraRing"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.2, 5.0, 5.0)
	ring.CFrame = root.CFrame * CFrame.new(0, -root.Size.Y * 0.45, 0) * CFrame.Angles(0, 0, math.rad(90))
	ring.Color = Color3.fromRGB(80, 180, 255)
	ring.Material = Enum.Material.Neon
	ring.Transparency = 0.65
	ring.Anchored = false
	ring.CanCollide = false
	ring.Massless = true
	ring.Parent = ctx.sandboxContainer or Workspace

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = ring
	weld.Parent = ring

	auraParts[ctx.sourceModel] = ring
	ctx.registerInstance(ring, nil)

	ctx.registerCleanupCallback(function()
		if auraParts[ctx.sourceModel] == ring then
			auraParts[ctx.sourceModel] = nil
		end
	end)

	local destroyConn: RBXScriptConnection? = nil
	destroyConn = ring.Destroying:Connect(function()
		if destroyConn then
			destroyConn:Disconnect()
		end
		if auraParts[ctx.sourceModel] == ring then
			auraParts[ctx.sourceModel] = nil
		end
	end)
end

function _FallbackVFX.stopPassiveAura(sourceModel: Model)
	local ring = auraParts[sourceModel]
	if ring then
		auraParts[sourceModel] = nil
		if ring.Parent then
			ring:Destroy()
		end
	end
end

function _FallbackVFX.triggerCue(ctx: VFXContract.VFXExecutionContext)
	local cue = ctx.cueType
	local root = ctx.rootPart
	local targetPos = ctx.targetPosition
	local container = ctx.sandboxContainer or Workspace

	if cue == "PassiveAura" then
		_FallbackVFX.startPassiveAura(ctx)

	elseif cue == "SpawnDeploy" then
		if not ctx.layerFlags.enableImpactEffect then return end

		local shockwave = Instance.new("Part")
		shockwave.Name = "FallbackSpawnShockwave"
		shockwave.Shape = Enum.PartType.Cylinder
		shockwave.Size = Vector3.new(0.3, 1.0, 1.0)
		shockwave.CFrame = CFrame.new(root.Position - Vector3.new(0, 1.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
		shockwave.Color = Color3.fromRGB(100, 200, 255)
		shockwave.Material = Enum.Material.Neon
		shockwave.Transparency = 0.2
		shockwave.Anchored = true
		shockwave.CanCollide = false
		shockwave.Parent = container
		ctx.registerInstance(shockwave, 0.6)

		local tw = TweenService:Create(shockwave, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, 8.0, 8.0),
			Transparency = 1.0,
		})
		tw:Play()
		ctx.registerTween(tw)

	elseif cue == "AttackWindup" then
		if not ctx.layerFlags.enableParticles then return end

		local flare = Instance.new("Part")
		flare.Name = "FallbackWindupFlare"
		flare.Shape = Enum.PartType.Ball
		flare.Size = Vector3.new(0.8, 0.8, 0.8)
		flare.CFrame = root.CFrame * CFrame.new(0.8, 0.5, -0.5)
		flare.Color = Color3.fromRGB(255, 180, 50)
		flare.Material = Enum.Material.Neon
		flare.Transparency = 0.3
		flare.Anchored = true
		flare.CanCollide = false
		flare.Parent = container
		ctx.registerInstance(flare, 0.14)

		local tw = TweenService:Create(flare, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = Vector3.new(1.8, 1.8, 1.8),
			Transparency = 0.1,
		})
		tw:Play()
		ctx.registerTween(tw)

	elseif cue == "AttackRelease" then
		if not ctx.layerFlags.enableTrailOrBeam then return end

		local projectile = Instance.new("Part")
		projectile.Name = "FallbackAttackBullet"
		projectile.Shape = Enum.PartType.Ball
		projectile.Size = Vector3.new(0.6, 0.6, 1.2)
		projectile.CFrame = CFrame.lookAt(root.Position + Vector3.new(0, 1, 0), targetPos)
		projectile.Color = Color3.fromRGB(255, 200, 80)
		projectile.Material = Enum.Material.Neon
		projectile.Anchored = true
		projectile.CanCollide = false
		projectile.Parent = container
		ctx.registerInstance(projectile, 0.12)

		local tw = TweenService:Create(projectile, TweenInfo.new(0.10, Enum.EasingStyle.Linear), {
			CFrame = CFrame.lookAt(targetPos, targetPos + (targetPos - root.Position).Unit),
		})
		tw:Play()
		ctx.registerTween(tw)

	elseif cue == "AttackImpact" then
		if ctx.layerFlags.enableImpactEffect then
			local sphere = Instance.new("Part")
			sphere.Name = "FallbackImpactBlast"
			sphere.Shape = Enum.PartType.Ball
			sphere.Size = Vector3.new(1.0, 1.0, 1.0)
			sphere.Position = targetPos
			sphere.Color = Color3.fromRGB(255, 120, 30)
			sphere.Material = Enum.Material.Neon
			sphere.Transparency = 0.2
			sphere.Anchored = true
			sphere.CanCollide = false
			sphere.Parent = container
			ctx.registerInstance(sphere, 0.25)

			local targetSize = 5.0 * ctx.intensity
			local tw = TweenService:Create(sphere, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(targetSize, targetSize, targetSize),
				Transparency = 1.0,
			})
			tw:Play()
			ctx.registerTween(tw)
		end

		local qConfig = VFXContract.ResolveQuality(ctx.quality)
		if qConfig.allowPointLights then
			local light = Instance.new("PointLight")
			light.Name = "FallbackImpactLight"
			light.Color = Color3.fromRGB(255, 160, 50)
			light.Range = 12 * ctx.intensity
			light.Brightness = 2.5
			local lightPart = Instance.new("Part")
			lightPart.Transparency = 1
			lightPart.Anchored = true
			lightPart.CanCollide = false
			lightPart.Position = targetPos
			lightPart.Parent = container
			light.Parent = lightPart
			ctx.registerInstance(lightPart, 0.15)
		end

	elseif cue == "UltimateCast" then
		if not ctx.layerFlags.enableAura then return end

		local pillar = Instance.new("Part")
		pillar.Name = "FallbackUltimateChargePillar"
		pillar.Shape = Enum.PartType.Cylinder
		pillar.Size = Vector3.new(8.0, 4.0, 4.0)
		pillar.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, 0, math.rad(90))
		pillar.Color = Color3.fromRGB(255, 230, 100)
		pillar.Material = Enum.Material.Neon
		pillar.Transparency = 0.4
		pillar.Anchored = true
		pillar.CanCollide = false
		pillar.Parent = container
		ctx.registerInstance(pillar, 0.5)

		local tw = TweenService:Create(pillar, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(16.0, 8.0, 8.0),
			Transparency = 1.0,
		})
		tw:Play()
		ctx.registerTween(tw)

	elseif cue == "UltimateImpact" then
		if not ctx.layerFlags.enableImpactEffect then return end

		local dome = Instance.new("Part")
		dome.Name = "FallbackUltimateDome"
		dome.Shape = Enum.PartType.Ball
		dome.Size = Vector3.new(2.0, 2.0, 2.0)
		dome.Position = targetPos
		dome.Color = Color3.fromRGB(255, 80, 20)
		dome.Material = Enum.Material.Neon
		dome.Transparency = 0.1
		dome.Anchored = true
		dome.CanCollide = false
		dome.Parent = container
		ctx.registerInstance(dome, 0.6)

		local domeSize = 14.0 * ctx.intensity
		local tw = TweenService:Create(dome, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(domeSize, domeSize, domeSize),
			Transparency = 1.0,
		})
		tw:Play()
		ctx.registerTween(tw)

	elseif cue == "SpecialIdleCue" then
		if not ctx.layerFlags.enableParticles then return end

		local puff = Instance.new("Part")
		puff.Name = "FallbackSpecialIdlePuff"
		puff.Shape = Enum.PartType.Ball
		puff.Size = Vector3.new(0.5, 0.5, 0.5)
		puff.Position = root.Position + Vector3.new(0, 2, 0)
		puff.Color = Color3.fromRGB(255, 255, 150)
		puff.Material = Enum.Material.Neon
		puff.Transparency = 0.3
		puff.Anchored = true
		puff.CanCollide = false
		puff.Parent = container
		ctx.registerInstance(puff, 0.4)

		local tw = TweenService:Create(puff, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(2.0, 2.0, 2.0),
			Transparency = 1.0,
		})
		tw:Play()
		ctx.registerTween(tw)
	end
end

function _FallbackVFX.cleanupAllForModel(sourceModel: Model)
	_FallbackVFX.stopPassiveAura(sourceModel)
	auraParts[sourceModel] = nil
end

return table.freeze(_FallbackVFX)
