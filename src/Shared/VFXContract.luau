--!strict
-- src/Shared/VFXContract.luau
-- Anime Limitless Tower Defense — Phase 5 Foundational VFX Contract
-- Authoritative definition of Quality Presets, Layer Flags, Intensity Scaling,
-- Resource Ledgers, Cue Schemas, and Strict Combat Decoupling.

local VFXContract = {}

VFXContract.VERSION = "5.0.0"

-- =============================================================================
-- 1. QUALITY PRESETS & SETTINGS
-- =============================================================================

export type VFXQualityPreset = "Low" | "Medium" | "High"

export type QualityConfig = {
	particleRate: number,
	maxParts: number,
	allowBeams: boolean,
	allowScreenFX: boolean,
	allowPointLights: boolean,
	allowTrails: boolean,
	meshDetail: "Low" | "Medium" | "High",
}

VFXContract.QUALITY_SETTINGS = table.freeze({
	Low = table.freeze({
		particleRate = 0.35,
		maxParts = 8,
		allowBeams = false,
		allowScreenFX = false,
		allowPointLights = false,
		allowTrails = false,
		meshDetail = "Low" :: "Low",
	}),
	Medium = table.freeze({
		particleRate = 0.70,
		maxParts = 16,
		allowBeams = true,
		allowScreenFX = false,
		allowPointLights = true,
		allowTrails = true,
		meshDetail = "Medium" :: "Medium",
	}),
	High = table.freeze({
		particleRate = 1.00,
		maxParts = 30,
		allowBeams = true,
		allowScreenFX = true,
		allowPointLights = true,
		allowTrails = true,
		meshDetail = "High" :: "High",
	}),
})

-- =============================================================================
-- 2. 6 LAYER FLAGS
-- =============================================================================

export type VFXLayerFlags = {
	enableParticles: boolean,
	enableAura: boolean,
	enableTrailOrBeam: boolean,
	enableImpactEffect: boolean,
	enableCameraShake: boolean,
	enableScreenFlash: boolean,
}

VFXContract.DEFAULT_LAYER_FLAGS = table.freeze({
	enableParticles = true,
	enableAura = true,
	enableTrailOrBeam = true,
	enableImpactEffect = true,
	enableCameraShake = true,
	enableScreenFlash = true,
})

-- =============================================================================
-- 3. CUES & EXTENSION CUES
-- =============================================================================

export type CommonVFXCue =
	"PassiveAura"
	| "SpawnDeploy"
	| "AttackWindup"
	| "AttackRelease"
	| "AttackImpact"
	| "UltimateCast"
	| "UltimateImpact"

export type CharacterExtensionCue =
	"SpecialIdleCue"
	| "NikaLaughPuff"
	| "EnmaChargePulse"
	| "FlameShoulderFlare"

export type VFXCueType = CommonVFXCue | CharacterExtensionCue | string

VFXContract.COMMON_CUES = table.freeze({
	"PassiveAura",
	"SpawnDeploy",
	"AttackWindup",
	"AttackRelease",
	"AttackImpact",
	"UltimateCast",
	"UltimateImpact",
})

VFXContract.CHARACTER_CUES = table.freeze({
	"SpecialIdleCue",
	"NikaLaughPuff",
	"EnmaChargePulse",
	"FlameShoulderFlare",
})

VFXContract.ALL_CUES = table.freeze({
	"PassiveAura",
	"SpawnDeploy",
	"SpecialIdleCue",
	"AttackWindup",
	"AttackRelease",
	"AttackImpact",
	"UltimateCast",
	"UltimateImpact",
	"NikaLaughPuff",
	"EnmaChargePulse",
	"FlameShoulderFlare",
})

local CUE_LOOKUP: { [string]: boolean } = {}
for _, cue in ipairs(VFXContract.ALL_CUES) do
	CUE_LOOKUP[cue] = true
end

function VFXContract.IsValidCue(cue: string): boolean
	return CUE_LOOKUP[cue] == true
end

-- =============================================================================
-- 4. INTENSITY RANGE & CONSTANTS
-- =============================================================================

VFXContract.MIN_INTENSITY = 0.1
VFXContract.MAX_INTENSITY = 2.0
VFXContract.DEFAULT_INTENSITY = 1.0
VFXContract.DEFAULT_MAX_CONCURRENT_INSTANCES = 25

function VFXContract.ClampIntensity(intensity: number?): number
	if not intensity or intensity ~= intensity then
		return VFXContract.DEFAULT_INTENSITY
	end
	return math.clamp(intensity, VFXContract.MIN_INTENSITY, VFXContract.MAX_INTENSITY)
end

-- =============================================================================
-- 5. RESOURCE LEDGER & EXECUTION CONTEXT INTERFACES
-- =============================================================================

