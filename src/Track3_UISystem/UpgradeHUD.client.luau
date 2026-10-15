--!strict
-- src/Track3_UISystem/UpgradeHUD.client.luau
-- Anime Limitless Tower Defense — Phase 3 Turnkey Client UI System
-- Milestone 5: Full Procedural ScreenGui HUD, Wanted Gacha Modal, Bag/8-Slot Manager, 3-Card Wave Draft & Camera Shake Engine
-- Architecture: Decoupled Zero-Conflict Client UI conforming to PROJECT.md & Canonical Rules R01-R08

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(SharedFolder:WaitForChild("GameConfig")) :: any

-- =============================================================================
-- STRICT TYPE DEFINITIONS
-- =============================================================================

export type HeroSpec = {
	Id: string,
	Name: string,
	Subtitle: string,
	Rarity: string,
	Weight: number,
	DamageMult: number,
	RangeBonus: number,
	CooldownMult: number,
	SplashBonus: number,
	SellValue: number,
	AttackStyle: string,
	Onomatopoeia: string,
	PrimaryColor: Color3,
	SecondaryColor: Color3,
}

export type CardDef = {
	Id: string,
	Rarity: string,
	Category: string,
	Title: string,
	Desc: string,
	BorderColor: Color3,
	BgColor: Color3,
	DamagePct: number?,
	DamageFlat: number?,
	RangeFlat: number?,
	CooldownMult: number?,
	SplashFlat: number?,
	CritChanceFlat: number?,
	CritDamageFlat: number?,
	BountyMultFlat: number?,
	ExtraTowerSlot: number?,
	InstantCash: number?,
	BonusRerolls: number?,
	BaseHeal: number?,
}

export type BagUnit = {
	Uid: string,
	HeroId: string,
	Name: string,
	Rarity: string,
	SellValue: number,
}

export type SlotDef = {
	SlotId: string,
	Label: string,
	Position: Vector3,
}

type ShakeInstance = {
	startTime: number,
	duration: number,
	intensity: number,
	profile: string,
}

-- =============================================================================
-- HERO CATALOG MAP CACHE
-- =============================================================================

local HERO_CATALOG_MAP: { [string]: HeroSpec } = {}
if GameConfig.HERO_CATALOG and typeof(GameConfig.HERO_CATALOG) == "table" then
	for _, hero in ipairs(GameConfig.HERO_CATALOG) do
		HERO_CATALOG_MAP[hero.Id] = hero
	end
end

local function findHeroSpec(heroId: string): HeroSpec?
	return HERO_CATALOG_MAP[heroId]
end

-- =============================================================================
-- SAFE REMOTE RESOLUTION (DUAL CONTAINER RESILIENCE)
-- =============================================================================

local function resolveRemote(remoteName: string, expectedClass: string): Instance?
	-- 1. Direct ReplicatedStorage check
	local direct = ReplicatedStorage:FindFirstChild(remoteName)
	if direct and direct:IsA(expectedClass) then
		return direct
	end

	-- 2. ReplicatedStorage.Remotes subfolder check
	local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if remotesFolder then
		local nested = remotesFolder:FindFirstChild(remoteName)
		if nested and nested:IsA(expectedClass) then
			return nested
		end
	end

	-- 3. Yielding fallback
	local yielded = ReplicatedStorage:WaitForChild(remoteName, 4)
	if yielded and yielded:IsA(expectedClass) then
		return yielded
	end

	if remotesFolder then
		local nestedYielded = remotesFolder:WaitForChild(remoteName, 2)
		if nestedYielded and nestedYielded:IsA(expectedClass) then
			return nestedYielded
		end
	end

	return nil
end

-- Resolve Remotes with Fallbacks
local upgradeStatRemoteFunc = resolveRemote(GameConfig.REMOTES.UPGRADE_REQUEST, "RemoteFunction") :: RemoteFunction?
local upgradeEventRemote = resolveRemote("UpgradeRequest", "RemoteEvent") :: RemoteEvent?
if not upgradeEventRemote then
	upgradeEventRemote = resolveRemote(GameConfig.REMOTES.UPGRADE_REQUEST, "RemoteEvent") :: RemoteEvent?
end

local cardDraftRemote = resolveRemote(GameConfig.REMOTES.CARD_DRAFT_SELECT, "RemoteEvent") :: RemoteEvent?
local summonRerollRemote = resolveRemote(GameConfig.REMOTES.TOWER_SUMMON_REROLL, "RemoteEvent") :: RemoteEvent?
local placementActionRemote = resolveRemote(GameConfig.REMOTES.TOWER_PLACEMENT_ACTION, "RemoteEvent") :: RemoteEvent?
local cameraShakeRemote = resolveRemote(GameConfig.REMOTES.VFX_CAMERA_SHAKE, "RemoteEvent") :: RemoteEvent?

-- Lazy Accessors to Guarantee Remote Availability
local function getUpgradeStatRemoteFunc(): RemoteFunction?
	if not upgradeStatRemoteFunc or not upgradeStatRemoteFunc.Parent then
		upgradeStatRemoteFunc = resolveRemote(GameConfig.REMOTES.UPGRADE_REQUEST, "RemoteFunction") :: RemoteFunction?
	end
	return upgradeStatRemoteFunc
end

local function getUpgradeEventRemote(): RemoteEvent?
	if not upgradeEventRemote or not upgradeEventRemote.Parent then
		upgradeEventRemote = resolveRemote("UpgradeRequest", "RemoteEvent") :: RemoteEvent?
		if not upgradeEventRemote then
			upgradeEventRemote = resolveRemote(GameConfig.REMOTES.UPGRADE_REQUEST, "RemoteEvent") :: RemoteEvent?
		end
	end
	return upgradeEventRemote
end

local function getCardDraftRemote(): RemoteEvent?
	if not cardDraftRemote or not cardDraftRemote.Parent then
		cardDraftRemote = resolveRemote(GameConfig.REMOTES.CARD_DRAFT_SELECT, "RemoteEvent") :: RemoteEvent?
	end
	return cardDraftRemote
end

local function getSummonRerollRemote(): RemoteEvent?
	if not summonRerollRemote or not summonRerollRemote.Parent then
		summonRerollRemote = resolveRemote(GameConfig.REMOTES.TOWER_SUMMON_REROLL, "RemoteEvent") :: RemoteEvent?
	end
	return summonRerollRemote
end

local function getPlacementActionRemote(): RemoteEvent?
	if not placementActionRemote or not placementActionRemote.Parent then
		placementActionRemote = resolveRemote(GameConfig.REMOTES.TOWER_PLACEMENT_ACTION, "RemoteEvent") :: RemoteEvent?
	end
	return placementActionRemote
end

