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

local ViewsFolder = script.Parent:FindFirstChild("Views")
local MapSelectionView = if ViewsFolder and ViewsFolder:FindFirstChild("MapSelectionView") then require(ViewsFolder:FindFirstChild("MapSelectionView")) else nil
local LobbyHubView = if ViewsFolder and ViewsFolder:FindFirstChild("LobbyHubView") then require(ViewsFolder:FindFirstChild("LobbyHubView")) else nil

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
-- MINIMALIST FLAT UI THEME CONSTANTS & HERO ACRONYMS (PLAN-0009)
-- =============================================================================

local UI_THEME = {
	BgDark = Color3.fromRGB(14, 16, 22),
	BgCard = Color3.fromRGB(22, 25, 34),
	AccentGold = Color3.fromRGB(245, 195, 55),
	AccentCyan = Color3.fromRGB(60, 200, 255),
	AccentRed = Color3.fromRGB(235, 65, 85),
	TextLight = Color3.fromRGB(240, 244, 250),
	TextMuted = Color3.fromRGB(160, 170, 185),
}

local HERO_ACRONYMS: { [string]: { Acronym: string, Accent: Color3, Name: string, Cost: number } } = {
	["Tower_Luffy_G5"] = { Acronym = "LUF", Accent = Color3.fromRGB(255, 230, 110), Name = "LUFFY", Cost = 100 },
	["Tower_Zoro_KingOfHell"] = { Acronym = "ZOR", Accent = Color3.fromRGB(50, 225, 120), Name = "ZORO", Cost = 100 },
	["Tower_Sanji_Ifrit"] = { Acronym = "SAN", Accent = Color3.fromRGB(45, 140, 255), Name = "SANJI", Cost = 100 },
	["Tower_Shanks_Kamusari"] = { Acronym = "SHA", Accent = Color3.fromRGB(235, 45, 65), Name = "SHANKS", Cost = 100 },
	["Tower_Whitebeard_Gura"] = { Acronym = "WB", Accent = Color3.fromRGB(230, 245, 255), Name = "WHITEBEARD", Cost = 100 },
	["Tower_Ace_Entei"] = { Acronym = "ACE", Accent = Color3.fromRGB(255, 130, 30), Name = "ACE", Cost = 100 },
	["Tower_Law_KRoom"] = { Acronym = "LAW", Accent = Color3.fromRGB(80, 200, 255), Name = "LAW", Cost = 100 },
	["Tower_Kizaru_Pika"] = { Acronym = "KIZ", Accent = Color3.fromRGB(255, 245, 90), Name = "KIZARU", Cost = 100 },
}

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

local feedbackPort = playerGui:FindFirstChild("PresentationFeedback") :: BindableEvent?
if not feedbackPort then
	local be = Instance.new("BindableEvent")
	be.Name = "PresentationFeedback"
	be.Parent = playerGui
	feedbackPort = be
end

feedbackPort.Event:Connect(function(action: string, payload: any)
	if action == "Shake" then
		local intensity = payload and payload.intensity or 0.45
		local dur = payload and payload.duration or 0.25
		local prof = payload and payload.profile or "Explosive"
		local col = payload and payload.color or Color3.fromRGB(255, 255, 255)
		onCameraShakeReceived({
			Intensity = intensity,
			Duration = dur,
			ShakeProfile = prof,
			Color = col,
		})
	elseif action == "Flash" then
		local col = payload and payload.color or Color3.fromRGB(255, 255, 255)
		local dur = payload and payload.duration or 0.25
		triggerScreenFlash(col, dur)
	end
end)

---- =============================================================================
-- SUBSYSTEM 2: TOP STATUS PILL & EARLY WAVE START BUTTON (PLAN-0009)
-- =============================================================================

local topPill = Instance.new("Frame")
topPill.Name = "TopWaveBar"
topPill.Size = UDim2.new(0, 360, 0, 30)
topPill.Position = UDim2.new(0.5, -180, 0, 6)
topPill.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
topPill.BackgroundTransparency = 0.25
topPill.BorderSizePixel = 0
topPill.Parent = screenGui

local topPillCorner = Instance.new("UICorner")
topPillCorner.CornerRadius = UDim.new(1, 0)
topPillCorner.Parent = topPill

