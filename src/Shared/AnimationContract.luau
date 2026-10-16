--!strict
-- src/Shared/AnimationContract.luau
-- Anime Limitless Tower Defense — Phase 5 Foundational Animation Contract
-- Authoritative definition of Animation States, Semantic Joints, Rig Mapping,
-- RestPoseSnapshot, Procedural Keyframes, and Deterministic Timeline Evaluation.

local AnimationContract = {}

AnimationContract.VERSION = "5.0.0"

-- =============================================================================
-- ATTRIBUTES & CONSTANTS
-- =============================================================================

AnimationContract.ATTRIBUTES = table.freeze({
	TRACK2_RIG_OWNED = "Track2RigOwned",
	RIG_READY = "RigReady",
	VISUAL_SOURCE = "VisualSource",
	RIG_VERSION = "RigVersion",
	HERO_ID = "HeroId",
	IS_LAB_DUMMY = "IsAnimationLabDummy",
	IS_LAB_DUMMY_LEGACY = "IsLabDummy",
})

-- =============================================================================
-- 1. ANIMATION STATES
-- =============================================================================

export type AnimationState =
	"Idle"
	| "SpecialIdle"
	| "Spawn"
	| "Windup"
	| "Attack"
	| "Impact"
	| "Recovery"
	| "Ultimate"

AnimationContract.STATES = table.freeze({
	Idle = "Idle" :: AnimationState,
	SpecialIdle = "SpecialIdle" :: AnimationState,
	Spawn = "Spawn" :: AnimationState,
	Windup = "Windup" :: AnimationState,
	Attack = "Attack" :: AnimationState,
	Impact = "Impact" :: AnimationState,
	Recovery = "Recovery" :: AnimationState,
	Ultimate = "Ultimate" :: AnimationState,
})

AnimationContract.REQUIRED_STATES = table.freeze({
	"Idle",
	"Windup",
	"Attack",
	"Impact",
	"Recovery",
})

AnimationContract.OPTIONAL_STATES = table.freeze({
	"SpecialIdle",
	"Spawn",
	"Ultimate",
})

AnimationContract.ATTACK_SEQUENCE = table.freeze({
	"Windup",
	"Attack",
	"Impact",
	"Recovery",
})

-- =============================================================================
-- 2. SEMANTIC JOINTS (6 Body + 3 Weapon Joints)
-- =============================================================================

export type JointName =
	"RootJoint"
	| "Neck"
	| "RightShoulder"
	| "LeftShoulder"
	| "RightHip"
	| "LeftHip"
	| "WeaponRight"
	| "WeaponLeft"
	| "WeaponMouth"

AnimationContract.BODY_JOINTS = table.freeze({
	"RootJoint",
	"Neck",
	"RightShoulder",
	"LeftShoulder",
	"RightHip",
	"LeftHip",
})

AnimationContract.WEAPON_JOINTS = table.freeze({
	"WeaponRight",
	"WeaponLeft",
	"WeaponMouth",
})

AnimationContract.CANONICAL_JOINTS = table.freeze({
	"RootJoint",
	"Neck",
	"RightShoulder",
	"LeftShoulder",
	"RightHip",
	"LeftHip",
	"WeaponRight",
	"WeaponLeft",
	"WeaponMouth",
})

export type JointHierarchyDef = {
	parentLimb: string,
	childLimb: string,
	defaultBaseC0: CFrame,
	defaultBaseC1: CFrame,
}

AnimationContract.JOINT_DEFAULTS = table.freeze({
	RootJoint = {
		parentLimb = "HumanoidRootPart",
		childLimb = "Torso",
		defaultBaseC0 = CFrame.identity,
		defaultBaseC1 = CFrame.identity,
	},
	Neck = {
		parentLimb = "Torso",
		childLimb = "Head",
		defaultBaseC0 = CFrame.new(0, 1.5, 0),
		defaultBaseC1 = CFrame.new(0, -0.5, 0),
	},
	RightShoulder = {
		parentLimb = "Torso",
		childLimb = "RightArm",
		defaultBaseC0 = CFrame.new(1.5, 0.5, 0),
		defaultBaseC1 = CFrame.new(0, 0.5, 0),
	},
	LeftShoulder = {
		parentLimb = "Torso",
		childLimb = "LeftArm",
		defaultBaseC0 = CFrame.new(-1.5, 0.5, 0),
		defaultBaseC1 = CFrame.new(0, 0.5, 0),
	},
	RightHip = {
		parentLimb = "Torso",
		childLimb = "RightLeg",
		defaultBaseC0 = CFrame.new(0.5, -1.0, 0),
		defaultBaseC1 = CFrame.new(0, 1.0, 0),
	},
	LeftHip = {
		parentLimb = "Torso",
		childLimb = "LeftLeg",
		defaultBaseC0 = CFrame.new(-0.5, -1.0, 0),
		defaultBaseC1 = CFrame.new(0, 1.0, 0),
	},
	WeaponRight = {
		parentLimb = "RightArm",
		childLimb = "EnmaHandle",
		defaultBaseC0 = CFrame.new(0, -1.0, -0.2) * CFrame.Angles(math.rad(-90), 0, 0),
		defaultBaseC1 = CFrame.identity,
	},
	WeaponLeft = {
		parentLimb = "LeftArm",
		childLimb = "SandaiHandle",
		defaultBaseC0 = CFrame.new(0, -1.0, -0.2) * CFrame.Angles(math.rad(-90), 0, 0),
		defaultBaseC1 = CFrame.identity,
	},
	WeaponMouth = {
		parentLimb = "Head",
		childLimb = "WadoHandle",
		defaultBaseC0 = CFrame.new(0, -0.25, -0.55) * CFrame.Angles(0, 0, math.rad(90)),
		defaultBaseC1 = CFrame.identity,
	},
})