export type RegisterInstanceFn = (inst: Instance, ttlSeconds: number?) -> ()
export type RegisterTweenFn = (tween: Tween) -> ()
export type RegisterTaskFn = (taskRef: any) -> ()
export type RegisterConnectionFn = (conn: RBXScriptConnection) -> ()
export type RegisterCleanupCallbackFn = (cb: () -> ()) -> ()

export type VFXExecutionContext = {
	heroId: string,
	cueType: VFXCueType,
	sourceModel: Model,
	rootPart: BasePart,
	originCFrame: CFrame,
	targetPosition: Vector3,
	targetModel: Model?,
	intensity: number,
	quality: VFXQualityPreset,
	layerFlags: VFXLayerFlags,
	sandboxContainer: Folder?,
	registerInstance: RegisterInstanceFn,
	registerTween: RegisterTweenFn,
	registerTask: RegisterTaskFn,
	registerConnection: RegisterConnectionFn,
	registerCleanupCallback: RegisterCleanupCallbackFn,
}

export type ResourceLedgerReport = {
	trackedInstances: number,
	trackedTweens: number,
	trackedTasks: number,
	trackedConnections: number,
	createdCount: number,
	cleanedCount: number,
	activeCount: number,
}

-- =============================================================================
-- 6. CHARACTER VFX MODULE INTERFACE
-- =============================================================================

export type CharacterVFXModule = {
	heroId: string,
	maxConcurrentVFXInstances: number,
	startPassiveAura: (ctx: VFXExecutionContext) -> (),
	stopPassiveAura: (sourceModel: Model) -> (),
	triggerCue: (ctx: VFXExecutionContext) -> (),
	cleanupAllForModel: (sourceModel: Model) -> (),
}

-- =============================================================================
-- 7. PURE HELPER & CONFIGURATION FUNCTIONS
-- =============================================================================

function VFXContract.ResolveQuality(preset: VFXQualityPreset?): QualityConfig
	if preset == "Low" then
		return VFXContract.QUALITY_SETTINGS.Low
	elseif preset == "High" then
		return VFXContract.QUALITY_SETTINGS.High
	else
		return VFXContract.QUALITY_SETTINGS.Medium
	end
end

function VFXContract.MergeLayerFlags(customFlags: { [string]: boolean }?): VFXLayerFlags
	local defaults = VFXContract.DEFAULT_LAYER_FLAGS
	if not customFlags then
		return {
			enableParticles = defaults.enableParticles,
			enableAura = defaults.enableAura,
			enableTrailOrBeam = defaults.enableTrailOrBeam,
			enableImpactEffect = defaults.enableImpactEffect,
			enableCameraShake = defaults.enableCameraShake,
			enableScreenFlash = defaults.enableScreenFlash,
		}
	end

	return {
		enableParticles = if customFlags.enableParticles ~= nil then customFlags.enableParticles else defaults.enableParticles,
		enableAura = if customFlags.enableAura ~= nil then customFlags.enableAura else defaults.enableAura,
		enableTrailOrBeam = if customFlags.enableTrailOrBeam ~= nil then customFlags.enableTrailOrBeam else defaults.enableTrailOrBeam,
		enableImpactEffect = if customFlags.enableImpactEffect ~= nil then customFlags.enableImpactEffect else defaults.enableImpactEffect,
		enableCameraShake = if customFlags.enableCameraShake ~= nil then customFlags.enableCameraShake else defaults.enableCameraShake,
		enableScreenFlash = if customFlags.enableScreenFlash ~= nil then customFlags.enableScreenFlash else defaults.enableScreenFlash,
	}
end

function VFXContract.CalculateParticleRate(
	baseRate: number,
	quality: VFXQualityPreset,
	intensity: number,
	layerFlags: VFXLayerFlags
): number
	if not layerFlags.enableParticles then
		return 0
	end
	local qConfig = VFXContract.ResolveQuality(quality)
	local clampedIntensity = VFXContract.ClampIntensity(intensity)
	return math.round(baseRate * qConfig.particleRate * clampedIntensity)
end

function VFXContract.CalculateMaxParts(baseMaxParts: number, quality: VFXQualityPreset): number
	local qConfig = VFXContract.ResolveQuality(quality)
	return math.min(baseMaxParts, qConfig.maxParts)
end

-- =============================================================================
-- 8. ARCHITECTURAL INVARIANT CONTRACT: DECOUPLING FROM COMBAT
-- =============================================================================
-- Invariant Rules:
-- 1. VFX modules MUST NEVER mutate enemy health, attributes, or game economy.
-- 2. VFXExecutionContext does NOT contain damage callbacks or combat delegates.
-- 3. Any visual script error caught in pcall inside VFXDispatcher MUST NOT delay,
--    interrupt, or drop the server combat loop (0.31s nominal impact timer).
-- 4. Tower destruction/sale cancels all pending VFX instances immediately.

return table.freeze(VFXContract)
