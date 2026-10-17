--!strict
-- src/Track2_TowerSystem/Animations/Zoro.luau
-- Anime Limitless Tower Defense — Phase 5 Roronoa Zoro [King of Hell] Signature Animation Profile
-- Implements Task Z-02: Complete 8-State (+ Despawn) Profile with 9-Joint Santoryu Kinematics,
-- 3-Blade Cross Slash Coordination, Nominal Combat Hit Timing (0.31s hit / 0.73s cycle),
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
	error("[Zoro.luau] Failed to load AnimationContract")
end)() :: any

type AnimationState = AnimationContract.AnimationState
type StateTrackDefinition = AnimationContract.StateTrackDefinition
type ProceduralKeyframe = AnimationContract.ProceduralKeyframe
type CharacterAnimationProfile = AnimationContract.CharacterAnimationProfile

-- =============================================================================
-- SANTORYU COMBAT TIMINGS & ACCESSORY RULES
-- =============================================================================

-- Combat cycle timings strictly locked to 0.31s nominal hit impact (0.14s + 0.10s + 0.07s)
-- Total attack cycle duration = 0.14s + 0.10s + 0.07s + 0.42s = 0.73s
local ATTACK_TIMINGS: AnimationContract.AttackCycleTimings = table.freeze({
	windupRatio = 0.14 / 0.73, -- approx 0.19178 (0.14s)
	attackRatio = 0.10 / 0.73, -- approx 0.13699 (0.10s)
	impactRatio = 0.07 / 0.73, -- approx 0.09589 (0.07s)
	recoveryRatio = 0.42 / 0.73, -- approx 0.57534 (0.42s)
})

local ACCESSORY_RULES: { AnimationContract.AccessoryWeldRule } = table.freeze({
	{
		accessoryNamePattern = "BlackBandana",
		attachToLimb = "Head",
		offsetCFrame = CFrame.new(0, 0.45, 0),
	},
	{
		accessoryNamePattern = "Bandana",
		attachToLimb = "Head",
		offsetCFrame = CFrame.new(0, 0.45, 0),
	},
	{
		accessoryNamePattern = "Hair",
		attachToLimb = "Head",
		offsetCFrame = CFrame.new(0, 0.65, 0),
	},
	{
		accessoryNamePattern = "Haramaki",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, -0.65, 0),
	},
	{
		accessoryNamePattern = "Sash",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, -0.65, 0),
	},
	{
		accessoryNamePattern = "CoatSkirt",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, -1.05, 0),
	},
	{
		accessoryNamePattern = "Scabbard",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0.95, -0.65, 0.25) * CFrame.Angles(0, math.rad(-15), math.rad(-25)),
	},
	{
		accessoryNamePattern = "MihawkChestScar",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, 0.15, -0.52),
	},
	{
		accessoryNamePattern = "BareChestDiagonal",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, 0.15, -0.52),
	},
	{
		accessoryNamePattern = "Enma",
		attachToLimb = "RightArm",
		offsetCFrame = CFrame.new(0, -1.0, -0.2) * CFrame.Angles(math.rad(-90), 0, 0),
		useMotor6D = true,
		jointName = "WeaponRight",
	},
	{
		accessoryNamePattern = "Sandai",
		attachToLimb = "LeftArm",
		offsetCFrame = CFrame.new(0, -1.0, -0.2) * CFrame.Angles(math.rad(-90), 0, 0),
		useMotor6D = true,
		jointName = "WeaponLeft",
	},
	{
		accessoryNamePattern = "Wado",
		attachToLimb = "Head",
		offsetCFrame = CFrame.new(0, -0.25, -0.55) * CFrame.Angles(0, 0, math.rad(90)),
		useMotor6D = true,
		jointName = "WeaponMouth",
	},
})

-- Common scale target preserving 1:1 human proportions
local NEUTRAL_SCALE: AnimationContract.ScaleTarget = table.freeze({
	targetLimb = "Torso",
	scaleFactor = Vector3.new(1, 1, 1),
	pivotOffsetCompensation = Vector3.zero,
})

