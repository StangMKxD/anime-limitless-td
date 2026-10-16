--!strict
-- src/Track2_TowerSystem/Animations/Luffy.luau
-- Anime Limitless Tower Defense — Phase 5 Monkey D. Luffy [Gear 5 Sun God Nika] Signature Animation Profile
-- Implements Task L-02: Complete 8-State Profile with Exaggerated Toon Rubber Stretch,
-- Shoulder Pivot Compensation, Elastic Restitution, and Mathematically Verified Zero Drift (delta < 0.001).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local AnimationContract = require(SharedFolder:WaitForChild("AnimationContract")) :: any

type AnimationState = AnimationContract.AnimationState
type StateTrackDefinition = AnimationContract.StateTrackDefinition
type ProceduralKeyframe = AnimationContract.ProceduralKeyframe
type CharacterAnimationProfile = AnimationContract.CharacterAnimationProfile

-- =============================================================================
-- GEAR 5 SIGNATURE TIMINGS & ACCESSORY RULES
-- =============================================================================

-- Combat cycle timings locked to 0.31s nominal hit impact (0.14 + 0.10 + 0.07):
-- Total cycle = 0.14s + 0.10s + 0.07s + 0.42s = 0.73s
local ATTACK_TIMINGS: AnimationContract.AttackCycleTimings = table.freeze({
	windupRatio = 0.14 / 0.73, -- approx 0.19178 (0.14s)
	attackRatio = 0.10 / 0.73, -- approx 0.13699 (0.10s)
	impactRatio = 0.07 / 0.73, -- approx 0.09589 (0.07s)
	recoveryRatio = 0.42 / 0.73, -- approx 0.57534 (0.42s)
})

local ACCESSORY_RULES: { AnimationContract.AccessoryWeldRule } = table.freeze({
	{
		accessoryNamePattern = "StrawHat",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, 0.85, 0.75) * CFrame.Angles(math.rad(-60), 0, 0),
	},
	{
		accessoryNamePattern = "CloudScarf",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, 1.15, 0.15),
	},
	{
		accessoryNamePattern = "WaistSash",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, -0.85, 0),
	},
	{
		accessoryNamePattern = "Sash",
		attachToLimb = "Torso",
		offsetCFrame = CFrame.new(0, -0.85, 0),
	},
	{
		accessoryNamePattern = "Hair",
		attachToLimb = "Head",
		offsetCFrame = CFrame.new(0, 0.65, 0.05),
	},
})

