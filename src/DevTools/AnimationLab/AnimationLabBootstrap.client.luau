--!strict
-- src/DevTools/AnimationLab/AnimationLabBootstrap.client.luau
-- Studio Client Entrypoint: Hooks F4 shortcut, manages Camera and mounts AnimationLabGui.

local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	return
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local OrbitCameraController = require(script.Parent:WaitForChild("OrbitCameraController")) :: any
local AnimationLabGui = require(script.Parent:WaitForChild("AnimationLabGui")) :: any

local activeGui: ScreenGui? = nil
local isLabOpen = false

local function toggleLab()
	local commandRemote = ReplicatedStorage:WaitForChild("AnimationLabCommand", 5) :: RemoteFunction?
	if not commandRemote then
		warn("[AnimationLab] AnimationLabCommand RemoteFunction not found")
		return
	end

	if isLabOpen then
		isLabOpen = false
		OrbitCameraController.Deactivate()
		if activeGui then
			activeGui:Destroy()
			activeGui = nil
		end
		pcall(function()
			commandRemote:InvokeServer("CloseSession")
		end)
	else
		isLabOpen = true
		local ok, res = pcall(function()
			return commandRemote:InvokeServer("OpenSession")
		end)
		if ok and res and res.success then
			OrbitCameraController.Activate()
			activeGui = AnimationLabGui.Create()
			activeGui.Parent = localPlayer:WaitForChild("PlayerGui")
		else
			isLabOpen = false
		end
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.F4 then
		toggleLab()
	end
end)