local topPillStroke = Instance.new("UIStroke")
topPillStroke.Color = Color3.fromRGB(60, 68, 85)
topPillStroke.Thickness = 1
topPillStroke.Parent = topPill

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusText"
statusLabel.Size = UDim2.new(1, -80, 1, 0)
statusLabel.Position = UDim2.new(0, 14, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 13
statusLabel.TextColor3 = Color3.fromRGB(240, 244, 250)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Text = "WAVE 1  •  HP 1000  •  $500"
statusLabel.Parent = topPill

local earlyStartBtn = Instance.new("TextButton")
earlyStartBtn.Name = "EarlyStartBtn"
earlyStartBtn.Size = UDim2.new(0, 64, 0, 22)
earlyStartBtn.Position = UDim2.new(1, -68, 0.5, -11)
earlyStartBtn.BackgroundColor3 = Color3.fromRGB(245, 195, 55)
earlyStartBtn.Font = Enum.Font.GothamBlack
earlyStartBtn.TextSize = 11
earlyStartBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
earlyStartBtn.Text = "START"
earlyStartBtn.Visible = false
earlyStartBtn.Parent = topPill

local earlyStartCorner = Instance.new("UICorner")
earlyStartCorner.CornerRadius = UDim.new(1, 0)
earlyStartCorner.Parent = earlyStartBtn

earlyStartBtn.MouseButton1Click:Connect(function()
	local rf = getUpgradeStatRemoteFunc()
	local re = getUpgradeEventRemote()
	if rf then
		pcall(function()
			rf:InvokeServer("EarlyStart")
		end)
	elseif re then
		re:FireServer("EarlyStart")
	end
	earlyStartBtn.Visible = false
end)

-- =============================================================================
-- SUBSYSTEM 3: COLLAPSIBLE MINI ACTION TOGGLES & STAT UPGRADE DRAWER (PLAN-0009)
-- =============================================================================

-- Mini Action Toggles Container (100x98 px at bottom-left)
local miniActionToggles = Instance.new("Frame")
miniActionToggles.Name = "MiniActionToggles"
miniActionToggles.Size = UDim2.new(0, 100, 0, 98)
miniActionToggles.Position = UDim2.new(0, 10, 1, -162)
miniActionToggles.BackgroundTransparency = 1
miniActionToggles.Parent = screenGui

local toggleUpgradeBtn = Instance.new("TextButton")
toggleUpgradeBtn.Name = "ToggleUpgradeBtn"
toggleUpgradeBtn.Size = UDim2.new(1, 0, 0, 28)
toggleUpgradeBtn.Position = UDim2.new(0, 0, 0, 0)
toggleUpgradeBtn.BackgroundColor3 = UI_THEME.BgDark
toggleUpgradeBtn.BackgroundTransparency = 0.2
toggleUpgradeBtn.Font = Enum.Font.GothamBold
toggleUpgradeBtn.TextSize = 11
toggleUpgradeBtn.TextColor3 = UI_THEME.AccentCyan
toggleUpgradeBtn.Text = "▲ STATS"
toggleUpgradeBtn.Parent = miniActionToggles

local uCorner = Instance.new("UICorner")
uCorner.CornerRadius = UDim.new(0, 6)
uCorner.Parent = toggleUpgradeBtn

local uStroke = Instance.new("UIStroke")
uStroke.Color = Color3.fromRGB(50, 70, 95)
uStroke.Thickness = 1
uStroke.Parent = toggleUpgradeBtn

local toggleGachaBtn = Instance.new("TextButton")
toggleGachaBtn.Name = "ToggleGachaBtn"
toggleGachaBtn.Size = UDim2.new(1, 0, 0, 28)
toggleGachaBtn.Position = UDim2.new(0, 0, 0, 34)
toggleGachaBtn.BackgroundColor3 = UI_THEME.BgDark
toggleGachaBtn.BackgroundTransparency = 0.2
toggleGachaBtn.Font = Enum.Font.GothamBold
toggleGachaBtn.TextSize = 11
toggleGachaBtn.TextColor3 = UI_THEME.AccentGold
toggleGachaBtn.Text = "★ SUMMON"
toggleGachaBtn.Parent = miniActionToggles

local gCorner = Instance.new("UICorner")
gCorner.CornerRadius = UDim.new(0, 6)
gCorner.Parent = toggleGachaBtn

local gStroke = Instance.new("UIStroke")
gStroke.Color = Color3.fromRGB(90, 80, 50)
gStroke.Thickness = 1
gStroke.Parent = toggleGachaBtn

local mapSelectionModal: Frame? = if MapSelectionView then MapSelectionView.Create(screenGui) else nil

local toggleMapBtn = Instance.new("TextButton")
toggleMapBtn.Name = "ToggleMapBtn"
toggleMapBtn.Size = UDim2.new(1, 0, 0, 28)
toggleMapBtn.Position = UDim2.new(0, 0, 0, 68)
toggleMapBtn.BackgroundColor3 = UI_THEME.BgDark
toggleMapBtn.BackgroundTransparency = 0.2
toggleMapBtn.Font = Enum.Font.GothamBold
toggleMapBtn.TextSize = 11
toggleMapBtn.TextColor3 = Color3.fromRGB(120, 200, 255)
toggleMapBtn.Text = "🗺 MAP"
toggleMapBtn.Parent = miniActionToggles

local mMapCorner = Instance.new("UICorner")
mMapCorner.CornerRadius = UDim.new(0, 6)
mMapCorner.Parent = toggleMapBtn

local mMapStroke = Instance.new("UIStroke")
mMapStroke.Color = Color3.fromRGB(60, 95, 140)
mMapStroke.Thickness = 1
mMapStroke.Parent = toggleMapBtn

toggleMapBtn.MouseButton1Click:Connect(function()
	if mapSelectionModal then
		mapSelectionModal.Visible = not mapSelectionModal.Visible
	end
end)

-- Collapsible Upgrade Shop Drawer (210x185 px at bottom-left, hidden by default)
local upgradePanel = Instance.new("Frame")
upgradePanel.Name = "UpgradeShopFrame"
upgradePanel.Size = UDim2.new(0, 210, 0, 185)
upgradePanel.Position = UDim2.new(0, 10, 1, -320)
upgradePanel.BackgroundColor3 = UI_THEME.BgDark
upgradePanel.BackgroundTransparency = 0.15
upgradePanel.BorderSizePixel = 0
upgradePanel.Visible = false -- Hidden by default to preserve >85% clear screen space
upgradePanel.Parent = screenGui

local upgradePanelCorner = Instance.new("UICorner")
upgradePanelCorner.CornerRadius = UDim.new(0, 8)
upgradePanelCorner.Parent = upgradePanel

local upgradePanelStroke = Instance.new("UIStroke")
upgradePanelStroke.Color = UI_THEME.AccentCyan
upgradePanelStroke.Thickness = 1.5
upgradePanelStroke.Parent = upgradePanel

local upgradeTitle = Instance.new("TextLabel")
upgradeTitle.Name = "UpgradeTitle"
upgradeTitle.Size = UDim2.new(1, -16, 0, 22)
upgradeTitle.Position = UDim2.fromOffset(8, 6)
upgradeTitle.BackgroundTransparency = 1
upgradeTitle.TextColor3 = UI_THEME.AccentCyan
upgradeTitle.Font = Enum.Font.GothamBlack
upgradeTitle.TextSize = 11
upgradeTitle.Text = "POWER UPGRADES"
upgradeTitle.Parent = upgradePanel

-- 3 Upgrade Buttons Container
local btnDamage = Instance.new("TextButton")
btnDamage.Name = "UpgradeDamageBtn"
btnDamage.Size = UDim2.new(1, -16, 0, 44)
btnDamage.Position = UDim2.fromOffset(8, 32)
btnDamage.BackgroundColor3 = Color3.fromRGB(28, 68, 48)
btnDamage.TextColor3 = UI_THEME.TextLight
btnDamage.Font = Enum.Font.GothamBold
btnDamage.TextSize = 10
btnDamage.Text = "⚔️ DAMAGE Lv.1\nCost: $75 | +10 DMG"
btnDamage.Parent = upgradePanel

local btnDmgCorner = Instance.new("UICorner")
btnDmgCorner.CornerRadius = UDim.new(0, 6)
btnDmgCorner.Parent = btnDamage

local btnRange = Instance.new("TextButton")
btnRange.Name = "UpgradeRangeBtn"
btnRange.Size = UDim2.new(1, -16, 0, 44)
btnRange.Position = UDim2.fromOffset(8, 80)
btnRange.BackgroundColor3 = Color3.fromRGB(28, 68, 48)
btnRange.TextColor3 = UI_THEME.TextLight
btnRange.Font = Enum.Font.GothamBold
btnRange.TextSize = 10
btnRange.Text = "🎯 RANGE Lv.1\nCost: $60 | +4 STUDS"
btnRange.Parent = upgradePanel

local btnRngCorner = Instance.new("UICorner")
btnRngCorner.CornerRadius = UDim.new(0, 6)
btnRngCorner.Parent = btnRange

local btnSpeed = Instance.new("TextButton")
btnSpeed.Name = "UpgradeSpeedBtn"
btnSpeed.Size = UDim2.new(1, -16, 0, 44)
btnSpeed.Position = UDim2.fromOffset(8, 128)
btnSpeed.BackgroundColor3 = Color3.fromRGB(28, 68, 48)
btnSpeed.TextColor3 = UI_THEME.TextLight
btnSpeed.Font = Enum.Font.GothamBold
btnSpeed.TextSize = 10
btnSpeed.Text = "⚡ SPEED Lv.1\nCost: $90 | -10% CD"
btnSpeed.Parent = upgradePanel

local btnSpdCorner = Instance.new("UICorner")
btnSpdCorner.CornerRadius = UDim.new(0, 6)
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

toggleUpgradeBtn.MouseButton1Click:Connect(function()
	upgradePanel.Visible = not upgradePanel.Visible
end)

-- =============================================================================
-- SUBSYSTEM 4: CENTRAL WANTED POSTER GACHA MODAL
-- =============================================================================

local summonModal = Instance.new("Frame")
summonModal.Name = "CentralWantedGachaModal"
summonModal.Size = UDim2.fromOffset(500, 330)
summonModal.Position = UDim2.new(0.5, -250, 0.5, -165)
summonModal.BackgroundColor3 = UI_THEME.BgDark
summonModal.BackgroundTransparency = 0.15
summonModal.BorderSizePixel = 0
summonModal.Visible = false -- PLAN-0009: Hidden by default, toggled via [★ SUMMON]
summonModal.Parent = screenGui

local modalCorner = Instance.new("UICorner")
modalCorner.CornerRadius = UDim.new(0, 14)
modalCorner.Parent = summonModal

local modalStroke = Instance.new("UIStroke")
modalStroke.Color = UI_THEME.AccentGold
modalStroke.Thickness = 2
modalStroke.Parent = summonModal

local modalHeader = Instance.new("TextLabel")
modalHeader.Name = "ModalHeader"
modalHeader.Size = UDim2.new(1, -20, 0, 32)
modalHeader.Position = UDim2.fromOffset(10, 8)
modalHeader.BackgroundTransparency = 1
modalHeader.TextColor3 = UI_THEME.AccentGold
modalHeader.Font = Enum.Font.GothamBlack
modalHeader.TextScaled = true
modalHeader.Text = "🏴‍☠️ GRAND LINE WANTED POSTER GACHA 🏴‍☠️"
modalHeader.Parent = summonModal

local wantedPosterCard = Instance.new("Frame")
wantedPosterCard.Name = "WantedPosterCard"
wantedPosterCard.Size = UDim2.new(1, -32, 0, 170)
wantedPosterCard.Position = UDim2.fromOffset(16, 44)
wantedPosterCard.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
wantedPosterCard.BorderSizePixel = 0
wantedPosterCard.Parent = summonModal

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 8)
cardCorner.Parent = wantedPosterCard

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = UI_THEME.AccentGold
cardStroke.Thickness = 1.5
cardStroke.Parent = wantedPosterCard

