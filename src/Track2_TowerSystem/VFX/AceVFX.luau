--!strict
-- src/Track2_TowerSystem/VFX/AceVFX.luau
-- Anime Limitless Tower Defense — Phase 5 Ace Flame Emperor Signature VFX Module (Task A-03)
-- Conforms strictly to VFXContract.CharacterVFXModule with heroId = "Ace".
-- Author: Explorer M4-3 (Milestone M4: Ace Character Pack)
--
-- Features:
-- 1. PassiveAura: Subtle flame ribbons on shoulders and fingertips with warm PointLight.
-- 2. SpawnDeploy: Fiery pillar impact, ground scorch ring, expanding ember wave.
-- 3. AttackWindup: Fiery sparks coiling around right hand, flame flare on fingertips (0.14s).
-- 4. AttackRelease: Hiken fire fist projectile/beam hurling forward along target ray (0.10s).
-- 5. AttackImpact: Conical fire blast, radial shockwave ring, orange-yellow spark burst (0.07s).
-- 6. UltimateCast: Colossal Dai Enkai: Entei sunball overhead (dense orange core + outer corona), upward fire vortex.
-- 7. UltimateImpact: Massive supernova explosion dome, expanding ground scorch ring, fiery shockwave, PointLight flash.
-- 8. SpecialIdleCue / FlameShoulderFlare: Hat tip flame swirl around brim + shoulder flame flare.
--
-- Strict Resource Ledger Compliance:
-- - 100% of created instances registered via ctx.registerInstance(inst, ttlSeconds).
-- - 100% of created tweens registered via ctx.registerTween(tw).
-- - Guaranteed zero-leak balance across single and concurrent models upon cleanupAllForModel.
-- - Preset scaling: strictly adheres to Low (max 8 parts), Medium (max 16 parts), High (max 30 parts).
-- - Layer flag toggles respected: enableAura, enableImpactEffect, enableTrailOrBeam, enableParticles.
-- - Decoupled from combat: fire-and-forget, zero damage calculation, zero enemy health mutation, pcall protected.

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local VFXContract = (function()
	local rep = game:GetService("ReplicatedStorage")
	local shared = rep:FindFirstChild("Shared")
	if shared and shared:FindFirstChild("VFXContract") then
		return require(shared:FindFirstChild("VFXContract") :: any) :: any
	end
	-- Fallback for test runners requiring relative path
	local candidatePaths = {
		"../../../src/Shared/VFXContract",
		"../../src/Shared/VFXContract",
		"../src/Shared/VFXContract",
		"src/Shared/VFXContract",
		"../../../Shared/VFXContract",
		"../../Shared/VFXContract",
	}
	for _, p in ipairs(candidatePaths) do
		local ok, mod = pcall(require, p)
		if ok then return mod end
	end
	error("[AceVFX] Could not locate VFXContract module")
end)()

local AceVFX: VFXContract.CharacterVFXModule = {
	heroId = "Ace",
	maxConcurrentVFXInstances = 25,
	startPassiveAura = function(ctx: VFXContract.VFXExecutionContext) end,
	stopPassiveAura = function(sourceModel: Model) end,
	triggerCue = function(ctx: VFXContract.VFXExecutionContext) end,
	cleanupAllForModel = function(sourceModel: Model) end,
}

-- Per-model active passive aura tracking
local activeAuras: { [Model]: { [Instance]: boolean } } = {}

-- =============================================================================
-- HELPER: TRAIL SAFETY MANAGEMENT (Zero Lingering Trails)
-- =============================================================================

function AceVFX.disableAllTrails(sourceModel: Model)
	for _, desc in ipairs(sourceModel:GetDescendants()) do
		if desc:IsA("Trail") then
			pcall(function()
				desc.Enabled = false
			end)
		end
	end
end

-- =============================================================================
-- 1. PASSIVE AURA: MERA MERA FLAME RIBBONS & FINGERTIP WISPS
-- =============================================================================

