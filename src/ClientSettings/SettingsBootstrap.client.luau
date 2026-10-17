--!strict
-- src/ClientSettings/SettingsBootstrap.client.luau
-- Anime Limitless Tower Defense — Phase 6 Settings Client Entrypoint
-- Mounts Settings UI in PlayerGui and creates a header gear button if not already present.

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local SettingsPanel = require(script.Parent:WaitForChild("SettingsPanel")) :: any

local settingsGui = Instance.new("ScreenGui")
settingsGui.Name = "AnimeSettingsGui"
settingsGui.ResetOnSpawn = false
settingsGui.DisplayOrder = 90
settingsGui.Parent = playerGui

local panel = SettingsPanel.Create(settingsGui)

-- Create a small top-right gear button
local gearBtn = Instance.new("TextButton")
gearBtn.Name = "SettingsGearButton"
gearBtn.Size = UDim2.new(0, 36, 0, 36)
gearBtn.Position = UDim2.new(1, -50, 0, 16)
gearBtn.BackgroundColor3 = Color3.fromRGB(32, 35, 48)
gearBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
gearBtn.Font = Enum.Font.GothamBold
gearBtn.TextSize = 16
gearBtn.Text = "⚙️"
gearBtn.BorderSizePixel = 0
gearBtn.Parent = settingsGui

local uic = Instance.new("UICorner")
uic.CornerRadius = UDim.new(0, 8)
uic.Parent = gearBtn

local uis = Instance.new("UIStroke")
uis.Color = Color3.fromRGB(80, 95, 135)
uis.Thickness = 1.5
uis.Parent = gearBtn

gearBtn.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)
