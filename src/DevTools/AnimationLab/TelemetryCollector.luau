--!strict
-- src/DevTools/AnimationLab/TelemetryCollector.luau
-- Real-time instrumentation collecting BaseParts, Joints, VFX instances, and zero-leak balance.

local RunService = game:GetService("RunService")
local TelemetryCollector = {}

export type TelemetrySnapshot = {
	modelName: string,
	basePartCount: number,
	activeMotorCount: number,
	activeWeldCount: number,
	emitterCount: number,
	activeVFXInstances: number,
	trackedTweens: number,
	createdCount: number,
	cleanedCount: number,
	leakDelta: number,
	frameTimeMs: number,
	fps: number,
}

local lastFpsTime = os.clock()
local frameCount = 0
local currentFps = 60.0
local currentFrameTimeMs = 16.67

if RunService:IsStudio() then
	RunService.Heartbeat:Connect(function(dt: number)
		frameCount += 1
		currentFrameTimeMs = dt * 1000
		local now = os.clock()
		if now - lastFpsTime >= 0.5 then
			currentFps = math.round(frameCount / (now - lastFpsTime))
			frameCount = 0
			lastFpsTime = now
		end
	end)
end

function TelemetryCollector.Sample(model: Model?, vfxContainer: Folder?, createdTotal: number?, cleanedTotal: number?): TelemetrySnapshot
	local basePartCount = 0
	local motorCount = 0
	local weldCount = 0
	local emitterCount = 0

	if model then
		for _, desc in ipairs(model:GetDescendants()) do
			if desc:IsA("BasePart") then
				basePartCount += 1
			elseif desc:IsA("Motor6D") then
				motorCount += 1
			elseif desc:IsA("WeldConstraint") or desc:IsA("Weld") then
				weldCount += 1
			elseif desc:IsA("ParticleEmitter") then
				emitterCount += 1
			end
		end
	end

	local vfxInstanceCount = 0
	if vfxContainer then
		vfxInstanceCount = #vfxContainer:GetChildren()
		for _, desc in ipairs(vfxContainer:GetDescendants()) do
			if desc:IsA("BasePart") then
				basePartCount += 1
			elseif desc:IsA("ParticleEmitter") then
				emitterCount += 1
			end
		end
	end

	local cTotal = createdTotal or 0
	local clTotal = cleanedTotal or 0

	return {
		modelName = model and model.Name or "None",
		basePartCount = basePartCount,
		activeMotorCount = motorCount,
		activeWeldCount = weldCount,
		emitterCount = emitterCount,
		activeVFXInstances = vfxInstanceCount,
		trackedTweens = 0,
		createdCount = cTotal,
		cleanedCount = clTotal,
		leakDelta = cTotal - clTotal,
		frameTimeMs = currentFrameTimeMs,
		fps = currentFps,
	}
end

return table.freeze(TelemetryCollector)