-- =============================================================================
-- ROOT SCREENGUI INITIALIZATION (PERSISTENT & CLEAN)
-- =============================================================================

for _, oldGuiName in ipairs({ "AnimeLimitlessPhase3HUD", "OnePieceTD_CardHUD", "AnimeTD_HUD" }) do
	local oldGui = playerGui:FindFirstChild(oldGuiName)
	if oldGui then
		oldGui:Destroy()
	end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimeLimitlessPhase3HUD"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- =============================================================================
-- SUBSYSTEM 1: VIEWPORT CAMERA SHAKE & SCREEN IMPACT FLASH
-- =============================================================================

local currentShakeOffset: CFrame = CFrame.identity
local activeShakes: { [number]: ShakeInstance } = {}
local shakeCounter: number = 0
local renderConnection: RBXScriptConnection? = nil

local function updateCameraShake()
	local cam = Workspace.CurrentCamera
	if not cam then
		return
	end

	-- Crucial Anti-Drift Contract: Revert previous frame's offset before calculating new
	cam.CFrame = cam.CFrame * currentShakeOffset:Inverse()

	local now = os.clock()
	local totalOffsetX = 0
	local totalOffsetY = 0
	local totalOffsetZ = 0
	local totalRotZ = 0
	local activeCount = 0

	for id, shake in pairs(activeShakes) do
		local elapsed = now - shake.startTime
		if elapsed >= shake.duration then
			activeShakes[id] = nil
		else
			activeCount += 1
			local progress = math.clamp(elapsed / shake.duration, 0, 1)
			-- Damped sinusoidal decay: (1 - p)^2
			local damping = (1 - progress) * (1 - progress)
			local freq = 26.0

			if shake.profile == "Explosive" or shake.profile == "BajrangFist" or shake.profile == "Kamusari" or shake.profile == "GuraQuake" then
				freq = 34.0
				damping = math.pow(1 - progress, 2.8)
			elseif shake.profile == "Subtle" then
				freq = 16.0
			end

			local amp = shake.intensity * damping
			local sinX = math.sin(elapsed * freq * 1.1) * amp
			local sinY = math.cos(elapsed * freq * 1.3) * amp
			local jitterZ = (math.random() - 0.5) * amp * 0.35
			local rotZ = math.sin(elapsed * freq * 0.8) * math.rad(amp * 2.2)

			totalOffsetX += sinX
			totalOffsetY += sinY
			totalOffsetZ += jitterZ
			totalRotZ += rotZ
		end
	end

	if activeCount > 0 then
		local newOffset = CFrame.new(totalOffsetX, totalOffsetY, totalOffsetZ) * CFrame.Angles(0, 0, totalRotZ)
		cam.CFrame = cam.CFrame * newOffset
		currentShakeOffset = newOffset
	else
		currentShakeOffset = CFrame.identity
		if renderConnection then
			renderConnection:Disconnect()
			renderConnection = nil
		end
	end
end

local function triggerScreenFlash(flashColor: Color3, duration: number?)
	local flashDuration = duration or 0.25
	local flashFrame = Instance.new("Frame")
	flashFrame.Name = "ScreenImpactFlash"
	flashFrame.Size = UDim2.fromScale(1, 1)
	flashFrame.Position = UDim2.fromScale(0, 0)
	flashFrame.BackgroundColor3 = flashColor
	flashFrame.BackgroundTransparency = 0.70
	flashFrame.BorderSizePixel = 0
	flashFrame.ZIndex = 100
	flashFrame.Parent = screenGui

	local tween = TweenService:Create(
		flashFrame,
		TweenInfo.new(flashDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ BackgroundTransparency = 1.0 }
	)
	tween:Play()

	task.delay(flashDuration + 0.05, function()
		if flashFrame.Parent then
			flashFrame:Destroy()
		end
	end)
end

local function onCameraShakeReceived(arg1: any, arg2: any, arg3: any, arg4: any)
	local intensity = 0.45
	local duration = 0.25
	local profile = "Sinusoidal"
	local flashColor = Color3.fromRGB(255, 255, 255)

	-- Dual-Resolution Input Handler (Table payload vs positional parameters)
	if typeof(arg1) == "table" then
		if typeof(arg1.Intensity) == "number" then
			intensity = arg1.Intensity
		end
		if typeof(arg1.Duration) == "number" then
			duration = arg1.Duration
		end
		if typeof(arg1.ShakeProfile) == "string" then
			profile = arg1.ShakeProfile
		end
		if typeof(arg1.Color) == "Color3" then
			flashColor = arg1.Color
		elseif typeof(arg1.HeroId) == "string" then
			local hero = findHeroSpec(arg1.HeroId)
			if hero then
				flashColor = hero.SecondaryColor or hero.PrimaryColor
			end
		end
	elseif typeof(arg1) == "number" then
		intensity = arg1
		if typeof(arg2) == "Color3" then
			flashColor = arg2
		elseif typeof(arg2) == "string" then
			local hero = findHeroSpec(arg2)
			if hero then
				flashColor = hero.SecondaryColor or hero.PrimaryColor
			end
		end
		if typeof(arg3) == "number" then
			duration = arg3
		end
		if typeof(arg4) == "string" then
			profile = arg4
		end
	end

	triggerScreenFlash(flashColor, duration)

	shakeCounter += 1
	activeShakes[shakeCounter] = {
		startTime = os.clock(),
		duration = duration,
		intensity = intensity,
		profile = profile,
	}

	if not renderConnection then
		renderConnection = RunService.RenderStepped:Connect(updateCameraShake)
	end
end

if cameraShakeRemote then
	cameraShakeRemote.OnClientEvent:Connect(onCameraShakeReceived)
else
	task.spawn(function()
		cameraShakeRemote = resolveRemote(GameConfig.REMOTES.VFX_CAMERA_SHAKE, "RemoteEvent") :: RemoteEvent?
		if cameraShakeRemote then
			cameraShakeRemote.OnClientEvent:Connect(onCameraShakeReceived)
		end
	end)
end

-- =============================================================================
-- SUBSYSTEM 2: TOP BANNER HUD (WAVE, BASE HP, RESOURCES & CREW STATS)
-- =============================================================================

local topBanner = Instance.new("Frame")
topBanner.Name = "TopBannerHUD"
topBanner.Size = UDim2.new(0, 720, 0, 78)
topBanner.Position = UDim2.new(0.5, -360, 0, 8)
topBanner.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
topBanner.BorderSizePixel = 0
topBanner.Parent = screenGui

local topBannerCorner = Instance.new("UICorner")
topBannerCorner.CornerRadius = UDim.new(0, 12)
topBannerCorner.Parent = topBanner

