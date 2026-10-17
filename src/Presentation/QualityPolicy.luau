--!strict
-- src/Presentation/QualityPolicy.luau
-- Anime Limitless Tower Defense — Phase 6 Quality Policy Engine
-- Translates client preferences into exact numeric caps for VFX, camera shake, and lights.

local PresentationPreferences = (function()
	local ok, mod = pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local pres = rs:WaitForChild("Presentation")
		return require(pres:WaitForChild("PresentationPreferences"))
	end)
	if ok and mod then return mod end
	if typeof(script) ~= "nil" and script.Parent then
		local ok2, mod2 = pcall(function()
			return require(script.Parent:WaitForChild("PresentationPreferences"))
		end)
		if ok2 and mod2 then return mod2 end
	end
	local ok3, mod3 = pcall(require, "./PresentationPreferences")
	if ok3 and mod3 then return mod3 end
	local ok4, mod4 = pcall(require, "../src/Presentation/PresentationPreferences")
	if ok4 and mod4 then return mod4 end
	error("Failed to resolve PresentationPreferences")
end)()

export type QualityCaps = {
	maxParticlesPerEmitter: number,
	maxVFXPartsPerModel: number,
	maxPointLightsPerModel: number,
	enableBeams: boolean,
	enableTrails: boolean,
	enableAuras: boolean,
	shakeScale: number,
	flashAlpha: number,
}

local QualityPolicy = {}

function QualityPolicy.GetPolicy(q: string): QualityCaps
	local maxParts = 30
	local maxParticles = 60
	local maxLights = 2
	local enableBeams = true
	local enableTrails = true
	local allowPointLights = true

	if q == "Low" then
		maxParts = 8
		maxParticles = 15
		maxLights = 0
		enableBeams = false
		enableTrails = false
		allowPointLights = false
	elseif q == "Medium" then
		maxParts = 16
		maxParticles = 35
		maxLights = 1
		enableBeams = true
		enableTrails = true
		allowPointLights = true
	else -- High
		maxParts = 30
		maxParticles = 60
		maxLights = 2
		enableBeams = true
		enableTrails = true
		allowPointLights = true
	end

	return {
		maxParticlesPerEmitter = maxParticles,
		maxVFXPartsPerModel = maxParts,
		maxPointLightsPerModel = maxLights,
		allowPointLights = allowPointLights,
		maxLightsPerCharacter = maxLights,
		enableBeams = enableBeams,
		enableTrails = enableTrails,
		enableAuras = true,
		shakeScale = 1.0,
		flashAlpha = 1.0,
	}
end

function QualityPolicy.GetActiveCaps(): QualityCaps
	local prefs = PresentationPreferences.GetSnapshot()
	local caps = QualityPolicy.GetPolicy(prefs.quality)

	local shakeScale = 1.0
	if prefs.cameraShakeMode == "Off" then
		shakeScale = 0.0
	elseif prefs.cameraShakeMode == "Reduced" then
		shakeScale = 0.4
	end

	local flashAlpha = 1.0
	if prefs.flashMode == "Off" then
		flashAlpha = 0.0
	elseif prefs.flashMode == "Reduced" then
		flashAlpha = 0.35
	end

	if prefs.reducedMotion then
		shakeScale = math.min(shakeScale, 0.25)
	end

	caps.shakeScale = shakeScale
	caps.flashAlpha = flashAlpha
	caps.enableAuras = prefs.decorativeAura

	return caps
end

return table.freeze(QualityPolicy)
