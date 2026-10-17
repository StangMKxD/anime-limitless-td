--!strict
-- src/Track2_TowerSystem/Animations/Ace.luau
-- Anime Limitless Tower Defense — Phase 5 Portgas D. Ace [Flame Emperor] Signature Animation Profile
-- Implements Task A-02: Complete 8-State (+ Despawn) Profile with 6-Joint Articulated Kinematics,
-- Logia Pyrokinesis & Explosive Thrust Choreography, Nominal Combat Hit Timing (0.31s hit / 0.73s cycle),
-- and Mathematically Verified Zero-Drift Restitution (delta < 0.001 studs).

local ReplicatedStorage = (function()
	local ok, svc = pcall(function()
		return game:GetService("ReplicatedStorage")
	end)
	return if ok then svc else nil
end)()

local AnimationContract = (function()
	if ReplicatedStorage then
		local sharedFolder = ReplicatedStorage:FindFirstChild("Shared") or ReplicatedStorage:WaitForChild("Shared", 2)
		if sharedFolder then
			local animMod = sharedFolder:FindFirstChild("AnimationContract") or sharedFolder:WaitForChild("AnimationContract", 2)
			if animMod then
				local ok, mod = pcall(require, animMod)
				if ok then
					return mod
				end
			end
		end
	end
	-- Direct relative require fallback for test harnesses and standalone execution
	local candidatePaths = {
		"../../Shared/AnimationContract",
		"../../../src/Shared/AnimationContract",
		"../../src/Shared/AnimationContract",
		"../src/Shared/AnimationContract",
		"src/Shared/AnimationContract",
	}
	for _, p in ipairs(candidatePaths) do
		local ok, mod = pcall(require, p)
		if ok then
			return mod
		end
	end
	error("[Ace.luau] Failed to load AnimationContract")
end)() :: any

type AnimationState = AnimationContract.AnimationState
type StateTrackDefinition = AnimationContract.StateTrackDefinition
type ProceduralKeyframe = AnimationContract.ProceduralKeyframe
type CharacterAnimationProfile = AnimationContract.CharacterAnimationProfile

-- =============================================================================
-- ACE FLAME EMPEROR COMBAT TIMINGS & ACCESSORY RULES
-- =============================================================================

-- Combat cycle timings strictly locked to 0.31s nominal hit impact (0.14s + 0.10s + 0.07s)
-- Total attack cycle duration = 0.14s + 0.10s + 0.07s + 0.42s = 0.73s
-- Ratios sum strictly to 1.0 (difference < 0.005)
local ATTACK_TIMINGS: AnimationContract.AttackCycleTimings = table.freeze({
	windupRatio = 0.14 / 0.73, -- approx 0.19178 (0.14s)
	attackRatio = 0.10 / 0.73, -- approx 0.13699 (0.10s)
	impactRatio = 0.07 / 0.73, -- approx 0.09589 (0.07s)
	recoveryRatio = 0.42 / 0.73, -- approx 0.57534 (0.42s)
})

local ACCESSORY_RULES: { AnimationContract.AccessoryWeldRule } = table.freeze({
	{
		accessoryNamePattern = "CowboyHat",
		attachToLimb = "Head",
		offsetCFrame = CFrame.new(0, 0.60, 0) * CFrame.Angles(math.rad(-6), 0, 0),
	},
	{
		accessoryNamePattern = "AceHat",
		attachToLimb = "Head",
		offsetCFrame = CFrame.new(0, 0.60, 0) * CFrame.Angles(math.rad(-6), 0, 0),
	},
	{
		accessoryNamePattern = "Hat",
		attachToLimb = "Head",
		offsetCFrame = CFrame.new(0, 0.60, 0) * CFrame.Angles(math.rad(-6), 0, 0),
	},
	{
		accessoryNamePattern = "RedBead",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, 0.92, 0),
	},
	{
		accessoryNamePattern = "RedNeckBead",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, 0.92, 0),
	},
	{
		accessoryNamePattern = "Necklace",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, 0.92, 0),
	},
	{
		accessoryNamePattern = "HipDagger",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(-1.05, -0.85, 0) * CFrame.Angles(0, 0, math.rad(12)),
	},
	{
		accessoryNamePattern = "Dagger",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(-1.05, -0.85, 0) * CFrame.Angles(0, 0, math.rad(12)),
	},
	{
		accessoryNamePattern = "Belt",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, -0.85, 0),
	},
})