local topBannerStroke = Instance.new("UIStroke")
topBannerStroke.Color = Color3.fromRGB(255, 205, 50)
topBannerStroke.Thickness = 2
topBannerStroke.Parent = topBanner

-- Row 1: Wave Status & Prep Countdown
local waveStatusLbl = Instance.new("TextLabel")
waveStatusLbl.Name = "WaveStatusLabel"
waveStatusLbl.Size = UDim2.new(1, -20, 0, 24)
waveStatusLbl.Position = UDim2.fromOffset(10, 4)
waveStatusLbl.BackgroundTransparency = 1
waveStatusLbl.TextColor3 = Color3.fromRGB(255, 220, 70)
waveStatusLbl.Font = Enum.Font.GothamBlack
waveStatusLbl.TextScaled = true
waveStatusLbl.Text = "PREPARING GRAND LINE..."
waveStatusLbl.Parent = topBanner

-- Row 2: Base HP Bar
local hpBarBg = Instance.new("Frame")
hpBarBg.Name = "BaseHpBarBg"
hpBarBg.Size = UDim2.new(1, -24, 0, 20)
hpBarBg.Position = UDim2.fromOffset(12, 30)
hpBarBg.BackgroundColor3 = Color3.fromRGB(36, 18, 24)
hpBarBg.BorderSizePixel = 0
hpBarBg.Parent = topBanner

local hpBarBgCorner = Instance.new("UICorner")
hpBarBgCorner.CornerRadius = UDim.new(0, 6)
hpBarBgCorner.Parent = hpBarBg

local hpBarFill = Instance.new("Frame")
hpBarFill.Name = "BaseHpBarFill"
hpBarFill.Size = UDim2.new(1, 0, 1, 0)
hpBarFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
hpBarFill.BorderSizePixel = 0
hpBarFill.Parent = hpBarBg

local hpBarFillCorner = Instance.new("UICorner")
hpBarFillCorner.CornerRadius = UDim.new(0, 6)
hpBarFillCorner.Parent = hpBarFill

local hpBarText = Instance.new("TextLabel")
hpBarText.Name = "BaseHpBarText"
hpBarText.Size = UDim2.new(1, 0, 1, 0)
hpBarText.BackgroundTransparency = 1
hpBarText.TextColor3 = Color3.fromRGB(255, 255, 255)
hpBarText.Font = Enum.Font.GothamBlack
hpBarText.TextScaled = true
hpBarText.Text = "BASE HP: 1000 / 1000 (100%)"
hpBarText.Parent = hpBarBg

-- Row 3: Live Stats & Resource Counters
local statsSummaryLbl = Instance.new("TextLabel")
statsSummaryLbl.Name = "StatsSummaryLabel"
statsSummaryLbl.Size = UDim2.new(1, -20, 0, 20)
statsSummaryLbl.Position = UDim2.fromOffset(10, 53)
statsSummaryLbl.BackgroundTransparency = 1
statsSummaryLbl.TextColor3 = Color3.fromRGB(180, 235, 255)
statsSummaryLbl.Font = Enum.Font.GothamBold
statsSummaryLbl.TextScaled = true
statsSummaryLbl.Text = "💰 $500 | 🎟️ 1 | 🪙 3 | 🗼 0/4 | DMG: 50 | RNG: 30 | CD: 1.15s | CRIT: 8% (2.00x)"
statsSummaryLbl.Parent = topBanner

-- =============================================================================
-- SUBSYSTEM 3: LEFT SIDE INFINITE STAT UPGRADES PANEL
-- =============================================================================

local upgradePanel = Instance.new("Frame")
upgradePanel.Name = "InfiniteUpgradePanel"
upgradePanel.Size = UDim2.fromOffset(250, 240)
upgradePanel.Position = UDim2.new(0, 14, 0.5, -120)
upgradePanel.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
upgradePanel.BorderSizePixel = 0
upgradePanel.Parent = screenGui

local upgradePanelCorner = Instance.new("UICorner")
upgradePanelCorner.CornerRadius = UDim.new(0, 12)
upgradePanelCorner.Parent = upgradePanel

local upgradePanelStroke = Instance.new("UIStroke")
upgradePanelStroke.Color = Color3.fromRGB(0, 210, 255)
upgradePanelStroke.Thickness = 2
upgradePanelStroke.Parent = upgradePanel

local upgradeTitle = Instance.new("TextLabel")
upgradeTitle.Name = "UpgradeTitle"
upgradeTitle.Size = UDim2.new(1, -16, 0, 28)
upgradeTitle.Position = UDim2.fromOffset(8, 8)
upgradeTitle.BackgroundTransparency = 1
upgradeTitle.TextColor3 = Color3.fromRGB(0, 225, 255)
upgradeTitle.Font = Enum.Font.GothamBlack
upgradeTitle.TextScaled = true
upgradeTitle.Text = "ANIME STAT UPGRADES"
upgradeTitle.Parent = upgradePanel

-- 3 Upgrade Buttons Container
local btnDamage = Instance.new("TextButton")
btnDamage.Name = "UpgradeDamageBtn"
btnDamage.Size = UDim2.new(1, -20, 0, 56)
btnDamage.Position = UDim2.fromOffset(10, 42)
btnDamage.BackgroundColor3 = Color3.fromRGB(34, 48, 64)
btnDamage.TextColor3 = Color3.fromRGB(255, 255, 255)
btnDamage.Font = Enum.Font.GothamBold
btnDamage.TextScaled = true
btnDamage.Text = "⚔️ DAMAGE Lv.1\nCost: $75 | +10 DMG"
btnDamage.Parent = upgradePanel

local btnDmgCorner = Instance.new("UICorner")
btnDmgCorner.CornerRadius = UDim.new(0, 8)
btnDmgCorner.Parent = btnDamage

local btnRange = Instance.new("TextButton")
btnRange.Name = "UpgradeRangeBtn"
btnRange.Size = UDim2.new(1, -20, 0, 56)
btnRange.Position = UDim2.fromOffset(10, 104)
btnRange.BackgroundColor3 = Color3.fromRGB(34, 48, 64)
btnRange.TextColor3 = Color3.fromRGB(255, 255, 255)
btnRange.Font = Enum.Font.GothamBold
btnRange.TextScaled = true
btnRange.Text = "🎯 RANGE Lv.1\nCost: $60 | +4 STUDS"
btnRange.Parent = upgradePanel

local btnRngCorner = Instance.new("UICorner")
btnRngCorner.CornerRadius = UDim.new(0, 8)
btnRngCorner.Parent = btnRange

