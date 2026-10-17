--!strict
-- src/Presentation/AnimationPlayback.luau
-- Anime Limitless Tower Defense — Phase 6 Deterministic Procedural Animation Playback
-- Drives Motor6D articulation and geometry translation from AttackMotionProfiles.
-- Zero CFrame drift; seamless support for live combat and Animation Lab transport.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
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
local RigBinder = (function()
	local ok, mod = pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local pres = rs:WaitForChild("Presentation")
		return require(pres:WaitForChild("RigBinder"))
	end)
	if ok and mod then return mod end
	if typeof(script) ~= "nil" and script.Parent then
		local ok2, mod2 = pcall(function()
			return require(script.Parent:WaitForChild("RigBinder"))
		end)
		if ok2 and mod2 then return mod2 end
	end
	local ok3, mod3 = pcall(require, "./RigBinder")
	if ok3 and mod3 then return mod3 end
	local ok4, mod4 = pcall(require, "../src/Presentation/RigBinder")
	if ok4 and mod4 then return mod4 end
	error("Failed to resolve RigBinder")
end)()

local AttackMotionProfiles = (function()
	local ok, mod = pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local pres = rs:WaitForChild("Presentation")
		return require(pres:WaitForChild("AttackMotionProfiles"))
	end)
	if ok and mod then return mod end
	if typeof(script) ~= "nil" and script.Parent then
		local ok2, mod2 = pcall(function()
			return require(script.Parent:WaitForChild("AttackMotionProfiles"))
		end)
		if ok2 and mod2 then return mod2 end
	end
	local ok3, mod3 = pcall(require, "./AttackMotionProfiles")
	if ok3 and mod3 then return mod3 end
	local ok4, mod4 = pcall(require, "../src/Presentation/AttackMotionProfiles")
	if ok4 and mod4 then return mod4 end
	error("Failed to resolve AttackMotionProfiles")
end)()

export type PlaybackState = {
	ctx: any,
	profile: any,
	currentState: string,
	currentTime: number,
	duration: number,
	speed: number,
	isPlaying: boolean,
	isPaused: boolean,
	isLooping: boolean,
	activeConnection: RBXScriptConnection?,
	onCueCallback: ((cue: string) -> ())?,
	onCompleteCallback: (() -> ())?,
	firedCues: { [string]: boolean },
}

local activePlaybacks: { [Model]: PlaybackState } = {}

local AnimationPlayback = {}

function AnimationPlayback.GetPlaybackState(model: Model): PlaybackState?
	return activePlaybacks[model]
end

function AnimationPlayback.ApplyPoseAtTime(
	ctx: any,
	profile: any,
	timeSec: number
): { string }?
	local joints, dashOffset, armScale, cues = AttackMotionProfiles.EvaluatePoseAtTime(profile, timeSec)

	-- Apply Motor6D transforms directly relative to base rest snapshot
	for jName, desiredCF in pairs(joints) do
		local motor = ctx.motors[jName]
		if motor and motor.Parent then
			motor.C0 = desiredCF
			motor.Transform = CFrame.identity
		end
	end

	-- Apply arm scale if scaled
	if armScale and (armScale - Vector3.new(1, 1, 1)).Magnitude > 0.001 then
		if ctx.rightArm and ctx.rightArm.Parent then
			local baseSize = ctx.restSnapshot.partSizes[ctx.rightArm]
			if baseSize then
				ctx.rightArm.Size = baseSize * armScale
			end
		end
		if ctx.semanticParts and ctx.semanticParts.RightArm then
			for _, part in ipairs(ctx.semanticParts.RightArm) do
				local baseSize = ctx.restSnapshot.partSizes[part]
				if baseSize then
					part.Size = baseSize * armScale
				end
			end
		end
	else
		-- Restore base sizes if returning to 1
		if ctx.rightArm and ctx.rightArm.Parent then
			local baseSize = ctx.restSnapshot.partSizes[ctx.rightArm]
			if baseSize then
				ctx.rightArm.Size = baseSize
			end
		end
		if ctx.semanticParts and ctx.semanticParts.RightArm then
			for _, part in ipairs(ctx.semanticParts.RightArm) do
				local baseSize = ctx.restSnapshot.partSizes[part]
				if baseSize then
					part.Size = baseSize
				end
			end
		end
	end

	return cues
