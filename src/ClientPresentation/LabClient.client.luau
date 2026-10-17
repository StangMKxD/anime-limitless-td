--!strict
-- src/ClientPresentation/LabClient.client.luau
-- Anime Limitless Tower Defense — Phase 6 Studio Lab Launcher
-- Placed in StarterPlayerScripts to guarantee execution in Roblox Studio.
-- Mounts F4 shortcut and a visible Studio Launch Button ("🧪 Animation Lab").

local RunService = game:GetService("RunService")
if not RunService:IsStudio() then
	return -- Strict production lockout: zero presence in live games
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local DevToolsFolder = ReplicatedStorage:WaitForChild("DevTools", 10) :: Folder?
if not DevToolsFolder then
	return
end

local LabFolder = DevToolsFolder:WaitForChild("AnimationLab", 10) :: Folder?
if not LabFolder then
	return
end

local OrbitCameraController = require(LabFolder:WaitForChild("OrbitCameraController")) :: any
local AnimationLabGui = require(LabFolder:WaitForChild("AnimationLabGui")) :: any

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
			activeGui.Parent = playerGui
		else
			isLabOpen = false
		end
	end
end

-- 1. Hook F4 shortcut
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.F4 then
		toggleLab()
	end
end)

-- 2. Create visible Studio Button
local launcherGui = Instance.new("ScreenGui")
launcherGui.Name = "StudioLabLauncherGui"
launcherGui.ResetOnSpawn = false
launcherGui.DisplayOrder = 999
launcherGui.Parent = playerGui

local labBtn = Instance.new("TextButton")
labBtn.Name = "OpenLabButton"
labBtn.Size = UDim2.new(0, 150, 0, 36)
labBtn.Position = UDim2.new(0, 16, 0, 16)
labBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
labBtn.TextColor3 = Color3.fromRGB(255, 220, 100)
labBtn.Font = Enum.Font.GothamBold
labBtn.TextSize = 13
labBtn.Text = "🧪 Animation Lab [F4]"
labBtn.BorderSizePixel = 0
labBtn.Parent = launcherGui

local uic = Instance.new("UICorner")
uic.CornerRadius = UDim.new(0, 8)
uic.Parent = labBtn

local uis = Instance.new("UIStroke")
uis.Color = Color3.fromRGB(90, 110, 160)
uis.Thickness = 1.5
uis.Parent = labBtn

labBtn.MouseButton1Click:Connect(function()
	toggleLab()
end)
