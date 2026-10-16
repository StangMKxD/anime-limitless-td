--!strict
-- src/DevTools/AnimationLab/AnimationLabBootstrap.server.luau
-- Studio Gatekeeper & Session Lifecycle Dispatcher.
-- Halts and cleans up immediately if not in Roblox Studio.

local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LabConfig = require(script.Parent:WaitForChild("LabConfig")) :: any
local ModelValidator = require(script.Parent:WaitForChild("ModelValidator")) :: any
local SandboxStageManager = require(script.Parent:WaitForChild("SandboxStageManager")) :: any
local StressTestRunner = require(script.Parent:WaitForChild("StressTestRunner")) :: any

-- Setup Command RemoteFunction
local remoteName = "AnimationLabCommand"
local commandRemote = ReplicatedStorage:FindFirstChild(remoteName) :: RemoteFunction?
if not commandRemote then
	commandRemote = Instance.new("RemoteFunction")
	commandRemote.Name = remoteName
	commandRemote.Parent = ReplicatedStorage
end

commandRemote.OnServerInvoke = function(player: Player, action: string, payload: any)
	if not RunService:IsStudio() then
		return { success = false, error = "AnimationLab is restricted to Roblox Studio" }
	end

	local sessionId = tostring(player.UserId)

	if action == "OpenSession" then
		local session = SandboxStageManager.CreateSession(sessionId)
		return { success = true, sessionId = sessionId, stagePosition = LabConfig.STAGE_POSITION }
	elseif action == "CloseSession" then
		SandboxStageManager.CleanupSession(sessionId)
		return { success = true }
	elseif action == "LoadModel" then
		local assetId = payload and payload.assetId
		local scale = payload and payload.scale or 1.0
		if not assetId or not LabConfig.ASSET_CATALOG[assetId] then
			return { success = false, error = "Invalid assetId: " .. tostring(assetId) }
		end

		local template, err = ModelValidator.ResolveModelTemplate(assetId)
		if not template then
			return { success = false, error = err }
		end

		local validation = ModelValidator.ValidateModel(template)
		local spawned = SandboxStageManager.SpawnModelOnStage(sessionId, template, scale)
		return {
			success = true,
			assetId = assetId,
			validationReport = validation,
			scale = scale,
		}
	elseif action == "RunStressTest" then
		local scenario = payload and payload.scenario or "Single"
		local templates: { Model } = {}
		for _, assetId in ipairs({ "Luffy", "Zoro", "Ace" }) do
			local t = ModelValidator.ResolveModelTemplate(assetId)
			if t then
				table.insert(templates, t)
			end
		end
		if #templates == 0 then
			return { success = false, error = "No template models found for stress test" }
		end

		local stressResult = StressTestRunner.RunTest(sessionId, scenario, templates)
		return { success = true, result = stressResult }
	end

	return { success = false, error = "Unknown action: " .. tostring(action) }
end

Players.PlayerRemoving:Connect(function(player: Player)
	SandboxStageManager.CleanupSession(tostring(player.UserId))
end)
