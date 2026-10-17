--!strict
-- src/Presentation/EnemyPresentation.luau
-- Anime Limitless Tower Defense — Phase 6 Enemy Cosmetic Presentation Engine
-- Binds procedural locomotion tracking authoritative root displacement without modifying server physics.

local RunService = game:GetService("RunService")
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

local EnemyMotionProfiles = (function()
	local ok, mod = pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local pres = rs:WaitForChild("Presentation")
		return require(pres:WaitForChild("EnemyMotionProfiles"))
	end)
	if ok and mod then return mod end
	if typeof(script) ~= "nil" and script.Parent then
		local ok2, mod2 = pcall(function()
			return require(script.Parent:WaitForChild("EnemyMotionProfiles"))
		end)
		if ok2 and mod2 then return mod2 end
	end
	local ok3, mod3 = pcall(require, "./EnemyMotionProfiles")
	if ok3 and mod3 then return mod3 end
	local ok4, mod4 = pcall(require, "../src/Presentation/EnemyMotionProfiles")
	if ok4 and mod4 then return mod4 end
	error("Failed to resolve EnemyMotionProfiles")
end)()

export type EnemyPresentationContext = {
	model: Model,
	className: string,
	rigContext: any,
	gaitProfile: any,
	lastPosition: Vector3,
	totalDistanceTraveled: number,
	connection: RBXScriptConnection?,
	isDestroyed: boolean,
}

local activeEnemyPresentations: { [Model]: EnemyPresentationContext } = {}

local EnemyPresentation = {}

function EnemyPresentation.BindEnemy(model: Model, className: string): EnemyPresentationContext?
	if activeEnemyPresentations[model] then
		return activeEnemyPresentations[model]
	end

	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart? or model.PrimaryPart
	if not root then
		return nil
	end

	local rigCtx, report = RigBinder.Bind(model, className)
	if not rigCtx then
		return nil
	end

	local profile = EnemyMotionProfiles.GetProfile(className)
	local ctx: EnemyPresentationContext = {
		model = model,
		className = className,
		rigContext = rigCtx,
		gaitProfile = profile,
		lastPosition = root.Position,
		totalDistanceTraveled = 0,
		connection = nil,
		isDestroyed = false,
	}

	activeEnemyPresentations[model] = ctx

	local stepSignal = if RunService:IsClient() then RunService.RenderStepped else RunService.Heartbeat

	ctx.connection = stepSignal:Connect(function(dt: number)
		if ctx.isDestroyed or not model.Parent or not root.Parent then
			EnemyPresentation.UnbindEnemy(model)
			return
		end

		local currentPos = root.Position
		local deltaPos = currentPos - ctx.lastPosition
		local dist = deltaPos.Magnitude
		ctx.lastPosition = currentPos

		-- Update gait only if moved
		if dist > 0.005 then
			ctx.totalDistanceTraveled += dist
			local legAngle, armAngle, bobOffset, leanAngle = EnemyMotionProfiles.CalculateGaitPose(profile, ctx.totalDistanceTraveled)

			-- Apply to Motor6Ds
			local motors = rigCtx.motors
			if motors["RightHip"] then
				motors["RightHip"].C0 = CFrame.new(0.53, -0.72 + bobOffset, 0) * CFrame.Angles(legAngle, 0, 0)
			end
			if motors["LeftHip"] then
				motors["LeftHip"].C0 = CFrame.new(-0.53, -0.72 + bobOffset, 0) * CFrame.Angles(-legAngle, 0, 0)
			end
			if motors["RightShoulder"] then
				motors["RightShoulder"].C0 = CFrame.new(1.39, 0.63 + bobOffset, 0) * CFrame.Angles(armAngle, 0, 0)
			end
			if motors["LeftShoulder"] then
				motors["LeftShoulder"].C0 = CFrame.new(-1.39, 0.63 + bobOffset, 0) * CFrame.Angles(-armAngle, 0, 0)
			end
			if motors["RootJoint"] then
				motors["RootJoint"].C0 = CFrame.new(0, 0.12 + bobOffset, 0) * CFrame.Angles(leanAngle, 0, 0)
			end
		end
	end)

	return ctx
end

function EnemyPresentation.UnbindEnemy(model: Model)
	local ctx = activeEnemyPresentations[model]
	if not ctx then
		return
	end
	ctx.isDestroyed = true
	if ctx.connection then
		ctx.connection:Disconnect()
		ctx.connection = nil
	end
	activeEnemyPresentations[model] = nil
end

function EnemyPresentation.GetContext(model: Model): EnemyPresentationContext?
	return activeEnemyPresentations[model]
end

function EnemyPresentation.ComputeGaitDisplacement(timeSec: number, speed: number, scale: number?): Vector3
	local freq = 6.0
	local amp = 0.15 * (scale or 1.0)
	local yOffset = math.sin(timeSec * freq) * amp
	local xOffset = math.cos(timeSec * (freq * 0.5)) * (amp * 0.5)
	return Vector3.new(xOffset, yOffset, 0)
end

return table.freeze(EnemyPresentation)