local rolledHeroDisplay = Instance.new("TextLabel")
rolledHeroDisplay.Name = "RolledHeroDisplay"
rolledHeroDisplay.Size = UDim2.new(1, -16, 1, -16)
rolledHeroDisplay.Position = UDim2.fromOffset(8, 8)
rolledHeroDisplay.BackgroundTransparency = 1
rolledHeroDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
rolledHeroDisplay.Font = Enum.Font.GothamBlack
rolledHeroDisplay.TextScaled = true
rolledHeroDisplay.Text = "WELCOME TO GRAND LINE!\n\nNo towers deployed on the map.\nPress [SUMMON HERO] below to recruit your first One Piece pirate!"
rolledHeroDisplay.Parent = wantedPosterCard

-- Action Buttons Row
local btnSummon = Instance.new("TextButton")
btnSummon.Name = "BtnSummon"
btnSummon.Size = UDim2.fromOffset(226, 46)
btnSummon.Position = UDim2.fromOffset(16, 222)
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
btnReroll.Size = UDim2.fromOffset(226, 46)
btnReroll.Position = UDim2.fromOffset(258, 222)
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
btnCloseModal.Size = UDim2.new(1, -32, 0, 40)
btnCloseModal.Position = UDim2.fromOffset(16, 276)
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

