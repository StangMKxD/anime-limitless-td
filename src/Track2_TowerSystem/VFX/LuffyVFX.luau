--!strict
-- src/Track2_TowerSystem/VFX/LuffyVFX.luau
-- Anime Limitless Tower Defense — Phase 5 Luffy Gear 5 Signature VFX Module (Task L-03)
-- Conforms strictly to VFXContract.CharacterVFXModule with heroId = "Luffy".
-- Author: Explorer M2-3 (Milestone M2: Luffy Character Pack)
--
-- Features:
-- 1. PassiveAura: Gear 5 Drums of Liberation white steam / cloud ribbon encircling torso and shoulders.
-- 2. SpawnDeploy: Divine sky lightning strike bolt + white cloud puff shockwave on pad.
-- 3. AttackWindup: Conqueror's Haki black-red lightning crackle arcing from fist/arm with tension coil.
-- 4. AttackRelease: Sonic vapor rings and stretching rubber snap lines along arm attack trajectory.
-- 5. AttackImpact: Manga shockwave ring + Conqueror's Haki black-red lightning burst at target point.
-- 6. UltimateCast: Colossal Bajrang Gun fist construct materializes overhead with swirling clouds and black lightning storm.
-- 7. UltimateImpact: Cataclysmic ground crater shockwave dome, immense shockwave ring & Haki explosion.
-- 8. SpecialIdleCue / NikaLaughPuff: Joyous cartoon laughing cloud puffs emitting from head.
--
-- Strict Resource Ledger Compliance:
-- - 100% of created instances registered via ctx.registerInstance(inst, ttlSeconds).
-- - 100% of created tweens registered via ctx.registerTween(tw).
-- - Guaranteed zero-leak balance across single and concurrent models upon cleanupAllForModel.
-- - Preset scaling: strictly adheres to Low (max 8 parts), Medium (max 16 parts), High (max 30 parts).
-- - Layer flag toggles respected: enableAura, enableImpactEffect, enableTrailOrBeam, enableParticles.
-- - Decoupled from combat: zero damage calculation, zero enemy health mutation, pcall protected.

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local VFXContract = (function()
	local rep = game:GetService("ReplicatedStorage")
	local shared = rep:FindFirstChild("Shared")
	if shared and shared:FindFirstChild("VFXContract") then
		return require(shared:FindFirstChild("VFXContract") :: any) :: any
	end
	-- Fallback for test runners requiring relative path
	local ok, mod = pcall(require, "../../../Shared/VFXContract")
	if ok then return mod end
	local ok2, mod2 = pcall(require, "../../Shared/VFXContract")
	if ok2 then return mod2 end
	error("[LuffyVFX] Could not locate VFXContract module")
end)()

local LuffyVFX: VFXContract.CharacterVFXModule = {
	heroId = "Luffy",
	maxConcurrentVFXInstances = 25,
	startPassiveAura = function(ctx: VFXContract.VFXExecutionContext) end,
	stopPassiveAura = function(sourceModel: Model) end,
	triggerCue = function(ctx: VFXContract.VFXExecutionContext) end,
	cleanupAllForModel = function(sourceModel: Model) end,
}

-- Per-model active passive aura tracking
local activeAuras: { [Model]: { [Instance]: boolean } } = {}

-- =============================================================================
-- 1. PASSIVE AURA: GEAR 5 WHITE STEAM / CLOUD RIBBON
-- =============================================================================

