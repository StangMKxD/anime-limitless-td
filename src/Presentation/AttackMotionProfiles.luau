--!strict
-- src/Presentation/AttackMotionProfiles.luau
-- Anime Limitless Tower Defense — Phase 6 Attack Motion Profiles
-- Specific procedural melee trajectories, stances, and joint poses for all 8 playable heroes.
-- Decoupled from damage logic; pure cosmetic presentation conforming to 0.31s nominal hit.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationContract = (function()
	local ok, mod = pcall(function()
		return require(SharedFolder:WaitForChild("AnimationContract"))
	end)
	if ok and mod then return mod end
	local ok2, mod2 = pcall(require, "./AnimationContract")
	if ok2 and mod2 then return mod2 end
	local ok3, mod3 = pcall(require, "../Shared/AnimationContract")
	if ok3 and mod3 then return mod3 end
	local ok4, mod4 = pcall(require, "../src/Shared/AnimationContract")
	if ok4 and mod4 then return mod4 end
	error("Failed to resolve AnimationContract")
end)()

export type JointPoseMap = { [string]: CFrame }

export type KeyframeData = {
	time: number,
	joints: JointPoseMap,
	dashOffset: Vector3?,
	rightArmScale: Vector3?,
	cues: { string }?,
}

export type HeroMotionProfile = {
	heroId: string,
	displayName: string,
	attackDuration: number, -- Nominal full attack cycle duration
	windupTime: number,    -- ~0.14s
	dashTime: number,      -- ~0.24s (0.14 + 0.10)
	impactTime: number,    -- 0.31s nominal impact
	recoveryTime: number,  -- 0.51s
	keyframes: { KeyframeData },
}

local rad = math.rad

local function makeKeyframe(
	t: number,
	rootRot: CFrame,
	neckRot: CFrame,
	rArmRot: CFrame,
	lArmRot: CFrame,
	rLegRot: CFrame,
	lLegRot: CFrame,
	dashOffset: Vector3?,
	armScale: Vector3?,
	cues: { string }?
): KeyframeData
	local joints: JointPoseMap = {
		RootJoint = CFrame.new(0, 0.12, 0) * rootRot,
		Neck = CFrame.new(0, 1.80, 0) * neckRot,
		RightShoulder = CFrame.new(1.39, 0.63, 0) * rArmRot,
		LeftShoulder = CFrame.new(-1.39, 0.63, 0) * lArmRot,
		RightHip = CFrame.new(0.53, -0.72, 0) * rLegRot,
		LeftHip = CFrame.new(-0.53, -0.72, 0) * lLegRot,
	}

	return {
		time = t,
		joints = joints,
		dashOffset = dashOffset or Vector3.zero,
		rightArmScale = armScale or Vector3.new(1, 1, 1),
		cues = cues,
	}
end

local Profiles: { [string]: HeroMotionProfile } = {}

-- 1. Luffy Gear 5 (Rubber Arm Stretch & Joyboy Stance)
Profiles["Tower_Luffy_G5"] = {
	heroId = "Tower_Luffy_G5",
	displayName = "Monkey D. Luffy [Gear 5 Sun God Nika]",
	attackDuration = 0.55,
	windupTime = 0.14,
	dashTime = 0.24,
	impactTime = 0.31,
	recoveryTime = 0.55,
	keyframes = {
		makeKeyframe(0.00, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
		makeKeyframe(0.14, CFrame.Angles(rad(-12), rad(-15), 0), CFrame.Angles(rad(5), rad(10), 0), CFrame.Angles(rad(60), rad(-30), rad(20)), CFrame.Angles(rad(-20), 0, rad(-15)), CFrame.Angles(rad(15), 0, 0), CFrame.Angles(rad(-15), 0, 0), Vector3.new(0, 0, 0), Vector3.new(1, 1, 1), { "AttackWindup" }),
		makeKeyframe(0.24, CFrame.Angles(rad(10), rad(10), 0), CFrame.Angles(rad(-5), 0, 0), CFrame.Angles(rad(-70), rad(20), 0), CFrame.Angles(rad(30), 0, 0), CFrame.Angles(rad(-10), 0, 0), CFrame.Angles(rad(10), 0, 0), Vector3.new(0, 0, -2.5), Vector3.new(1.4, 2.5, 1.4), { "AttackRelease" }),
		makeKeyframe(0.31, CFrame.Angles(rad(15), rad(20), 0), CFrame.Angles(rad(-10), 0, 0), CFrame.Angles(rad(-90), rad(30), 0), CFrame.Angles(rad(40), 0, 0), CFrame.Angles(rad(-15), 0, 0), CFrame.Angles(rad(15), 0, 0), Vector3.new(0, 0, -3.2), Vector3.new(1.8, 3.8, 1.8), { "AttackImpact" }),
		makeKeyframe(0.42, CFrame.Angles(rad(5), rad(5), 0), CFrame.Angles(0, 0, 0), CFrame.Angles(rad(-30), rad(10), 0), CFrame.Angles(rad(15), 0, 0), CFrame.Angles(rad(-5), 0, 0), CFrame.Angles(rad(5), 0, 0), Vector3.new(0, 0, -1.0), Vector3.new(1.2, 1.5, 1.2)),
		makeKeyframe(0.55, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), Vector3.new(0, 0, 0), Vector3.new(1, 1, 1)),
	},
}

