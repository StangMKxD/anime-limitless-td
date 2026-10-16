--!strict
-- src/Track2_TowerSystem/AnimationRegistry.luau
-- Anime Limitless Tower Defense — Phase 5 Animation & VFX Registry
-- Dynamically discovers and caches character profiles and VFX modules.
-- Features canonical alias mapping, zero-conflict loading, and graceful fallbacks.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")

local AnimationContract = require(SharedFolder:WaitForChild("AnimationContract")) :: any
local VFXContract = require(SharedFolder:WaitForChild("VFXContract")) :: any

local AnimationRegistry = {}

-- Safe directory references (supports runtime staging and test harnesses)
local function getAnimationsFolder(): Instance?
	return script.Parent:FindFirstChild("Animations")
end

local function getVFXFolder(): Instance?
	return script.Parent:FindFirstChild("VFX")
end

-- Internal in-memory caches
local profileCache: { [string]: AnimationContract.CharacterAnimationProfile } = {}
local vfxCache: { [string]: VFXContract.CharacterVFXModule } = {}

-- Canonical GameConfig HeroId -> Model Name Alias Map
local HERO_ALIASES: { [string]: string } = {
	Tower_Luffy_G5 = "Luffy",
	Tower_Zoro_KingOfHell = "Zoro",
	Tower_Ace_Entei = "Ace",
	Tower_Shanks_Kamusari = "Shanks",
	Tower_Whitebeard_Gura = "Whitebeard",
	Tower_Sanji_Ifrit = "Sanji",
	Tower_Nami_Zeus = "Nami",
	Tower_Usopp_Kabuto = "Usopp",
	Tower_Chopper_Monster = "Chopper",
	Tower_Robin_Demonio = "Robin",
	Tower_Law_KRoom = "Law",
	Tower_Kizaru_Pika = "Kizaru",
}

function AnimationRegistry.NormalizeHeroId(rawId: string): string
	if not rawId or rawId == "" then
		return "Default"
	end
	if HERO_ALIASES[rawId] then
		return HERO_ALIASES[rawId]
	end
	-- Strip "Tower_" prefix if present
	local stripped = string.gsub(rawId, "^Tower_", "")
	-- Strip trailing underscores or variants
	local base = string.split(stripped, "_")[1]
	return if base and base ~= "" then base else rawId
end

function AnimationRegistry.GetAnimationProfile(
	heroId: string
): (AnimationContract.CharacterAnimationProfile, boolean, string)
	local normId = AnimationRegistry.NormalizeHeroId(heroId)

	-- 1. Check in-memory cache
	if profileCache[normId] then
		return profileCache[normId], true, "CachedSignature"
	end

	-- 2. Attempt dynamic discovery in Animations/
	local folder = getAnimationsFolder()
	if folder then
		local modInst = folder:FindFirstChild(normId)
		if modInst and modInst:IsA("ModuleScript") then
			local ok, result = pcall(require, modInst)
			if ok and type(result) == "table" and result.states then
				local valid, valErr = AnimationContract.ValidateProfile(result)
				if valid then
					profileCache[normId] = result :: AnimationContract.CharacterAnimationProfile
					return profileCache[normId], true, "SignatureLoaded"
				else
					warn(string.format("[AnimationRegistry] Invalid profile for '%s': %s", normId, tostring(valErr)))
				end
			else
				warn(string.format("[AnimationRegistry] Failed to require profile for '%s': %s", normId, tostring(result)))
			end
		end
	end

	-- 3. Graceful fallback to _FallbackProfile
	local fallbackModule: any = nil
	if folder then
		local fbInst = folder:FindFirstChild("_FallbackProfile")
		if fbInst and fbInst:IsA("ModuleScript") then
			local ok, res = pcall(require, fbInst)
			if ok then
				fallbackModule = res
			end
		end
	end

	if fallbackModule and type(fallbackModule.CreateForHero) == "function" then
		local fallback = fallbackModule.CreateForHero(normId)
		return fallback, false, "FallbackUsed: ModuleNotFound"
	end

	-- Extreme fallback if _FallbackProfile file itself cannot be located
	local emergencyFallback: AnimationContract.CharacterAnimationProfile = {
		heroId = normId,
		displayName = normId .. " (Emergency Fallback)",
		contractVersion = "5.0.0",
		rigType = "StaticFallback",
		expectedJoints = AnimationContract.BODY_JOINTS,
		accessoryRules = {},
		baseScale = 1.0,
		attackCycleTimings = {
			windupRatio = 0.2745,
			attackRatio = 0.1961,
			impactRatio = 0.1373,
			recoveryRatio = 0.3921,
		},
		states = {
			Idle = {
				state = "Idle",
				duration = 1.0,
				looped = true,
				canCancel = true,
				keyframes = {
					{ alpha = 0.0, poses = {} },
					{ alpha = 1.0, poses = {} },
				},
			},
			Windup = {
				state = "Windup",
				duration = 0.14,
				looped = false,
				canCancel = true,
				keyframes = { { alpha = 0.0, poses = {} }, { alpha = 1.0, poses = {} } },
			},
			Attack = {
				state = "Attack",
				duration = 0.10,
				looped = false,
				canCancel = true,
				keyframes = { { alpha = 0.0, poses = {} }, { alpha = 1.0, poses = {} } },
			},
			Impact = {
				state = "Impact",
				duration = 0.07,
				looped = false,
				canCancel = false,
				keyframes = { { alpha = 0.0, poses = {} }, { alpha = 1.0, poses = {} } },
			},
			Recovery = {
				state = "Recovery",
				duration = 0.20,
				looped = false,
				canCancel = true,
				keyframes = { { alpha = 0.0, poses = {} }, { alpha = 1.0, poses = {} } },
			},
		},
	}
	return emergencyFallback, false, "EmergencyFallbackUsed"
