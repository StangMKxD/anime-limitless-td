--!strict
-- src/Presentation/EnemyMotionProfiles.luau
-- Anime Limitless Tower Defense — Phase 6 Enemy Locomotion Motion Profiles
-- Specific procedural walk gaits, arm swings, and stride frequencies for 4 enemy classes.
-- Purely cosmetic presentation based on displacement; zero authority over server root movement.

export type EnemyGaitConfig = {
	className: string,
	strideFrequency: number, -- Steps per stud of movement
	legSwingAngleDeg: number,
	armSwingAngleDeg: number,
	bodyBobHeight: number,
	leanForwardAngleDeg: number,
}

local Profiles: { [string]: EnemyGaitConfig } = {
	PirateGrunt = {
		className = "PirateGrunt",
		strideFrequency = 0.55,
		legSwingAngleDeg = 28,
		armSwingAngleDeg = 24,
		bodyBobHeight = 0.12,
		leanForwardAngleDeg = 5,
	},

	SoruAssassin = {
		className = "SoruAssassin",
		strideFrequency = 0.85,
		legSwingAngleDeg = 36,
		armSwingAngleDeg = 32,
		bodyBobHeight = 0.08,
		leanForwardAngleDeg = 18,
	},

	HakiBrute = {
		className = "HakiBrute",
		strideFrequency = 0.38,
		legSwingAngleDeg = 24,
		armSwingAngleDeg = 18,
		bodyBobHeight = 0.22,
		leanForwardAngleDeg = 8,
	},

	YonkoBoss = {
		className = "YonkoBoss",
		strideFrequency = 0.32,
		legSwingAngleDeg = 22,
		armSwingAngleDeg = 16,
		bodyBobHeight = 0.28,
		leanForwardAngleDeg = 6,
	},
}

local FallbackGait: EnemyGaitConfig = {
	className = "_FallbackEnemy",
	strideFrequency = 0.50,
	legSwingAngleDeg = 25,
	armSwingAngleDeg = 20,
	bodyBobHeight = 0.15,
	leanForwardAngleDeg = 5,
}

local EnemyMotionProfiles = {}

function EnemyMotionProfiles.GetProfile(className: string): EnemyGaitConfig
	return Profiles[className] or FallbackGait
end

function EnemyMotionProfiles.CalculateGaitPose(
	profile: EnemyGaitConfig,
	distanceTraveled: number
): (number, number, number, number)
	local phase = distanceTraveled * profile.strideFrequency * math.pi * 2
	local sinPhase = math.sin(phase)
	local cosPhase = math.cos(phase)

	local legAngle = math.rad(profile.legSwingAngleDeg) * sinPhase
	local armAngle = math.rad(profile.armSwingAngleDeg) * -sinPhase
	local bobOffset = math.abs(sinPhase) * profile.bodyBobHeight
	local leanAngle = math.rad(profile.leanForwardAngleDeg)

	return legAngle, armAngle, bobOffset, leanAngle
end

return table.freeze(EnemyMotionProfiles)