local btnSpeed = Instance.new("TextButton")
btnSpeed.Name = "UpgradeSpeedBtn"
btnSpeed.Size = UDim2.new(1, -20, 0, 56)
btnSpeed.Position = UDim2.fromOffset(10, 166)
btnSpeed.BackgroundColor3 = Color3.fromRGB(34, 48, 64)
btnSpeed.TextColor3 = Color3.fromRGB(255, 255, 255)
btnSpeed.Font = Enum.Font.GothamBold
btnSpeed.TextScaled = true
btnSpeed.Text = "⚡ SPEED Lv.1\nCost: $90 | -10% CD"
btnSpeed.Parent = upgradePanel

local btnSpdCorner = Instance.new("UICorner")
btnSpdCorner.CornerRadius = UDim.new(0, 8)
btnSpdCorner.Parent = btnSpeed

-- Safe Upgrade Dispatcher
local isUpgrading = false
local function fireStatUpgrade(statType: string)
	if isUpgrading then
		return
	end
	isUpgrading = true

	task.spawn(function()
		local rf = getUpgradeStatRemoteFunc()
		local re = getUpgradeEventRemote()
		if rf and rf:IsA("RemoteFunction") then
			pcall(function()
				rf:InvokeServer(statType)
			end)
		elseif re and re:IsA("RemoteEvent") then
			re:FireServer(statType)
		end
		task.wait(0.12)
		isUpgrading = false
	end)
end

btnDamage.MouseButton1Click:Connect(function()
	fireStatUpgrade("Damage")
end)

btnRange.MouseButton1Click:Connect(function()
	fireStatUpgrade("Range")
end)

btnSpeed.MouseButton1Click:Connect(function()
	local curCd = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) :: number?) or 1.15
	local minCd = (GameConfig.INITIAL_PLAYER_STATS and GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN) or 0.15
	if curCd > minCd then
		fireStatUpgrade("Speed")
	end
end)

-- =============================================================================
-- SUBSYSTEM 4: CENTRAL WANTED POSTER GACHA MODAL
-- =============================================================================

local summonModal = Instance.new("Frame")
summonModal.Name = "CentralWantedGachaModal"
summonModal.Size = UDim2.fromOffset(560, 360)
summonModal.Position = UDim2.new(0.5, -280, 0.5, -180)
summonModal.BackgroundColor3 = Color3.fromRGB(20, 18, 32)
summonModal.BorderSizePixel = 0
summonModal.Visible = true -- Open initially if player has 0 towers
summonModal.Parent = screenGui

local modalCorner = Instance.new("UICorner")
modalCorner.CornerRadius = UDim.new(0, 14)
modalCorner.Parent = summonModal

local modalStroke = Instance.new("UIStroke")
modalStroke.Color = Color3.fromRGB(255, 205, 55)
modalStroke.Thickness = 3
modalStroke.Parent = summonModal

local modalHeader = Instance.new("TextLabel")
modalHeader.Name = "ModalHeader"
modalHeader.Size = UDim2.new(1, -20, 0, 36)
modalHeader.Position = UDim2.fromOffset(10, 8)
modalHeader.BackgroundTransparency = 1
modalHeader.TextColor3 = Color3.fromRGB(255, 220, 65)
modalHeader.Font = Enum.Font.GothamBlack
modalHeader.TextScaled = true
modalHeader.Text = "🏴‍☠️ GRAND LINE WANTED POSTER GACHA 🏴‍☠️"
modalHeader.Parent = summonModal

local wantedPosterCard = Instance.new("Frame")
wantedPosterCard.Name = "WantedPosterCard"
wantedPosterCard.Size = UDim2.new(1, -40, 0, 185)
wantedPosterCard.Position = UDim2.fromOffset(20, 48)
wantedPosterCard.BackgroundColor3 = Color3.fromRGB(34, 28, 48)
wantedPosterCard.BorderSizePixel = 0
wantedPosterCard.Parent = summonModal

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 10)
cardCorner.Parent = wantedPosterCard

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = Color3.fromRGB(255, 185, 45)
cardStroke.Thickness = 2
cardStroke.Parent = wantedPosterCard

local rolledHeroDisplay = Instance.new("TextLabel")
rolledHeroDisplay.Name = "RolledHeroDisplay"
rolledHeroDisplay.Size = UDim2.new(1, -20, 1, -20)
rolledHeroDisplay.Position = UDim2.fromOffset(10, 10)
rolledHeroDisplay.BackgroundTransparency = 1
rolledHeroDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
rolledHeroDisplay.Font = Enum.Font.GothamBlack
rolledHeroDisplay.TextScaled = true
rolledHeroDisplay.Text = "WELCOME TO GRAND LINE!\n\nNo towers deployed on the map.\nPress [SUMMON HERO] below to recruit your first One Piece pirate!"
rolledHeroDisplay.Parent = wantedPosterCard

-- Action Buttons Row
local btnSummon = Instance.new("TextButton")
btnSummon.Name = "BtnSummon"
btnSummon.Size = UDim2.fromOffset(250, 52)
btnSummon.Position = UDim2.fromOffset(20, 245)
btnSummon.BackgroundColor3 = Color3.fromRGB(255, 185, 30)
btnSummon.TextColor3 = Color3.fromRGB(20, 15, 10)
btnSummon.Font = Enum.Font.GothamBlack
btnSummon.TextScaled = true
btnSummon.Text = "🎲 SUMMON (FREE x1)"
btnSummon.Parent = summonModal

local summonBtnCorner = Instance.new("UICorner")
summonBtnCorner.CornerRadius = UDim.new(0, 8)
summonBtnCorner.Parent = btnSummon

local btnReroll = Instance.new("TextButton")
btnReroll.Name = "BtnReroll"
btnReroll.Size = UDim2.fromOffset(250, 52)
btnReroll.Position = UDim2.fromOffset(290, 245)
btnReroll.BackgroundColor3 = Color3.fromRGB(180, 55, 250)
btnReroll.TextColor3 = Color3.fromRGB(255, 255, 255)
btnReroll.Font = Enum.Font.GothamBlack
btnReroll.TextScaled = true
btnReroll.Text = "🔄 REROLL (Token x3)"
btnReroll.Parent = summonModal

local rerollBtnCorner = Instance.new("UICorner")
rerollBtnCorner.CornerRadius = UDim.new(0, 8)
rerollBtnCorner.Parent = btnReroll

local btnCloseModal = Instance.new("TextButton")
btnCloseModal.Name = "BtnCloseModal"
btnCloseModal.Size = UDim2.new(1, -40, 0, 42)
btnCloseModal.Position = UDim2.fromOffset(20, 306)
btnCloseModal.BackgroundColor3 = Color3.fromRGB(38, 185, 110)
btnCloseModal.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCloseModal.Font = Enum.Font.GothamBlack
btnCloseModal.TextScaled = true
btnCloseModal.Text = "📍 DEPLOY / TACTICAL BOARD (CLOSE MODAL)"
btnCloseModal.Parent = summonModal

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = btnCloseModal

