--!strict
-- src/Track3_UISystem/UpgradeHUD.client.luau
-- Author: Google Antigravity (agy teamwork-preview / stang-darkmatter)
-- Plan: PLAN-0003 (Infinite Upgrade UI and Server System)
-- Scope: Track 3 Procedural ScreenGui HUD and Infinite Upgrade Client Shop

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local upgradeRemote = ReplicatedStorage:WaitForChild(GameConfig.REMOTES.UPGRADE_REQUEST) :: RemoteEvent

-- สร้าง ScreenGui หลัก
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimeTD_HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 1. แถบด้านบนแสดง Wave และเลือดฐานคริสตัล (Top Status Bar)
local topFrame = Instance.new("Frame")
topFrame.Name = "TopWaveBar"
topFrame.Size = UDim2.new(0, 420, 0, 76)
topFrame.Position = UDim2.new(0.5, -210, 0, 12)
topFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 34)
topFrame.BorderSizePixel = 0
topFrame.Parent = screenGui

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topFrame

local waveLabel = Instance.new("TextLabel")
waveLabel.Name = "WaveLabel"
waveLabel.Size = UDim2.new(1, -20, 0, 32)
waveLabel.Position = UDim2.new(0, 10, 0, 6)
waveLabel.BackgroundTransparency = 1
waveLabel.Font = Enum.Font.GothamBlack
waveLabel.TextColor3 = Color3.fromRGB(255, 215, 60)
waveLabel.TextScaled = true
waveLabel.Text = "WAVE 1 | ZOMBIES: 0"
waveLabel.Parent = topFrame

local hpBarBg = Instance.new("Frame")
hpBarBg.Name = "HpBarBg"
hpBarBg.Size = UDim2.new(1, -24, 0, 24)
hpBarBg.Position = UDim2.new(0, 12, 0, 42)
hpBarBg.BackgroundColor3 = Color3.fromRGB(45, 25, 30)
hpBarBg.BorderSizePixel = 0
hpBarBg.Parent = topFrame

local hpBarFill = Instance.new("Frame")
hpBarFill.Name = "HpBarFill"
hpBarFill.Size = UDim2.new(1, 0, 1, 0)
hpBarFill.BackgroundColor3 = Color3.fromRGB(0, 215, 255)
hpBarFill.BorderSizePixel = 0
hpBarFill.Parent = hpBarBg

local hpText = Instance.new("TextLabel")
hpText.Name = "HpText"
hpText.Size = UDim2.new(1, 0, 1, 0)
hpText.BackgroundTransparency = 1
hpText.Font = Enum.Font.GothamBold
hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
hpText.TextScaled = true
hpText.Text = "CRYSTAL BASE HP: 1000 / 1000"
hpText.Parent = hpBarBg

-- 2. แผงร้านค้าอัปเกรดสเตตัสไร้ขีดจำกัดด้านซ้ายจอ (Infinite Upgrade Panel)
local shopFrame = Instance.new("Frame")
shopFrame.Name = "UpgradeShopFrame"
shopFrame.Size = UDim2.new(0, 290, 0, 340)
shopFrame.Position = UDim2.new(0, 16, 0.5, -170)
shopFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
shopFrame.BorderSizePixel = 0
shopFrame.Parent = screenGui

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 12)
shopCorner.Parent = shopFrame

local shopHeader = Instance.new("TextLabel")
shopHeader.Name = "ShopHeader"
shopHeader.Size = UDim2.new(1, -16, 0, 36)
shopHeader.Position = UDim2.new(0, 8, 0, 8)
shopHeader.BackgroundTransparency = 1
shopHeader.Font = Enum.Font.GothamBlack
shopHeader.TextColor3 = Color3.fromRGB(0, 230, 255)
shopHeader.TextScaled = true
shopHeader.Text = "ANIME POWER UPGRADES"
shopHeader.Parent = shopFrame

local cashDisplay = Instance.new("TextLabel")
cashDisplay.Name = "CashDisplay"
cashDisplay.Size = UDim2.new(1, -16, 0, 28)
cashDisplay.Position = UDim2.new(0, 8, 0, 44)
cashDisplay.BackgroundTransparency = 1
cashDisplay.Font = Enum.Font.GothamBold
cashDisplay.TextColor3 = Color3.fromRGB(80, 255, 130)
cashDisplay.TextScaled = true
cashDisplay.Text = "CASH: $300 | DPS: 35/s"
cashDisplay.Parent = shopFrame