toggleGachaBtn.MouseButton1Click:Connect(function()
	summonModal.Visible = not summonModal.Visible
end)

-- =============================================================================
-- SUBSYSTEM 5: BOTTOM COMPACT HERO DOCK & BAG TRAY (PLAN-0009)
-- =============================================================================

-- 1. Compact Hero Dock (404x52 px centered at bottom Y = 1 - 58px)
local heroDock = Instance.new("Frame")
heroDock.Name = "CompactHeroDock"
heroDock.Size = UDim2.new(0, 404, 0, 52)
heroDock.Position = UDim2.new(0.5, -202, 1, -58)
heroDock.BackgroundColor3 = UI_THEME.BgDark
heroDock.BackgroundTransparency = 0.25
heroDock.BorderSizePixel = 0
heroDock.Parent = screenGui

local heroDockCorner = Instance.new("UICorner")
heroDockCorner.CornerRadius = UDim.new(0, 10)
heroDockCorner.Parent = heroDock

local heroDockStroke = Instance.new("UIStroke")
heroDockStroke.Color = Color3.fromRGB(55, 62, 78)
heroDockStroke.Thickness = 1
heroDockStroke.Parent = heroDock

type DockSlotEntry = {
	Button: TextButton,
	Stroke: UIStroke,
	Conn1: RBXScriptConnection?,
	Conn2: RBXScriptConnection?,
}

