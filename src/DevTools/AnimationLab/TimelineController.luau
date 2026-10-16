--!strict
-- src/DevTools/AnimationLab/TimelineController.luau
-- 5-Phase Timeline Scrubber & Transport Controller with Deterministic Rest-Pose Restoration.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local AnimationContract = require(SharedFolder:WaitForChild("AnimationContract")) :: any

local TimelineController = {}

export type PlaybackState = {
	activeState: string,
	elapsed: number,
	duration: number,
	isPlaying: boolean,
	isLooping: boolean,
	speedMultiplier: number,
	playheadAlpha: number,
	restPose: any?,
	motors: { [string]: Motor6D },
	activeTrack: any?,
}

local currentPlayback: PlaybackState? = nil
local heartbeatConn: RBXScriptConnection? = nil

function TimelineController.BindModel(model: Model, profile: any?): PlaybackState
	TimelineController.Stop()

	local motors: { [string]: Motor6D } = {}
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("Motor6D") then
			motors[desc.Name] = desc
		end
	end

	local restSnapshot = AnimationContract.CreateRestPoseSnapshot(motors)
	local defaultTrack = profile and profile.states and profile.states.Idle
	local duration = defaultTrack and defaultTrack.duration or 1.0

	local state: PlaybackState = {
		activeState = "Idle",
		elapsed = 0,
		duration = duration,
		isPlaying = false,
		isLooping = true,
		speedMultiplier = 1.0,
		playheadAlpha = 0,
		restPose = restSnapshot,
		motors = motors,
		activeTrack = defaultTrack,
	}

	currentPlayback = state
	return state
end

function TimelineController.Play(stateName: string?, trackDef: any?)
	if not currentPlayback then
		return
	end
	if stateName then
		currentPlayback.activeState = stateName
	end
	if trackDef then
		currentPlayback.activeTrack = trackDef
		currentPlayback.duration = trackDef.duration or 1.0
	end
	currentPlayback.isPlaying = true

	if not heartbeatConn then
		heartbeatConn = RunService.Heartbeat:Connect(function(dt: number)
			if currentPlayback and currentPlayback.isPlaying and currentPlayback.activeTrack then
				currentPlayback.elapsed += dt * currentPlayback.speedMultiplier
				local d = currentPlayback.duration
				if d <= 0 then
					d = 0.001
				end

				if currentPlayback.isLooping then
					currentPlayback.elapsed = currentPlayback.elapsed % d
				else
					if currentPlayback.elapsed >= d then
						currentPlayback.elapsed = d
						currentPlayback.isPlaying = false
					end
				end

				currentPlayback.playheadAlpha = math.clamp(currentPlayback.elapsed / d, 0, 1)
				TimelineController.ApplyPoseAtTime(currentPlayback.elapsed, false)
			end
		end)
	end
end

function TimelineController.Pause()
	if currentPlayback then
		currentPlayback.isPlaying = false
	end
end

function TimelineController.Stop()
	if currentPlayback then
		currentPlayback.isPlaying = false
		currentPlayback.elapsed = 0
		currentPlayback.playheadAlpha = 0
		TimelineController.ResetToRestPose()
	end
	if heartbeatConn then
		heartbeatConn:Disconnect()
		heartbeatConn = nil
	end
end

function TimelineController.Seek(alpha: number)
	if not currentPlayback or not currentPlayback.activeTrack then
		return
	end
	currentPlayback.playheadAlpha = math.clamp(alpha, 0, 1)
	currentPlayback.elapsed = currentPlayback.playheadAlpha * currentPlayback.duration
	TimelineController.ApplyPoseAtTime(currentPlayback.elapsed, false)
end

function TimelineController.StepFrame(direction: number)
	if not currentPlayback or not currentPlayback.activeTrack then
		return
	end
	local stepSeconds = (1 / 60) * direction
	currentPlayback.elapsed = math.clamp(currentPlayback.elapsed + stepSeconds, 0, currentPlayback.duration)
	currentPlayback.playheadAlpha = currentPlayback.elapsed / currentPlayback.duration
	TimelineController.ApplyPoseAtTime(currentPlayback.elapsed, false)
end

function TimelineController.SetSpeed(speed: number)
	if currentPlayback then
		currentPlayback.speedMultiplier = math.clamp(speed, 0.1, 2.0)
	end
end

function TimelineController.SetLoop(loop: boolean)
	if currentPlayback then
		currentPlayback.isLooping = loop
	end
end

function TimelineController.ApplyPoseAtTime(elapsedSeconds: number, emitCues: boolean)
	if not currentPlayback or not currentPlayback.activeTrack then
		return
	end
	local poses, scaleTarget, cue = AnimationContract.EvaluatePoseAtTime(currentPlayback.activeTrack, elapsedSeconds)

	for jointName, poseCFrame in pairs(poses) do
		local motor = currentPlayback.motors[jointName]
		if motor and currentPlayback.restPose then
			local baseC0 = currentPlayback.restPose.baseC0[jointName] or CFrame.identity
			motor.C0 = baseC0 * poseCFrame
		end
	end
end

function TimelineController.ResetToRestPose(): boolean
	if not currentPlayback or not currentPlayback.restPose then
		return false
	end
	local maxDelta = 0.0

	for jointName, motor in pairs(currentPlayback.motors) do
		local baseC0 = currentPlayback.restPose.baseC0[jointName]
		local baseC1 = currentPlayback.restPose.baseC1[jointName]
		if baseC0 then
			local delta = (motor.C0.Position - baseC0.Position).Magnitude
			if delta > maxDelta then
				maxDelta = delta
			end
			motor.C0 = baseC0
		end
		if baseC1 then
			motor.C1 = baseC1
		end
	end

	return maxDelta < 0.001
end

function TimelineController.GetPlaybackState(): PlaybackState?
	return currentPlayback
end

return table.freeze(TimelineController)