local function createUpgradeButton(name: string, yPos: number, accentColor: Color3, upgradeType: string)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, -24, 0, 74)
	btn.Position = UDim2.new(0, 12, 0, yPos)
	btn.BackgroundColor3 = accentColor
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.AutoButtonColor = true
	btn.Parent = shopFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		upgradeRemote:FireServer(upgradeType)
	end)

	return btn
end

local dmgBtn = createUpgradeButton("DamageBtn", 82, Color3.fromRGB(190, 45, 70), "Damage")
local rangeBtn = createUpgradeButton("RangeBtn", 168, Color3.fromRGB(45, 115, 200), "Range")
local speedBtn = createUpgradeButton("SpeedBtn", 254, Color3.fromRGB(130, 50, 200), "Speed")

-- 3. ฟังก์ชันอัปเดตตัวเลขบน UI แบบเรียลไทม์
local function refreshUI()
	local wave = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE) or 1
	local zombiesLeft = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING) or 0
	local baseHp = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) or GameConfig.WAVE_SETTINGS.INITIAL_BASE_HP
	local maxBaseHp = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP) or GameConfig.WAVE_SETTINGS.INITIAL_BASE_HP
	local isGameOver = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == true

	if isGameOver then
		waveLabel.Text = "BASE DESTROYED! RESTARTING WAVE 1..."
	else
		waveLabel.Text = string.format("WAVE %d  |  ZOMBIES: %d", wave, zombiesLeft)
	end

	local hpRatio = math.clamp(baseHp / math.max(1, maxBaseHp), 0, 1)
	hpBarFill.Size = UDim2.new(hpRatio, 0, 1, 0)
	hpText.Text = string.format("CRYSTAL BASE HP: %d / %d", baseHp, maxBaseHp)

	local ls = localPlayer:FindFirstChild("leaderstats")
	local cashVal = ls and ls:FindFirstChild("Cash") :: IntValue?
	local currentCash = cashVal and cashVal.Value or 0

	local dmg = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) or GameConfig.INITIAL_PLAYER_STATS.DAMAGE_STAT) :: number
	local rng = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) or GameConfig.INITIAL_PLAYER_STATS.RANGE_STAT) :: number
	local cd = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) or GameConfig.INITIAL_PLAYER_STATS.COOLDOWN_STAT) :: number

	local dmgLvl = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL) or 1) :: number
	local rngLvl = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL) or 1) :: number
	local spdLvl = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL) or 1) :: number

	local dmgCost = math.floor(75 * (1.35 ^ (dmgLvl - 1)))
	local rngCost = math.floor(60 * (1.30 ^ (rngLvl - 1)))
	local spdCost = math.floor(90 * (1.40 ^ (spdLvl - 1)))

	local dps = math.floor(dmg / math.max(0.12, cd))
	cashDisplay.Text = string.format("CASH: $%d  |  TOWER DPS: %d/s", currentCash, dps)

	dmgBtn.Text = string.format("[Lv.%d] UPGRADE ANIME DAMAGE\nDMG: %d -> %d  |  Cost: $%d", dmgLvl, dmg, math.floor(dmg * 1.35 + 10), dmgCost)
	rangeBtn.Text = string.format("[Lv.%d] UPGRADE SPIRIT RANGE\nRange: %d -> %d  |  Cost: $%d", rngLvl, rng, rng + 4, rngCost)

	if cd <= GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN then
		speedBtn.Text = string.format("[MAX] ATTACK SPEED LIMIT\nCooldown: %.2fs (MAX SPEED)", cd)
	else
		speedBtn.Text = string.format("[Lv.%d] UPGRADE ATTACK SPEED\nCooldown: %.2fs -> %.2fs  |  Cost: $%d", spdLvl, cd, math.max(0.12, cd * 0.9), spdCost)
	end
end

Workspace.AttributeChanged:Connect(refreshUI)
localPlayer.AttributeChanged:Connect(refreshUI)

task.spawn(function()
	local ls = localPlayer:WaitForChild("leaderstats", 10)
	if ls then
		local cash = ls:WaitForChild("Cash", 10) :: IntValue?
		if cash then
			cash.Changed:Connect(refreshUI)
		end
	end
	refreshUI()
end)

refreshUI()