-- =============================================================================
-- 3. MULTI-PART LIMB BINDING & ACCESSORY SCHEMAS
-- =============================================================================

export type SemanticLimbName =
	"Head"
	| "Torso"
	| "RightArm"
	| "LeftArm"
	| "RightLeg"
	| "LeftLeg"
	| "WeaponRight"
	| "WeaponLeft"
	| "WeaponMouth"

export type LimbBindingRule = {
	limbName: SemanticLimbName,
	primaryPartPattern: string,
	memberPatterns: { string },
	mirrorSide: ("Right" | "Left" | "Center")?,
	relativePositionHint: Vector3?,
}

export type AccessoryWeldRule = {
	accessoryNamePattern: string,
	attachToLimb: SemanticLimbName,
	offsetCFrame: CFrame?,
	useMotor6D: boolean?,
	jointName: JointName?,
}

export type ScaleTarget = {
	targetLimb: string,
	scaleFactor: Vector3,
	pivotOffsetCompensation: Vector3?,
	affectedParts: { string }?,
}

-- =============================================================================
-- 4. REST POSE SNAPSHOT SCHEMA (Zero-Drift Invariant)
-- =============================================================================

export type RestPoseSnapshot = {
	baseC0: { [JointName]: CFrame },
	baseC1: { [JointName]: CFrame },
	basePartSizes: { [string]: Vector3 },
	baseAttachmentCFrames: { [string]: CFrame },
	basePartPositions: { [string]: Vector3 }?,
}

-- =============================================================================
-- 5. PROCEDURAL KEYFRAMES & TIMELINES
-- =============================================================================

export type JointPoseMap = {
	[JointName]: CFrame,
}

export type ProceduralKeyframe = {
	alpha: number, -- 0.0 to 1.0 (finite, monotonically sorted)
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	poses: JointPoseMap,
	vfxCue: string?,
	scaleTarget: ScaleTarget?,
	scaleMultiplier: Vector3?, -- Backward-compatible alias
}

export type StateTrackDefinition = {
	state: AnimationState,
	duration: number, -- Base duration in seconds (> 0)
	looped: boolean,
	canCancel: boolean,
	keyframes: { ProceduralKeyframe },
}

export type AttackCycleTimings = {
	windupRatio: number,
	attackRatio: number,
	impactRatio: number,
	recoveryRatio: number,
}

export type CharacterAnimationProfile = {
	heroId: string,
	displayName: string,
	contractVersion: string,
	rigType: "Articulated6Joint" | "ArticulatedWeaponRig" | "StaticFallback",
	expectedJoints: { JointName },
	accessoryRules: { AccessoryWeldRule },
	baseScale: number,
	attackCycleTimings: AttackCycleTimings,
	states: { [AnimationState]: StateTrackDefinition },
}

-- =============================================================================
-- 6. RUNTIME RIG CONTEXT & TRANSPORT CONTROLS
-- =============================================================================

export type TransportAction =
	"Play"
	| "Pause"
	| "Resume"
	| "Stop"
	| "Replay"
	| "Seek"
	| "Step"
	| "ResetPose"

export type RigContext = {
	model: Model,
	rootPart: BasePart,
	torso: BasePart?,
	limbs: { [string]: BasePart },
	motors: { [JointName]: Motor6D },
	restPose: RestPoseSnapshot,
	activeState: AnimationState,
	playbackSpeed: number, -- Clamped to [0.1, 2.0]
	isPaused: boolean,
	elapsedInState: number,
	cancelToken: number,
	currentScaleMultiplier: Vector3?,
	isDestroyed: boolean?,
}