function LuffyVFX.startPassiveAura(ctx: VFXContract.VFXExecutionContext)
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

	-- Find torso or anchor directly to rootPart
	local torso = sourceModel:FindFirstChild("Torso") :: BasePart? or root

	-- 1. Primary Cloud Ribbon Torus (White steam circling waist/chest)
	local cloudRibbon = Instance.new("Part")
	cloudRibbon.Name = "LuffyGear5_CloudRibbon"
	cloudRibbon.Shape = Enum.PartType.Cylinder
	cloudRibbon.Size = Vector3.new(0.25, 4.2 * ctx.intensity, 4.2 * ctx.intensity)
	cloudRibbon.CFrame = torso.CFrame * CFrame.new(0, 0.3, 0) * CFrame.Angles(math.rad(15), 0, math.rad(90))
	cloudRibbon.Color = Color3.fromRGB(250, 250, 255)
	cloudRibbon.Material = Enum.Material.SmoothPlastic
	cloudRibbon.Transparency = 0.65
	cloudRibbon.Anchored = false
	cloudRibbon.CanCollide = false
	cloudRibbon.CanTouch = false
	cloudRibbon.CanQuery = false
	cloudRibbon.Massless = true
	cloudRibbon.Parent = container

	local weld1 = Instance.new("WeldConstraint")
	weld1.Part0 = torso
	weld1.Part1 = cloudRibbon
	weld1.Parent = cloudRibbon

	auraSet[cloudRibbon] = true
	ctx.registerInstance(cloudRibbon, nil)

	-- 2. Secondary Shoulder Halo Ribbon (Medium & High quality)
	if ctx.quality ~= "Low" and qConfig.maxParts >= 2 then
		local shoulderRibbon = Instance.new("Part")
		shoulderRibbon.Name = "LuffyGear5_ShoulderRibbon"
		shoulderRibbon.Shape = Enum.PartType.Cylinder
		shoulderRibbon.Size = Vector3.new(0.20, 3.6 * ctx.intensity, 3.6 * ctx.intensity)
		shoulderRibbon.CFrame = torso.CFrame * CFrame.new(0, 1.1, 0.1) * CFrame.Angles(math.rad(-15), math.rad(30), math.rad(90))
		shoulderRibbon.Color = Color3.fromRGB(245, 245, 255)
		shoulderRibbon.Material = Enum.Material.Neon
		shoulderRibbon.Transparency = 0.70
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

	-- 3. Third Floating Scarf Puff (High quality)
	if ctx.quality == "High" and qConfig.maxParts >= 3 then
		local cloudPuff = Instance.new("Part")
		cloudPuff.Name = "LuffyGear5_BackCloudPuff"
		cloudPuff.Shape = Enum.PartType.Ball
		cloudPuff.Size = Vector3.new(0.9, 0.9, 0.9)
		cloudPuff.CFrame = torso.CFrame * CFrame.new(0, 1.4, -0.8)
		cloudPuff.Color = Color3.fromRGB(255, 255, 255)
		cloudPuff.Material = Enum.Material.SmoothPlastic
		cloudPuff.Transparency = 0.55
		cloudPuff.Anchored = false
		cloudPuff.CanCollide = false
		cloudPuff.CanTouch = false
		cloudPuff.CanQuery = false
		cloudPuff.Massless = true
		cloudPuff.Parent = container

		local weld3 = Instance.new("WeldConstraint")
		weld3.Part0 = torso
		weld3.Part1 = cloudPuff
		weld3.Parent = cloudPuff

		auraSet[cloudPuff] = true
		ctx.registerInstance(cloudPuff, nil)
	end

	-- Cleanup delegate registration
	ctx.registerCleanupCallback(function()
		LuffyVFX.stopPassiveAura(sourceModel)
	end)
end

function LuffyVFX.stopPassiveAura(sourceModel: Model)
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
-- 2. SIGNATURE CUE DISPATCH: GEAR 5 VISUAL EFFECTS
-- =============================================================================