-- Pre-instantiate 8 tactical slot buttons inside dock
local dockSlotBtns: { [number]: DockSlotEntry } = {}
for i = 1, 8 do
	local btn = Instance.new("TextButton")
	btn.Name = "Slot_" .. i
	btn.Size = UDim2.new(0, 44, 0, 44)
	btn.Position = UDim2.new(0, 6 + (i - 1) * 49, 0, 4)
	btn.BackgroundColor3 = UI_THEME.BgCard
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.TextColor3 = UI_THEME.TextLight
	btn.Text = "-"
	btn.Parent = heroDock

	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(0, 6)
	sCorner.Parent = btn

	local sStroke = Instance.new("UIStroke")
	sStroke.Color = Color3.fromRGB(70, 78, 95)
	sStroke.Thickness = 1
	sStroke.Parent = btn

	dockSlotBtns[i] = { Button = btn, Stroke = sStroke, Conn1 = nil, Conn2 = nil }
end

-- 2. Compact Collapsible Bag Tray (attached right above dock at UDim2.new(0.5, -202, 1, -122), height 58 px)
local bagPanel = Instance.new("Frame")
bagPanel.Name = "BottomBagAndSlotPanel"
bagPanel.Size = UDim2.new(0, 404, 0, 58)
bagPanel.Position = UDim2.new(0.5, -202, 1, -122)
bagPanel.BackgroundColor3 = UI_THEME.BgDark
bagPanel.BackgroundTransparency = 0.20
bagPanel.BorderSizePixel = 0
bagPanel.Visible = false -- Auto-opens when units are in bag or summon modal opened
bagPanel.Parent = screenGui

local bagPanelCorner = Instance.new("UICorner")
bagPanelCorner.CornerRadius = UDim.new(0, 8)
bagPanelCorner.Parent = bagPanel

local bagPanelStroke = Instance.new("UIStroke")
bagPanelStroke.Color = UI_THEME.AccentCyan
bagPanelStroke.Thickness = 1
bagPanelStroke.Parent = bagPanel

local bagScrolling = Instance.new("ScrollingFrame")
bagScrolling.Name = "BagScrollingTray"
bagScrolling.Size = UDim2.new(1, -8, 1, -8)
bagScrolling.Position = UDim2.fromOffset(4, 4)
bagScrolling.BackgroundTransparency = 1
bagScrolling.BorderSizePixel = 0
bagScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
bagScrolling.ScrollBarThickness = 3
bagScrolling.Parent = bagPanel

local bagLayout = Instance.new("UIListLayout")
bagLayout.FillDirection = Enum.FillDirection.Horizontal
bagLayout.Padding = UDim.new(0, 6)
bagLayout.Parent = bagScrolling