function AceVFX.startPassiveAura(ctx: VFXContract.VFXExecutionContext)
	if not ctx.layerFlags.enableAura then
		return
	end

	local sourceModel = ctx.sourceModel
	local root = ctx.rootPart
	if not root or not sourceModel or not sourceModel.Parent then
		return
	end

	-- Prevent duplicate aura creation if already active
	local existingAura = activeAuras[sourceModel]
	if existingAura then
		local hasLive = false
		for inst in pairs(existingAura) do
			if inst.Parent and inst:IsDescendantOf(game) then
				hasLive = true
				break
			end
		end
		if hasLive then
			return
		end
		activeAuras[sourceModel] = nil
	end

	local container = ctx.sandboxContainer or Workspace
	local qConfig = VFXContract.ResolveQuality(ctx.quality)
	local auraSet: { [Instance]: boolean } = {}
	activeAuras[sourceModel] = auraSet

	-- Find limbs or anchor directly to rootPart
	local torso = sourceModel:FindFirstChild("Torso") :: BasePart? or root
	local rightArm = sourceModel:FindFirstChild("RightArm") :: BasePart?
	local leftArm = sourceModel:FindFirstChild("LeftArm") :: BasePart?

	-- 1. Primary Right Hand Flame Wisp (fingertip Mera Mera fire)
	local rightHandFlame = Instance.new("Part")
	rightHandFlame.Name = "AceMera_RightHandFlameWisp"
	rightHandFlame.Shape = Enum.PartType.Ball
	rightHandFlame.Size = Vector3.new(0.85 * ctx.intensity, 0.85 * ctx.intensity, 0.85 * ctx.intensity)
	local rightAnchor = rightArm or torso
	rightHandFlame.CFrame = rightAnchor.CFrame * CFrame.new(0.2, -0.75, 0)
	rightHandFlame.Color = Color3.fromRGB(255, 135, 20) -- Mera Mera Orange
	rightHandFlame.Material = Enum.Material.Neon
	rightHandFlame.Transparency = 0.45
	rightHandFlame.Anchored = false
	rightHandFlame.CanCollide = false
	rightHandFlame.CanTouch = false
	rightHandFlame.CanQuery = false
	rightHandFlame.Massless = true
	rightHandFlame.Parent = container

	local weld1 = Instance.new("WeldConstraint")
	weld1.Part0 = rightAnchor
	weld1.Part1 = rightHandFlame
	weld1.Parent = rightHandFlame

	-- Warm PointLight (Medium & High quality)
	if qConfig.allowPointLights and ctx.quality ~= "Low" then
		local light = Instance.new("PointLight")
		light.Name = "AceMera_HandLight"
		light.Color = Color3.fromRGB(255, 140, 30)
		light.Range = 8 * ctx.intensity
		light.Brightness = 1.2
		light.Parent = rightHandFlame
	end

	auraSet[rightHandFlame] = true
	ctx.registerInstance(rightHandFlame, nil)

	-- 2. Secondary Shoulder Flame Ribbon (Medium & High quality)
	if ctx.quality ~= "Low" and qConfig.maxParts >= 2 then
		local shoulderRibbon = Instance.new("Part")
		shoulderRibbon.Name = "AceMera_ShoulderFlameRibbon"
		shoulderRibbon.Shape = Enum.PartType.Cylinder
		shoulderRibbon.Size = Vector3.new(0.20, 3.6 * ctx.intensity, 3.6 * ctx.intensity)
		shoulderRibbon.CFrame = torso.CFrame * CFrame.new(0, 1.15, 0) * CFrame.Angles(math.rad(10), 0, math.rad(90))
		shoulderRibbon.Color = Color3.fromRGB(255, 95, 15)
		shoulderRibbon.Material = Enum.Material.Neon
		shoulderRibbon.Transparency = 0.60
		shoulderRibbon.Anchored = false
		shoulderRibbon.CanCollide = false
		shoulderRibbon.CanTouch = false
		shoulderRibbon.CanQuery = false
		shoulderRibbon.Massless = true
		shoulderRibbon.Parent = container

		local weld2 = Instance.new("WeldConstraint")
		weld2.Part0 = torso
		weld2.Part1 = shoulderRibbon
		weld2.Parent = shoulderRibbon

		auraSet[shoulderRibbon] = true
		ctx.registerInstance(shoulderRibbon, nil)
	end

	-- 3. Third Floating Fingertip Spark / Left Hand Flame (High quality)
	if ctx.quality == "High" and qConfig.maxParts >= 3 then
		local leftHandFlame = Instance.new("Part")
		leftHandFlame.Name = "AceMera_LeftHandFlameWisp"
		leftHandFlame.Shape = Enum.PartType.Ball
		leftHandFlame.Size = Vector3.new(0.65, 0.65, 0.65)
		local leftAnchor = leftArm or torso
		leftHandFlame.CFrame = leftAnchor.CFrame * CFrame.new(-0.2, -0.65, 0)
		leftHandFlame.Color = Color3.fromRGB(255, 215, 45) -- Golden Ember
		leftHandFlame.Material = Enum.Material.Neon
		leftHandFlame.Transparency = 0.55
		leftHandFlame.Anchored = false
		leftHandFlame.CanCollide = false
		leftHandFlame.CanTouch = false
		leftHandFlame.CanQuery = false
		leftHandFlame.Massless = true
		leftHandFlame.Parent = container

		local weld3 = Instance.new("WeldConstraint")
		weld3.Part0 = leftAnchor
		weld3.Part1 = leftHandFlame
		weld3.Parent = leftHandFlame

		auraSet[leftHandFlame] = true
		ctx.registerInstance(leftHandFlame, nil)
	end

	-- Cleanup delegate registration
	ctx.registerCleanupCallback(function()
		AceVFX.stopPassiveAura(sourceModel)
	end)
end

function AceVFX.stopPassiveAura(sourceModel: Model)
	local auraSet = activeAuras[sourceModel]
	if auraSet then
		for inst in pairs(auraSet) do
			if inst.Parent then
				pcall(function()
					inst:Destroy()
				end)
			end
		end
		table.clear(auraSet)
		activeAuras[sourceModel] = nil
	end
end

-- =============================================================================
-- 2. SIGNATURE CUE DISPATCH: FLAME EMPEROR VISUAL EFFECTS
-- =============================================================================