btnSummon.MouseButton1Click:Connect(function()
	local re = getSummonRerollRemote()
	if re then
		re:FireServer("Summon")
	end
end)

btnReroll.MouseButton1Click:Connect(function()
	local re = getSummonRerollRemote()
	if re then
		re:FireServer("Reroll")
	end
end)

btnCloseModal.MouseButton1Click:Connect(function()
	summonModal.Visible = false
end)

-- Re-open / Toggle Modal Button
local toggleGachaBtn = Instance.new("TextButton")
toggleGachaBtn.Name = "ToggleGachaBtn"
toggleGachaBtn.Size = UDim2.fromOffset(210, 44)
toggleGachaBtn.Position = UDim2.new(0, 14, 0.5, -172)
toggleGachaBtn.BackgroundColor3 = Color3.fromRGB(255, 195, 45)
toggleGachaBtn.TextColor3 = Color3.fromRGB(24, 16, 12)
toggleGachaBtn.Font = Enum.Font.GothamBlack
toggleGachaBtn.TextScaled = true
toggleGachaBtn.Text = "🎲 WANTED POSTER / GACHA"
toggleGachaBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleGachaBtn

toggleGachaBtn.MouseButton1Click:Connect(function()
	summonModal.Visible = not summonModal.Visible
end)

-- =============================================================================
-- SUBSYSTEM 5: BOTTOM BAG INVENTORY & 8-SLOT TACTICAL PAD MANAGER
-- =============================================================================

local bagPanel = Instance.new("Frame")
bagPanel.Name = "BottomBagAndSlotPanel"
bagPanel.Size = UDim2.new(0, 920, 0, 168)
bagPanel.Position = UDim2.new(0.5, -460, 1, -178)
bagPanel.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
bagPanel.BorderSizePixel = 0
bagPanel.Parent = screenGui

local bagPanelCorner = Instance.new("UICorner")
bagPanelCorner.CornerRadius = UDim.new(0, 12)
bagPanelCorner.Parent = bagPanel

local bagPanelStroke = Instance.new("UIStroke")
bagPanelStroke.Color = Color3.fromRGB(0, 200, 255)
bagPanelStroke.Thickness = 2
bagPanelStroke.Parent = bagPanel

local bagHeaderLbl = Instance.new("TextLabel")
bagHeaderLbl.Name = "BagHeaderLabel"
bagHeaderLbl.Size = UDim2.new(1, -20, 0, 24)
bagHeaderLbl.Position = UDim2.fromOffset(10, 4)
bagHeaderLbl.BackgroundTransparency = 1
bagHeaderLbl.TextColor3 = Color3.fromRGB(255, 220, 90)
bagHeaderLbl.Font = Enum.Font.GothamBold
bagHeaderLbl.TextScaled = true
bagHeaderLbl.Text = "🎒 INVENTORY BAG (SELECT UNIT) & 8 TACTICAL PADS (DEPLOY / ATOMIC SWAP / RECALL / SELL)"
bagHeaderLbl.Parent = bagPanel

-- Row 1: Bag Container (Horizontal Scrolling/List)
local bagScrolling = Instance.new("ScrollingFrame")
bagScrolling.Name = "BagScrollingTray"
bagScrolling.Size = UDim2.new(1, -20, 0, 60)
bagScrolling.Position = UDim2.fromOffset(10, 30)
bagScrolling.BackgroundTransparency = 1
bagScrolling.BorderSizePixel = 0
bagScrolling.CanvasSize = UDim2.new(2, 0, 0, 0)
bagScrolling.ScrollBarThickness = 4
bagScrolling.Parent = bagPanel

local bagLayout = Instance.new("UIListLayout")
bagLayout.FillDirection = Enum.FillDirection.Horizontal
bagLayout.Padding = UDim.new(0, 8)
bagLayout.Parent = bagScrolling

-- Row 2: 8 Tactical Placement Slot Buttons
local slotsRow = Instance.new("Frame")
slotsRow.Name = "TacticalSlotsRow"
slotsRow.Size = UDim2.new(1, -20, 0, 64)
slotsRow.Position = UDim2.fromOffset(10, 96)
slotsRow.BackgroundTransparency = 1
slotsRow.Parent = bagPanel

local slotsLayout = Instance.new("UIListLayout")
slotsLayout.FillDirection = Enum.FillDirection.Horizontal
slotsLayout.Padding = UDim.new(0, 6)
slotsLayout.Parent = slotsRow