export type RigValidationCode =
	"VALID"
	| "MISSING_ROOT"
	| "MISSING_LIMB"
	| "MISSING_JOINT"
	| "AMBIGUOUS_MAPPING"
	| "CONFLICT_WELD_OVER_MOTOR"
	| "DESTROYED_CONTEXT"
	| "INVALID_PROFILE"
	| "STATIC_MAP_ASSET"

export type RigValidationReport = {
	isValid: boolean,
	code: RigValidationCode,
	message: string,
	missingJoints: { JointName },
	conflictingWelds: { string },
	limbPartCounts: { [string]: number },
}

-- =============================================================================
-- 7. PURE LOGIC & DETERMINISTIC EVALUATION FUNCTIONS
-- =============================================================================

function AnimationContract.InterpolateCFrame(cf0: CFrame, cf1: CFrame, alpha: number): CFrame
	return cf0:Lerp(cf1, math.clamp(alpha, 0, 1))
end

function AnimationContract.InterpolateVector3(v0: Vector3, v1: Vector3, alpha: number): Vector3
	return v0:Lerp(v1, math.clamp(alpha, 0, 1))
end

function AnimationContract.ValidateKeyframes(keyframes: { ProceduralKeyframe }): (boolean, string?)
	if #keyframes == 0 then
		return false, "Keyframes array cannot be empty"
	end

	local prevAlpha = -1
	for idx, kf in ipairs(keyframes) do
		if kf.alpha ~= kf.alpha or kf.alpha < 0 or kf.alpha > 1 then
			return false, string.format("Keyframe %d has invalid alpha: %s", idx, tostring(kf.alpha))
		end
		if kf.alpha < prevAlpha then
			return false, string.format("Keyframes not sorted monotonically: idx %d alpha %.4f < %.4f", idx, kf.alpha, prevAlpha)
		end
		prevAlpha = kf.alpha
	end

	return true, nil
end

function AnimationContract.ValidateProfile(profile: CharacterAnimationProfile): (boolean, string?)
	if not profile.heroId or profile.heroId == "" then
		return false, "Missing or empty heroId"
	end
	if not profile.states or not profile.states.Idle then
		return false, "Missing mandatory Idle state"
	end

	for _, requiredState in ipairs(AnimationContract.REQUIRED_STATES) do
		local track = profile.states[requiredState :: AnimationState]
		if not track then
			return false, string.format("Missing required combat state: %s", requiredState)
		end
		if track.duration <= 0 then
			return false, string.format("State %s has non-positive duration: %.4f", requiredState, track.duration)
		end
		local validKfs, kfErr = AnimationContract.ValidateKeyframes(track.keyframes)
		if not validKfs then
			return false, string.format("State %s invalid keyframes: %s", requiredState, kfErr or "unknown error")
		end
	end

	local timings = profile.attackCycleTimings
	if timings then
		local sum = timings.windupRatio + timings.attackRatio + timings.impactRatio + timings.recoveryRatio
		if math.abs(sum - 1.0) > 0.005 then
			return false, string.format("AttackCycleTimings ratios must sum to 1.0 (got %.4f)", sum)
		end
	end

	return true, nil
end