function AceVFX.triggerCue(ctx: VFXContract.VFXExecutionContext)
	local cue = ctx.cueType
	local root = ctx.rootPart
	local sourceModel = ctx.sourceModel
	if not root or not sourceModel or not sourceModel.Parent then
		return
	end

	local targetPos = ctx.targetPosition or (root.Position + root.CFrame.LookVector * 15)
	local container = ctx.sandboxContainer or Workspace
	local qConfig = VFXContract.ResolveQuality(ctx.quality)
	local intensity = VFXContract.ClampIntensity(ctx.intensity)

	-- -------------------------------------------------------------------------
	-- CUE 1: PassiveAura
	-- -------------------------------------------------------------------------
	if cue == "PassiveAura" then
		AceVFX.startPassiveAura(ctx)

	-- -------------------------------------------------------------------------
	-- CUE 2: SpawnDeploy (Fiery Pillar Impact + Ground Scorch Ring + Ember Wave)
	-- -------------------------------------------------------------------------
	elseif cue == "SpawnDeploy" then
		if not ctx.layerFlags.enableImpactEffect then
			return
		end

		-- A. Fiery Pillar Impact (Sky-to-ground fire pillar)
		local pillar = Instance.new("Part")
		pillar.Name = "AceSpawn_FirePillar"
		pillar.Shape = Enum.PartType.Cylinder
		pillar.Size = Vector3.new(0.40, 24.0, 0.40)
		pillar.CFrame = CFrame.new(root.Position + Vector3.new(0, 12, 0)) * CFrame.Angles(0, 0, math.rad(90))
		pillar.Color = Color3.fromRGB(255, 130, 20) -- Fiery Pillar Orange
		pillar.Material = Enum.Material.Neon
		pillar.Transparency = 0.10
		pillar.Anchored = true
		pillar.CanCollide = false
		pillar.Parent = container
		ctx.registerInstance(pillar, 0.22)

		local twPillar = TweenService:Create(pillar, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1.0,
			Size = Vector3.new(0.08, 24.0, 0.08),
		})
		twPillar:Play()
		ctx.registerTween(twPillar)

		-- B. Ground Scorch Ring expanding on pad
		local scorchRing = Instance.new("Part")
		scorchRing.Name = "AceSpawn_GroundScorchRing"
		scorchRing.Shape = Enum.PartType.Cylinder
		scorchRing.Size = Vector3.new(0.25, 1.6, 1.6)
		scorchRing.CFrame = CFrame.new(root.Position - Vector3.new(0, 1.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
		scorchRing.Color = Color3.fromRGB(230, 70, 10) -- Crimson ember
		scorchRing.Material = Enum.Material.Neon
		scorchRing.Transparency = 0.20
		scorchRing.Anchored = true
		scorchRing.CanCollide = false
		scorchRing.Parent = container
		ctx.registerInstance(scorchRing, 0.45)

		local maxRadius = 9.5 * intensity
		local twRing = TweenService:Create(scorchRing, TweenInfo.new(0.40, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.10, maxRadius, maxRadius),
			Transparency = 1.0,
		})
		twRing:Play()
		ctx.registerTween(twRing)

		-- C. Expanding Ember Wave (Medium & High quality)
		if ctx.quality ~= "Low" and qConfig.maxParts >= 3 then
			local emberWave = Instance.new("Part")
			emberWave.Name = "AceSpawn_EmberWave"
			emberWave.Shape = Enum.PartType.Cylinder
			emberWave.Size = Vector3.new(0.15, 2.2, 2.2)
			emberWave.CFrame = CFrame.new(root.Position - Vector3.new(0, 1.45, 0)) * CFrame.Angles(0, 0, math.rad(90))
			emberWave.Color = Color3.fromRGB(255, 195, 40) -- Golden Yellow Ember
			emberWave.Material = Enum.Material.Neon
			emberWave.Transparency = 0.35
			emberWave.Anchored = true
			emberWave.CanCollide = false
			emberWave.Parent = container
			ctx.registerInstance(emberWave, 0.50)

			local twEmber = TweenService:Create(emberWave, TweenInfo.new(0.48, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.05, 13.5 * intensity, 13.5 * intensity),
				Transparency = 1.0,
			})
			twEmber:Play()
			ctx.registerTween(twEmber)
		end

		-- D. Secondary Outer Shockwave Ring (High quality)
		if ctx.quality == "High" and qConfig.maxParts >= 4 then
			local outerRing = Instance.new("Part")
			outerRing.Name = "AceSpawn_OuterShockRing"
			outerRing.Shape = Enum.PartType.Cylinder
			outerRing.Size = Vector3.new(0.10, 2.8, 2.8)
			outerRing.CFrame = CFrame.new(root.Position - Vector3.new(0, 1.48, 0)) * CFrame.Angles(0, 0, math.rad(90))
			outerRing.Color = Color3.fromRGB(255, 80, 10)
			outerRing.Material = Enum.Material.Neon
			outerRing.Transparency = 0.50
			outerRing.Anchored = true
			outerRing.CanCollide = false
			outerRing.Parent = container
			ctx.registerInstance(outerRing, 0.52)

			local twOuter = TweenService:Create(outerRing, TweenInfo.new(0.50, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.04, 16.0 * intensity, 16.0 * intensity),
				Transparency = 1.0,
			})
			twOuter:Play()
			ctx.registerTween(twOuter)
		end

	-- -------------------------------------------------------------------------
	-- CUE 3: AttackWindup (Fiery Sparks Coiling Around Right Hand + Fingertip Flare - 0.14s)
	-- -------------------------------------------------------------------------
	elseif cue == "AttackWindup" then
		if not ctx.layerFlags.enableAura and not ctx.layerFlags.enableParticles then
			return
		end

		local rightArm = sourceModel:FindFirstChild("RightArm") :: BasePart?
		local handPos = if rightArm
			then rightArm.Position + rightArm.CFrame.LookVector * 0.75
			else (root.Position + root.CFrame.RightVector * 1.35 + Vector3.new(0, 0.3, 0))

		local sparkCount = 1
		if ctx.quality == "Medium" then
			sparkCount = 2
		elseif ctx.quality == "High" then
			sparkCount = 3
		end

		for i = 1, sparkCount do
			local angle = (i * (math.pi * 2 / sparkCount)) + math.rad(25)
			local offset = Vector3.new(math.cos(angle) * 0.75, math.sin(angle) * 0.75, 0.20)

			local spark = Instance.new("Part")
			spark.Name = string.format("AceWindup_FlameSpark_%d", i)
			spark.Shape = Enum.PartType.Block
			spark.Size = Vector3.new(0.14, 0.14, 1.1 * intensity)
			spark.CFrame = CFrame.lookAt(handPos + offset, handPos)
			-- Alternating Fire Orange and Radiant Sun Yellow
			spark.Color = if i % 2 == 1 then Color3.fromRGB(255, 145, 20) else Color3.fromRGB(255, 220, 50)
			spark.Material = Enum.Material.Neon
			spark.Transparency = 0.10
			spark.Anchored = true
			spark.CanCollide = false
			spark.Parent = container
			ctx.registerInstance(spark, 0.16)

			local twSpark = TweenService:Create(spark, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				CFrame = CFrame.lookAt(handPos, handPos + root.CFrame.LookVector),
				Size = Vector3.new(0.04, 0.04, 0.25),
				Transparency = 0.90,
			})
			twSpark:Play()
			ctx.registerTween(twSpark)
		end

		-- Fingertip Flame Flare (Medium & High quality)
		if ctx.quality ~= "Low" and qConfig.maxParts >= 3 then
			local flare = Instance.new("Part")
			flare.Name = "AceWindup_FingertipFlare"
			flare.Shape = Enum.PartType.Ball
			flare.Size = Vector3.new(0.4, 0.4, 0.4)
			flare.Position = handPos
			flare.Color = Color3.fromRGB(255, 245, 110) -- Intense white-yellow ignition
			flare.Material = Enum.Material.Neon
			flare.Transparency = 0.15
			flare.Anchored = true
			flare.CanCollide = false
			flare.Parent = container
			ctx.registerInstance(flare, 0.14)

			local twFlare = TweenService:Create(flare, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(1.3 * intensity, 1.3 * intensity, 1.3 * intensity),
				Transparency = 1.0,
			})
			twFlare:Play()
			ctx.registerTween(twFlare)
		end

	-- -------------------------------------------------------------------------
	-- CUE 4: AttackRelease (Hiken Fire Fist Projectile & Flame Beam - 0.10s)
	-- -------------------------------------------------------------------------
	elseif cue == "AttackRelease" then
		if not ctx.layerFlags.enableTrailOrBeam then
			return
		end

		local originPos = root.Position + Vector3.new(0, 0.6, 0)
		local ray = targetPos - originPos
		local dist = ray.Magnitude
		local dir = if dist > 0.001 then ray.Unit else root.CFrame.LookVector

		-- A. Hiken Fire Fist Projectile
		local fistPos = originPos + dir * (dist * 0.45)
		local hikenFist = Instance.new("Part")
		hikenFist.Name = "AceRelease_HikenProjectile"
		hikenFist.Shape = Enum.PartType.Ball
		hikenFist.Size = Vector3.new(1.8 * intensity, 1.8 * intensity, 2.6 * intensity)
		hikenFist.CFrame = CFrame.lookAt(fistPos, fistPos + dir)
		hikenFist.Color = Color3.fromRGB(255, 110, 20) -- Hiken Fire Fist Orange
		hikenFist.Material = Enum.Material.Neon
		hikenFist.Transparency = 0.10
		hikenFist.Anchored = true
		hikenFist.CanCollide = false
		hikenFist.Parent = container
		ctx.registerInstance(hikenFist, 0.25)

		local targetFistPos = fistPos + dir * 6.5
		local twFist = TweenService:Create(hikenFist, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = targetFistPos,
			Size = Vector3.new(2.4 * intensity, 2.4 * intensity, 3.4 * intensity),
			Transparency = 0.85,
		})
		twFist:Play()
		ctx.registerTween(twFist)

		-- B. Connecting Flame Beam / Stream (Medium & High quality)
		if ctx.quality ~= "Low" and qConfig.allowBeams and qConfig.maxParts >= 2 then
			local beamLen = math.min(dist * 0.70, 12.0)
			local flameBeam = Instance.new("Part")
			flameBeam.Name = "AceRelease_FlameBeam"
			flameBeam.Shape = Enum.PartType.Cylinder
			flameBeam.Size = Vector3.new(0.30, beamLen, 0.30)
			flameBeam.CFrame = CFrame.lookAt(originPos, originPos + dir) * CFrame.new(0, 0, -beamLen * 0.5) * CFrame.Angles(0, 0, math.rad(90))
			flameBeam.Color = Color3.fromRGB(255, 160, 30)
			flameBeam.Material = Enum.Material.Neon
			flameBeam.Transparency = 0.25
			flameBeam.Anchored = true
			flameBeam.CanCollide = false
			flameBeam.Parent = container
			ctx.registerInstance(flameBeam, 0.20)

			local twBeam = TweenService:Create(flameBeam, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.08, beamLen * 1.1, 0.08),
				Transparency = 1.0,
			})
			twBeam:Play()
			ctx.registerTween(twBeam)
		end

		-- C. High Quality Additions: Inner Core + Swirling Ribbon
		if ctx.quality == "High" and qConfig.maxParts >= 4 then
			local innerCore = Instance.new("Part")
			innerCore.Name = "AceRelease_HikenInnerCore"
			innerCore.Shape = Enum.PartType.Ball
			innerCore.Size = Vector3.new(1.0 * intensity, 1.0 * intensity, 1.6 * intensity)
			innerCore.CFrame = CFrame.lookAt(fistPos, fistPos + dir)
			innerCore.Color = Color3.fromRGB(255, 245, 130) -- White-Yellow Core
			innerCore.Material = Enum.Material.Neon
			innerCore.Transparency = 0.05
			innerCore.Anchored = true
			innerCore.CanCollide = false
			innerCore.Parent = container
			ctx.registerInstance(innerCore, 0.25)

			local twInner = TweenService:Create(innerCore, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = targetFistPos,
				Size = Vector3.new(1.4 * intensity, 1.4 * intensity, 2.0 * intensity),
				Transparency = 0.90,
			})
			twInner:Play()
			ctx.registerTween(twInner)

			local swirlRibbon = Instance.new("Part")
			swirlRibbon.Name = "AceRelease_SwirlRibbon"
			swirlRibbon.Shape = Enum.PartType.Block
			swirlRibbon.Size = Vector3.new(0.15, 0.15, 2.2 * intensity)
			swirlRibbon.CFrame = CFrame.lookAt(fistPos + Vector3.new(0.4, 0.4, 0), fistPos)
			swirlRibbon.Color = Color3.fromRGB(230, 50, 10)
			swirlRibbon.Material = Enum.Material.Neon
			swirlRibbon.Transparency = 0.30
			swirlRibbon.Anchored = true
			swirlRibbon.CanCollide = false
			swirlRibbon.Parent = container
			ctx.registerInstance(swirlRibbon, 0.20)

			local twSwirl = TweenService:Create(swirlRibbon, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1.0,
			})
			twSwirl:Play()
			ctx.registerTween(twSwirl)
		end

	-- -------------------------------------------------------------------------
	-- CUE 5: AttackImpact (Conical Fire Blast + Radial Shockwave + Spark Burst - 0.07s)
	-- -------------------------------------------------------------------------
	elseif cue == "AttackImpact" then
		-- Invariant: disable any lingering trails on impact
		AceVFX.disableAllTrails(sourceModel)

		if ctx.layerFlags.enableImpactEffect then
			-- A. Conical Fire Blast / Flame Pillar Burst
			local flameBlast = Instance.new("Part")
			flameBlast.Name = "AceImpact_FlameBlast"
			flameBlast.Shape = Enum.PartType.Cylinder
			flameBlast.Size = Vector3.new(0.40, 4.5 * intensity, 0.40)
			flameBlast.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, 0, math.rad(90))
			flameBlast.Color = Color3.fromRGB(255, 115, 15)
			flameBlast.Material = Enum.Material.Neon
			flameBlast.Transparency = 0.10
			flameBlast.Anchored = true
			flameBlast.CanCollide = false
			flameBlast.Parent = container
			ctx.registerInstance(flameBlast, 0.26)

			local twBlast = TweenService:Create(flameBlast, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.15, 7.0 * intensity, 7.0 * intensity),
				Transparency = 1.0,
			})
			twBlast:Play()
			ctx.registerTween(twBlast)

			-- B. High Quality Secondary Inner Core Blast
			if ctx.quality == "High" and qConfig.maxParts >= 6 then
				local innerBlast = Instance.new("Part")
				innerBlast.Name = "AceImpact_InnerCoreBlast"
				innerBlast.Shape = Enum.PartType.Cylinder
				innerBlast.Size = Vector3.new(0.30, 3.2 * intensity, 0.30)
				innerBlast.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, 0, math.rad(90))
				innerBlast.Color = Color3.fromRGB(255, 240, 100) -- Sun Yellow Core
				innerBlast.Material = Enum.Material.Neon
				innerBlast.Transparency = 0.05
				innerBlast.Anchored = true
				innerBlast.CanCollide = false
				innerBlast.Parent = container
				ctx.registerInstance(innerBlast, 0.22)

				local twInnerB = TweenService:Create(innerBlast, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(0.10, 5.0 * intensity, 5.0 * intensity),
					Transparency = 1.0,
				})
				twInnerB:Play()
				ctx.registerTween(twInnerB)
			end

			-- C. Radial Scorch Shockwave Ring
			local shockwave = Instance.new("Part")
			shockwave.Name = "AceImpact_RadialShockwave"
			shockwave.Shape = Enum.PartType.Cylinder
			shockwave.Size = Vector3.new(0.20, 1.4, 1.4)
			shockwave.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, 0, math.rad(90))
			shockwave.Color = Color3.fromRGB(255, 140, 20)
			shockwave.Material = Enum.Material.Neon
			shockwave.Transparency = 0.15
			shockwave.Anchored = true
			shockwave.CanCollide = false
			shockwave.Parent = container
			ctx.registerInstance(shockwave, 0.28)

			local targetSize = 7.5 * intensity
			local twShock = TweenService:Create(shockwave, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.06, targetSize, targetSize),
				Transparency = 1.0,
			})
			twShock:Play()
			ctx.registerTween(twShock)

			-- D. Orange-Yellow Spark Burst Arcs
			local sparkCount = 1
			if ctx.quality == "Medium" then
				sparkCount = 3
			elseif ctx.quality == "High" then
				sparkCount = 5
			end

			for i = 1, sparkCount do
				local yaw = (i * (math.pi * 2 / sparkCount)) + math.rad(18)
				local pitch = math.rad((i % 3 - 1) * 25)
				local dirVec = Vector3.new(math.cos(yaw) * math.cos(pitch), math.sin(pitch), math.sin(yaw) * math.cos(pitch))
				local arcLen = 2.4 * intensity

				local spark = Instance.new("Part")
				spark.Name = string.format("AceImpact_FlameSpark_%d", i)
				spark.Shape = Enum.PartType.Block
				spark.Size = Vector3.new(0.14, 0.14, arcLen)
				spark.CFrame = CFrame.lookAt(targetPos, targetPos + dirVec) * CFrame.new(0, 0, -arcLen * 0.5)
				spark.Color = if i % 2 == 1 then Color3.fromRGB(255, 130, 20) else Color3.fromRGB(255, 225, 60)
				spark.Material = Enum.Material.Neon
				spark.Transparency = 0.05
				spark.Anchored = true
				spark.CanCollide = false
				spark.Parent = container
				ctx.registerInstance(spark, 0.24)

				local twSpark = TweenService:Create(spark, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(0.04, 0.04, arcLen * 1.6),
					Transparency = 1.0,
				})
				twSpark:Play()
				ctx.registerTween(twSpark)
			end
		end

		-- E. PointLight Flash (Medium & High quality)
		if ctx.layerFlags.enableImpactEffect and qConfig.allowPointLights then
			local lightPart = Instance.new("Part")
			lightPart.Name = "AceImpact_LightPart"
			lightPart.Transparency = 1.0
			lightPart.Anchored = true
			lightPart.CanCollide = false
			lightPart.Position = targetPos
			lightPart.Parent = container

			local light = Instance.new("PointLight")
			light.Name = "AceImpact_PointLight"
			light.Color = Color3.fromRGB(255, 140, 30)
			light.Range = 14 * intensity
			light.Brightness = 3.5
			light.Parent = lightPart

			ctx.registerInstance(lightPart, 0.14)
		end

	-- -------------------------------------------------------------------------
	-- CUE 6: UltimateCast (Dai Enkai: Entei — Colossal Sunball Overhead + Vortex)
	-- -------------------------------------------------------------------------
	elseif cue == "UltimateCast" then
		if not ctx.layerFlags.enableAura then
			return
		end

		local sunPos = root.Position + Vector3.new(0, 7.8, 0)

		-- A. Dense Orange Core (Entei Sunball Core)
		local sunCore = Instance.new("Part")
		sunCore.Name = "AceEntei_DenseSunCore"
		sunCore.Shape = Enum.PartType.Ball
		sunCore.Size = Vector3.new(1.6, 1.6, 1.6)
		sunCore.Position = sunPos
		sunCore.Color = Color3.fromRGB(255, 120, 20) -- Dense Orange Sun
		sunCore.Material = Enum.Material.Neon
		sunCore.Transparency = 0.15
		sunCore.Anchored = true
		sunCore.CanCollide = false
		sunCore.Parent = container
		ctx.registerInstance(sunCore, 0.90)

		local targetSunSize = 7.2 * intensity
		local twSun = TweenService:Create(sunCore, TweenInfo.new(0.70, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(targetSunSize, targetSunSize, targetSunSize),
			Transparency = 0.05,
		})
		twSun:Play()
		ctx.registerTween(twSun)

		-- B. Fiery Outer Corona (Medium & High quality)
		if ctx.quality ~= "Low" and qConfig.maxParts >= 2 then
			local outerCorona = Instance.new("Part")
			outerCorona.Name = "AceEntei_OuterCorona"
			outerCorona.Shape = Enum.PartType.Ball
			outerCorona.Size = Vector3.new(2.2, 2.2, 2.2)
			outerCorona.Position = sunPos
			outerCorona.Color = Color3.fromRGB(255, 55, 10) -- Crimson Outer Corona
			outerCorona.Material = Enum.Material.Neon
			outerCorona.Transparency = 0.45
			outerCorona.Anchored = true
			outerCorona.CanCollide = false
			outerCorona.Parent = container
			ctx.registerInstance(outerCorona, 0.95)

			local targetCoronaSize = 9.2 * intensity
			local twCorona = TweenService:Create(outerCorona, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(targetCoronaSize, targetCoronaSize, targetCoronaSize),
				Transparency = 0.30,
			})
			twCorona:Play()
			ctx.registerTween(twCorona)
		end

		-- C. Upward Fire Vortex Ribbons swirling toward Entei
		local vortexCount = if ctx.quality == "Low" then 1 elseif ctx.quality == "Medium" then 2 else 4
		for i = 1, vortexCount do
			local angle = (i * (math.pi * 2 / vortexCount))
			local offset = Vector3.new(math.cos(angle) * 3.4, math.sin(angle) * 1.4 - 2.0, math.sin(angle) * 3.4)

			local vortex = Instance.new("Part")
			vortex.Name = string.format("AceEntei_VortexRibbon_%d", i)
			vortex.Shape = Enum.PartType.Block
			vortex.Size = Vector3.new(0.18, 0.18, 3.4 * intensity)
			vortex.CFrame = CFrame.lookAt(sunPos + offset, sunPos)
			vortex.Color = if i % 2 == 1 then Color3.fromRGB(255, 145, 20) else Color3.fromRGB(255, 215, 45)
			vortex.Material = Enum.Material.Neon
			vortex.Transparency = 0.20
			vortex.Anchored = true
			vortex.CanCollide = false
			vortex.Parent = container
			ctx.registerInstance(vortex, 0.65)

			local twVortex = TweenService:Create(vortex, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Transparency = 0.90,
				Size = Vector3.new(0.06, 0.06, 1.2 * intensity),
			})
			twVortex:Play()
			ctx.registerTween(twVortex)
		end

	-- -------------------------------------------------------------------------
	-- CUE 7: UltimateImpact (Supernova Explosion Dome + Ground Scorch Ring)
	-- -------------------------------------------------------------------------
	elseif cue == "UltimateImpact" then
		AceVFX.disableAllTrails(sourceModel)

		if not ctx.layerFlags.enableImpactEffect then
			return
		end

		-- A. Supernova Blast Dome
		local blastDome = Instance.new("Part")
		blastDome.Name = "AceEntei_SupernovaBlastDome"
		blastDome.Shape = Enum.PartType.Ball
		blastDome.Size = Vector3.new(2.2, 2.2, 2.2)
		blastDome.Position = targetPos
		blastDome.Color = Color3.fromRGB(255, 130, 20) -- Supernova Orange
		blastDome.Material = Enum.Material.Neon
		blastDome.Transparency = 0.10
		blastDome.Anchored = true
		blastDome.CanCollide = false
		blastDome.Parent = container
		ctx.registerInstance(blastDome, 0.60)

		local domeSize = 18.0 * intensity
		local twDome = TweenService:Create(blastDome, TweenInfo.new(0.50, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(domeSize, domeSize, domeSize),
			Transparency = 1.0,
		})
		twDome:Play()
		ctx.registerTween(twDome)

		-- B. Ground Scorch Ring
		local scorchRing = Instance.new("Part")
		scorchRing.Name = "AceEntei_GroundScorchRing"
		scorchRing.Shape = Enum.PartType.Cylinder
		scorchRing.Size = Vector3.new(0.30, 2.5, 2.5)
		scorchRing.CFrame = CFrame.new(targetPos - Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
		scorchRing.Color = Color3.fromRGB(220, 50, 10) -- Deep Scorch Red
		scorchRing.Material = Enum.Material.Neon
		scorchRing.Transparency = 0.15
		scorchRing.Anchored = true
		scorchRing.CanCollide = false
		scorchRing.Parent = container
		ctx.registerInstance(scorchRing, 0.65)

		local ringSize = 22.0 * intensity
		local twRing = TweenService:Create(scorchRing, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.10, ringSize, ringSize),
			Transparency = 1.0,
		})
		twRing:Play()
		ctx.registerTween(twRing)

		-- C. Fiery Radial Shockwave Ring
		local shockwave = Instance.new("Part")
		shockwave.Name = "AceEntei_FieryShockwaveRing"
		shockwave.Shape = Enum.PartType.Cylinder
		shockwave.Size = Vector3.new(0.20, 2.0, 2.0)
		shockwave.CFrame = CFrame.new(targetPos - Vector3.new(0, 0.45, 0)) * CFrame.Angles(0, 0, math.rad(90))
		shockwave.Color = Color3.fromRGB(255, 200, 40)
		shockwave.Material = Enum.Material.Neon
		shockwave.Transparency = 0.20
		shockwave.Anchored = true
		shockwave.CanCollide = false
		shockwave.Parent = container
		ctx.registerInstance(shockwave, 0.55)

		local shockSize = 16.0 * intensity
		local twShock = TweenService:Create(shockwave, TweenInfo.new(0.48, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.08, shockSize, shockSize),
			Transparency = 1.0,
		})
		twShock:Play()
		ctx.registerTween(twShock)

		-- D. Fiery Energy Bolts Radiating Outward
		local boltCount = if ctx.quality == "Low" then 2 elseif ctx.quality == "Medium" then 4 else 6
		for i = 1, boltCount do
			local angle = i * (math.pi * 2 / boltCount)
			local dir = Vector3.new(math.cos(angle), 0.15, math.sin(angle))
			local len = 4.8 * intensity

			local bolt = Instance.new("Part")
			bolt.Name = string.format("AceEntei_EnergyBolt_%d", i)
			bolt.Shape = Enum.PartType.Block
			bolt.Size = Vector3.new(0.20, 0.20, len)
			bolt.CFrame = CFrame.lookAt(targetPos, targetPos + dir) * CFrame.new(0, 0, -len * 0.5)
			bolt.Color = if i % 2 == 1 then Color3.fromRGB(255, 140, 20) else Color3.fromRGB(255, 220, 50)
			bolt.Material = Enum.Material.Neon
			bolt.Transparency = 0.05
			bolt.Anchored = true
			bolt.CanCollide = false
			bolt.Parent = container
			ctx.registerInstance(bolt, 0.45)

			local twBolt = TweenService:Create(bolt, TweenInfo.new(0.38, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.06, 0.06, len * 1.5),
				Transparency = 1.0,
			})
			twBolt:Play()
			ctx.registerTween(twBolt)
		end

		-- E. PointLight Flash (Medium & High quality)
		if qConfig.allowPointLights then
			local lightPart = Instance.new("Part")
			lightPart.Name = "AceEntei_LightPart"
			lightPart.Transparency = 1.0
			lightPart.Anchored = true
			lightPart.CanCollide = false
			lightPart.Position = targetPos
			lightPart.Parent = container

			local light = Instance.new("PointLight")
			light.Name = "AceEntei_PointLight"
			light.Color = Color3.fromRGB(255, 140, 20)
			light.Range = 26 * intensity
			light.Brightness = 4.8
			light.Parent = lightPart

			ctx.registerInstance(lightPart, 0.28)
		end

	-- -------------------------------------------------------------------------
	-- CUE 8: SpecialIdleCue / FlameShoulderFlare (Hat Tip Flame Swirl & Shoulder Flare)
	-- -------------------------------------------------------------------------
	elseif cue == "SpecialIdleCue" or cue == "FlameShoulderFlare" then
		if not ctx.layerFlags.enableParticles then
			return
		end

		local head = sourceModel:FindFirstChild("Head") :: BasePart?
		local torso = sourceModel:FindFirstChild("Torso") :: BasePart? or root
		local hatPos = if head
			then head.Position + Vector3.new(0, 0.65, 0)
			else (root.Position + Vector3.new(0, 2.2, 0))

		-- A. Flame swirl arcs around hat brim
		for i = 1, 2 do
			local angle = (i * math.pi) + math.rad(45)
			local offset = Vector3.new(math.cos(angle) * 0.85, 0.05, math.sin(angle) * 0.85)

			local swirl = Instance.new("Part")
			swirl.Name = string.format("AceHat_FlameSwirl_%d", i)
			swirl.Shape = Enum.PartType.Block
			swirl.Size = Vector3.new(0.12, 0.12, 1.0 * intensity)
			swirl.CFrame = CFrame.lookAt(hatPos + offset, hatPos)
			swirl.Color = if i == 1 then Color3.fromRGB(255, 140, 20) else Color3.fromRGB(255, 215, 45)
			swirl.Material = Enum.Material.Neon
			swirl.Transparency = 0.20
			swirl.Anchored = true
			swirl.CanCollide = false
			swirl.Parent = container
			ctx.registerInstance(swirl, 0.32)

			local twSwirl = TweenService:Create(swirl, TweenInfo.new(0.30, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = CFrame.lookAt(hatPos + offset * 1.5, hatPos) * CFrame.new(0, 0.4, 0),
				Size = Vector3.new(0.04, 0.04, 1.4 * intensity),
				Transparency = 1.0,
			})
			twSwirl:Play()
			ctx.registerTween(twSwirl)
		end

		-- B. Shoulder flame flare (Medium & High quality)
		if ctx.quality ~= "Low" and qConfig.maxParts >= 4 then
			for i = 1, 2 do
				local flare = Instance.new("Part")
				flare.Name = string.format("AceShoulder_FlareWisp_%d", i)
				flare.Shape = Enum.PartType.Ball
				flare.Size = Vector3.new(0.40, 0.40, 0.40)
				flare.Position = torso.Position + Vector3.new((i - 1.5) * 1.4, 0.9, 0)
				flare.Color = if i == 1 then Color3.fromRGB(255, 110, 15) else Color3.fromRGB(255, 190, 30)
				flare.Material = Enum.Material.Neon
				flare.Transparency = 0.25
				flare.Anchored = true
				flare.CanCollide = false
				flare.Parent = container
				ctx.registerInstance(flare, 0.35)

				local twFlare = TweenService:Create(flare, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(1.2 * intensity, 1.2 * intensity, 1.2 * intensity),
					Position = flare.Position + Vector3.new(0, 0.8, 0),
					Transparency = 1.0,
				})
				twFlare:Play()
				ctx.registerTween(twFlare)
			end
		end
	end
end

-- =============================================================================
-- 3. CLEANUP ALL FOR MODEL
-- =============================================================================

function AceVFX.cleanupAllForModel(sourceModel: Model)
	AceVFX.stopPassiveAura(sourceModel)
	AceVFX.disableAllTrails(sourceModel)
	activeAuras[sourceModel] = nil
end

return table.freeze(AceVFX)