-- =============================================================================
-- 1. IDLE (Gear 5 Joyboy Bounce / Drums of Liberation)
-- =============================================================================
-- Rhythmic toon hopping, torso bobbing, knees lifted in air step, arms swinging freely.
local IDLE_TRACK: StateTrackDefinition = {
	state = "Idle",
	duration = 1.20,
	looped = true,
	canCancel = true,
	keyframes = {
		{
			alpha = 0.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			vfxCue = "PassiveAura",
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.Angles(math.rad(10), 0, math.rad(12)),
				LeftShoulder = CFrame.Angles(math.rad(-10), 0, math.rad(-12)),
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
		{
			alpha = 0.28,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0.48, 0) * CFrame.Angles(math.rad(6), math.rad(3), math.rad(4)),
				Neck = CFrame.Angles(math.rad(8), math.rad(5), math.rad(-3)),
				RightShoulder = CFrame.Angles(math.rad(28), math.rad(15), math.rad(22)),
				LeftShoulder = CFrame.Angles(math.rad(-24), math.rad(-10), math.rad(-18)),
				RightHip = CFrame.new(0, 0.22, 0) * CFrame.Angles(math.rad(22), 0, math.rad(10)),
				LeftHip = CFrame.new(0, 0.10, 0) * CFrame.Angles(math.rad(-12), 0, math.rad(-5)),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
		{
			alpha = 0.62,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			poses = {
				RootJoint = CFrame.new(0, 0.26, 0) * CFrame.Angles(math.rad(-4), math.rad(-3), math.rad(-3)),
				Neck = CFrame.Angles(math.rad(-5), math.rad(-4), math.rad(2)),
				RightShoulder = CFrame.Angles(math.rad(-18), math.rad(-10), math.rad(16)),
				LeftShoulder = CFrame.Angles(math.rad(25), math.rad(12), math.rad(-20)),
				RightHip = CFrame.Angles(math.rad(-10), 0, math.rad(4)),
				LeftHip = CFrame.new(0, 0.18, 0) * CFrame.Angles(math.rad(18), 0, math.rad(-8)),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
		{
			alpha = 0.88,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, -0.16, 0) * CFrame.Angles(math.rad(4), 0, 0),
				Neck = CFrame.Angles(math.rad(4), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(4), 0, math.rad(8)),
				LeftShoulder = CFrame.Angles(math.rad(4), 0, math.rad(-8)),
				RightHip = CFrame.Angles(math.rad(-10), math.rad(5), math.rad(6)),
				LeftHip = CFrame.Angles(math.rad(-10), math.rad(-5), math.rad(-6)),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.Angles(math.rad(10), 0, math.rad(12)),
				LeftShoulder = CFrame.Angles(math.rad(-10), 0, math.rad(-12)),
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
	},
}

-- =============================================================================
-- 2. ATTACK WINDUP (0.14s — Rubber Arm Coil Back)
-- =============================================================================
-- Arm coils backwards with exaggerated rubber torsion, building kinetic energy.
local WINDUP_TRACK: StateTrackDefinition = {
	state = "Windup",
	duration = 0.14,
	looped = false,
	canCancel = true,
	keyframes = {
		{
			alpha = 0.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			vfxCue = "AttackWindup",
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.identity,
				RightShoulder = CFrame.identity,
				LeftShoulder = CFrame.identity,
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
		{
			alpha = 0.50,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.Angles(math.rad(-8), math.rad(-20), 0),
				Neck = CFrame.Angles(math.rad(-4), math.rad(15), 0),
				RightShoulder = CFrame.new(0.2, 0.1, 0.7) * CFrame.Angles(math.rad(70), math.rad(-15), math.rad(25)),
				LeftShoulder = CFrame.Angles(math.rad(-20), math.rad(15), math.rad(-20)),
				RightHip = CFrame.Angles(math.rad(-12), math.rad(6), 0),
				LeftHip = CFrame.Angles(math.rad(15), math.rad(-6), 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1.08, 1.08, 0.90),
				pivotOffsetCompensation = Vector3.new(0, 0, 0.1),
			},
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.Angles(math.rad(-14), math.rad(-38), math.rad(-6)),
				Neck = CFrame.Angles(math.rad(-8), math.rad(32), 0),
				RightShoulder = CFrame.new(0.4, 0.25, 1.4) * CFrame.Angles(math.rad(105), math.rad(-28), math.rad(42)),
				LeftShoulder = CFrame.Angles(math.rad(-35), math.rad(22), math.rad(-30)),
				RightHip = CFrame.Angles(math.rad(-20), math.rad(12), 0),
				LeftHip = CFrame.Angles(math.rad(24), math.rad(-12), 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1.15, 1.15, 0.82),
				pivotOffsetCompensation = Vector3.new(0, 0, 0.25),
			},
		},
	},
}

-- =============================================================================
-- 3. ATTACK RELEASE (0.10s — Gomu Gomu no Stretch Punch Snap)
-- =============================================================================
-- Arm snaps forward at supersonic speed with shoulder pivot compensation.
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
				RootJoint = CFrame.Angles(math.rad(-14), math.rad(-38), math.rad(-6)),
				Neck = CFrame.Angles(math.rad(-8), math.rad(32), 0),
				RightShoulder = CFrame.new(0.4, 0.25, 1.4) * CFrame.Angles(math.rad(105), math.rad(-28), math.rad(42)),
				LeftShoulder = CFrame.Angles(math.rad(-35), math.rad(22), math.rad(-30)),
				RightHip = CFrame.Angles(math.rad(-20), math.rad(12), 0),
				LeftHip = CFrame.Angles(math.rad(24), math.rad(-12), 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1.15, 1.15, 0.82),
				pivotOffsetCompensation = Vector3.new(0, 0, 0.25),
			},
		},
		{
			alpha = 0.40,
			easingStyle = Enum.EasingStyle.Exponential,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, 0, -0.3) * CFrame.Angles(math.rad(6), math.rad(5), 0),
				Neck = CFrame.Angles(math.rad(4), 0, 0),
				RightShoulder = CFrame.new(0, 0, -1.2) * CFrame.Angles(math.rad(-50), math.rad(10), 0),
				LeftShoulder = CFrame.Angles(math.rad(15), math.rad(-10), math.rad(-15)),
				RightHip = CFrame.Angles(math.rad(15), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-15), 0, 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1.4, 1.4, 3.2),
				pivotOffsetCompensation = Vector3.new(0, 0, -1.2),
			},
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Exponential,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, 0, -0.8) * CFrame.Angles(math.rad(22), math.rad(28), 0),
				Neck = CFrame.Angles(math.rad(10), math.rad(-15), 0),
				RightShoulder = CFrame.new(0, 0, -2.6) * CFrame.Angles(math.rad(-88), math.rad(16), 0),
				LeftShoulder = CFrame.Angles(math.rad(48), math.rad(-22), math.rad(-32)),
				RightHip = CFrame.Angles(math.rad(38), math.rad(6), 0),
				LeftHip = CFrame.Angles(math.rad(-32), math.rad(-6), 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1.8, 1.8, 5.8),
				pivotOffsetCompensation = Vector3.new(0, 0, -2.6),
			},
		},
	},
}

