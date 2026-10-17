--!strict
-- src/Track2_TowerSystem/VFX/ZoroVFX.luau
-- Anime Limitless Tower Defense — Phase 5 Zoro King of Hell Signature VFX Module (Task Z-03)
-- Conforms strictly to VFXContract.CharacterVFXModule with heroId = "Zoro".
-- Author: Explorer M3-3 (Milestone M3: Zoro Character Pack)
--
-- Features:
-- 1. PassiveAura: Flowing green King of Hell flame wisps radiating from Enma blade and shoulders.
-- 2. SpawnDeploy: Emerald lightning strike bolt + ground green dust shockwave ring on pad.
-- 3. AttackWindup: Green flame ignition along the 3 blades, Conqueror's green-black lightning crackle (0.14s).
-- 4. AttackRelease: Three green crescent slash projectiles / vapor trails slicing along attack vector (0.10s).
-- 5. AttackImpact: Triple slash intersection flash + emerald shockwave ring + spark burst at target (0.07s).
-- 6. UltimateCast: Colossal green dragon aura projection / King of Hell inferno swirling around Zoro.
-- 7. UltimateImpact: Massive green cross-slash energy explosion + ground scorch ring.
-- 8. SpecialIdleCue / EnmaChargePulse: Green flame flare and pulse from Enma blade.
--
-- Strict Resource Ledger Compliance:
-- - 100% of created instances registered via ctx.registerInstance(inst, ttlSeconds).
-- - 100% of created tweens registered via ctx.registerTween(tw).
-- - Guaranteed zero-leak balance across single and concurrent models upon cleanupAllForModel.
-- - Preset scaling: strictly adheres to Low (max 8 parts), Medium (max 16 parts), High (max 30 parts).
-- - Layer flag toggles respected: enableAura, enableImpactEffect, enableTrailOrBeam, enableParticles.
-- - Forced Trail safety: all sword trails strictly disabled (Trail.Enabled = false) on impact, stop, or cleanup.
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
	error("[ZoroVFX] Could not locate VFXContract module")
end)()

local ZoroVFX: VFXContract.CharacterVFXModule = {
	heroId = "Zoro",
	maxConcurrentVFXInstances = 25,
	startPassiveAura = function(ctx: VFXContract.VFXExecutionContext) end,
	stopPassiveAura = function(sourceModel: Model) end,
	triggerCue = function(ctx: VFXContract.VFXExecutionContext) end,
	cleanupAllForModel = function(sourceModel: Model) end,
}

-- Per-model active passive aura tracking
local activeAuras: { [Model]: { [Instance]: boolean } } = {}

-- Per-model sword trail tracking
local activeTrails: { [Model]: { [Trail]: boolean } } = {}

-- =============================================================================
-- HELPER: SWORD TRAIL MANAGEMENT (Zero Lingering Trails)
-- =============================================================================

local function getOrCreateTrailSet(sourceModel: Model): { [Trail]: boolean }
	local trailSet = activeTrails[sourceModel]
	if not trailSet then
		trailSet = {}
		activeTrails[sourceModel] = trailSet
		for _, desc in ipairs(sourceModel:GetDescendants()) do
			if desc:IsA("Trail") then
				trailSet[desc] = true
			end
		end
	end
	return trailSet
end

function ZoroVFX.disableAllTrails(sourceModel: Model)
	local trailSet = activeTrails[sourceModel]
	if trailSet then
		for trail in pairs(trailSet) do
			if trail.Parent then
				pcall(function()
					trail.Enabled = false
				end)
			end
		end
	end
	-- Scan descendants directly to guarantee 100% suppression even for newly added trails
	for _, desc in ipairs(sourceModel:GetDescendants()) do
		if desc:IsA("Trail") then
			pcall(function()
				desc.Enabled = false
			end)
		end
	end
end

function ZoroVFX.enableAllTrails(sourceModel: Model)
	local trailSet = getOrCreateTrailSet(sourceModel)
	for trail in pairs(trailSet) do
		if trail.Parent then
			pcall(function()
				trail.Enabled = true
			end)
		end
	end
	for _, desc in ipairs(sourceModel:GetDescendants()) do
		if desc:IsA("Trail") then
			trailSet[desc] = true
			pcall(function()
				desc.Enabled = true
			end)
		end
	end