function AnimationContract.EvaluatePoseAtTime(
	track: StateTrackDefinition,
	elapsedSeconds: number
): (JointPoseMap, ScaleTarget?, string?)
	if elapsedSeconds ~= elapsedSeconds or elapsedSeconds < 0 then
		elapsedSeconds = 0
	end

	local duration = track.duration
	if duration <= 0 then
		duration = 0.001
	end

	local effectiveElapsed = elapsedSeconds
	if track.looped then
		effectiveElapsed = elapsedSeconds % duration
	else
		effectiveElapsed = math.clamp(elapsedSeconds, 0, duration)
	end

	local alpha = math.clamp(effectiveElapsed / duration, 0, 1)
	local keyframes = track.keyframes
	local kfCount = #keyframes

	if kfCount == 0 then
		return {}, nil, nil
	elseif kfCount == 1 or alpha <= keyframes[1].alpha then
		local kf = keyframes[1]
		local scale = kf.scaleTarget
		if not scale and kf.scaleMultiplier then
			scale = {
				targetLimb = "Model",
				scaleFactor = kf.scaleMultiplier,
			}
		end
		return kf.poses, scale, kf.vfxCue
	elseif alpha >= keyframes[kfCount].alpha then
		local kf = keyframes[kfCount]
		local scale = kf.scaleTarget
		if not scale and kf.scaleMultiplier then
			scale = {
				targetLimb = "Model",
				scaleFactor = kf.scaleMultiplier,
			}
		end
		return kf.poses, scale, nil
	end

	-- Binary search / linear scan for bounding keyframe pair
	local idx0 = 1
	for i = 1, kfCount - 1 do
		if alpha >= keyframes[i].alpha and alpha <= keyframes[i + 1].alpha then
			idx0 = i
			break
		end
	end

	local k0 = keyframes[idx0]
	local k1 = keyframes[idx0 + 1]
	local span = k1.alpha - k0.alpha
	local localAlpha = 0
	if span > 0.00001 then
		localAlpha = (alpha - k0.alpha) / span
	end

	-- Apply easing if specified on target keyframe
	local easedAlpha = localAlpha
	if k1.easingStyle and k1.easingStyle ~= Enum.EasingStyle.Linear then
		local style = k1.easingStyle
		local dir = k1.easingDirection or Enum.EasingDirection.Out
		if style == Enum.EasingStyle.Quad then
			if dir == Enum.EasingDirection.In then
				easedAlpha = localAlpha * localAlpha
			elseif dir == Enum.EasingDirection.Out then
				easedAlpha = localAlpha * (2 - localAlpha)
			else
				if localAlpha < 0.5 then
					easedAlpha = 2 * localAlpha * localAlpha
				else
					easedAlpha = -1 + (4 - 2 * localAlpha) * localAlpha
				end
			end
		elseif style == Enum.EasingStyle.Exponential then
			if dir == Enum.EasingDirection.In then
				easedAlpha = if localAlpha == 0 then 0 else math.pow(2, 10 * (localAlpha - 1))
			elseif dir == Enum.EasingDirection.Out then
				easedAlpha = if localAlpha == 1 then 1 else 1 - math.pow(2, -10 * localAlpha)
			else
				if localAlpha < 0.5 then
					easedAlpha = 0.5 * math.pow(2, 20 * localAlpha - 10)
				else
					easedAlpha = 1 - 0.5 * math.pow(2, -20 * localAlpha + 10)
				end
			end
		end
	end

	-- Interpolate joint poses
	local interpolatedPoses: JointPoseMap = {}
	for _, jointName in ipairs(AnimationContract.CANONICAL_JOINTS) do
		local pose0 = k0.poses[jointName] or CFrame.identity
		local pose1 = k1.poses[jointName] or pose0
		if pose0 == pose1 then
			interpolatedPoses[jointName] = pose0
		else
			interpolatedPoses[jointName] = pose0:Lerp(pose1, easedAlpha)
		end
	end

	-- Interpolate scale target if present
	local interpolatedScale: ScaleTarget? = nil
	local s0 = k0.scaleTarget or (if k0.scaleMultiplier then { targetLimb = "Model", scaleFactor = k0.scaleMultiplier } else nil)
	local s1 = k1.scaleTarget or (if k1.scaleMultiplier then { targetLimb = "Model", scaleFactor = k1.scaleMultiplier } else nil)

	if s0 and s1 and s0.targetLimb == s1.targetLimb then
		interpolatedScale = {
			targetLimb = s0.targetLimb,
			scaleFactor = s0.scaleFactor:Lerp(s1.scaleFactor, easedAlpha),
			pivotOffsetCompensation = if s0.pivotOffsetCompensation and s1.pivotOffsetCompensation
				then s0.pivotOffsetCompensation:Lerp(s1.pivotOffsetCompensation, easedAlpha)
				else (s1.pivotOffsetCompensation or s0.pivotOffsetCompensation),
			affectedParts = s1.affectedParts or s0.affectedParts,
		}
	elseif s1 then
		interpolatedScale = s1
	elseif s0 then
		interpolatedScale = s0
	end

	-- Cue emission only on exact keyframe boundary span
	local cue = if localAlpha < 0.05 then k0.vfxCue else nil

	return interpolatedPoses, interpolatedScale, cue
end

function AnimationContract.CreateRestPoseSnapshot(
	motors: { [JointName]: Motor6D },
	partSizes: { [string]: Vector3 }?,
	attachmentCFrames: { [string]: CFrame }?
): RestPoseSnapshot
	local baseC0: { [JointName]: CFrame } = {}
	local baseC1: { [JointName]: CFrame } = {}

	for jointName, motor in pairs(motors) do
		baseC0[jointName] = motor.C0
		baseC1[jointName] = motor.C1
	end

	return {
		baseC0 = baseC0,
		baseC1 = baseC1,
		basePartSizes = partSizes or {},
		baseAttachmentCFrames = attachmentCFrames or {},
	}
end

function AnimationContract.CalculateAttackStateDurations(
	baseCycleDuration: number,
	timings: AttackCycleTimings
): { Windup: number, Attack: number, Impact: number, Recovery: number }
	return {
		Windup = baseCycleDuration * timings.windupRatio,
		Attack = baseCycleDuration * timings.attackRatio,
		Impact = baseCycleDuration * timings.impactRatio,
		Recovery = baseCycleDuration * timings.recoveryRatio,
	}
end

return table.freeze(AnimationContract)