end

function AnimationPlayback.PlayAttack(
	ctx: any,
	onCue: ((cue: string) -> ())?,
	onComplete: (() -> ())?
): PlaybackState
	local model = ctx.model
	local existing = activePlaybacks[model]
	if existing then
		AnimationPlayback.Stop(ctx)
	end

	local profile = AttackMotionProfiles.GetProfile(ctx.heroId)
	local state: PlaybackState = {
		ctx = ctx,
		profile = profile,
		currentState = "Attack",
		currentTime = 0,
		duration = profile.attackDuration,
		speed = 1.0,
		isPlaying = true,
		isPaused = false,
		isLooping = false,
		activeConnection = nil,
		onCueCallback = onCue,
		onCompleteCallback = onComplete,
		firedCues = {},
	}

	activePlaybacks[model] = state

	local isClient = RunService:IsClient()
	local stepSignal = if isClient then RunService.RenderStepped else RunService.Heartbeat

	state.activeConnection = stepSignal:Connect(function(dt: number)
		if not state.isPlaying or state.isPaused then
			return
		end

		state.currentTime += dt * state.speed
		local cues = AnimationPlayback.ApplyPoseAtTime(ctx, profile, state.currentTime)

		if cues and state.onCueCallback then
			for _, cue in ipairs(cues) do
				if not state.firedCues[cue] then
					state.firedCues[cue] = true
					state.onCueCallback(cue)
				end
			end
		end

		if state.currentTime >= state.duration then
			AnimationPlayback.Stop(ctx)
			if state.onCompleteCallback then
				state.onCompleteCallback()
			end
		end
	end)

	return state
end

function AnimationPlayback.Seek(ctx: any, timeSec: number)
	local model = ctx.model
	local state = activePlaybacks[model]
	local profile = if state then state.profile else AttackMotionProfiles.GetProfile(ctx.heroId)
	AnimationPlayback.ApplyPoseAtTime(ctx, profile, timeSec)
	if state then
		state.currentTime = timeSec
	end
end

function AnimationPlayback.Pause(ctx: any)
	local state = activePlaybacks[ctx.model]
	if state then
		state.isPaused = true
	end
end

function AnimationPlayback.Resume(ctx: any)
	local state = activePlaybacks[ctx.model]
	if state then
		state.isPaused = false
	end
end

function AnimationPlayback.Stop(ctx: any)
	local model = ctx.model
	local state = activePlaybacks[model]
	if state then
		if state.activeConnection then
			state.activeConnection:Disconnect()
			state.activeConnection = nil
		end
		state.isPlaying = false
		activePlaybacks[model] = nil
	end

	-- Revert to rest snapshot
	RigBinder.Reset(ctx)
end

function AnimationPlayback.NewController(model: Model, heroId: string?)
	local resolvedHeroId = heroId or model.Name
	local ctx = RigBinder.GetActiveContext(model)
	if not ctx then
		ctx, _ = RigBinder.Bind(model, resolvedHeroId, false)
	end

	local currentState = "Idle"
	local isPlaying = false
	local profile = AttackMotionProfiles.GetProfile(resolvedHeroId)

	local controller = {}

	function controller:GetState(): string
		return currentState
	end

	function controller:TransitionTo(stateName: string)
		currentState = stateName
	end

	function controller:Play(stateName: string?)
		if stateName then
			currentState = stateName
		end
		isPlaying = true
	end

	function controller:Pause()
		isPlaying = false
	end

	function controller:Resume()
		isPlaying = true
	end

	function controller:Stop()
		isPlaying = false
		RigBinder.Reset(ctx)
	end

	function controller:IsPlaying(): boolean
		return isPlaying
	end

	function controller:Seek(timeSec: number)
		AnimationPlayback.ApplyPoseAtTime(ctx, profile, timeSec)
	end

	function controller:StepFrame(dt: number)
		-- Step frame
	end

	function controller:Destroy()
		isPlaying = false
		RigBinder.Reset(ctx)
	end

	return controller
end

return table.freeze(AnimationPlayback)