-- Human proportion invariant (1:1 scale)
local NEUTRAL_SCALE: AnimationContract.ScaleTarget = table.freeze({
	targetLimb = "Torso",
	scaleFactor = Vector3.new(1, 1, 1),
	pivotOffsetCompensation = Vector3.zero,
})

-- =============================================================================
-- 1. IDLE (1.40s — Logia Flame Finger Stance)
-- =============================================================================
-- Relaxed confidence: standing angled with weight on back leg, left hand resting on hip near
-- dagger, right hand raised at chest level playing with dancing flame flicker, subtle breathing.
local IDLE_TRACK: StateTrackDefinition = {
	state = "Idle",
	duration = 1.40,
	looped = true,
	canCancel = true,
	keyframes = {
		{
			alpha = 0.0,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			vfxCue = "PassiveAura",
			poses = {
				RootJoint = CFrame.new(0, 0.02, 0) * CFrame.Angles(0, math.rad(-12), 0),
				Neck = CFrame.Angles(math.rad(-4), math.rad(12), 0),
				RightShoulder = CFrame.new(0, 0.05, -0.25) * CFrame.Angles(math.rad(65), math.rad(-15), math.rad(12)),
				LeftShoulder = CFrame.Angles(math.rad(-18), math.rad(5), math.rad(-28)),
				RightHip = CFrame.Angles(math.rad(-10), 0, math.rad(4)),
				LeftHip = CFrame.Angles(math.rad(12), 0, math.rad(-4)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.50,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			poses = {
				RootJoint = CFrame.new(0, 0.10, 0) * CFrame.Angles(0, math.rad(-10), 0),
				Neck = CFrame.Angles(math.rad(2), math.rad(10), 0),
				RightShoulder = CFrame.new(0, 0.12, -0.25) * CFrame.Angles(math.rad(72), math.rad(-12), math.rad(16)),
				LeftShoulder = CFrame.Angles(math.rad(-15), math.rad(4), math.rad(-25)),
				RightHip = CFrame.Angles(math.rad(-8), 0, math.rad(3)),
				LeftHip = CFrame.Angles(math.rad(10), 0, math.rad(-3)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			poses = {
				RootJoint = CFrame.new(0, 0.02, 0) * CFrame.Angles(0, math.rad(-12), 0),
				Neck = CFrame.Angles(math.rad(-4), math.rad(12), 0),
				RightShoulder = CFrame.new(0, 0.05, -0.25) * CFrame.Angles(math.rad(65), math.rad(-15), math.rad(12)),
				LeftShoulder = CFrame.Angles(math.rad(-18), math.rad(5), math.rad(-28)),
				RightHip = CFrame.Angles(math.rad(-10), 0, math.rad(4)),
				LeftHip = CFrame.Angles(math.rad(12), 0, math.rad(-4)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 2. SPECIAL IDLE (1.50s — Hat Tip & Shoulder Flame Flare)
-- =============================================================================
-- Lowers head, raises right hand to grip cowboy hat brim, tips brim up with a confident smirk
-- as shoulder flames flare up, before lowering hand back to neutral.
local SPECIAL_IDLE_TRACK: StateTrackDefinition = {
	state = "SpecialIdle",
	duration = 1.50,
	looped = false,
	canCancel = true,
	keyframes = {
		{
			alpha = 0.0,
			vfxCue = "SpecialIdleCue",
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.identity,
				LeftShoulder = CFrame.identity,
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.25,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.02, 0) * CFrame.Angles(math.rad(2), math.rad(-6), 0),
				Neck = CFrame.Angles(math.rad(-14), math.rad(4), 0),
				RightShoulder = CFrame.new(-0.15, 0.25, -0.25) * CFrame.Angles(math.rad(120), math.rad(-20), math.rad(25)),
				LeftShoulder = CFrame.Angles(math.rad(-16), math.rad(5), math.rad(-24)),
				RightHip = CFrame.Angles(math.rad(-6), 0, math.rad(2)),
				LeftHip = CFrame.Angles(math.rad(6), 0, math.rad(-2)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.50,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			vfxCue = "FlameShoulderFlare",
			poses = {
				RootJoint = CFrame.new(0, 0.02, 0) * CFrame.Angles(math.rad(-4), math.rad(-8), 0),
				Neck = CFrame.Angles(math.rad(-8), math.rad(8), 0),
				RightShoulder = CFrame.new(-0.20, 0.35, -0.28) * CFrame.Angles(math.rad(140), math.rad(-25), math.rad(30)),
				LeftShoulder = CFrame.Angles(math.rad(-20), math.rad(6), math.rad(-28)),
				RightHip = CFrame.Angles(math.rad(-8), 0, math.rad(3)),
				LeftHip = CFrame.Angles(math.rad(8), 0, math.rad(-3)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.75,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.InOut,
			poses = {
				RootJoint = CFrame.Angles(math.rad(1), math.rad(-3), 0),
				Neck = CFrame.Angles(math.rad(-2), math.rad(3), 0),
				RightShoulder = CFrame.new(-0.08, 0.12, -0.10) * CFrame.Angles(math.rad(60), math.rad(-10), math.rad(15)),
				LeftShoulder = CFrame.Angles(math.rad(-10), math.rad(2), math.rad(-14)),
				RightHip = CFrame.Angles(math.rad(-3), 0, 0),
				LeftHip = CFrame.Angles(math.rad(3), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.identity,
				LeftShoulder = CFrame.identity,
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 3. SPAWN (0.75s — Fiery Landing & Blazing Flame Pillar Shockwave)
-- =============================================================================
-- Plunges down in a fiery meteor column, impacts with fist to ground sending shockwave,
-- rises up and flares arms outward as fire erupts before settling to rest.
local SPAWN_TRACK: StateTrackDefinition = {
	state = "Spawn",
	duration = 0.75,
	looped = false,
	canCancel = false,
	keyframes = {
		{
			alpha = 0.0,
			vfxCue = "SpawnDeploy",
			poses = {
				RootJoint = CFrame.new(0, 6.0, 0) * CFrame.Angles(math.rad(20), 0, 0),
				Neck = CFrame.Angles(math.rad(-15), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(-60), 0, math.rad(15)),
				LeftShoulder = CFrame.Angles(math.rad(70), 0, math.rad(-35)),
				RightHip = CFrame.Angles(math.rad(-25), 0, math.rad(8)),
				LeftHip = CFrame.Angles(math.rad(-25), 0, math.rad(-8)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.40,
			easingStyle = Enum.EasingStyle.Bounce,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.55, 0) * CFrame.Angles(math.rad(28), 0, 0),
				Neck = CFrame.Angles(math.rad(18), 0, 0),
				RightShoulder = CFrame.new(0, -0.35, -0.45) * CFrame.Angles(math.rad(-88), 0, 0),
				LeftShoulder = CFrame.Angles(math.rad(45), 0, math.rad(-45)),
				RightHip = CFrame.Angles(math.rad(50), math.rad(15), math.rad(10)),
				LeftHip = CFrame.Angles(math.rad(50), math.rad(-15), math.rad(-10)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.70,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0.25, 0) * CFrame.Angles(math.rad(-8), 0, 0),
				Neck = CFrame.Angles(math.rad(12), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(45), math.rad(20), math.rad(55)),
				LeftShoulder = CFrame.Angles(math.rad(45), math.rad(-20), math.rad(-55)),
				RightHip = CFrame.Angles(math.rad(-12), 0, math.rad(5)),
				LeftHip = CFrame.Angles(math.rad(-12), 0, math.rad(-5)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.identity,
				LeftShoulder = CFrame.identity,
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 4. ATTACK WINDUP (0.14s — Mera Mera Fire Charge & Fire-Gun Stance)
-- =============================================================================
-- Pulls right arm back behind flank coiling fiery vortex, raises left arm targeting
-- forward with index and middle finger raised in fire-gun (Higan) stance.
local WINDUP_TRACK: StateTrackDefinition = {
	state = "Windup",
	duration = 0.14,
	looped = false,
	canCancel = true,
	keyframes = {
		{
			alpha = 0.0,
			vfxCue = "AttackWindup",
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.identity,
				LeftShoulder = CFrame.identity,
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.50,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.10, 0.18) * CFrame.Angles(math.rad(4), math.rad(-28), 0),
				Neck = CFrame.Angles(math.rad(-4), math.rad(24), 0),
				RightShoulder = CFrame.new(0.20, -0.06, 0.35) * CFrame.Angles(math.rad(-28), math.rad(-30), math.rad(18)),
				LeftShoulder = CFrame.new(0, 0.04, -0.20) * CFrame.Angles(math.rad(75), math.rad(25), 0),
				RightHip = CFrame.Angles(math.rad(-15), 0, 0),
				LeftHip = CFrame.Angles(math.rad(18), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Back,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.16, 0.32) * CFrame.Angles(math.rad(6), math.rad(-48), 0),
				Neck = CFrame.Angles(math.rad(-6), math.rad(45), 0),
				RightShoulder = CFrame.new(0.35, -0.10, 0.55) * CFrame.Angles(math.rad(-42), math.rad(-42), math.rad(26)),
				LeftShoulder = CFrame.new(0, 0.08, -0.32) * CFrame.Angles(math.rad(90), math.rad(34), 0),
				RightHip = CFrame.Angles(math.rad(-24), 0, 0),
				LeftHip = CFrame.Angles(math.rad(28), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 5. ATTACK RELEASE (0.10s — Hiken: Fire Fist Thrust)
-- =============================================================================
-- Snaps right arm forward with explosive rotational hip torque, unleashing colossal
-- flame pillar punch straight down the targeting sight line.
local ATTACK_TRACK: StateTrackDefinition = {
	state = "Attack",
	duration = 0.10,
	looped = false,
	canCancel = false,
	keyframes = {
		{
			alpha = 0.0,
			vfxCue = "AttackRelease",
			poses = {
				RootJoint = CFrame.new(0, -0.16, 0.32) * CFrame.Angles(math.rad(6), math.rad(-48), 0),
				Neck = CFrame.Angles(math.rad(-6), math.rad(45), 0),
				RightShoulder = CFrame.new(0.35, -0.10, 0.55) * CFrame.Angles(math.rad(-42), math.rad(-42), math.rad(26)),
				LeftShoulder = CFrame.new(0, 0.08, -0.32) * CFrame.Angles(math.rad(90), math.rad(34), 0),
				RightHip = CFrame.Angles(math.rad(-24), 0, 0),
				LeftHip = CFrame.Angles(math.rad(28), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.40,
			easingStyle = Enum.EasingStyle.Exponential,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, -0.06, -0.35) * CFrame.Angles(math.rad(-8), math.rad(10), 0),
				Neck = CFrame.Angles(math.rad(4), math.rad(-10), 0),
				RightShoulder = CFrame.new(0, 0.06, -0.45) * CFrame.Angles(math.rad(52), math.rad(-18), 0),
				LeftShoulder = CFrame.Angles(math.rad(-15), 0, math.rad(-18)),
				RightHip = CFrame.Angles(math.rad(15), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-15), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Exponential,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.08, -0.85) * CFrame.Angles(math.rad(-16), math.rad(44), 0),
				Neck = CFrame.Angles(math.rad(8), math.rad(-40), 0),
				RightShoulder = CFrame.new(0, 0.12, -0.90) * CFrame.Angles(math.rad(94), math.rad(-34), 0),
				LeftShoulder = CFrame.Angles(math.rad(-44), 0, math.rad(-32)),
				RightHip = CFrame.Angles(math.rad(32), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-30), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 6. ATTACK IMPACT (0.07s — Hit-Stop Micro-Vibration & Detonation Hold)
-- =============================================================================
-- Fist locked at full extension emitting blinding heatwave; micro-vibration recoil
-- from catastrophic flame combustion at impact point.
local IMPACT_TRACK: StateTrackDefinition = {
	state = "Impact",
	duration = 0.07,
	looped = false,
	canCancel = false,
	keyframes = {
		{
			alpha = 0.0,
			vfxCue = "AttackImpact",
			poses = {
				RootJoint = CFrame.new(0, -0.08, -0.85) * CFrame.Angles(math.rad(-16), math.rad(44), 0),
				Neck = CFrame.Angles(math.rad(8), math.rad(-40), 0),
				RightShoulder = CFrame.new(0, 0.12, -0.90) * CFrame.Angles(math.rad(94), math.rad(-34), 0),
				LeftShoulder = CFrame.Angles(math.rad(-44), 0, math.rad(-32)),
				RightHip = CFrame.Angles(math.rad(32), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-30), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.45,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.07, -0.82) * CFrame.Angles(math.rad(-15), math.rad(42), math.rad(2)),
				Neck = CFrame.Angles(math.rad(9), math.rad(-38), math.rad(1)),
				RightShoulder = CFrame.new(0.02, 0.14, -0.87) * CFrame.Angles(math.rad(96), math.rad(-32), math.rad(2)),
				LeftShoulder = CFrame.Angles(math.rad(-42), math.rad(2), math.rad(-30)),
				RightHip = CFrame.Angles(math.rad(32), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-30), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, -0.06, -0.75) * CFrame.Angles(math.rad(-12), math.rad(38), 0),
				Neck = CFrame.Angles(math.rad(7), math.rad(-35), 0),
				RightShoulder = CFrame.new(0, 0.10, -0.78) * CFrame.Angles(math.rad(90), math.rad(-30), 0),
				LeftShoulder = CFrame.Angles(math.rad(-40), 0, math.rad(-28)),
				RightHip = CFrame.Angles(math.rad(28), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-26), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 7. ATTACK RECOVERY (0.42s — Ember Shake-Out & Zero-Drift Restitution)
-- =============================================================================
-- Retracts right arm smoothly, shakes glowing embers from knuckles and wrist,
-- restores all joint poses strictly to baseline rest pose (delta < 0.001 studs).
local RECOVERY_TRACK: StateTrackDefinition = {
	state = "Recovery",
	duration = 0.42,
	looped = false,
	canCancel = true,
	keyframes = {
		{
			alpha = 0.0,
			poses = {
				RootJoint = CFrame.new(0, -0.06, -0.75) * CFrame.Angles(math.rad(-12), math.rad(38), 0),
				Neck = CFrame.Angles(math.rad(7), math.rad(-35), 0),
				RightShoulder = CFrame.new(0, 0.10, -0.78) * CFrame.Angles(math.rad(90), math.rad(-30), 0),
				LeftShoulder = CFrame.Angles(math.rad(-40), 0, math.rad(-28)),
				RightHip = CFrame.Angles(math.rad(28), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-26), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.35,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.02, -0.20) * CFrame.Angles(math.rad(-4), math.rad(14), 0),
				Neck = CFrame.Angles(math.rad(2), math.rad(-10), 0),
				RightShoulder = CFrame.new(0, -0.05, -0.20) * CFrame.Angles(math.rad(35), math.rad(-12), math.rad(15)),
				LeftShoulder = CFrame.Angles(math.rad(-15), 0, math.rad(-15)),
				RightHip = CFrame.Angles(math.rad(10), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-10), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.70,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.InOut,
			poses = {
				RootJoint = CFrame.Angles(math.rad(1), math.rad(4), 0),
				Neck = CFrame.Angles(math.rad(1), math.rad(-2), 0),
				RightShoulder = CFrame.Angles(math.rad(12), 0, math.rad(6)),
				LeftShoulder = CFrame.Angles(math.rad(-6), 0, math.rad(-6)),
				RightHip = CFrame.Angles(math.rad(2), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-2), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.identity,
				LeftShoulder = CFrame.identity,
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 8. ULTIMATE (2.20s — Dai Enkai: Entei [Great Flame Commandment: Flame Emperor])
-- =============================================================================
-- Phase 1 (0.00-0.45s): Commands spiral fire vortex, raises right arm high overhead creating colossal sunball.
-- Phase 2 (0.45-0.65s): Leaps/lunges forward hurling the miniature sun downward in apocalyptic plunge.
-- Phase 3 (0.65-2.20s): Follow-through as ground ignites into thermonuclear sea of flames, returns to rest.
local ULTIMATE_TRACK: StateTrackDefinition = {
	state = "Ultimate",
	duration = 2.20,
	looped = false,
	canCancel = false,
	keyframes = {
		{
			alpha = 0.0,
			vfxCue = "UltimateCast",
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.identity,
				LeftShoulder = CFrame.identity,
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.20,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0.25, 0) * CFrame.Angles(math.rad(6), 0, 0),
				Neck = CFrame.Angles(math.rad(8), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(50), 0, math.rad(50)),
				LeftShoulder = CFrame.Angles(math.rad(50), 0, math.rad(-50)),
				RightHip = CFrame.Angles(math.rad(-10), 0, math.rad(6)),
				LeftHip = CFrame.Angles(math.rad(-10), 0, math.rad(-6)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.45,
			easingStyle = Enum.EasingStyle.Cubic,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0.85, 0) * CFrame.Angles(math.rad(14), 0, 0),
				Neck = CFrame.Angles(math.rad(38), 0, 0),
				RightShoulder = CFrame.new(0, 0.45, 0) * CFrame.Angles(math.rad(176), 0, math.rad(8)),
				LeftShoulder = CFrame.Angles(math.rad(35), 0, math.rad(-55)),
				RightHip = CFrame.Angles(math.rad(-18), 0, math.rad(4)),
				LeftHip = CFrame.Angles(math.rad(-12), 0, math.rad(-4)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.65,
			easingStyle = Enum.EasingStyle.Exponential,
			easingDirection = Enum.EasingDirection.In,
			vfxCue = "UltimateImpact",
			poses = {
				RootJoint = CFrame.new(0, 0.20, -0.90) * CFrame.Angles(math.rad(-26), math.rad(36), 0),
				Neck = CFrame.Angles(math.rad(-14), math.rad(-30), 0),
				RightShoulder = CFrame.new(0, 0.10, -0.85) * CFrame.Angles(math.rad(74), 0, 0),
				LeftShoulder = CFrame.Angles(math.rad(-45), 0, math.rad(-35)),
				RightHip = CFrame.Angles(math.rad(35), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-30), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.85,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0.05, -0.30) * CFrame.Angles(math.rad(-8), math.rad(14), 0),
				Neck = CFrame.Angles(math.rad(2), math.rad(-10), 0),
				RightShoulder = CFrame.Angles(math.rad(38), 0, math.rad(12)),
				LeftShoulder = CFrame.Angles(math.rad(-20), 0, math.rad(-15)),
				RightHip = CFrame.Angles(math.rad(10), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-8), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.identity,
				LeftShoulder = CFrame.identity,
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 9. DESPAWN (0.80s — Hat Tip & Ember Dissolve)
-- =============================================================================
-- Offers a farewell tip of the hat with relaxed confidence, then dissolves cleanly
-- into floating embers and curling smoke.
local DESPAWN_TRACK: StateTrackDefinition = {
	state = "Despawn" :: any,
	duration = 0.80,
	looped = false,
	canCancel = false,
	keyframes = {
		{
			alpha = 0.0,
			vfxCue = "DespawnEmbers",
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.identity,
				LeftShoulder = CFrame.identity,
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.40,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.Angles(math.rad(2), math.rad(-4), 0),
				Neck = CFrame.Angles(math.rad(-14), math.rad(2), 0),
				RightShoulder = CFrame.new(-0.20, 0.28, -0.28) * CFrame.Angles(math.rad(132), math.rad(-22), math.rad(28)),
				LeftShoulder = CFrame.Angles(math.rad(-12), 0, math.rad(-16)),
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.75,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			poses = {
				RootJoint = CFrame.new(0, 0.35, 0) * CFrame.Angles(math.rad(-4), 0, 0),
				Neck = CFrame.Angles(math.rad(-8), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(80), math.rad(-10), math.rad(20)),
				LeftShoulder = CFrame.Angles(math.rad(40), 0, math.rad(-25)),
				RightHip = CFrame.Angles(math.rad(8), 0, 0),
				LeftHip = CFrame.Angles(math.rad(8), 0, 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.identity,
				LeftShoulder = CFrame.identity,
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- PROFILE ASSEMBLY WITH FULL CANONICAL & ALIAS SUPPORT
-- =============================================================================

local statesTable: { [string]: StateTrackDefinition } = {
	-- Canonical AnimationContract states
	Idle = IDLE_TRACK,
	SpecialIdle = SPECIAL_IDLE_TRACK,
	Spawn = SPAWN_TRACK,
	Windup = WINDUP_TRACK,
	Attack = ATTACK_TRACK,
	Impact = IMPACT_TRACK,
	Recovery = RECOVERY_TRACK,
	Ultimate = ULTIMATE_TRACK,
	Despawn = DESPAWN_TRACK,

	-- Canonical Dispatch & Extended aliases
	AttackWindup = WINDUP_TRACK,
	AttackRelease = ATTACK_TRACK,
	AttackImpact = IMPACT_TRACK,
	AttackRecover = RECOVERY_TRACK,
	UltimateCast = ULTIMATE_TRACK,
	SpawnDeploy = SPAWN_TRACK,
}

local AceProfile: CharacterAnimationProfile = {
	heroId = "Ace",
	displayName = "Portgas D. Ace [Flame Emperor]",
	contractVersion = "5.0.0",
	rigType = "Articulated6Joint",
	expectedJoints = AnimationContract.BODY_JOINTS,
	accessoryRules = ACCESSORY_RULES,
	baseScale = 1.0,
	attackCycleTimings = ATTACK_TIMINGS,
	states = statesTable :: any,
}

-- Direct factory constructor for dynamic instantiation
(AceProfile :: any).CreateProfile = function(): CharacterAnimationProfile
	return AceProfile
end

return table.freeze(AceProfile :: any)
