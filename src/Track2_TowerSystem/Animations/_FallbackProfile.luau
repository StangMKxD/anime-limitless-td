--!strict
-- src/Track2_TowerSystem/Animations/_FallbackProfile.luau
-- Anime Limitless Tower Defense — Phase 5 Canonical Fallback Animation Profile
-- Implements complete 8-state animations aligned with nominal combat timings (0.31s hit).
-- Serves 9 Legacy Heroes and 4 Enemies smoothly without errors.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local AnimationContract = require(SharedFolder:WaitForChild("AnimationContract")) :: any

local _FallbackProfile = {}

local BASE_PROFILE: AnimationContract.CharacterAnimationProfile = {
	heroId = "_Fallback",
	displayName = "Default Character Rig Profile",
	contractVersion = "5.0.0",
	rigType = "Articulated6Joint",
	expectedJoints = AnimationContract.BODY_JOINTS,
	accessoryRules = {},
	baseScale = 1.0,
	attackCycleTimings = {
		windupRatio = 0.2745, -- 0.14s / 0.51s
		attackRatio = 0.1961, -- 0.10s / 0.51s
		impactRatio = 0.1373, -- 0.07s / 0.51s
		recoveryRatio = 0.3921, -- 0.20s / 0.51s
	},
	states = {
		Idle = {
			state = "Idle",
			duration = 1.2,
			looped = true,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					easingStyle = Enum.EasingStyle.Sine,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = CFrame.identity,
						Neck = CFrame.identity,
						RightShoulder = CFrame.identity,
						LeftShoulder = CFrame.identity,
						RightHip = CFrame.identity,
						LeftHip = CFrame.identity,
					},
				},
				{
					alpha = 0.5,
					easingStyle = Enum.EasingStyle.Sine,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = CFrame.new(0, -0.05, 0),
						Neck = CFrame.Angles(math.rad(2.5), 0, 0),
						RightShoulder = CFrame.Angles(math.rad(3), 0, math.rad(2)),
						LeftShoulder = CFrame.Angles(math.rad(3), 0, math.rad(-2)),
						RightHip = CFrame.Angles(math.rad(-2), 0, 0),
						LeftHip = CFrame.Angles(math.rad(-2), 0, 0),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Sine,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = CFrame.identity,
						Neck = CFrame.identity,
						RightShoulder = CFrame.identity,
						LeftShoulder = CFrame.identity,
						RightHip = CFrame.identity,
						LeftHip = CFrame.identity,
					},
				},
			},
		},

		SpecialIdle = {
			state = "SpecialIdle",
			duration = 1.5,
			looped = false,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					poses = { Neck = CFrame.identity, RightShoulder = CFrame.identity },
				},
				{
					alpha = 0.4,
					easingStyle = Enum.EasingStyle.Quad,
					easingDirection = Enum.EasingDirection.Out,
					vfxCue = "SpecialIdleCue",
					poses = {
						Neck = CFrame.Angles(math.rad(-15), math.rad(10), 0),
						RightShoulder = CFrame.Angles(math.rad(70), math.rad(20), math.rad(15)),
					},
				},
				{
					alpha = 0.7,
					easingStyle = Enum.EasingStyle.Quad,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						Neck = CFrame.Angles(math.rad(-10), math.rad(-5), 0),
						RightShoulder = CFrame.Angles(math.rad(80), math.rad(15), math.rad(20)),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Quad,
					easingDirection = Enum.EasingDirection.In,
					poses = { Neck = CFrame.identity, RightShoulder = CFrame.identity },
				},
			},
		},

		Spawn = {
			state = "Spawn",
			duration = 0.8,
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					vfxCue = "SpawnDeploy",
					poses = {
						RootJoint = CFrame.new(0, 3, 0),
						RightShoulder = CFrame.Angles(math.rad(120), 0, math.rad(30)),
						LeftShoulder = CFrame.Angles(math.rad(120), 0, math.rad(-30)),
					},
				},
				{
					alpha = 0.7,
					easingStyle = Enum.EasingStyle.Bounce,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						RootJoint = CFrame.new(0, -0.2, 0),
						Neck = CFrame.Angles(math.rad(15), 0, 0),
						RightShoulder = CFrame.Angles(math.rad(-20), 0, 0),
						LeftShoulder = CFrame.Angles(math.rad(-20), 0, 0),
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
					},
				},
			},
		},

		Windup = {
			state = "Windup",
			duration = 0.14, -- Exact Phase 1 timing
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
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Quad,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						RootJoint = CFrame.Angles(math.rad(-14), 0, 0),
						Neck = CFrame.Angles(math.rad(-10), 0, 0),
						RightShoulder = CFrame.new(0, 0.2, 0) * CFrame.Angles(math.rad(55), math.rad(-15), math.rad(20)),
						LeftShoulder = CFrame.Angles(math.rad(-30), 0, math.rad(-20)),
						RightHip = CFrame.Angles(math.rad(-12), 0, 0),
						LeftHip = CFrame.Angles(math.rad(18), 0, 0),
					},
				},
			},
		},

		Attack = {
			state = "Attack",
			duration = 0.10, -- Exact Phase 2 timing
			looped = false,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					vfxCue = "AttackRelease",
					poses = {
						RootJoint = CFrame.Angles(math.rad(-14), 0, 0),
						RightShoulder = CFrame.new(0, 0.2, 0) * CFrame.Angles(math.rad(55), math.rad(-15), math.rad(20)),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Exponential,
					easingDirection = Enum.EasingDirection.In,
					poses = {
						RootJoint = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(18), 0, 0),
						RightShoulder = CFrame.Angles(math.rad(-75), math.rad(20), math.rad(-10)),
						LeftShoulder = CFrame.Angles(math.rad(45), 0, math.rad(-25)),
						RightHip = CFrame.Angles(math.rad(40), 0, 0),
						LeftHip = CFrame.Angles(math.rad(-35), 0, 0),
					},
				},
			},
		},

		Impact = {
			state = "Impact",
			duration = 0.07, -- Exact Phase 3 timing
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					vfxCue = "AttackImpact",
					poses = {
						RootJoint = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(18), 0, 0),
						RightShoulder = CFrame.Angles(math.rad(-85), math.rad(30), 0),
						Neck = CFrame.Angles(math.rad(5), 0, 0),
					},
				},
				{
					alpha = 1.0,
					poses = {
						RootJoint = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(18), 0, 0),
						RightShoulder = CFrame.Angles(math.rad(-90), math.rad(40), 0),
						Neck = CFrame.Angles(math.rad(8), 0, 0),
					},
				},
			},
		},

		Recovery = {
			state = "Recovery",
			duration = 0.20, -- Exact Phase 4-5 return timing
			looped = false,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = CFrame.new(0, 0, -0.6) * CFrame.Angles(math.rad(18), 0, 0),
						RightShoulder = CFrame.Angles(math.rad(-90), math.rad(40), 0),
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
				},
			},
		},

		Ultimate = {
			state = "Ultimate",
			duration = 1.0,
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					vfxCue = "UltimateCast",
					poses = {
						RootJoint = CFrame.new(0, 0.5, 0),
						RightShoulder = CFrame.Angles(math.rad(160), 0, math.rad(20)),
						LeftShoulder = CFrame.Angles(math.rad(160), 0, math.rad(-20)),
					},
				},
				{
					alpha = 0.6,
					easingStyle = Enum.EasingStyle.Exponential,
					easingDirection = Enum.EasingDirection.In,
					vfxCue = "UltimateImpact",
					poses = {
						RootJoint = CFrame.new(0, -0.3, -0.4) * CFrame.Angles(math.rad(30), 0, 0),
						Neck = CFrame.Angles(math.rad(-20), 0, 0),
						RightShoulder = CFrame.Angles(math.rad(-90), 0, 0),
						LeftShoulder = CFrame.Angles(math.rad(-90), 0, 0),
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
					},
				},
			},
		},
	},
}

function _FallbackProfile.CreateForHero(heroId: string): AnimationContract.CharacterAnimationProfile
	local cloned: AnimationContract.CharacterAnimationProfile = {
		heroId = heroId,
		displayName = heroId .. " (Fallback Rig)",
		contractVersion = BASE_PROFILE.contractVersion,
		rigType = BASE_PROFILE.rigType,
		expectedJoints = BASE_PROFILE.expectedJoints,
		accessoryRules = BASE_PROFILE.accessoryRules,
		baseScale = BASE_PROFILE.baseScale,
		attackCycleTimings = BASE_PROFILE.attackCycleTimings,
		states = BASE_PROFILE.states,
	}
	return cloned
end

return table.freeze(_FallbackProfile)