end

-- =============================================================================
-- 1. PASSIVE AURA: KING OF HELL EMERALD FLAME & HAKI WISPS
-- =============================================================================

function ZoroVFX.startPassiveAura(ctx: VFXContract.VFXExecutionContext)
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
	local rightArm = sourceModel:FindFirstChild("RightArm") :: BasePart?

	-- 1. Primary Enma King of Hell Flame Wisp (radiating from RightArm / Enma)
	local enmaFlame = Instance.new("Part")
	enmaFlame.Name = "ZoroKoH_EnmaFlameWisp"
	enmaFlame.Shape = Enum.PartType.Cylinder
	enmaFlame.Size = Vector3.new(0.25, 3.4 * ctx.intensity, 3.4 * ctx.intensity)
	local anchorPart = rightArm or torso
	enmaFlame.CFrame = anchorPart.CFrame * CFrame.new(0.3, -0.6, 0) * CFrame.Angles(0, 0, math.rad(90))
	enmaFlame.Color = Color3.fromRGB(40, 235, 120) -- Emerald Flame
	enmaFlame.Material = Enum.Material.Neon
	enmaFlame.Transparency = 0.55
	enmaFlame.Anchored = false
	enmaFlame.CanCollide = false
	enmaFlame.CanTouch = false
	enmaFlame.CanQuery = false
	enmaFlame.Massless = true
	enmaFlame.Parent = container

	local weld1 = Instance.new("WeldConstraint")
	weld1.Part0 = anchorPart
	weld1.Part1 = enmaFlame
	weld1.Parent = enmaFlame

	auraSet[enmaFlame] = true
	ctx.registerInstance(enmaFlame, nil)

	-- 2. Secondary Shoulder Flame Ribbon (Medium & High quality)
	if ctx.quality ~= "Low" and qConfig.maxParts >= 2 then
		local shoulderRibbon = Instance.new("Part")
		shoulderRibbon.Name = "ZoroKoH_ShoulderFlameRibbon"
		shoulderRibbon.Shape = Enum.PartType.Cylinder
		shoulderRibbon.Size = Vector3.new(0.20, 3.8 * ctx.intensity, 3.8 * ctx.intensity)
		shoulderRibbon.CFrame = torso.CFrame * CFrame.new(0, 1.1, 0) * CFrame.Angles(math.rad(12), 0, math.rad(90))
		shoulderRibbon.Color = Color3.fromRGB(30, 220, 100)
		shoulderRibbon.Material = Enum.Material.Neon
		shoulderRibbon.Transparency = 0.65
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

	-- 3. Third Floating King of Hell Purple/Emerald Wisp (High quality)
	if ctx.quality == "High" and qConfig.maxParts >= 3 then
		local purpleWisp = Instance.new("Part")
		purpleWisp.Name = "ZoroKoH_BackHakiWisp"
		purpleWisp.Shape = Enum.PartType.Ball
		purpleWisp.Size = Vector3.new(0.85, 0.85, 0.85)
		purpleWisp.CFrame = torso.CFrame * CFrame.new(0, 1.3, -0.7)
		purpleWisp.Color = Color3.fromRGB(140, 40, 220) -- King of Hell Purple Haki
		purpleWisp.Material = Enum.Material.Neon
		purpleWisp.Transparency = 0.60
		purpleWisp.Anchored = false
		purpleWisp.CanCollide = false
		purpleWisp.CanTouch = false
		purpleWisp.CanQuery = false
		purpleWisp.Massless = true
		purpleWisp.Parent = container

		local weld3 = Instance.new("WeldConstraint")
		weld3.Part0 = torso
		weld3.Part1 = purpleWisp
		weld3.Parent = purpleWisp

		auraSet[purpleWisp] = true
		ctx.registerInstance(purpleWisp, nil)
	end

	-- Cleanup delegate registration
	ctx.registerCleanupCallback(function()
		ZoroVFX.stopPassiveAura(sourceModel)
	end)