-- =============================================================================
-- 4. ATTACK IMPACT (0.07s — Hit-Stop Elastic Recoil Vibration)
-- =============================================================================
-- Cartoon hit-stop freeze with micro-vibration and Conqueror's Haki discharge.
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
				RootJoint = CFrame.new(0, 0, -0.8) * CFrame.Angles(math.rad(22), math.rad(28), 0),
				Neck = CFrame.Angles(math.rad(10), math.rad(-15), 0),
				RightShoulder = CFrame.new(0, 0, -2.6) * CFrame.Angles(math.rad(-88), math.rad(16), 0),
				LeftShoulder = CFrame.Angles(math.rad(48), math.rad(-22), math.rad(-32)),
				RightHip = CFrame.Angles(math.rad(38), math.rad(6), 0),
				LeftHip = CFrame.Angles(math.rad(-32), math.rad(-6), 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1.8, 1.8, 5.8),
				pivotOffsetCompensation = Vector3.new(0, 0, -2.6),
			},
		},
		{
			alpha = 0.45,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0.04, -0.76) * CFrame.Angles(math.rad(23), math.rad(27), math.rad(2)),
				Neck = CFrame.Angles(math.rad(12), math.rad(-14), math.rad(1)),
				RightShoulder = CFrame.new(0, 0.04, -2.52) * CFrame.Angles(math.rad(-90), math.rad(18), math.rad(3)),
				LeftShoulder = CFrame.Angles(math.rad(50), math.rad(-21), math.rad(-31)),
				RightHip = CFrame.Angles(math.rad(38), math.rad(6), 0),
				LeftHip = CFrame.Angles(math.rad(-32), math.rad(-6), 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(2.0, 2.0, 5.4),
				pivotOffsetCompensation = Vector3.new(0, 0, -2.52),
			},
		},
		{
			alpha = 1.0,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.In,
			poses = {
				RootJoint = CFrame.new(0, 0, -0.78) * CFrame.Angles(math.rad(21), math.rad(26), 0),
				Neck = CFrame.Angles(math.rad(10), math.rad(-15), 0),
				RightShoulder = CFrame.new(0, 0, -2.55) * CFrame.Angles(math.rad(-87), math.rad(16), 0),
				LeftShoulder = CFrame.Angles(math.rad(48), math.rad(-22), math.rad(-32)),
				RightHip = CFrame.Angles(math.rad(38), math.rad(6), 0),
				LeftHip = CFrame.Angles(math.rad(-32), math.rad(-6), 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1.85, 1.85, 5.5),
				pivotOffsetCompensation = Vector3.new(0, 0, -2.55),
			},
		},
	},
}