function LuffyVFX.triggerCue(ctx: VFXContract.VFXExecutionContext)
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
		LuffyVFX.startPassiveAura(ctx)

	-- -------------------------------------------------------------------------
	-- CUE 2: SpawnDeploy (Divine Sky Lightning Strike + White Cloud Puff Shockwave)
	-- -------------------------------------------------------------------------
	elseif cue == "SpawnDeploy" then
		if not ctx.layerFlags.enableImpactEffect then
			return
		end

		-- A. Divine Sky Lightning Strike Bolt (Medium & High)
		if ctx.quality ~= "Low" and qConfig.maxParts >= 2 then
			local lightning = Instance.new("Part")
			lightning.Name = "LuffySpawn_LightningBolt"
			lightning.Shape = Enum.PartType.Cylinder
			lightning.Size = Vector3.new(0.35, 24.0, 0.35)
			lightning.CFrame = CFrame.new(root.Position + Vector3.new(0, 12, 0)) * CFrame.Angles(0, 0, math.rad(90))
			lightning.Color = Color3.fromRGB(255, 255, 230)
			lightning.Material = Enum.Material.Neon
			lightning.Transparency = 0.05
			lightning.Anchored = true
			lightning.CanCollide = false
			lightning.Parent = container
			ctx.registerInstance(lightning, 0.20)

			local twBolt = TweenService:Create(lightning, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1.0,
				Size = Vector3.new(0.05, 24.0, 0.05),
			})
			twBolt:Play()
			ctx.registerTween(twBolt)
		end

		-- B. White Cloud Puff Shockwave expanding on pad
		local cloudShockwave = Instance.new("Part")
		cloudShockwave.Name = "LuffySpawn_CloudShockwave"
		cloudShockwave.Shape = Enum.PartType.Cylinder
		cloudShockwave.Size = Vector3.new(0.25, 1.5, 1.5)
		cloudShockwave.CFrame = CFrame.new(root.Position - Vector3.new(0, 1.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
		cloudShockwave.Color = Color3.fromRGB(250, 250, 255)
		cloudShockwave.Material = Enum.Material.SmoothPlastic
		cloudShockwave.Transparency = 0.20
		cloudShockwave.Anchored = true
		cloudShockwave.CanCollide = false
		cloudShockwave.Parent = container
		ctx.registerInstance(cloudShockwave, 0.45)

		local maxRadius = 9.0 * intensity
		local twCloud = TweenService:Create(cloudShockwave, TweenInfo.new(0.40, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.10, maxRadius, maxRadius),
			Transparency = 1.0,
		})
		twCloud:Play()
		ctx.registerTween(twCloud)

		-- C. Secondary outer ring (High quality)
		if ctx.quality == "High" and qConfig.maxParts >= 4 then
			local outerRing = Instance.new("Part")
			outerRing.Name = "LuffySpawn_OuterRing"
			outerRing.Shape = Enum.PartType.Cylinder
			outerRing.Size = Vector3.new(0.15, 2.0, 2.0)
			outerRing.CFrame = CFrame.new(root.Position - Vector3.new(0, 1.45, 0)) * CFrame.Angles(0, 0, math.rad(90))
			outerRing.Color = Color3.fromRGB(240, 245, 255)
			outerRing.Material = Enum.Material.Neon
			outerRing.Transparency = 0.40
			outerRing.Anchored = true
			outerRing.CanCollide = false
			outerRing.Parent = container
			ctx.registerInstance(outerRing, 0.50)

			local twOuter = TweenService:Create(outerRing, TweenInfo.new(0.48, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.05, 13.0 * intensity, 13.0 * intensity),
				Transparency = 1.0,
			})
			twOuter:Play()
			ctx.registerTween(twOuter)
		end

	-- -------------------------------------------------------------------------
	-- CUE 3: AttackWindup (Conqueror's Haki Black-Red Lightning Crackle)
	-- -------------------------------------------------------------------------
	elseif cue == "AttackWindup" then
		if not ctx.layerFlags.enableAura and not ctx.layerFlags.enableParticles then
			return
		end

		local armLimb = sourceModel:FindFirstChild("RightArm") :: BasePart?
		local fistPos = if armLimb
			then armLimb.Position + armLimb.CFrame.LookVector * -0.6
			else (root.Position + root.CFrame.RightVector * 1.5 + root.CFrame.LookVector * -0.5 + Vector3.new(0, 0.4, 0))

		local arcCount = 1
		if ctx.quality == "Medium" then
			arcCount = 2
		elseif ctx.quality == "High" then
			arcCount = 3
		end

		for i = 1, arcCount do
			local angle = (i * (math.pi * 2 / arcCount)) + math.rad(25)
			local offset = Vector3.new(math.cos(angle) * 0.75, math.sin(angle) * 0.75, 0.2)

			local arc = Instance.new("Part")
			arc.Name = string.format("LuffyWindup_HakiArc_%d", i)
			arc.Shape = Enum.PartType.Block
			arc.Size = Vector3.new(0.14, 0.14, 1.1 * intensity)
			arc.CFrame = CFrame.lookAt(fistPos + offset, fistPos)
			-- Alternating Crimson Red and Jet Black
			arc.Color = if i % 2 == 1 then Color3.fromRGB(220, 20, 45) else Color3.fromRGB(20, 10, 15)
			arc.Material = Enum.Material.Neon
			arc.Transparency = 0.10
			arc.Anchored = true
			arc.CanCollide = false
			arc.Parent = container
			ctx.registerInstance(arc, 0.16)

			local twArc = TweenService:Create(arc, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				CFrame = CFrame.lookAt(fistPos, fistPos + root.CFrame.LookVector),
				Size = Vector3.new(0.04, 0.04, 0.2),
				Transparency = 0.90,
			})
			twArc:Play()
			ctx.registerTween(twArc)
		end

	-- -------------------------------------------------------------------------
	-- CUE 4: AttackRelease (Rubber Sonic Rings along Stretching Arm)
	-- -------------------------------------------------------------------------
	elseif cue == "AttackRelease" then
		if not ctx.layerFlags.enableTrailOrBeam then
			return
		end

		local originPos = root.Position + root.CFrame.RightVector * 1.2 + Vector3.new(0, 0.5, 0)
		local ray = targetPos - originPos
		local dist = ray.Magnitude
		local dir = if dist > 0.001 then ray.Unit else root.CFrame.LookVector

		local ringCount = 1
		if ctx.quality == "Medium" then
			ringCount = 2
		elseif ctx.quality == "High" then
			ringCount = 3
		end

		for i = 1, ringCount do
			local frac = i / (ringCount + 1)
			local ringPos = originPos + dir * (dist * frac)

			local ring = Instance.new("Part")
			ring.Name = string.format("LuffyRelease_SonicRing_%d", i)
			ring.Shape = Enum.PartType.Cylinder
			ring.Size = Vector3.new(0.18, 1.2, 1.2)
			ring.CFrame = CFrame.lookAt(ringPos, ringPos + dir) * CFrame.Angles(0, 0, math.rad(90))
			ring.Color = Color3.fromRGB(240, 248, 255)
			ring.Material = Enum.Material.Neon
			ring.Transparency = 0.30
			ring.Anchored = true
			ring.CanCollide = false
			ring.Parent = container
			ctx.registerInstance(ring, 0.15)

			local expandSize = 4.2 * intensity
			local twRing = TweenService:Create(ring, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.06, expandSize, expandSize),
				Transparency = 1.0,
			})
			twRing:Play()
			ctx.registerTween(twRing)
		end

	-- -------------------------------------------------------------------------
	-- CUE 5: AttackImpact (Manga Shockwave Ring + Conqueror's Haki Burst)
	-- -------------------------------------------------------------------------
	elseif cue == "AttackImpact" then
		if ctx.layerFlags.enableImpactEffect then
			-- A. Manga Shockwave Ring (Flat expanding white circle)
			local shockwave = Instance.new("Part")
			shockwave.Name = "LuffyImpact_MangaShockwave"
			shockwave.Shape = Enum.PartType.Cylinder
			shockwave.Size = Vector3.new(0.20, 1.2, 1.2)
			shockwave.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, 0, math.rad(90))
			shockwave.Color = Color3.fromRGB(255, 255, 255)
			shockwave.Material = Enum.Material.Neon
			shockwave.Transparency = 0.15
			shockwave.Anchored = true
			shockwave.CanCollide = false
			shockwave.Parent = container
			ctx.registerInstance(shockwave, 0.25)

			local targetSize = 6.8 * intensity
			local twShock = TweenService:Create(shockwave, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.06, targetSize, targetSize),
				Transparency = 1.0,
			})
			twShock:Play()
			ctx.registerTween(twShock)

			-- B. Conqueror's Haki Black-Red Lightning Burst
			local arcCount = 2
			if ctx.quality == "Medium" then
				arcCount = 3
			elseif ctx.quality == "High" then
				arcCount = 5
			end

			for i = 1, arcCount do
				local yaw = (i * (math.pi * 2 / arcCount)) + math.rad(15)
				local pitch = math.rad((i % 3 - 1) * 20)
				local dirVec = Vector3.new(math.cos(yaw) * math.cos(pitch), math.sin(pitch), math.sin(yaw) * math.cos(pitch))
				local arcLen = 2.4 * intensity

				local arc = Instance.new("Part")
				arc.Name = string.format("LuffyImpact_HakiLightning_%d", i)
				arc.Shape = Enum.PartType.Block
				arc.Size = Vector3.new(0.14, 0.14, arcLen)
				arc.CFrame = CFrame.lookAt(targetPos, targetPos + dirVec) * CFrame.new(0, 0, -arcLen * 0.5)
				arc.Color = if i % 2 == 1 then Color3.fromRGB(230, 20, 45) else Color3.fromRGB(15, 8, 15)
				arc.Material = Enum.Material.Neon
				arc.Transparency = 0.05
				arc.Anchored = true
				arc.CanCollide = false
				arc.Parent = container
				ctx.registerInstance(arc, 0.22)

				local twArc = TweenService:Create(arc, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(0.04, 0.04, arcLen * 1.6),
					Transparency = 1.0,
				})
				twArc:Play()
				ctx.registerTween(twArc)
			end
		end

		-- C. PointLight Flash (Medium & High quality)
		if ctx.layerFlags.enableImpactEffect and qConfig.allowPointLights then
			local lightPart = Instance.new("Part")
			lightPart.Name = "LuffyImpact_LightPart"
			lightPart.Transparency = 1.0
			lightPart.Anchored = true
			lightPart.CanCollide = false
			lightPart.Position = targetPos
			lightPart.Parent = container

			local light = Instance.new("PointLight")
			light.Name = "LuffyImpact_PointLight"
			light.Color = Color3.fromRGB(255, 60, 40)
			light.Range = 14 * intensity
			light.Brightness = 3.5
			light.Parent = lightPart

			ctx.registerInstance(lightPart, 0.12)
		end

	-- -------------------------------------------------------------------------
	-- CUE 6: UltimateCast (Bajrang Gun - Colossal Fist Construct Overhead)
	-- -------------------------------------------------------------------------
	elseif cue == "UltimateCast" then
		if not ctx.layerFlags.enableAura then
			return
		end

		local overheadPos = root.Position + Vector3.new(0, 12, 0)

		-- Colossal Fist Construct (Black Armament with Gear 5 Glow)
		local fist = Instance.new("Part")
		fist.Name = "LuffyBajrang_ColossalFist"
		fist.Shape = Enum.PartType.Ball
		fist.Size = Vector3.new(2.5, 2.5, 2.5)
		fist.Position = overheadPos
		fist.Color = Color3.fromRGB(35, 30, 40)
		fist.Material = Enum.Material.SmoothPlastic
		fist.Transparency = 0.30
		fist.Anchored = true
		fist.CanCollide = false
		fist.Parent = container
		ctx.registerInstance(fist, 0.65)

		local fistTargetSize = 8.5 * intensity
		local twFist = TweenService:Create(fist, TweenInfo.new(0.50, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(fistTargetSize, fistTargetSize, fistTargetSize),
			Transparency = 0.08,
		})
		twFist:Play()
		ctx.registerTween(twFist)

		-- Surrounding Black-Red Lightning Storm
		local arcCount = if ctx.quality == "Low" then 1 elseif ctx.quality == "Medium" then 2 else 4
		for i = 1, arcCount do
			local angle = (i * (math.pi * 2 / arcCount))
			local offset = Vector3.new(math.cos(angle) * 3.5, math.sin(angle) * 1.5, math.sin(angle) * 3.5)

			local arc = Instance.new("Part")
			arc.Name = string.format("LuffyBajrang_SkyLightning_%d", i)
			arc.Shape = Enum.PartType.Block
			arc.Size = Vector3.new(0.18, 0.18, 3.2 * intensity)
			arc.CFrame = CFrame.lookAt(overheadPos + offset, overheadPos)
			arc.Color = if i % 2 == 1 then Color3.fromRGB(235, 20, 50) else Color3.fromRGB(15, 8, 15)
			arc.Material = Enum.Material.Neon
			arc.Transparency = 0.10
			arc.Anchored = true
			arc.CanCollide = false
			arc.Parent = container
			ctx.registerInstance(arc, 0.50)

			local twArc = TweenService:Create(arc, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Transparency = 0.90,
			})
			twArc:Play()
			ctx.registerTween(twArc)
		end

	-- -------------------------------------------------------------------------
	-- CUE 7: UltimateImpact (Bajrang Gun Cataclysmic Slam & Crater Shockwave)
	-- -------------------------------------------------------------------------
	elseif cue == "UltimateImpact" then
		if not ctx.layerFlags.enableImpactEffect then
			return
		end

		-- A. Cataclysmic Crater Impact Dome
		local dome = Instance.new("Part")
		dome.Name = "LuffyBajrang_ImpactDome"
		dome.Shape = Enum.PartType.Ball
		dome.Size = Vector3.new(2.0, 2.0, 2.0)
		dome.Position = targetPos
		dome.Color = Color3.fromRGB(255, 45, 30)
		dome.Material = Enum.Material.Neon
		dome.Transparency = 0.10
		dome.Anchored = true
		dome.CanCollide = false
		dome.Parent = container
		ctx.registerInstance(dome, 0.55)

		local domeSize = 16.0 * intensity
		local twDome = TweenService:Create(dome, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(domeSize, domeSize, domeSize),
			Transparency = 1.0,
		})
		twDome:Play()
		ctx.registerTween(twDome)

		-- B. Immense Ground Shockwave Ring
		local groundRing = Instance.new("Part")
		groundRing.Name = "LuffyBajrang_GroundRing"
		groundRing.Shape = Enum.PartType.Cylinder
		groundRing.Size = Vector3.new(0.30, 2.0, 2.0)
		groundRing.CFrame = CFrame.new(targetPos - Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
		groundRing.Color = Color3.fromRGB(255, 255, 255)
		groundRing.Material = Enum.Material.Neon
		groundRing.Transparency = 0.15
		groundRing.Anchored = true
		groundRing.CanCollide = false
		groundRing.Parent = container
		ctx.registerInstance(groundRing, 0.60)

		local ringSize = 20.0 * intensity
		local twRing = TweenService:Create(groundRing, TweenInfo.new(0.50, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.10, ringSize, ringSize),
			Transparency = 1.0,
		})
		twRing:Play()
		ctx.registerTween(twRing)

		-- C. Cataclysmic Black-Red Lightning Arcs (Medium & High)
		local lightningCount = if ctx.quality == "Low" then 2 elseif ctx.quality == "Medium" then 4 else 6
		for i = 1, lightningCount do
			local angle = i * (math.pi * 2 / lightningCount)
			local dir = Vector3.new(math.cos(angle), 0.15, math.sin(angle))
			local len = 4.5 * intensity

			local bolt = Instance.new("Part")
			bolt.Name = string.format("LuffyBajrang_CraterBolt_%d", i)
			bolt.Shape = Enum.PartType.Block
			bolt.Size = Vector3.new(0.20, 0.20, len)
			bolt.CFrame = CFrame.lookAt(targetPos, targetPos + dir) * CFrame.new(0, 0, -len * 0.5)
			bolt.Color = if i % 2 == 1 then Color3.fromRGB(240, 20, 50) else Color3.fromRGB(15, 5, 15)
			bolt.Material = Enum.Material.Neon
			bolt.Transparency = 0.05
			bolt.Anchored = true
			bolt.CanCollide = false
			bolt.Parent = container
			ctx.registerInstance(bolt, 0.40)

			local twBolt = TweenService:Create(bolt, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.06, 0.06, len * 1.5),
				Transparency = 1.0,
			})
			twBolt:Play()
			ctx.registerTween(twBolt)
		end

		-- D. PointLight Flash
		if qConfig.allowPointLights then
			local lightPart = Instance.new("Part")
			lightPart.Name = "LuffyBajrang_LightPart"
			lightPart.Transparency = 1.0
			lightPart.Anchored = true
			lightPart.CanCollide = false
			lightPart.Position = targetPos
			lightPart.Parent = container

			local light = Instance.new("PointLight")
			light.Name = "LuffyBajrang_PointLight"
			light.Color = Color3.fromRGB(255, 80, 50)
			light.Range = 24 * intensity
			light.Brightness = 4.5
			light.Parent = lightPart

			ctx.registerInstance(lightPart, 0.25)
		end

	-- -------------------------------------------------------------------------
	-- CUE 8: SpecialIdleCue / NikaLaughPuff (Joyous Cartoon Laughing Cloud Puffs)
	-- -------------------------------------------------------------------------
	elseif cue == "SpecialIdleCue" or cue == "NikaLaughPuff" then
		if not ctx.layerFlags.enableParticles then
			return
		end

		local headPos = root.Position + Vector3.new(0, 2.2, 0.4)
		for i = 1, 2 do
			local puff = Instance.new("Part")
			puff.Name = string.format("LuffyLaugh_Puff_%d", i)
			puff.Shape = Enum.PartType.Ball
			puff.Size = Vector3.new(0.45, 0.45, 0.45)
			puff.Position = headPos + Vector3.new((i - 1.5) * 0.4, 0, 0)
			puff.Color = Color3.fromRGB(255, 255, 255)
			puff.Material = Enum.Material.SmoothPlastic
			puff.Transparency = 0.25
			puff.Anchored = true
			puff.CanCollide = false
			puff.Parent = container
			ctx.registerInstance(puff, 0.35)

			local twPuff = TweenService:Create(puff, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(1.4 * intensity, 1.4 * intensity, 1.4 * intensity),
				Position = puff.Position + Vector3.new(0, 1.0, 0.3),
				Transparency = 1.0,
			})
			twPuff:Play()
			ctx.registerTween(twPuff)
		end
	end
end

-- =============================================================================
-- 3. CLEANUP ALL FOR MODEL
-- =============================================================================

function LuffyVFX.cleanupAllForModel(sourceModel: Model)
	LuffyVFX.stopPassiveAura(sourceModel)
	activeAuras[sourceModel] = nil
end

return table.freeze(LuffyVFX)