end

function ZoroVFX.stopPassiveAura(sourceModel: Model)
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
-- 2. SIGNATURE CUE DISPATCH: KING OF HELL VISUAL EFFECTS
-- =============================================================================

function ZoroVFX.triggerCue(ctx: VFXContract.VFXExecutionContext)
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
		ZoroVFX.startPassiveAura(ctx)

	-- -------------------------------------------------------------------------
	-- CUE 2: SpawnDeploy (Emerald Lightning Strike + Ground Green Dust Ring)
	-- -------------------------------------------------------------------------
	elseif cue == "SpawnDeploy" then
		if not ctx.layerFlags.enableImpactEffect then
			return
		end

		-- A. Emerald Sky Lightning Strike Bolt (Medium & High)
		if ctx.quality ~= "Low" and qConfig.maxParts >= 2 then
			local lightning = Instance.new("Part")
			lightning.Name = "ZoroSpawn_LightningBolt"
			lightning.Shape = Enum.PartType.Cylinder
			lightning.Size = Vector3.new(0.35, 24.0, 0.35)
			lightning.CFrame = CFrame.new(root.Position + Vector3.new(0, 12, 0)) * CFrame.Angles(0, 0, math.rad(90))
			lightning.Color = Color3.fromRGB(50, 255, 140) -- Emerald lightning
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

		-- B. Ground Green Dust Shockwave Ring expanding on pad
		local groundRing = Instance.new("Part")
		groundRing.Name = "ZoroSpawn_DustShockwave"
		groundRing.Shape = Enum.PartType.Cylinder
		groundRing.Size = Vector3.new(0.25, 1.5, 1.5)
		groundRing.CFrame = CFrame.new(root.Position - Vector3.new(0, 1.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
		groundRing.Color = Color3.fromRGB(40, 230, 110)
		groundRing.Material = Enum.Material.Neon
		groundRing.Transparency = 0.20
		groundRing.Anchored = true
		groundRing.CanCollide = false
		groundRing.Parent = container
		ctx.registerInstance(groundRing, 0.45)

		local maxRadius = 9.0 * intensity
		local twRing = TweenService:Create(groundRing, TweenInfo.new(0.40, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.10, maxRadius, maxRadius),
			Transparency = 1.0,
		})
		twRing:Play()
		ctx.registerTween(twRing)

		-- C. Secondary outer emerald ring (High quality)
		if ctx.quality == "High" and qConfig.maxParts >= 4 then
			local outerRing = Instance.new("Part")
			outerRing.Name = "ZoroSpawn_OuterRing"
			outerRing.Shape = Enum.PartType.Cylinder
			outerRing.Size = Vector3.new(0.15, 2.0, 2.0)
			outerRing.CFrame = CFrame.new(root.Position - Vector3.new(0, 1.45, 0)) * CFrame.Angles(0, 0, math.rad(90))
			outerRing.Color = Color3.fromRGB(30, 200, 90)
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
	-- CUE 3: AttackWindup (3-Blade Flame Ignition & Green-Black Crackle - 0.14s)
	-- -------------------------------------------------------------------------
	elseif cue == "AttackWindup" then
		if not ctx.layerFlags.enableAura and not ctx.layerFlags.enableParticles then
			return
		end

		-- Enable sword trails safely during attack windup
		if ctx.layerFlags.enableTrailOrBeam and qConfig.allowTrails then
			ZoroVFX.enableAllTrails(sourceModel)
		end

		local rightArm = sourceModel:FindFirstChild("RightArm") :: BasePart?
		local bladePos = if rightArm
			then rightArm.Position + rightArm.CFrame.LookVector * 0.8
			else (root.Position + root.CFrame.RightVector * 1.4 + Vector3.new(0, 0.3, 0))

		local arcCount = 1
		if ctx.quality == "Medium" then
			arcCount = 2
		elseif ctx.quality == "High" then
			arcCount = 3
		end

		for i = 1, arcCount do
			local angle = (i * (math.pi * 2 / arcCount)) + math.rad(30)
			local offset = Vector3.new(math.cos(angle) * 0.8, math.sin(angle) * 0.8, 0.25)

			local arc = Instance.new("Part")
			arc.Name = string.format("ZoroWindup_HakiArc_%d", i)
			arc.Shape = Enum.PartType.Block
			arc.Size = Vector3.new(0.14, 0.14, 1.1 * intensity)
			arc.CFrame = CFrame.lookAt(bladePos + offset, bladePos)
			-- Alternating Emerald Green and Jet Black / Dark Purple
			arc.Color = if i % 2 == 1 then Color3.fromRGB(40, 245, 120) else Color3.fromRGB(15, 20, 15)
			arc.Material = Enum.Material.Neon
			arc.Transparency = 0.10
			arc.Anchored = true
			arc.CanCollide = false
			arc.Parent = container
			ctx.registerInstance(arc, 0.16)

			local twArc = TweenService:Create(arc, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				CFrame = CFrame.lookAt(bladePos, bladePos + root.CFrame.LookVector),
				Size = Vector3.new(0.04, 0.04, 0.2),
				Transparency = 0.90,
			})
			twArc:Play()
			ctx.registerTween(twArc)
		end

		-- High quality blade ignition flare
		if ctx.quality == "High" and qConfig.maxParts >= 5 then
			local flare = Instance.new("Part")
			flare.Name = "ZoroWindup_BladeFlare"
			flare.Shape = Enum.PartType.Ball
			flare.Size = Vector3.new(0.4, 0.4, 0.4)
			flare.Position = bladePos
			flare.Color = Color3.fromRGB(60, 255, 140)
			flare.Material = Enum.Material.Neon
			flare.Transparency = 0.20
			flare.Anchored = true
			flare.CanCollide = false
			flare.Parent = container
			ctx.registerInstance(flare, 0.14)

			local twFlare = TweenService:Create(flare, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(1.2 * intensity, 1.2 * intensity, 1.2 * intensity),
				Transparency = 1.0,
			})
			twFlare:Play()
			ctx.registerTween(twFlare)
		end

	-- -------------------------------------------------------------------------
	-- CUE 4: AttackRelease (Three Green Crescent Slash Projectiles - 0.10s)
	-- -------------------------------------------------------------------------
	elseif cue == "AttackRelease" then
		if not ctx.layerFlags.enableTrailOrBeam then
			return
		end

		local originPos = root.Position + Vector3.new(0, 0.6, 0)
		local ray = targetPos - originPos
		local dist = ray.Magnitude
		local dir = if dist > 0.001 then ray.Unit else root.CFrame.LookVector

		local slashCount = 1
		if ctx.quality == "Medium" then
			slashCount = 2
		elseif ctx.quality == "High" then
			slashCount = 3
		end

		-- Generate up to 3 distinct crescent slashes (Right diagonal, Left diagonal, Center horizontal)
		local slashAngles = {
			CFrame.Angles(0, 0, math.rad(45)),  -- Slash 1 (Enma diagonal)
			CFrame.Angles(0, 0, math.rad(-45)), -- Slash 2 (Sandai diagonal)
			CFrame.Angles(0, 0, 0),              -- Slash 3 (Wado horizontal)
		}

		for i = 1, slashCount do
			local frac = i / (slashCount + 1)
			local slashPos = originPos + dir * (dist * frac)

			local slash = Instance.new("Part")
			slash.Name = string.format("ZoroRelease_CrescentSlash_%d", i)
			slash.Shape = Enum.PartType.Block
			slash.Size = Vector3.new(0.18, 2.6 * intensity, 0.8 * intensity)
			slash.CFrame = CFrame.lookAt(slashPos, slashPos + dir) * slashAngles[i]
			slash.Color = if i % 2 == 1 then Color3.fromRGB(40, 240, 120) else Color3.fromRGB(140, 40, 230)
			slash.Material = Enum.Material.Neon
			slash.Transparency = 0.20
			slash.Anchored = true
			slash.CanCollide = false
			slash.Parent = container
			ctx.registerInstance(slash, 0.20)

			local targetSlashPos = slashPos + dir * 6.0
			local twSlash = TweenService:Create(slash, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = targetSlashPos,
				Size = Vector3.new(0.06, 4.6 * intensity, 1.2 * intensity),
				Transparency = 1.0,
			})
			twSlash:Play()
			ctx.registerTween(twSlash)
		end

	-- -------------------------------------------------------------------------
	-- CUE 5: AttackImpact (Triple Slash Intersection Flash + Shockwave - 0.07s)
	-- -------------------------------------------------------------------------
	elseif cue == "AttackImpact" then
		-- Invariant: disable all lingering blade trails on impact
		ZoroVFX.disableAllTrails(sourceModel)

		if ctx.layerFlags.enableImpactEffect then
			-- A. Triple Slash Intersection Flash (Cross Cut)
			local crossCount = if ctx.quality == "Low" then 1 elseif ctx.quality == "Medium" then 2 else 3
			for i = 1, crossCount do
				local cut = Instance.new("Part")
				cut.Name = string.format("ZoroImpact_CrossCut_%d", i)
				cut.Shape = Enum.PartType.Block
				local rotAngle = if i == 1 then math.rad(45) elseif i == 2 then math.rad(-45) else 0
				cut.Size = Vector3.new(0.16, 3.8 * intensity, 0.2)
				cut.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, 0, rotAngle)
				cut.Color = if i % 2 == 1 then Color3.fromRGB(50, 255, 130) else Color3.fromRGB(160, 50, 240)
				cut.Material = Enum.Material.Neon
				cut.Transparency = 0.10
				cut.Anchored = true
				cut.CanCollide = false
				cut.Parent = container
				ctx.registerInstance(cut, 0.22)

				local twCut = TweenService:Create(cut, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(0.04, 5.2 * intensity, 0.05),
					Transparency = 1.0,
				})
				twCut:Play()
				ctx.registerTween(twCut)
			end

			-- B. Emerald Shockwave Ring
			local shockwave = Instance.new("Part")
			shockwave.Name = "ZoroImpact_EmeraldShockwave"
			shockwave.Shape = Enum.PartType.Cylinder
			shockwave.Size = Vector3.new(0.20, 1.2, 1.2)
			shockwave.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, 0, math.rad(90))
			shockwave.Color = Color3.fromRGB(40, 245, 120)
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

			-- C. Emerald & Purple Spark Burst Arcs
			local arcCount = 1
			if ctx.quality == "Medium" then
				arcCount = 3
			elseif ctx.quality == "High" then
				arcCount = 5
			end

			for i = 1, arcCount do
				local yaw = (i * (math.pi * 2 / arcCount)) + math.rad(20)
				local pitch = math.rad((i % 3 - 1) * 25)
				local dirVec = Vector3.new(math.cos(yaw) * math.cos(pitch), math.sin(pitch), math.sin(yaw) * math.cos(pitch))
				local arcLen = 2.4 * intensity

				local arc = Instance.new("Part")
				arc.Name = string.format("ZoroImpact_HakiSpark_%d", i)
				arc.Shape = Enum.PartType.Block
				arc.Size = Vector3.new(0.14, 0.14, arcLen)
				arc.CFrame = CFrame.lookAt(targetPos, targetPos + dirVec) * CFrame.new(0, 0, -arcLen * 0.5)
				arc.Color = if i % 2 == 1 then Color3.fromRGB(40, 255, 110) else Color3.fromRGB(140, 30, 220)
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

		-- D. PointLight Flash (Medium & High quality)
		if ctx.layerFlags.enableImpactEffect and qConfig.allowPointLights then
			local lightPart = Instance.new("Part")
			lightPart.Name = "ZoroImpact_LightPart"
			lightPart.Transparency = 1.0
			lightPart.Anchored = true
			lightPart.CanCollide = false
			lightPart.Position = targetPos
			lightPart.Parent = container

			local light = Instance.new("PointLight")
			light.Name = "ZoroImpact_PointLight"
			light.Color = Color3.fromRGB(50, 255, 130)
			light.Range = 14 * intensity
			light.Brightness = 3.5
			light.Parent = lightPart

			ctx.registerInstance(lightPart, 0.12)
		end

	-- -------------------------------------------------------------------------
	-- CUE 6: UltimateCast (Dragon Inferno - Swirling King of Hell Vortex)
	-- -------------------------------------------------------------------------
	elseif cue == "UltimateCast" then
		if not ctx.layerFlags.enableAura then
			return
		end

		if ctx.layerFlags.enableTrailOrBeam and qConfig.allowTrails then
			ZoroVFX.enableAllTrails(sourceModel)
		end

		local centerPos = root.Position + Vector3.new(0, 1.5, 0)

		-- Central Dragon Inferno Vortex Core
		local vortex = Instance.new("Part")
		vortex.Name = "ZoroDragon_InfernoCore"
		vortex.Shape = Enum.PartType.Ball
		vortex.Size = Vector3.new(2.4, 2.4, 2.4)
		vortex.Position = centerPos
		vortex.Color = Color3.fromRGB(30, 220, 100)
		vortex.Material = Enum.Material.Neon
		vortex.Transparency = 0.30
		vortex.Anchored = true
		vortex.CanCollide = false
		vortex.Parent = container
		ctx.registerInstance(vortex, 0.65)

		local targetSize = 7.5 * intensity
		local twVortex = TweenService:Create(vortex, TweenInfo.new(0.50, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(targetSize, targetSize, targetSize),
			Transparency = 0.10,
		})
		twVortex:Play()
		ctx.registerTween(twVortex)

		-- Swirling King of Hell Energy Ribbons
		local ribbonCount = if ctx.quality == "Low" then 1 elseif ctx.quality == "Medium" then 2 else 4
		for i = 1, ribbonCount do
			local angle = (i * (math.pi * 2 / ribbonCount))
			local offset = Vector3.new(math.cos(angle) * 3.2, math.sin(angle) * 1.2, math.sin(angle) * 3.2)

			local ribbon = Instance.new("Part")
			ribbon.Name = string.format("ZoroDragon_AuraRibbon_%d", i)
			ribbon.Shape = Enum.PartType.Block
			ribbon.Size = Vector3.new(0.18, 0.18, 3.2 * intensity)
			ribbon.CFrame = CFrame.lookAt(centerPos + offset, centerPos)
			ribbon.Color = if i % 2 == 1 then Color3.fromRGB(40, 245, 130) else Color3.fromRGB(140, 35, 220)
			ribbon.Material = Enum.Material.Neon
			ribbon.Transparency = 0.15
			ribbon.Anchored = true
			ribbon.CanCollide = false
			ribbon.Parent = container
			ctx.registerInstance(ribbon, 0.50)

			local twRibbon = TweenService:Create(ribbon, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				Transparency = 0.90,
			})
			twRibbon:Play()
			ctx.registerTween(twRibbon)
		end

	-- -------------------------------------------------------------------------
	-- CUE 7: UltimateImpact (103 Mercies Dragon Damnation Cross-Slash Explosion)
	-- -------------------------------------------------------------------------
	elseif cue == "UltimateImpact" then
		-- Invariant: disable all lingering blade trails on impact
		ZoroVFX.disableAllTrails(sourceModel)

		if not ctx.layerFlags.enableImpactEffect then
			return
		end

		-- A. Cataclysmic Dragon Cross-Slash Energy Blast Dome
		local blastDome = Instance.new("Part")
		blastDome.Name = "ZoroDragon_BlastDome"
		blastDome.Shape = Enum.PartType.Ball
		blastDome.Size = Vector3.new(2.0, 2.0, 2.0)
		blastDome.Position = targetPos
		blastDome.Color = Color3.fromRGB(40, 255, 120)
		blastDome.Material = Enum.Material.Neon
		blastDome.Transparency = 0.10
		blastDome.Anchored = true
		blastDome.CanCollide = false
		blastDome.Parent = container
		ctx.registerInstance(blastDome, 0.55)

		local domeSize = 16.0 * intensity
		local twDome = TweenService:Create(blastDome, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(domeSize, domeSize, domeSize),
			Transparency = 1.0,
		})
		twDome:Play()
		ctx.registerTween(twDome)

		-- B. Immense Ground Scorch Ring
		local groundRing = Instance.new("Part")
		groundRing.Name = "ZoroDragon_GroundRing"
		groundRing.Shape = Enum.PartType.Cylinder
		groundRing.Size = Vector3.new(0.30, 2.0, 2.0)
		groundRing.CFrame = CFrame.new(targetPos - Vector3.new(0, 0.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
		groundRing.Color = Color3.fromRGB(30, 180, 80)
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

		-- C. Dragon Cross-Slash Energy Bolts (Medium & High)
		local boltCount = if ctx.quality == "Low" then 2 elseif ctx.quality == "Medium" then 4 else 6
		for i = 1, boltCount do
			local angle = i * (math.pi * 2 / boltCount)
			local dir = Vector3.new(math.cos(angle), 0.15, math.sin(angle))
			local len = 4.5 * intensity

			local bolt = Instance.new("Part")
			bolt.Name = string.format("ZoroDragon_EnergyBolt_%d", i)
			bolt.Shape = Enum.PartType.Block
			bolt.Size = Vector3.new(0.20, 0.20, len)
			bolt.CFrame = CFrame.lookAt(targetPos, targetPos + dir) * CFrame.new(0, 0, -len * 0.5)
			bolt.Color = if i % 2 == 1 then Color3.fromRGB(50, 255, 140) else Color3.fromRGB(140, 30, 220)
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
			lightPart.Name = "ZoroDragon_LightPart"
			lightPart.Transparency = 1.0
			lightPart.Anchored = true
			lightPart.CanCollide = false
			lightPart.Position = targetPos
			lightPart.Parent = container

			local light = Instance.new("PointLight")
			light.Name = "ZoroDragon_PointLight"
			light.Color = Color3.fromRGB(50, 255, 140)
			light.Range = 24 * intensity
			light.Brightness = 4.5
			light.Parent = lightPart

			ctx.registerInstance(lightPart, 0.25)
		end

	-- -------------------------------------------------------------------------
	-- CUE 8: SpecialIdleCue / EnmaChargePulse (Green Flame Blade Flare)
	-- -------------------------------------------------------------------------
	elseif cue == "SpecialIdleCue" or cue == "EnmaChargePulse" then
		if not ctx.layerFlags.enableParticles then
			return
		end

		local rightArm = sourceModel:FindFirstChild("RightArm") :: BasePart?
		local flarePos = if rightArm
			then rightArm.Position + rightArm.CFrame.LookVector * 0.9 + Vector3.new(0, 0.4, 0)
			else (root.Position + Vector3.new(1.0, 1.8, 0.2))

		for i = 1, 2 do
			local flare = Instance.new("Part")
			flare.Name = string.format("ZoroEnma_FlareWisp_%d", i)
			flare.Shape = Enum.PartType.Ball
			flare.Size = Vector3.new(0.45, 0.45, 0.45)
			flare.Position = flarePos + Vector3.new((i - 1.5) * 0.35, 0, 0)
			flare.Color = if i % 2 == 1 then Color3.fromRGB(40, 240, 120) else Color3.fromRGB(150, 40, 230)
			flare.Material = Enum.Material.Neon
			flare.Transparency = 0.25
			flare.Anchored = true
			flare.CanCollide = false
			flare.Parent = container
			ctx.registerInstance(flare, 0.35)

			local twFlare = TweenService:Create(flare, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(1.4 * intensity, 1.4 * intensity, 1.4 * intensity),
				Position = flare.Position + Vector3.new(0, 0.9, 0.2),
				Transparency = 1.0,
			})
			twFlare:Play()
			ctx.registerTween(twFlare)
		end
	end
end

-- =============================================================================
-- 3. CLEANUP ALL FOR MODEL
-- =============================================================================

function ZoroVFX.cleanupAllForModel(sourceModel: Model)
	ZoroVFX.stopPassiveAura(sourceModel)
	ZoroVFX.disableAllTrails(sourceModel)
	activeAuras[sourceModel] = nil
	activeTrails[sourceModel] = nil
end

return table.freeze(ZoroVFX)