-- =============================================================================
-- 1. IDLE (Santoryu 3-Sword Guard Stance)
-- =============================================================================
-- Crouch guard stance with Enma & Sandai angled forward, Wado held firmly in jaw,
-- rhythmic breathing oscillation, and slight blade gleam angle.
local IDLE_TRACK: StateTrackDefinition = {
	state = "Idle",
	duration = 1.50,
	looped = true,
	canCancel = true,
	keyframes = {
		{
			alpha = 0.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			vfxCue = "PassiveAura",
			poses = {
				RootJoint = CFrame.new(0, -0.15, 0) * CFrame.Angles(0, math.rad(18), 0),
				Neck = CFrame.Angles(math.rad(2), math.rad(-16), 0),
				RightShoulder = CFrame.Angles(math.rad(18), math.rad(-12), math.rad(22)),
				LeftShoulder = CFrame.Angles(math.rad(-14), math.rad(12), math.rad(-22)),
				RightHip = CFrame.Angles(math.rad(14), math.rad(-8), math.rad(4)),
				LeftHip = CFrame.Angles(math.rad(-12), math.rad(8), math.rad(-4)),
				WeaponRight = CFrame.Angles(math.rad(12), 0, math.rad(-18)),
				WeaponLeft = CFrame.Angles(math.rad(12), 0, math.rad(18)),
				WeaponMouth = CFrame.Angles(0, 0, math.rad(4)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.30,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			poses = {
				RootJoint = CFrame.new(0, -0.10, 0) * CFrame.Angles(math.rad(1), math.rad(19), 0),
				Neck = CFrame.Angles(math.rad(3), math.rad(-17), 0),
				RightShoulder = CFrame.Angles(math.rad(22), math.rad(-10), math.rad(24)),
				LeftShoulder = CFrame.Angles(math.rad(-10), math.rad(10), math.rad(-24)),
				RightHip = CFrame.Angles(math.rad(12), math.rad(-8), math.rad(4)),
				LeftHip = CFrame.Angles(math.rad(-10), math.rad(8), math.rad(-4)),
				WeaponRight = CFrame.Angles(math.rad(15), 0, math.rad(-16)),
				WeaponLeft = CFrame.Angles(math.rad(15), 0, math.rad(16)),
				WeaponMouth = CFrame.Angles(0, 0, math.rad(5)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.65,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			poses = {
				RootJoint = CFrame.new(0, -0.13, 0) * CFrame.Angles(math.rad(-1), math.rad(17), 0),
				Neck = CFrame.Angles(math.rad(1), math.rad(-15), 0),
				RightShoulder = CFrame.Angles(math.rad(16), math.rad(-14), math.rad(20)),
				LeftShoulder = CFrame.Angles(math.rad(-16), math.rad(14), math.rad(-20)),
				RightHip = CFrame.Angles(math.rad(15), math.rad(-8), math.rad(4)),
				LeftHip = CFrame.Angles(math.rad(-13), math.rad(8), math.rad(-4)),
				WeaponRight = CFrame.Angles(math.rad(10), 0, math.rad(-20)),
				WeaponLeft = CFrame.Angles(math.rad(10), 0, math.rad(20)),
				WeaponMouth = CFrame.Angles(0, 0, math.rad(3)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, -0.15, 0) * CFrame.Angles(0, math.rad(18), 0),
				Neck = CFrame.Angles(math.rad(2), math.rad(-16), 0),
				RightShoulder = CFrame.Angles(math.rad(18), math.rad(-12), math.rad(22)),
				LeftShoulder = CFrame.Angles(math.rad(-14), math.rad(12), math.rad(-22)),
				RightHip = CFrame.Angles(math.rad(14), math.rad(-8), math.rad(4)),
				LeftHip = CFrame.Angles(math.rad(-12), math.rad(8), math.rad(-4)),
				WeaponRight = CFrame.Angles(math.rad(12), 0, math.rad(-18)),
				WeaponLeft = CFrame.Angles(math.rad(12), 0, math.rad(18)),
				WeaponMouth = CFrame.Angles(0, 0, math.rad(4)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 2. SPECIAL IDLE (1.60s — Enma Haki Tame & Bandana Tighten)
-- =============================================================================
-- Raises right arm holding Enma upright, channels King of Hell emerald/purple flame,
-- tightens grip, and flourishes blade downward returning smoothly to rest pose.
local SPECIAL_IDLE_TRACK: StateTrackDefinition = {
	state = "SpecialIdle",
	duration = 1.60,
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
				WeaponRight = CFrame.identity,
				WeaponLeft = CFrame.identity,
				WeaponMouth = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.28,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.Angles(math.rad(-4), math.rad(-10), 0),
				Neck = CFrame.Angles(math.rad(-8), math.rad(12), 0),
				RightShoulder = CFrame.new(0.1, 0.3, -0.2) * CFrame.Angles(math.rad(85), math.rad(-25), math.rad(18)),
				LeftShoulder = CFrame.Angles(math.rad(-15), math.rad(15), math.rad(-18)),
				RightHip = CFrame.Angles(math.rad(-6), 0, 0),
				LeftHip = CFrame.Angles(math.rad(6), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(65), math.rad(15), math.rad(-10)),
				WeaponLeft = CFrame.Angles(math.rad(-10), 0, 0),
				WeaponMouth = CFrame.Angles(0, 0, math.rad(2)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.55,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			vfxCue = "EnmaChargePulse",
			poses = {
				RootJoint = CFrame.Angles(math.rad(-6), math.rad(-12), 0),
				Neck = CFrame.Angles(math.rad(-12), math.rad(15), 0),
				RightShoulder = CFrame.new(0.15, 0.35, -0.25) * CFrame.Angles(math.rad(95), math.rad(-28), math.rad(22)),
				LeftShoulder = CFrame.Angles(math.rad(-20), math.rad(20), math.rad(-22)),
				RightHip = CFrame.Angles(math.rad(-8), 0, 0),
				LeftHip = CFrame.Angles(math.rad(8), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(75), math.rad(20), math.rad(-15)),
				WeaponLeft = CFrame.Angles(math.rad(-15), 0, 0),
				WeaponMouth = CFrame.Angles(0, 0, math.rad(4)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.80,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.Angles(math.rad(2), 0, 0),
				Neck = CFrame.Angles(math.rad(2), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(15), 0, math.rad(10)),
				LeftShoulder = CFrame.Angles(math.rad(-10), 0, math.rad(-10)),
				RightHip = CFrame.Angles(math.rad(2), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-2), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(-20), 0, math.rad(10)),
				WeaponLeft = CFrame.identity,
				WeaponMouth = CFrame.identity,
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
				WeaponRight = CFrame.identity,
				WeaponLeft = CFrame.identity,
				WeaponMouth = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 3. SPAWN (0.60s — Dash Slide Stop & Three-Sword Unsheathe)
-- =============================================================================
-- High-speed slide braking stop on placement pad, explosive dual cross-draw unsheathe
-- into an X-Cross pose with sword gleam, snapping into solid rest pose.
local SPAWN_TRACK: StateTrackDefinition = {
	state = "Spawn",
	duration = 0.60,
	looped = false,
	canCancel = false,
	keyframes = {
		{
			alpha = 0.0,
			vfxCue = "SpawnDeploy",
			poses = {
				RootJoint = CFrame.new(0, 0, 3.5) * CFrame.Angles(math.rad(-18), 0, 0),
				Neck = CFrame.Angles(math.rad(15), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(-45), 0, math.rad(15)),
				LeftShoulder = CFrame.Angles(math.rad(-45), 0, math.rad(-15)),
				RightHip = CFrame.Angles(math.rad(-25), 0, 0),
				LeftHip = CFrame.Angles(math.rad(25), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(-30), 0, 0),
				WeaponLeft = CFrame.Angles(math.rad(-30), 0, 0),
				WeaponMouth = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.40,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.30, 0.4) * CFrame.Angles(math.rad(10), 0, 0),
				Neck = CFrame.Angles(math.rad(-8), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(20), math.rad(-35), math.rad(15)),
				LeftShoulder = CFrame.Angles(math.rad(20), math.rad(35), math.rad(-15)),
				RightHip = CFrame.Angles(math.rad(30), math.rad(10), 0),
				LeftHip = CFrame.Angles(math.rad(-20), math.rad(-10), 0),
				WeaponRight = CFrame.Angles(math.rad(20), 0, math.rad(-25)),
				WeaponLeft = CFrame.Angles(math.rad(20), 0, math.rad(25)),
				WeaponMouth = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.70,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0.05, 0) * CFrame.Angles(math.rad(-4), 0, 0),
				Neck = CFrame.Angles(math.rad(4), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(75), math.rad(-25), math.rad(45)),
				LeftShoulder = CFrame.Angles(math.rad(75), math.rad(25), math.rad(-45)),
				RightHip = CFrame.Angles(math.rad(-5), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-5), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(-45), 0, math.rad(35)),
				WeaponLeft = CFrame.Angles(math.rad(-45), 0, math.rad(-35)),
				WeaponMouth = CFrame.Angles(0, 0, math.rad(5)),
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
				WeaponRight = CFrame.identity,
				WeaponLeft = CFrame.identity,
				WeaponMouth = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 4. ATTACK WINDUP (0.14s — Oni Giri Cross-Arm Stance)
-- =============================================================================
-- Nominal combat timing Phase 1: 0.14s.
-- Torso crouch coil, dual arms cross tightly over chest, blades turned back over shoulders,
-- neck lowered gripping Wado Ichimonji tightly.
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
				WeaponRight = CFrame.identity,
				WeaponLeft = CFrame.identity,
				WeaponMouth = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.50,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.18, 0.1) * CFrame.Angles(math.rad(-10), math.rad(-10), 0),
				Neck = CFrame.Angles(math.rad(-6), math.rad(10), 0),
				RightShoulder = CFrame.new(-0.15, 0.08, 0.25) * CFrame.Angles(math.rad(40), math.rad(-35), math.rad(22)),
				LeftShoulder = CFrame.new(0.15, 0.08, 0.25) * CFrame.Angles(math.rad(40), math.rad(35), math.rad(-22)),
				RightHip = CFrame.Angles(math.rad(-10), math.rad(6), 0),
				LeftHip = CFrame.Angles(math.rad(12), math.rad(-6), 0),
				WeaponRight = CFrame.Angles(math.rad(-45), math.rad(15), math.rad(-25)),
				WeaponLeft = CFrame.Angles(math.rad(-45), math.rad(-15), math.rad(25)),
				WeaponMouth = CFrame.Angles(0, math.rad(8), 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, -0.35, 0.25) * CFrame.Angles(math.rad(-18), math.rad(-22), 0),
				Neck = CFrame.Angles(math.rad(-12), math.rad(20), 0),
				RightShoulder = CFrame.new(-0.35, 0.15, 0.5) * CFrame.Angles(math.rad(70), math.rad(-55), math.rad(38)),
				LeftShoulder = CFrame.new(0.35, 0.15, 0.5) * CFrame.Angles(math.rad(70), math.rad(55), math.rad(-38)),
				RightHip = CFrame.Angles(math.rad(-20), math.rad(12), 0),
				LeftHip = CFrame.Angles(math.rad(24), math.rad(-12), 0),
				WeaponRight = CFrame.Angles(math.rad(-80), math.rad(25), math.rad(-45)),
				WeaponLeft = CFrame.Angles(math.rad(-80), math.rad(-25), math.rad(45)),
				WeaponMouth = CFrame.Angles(0, math.rad(16), 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 5. ATTACK RELEASE (0.10s — Oni Giri Explosive Cross-Slash Dash)
-- =============================================================================
-- Nominal combat timing Phase 2: 0.10s.
-- Lunges forward 1.8 studs, dual arms snap outward with high angular velocity,
-- head snaps driving mouth blade across target, creating triple-blade cross slash arc.
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
				RootJoint = CFrame.new(0, -0.35, 0.25) * CFrame.Angles(math.rad(-18), math.rad(-22), 0),
				Neck = CFrame.Angles(math.rad(-12), math.rad(20), 0),
				RightShoulder = CFrame.new(-0.35, 0.15, 0.5) * CFrame.Angles(math.rad(70), math.rad(-55), math.rad(38)),
				LeftShoulder = CFrame.new(0.35, 0.15, 0.5) * CFrame.Angles(math.rad(70), math.rad(55), math.rad(-38)),
				RightHip = CFrame.Angles(math.rad(-20), math.rad(12), 0),
				LeftHip = CFrame.Angles(math.rad(24), math.rad(-12), 0),
				WeaponRight = CFrame.Angles(math.rad(-80), math.rad(25), math.rad(-45)),
				WeaponLeft = CFrame.Angles(math.rad(-80), math.rad(-25), math.rad(45)),
				WeaponMouth = CFrame.Angles(0, math.rad(16), 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.40,
			easingStyle = Enum.EasingStyle.Exponential,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, 0, -0.9) * CFrame.Angles(math.rad(8), math.rad(5), 0),
				Neck = CFrame.Angles(math.rad(4), math.rad(-10), 0),
				RightShoulder = CFrame.new(0.2, 0, -0.4) * CFrame.Angles(math.rad(-30), math.rad(25), math.rad(15)),
				LeftShoulder = CFrame.new(-0.2, 0, -0.4) * CFrame.Angles(math.rad(-30), math.rad(-25), math.rad(-15)),
				RightHip = CFrame.Angles(math.rad(20), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-20), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(10), 0, math.rad(30)),
				WeaponLeft = CFrame.Angles(math.rad(10), 0, math.rad(-30)),
				WeaponMouth = CFrame.Angles(0, math.rad(-10), math.rad(6)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Exponential,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, 0, -1.8) * CFrame.Angles(math.rad(22), math.rad(18), 0),
				Neck = CFrame.Angles(math.rad(14), math.rad(-25), math.rad(8)),
				RightShoulder = CFrame.new(0.45, -0.1, -0.85) * CFrame.Angles(math.rad(-82), math.rad(65), math.rad(-18)),
				LeftShoulder = CFrame.new(-0.45, -0.1, -0.85) * CFrame.Angles(math.rad(-82), math.rad(-65), math.rad(18)),
				RightHip = CFrame.Angles(math.rad(36), math.rad(8), 0),
				LeftHip = CFrame.Angles(math.rad(-34), math.rad(-8), 0),
				WeaponRight = CFrame.Angles(math.rad(25), math.rad(-15), math.rad(85)),
				WeaponLeft = CFrame.Angles(math.rad(25), math.rad(15), math.rad(-85)),
				WeaponMouth = CFrame.Angles(0, math.rad(-30), math.rad(14)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 6. ATTACK IMPACT (0.07s — Triple Blade Strike Impact Hit-Stop)
-- =============================================================================
-- Nominal combat timing Phase 3: 0.07s (0.14s + 0.10s + 0.07s = 0.31s nominal combat hit timing).
-- Razor-sharp hit-stop freeze with micro-vibration recoil, follow-through cross slash pose.
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
				RootJoint = CFrame.new(0, 0, -1.8) * CFrame.Angles(math.rad(22), math.rad(18), 0),
				Neck = CFrame.Angles(math.rad(14), math.rad(-25), math.rad(8)),
				RightShoulder = CFrame.new(0.45, -0.1, -0.85) * CFrame.Angles(math.rad(-82), math.rad(65), math.rad(-18)),
				LeftShoulder = CFrame.new(-0.45, -0.1, -0.85) * CFrame.Angles(math.rad(-82), math.rad(-65), math.rad(18)),
				RightHip = CFrame.Angles(math.rad(36), math.rad(8), 0),
				LeftHip = CFrame.Angles(math.rad(-34), math.rad(-8), 0),
				WeaponRight = CFrame.Angles(math.rad(25), math.rad(-15), math.rad(85)),
				WeaponLeft = CFrame.Angles(math.rad(25), math.rad(15), math.rad(-85)),
				WeaponMouth = CFrame.Angles(0, math.rad(-30), math.rad(14)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.45,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0.04, -1.76) * CFrame.Angles(math.rad(23), math.rad(17), math.rad(2)),
				Neck = CFrame.Angles(math.rad(16), math.rad(-24), math.rad(9)),
				RightShoulder = CFrame.new(0.46, -0.08, -0.82) * CFrame.Angles(math.rad(-84), math.rad(67), math.rad(-16)),
				LeftShoulder = CFrame.new(-0.46, -0.08, -0.82) * CFrame.Angles(math.rad(-84), math.rad(-67), math.rad(16)),
				RightHip = CFrame.Angles(math.rad(36), math.rad(8), 0),
				LeftHip = CFrame.Angles(math.rad(-34), math.rad(-8), 0),
				WeaponRight = CFrame.Angles(math.rad(28), math.rad(-14), math.rad(88)),
				WeaponLeft = CFrame.Angles(math.rad(28), math.rad(14), math.rad(-88)),
				WeaponMouth = CFrame.Angles(0, math.rad(-32), math.rad(16)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, 0, -1.78) * CFrame.Angles(math.rad(21), math.rad(16), 0),
				Neck = CFrame.Angles(math.rad(14), math.rad(-25), math.rad(8)),
				RightShoulder = CFrame.new(0.45, -0.1, -0.85) * CFrame.Angles(math.rad(-82), math.rad(65), math.rad(-18)),
				LeftShoulder = CFrame.new(-0.45, -0.1, -0.85) * CFrame.Angles(math.rad(-82), math.rad(-65), math.rad(18)),
				RightHip = CFrame.Angles(math.rad(36), math.rad(8), 0),
				LeftHip = CFrame.Angles(math.rad(-34), math.rad(-8), 0),
				WeaponRight = CFrame.Angles(math.rad(25), math.rad(-15), math.rad(85)),
				WeaponLeft = CFrame.Angles(math.rad(25), math.rad(15), math.rad(-85)),
				WeaponMouth = CFrame.Angles(0, math.rad(-30), math.rad(14)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 7. ATTACK RECOVER (0.42s — Fluid Sword Flourish & Zero-Drift Restitution)
-- =============================================================================
-- Completes total combat attack cycle duration: 0.14s + 0.10s + 0.07s + 0.42s = 0.73s.
-- Rolls wrists in a crisp circular flourish, steps back to baseline position,
-- and strictly restores all 9 joints to identity rest pose (delta < 0.001 studs).
local RECOVERY_TRACK: StateTrackDefinition = {
	state = "Recovery",
	duration = 0.42,
	looped = false,
	canCancel = true,
	keyframes = {
		{
			alpha = 0.0,
			poses = {
				RootJoint = CFrame.new(0, 0, -1.78) * CFrame.Angles(math.rad(21), math.rad(16), 0),
				Neck = CFrame.Angles(math.rad(14), math.rad(-25), math.rad(8)),
				RightShoulder = CFrame.new(0.45, -0.1, -0.85) * CFrame.Angles(math.rad(-82), math.rad(65), math.rad(-18)),
				LeftShoulder = CFrame.new(-0.45, -0.1, -0.85) * CFrame.Angles(math.rad(-82), math.rad(-65), math.rad(18)),
				RightHip = CFrame.Angles(math.rad(36), math.rad(8), 0),
				LeftHip = CFrame.Angles(math.rad(-34), math.rad(-8), 0),
				WeaponRight = CFrame.Angles(math.rad(25), math.rad(-15), math.rad(85)),
				WeaponLeft = CFrame.Angles(math.rad(25), math.rad(15), math.rad(-85)),
				WeaponMouth = CFrame.Angles(0, math.rad(-30), math.rad(14)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.35,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(6), math.rad(5), 0),
				Neck = CFrame.Angles(math.rad(-4), math.rad(8), 0),
				RightShoulder = CFrame.new(0.2, 0.1, -0.2) * CFrame.Angles(math.rad(10), math.rad(15), math.rad(25)),
				LeftShoulder = CFrame.new(-0.2, 0.1, -0.2) * CFrame.Angles(math.rad(10), math.rad(-15), math.rad(-25)),
				RightHip = CFrame.Angles(math.rad(12), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-12), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(-50), math.rad(35), math.rad(20)),
				WeaponLeft = CFrame.Angles(math.rad(-50), math.rad(-35), math.rad(-20)),
				WeaponMouth = CFrame.Angles(0, math.rad(-5), 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.70,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.04, 0) * CFrame.Angles(math.rad(2), 0, 0),
				Neck = CFrame.Angles(math.rad(2), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(6), 0, math.rad(6)),
				LeftShoulder = CFrame.Angles(math.rad(-4), 0, math.rad(-6)),
				RightHip = CFrame.Angles(math.rad(-2), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-2), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(5), 0, 0),
				WeaponLeft = CFrame.Angles(math.rad(5), 0, 0),
				WeaponMouth = CFrame.identity,
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
				WeaponRight = CFrame.identity,
				WeaponLeft = CFrame.identity,
				WeaponMouth = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 8. ULTIMATE (2.10s — King of Hell: 103 Mercies Dragon Damnation)
-- =============================================================================
-- Phase 1 (0.0-0.65s): King of Hell Awakening (triple guard, emerald Haki flame ignition).
-- Phase 2 (0.65-1.25s): 720-degree whirlwind leaping spin with triple slash barrier.
-- Phase 3 (1.25-1.65s): Dragon Damnation execution plunge downward with massive shockwave.
-- Phase 4 (1.65-2.10s): Sheathe follow-through pose and restitution back to identity (delta < 0.001).
local ULTIMATE_TRACK: StateTrackDefinition = {
	state = "Ultimate",
	duration = 2.10,
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
				WeaponRight = CFrame.identity,
				WeaponLeft = CFrame.identity,
				WeaponMouth = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.20,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.4, 0) * CFrame.Angles(math.rad(-15), 0, 0),
				Neck = CFrame.Angles(math.rad(18), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(45), math.rad(-20), math.rad(20)),
				LeftShoulder = CFrame.Angles(math.rad(45), math.rad(20), math.rad(-20)),
				RightHip = CFrame.Angles(math.rad(25), 0, 0),
				LeftHip = CFrame.Angles(math.rad(25), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(40), 0, math.rad(-30)),
				WeaponLeft = CFrame.Angles(math.rad(40), 0, math.rad(30)),
				WeaponMouth = CFrame.Angles(0, 0, math.rad(8)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.45,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, 3.8, -0.6) * CFrame.Angles(math.rad(-10), math.rad(180), 0),
				Neck = CFrame.Angles(math.rad(-10), math.rad(15), 0),
				RightShoulder = CFrame.Angles(math.rad(120), math.rad(-30), math.rad(45)),
				LeftShoulder = CFrame.Angles(math.rad(120), math.rad(30), math.rad(-45)),
				RightHip = CFrame.Angles(math.rad(-20), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-20), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(-60), 0, math.rad(45)),
				WeaponLeft = CFrame.Angles(math.rad(-60), 0, math.rad(-45)),
				WeaponMouth = CFrame.Angles(0, math.rad(-20), 0),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.65,
			easingStyle = Enum.EasingStyle.Exponential,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, 5.5, -1.2) * CFrame.Angles(math.rad(-15), math.rad(360), 0),
				Neck = CFrame.Angles(math.rad(-15), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(165), math.rad(10), math.rad(20)),
				LeftShoulder = CFrame.Angles(math.rad(165), math.rad(-10), math.rad(-20)),
				RightHip = CFrame.Angles(math.rad(-25), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-25), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(-75), 0, 0),
				WeaponLeft = CFrame.Angles(math.rad(-75), 0, 0),
				WeaponMouth = CFrame.Angles(0, 0, math.rad(-10)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.75,
			easingStyle = Enum.EasingStyle.Exponential,
			easingDirection = Enum.EasingDirection.In,
			vfxCue = "UltimateImpact",
			poses = {
				RootJoint = CFrame.new(0, -0.3, -2.4) * CFrame.Angles(math.rad(38), 0, 0),
				Neck = CFrame.Angles(math.rad(-22), 0, 0),
				RightShoulder = CFrame.new(0.3, -0.5, -1.2) * CFrame.Angles(math.rad(-95), math.rad(40), 0),
				LeftShoulder = CFrame.new(-0.3, -0.5, -1.2) * CFrame.Angles(math.rad(-95), math.rad(-40), 0),
				RightHip = CFrame.Angles(math.rad(35), 0, 0),
				LeftHip = CFrame.Angles(math.rad(35), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(45), 0, math.rad(65)),
				WeaponLeft = CFrame.Angles(math.rad(45), 0, math.rad(-65)),
				WeaponMouth = CFrame.Angles(0, math.rad(-35), math.rad(20)),
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.90,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0.1, -0.4) * CFrame.Angles(math.rad(6), math.rad(-25), 0),
				Neck = CFrame.Angles(math.rad(4), math.rad(20), 0),
				RightShoulder = CFrame.Angles(math.rad(15), 0, math.rad(12)),
				LeftShoulder = CFrame.Angles(math.rad(-15), 0, math.rad(-12)),
				RightHip = CFrame.Angles(math.rad(5), 0, 0),
				LeftHip = CFrame.Angles(math.rad(5), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(-20), 0, 0),
				WeaponLeft = CFrame.Angles(math.rad(-20), 0, 0),
				WeaponMouth = CFrame.identity,
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
				WeaponRight = CFrame.identity,
				WeaponLeft = CFrame.identity,
				WeaponMouth = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
	},
}

-- =============================================================================
-- 9. DESPAWN (0.80s — Sheathing & Vanishing Smoke Step)
-- =============================================================================
-- Rapid sheathing click, pivots sideways, vanishes in smoke step, resetting to identity.
local DESPAWN_TRACK: StateTrackDefinition = {
	state = "Despawn" :: any,
	duration = 0.80,
	looped = false,
	canCancel = false,
	keyframes = {
		{
			alpha = 0.0,
			vfxCue = "DespawnSmoke",
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.identity,
				LeftShoulder = CFrame.identity,
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
				WeaponRight = CFrame.identity,
				WeaponLeft = CFrame.identity,
				WeaponMouth = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.40,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.Angles(0, math.rad(-45), 0),
				Neck = CFrame.Angles(math.rad(-5), math.rad(35), 0),
				RightShoulder = CFrame.Angles(math.rad(-30), math.rad(20), math.rad(15)),
				LeftShoulder = CFrame.Angles(math.rad(-30), math.rad(-20), math.rad(-15)),
				RightHip = CFrame.Angles(math.rad(-5), 0, 0),
				LeftHip = CFrame.Angles(math.rad(5), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(-60), 0, 0),
				WeaponLeft = CFrame.Angles(math.rad(-60), 0, 0),
				WeaponMouth = CFrame.identity,
			},
			scaleTarget = NEUTRAL_SCALE,
		},
		{
			alpha = 0.75,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, 1.2, -1.5) * CFrame.Angles(math.rad(15), math.rad(-45), 0),
				Neck = CFrame.Angles(math.rad(10), math.rad(30), 0),
				RightShoulder = CFrame.Angles(math.rad(-50), 0, 0),
				LeftShoulder = CFrame.Angles(math.rad(-50), 0, 0),
				RightHip = CFrame.Angles(math.rad(15), 0, 0),
				LeftHip = CFrame.Angles(math.rad(15), 0, 0),
				WeaponRight = CFrame.Angles(math.rad(-70), 0, 0),
				WeaponLeft = CFrame.Angles(math.rad(-70), 0, 0),
				WeaponMouth = CFrame.identity,
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
				WeaponRight = CFrame.identity,
				WeaponLeft = CFrame.identity,
				WeaponMouth = CFrame.identity,
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

local ZoroProfile: CharacterAnimationProfile = {
	heroId = "Zoro",
	displayName = "Roronoa Zoro [King of Hell]",
	contractVersion = "5.0.0",
	rigType = "ArticulatedWeaponRig",
	expectedJoints = AnimationContract.CANONICAL_JOINTS,
	accessoryRules = ACCESSORY_RULES,
	baseScale = 1.0,
	attackCycleTimings = ATTACK_TIMINGS,
	states = statesTable :: any,
}

-- Direct factory constructor for dynamic instantiation
(ZoroProfile :: any).CreateProfile = function(): CharacterAnimationProfile
	return ZoroProfile
end

return table.freeze(ZoroProfile :: any)