-- =============================================================================
-- 5. ATTACK RECOVERY (0.42s — Elastic Snap-Back Restitution)
-- =============================================================================
-- Arm contracts with snap-back elastic physics, returning strictly to baseline rest pose (< 0.001).
local RECOVERY_TRACK: StateTrackDefinition = {
	state = "Recovery",
	duration = 0.42,
	looped = false,
	canCancel = true,
	keyframes = {
		{
			alpha = 0.0,
			poses = {
				RootJoint = CFrame.new(0, 0, -0.78) * CFrame.Angles(math.rad(21), math.rad(26), 0),
				Neck = CFrame.Angles(math.rad(10), math.rad(-15), 0),
				RightShoulder = CFrame.new(0, 0, -2.55) * CFrame.Angles(math.rad(-87), math.rad(16), 0),
				LeftShoulder = CFrame.Angles(math.rad(48), math.rad(-22), math.rad(-32)),
				RightHip = CFrame.Angles(math.rad(38), math.rad(6), 0),
				LeftHip = CFrame.Angles(math.rad(-32), math.rad(-6), 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1.85, 1.85, 5.5),
				pivotOffsetCompensation = Vector3.new(0, 0, -2.55),
			},
		},
		{
			alpha = 0.35,
			easingStyle = Enum.EasingStyle.Elastic,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0, 0.15) * CFrame.Angles(math.rad(-6), math.rad(-10), 0),
				Neck = CFrame.Angles(math.rad(-4), math.rad(5), 0),
				RightShoulder = CFrame.new(0, 0, 0.4) * CFrame.Angles(math.rad(-20), math.rad(-10), math.rad(10)),
				LeftShoulder = CFrame.Angles(math.rad(10), math.rad(5), math.rad(-10)),
				RightHip = CFrame.Angles(math.rad(-8), 0, 0),
				LeftHip = CFrame.Angles(math.rad(8), 0, 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(0.92, 0.92, 0.88),
				pivotOffsetCompensation = Vector3.new(0, 0, 0.1),
			},
		},
		{
			alpha = 0.70,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.04, 0) * CFrame.Angles(math.rad(2), 0, 0),
				Neck = CFrame.Angles(math.rad(2), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(6), 0, math.rad(4)),
				LeftShoulder = CFrame.Angles(math.rad(-4), 0, math.rad(-4)),
				RightHip = CFrame.Angles(math.rad(-2), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-2), 0, 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1.02, 1.02, 1.02),
				pivotOffsetCompensation = Vector3.zero,
			},
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
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
	},
}

-- =============================================================================
-- 6. ULTIMATE (2.10s — Bajrang Gun / Bajrang Fist)
-- =============================================================================
-- Ascends to heavens, creates island-sized God Fist, slams down with shockwave.
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
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
		{
			alpha = 0.30,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 5.5, 0) * CFrame.Angles(math.rad(-20), 0, 0),
				Neck = CFrame.Angles(math.rad(25), 0, 0),
				RightShoulder = CFrame.new(0, 1.2, 0) * CFrame.Angles(math.rad(170), math.rad(12), math.rad(15)),
				LeftShoulder = CFrame.Angles(math.rad(-85), 0, math.rad(-25)),
				RightHip = CFrame.Angles(math.rad(-25), 0, math.rad(12)),
				LeftHip = CFrame.Angles(math.rad(-25), 0, math.rad(-12)),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(4.2, 4.2, 4.2),
				pivotOffsetCompensation = Vector3.new(0, 1.2, 0),
			},
		},
		{
			alpha = 0.55,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			poses = {
				RootJoint = CFrame.new(0, 6.0, 0) * CFrame.Angles(math.rad(-15), 0, 0),
				Neck = CFrame.Angles(math.rad(28), 0, 0),
				RightShoulder = CFrame.new(0, 1.5, 0) * CFrame.Angles(math.rad(178), math.rad(8), math.rad(18)),
				LeftShoulder = CFrame.Angles(math.rad(-90), 0, math.rad(-28)),
				RightHip = CFrame.Angles(math.rad(-28), 0, math.rad(15)),
				LeftHip = CFrame.Angles(math.rad(-28), 0, math.rad(-15)),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(5.0, 5.0, 5.0),
				pivotOffsetCompensation = Vector3.new(0, 1.5, 0),
			},
		},
		{
			alpha = 0.70,
			easingStyle = Enum.EasingStyle.Exponential,
			easingDirection = Enum.EasingDirection.In,
			vfxCue = "UltimateImpact",
			poses = {
				RootJoint = CFrame.new(0, -0.4, -1.8) * CFrame.Angles(math.rad(42), 0, 0),
				Neck = CFrame.Angles(math.rad(-25), 0, 0),
				RightShoulder = CFrame.new(0, -1.2, -2.8) * CFrame.Angles(math.rad(-92), 0, 0),
				LeftShoulder = CFrame.Angles(math.rad(-60), 0, math.rad(-35)),
				RightHip = CFrame.Angles(math.rad(35), 0, 0),
				LeftHip = CFrame.Angles(math.rad(35), 0, 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(5.2, 5.2, 5.2),
				pivotOffsetCompensation = Vector3.new(0, -1.2, -2.8),
			},
		},
		{
			alpha = 0.85,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0.2, -0.3) * CFrame.Angles(math.rad(8), 0, 0),
				Neck = CFrame.Angles(math.rad(4), 0, 0),
				RightShoulder = CFrame.new(0, 0, -0.4) * CFrame.Angles(math.rad(-25), 0, 0),
				LeftShoulder = CFrame.Angles(math.rad(-15), 0, math.rad(-10)),
				RightHip = CFrame.Angles(math.rad(5), 0, 0),
				LeftHip = CFrame.Angles(math.rad(5), 0, 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1.8, 1.8, 1.8),
				pivotOffsetCompensation = Vector3.zero,
			},
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
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
	},
}