end

function AnimationRegistry.GetVFXModule(
	heroId: string
): (VFXContract.CharacterVFXModule, boolean, string)
	local normId = AnimationRegistry.NormalizeHeroId(heroId)

	-- 1. Check in-memory cache
	if vfxCache[normId] then
		return vfxCache[normId], true, "CachedSignature"
	end

	-- 2. Attempt dynamic discovery in VFX/
	local folder = getVFXFolder()
	if folder then
		local modInst = folder:FindFirstChild(normId .. "VFX")
		if modInst and modInst:IsA("ModuleScript") then
			local ok, result = pcall(require, modInst)
			if ok and type(result) == "table" and type(result.triggerCue) == "function" then
				vfxCache[normId] = result :: VFXContract.CharacterVFXModule
				return vfxCache[normId], true, "SignatureLoaded"
			else
				warn(string.format("[AnimationRegistry] Failed to require VFX module for '%s': %s", normId, tostring(result)))
			end
		end
	end

	-- 3. Graceful fallback to _FallbackVFX
	if folder then
		local fbInst = folder:FindFirstChild("_FallbackVFX")
		if fbInst and fbInst:IsA("ModuleScript") then
			local fbOk, fbMod = pcall(require, fbInst)
			if fbOk and type(fbMod) == "table" then
				return fbMod :: VFXContract.CharacterVFXModule, false, "FallbackUsed: ModuleNotFound"
			end
		end
	end

	-- Extreme fallback
	local emergencyVFX: VFXContract.CharacterVFXModule = {
		heroId = normId,
		maxConcurrentVFXInstances = 25,
		startPassiveAura = function(_) end,
		stopPassiveAura = function(_) end,
		triggerCue = function(_) end,
		cleanupAllForModel = function(_) end,
	}
	return emergencyVFX, false, "EmergencyFallbackUsed"
end

function AnimationRegistry.RegisterProfile(heroId: string, profile: AnimationContract.CharacterAnimationProfile)
	profileCache[AnimationRegistry.NormalizeHeroId(heroId)] = profile
end

function AnimationRegistry.RegisterVFXModule(heroId: string, vfxModule: VFXContract.CharacterVFXModule)
	vfxCache[AnimationRegistry.NormalizeHeroId(heroId)] = vfxModule
end

function AnimationRegistry.ClearCache()
	table.clear(profileCache)
	table.clear(vfxCache)
end

return table.freeze(AnimationRegistry)