local function refreshBagAndSlotsUI()
	-- Clear old bag units
	for _, child in ipairs(bagScrolling:GetChildren()) do
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

	-- Update scrolling width & bag drawer visibility
	bagScrolling.CanvasSize = UDim2.new(0, math.max(#units * 140, 390), 0, 0)
	bagPanel.Visible = (#units > 0 and (selectedUid ~= "" or summonModal.Visible))

	for _, unit in ipairs(units) do
		local isSelected = (unit.Uid == selectedUid)
		local unitCard = Instance.new("Frame")
		unitCard.Size = UDim2.fromOffset(130, 48)
		unitCard.BackgroundColor3 = isSelected and Color3.fromRGB(42, 88, 62) or Color3.fromRGB(26, 30, 46)
		unitCard.BorderSizePixel = 0
		unitCard.Parent = bagScrolling

		local uCorner = Instance.new("UICorner")
		uCorner.CornerRadius = UDim.new(0, 6)
		uCorner.Parent = unitCard

		local uStroke = Instance.new("UIStroke")
		uStroke.Color = isSelected and Color3.fromRGB(75, 255, 140) or Color3.fromRGB(80, 95, 125)
		uStroke.Thickness = isSelected and 2 or 1
		uStroke.Parent = unitCard

		local selectBtn = Instance.new("TextButton")
		selectBtn.Size = UDim2.new(0.65, 0, 1, 0)
		selectBtn.BackgroundTransparency = 1
		selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		selectBtn.Font = Enum.Font.GothamBold
		selectBtn.TextSize = 10
		selectBtn.Text = string.format("%s\n[%s]", unit.Name, unit.Rarity)
		selectBtn.Parent = unitCard

		selectBtn.MouseButton1Click:Connect(function()
			local re = getPlacementActionRemote()
			if re then
				re:FireServer("SelectBagUnit", unit.Uid)
			end
		end)

		local sellBagBtn = Instance.new("TextButton")
		sellBagBtn.Size = UDim2.new(0.35, 0, 1, 0)
		sellBagBtn.Position = UDim2.fromScale(0.65, 0)
		sellBagBtn.BackgroundColor3 = Color3.fromRGB(205, 45, 55)
		sellBagBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		sellBagBtn.Font = Enum.Font.GothamBlack
		sellBagBtn.TextSize = 10
		sellBagBtn.Text = string.format("SELL\n+$%d", unit.SellValue or 150)
		sellBagBtn.Parent = unitCard

		local sellCorner = Instance.new("UICorner")
		sellCorner.CornerRadius = UDim.new(0, 4)
		sellCorner.Parent = sellBagBtn

		sellBagBtn.MouseButton1Click:Connect(function()
			local re = getPlacementActionRemote()
			if re then
				re:FireServer("SellFromBag", unit.Uid)
			end
		end)
	end

	-- Render 8 Tactical Slot Buttons inside CompactHeroDock
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

		local slotEntry = dockSlotBtns[idx]
		if slotEntry then
			local btn = slotEntry.Button
			local stroke = slotEntry.Stroke

			if occupant then
				local heroId = (occupant:GetAttribute("HeroId") :: string?) or "Tower"
				local info = HERO_ACRONYMS[heroId]
				local acronym = info and info.Acronym or string.sub(heroId, 7, 9)
				local accent = info and info.Accent or Color3.fromRGB(255, 205, 50)
				stroke.Color = accent
				btn.TextColor3 = accent
				btn.Text = string.format("%s\nS%d", acronym, idx)
			else
				stroke.Color = Color3.fromRGB(70, 78, 95)
				btn.TextColor3 = (selectedUid ~= "") and Color3.fromRGB(80, 240, 140) or UI_THEME.TextMuted
				btn.Text = (selectedUid ~= "") and string.format("+\n$%d", 100) or "-"
			end

			-- Disconnect old connections to prevent leaks
			if slotEntry.Conn1 then
				slotEntry.Conn1:Disconnect()
				slotEntry.Conn1 = nil
			end
			if slotEntry.Conn2 then
				slotEntry.Conn2:Disconnect()
				slotEntry.Conn2 = nil
			end

			-- Slot Click Actions (Atomic Place/Swap, Recall to Bag, and Sell)
			slotEntry.Conn1 = btn.MouseButton1Click:Connect(function()
				local re = getPlacementActionRemote()
				if re then
					if occupant and selectedUid == "" then
						re:FireServer("StoreToBag", slotSpec.SlotId)
					else
						re:FireServer("PlaceOrSwap", slotSpec.SlotId, selectedUid)
					end
				end
			end)

			slotEntry.Conn2 = btn.MouseButton2Click:Connect(function()
				local re = getPlacementActionRemote()
				if re and occupant then
					re:FireServer("SellFromSlot", slotSpec.SlotId)
				end
			end)
		end
	end
end

-- =============================================================================
-- SUBSYSTEM 6: 3-CARD WAVE DRAFT MODAL (12 ROGUELIKE CARDS) (PLAN-0009)
-- =============================================================================

local draftModal = Instance.new("Frame")
draftModal.Name = "WaveCardDraftModal"
draftModal.Size = UDim2.new(0, 500, 0, 175)
draftModal.Position = UDim2.new(0.5, -250, 0, 44)
draftModal.BackgroundColor3 = UI_THEME.BgDark
draftModal.BackgroundTransparency = 0.15
draftModal.BorderSizePixel = 0
draftModal.Visible = false
draftModal.Parent = screenGui

local draftModalCorner = Instance.new("UICorner")
draftModalCorner.CornerRadius = UDim.new(0, 10)
draftModalCorner.Parent = draftModal

local draftModalStroke = Instance.new("UIStroke")
draftModalStroke.Color = UI_THEME.AccentGold
draftModalStroke.Thickness = 1.5
draftModalStroke.Parent = draftModal

local draftHeader = Instance.new("TextLabel")
draftHeader.Name = "DraftHeader"
draftHeader.Size = UDim2.new(1, -140, 0, 24)
draftHeader.Position = UDim2.new(0, 12, 0, 4)
draftHeader.BackgroundTransparency = 1
draftHeader.TextColor3 = UI_THEME.AccentGold
draftHeader.Font = Enum.Font.GothamBold
draftHeader.TextSize = 12
draftHeader.TextXAlignment = Enum.TextXAlignment.Left
draftHeader.Text = "SELECT WAVE UPGRADE CARD"
draftHeader.Parent = draftModal

local collapseToggleBtn = Instance.new("TextButton")
collapseToggleBtn.Name = "CollapseToggleBtn"
collapseToggleBtn.Size = UDim2.new(0, 24, 0, 20)
collapseToggleBtn.Position = UDim2.new(1, -126, 0, 6)
collapseToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
collapseToggleBtn.Font = Enum.Font.GothamBold
collapseToggleBtn.TextSize = 11
collapseToggleBtn.TextColor3 = UI_THEME.TextLight
collapseToggleBtn.Text = "[-]"
collapseToggleBtn.Parent = draftModal

local ctCorner = Instance.new("UICorner")
ctCorner.CornerRadius = UDim.new(0, 4)
ctCorner.Parent = collapseToggleBtn

local rerollBtn = Instance.new("TextButton")
rerollBtn.Name = "RerollCardsBtn"
rerollBtn.Size = UDim2.new(0, 88, 0, 20)
rerollBtn.Position = UDim2.new(1, -96, 0, 6)
rerollBtn.BackgroundColor3 = Color3.fromRGB(45, 85, 165)
rerollBtn.Font = Enum.Font.GothamBold
rerollBtn.TextSize = 10
rerollBtn.TextColor3 = UI_THEME.TextLight
rerollBtn.Text = "Reroll ($50)"
rerollBtn.Parent = draftModal

local rCorner = Instance.new("UICorner")
rCorner.CornerRadius = UDim.new(0, 4)
rCorner.Parent = rerollBtn

local cardsContainer = Instance.new("Frame")
cardsContainer.Name = "CardsContainer"
cardsContainer.Size = UDim2.new(1, 0, 0, 140)
cardsContainer.Position = UDim2.new(0, 0, 0, 30)
cardsContainer.BackgroundTransparency = 1
cardsContainer.Parent = draftModal

local isDraftCollapsed = false
collapseToggleBtn.MouseButton1Click:Connect(function()
	isDraftCollapsed = not isDraftCollapsed
	if isDraftCollapsed then
		draftModal.Size = UDim2.new(0, 500, 0, 30)
		cardsContainer.Visible = false
		collapseToggleBtn.Text = "[+]"
	else
		draftModal.Size = UDim2.new(0, 500, 0, 175)
		cardsContainer.Visible = true
		collapseToggleBtn.Text = "[-]"
	end
end)

local function populateThreeDraftCards()
	for _, c in ipairs(cardsContainer:GetChildren()) do
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
		cardBtn.Name = "UpgradeCard_" .. i
		cardBtn.Size = UDim2.new(0, 154, 0, 134)
		cardBtn.Position = UDim2.new(0, 10 + (i - 1) * 163, 0, 2)
		cardBtn.BackgroundColor3 = card.BgColor or UI_THEME.BgCard
		cardBtn.Text = ""
		cardBtn.Parent = cardsContainer

		local cCorner = Instance.new("UICorner")
		cCorner.CornerRadius = UDim.new(0, 8)
		cCorner.Parent = cardBtn

		local cStroke = Instance.new("UIStroke")
		cStroke.Thickness = 1.5
		cStroke.Color = card.BorderColor or UI_THEME.AccentGold
		cStroke.Parent = cardBtn

		local title = Instance.new("TextLabel")
		title.Name = "CardTitle"
		title.Size = UDim2.new(1, -12, 0, 36)
		title.Position = UDim2.new(0, 6, 0, 8)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBlack
		title.TextSize = 12
		title.TextWrapped = true
		title.TextColor3 = UI_THEME.TextLight
		title.Text = card.Title
		title.Parent = cardBtn

		local desc = Instance.new("TextLabel")
		desc.Name = "CardDesc"
		desc.Size = UDim2.new(1, -12, 0, 74)
		desc.Position = UDim2.new(0, 6, 0, 48)
		desc.BackgroundTransparency = 1
		desc.Font = Enum.Font.GothamMedium
		desc.TextSize = 11
		desc.TextWrapped = true
		desc.TextColor3 = Color3.fromRGB(110, 240, 155)
		desc.Text = card.Desc
		desc.Parent = cardBtn

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

rerollBtn.MouseButton1Click:Connect(function()
	local rf = getUpgradeStatRemoteFunc()
	local re = getUpgradeEventRemote()
	if rf then
		task.spawn(function()
			local ok, res = pcall(function()
				return rf:InvokeServer("RerollCards")
			end)
			if ok and typeof(res) == "table" and res.success then
				populateThreeDraftCards()
			end
		end)
	elseif re then
		re:FireServer("RerollCards")
		populateThreeDraftCards()
	end
end)

-- =============================================================================
-- MASTER REACTIVE UI STATE SYNCHRONIZATION
-- =============================================================================

local lastRenderedDraws: number = 0

local function refreshAllUI()
	-- 1. Wave Status & Header (Top Status Pill Single-Line Format)
	local wave = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE) :: number?) or 1
	local waveStatus = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS) :: string?) or "READY"
	local prepCount = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN) :: number?) or 0
	local isGameOver = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) :: boolean?) or false
	local curBaseHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) :: number?) or 1000

	local ls = localPlayer:FindFirstChild("leaderstats")
	local cashObj = ls and ls:FindFirstChild("Cash") :: IntValue?
	local currentCash = cashObj and cashObj.Value or ((localPlayer:GetAttribute("Cash") :: number?) or 500)

	if isGameOver then
		statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
		statusLabel.Text = "💀 BASE DESTROYED! RESTARTING WAVE 1..."
		earlyStartBtn.Visible = false
	elseif prepCount > 0 or waveStatus == "PREP PHASE" then
		statusLabel.TextColor3 = Color3.fromRGB(255, 215, 60)
		statusLabel.Text = string.format("⏳ PREP: %ds  •  HP %d  •  $%d", prepCount, curBaseHp, currentCash)
		earlyStartBtn.Visible = true
	else
		statusLabel.TextColor3 = Color3.fromRGB(240, 244, 250)
		statusLabel.Text = string.format("WAVE %d  •  HP %d  •  $%d", wave, curBaseHp, currentCash)
		earlyStartBtn.Visible = false
	end

	-- 2. Player Stats & Resources
	local freeTickets = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.FREE_SUMMON_TICKETS) :: number?) or 0
	local rerollTokens = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
	local curDmg = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) :: number?) or 50
	local curRng = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) :: number?) or 30
	local curCd = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) :: number?) or 1.15
	local dps = math.floor(curDmg / math.max(0.12, curCd))
	upgradeTitle.Text = string.format("POWER UPGRADES (DPS: %d)", dps)

	-- 3. Stat Upgrades Buttons (Levels, Costs & Affordability)
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

	-- 4. Wanted Poster Modal Hero Display & Summon/Reroll Costs
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

	-- 5. 3-Card Wave Draft Modal Visibility & Sequential Refresh
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

	-- 6. Bag and 8-Slot Pad Status
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