local function refreshBagAndSlotsUI()
	-- Clear old bag units
	for _, child in ipairs(bagScrolling:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	-- Clear old slots
	for _, child in ipairs(slotsRow:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local rawBag = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.INVENTORY_JSON) :: string?) or "[]"
	local ok, bagList = pcall(function()
		return HttpService:JSONDecode(rawBag)
	end)
	local units: { BagUnit } = (ok and typeof(bagList) == "table") and bagList or {}
	local selectedUid = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID) :: string?) or ""

	-- Update scrolling width
	bagScrolling.CanvasSize = UDim2.new(0, math.max(#units * 168, 900), 0, 0)

	if #units == 0 then
		local emptyLbl = Instance.new("TextLabel")
		emptyLbl.Size = UDim2.new(1, 0, 1, 0)
		emptyLbl.BackgroundTransparency = 1
		emptyLbl.TextColor3 = Color3.fromRGB(150, 165, 190)
		emptyLbl.Font = Enum.Font.GothamBold
		emptyLbl.TextScaled = true
		emptyLbl.Text = "Bag is empty. Click [WANTED POSTER / GACHA] above to summon heroes!"
		emptyLbl.Parent = bagScrolling
	else
		for _, unit in ipairs(units) do
			local isSelected = (unit.Uid == selectedUid)
			local unitCard = Instance.new("Frame")
			unitCard.Size = UDim2.fromOffset(160, 54)
			unitCard.BackgroundColor3 = isSelected and Color3.fromRGB(42, 88, 62) or Color3.fromRGB(26, 30, 46)
			unitCard.BorderSizePixel = 0
			unitCard.Parent = bagScrolling

			local uCorner = Instance.new("UICorner")
			uCorner.CornerRadius = UDim.new(0, 8)
			uCorner.Parent = unitCard

			local uStroke = Instance.new("UIStroke")
			uStroke.Color = isSelected and Color3.fromRGB(75, 255, 140) or Color3.fromRGB(80, 95, 125)
			uStroke.Thickness = isSelected and 2 or 1
			uStroke.Parent = unitCard

			local selectBtn = Instance.new("TextButton")
			selectBtn.Size = UDim2.new(0.68, 0, 1, 0)
			selectBtn.BackgroundTransparency = 1
			selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			selectBtn.Font = Enum.Font.GothamBold
			selectBtn.TextScaled = true
			selectBtn.Text = string.format("%s\n[%s]", unit.Name, unit.Rarity)
			selectBtn.Parent = unitCard

			selectBtn.MouseButton1Click:Connect(function()
				local re = getPlacementActionRemote()
				if re then
					re:FireServer("SelectBagUnit", unit.Uid)
				end
			end)

			local sellBagBtn = Instance.new("TextButton")
			sellBagBtn.Size = UDim2.new(0.32, 0, 1, 0)
			sellBagBtn.Position = UDim2.fromScale(0.68, 0)
			sellBagBtn.BackgroundColor3 = Color3.fromRGB(205, 45, 55)
			sellBagBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			sellBagBtn.Font = Enum.Font.GothamBlack
			sellBagBtn.TextScaled = true
			sellBagBtn.Text = string.format("SELL\n+$%d", unit.SellValue or 150)
			sellBagBtn.Parent = unitCard

			local sellCorner = Instance.new("UICorner")
			sellCorner.CornerRadius = UDim.new(0, 6)
			sellCorner.Parent = sellBagBtn

			sellBagBtn.MouseButton1Click:Connect(function()
				local re = getPlacementActionRemote()
				if re then
					re:FireServer("SellFromBag", unit.Uid)
				end
			end)
		end
	end

	-- Render 8 Tactical Slot Buttons
	local towersFolder = Workspace:FindFirstChild("AnimeTowers")
	local slotList: { SlotDef } = GameConfig.PLACEMENT_SLOTS or {}

	for idx, slotSpec in ipairs(slotList) do
		local occupant: Model? = nil
		if towersFolder then
			for _, t in ipairs(towersFolder:GetChildren()) do
				if t:IsA("Model") and t:GetAttribute("SlotId") == slotSpec.SlotId then
					occupant = t
					break
				end
			end
		end

		local slotCard = Instance.new("Frame")
		slotCard.Size = UDim2.fromOffset(106, 58)
		slotCard.BackgroundColor3 = occupant and Color3.fromRGB(48, 38, 20) or Color3.fromRGB(20, 44, 34)
		slotCard.BorderSizePixel = 0
		slotCard.Parent = slotsRow

		local sCorner = Instance.new("UICorner")
		sCorner.CornerRadius = UDim.new(0, 8)
		sCorner.Parent = slotCard

		local sStroke = Instance.new("UIStroke")
		sStroke.Color = occupant and Color3.fromRGB(255, 190, 45) or Color3.fromRGB(40, 205, 110)
		sStroke.Thickness = 1
		sStroke.Parent = slotCard

		local occupantHeroName: string? = nil
		if occupant then
			local heroId = (occupant:GetAttribute("HeroId") :: string?) or "Tower"
			local hero = findHeroSpec(heroId)
			occupantHeroName = hero and hero.Name or heroId
		end

		local mainSlotBtn = Instance.new("TextButton")
		mainSlotBtn.Size = UDim2.new(1, 0, occupant and 0.54 or 1, 0)
		mainSlotBtn.BackgroundTransparency = 1
		mainSlotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		mainSlotBtn.Font = Enum.Font.GothamBold
		mainSlotBtn.TextScaled = true
		if occupant and occupantHeroName then
			mainSlotBtn.Text = string.format("S%d: %s\n[SWAP]", idx, occupantHeroName)
		else
			mainSlotBtn.Text = string.format("Slot %d: PLACE", idx)
		end
		mainSlotBtn.Parent = slotCard

		mainSlotBtn.MouseButton1Click:Connect(function()
			local re = getPlacementActionRemote()
			if re then
				re:FireServer("PlaceOrSwap", slotSpec.SlotId, selectedUid)
			end
		end)

		if occupant then
			-- Sub-button 1: Recall to Bag
			local recallBtn = Instance.new("TextButton")
			recallBtn.Size = UDim2.new(0.5, -2, 0.44, 0)
			recallBtn.Position = UDim2.new(0, 1, 0.54, 0)
			recallBtn.BackgroundColor3 = Color3.fromRGB(42, 115, 215)
			recallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			recallBtn.Font = Enum.Font.GothamBold
			recallBtn.TextScaled = true
			recallBtn.Text = "BAG"
			recallBtn.Parent = slotCard

			local rCorner = Instance.new("UICorner")
			rCorner.CornerRadius = UDim.new(0, 4)
			rCorner.Parent = recallBtn

			recallBtn.MouseButton1Click:Connect(function()
				local re = getPlacementActionRemote()
				if re then
					re:FireServer("StoreToBag", slotSpec.SlotId)
				end
			end)

			-- Sub-button 2: Sell Tower
			local sellSlotBtn = Instance.new("TextButton")
			sellSlotBtn.Size = UDim2.new(0.5, -2, 0.44, 0)
			sellSlotBtn.Position = UDim2.new(0.5, 1, 0.54, 0)
			sellSlotBtn.BackgroundColor3 = Color3.fromRGB(215, 45, 45)
			sellSlotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			sellSlotBtn.Font = Enum.Font.GothamBold
			sellSlotBtn.TextScaled = true
			sellSlotBtn.Text = "SELL"
			sellSlotBtn.Parent = slotCard

			local scCorner = Instance.new("UICorner")
			scCorner.CornerRadius = UDim.new(0, 4)
			scCorner.Parent = sellSlotBtn

			sellSlotBtn.MouseButton1Click:Connect(function()
				local re = getPlacementActionRemote()
				if re then
					re:FireServer("SellFromSlot", slotSpec.SlotId)
				end
			end)
		end
	end
end

-- =============================================================================
-- SUBSYSTEM 6: 3-CARD WAVE DRAFT MODAL (12 ROGUELIKE CARDS)
-- =============================================================================

local draftModal = Instance.new("Frame")
draftModal.Name = "WaveCardDraftModal"
draftModal.Size = UDim2.fromOffset(780, 340)
draftModal.Position = UDim2.new(0.5, -390, 0.5, -170)
draftModal.BackgroundColor3 = Color3.fromRGB(12, 14, 24)
draftModal.BorderSizePixel = 0
draftModal.Visible = false
draftModal.Parent = screenGui

local draftModalCorner = Instance.new("UICorner")
draftModalCorner.CornerRadius = UDim.new(0, 16)
draftModalCorner.Parent = draftModal

local draftModalStroke = Instance.new("UIStroke")
draftModalStroke.Color = Color3.fromRGB(255, 215, 60)
draftModalStroke.Thickness = 3
draftModalStroke.Parent = draftModal

local draftHeader = Instance.new("TextLabel")
draftHeader.Name = "DraftHeader"
draftHeader.Size = UDim2.new(1, -30, 0, 40)
draftHeader.Position = UDim2.fromOffset(15, 10)
draftHeader.BackgroundTransparency = 1
draftHeader.TextColor3 = Color3.fromRGB(255, 220, 65)
draftHeader.Font = Enum.Font.GothamBlack
draftHeader.TextScaled = true
draftHeader.Text = "⚡ WAVE CLEARED! CHOOSE 1 ROGUELIKE CARD ⚡"
draftHeader.Parent = draftModal

local cardsRow = Instance.new("Frame")
cardsRow.Name = "CardsRow"
cardsRow.Size = UDim2.new(1, -30, 0, 265)
cardsRow.Position = UDim2.fromOffset(15, 56)
cardsRow.BackgroundTransparency = 1
cardsRow.Parent = draftModal

local cardsLayout = Instance.new("UIListLayout")
cardsLayout.FillDirection = Enum.FillDirection.Horizontal
cardsLayout.Padding = UDim.new(0, 14)
cardsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
cardsLayout.Parent = cardsRow

local function populateThreeDraftCards()
	for _, c in ipairs(cardsRow:GetChildren()) do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end

	local pool: { CardDef } = GameConfig.CARD_POOL or {}
	local poolCopy = table.clone(pool)

	-- Fisher-Yates Shuffle
	for i = #poolCopy, 2, -1 do
		local j = math.random(1, i)
		poolCopy[i], poolCopy[j] = poolCopy[j], poolCopy[i]
	end

	local pickCount = math.min(3, #poolCopy)
	for i = 1, pickCount do
		local card = poolCopy[i]
		local cardBtn = Instance.new("TextButton")
		cardBtn.Name = "CardBtn_" .. card.Id
		cardBtn.Size = UDim2.fromOffset(236, 255)
		cardBtn.BackgroundColor3 = card.BgColor or Color3.fromRGB(28, 20, 38)
		cardBtn.Text = ""
		cardBtn.Parent = cardsRow

		local cCorner = Instance.new("UICorner")
		cCorner.CornerRadius = UDim.new(0, 12)
		cCorner.Parent = cardBtn

		local cStroke = Instance.new("UIStroke")
		cStroke.Color = card.BorderColor or Color3.fromRGB(255, 205, 50)
		cStroke.Thickness = 3
		cStroke.Parent = cardBtn

		local rarityLbl = Instance.new("TextLabel")
		rarityLbl.Size = UDim2.new(1, -16, 0, 28)
		rarityLbl.Position = UDim2.fromOffset(8, 8)
		rarityLbl.BackgroundTransparency = 1
		rarityLbl.TextColor3 = card.BorderColor or Color3.fromRGB(255, 205, 50)
		rarityLbl.Font = Enum.Font.GothamBlack
		rarityLbl.TextScaled = true
		rarityLbl.Text = string.format("[%s]\n%s", card.Rarity, card.Category)
		rarityLbl.Parent = cardBtn

		local titleLbl = Instance.new("TextLabel")
		titleLbl.Size = UDim2.new(1, -16, 0, 58)
		titleLbl.Position = UDim2.fromOffset(8, 42)
		titleLbl.BackgroundTransparency = 1
		titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		titleLbl.Font = Enum.Font.GothamBlack
		titleLbl.TextScaled = true
		titleLbl.Text = card.Title
		titleLbl.Parent = cardBtn

		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(1, -16, 0, 110)
		descLbl.Position = UDim2.fromOffset(8, 104)
		descLbl.BackgroundTransparency = 1
		descLbl.TextColor3 = Color3.fromRGB(220, 235, 255)
		descLbl.Font = Enum.Font.GothamBold
		descLbl.TextScaled = true
		descLbl.Text = card.Desc
		descLbl.Parent = cardBtn

		local selectBadge = Instance.new("TextLabel")
		selectBadge.Size = UDim2.new(1, -24, 0, 28)
		selectBadge.Position = UDim2.new(0, 12, 1, -34)
		selectBadge.BackgroundColor3 = card.BorderColor or Color3.fromRGB(255, 205, 50)
		selectBadge.TextColor3 = Color3.fromRGB(20, 20, 25)
		selectBadge.Font = Enum.Font.GothamBlack
		selectBadge.TextScaled = true
		selectBadge.Text = "SELECT CARD"
		selectBadge.Parent = cardBtn

		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 6)
		bCorner.Parent = selectBadge

		cardBtn.MouseButton1Click:Connect(function()
			local re = getCardDraftRemote()
			local rf = getUpgradeStatRemoteFunc()
			if re then
				re:FireServer(card.Id)
			elseif rf then
				pcall(function()
					rf:InvokeServer(card.Id)
				end)
			end
		end)
	end
end

-- =============================================================================
-- MASTER REACTIVE UI STATE SYNCHRONIZATION
-- =============================================================================

local lastRenderedDraws: number = 0

local function refreshAllUI()
	-- 1. Wave Status & Header
	local wave = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE) :: number?) or 1
	local waveStatus = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS) :: string?) or "READY"
	local prepCount = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN) :: number?) or 0
	local isGameOver = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) :: boolean?) or false
	local zombiesLeft = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING) :: number?) or 0

	if isGameOver then
		waveStatusLbl.TextColor3 = Color3.fromRGB(255, 60, 60)
		waveStatusLbl.Text = "💀 BASE DESTROYED! RESTARTING WAVE 1..."
	elseif prepCount > 0 or waveStatus == "PREP PHASE" then
		waveStatusLbl.TextColor3 = Color3.fromRGB(255, 215, 60)
		waveStatusLbl.Text = string.format("⏳ PREP PHASE: %ds | PLACE A TOWER ON FIELD TO START!", prepCount)
	else
		waveStatusLbl.TextColor3 = Color3.fromRGB(255, 220, 70)
		waveStatusLbl.Text = string.format("🌊 GRAND LINE WAVE %d | STATUS: %s | ENEMIES: %d", wave, waveStatus, zombiesLeft)
	end

	-- 2. Base HP Bar
	local curBaseHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) :: number?) or 1000
	local maxBaseHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP) :: number?) or 1000
	local hpRatio = math.clamp(curBaseHp / math.max(1, maxBaseHp), 0, 1)

	hpBarFill.Size = UDim2.new(hpRatio, 0, 1, 0)
	if hpRatio > 0.50 then
		hpBarFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	elseif hpRatio > 0.25 then
		hpBarFill.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
	else
		hpBarFill.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
	end
	hpBarText.Text = string.format("THOUSAND SUNNY BASE HP: %d / %d (%.0f%%)", curBaseHp, maxBaseHp, hpRatio * 100)

	-- 3. Player Stats & Resources
	local ls = localPlayer:FindFirstChild("leaderstats")
	local cashObj = ls and ls:FindFirstChild("Cash") :: IntValue?
	local currentCash = cashObj and cashObj.Value or ((localPlayer:GetAttribute("Cash") :: number?) or 500)

	local freeTickets = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.FREE_SUMMON_TICKETS) :: number?) or 0
	local rerollTokens = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
	local placedTowers = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.PLACED_TOWERS_COUNT) :: number?) or 0
	local maxTowers = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.MAX_PLACED_TOWERS) :: number?) or 4

	local curDmg = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) :: number?) or 50
	local curRng = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) :: number?) or 30
	local curCd = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) :: number?) or 1.15
	local curCrit = ((localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE) :: number?) or 0.08) * 100
	local curCritDmg = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_DAMAGE) :: number?) or 2.0
	local curSplash = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT) :: number?) or 7
	local curBounty = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.BOUNTY_MULT) :: number?) or 1.0
	local dps = math.floor(curDmg / math.max(0.12, curCd))

	statsSummaryLbl.Text = string.format(
		"💰 $%d | 🎟️ %d | 🪙 %d | 🗼 %d/%d | ⚔️ DMG: %d | 🎯 RNG: %d | ⚡ CD: %.2fs | 💥 CRIT: %.0f%% (%.2fx) | 🌊 AoE: %d | 🏴‍☠️ BOUNTY: %.1fx | DPS: %d",
		currentCash, freeTickets, rerollTokens, placedTowers, maxTowers,
		curDmg, curRng, curCd, curCrit, curCritDmg, curSplash, curBounty, dps
	)

	-- 4. Stat Upgrades Buttons (Levels, Costs & Affordability)
	local dmgLvl = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL) :: number?) or 1
	local rngLvl = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL) :: number?) or 1
	local spdLvl = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL) :: number?) or 1

	local dmgCost = math.floor(75 * math.pow(1.35, dmgLvl - 1))
	local rngCost = math.floor(60 * math.pow(1.30, rngLvl - 1))
	local spdCost = math.floor(90 * math.pow(1.40, spdLvl - 1))
	local minCd = (GameConfig.INITIAL_PLAYER_STATS and GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN) or 0.15

	btnDamage.Text = string.format("⚔️ DAMAGE Lv.%d\nCost: $%d | Next: %d DMG", dmgLvl, dmgCost, math.floor(curDmg * 1.35 + 10))
	btnDamage.BackgroundColor3 = (currentCash >= dmgCost) and Color3.fromRGB(28, 68, 48) or Color3.fromRGB(56, 32, 38)

	btnRange.Text = string.format("🎯 RANGE Lv.%d\nCost: $%d | Next: %d RNG", rngLvl, rngCost, curRng + 4)
	btnRange.BackgroundColor3 = (currentCash >= rngCost) and Color3.fromRGB(28, 68, 48) or Color3.fromRGB(56, 32, 38)

	if curCd <= minCd then
		btnSpeed.Text = string.format("⚡ SPEED [MAX]\nCooldown Limit: %.2fs", minCd)
		btnSpeed.BackgroundColor3 = Color3.fromRGB(44, 48, 56)
	else
		local nextCd = math.max(minCd, math.floor(curCd * 0.90 * 100) / 100)
		btnSpeed.Text = string.format("⚡ SPEED Lv.%d\nCost: $%d | Next: %.2fs CD", spdLvl, spdCost, nextCd)
		btnSpeed.BackgroundColor3 = (currentCash >= spdCost) and Color3.fromRGB(28, 68, 48) or Color3.fromRGB(56, 32, 38)
	end

	-- 5. Wanted Poster Modal Hero Display & Summon/Reroll Costs
	btnSummon.Text = (freeTickets > 0) and string.format("🎲 SUMMON (FREE x%d)", freeTickets) or "🎲 SUMMON ($100)"
	btnReroll.Text = (rerollTokens > 0) and string.format("🔄 REROLL (Token x%d)", rerollTokens) or "🔄 REROLL ($80)"

	local lastHeroId = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_HERO_ID) :: string?) or ""
	if lastHeroId ~= "" then
		local hero = findHeroSpec(lastHeroId)
		if hero then
			rolledHeroDisplay.TextColor3 = hero.PrimaryColor
			rolledHeroDisplay.Text = string.format(
				"✨ ROLLED: %s ✨\n[%s] — %s\n" ..
				"Damage Mult: %.2fx | Range Bonus: +%d | Cooldown: %.2fx | AoE: +%d\n" ..
				"Signature: %s (%s) | Sell Value: $%d",
				hero.Name, hero.Rarity, hero.Subtitle,
				hero.DamageMult, hero.RangeBonus, hero.CooldownMult, hero.SplashBonus,
				hero.AttackStyle, hero.Onomatopoeia, hero.SellValue
			)
		end
	else
		rolledHeroDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
		rolledHeroDisplay.Text = "WELCOME TO GRAND LINE!\n\nNo towers deployed on the map.\nPress [SUMMON HERO] below to recruit your first One Piece pirate!"
	end

	-- 6. 3-Card Wave Draft Modal Visibility & Sequential Refresh
	local pendingDraws = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) :: number?) or 0
	if pendingDraws > 0 then
		if not draftModal.Visible or lastRenderedDraws ~= pendingDraws then
			lastRenderedDraws = pendingDraws
			populateThreeDraftCards()
			draftModal.Visible = true
		end
		draftHeader.Text = string.format("⚡ WAVE CLEARED! CHOOSE 1 ROGUELIKE CARD (%d DRAWS LEFT) ⚡", pendingDraws)
	else
		lastRenderedDraws = 0
		draftModal.Visible = false
	end

	-- 7. Bag and 8-Slot Pad Status
	refreshBagAndSlotsUI()
end

-- =============================================================================
-- REACTIVE ATTRIBUTE & LIFECYCLE LISTENERS
-- =============================================================================

Workspace.AttributeChanged:Connect(refreshAllUI)
localPlayer.AttributeChanged:Connect(refreshAllUI)

task.spawn(function()
	local towersFolder = Workspace:WaitForChild("AnimeTowers", 30)
	if towersFolder then
		towersFolder.ChildAdded:Connect(refreshAllUI)
		towersFolder.ChildRemoved:Connect(refreshAllUI)
		refreshAllUI()
	end
end)

task.spawn(function()
	local ls = localPlayer:WaitForChild("leaderstats", 10)
	if ls then
		local cash = ls:WaitForChild("Cash", 10) :: IntValue?
		if cash then
			cash.Changed:Connect(refreshAllUI)
		end
	end
	refreshAllUI()
end)

refreshAllUI()
print("[UpgradeHUD] Anime Limitless Phase 3 Turnkey Client UI System loaded successfully.")