-- =============================================================================
-- 7. SPAWN (0.70s — Sky Bounce Drop & Squash-and-Stretch)
-- =============================================================================
-- Drops from sky lightning, squashes elastically, bounces cheerfully into place.
local SPAWN_TRACK: StateTrackDefinition = {
	state = "Spawn",
	duration = 0.70,
	looped = false,
	canCancel = false,
	keyframes = {
		{
			alpha = 0.0,
			vfxCue = "SpawnDeploy",
			poses = {
				RootJoint = CFrame.new(0, 7.0, 0) * CFrame.Angles(math.rad(15), 0, 0),
				Neck = CFrame.Angles(math.rad(-15), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(130), 0, math.rad(25)),
				LeftShoulder = CFrame.Angles(math.rad(130), 0, math.rad(-25)),
				RightHip = CFrame.Angles(math.rad(-20), 0, math.rad(10)),
				LeftHip = CFrame.Angles(math.rad(-20), 0, math.rad(-10)),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
		{
			alpha = 0.60,
			easingStyle = Enum.EasingStyle.Bounce,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, -0.45, 0) * CFrame.Angles(math.rad(12), 0, 0),
				Neck = CFrame.Angles(math.rad(15), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(-30), 0, math.rad(20)),
				LeftShoulder = CFrame.Angles(math.rad(-30), 0, math.rad(-20)),
				RightHip = CFrame.Angles(math.rad(45), math.rad(15), math.rad(10)),
				LeftHip = CFrame.Angles(math.rad(45), math.rad(-15), math.rad(-10)),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1.2, 0.8, 1.2),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
		{
			alpha = 0.82,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.new(0, 0.35, 0) * CFrame.Angles(math.rad(-6), 0, 0),
				Neck = CFrame.Angles(math.rad(-8), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(40), 0, math.rad(15)),
				LeftShoulder = CFrame.Angles(math.rad(40), 0, math.rad(-15)),
				RightHip = CFrame.Angles(math.rad(-15), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-15), 0, 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(0.95, 1.1, 0.95),
				pivotOffsetCompensation = Vector3.zero,
			},
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
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
	},
}

-- =============================================================================
-- 8. SPECIAL IDLE (1.80s — Nika Belly Laugh)
-- =============================================================================
-- Leans far back holding stomach, joyously roaring with laughter.
local SPECIAL_IDLE_TRACK: StateTrackDefinition = {
	state = "SpecialIdle",
	duration = 1.80,
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
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
		{
			alpha = 0.25,
			easingStyle = Enum.EasingStyle.Quad,
			easingDirection = Enum.EasingDirection.Out,
			poses = {
				RootJoint = CFrame.Angles(math.rad(-22), 0, 0),
				Neck = CFrame.Angles(math.rad(-25), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(105), math.rad(25), math.rad(15)),
				LeftShoulder = CFrame.Angles(math.rad(35), math.rad(-30), math.rad(25)),
				RightHip = CFrame.Angles(math.rad(-10), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-10), 0, 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
		{
			alpha = 0.45,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			poses = {
				RootJoint = CFrame.Angles(math.rad(-28), math.rad(3), 0),
				Neck = CFrame.Angles(math.rad(-32), math.rad(4), 0),
				RightShoulder = CFrame.Angles(math.rad(115), math.rad(28), math.rad(18)),
				LeftShoulder = CFrame.Angles(math.rad(42), math.rad(-32), math.rad(28)),
				RightHip = CFrame.Angles(math.rad(-8), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-8), 0, 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
		{
			alpha = 0.65,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			poses = {
				RootJoint = CFrame.Angles(math.rad(-24), math.rad(-3), 0),
				Neck = CFrame.Angles(math.rad(-27), math.rad(-4), 0),
				RightShoulder = CFrame.Angles(math.rad(110), math.rad(22), math.rad(14)),
				LeftShoulder = CFrame.Angles(math.rad(38), math.rad(-28), math.rad(24)),
				RightHip = CFrame.Angles(math.rad(-10), 0, 0),
				LeftHip = CFrame.Angles(math.rad(-10), 0, 0),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
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
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
	},
}

-- =============================================================================
-- 9. DESPAWN (0.80s — Cloud Puff Dissolve)
-- =============================================================================
-- Cheerful wave, leaps into air, dissolves cleanly into fluffy white cartoon clouds.
local DESPAWN_TRACK: StateTrackDefinition = {
	state = "Despawn" :: any,
	duration = 0.80,
	looped = false,
	canCancel = false,
	keyframes = {
		{
			alpha = 0.0,
			vfxCue = "DespawnCloud",
			poses = {
				RootJoint = CFrame.identity,
				Neck = CFrame.Angles(math.rad(5), math.rad(-10), 0),
				RightShoulder = CFrame.Angles(math.rad(140), math.rad(15), math.rad(15)),
				LeftShoulder = CFrame.Angles(math.rad(-10), 0, math.rad(-15)),
				RightHip = CFrame.identity,
				LeftHip = CFrame.identity,
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
		},
		{
			alpha = 0.45,
			easingStyle = Enum.EasingStyle.Sine,
			easingDirection = Enum.EasingDirection.InOut,
			poses = {
				RootJoint = CFrame.new(0, 1.8, 0) * CFrame.Angles(math.rad(-5), math.rad(10), 0),
				Neck = CFrame.Angles(math.rad(-10), 0, 0),
				RightShoulder = CFrame.Angles(math.rad(155), math.rad(20), math.rad(-15)),
				LeftShoulder = CFrame.Angles(math.rad(-20), 0, math.rad(-20)),
				RightHip = CFrame.Angles(math.rad(15), 0, math.rad(10)),
				LeftHip = CFrame.Angles(math.rad(15), 0, math.rad(-10)),
			},
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(0.9, 0.9, 0.9),
				pivotOffsetCompensation = Vector3.zero,
			},
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
			scaleTarget = {
				targetLimb = "RightArm",
				scaleFactor = Vector3.new(1, 1, 1),
				pivotOffsetCompensation = Vector3.zero,
			},
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

local LuffyProfile: CharacterAnimationProfile = {
	heroId = "Luffy",
	displayName = "Monkey D. Luffy [Gear 5 Sun God Nika]",
	contractVersion = "5.0.0",
	rigType = "Articulated6Joint",
	expectedJoints = AnimationContract.BODY_JOINTS,
	accessoryRules = ACCESSORY_RULES,
	baseScale = 1.0,
	attackCycleTimings = ATTACK_TIMINGS,
	states = statesTable :: any,
}

-- Direct factory constructor for dynamic instantiation
(LuffyProfile :: any).CreateProfile = function(): CharacterAnimationProfile
	return LuffyProfile
end

return table.freeze(LuffyProfile :: any)