-- 2. Zoro King of Hell (Santoryu Triple Blade Cross-Slash)
Profiles["Tower_Zoro_KingOfHell"] = {
	heroId = "Tower_Zoro_KingOfHell",
	displayName = "Roronoa Zoro [King of Hell Santoryu]",
	attackDuration = 0.55,
	windupTime = 0.14,
	dashTime = 0.24,
	impactTime = 0.31,
	recoveryTime = 0.55,
	keyframes = {
		makeKeyframe(0.00, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
		makeKeyframe(0.14, CFrame.Angles(rad(-15), rad(25), 0), CFrame.Angles(rad(10), rad(-15), 0), CFrame.Angles(rad(75), rad(45), rad(-20)), CFrame.Angles(rad(75), rad(-45), rad(20)), CFrame.Angles(rad(20), 0, 0), CFrame.Angles(rad(-20), 0, 0), Vector3.new(0, 0, 0), nil, { "AttackWindup" }),
		makeKeyframe(0.24, CFrame.Angles(rad(15), 0, 0), CFrame.Angles(rad(-5), 0, 0), CFrame.Angles(rad(-45), rad(-30), rad(30)), CFrame.Angles(rad(-45), rad(30), rad(-30)), CFrame.Angles(rad(-15), 0, 0), CFrame.Angles(rad(15), 0, 0), Vector3.new(0, 0, -2.8), nil, { "AttackRelease" }),
		makeKeyframe(0.31, CFrame.Angles(rad(20), 0, 0), CFrame.Angles(rad(-10), 0, 0), CFrame.Angles(rad(-90), rad(-50), rad(40)), CFrame.Angles(rad(-90), rad(50), rad(-40)), CFrame.Angles(rad(-25), 0, 0), CFrame.Angles(rad(25), 0, 0), Vector3.new(0, 0, -3.5), nil, { "AttackImpact" }),
		makeKeyframe(0.42, CFrame.Angles(rad(8), 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(rad(-20), rad(-15), rad(10)), CFrame.Angles(rad(-20), rad(15), rad(-10)), CFrame.Angles(rad(-10), 0, 0), CFrame.Angles(rad(10), 0, 0), Vector3.new(0, 0, -1.2)),
		makeKeyframe(0.55, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
	},
}

-- 3. Ace Flame Emperor (Mera Mera Fire Fist Thrust)
Profiles["Tower_Ace_Entei"] = {
	heroId = "Tower_Ace_Entei",
	displayName = "Portgas D. Ace [Flame Emperor Mera Mera]",
	attackDuration = 0.55,
	windupTime = 0.14,
	dashTime = 0.24,
	impactTime = 0.31,
	recoveryTime = 0.55,
	keyframes = {
		makeKeyframe(0.00, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
		makeKeyframe(0.14, CFrame.Angles(rad(-10), rad(-20), 0), CFrame.Angles(rad(5), rad(15), 0), CFrame.Angles(rad(40), rad(-25), rad(15)), CFrame.Angles(rad(-10), rad(20), 0), CFrame.Angles(rad(15), 0, 0), CFrame.Angles(rad(-15), 0, 0), Vector3.new(0, 0, 0), nil, { "AttackWindup" }),
		makeKeyframe(0.24, CFrame.Angles(rad(12), rad(10), 0), CFrame.Angles(rad(-5), 0, 0), CFrame.Angles(rad(-80), rad(20), 0), CFrame.Angles(rad(20), 0, 0), CFrame.Angles(rad(-12), 0, 0), CFrame.Angles(rad(12), 0, 0), Vector3.new(0, 0, -2.4), nil, { "AttackRelease" }),
		makeKeyframe(0.31, CFrame.Angles(rad(18), rad(15), 0), CFrame.Angles(rad(-10), 0, 0), CFrame.Angles(rad(-105), rad(25), 0), CFrame.Angles(rad(35), 0, 0), CFrame.Angles(rad(-20), 0, 0), CFrame.Angles(rad(20), 0, 0), Vector3.new(0, 0, -3.0), nil, { "AttackImpact" }),
		makeKeyframe(0.42, CFrame.Angles(rad(5), rad(5), 0), CFrame.Angles(0, 0, 0), CFrame.Angles(rad(-30), rad(10), 0), CFrame.Angles(rad(10), 0, 0), CFrame.Angles(rad(-5), 0, 0), CFrame.Angles(rad(5), 0, 0), Vector3.new(0, 0, -1.0)),
		makeKeyframe(0.55, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
	},
}

-- 4. Shanks Kamusari (Iaido Single Cut)
Profiles["Tower_Shanks_Kamusari"] = {
	heroId = "Tower_Shanks_Kamusari",
	displayName = "Red-Haired Shanks [Kamusari Divine Departure]",
	attackDuration = 0.55,
	windupTime = 0.14,
	dashTime = 0.24,
	impactTime = 0.31,
	recoveryTime = 0.55,
	keyframes = {
		makeKeyframe(0.00, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
		makeKeyframe(0.14, CFrame.Angles(rad(-18), rad(30), 0), CFrame.Angles(rad(8), rad(-20), 0), CFrame.Angles(rad(50), rad(30), rad(-15)), CFrame.Angles(rad(-25), rad(10), 0), CFrame.Angles(rad(22), 0, 0), CFrame.Angles(rad(-18), 0, 0), Vector3.new(0, 0, 0), nil, { "AttackWindup" }),
		makeKeyframe(0.24, CFrame.Angles(rad(20), rad(-10), 0), CFrame.Angles(rad(-10), 0, 0), CFrame.Angles(rad(-85), rad(-40), rad(25)), CFrame.Angles(rad(25), 0, 0), CFrame.Angles(rad(-20), 0, 0), CFrame.Angles(rad(20), 0, 0), Vector3.new(0, 0, -3.0), nil, { "AttackRelease" }),
		makeKeyframe(0.31, CFrame.Angles(rad(25), rad(-20), 0), CFrame.Angles(rad(-15), 0, 0), CFrame.Angles(rad(-110), rad(-60), rad(40)), CFrame.Angles(rad(35), 0, 0), CFrame.Angles(rad(-30), 0, 0), CFrame.Angles(rad(30), 0, 0), Vector3.new(0, 0, -3.8), nil, { "AttackImpact" }),
		makeKeyframe(0.42, CFrame.Angles(rad(10), rad(-5), 0), CFrame.Angles(0, 0, 0), CFrame.Angles(rad(-35), rad(-15), rad(10)), CFrame.Angles(rad(15), 0, 0), CFrame.Angles(rad(-10), 0, 0), CFrame.Angles(rad(10), 0, 0), Vector3.new(0, 0, -1.2)),
		makeKeyframe(0.55, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
	},
}

-- 5. Whitebeard Gura (Naginata Heavy Seismic Strike)
Profiles["Tower_Whitebeard_Gura"] = {
	heroId = "Tower_Whitebeard_Gura",
	displayName = "Edward Newgate [Whitebeard Gura Quake]",
	attackDuration = 0.58,
	windupTime = 0.14,
	dashTime = 0.24,
	impactTime = 0.31,
	recoveryTime = 0.58,
	keyframes = {
		makeKeyframe(0.00, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
		makeKeyframe(0.14, CFrame.Angles(rad(-22), rad(-15), 0), CFrame.Angles(rad(10), rad(10), 0), CFrame.Angles(rad(80), rad(-35), rad(20)), CFrame.Angles(rad(-40), rad(15), 0), CFrame.Angles(rad(25), 0, 0), CFrame.Angles(rad(-20), 0, 0), Vector3.new(0, 0, 0), nil, { "AttackWindup" }),
		makeKeyframe(0.24, CFrame.Angles(rad(18), rad(5), 0), CFrame.Angles(rad(-8), 0, 0), CFrame.Angles(rad(-75), rad(15), 0), CFrame.Angles(rad(25), 0, 0), CFrame.Angles(rad(-18), 0, 0), CFrame.Angles(rad(18), 0, 0), Vector3.new(0, 0, -2.6), nil, { "AttackRelease" }),
		makeKeyframe(0.31, CFrame.Angles(rad(28), rad(10), 0), CFrame.Angles(rad(-15), 0, 0), CFrame.Angles(rad(-115), rad(30), 0), CFrame.Angles(rad(45), 0, 0), CFrame.Angles(rad(-30), 0, 0), CFrame.Angles(rad(30), 0, 0), Vector3.new(0, 0, -3.4), nil, { "AttackImpact" }),
		makeKeyframe(0.44, CFrame.Angles(rad(12), rad(4), 0), CFrame.Angles(0, 0, 0), CFrame.Angles(rad(-45), rad(10), 0), CFrame.Angles(rad(20), 0, 0), CFrame.Angles(rad(-12), 0, 0), CFrame.Angles(rad(12), 0, 0), Vector3.new(0, 0, -1.4)),
		makeKeyframe(0.58, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
	},
}

-- 6. Law KRoom (Kikoku Surgical Thrust & Draw-Cut)
Profiles["Tower_Law_KRoom"] = {
	heroId = "Tower_Law_KRoom",
	displayName = "Trafalgar Law [Ope Ope K-Room]",
	attackDuration = 0.55,
	windupTime = 0.14,
	dashTime = 0.24,
	impactTime = 0.31,
	recoveryTime = 0.55,
	keyframes = {
		makeKeyframe(0.00, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
		makeKeyframe(0.14, CFrame.Angles(rad(-10), rad(20), 0), CFrame.Angles(rad(5), rad(-15), 0), CFrame.Angles(rad(35), rad(25), rad(-10)), CFrame.Angles(rad(-20), rad(15), 0), CFrame.Angles(rad(15), 0, 0), CFrame.Angles(rad(-12), 0, 0), Vector3.new(0, 0, 0), nil, { "AttackWindup" }),
		makeKeyframe(0.24, CFrame.Angles(rad(10), rad(-10), 0), CFrame.Angles(rad(-5), 0, 0), CFrame.Angles(rad(-70), rad(-20), rad(15)), CFrame.Angles(rad(15), 0, 0), CFrame.Angles(rad(-12), 0, 0), CFrame.Angles(rad(12), 0, 0), Vector3.new(0, 0, -2.4), nil, { "AttackRelease" }),
		makeKeyframe(0.31, CFrame.Angles(rad(15), rad(-15), 0), CFrame.Angles(rad(-10), 0, 0), CFrame.Angles(rad(-95), rad(-35), rad(25)), CFrame.Angles(rad(25), 0, 0), CFrame.Angles(rad(-18), 0, 0), CFrame.Angles(rad(18), 0, 0), Vector3.new(0, 0, -3.1), nil, { "AttackImpact" }),
		makeKeyframe(0.42, CFrame.Angles(rad(5), rad(-5), 0), CFrame.Angles(0, 0, 0), CFrame.Angles(rad(-30), rad(-10), rad(5)), CFrame.Angles(rad(10), 0, 0), CFrame.Angles(rad(-6), 0, 0), CFrame.Angles(rad(6), 0, 0), Vector3.new(0, 0, -1.0)),
		makeKeyframe(0.55, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
	},
}

-- 7. Kizaru Pika (Light-Speed Roundhouse Kick)
Profiles["Tower_Kizaru_Pika"] = {
	heroId = "Tower_Kizaru_Pika",
	displayName = "Borsalino Kizaru [Pika Pika Light Kick]",
	attackDuration = 0.52,
	windupTime = 0.14,
	dashTime = 0.24,
	impactTime = 0.31,
	recoveryTime = 0.52,
	keyframes = {
		makeKeyframe(0.00, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
		makeKeyframe(0.14, CFrame.Angles(rad(-12), rad(-25), 0), CFrame.Angles(rad(6), rad(20), 0), CFrame.Angles(rad(-20), rad(15), 0), CFrame.Angles(rad(25), rad(-15), 0), CFrame.Angles(rad(-20), rad(20), 0), CFrame.Angles(rad(15), 0, 0), Vector3.new(0, 0, 0), nil, { "AttackWindup" }),
		makeKeyframe(0.24, CFrame.Angles(rad(15), rad(35), 0), CFrame.Angles(rad(-8), 0, 0), CFrame.Angles(rad(25), rad(-20), 0), CFrame.Angles(rad(-35), rad(20), 0), CFrame.Angles(rad(85), rad(-40), rad(25)), CFrame.Angles(rad(-20), 0, 0), Vector3.new(0, 0, -2.8), nil, { "AttackRelease" }),
		makeKeyframe(0.31, CFrame.Angles(rad(20), rad(55), 0), CFrame.Angles(rad(-12), 0, 0), CFrame.Angles(rad(40), rad(-30), 0), CFrame.Angles(rad(-50), rad(30), 0), CFrame.Angles(rad(110), rad(-65), rad(45)), CFrame.Angles(rad(-30), 0, 0), Vector3.new(0, 0, -3.6), nil, { "AttackImpact" }),
		makeKeyframe(0.40, CFrame.Angles(rad(8), rad(20), 0), CFrame.Angles(0, 0, 0), CFrame.Angles(rad(15), rad(-10), 0), CFrame.Angles(rad(-15), rad(10), 0), CFrame.Angles(rad(35), rad(-20), 0), CFrame.Angles(rad(-10), 0, 0), Vector3.new(0, 0, -1.2)),
		makeKeyframe(0.52, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
	},
}

-- 8. Sanji Ifrit (Diable / Ifrit Jambe Rotating Leap Kick)
Profiles["Tower_Sanji_Ifrit"] = {
	heroId = "Tower_Sanji_Ifrit",
	displayName = "Vinsmoke Sanji [Ifrit Jambe Demon Kick]",
	attackDuration = 0.54,
	windupTime = 0.14,
	dashTime = 0.24,
	impactTime = 0.31,
	recoveryTime = 0.54,
	keyframes = {
		makeKeyframe(0.00, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
		makeKeyframe(0.14, CFrame.Angles(rad(-16), rad(-30), 0), CFrame.Angles(rad(8), rad(25), 0), CFrame.Angles(rad(25), rad(-15), 0), CFrame.Angles(rad(-35), rad(20), 0), CFrame.Angles(rad(-30), rad(25), 0), CFrame.Angles(rad(20), 0, 0), Vector3.new(0, 0, 0), nil, { "AttackWindup" }),
		makeKeyframe(0.24, CFrame.Angles(rad(15), rad(40), 0), CFrame.Angles(rad(-10), 0, 0), CFrame.Angles(rad(-40), rad(25), 0), CFrame.Angles(rad(30), rad(-20), 0), CFrame.Angles(rad(90), rad(-45), rad(30)), CFrame.Angles(rad(-22), 0, 0), Vector3.new(0, 0, -2.7), nil, { "AttackRelease" }),
		makeKeyframe(0.31, CFrame.Angles(rad(22), rad(60), 0), CFrame.Angles(rad(-15), 0, 0), CFrame.Angles(rad(-55), rad(35), 0), CFrame.Angles(rad(45), rad(-30), 0), CFrame.Angles(rad(115), rad(-70), rad(50)), CFrame.Angles(rad(-32), 0, 0), Vector3.new(0, 0, -3.5), nil, { "AttackImpact" }),
		makeKeyframe(0.42, CFrame.Angles(rad(8), rad(20), 0), CFrame.Angles(0, 0, 0), CFrame.Angles(rad(-18), rad(10), 0), CFrame.Angles(rad(15), rad(-10), 0), CFrame.Angles(rad(40), rad(-20), 0), CFrame.Angles(rad(-12), 0, 0), Vector3.new(0, 0, -1.1)),
		makeKeyframe(0.54, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
	},
}

-- Fallback for non-playable assets (Nami, Usopp, Chopper, Robin, Grunt, etc.)
local FallbackProfile: HeroMotionProfile = {
	heroId = "_FallbackProfile",
	displayName = "Generic Combatant",
	attackDuration = 0.55,
	windupTime = 0.14,
	dashTime = 0.24,
	impactTime = 0.31,
	recoveryTime = 0.55,
	keyframes = {
		makeKeyframe(0.00, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
		makeKeyframe(0.14, CFrame.Angles(rad(-12), 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(rad(45), 0, 0), CFrame.Angles(rad(-20), 0, 0), CFrame.Angles(rad(15), 0, 0), CFrame.Angles(rad(-15), 0, 0), Vector3.new(0, 0, 0), nil, { "AttackWindup" }),
		makeKeyframe(0.24, CFrame.Angles(rad(12), 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(rad(-60), 0, 0), CFrame.Angles(rad(20), 0, 0), CFrame.Angles(rad(-12), 0, 0), CFrame.Angles(rad(12), 0, 0), Vector3.new(0, 0, -2.5), nil, { "AttackRelease" }),
		makeKeyframe(0.31, CFrame.Angles(rad(18), 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(rad(-85), 0, 0), CFrame.Angles(rad(30), 0, 0), CFrame.Angles(rad(-18), 0, 0), CFrame.Angles(rad(18), 0, 0), Vector3.new(0, 0, -3.2), nil, { "AttackImpact" }),
		makeKeyframe(0.42, CFrame.Angles(rad(6), 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(rad(-25), 0, 0), CFrame.Angles(rad(10), 0, 0), CFrame.Angles(rad(-6), 0, 0), CFrame.Angles(rad(6), 0, 0), Vector3.new(0, 0, -1.0)),
		makeKeyframe(0.55, CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0), CFrame.Angles(0, 0, 0)),
	},
}

local ALIASES: { [string]: string } = {
	Luffy = "Tower_Luffy_G5",
	Zoro = "Tower_Zoro_KingOfHell",
	Ace = "Tower_Ace_Entei",
	Shanks = "Tower_Shanks_Kamusari",
	Whitebeard = "Tower_Whitebeard_Gura",
	Law = "Tower_Law_KRoom",
	Kizaru = "Tower_Kizaru_Pika",
	Sanji = "Tower_Sanji_Ifrit",
}

local AttackMotionProfiles = {}

function AttackMotionProfiles.GetProfile(heroId: string): HeroMotionProfile
	local targetId = ALIASES[heroId] or heroId
	local p = Profiles[targetId] or FallbackProfile
	return p
end

function AttackMotionProfiles.EvaluatePoseAtTime(
	profile: HeroMotionProfile,
	timeSeconds: number
): (JointPoseMap, Vector3, Vector3, { string }?)
	local kfs = profile.keyframes
	if timeSeconds <= kfs[1].time then
		return kfs[1].joints, kfs[1].dashOffset or Vector3.zero, kfs[1].rightArmScale or Vector3.new(1, 1, 1), nil
	end
	if timeSeconds >= kfs[#kfs].time then
		local last = kfs[#kfs]
		return last.joints, last.dashOffset or Vector3.zero, last.rightArmScale or Vector3.new(1, 1, 1), nil
	end

	-- Linear blend between bounding keyframes
	for i = 1, #kfs - 1 do
		local kf0 = kfs[i]
		local kf1 = kfs[i + 1]
		if timeSeconds >= kf0.time and timeSeconds <= kf1.time then
			local span = kf1.time - kf0.time
			local alpha = if span > 0.0001 then (timeSeconds - kf0.time) / span else 0
			-- Clamp alpha
			alpha = math.clamp(alpha, 0, 1)

			local blendedJoints: JointPoseMap = {}
			for jName, cf0 in pairs(kf0.joints) do
				local cf1 = kf1.joints[jName] or cf0
				blendedJoints[jName] = cf0:Lerp(cf1, alpha)
			end

			local d0 = kf0.dashOffset or Vector3.zero
			local d1 = kf1.dashOffset or Vector3.zero
			local blendedDash = d0:Lerp(d1, alpha)

			local s0 = kf0.rightArmScale or Vector3.new(1, 1, 1)
			local s1 = kf1.rightArmScale or Vector3.new(1, 1, 1)
			local blendedScale = s0:Lerp(s1, alpha)

			-- Check if exact cue point triggered
			local cues: { string }? = nil
			if math.abs(timeSeconds - kf1.time) < 0.016 then
				cues = kf1.cues
			end

			return blendedJoints, blendedDash, blendedScale, cues
		end
	end

	return kfs[1].joints, Vector3.zero, Vector3.new(1, 1, 1), nil
end

function AttackMotionProfiles.EvaluateAtTime(
	profile: HeroMotionProfile,
	timeSeconds: number
): { joints: JointPoseMap, rootOffset: Vector3, rightArmAngle: CFrame, scale: Vector3, cues: { string }? }
	local j, d, s, c = AttackMotionProfiles.EvaluatePoseAtTime(profile, timeSeconds)
	return {
		joints = j,
		rootOffset = d,
		rightArmAngle = j.RightShoulder or CFrame.identity,
		scale = s,
		cues = c,
	}
end

return table.freeze(AttackMotionProfiles)
