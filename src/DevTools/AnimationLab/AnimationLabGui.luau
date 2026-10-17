--!strict
-- src/DevTools/AnimationLab/AnimationLabGui.luau
-- Anime Limitless Tower Defense — Phase 6 Interactive Animation & VFX Lab Dashboard
-- Full interactive developer GUI: 19 Asset Explorer, 8-State Animation Transport,
-- 6-Layer VFX Inspector, Orbit Camera Toolbar, and Stress Benchmark Controls.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LabConfig = require(script.Parent:WaitForChild("LabConfig")) :: any
local ModelValidator = require(script.Parent:WaitForChild("ModelValidator")) :: any
local OrbitCameraController = require(script.Parent:WaitForChild("OrbitCameraController")) :: any
local TimelineController = require(script.Parent:WaitForChild("TimelineController")) :: any
local VFXInspector = require(script.Parent:WaitForChild("VFXInspector")) :: any
local StressTestRunner = require(script.Parent:WaitForChild("StressTestRunner")) :: any

local AnimationLabGui = {}

function AnimationLabGui.Create(): ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AnimationLabGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 999

	local currentSelectedAssetId: string? = nil
	local currentSelectedModel: Model? = nil

	-- Main Canvas Container
	local mainCanvas = Instance.new("Frame")
	mainCanvas.Name = "MainCanvas"
	mainCanvas.Size = UDim2.new(1, 0, 1, 0)
	mainCanvas.BackgroundTransparency = 1
	mainCanvas.Parent = screenGui

	-- 1. Top Header Bar
	local header = Instance.new("Frame")
	header.Name = "TopHeaderBar"
	header.Size = UDim2.new(1, 0, 0, 48)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
	header.BorderSizePixel = 0
	header.Parent = mainCanvas

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(0, 480, 1, 0)
	titleLabel.Position = UDim2.new(0, 16, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "ANIME LIMITLESS TD — ANIMATION & VFX LAB"
	titleLabel.TextColor3 = Color3.fromRGB(245, 185, 60)
	titleLabel.TextSize = 16
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = header

	local selectedAssetLabel = Instance.new("TextLabel")
	selectedAssetLabel.Name = "SelectedAssetLabel"
	selectedAssetLabel.Size = UDim2.new(0, 300, 1, 0)
	selectedAssetLabel.Position = UDim2.new(0, 500, 0, 0)
	selectedAssetLabel.BackgroundTransparency = 1
	selectedAssetLabel.Text = "No Asset Selected"
	selectedAssetLabel.TextColor3 = Color3.fromRGB(160, 200, 255)
	selectedAssetLabel.TextSize = 13
	selectedAssetLabel.Font = Enum.Font.GothamMedium
	selectedAssetLabel.TextXAlignment = Enum.TextXAlignment.Left
	selectedAssetLabel.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 36, 0, 36)
	closeBtn.Position = UDim2.new(1, -44, 0, 6)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 14
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = header
	local cbCorner = Instance.new("UICorner")
	cbCorner.CornerRadius = UDim.new(0, 6)
	cbCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		OrbitCameraController.Deactivate()
		TimelineController.Stop()
		local commandRemote = ReplicatedStorage:FindFirstChild("AnimationLabCommand") :: RemoteFunction?
		if commandRemote then
			pcall(function()
				commandRemote:InvokeServer("CloseSession")
			end)
		end
		screenGui:Destroy()
	end)

	-- 2. Left Sidebar: Model Explorer (Width: 260px)
	local leftSidebar = Instance.new("Frame")
	leftSidebar.Name = "LeftSidebar_ModelExplorer"
	leftSidebar.Size = UDim2.new(0, 260, 1, -48)
	leftSidebar.Position = UDim2.new(0, 0, 0, 48)
	leftSidebar.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
	leftSidebar.BorderSizePixel = 0
	leftSidebar.Parent = mainCanvas

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Size = UDim2.new(1, -20, 0, 32)
	searchBox.Position = UDim2.new(0, 10, 0, 10)
	searchBox.BackgroundColor3 = Color3.fromRGB(30, 34, 46)
	searchBox.PlaceholderText = "Search 19 assets..."
	searchBox.Text = ""
	searchBox.TextColor3 = Color3.fromRGB(240, 240, 240)
	searchBox.TextSize = 12
	searchBox.Font = Enum.Font.Gotham
	searchBox.Parent = leftSidebar
	local sbCorner = Instance.new("UICorner")
	sbCorner.CornerRadius = UDim.new(0, 6)
	sbCorner.Parent = searchBox

	local modelList = Instance.new("ScrollingFrame")
	modelList.Name = "ModelList"
	modelList.Size = UDim2.new(1, -20, 1, -55)
	modelList.Position = UDim2.new(0, 10, 0, 48)
	modelList.BackgroundTransparency = 1
	modelList.ScrollBarThickness = 4
	modelList.CanvasSize = UDim2.new(0, 0, 0, 720)
	modelList.Parent = leftSidebar

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = modelList

	local assetButtons: { [string]: Frame } = {}

	-- Populate 19 Assets
	local orderedAssetIds = {
		"Luffy", "Zoro", "Nami", "Usopp", "Sanji", "Chopper", "Robin",
		"Shanks", "Whitebeard", "Ace", "Law", "Kizaru",
		"PirateGrunt", "SoruAssassin", "HakiBrute", "YonkoBoss",
		"AnimeBaseCrystal", "EnemySpawnGate", "PlacementPadTemplate",
	}

	local function selectAsset(assetId: string)
		currentSelectedAssetId = assetId
		selectedAssetLabel.Text = "Selected: " .. assetId

		local commandRemote = ReplicatedStorage:FindFirstChild("AnimationLabCommand") :: RemoteFunction?
		if commandRemote then
			pcall(function()
				commandRemote:InvokeServer("LoadModel", { assetId = assetId, scale = 1.0 })
			end)
		end

		local template = ModelValidator.ResolveModelTemplate(assetId)
		if template then
			currentSelectedModel = template
			local entry = LabConfig.ASSET_CATALOG[assetId]
			if entry and not entry.isStaticMapAsset then
				TimelineController.BindModel(template, nil)
				VFXInspector.BindModel(template, nil)
			end
		end
	end

	for idx, assetId in ipairs(orderedAssetIds) do
		local entry = LabConfig.ASSET_CATALOG[assetId]
		local btnFrame = Instance.new("Frame")
		btnFrame.Name = "Asset_" .. assetId
		btnFrame.Size = UDim2.new(1, 0, 0, 34)
		btnFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
		btnFrame.BorderSizePixel = 0
		btnFrame.LayoutOrder = idx
		btnFrame.Parent = modelList

		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 6)
		bCorner.Parent = btnFrame

		local textBtn = Instance.new("TextButton")
		textBtn.Size = UDim2.new(1, -60, 1, 0)
		textBtn.Position = UDim2.new(0, 8, 0, 0)
		textBtn.BackgroundTransparency = 1
		textBtn.Font = Enum.Font.GothamMedium
		textBtn.TextSize = 12
		textBtn.TextColor3 = Color3.fromRGB(230, 235, 245)
		textBtn.TextXAlignment = Enum.TextXAlignment.Left
		textBtn.Text = assetId
		textBtn.Parent = btnFrame

		local tagLabel = Instance.new("TextLabel")
		tagLabel.Size = UDim2.new(0, 50, 0, 18)
		tagLabel.Position = UDim2.new(1, -54, 0.5, -9)
		tagLabel.BackgroundColor3 = if entry and entry.isStaticMapAsset then Color3.fromRGB(60, 60, 70) else Color3.fromRGB(45, 80, 140)
		tagLabel.Font = Enum.Font.GothamBold
		tagLabel.TextSize = 9
		tagLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		tagLabel.Text = if entry and entry.isStaticMapAsset then "MAP" else (if entry and entry.category == "EnemyModels" then "ENEMY" else "HERO")
		tagLabel.Parent = btnFrame
		local tCorner = Instance.new("UICorner")
		tCorner.CornerRadius = UDim.new(0, 4)
		tCorner.Parent = tagLabel

		textBtn.MouseButton1Click:Connect(function()
			selectAsset(assetId)
		end)

		assetButtons[assetId] = btnFrame
	end

	-- Search filter listener
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local query = string.lower(searchBox.Text)
		for assetId, frame in pairs(assetButtons) do
			if query == "" or string.find(string.lower(assetId), query) ~= nil then
				frame.Visible = true
			else
				frame.Visible = false
			end
		end
	end)

	-- 3. Center Camera Toolbar
	local centerOverlay = Instance.new("Frame")
	centerOverlay.Name = "CenterStage_OverlayControls"
	centerOverlay.Size = UDim2.new(1, -560, 1, -300)
	centerOverlay.Position = UDim2.new(0, 260, 0, 48)
	centerOverlay.BackgroundTransparency = 1
	centerOverlay.Parent = mainCanvas

	local camToolbar = Instance.new("Frame")
	camToolbar.Name = "CameraToolbar"
	camToolbar.Size = UDim2.new(0, 360, 0, 36)
	camToolbar.Position = UDim2.new(0.5, -180, 0, 10)
	camToolbar.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
	camToolbar.BorderSizePixel = 0
	camToolbar.Parent = centerOverlay
	local ctCorner = Instance.new("UICorner")
	ctCorner.CornerRadius = UDim.new(0, 8)
	ctCorner.Parent = camToolbar

	local camLayout = Instance.new("UIListLayout")
	camLayout.FillDirection = Enum.FillDirection.Horizontal
	camLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	camLayout.Padding = UDim.new(0, 6)
	camLayout.Parent = camToolbar

	local camPresets = { "Orbit", "Front", "Side", "Back", "Reset", "Focus" }
	for _, preset in ipairs(camPresets) do
		local btn = Instance.new("TextButton")
		btn.Name = "CamBtn_" .. preset
		btn.Size = UDim2.new(0, 52, 1, -8)
		btn.BackgroundColor3 = Color3.fromRGB(36, 42, 58)
		btn.Text = preset
		btn.TextColor3 = Color3.fromRGB(220, 220, 220)
		btn.TextSize = 11
		btn.Font = Enum.Font.GothamMedium
		btn.Parent = camToolbar
		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 4)
		bCorner.Parent = btn

		btn.MouseButton1Click:Connect(function()
			if preset == "Front" or preset == "Side" or preset == "Back" or preset == "Reset" or preset == "Focus" then
				OrbitCameraController.SetPresetView(preset :: any)
			end
		end)
	end

	-- 4. Bottom Dock: Animation & VFX
	local bottomDock = Instance.new("Frame")
	bottomDock.Name = "BottomCenter_AnimationAndVFXDock"
	bottomDock.Size = UDim2.new(1, -560, 0, 250)
	bottomDock.Position = UDim2.new(0, 260, 1, -252)
	bottomDock.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
	bottomDock.BorderSizePixel = 0
	bottomDock.Parent = mainCanvas

	-- Animation Panel
	local animPanel = Instance.new("Frame")
	animPanel.Name = "AnimationPlayerSubPanel"
	animPanel.Size = UDim2.new(0.55, 0, 1, 0)
	animPanel.BackgroundTransparency = 1
	animPanel.Parent = bottomDock

	local animTitle = Instance.new("TextLabel")
	animTitle.Size = UDim2.new(1, -20, 0, 26)
	animTitle.Position = UDim2.new(0, 10, 0, 6)
	animTitle.BackgroundTransparency = 1
	animTitle.Font = Enum.Font.GothamBold
	animTitle.TextSize = 12
	animTitle.TextColor3 = Color3.fromRGB(240, 200, 80)
	animTitle.TextXAlignment = Enum.TextXAlignment.Left
	animTitle.Text = "ANIMATION TRANSPORT & 8-STATE TIMELINE"
	animTitle.Parent = animPanel

	-- State Buttons Holder
	local stateButtonsHolder = Instance.new("Frame")
	stateButtonsHolder.Size = UDim2.new(1, -20, 0, 28)
	stateButtonsHolder.Position = UDim2.new(0, 10, 0, 34)
	stateButtonsHolder.BackgroundTransparency = 1
	stateButtonsHolder.Parent = animPanel
	local sbLayout = Instance.new("UIListLayout")
	sbLayout.FillDirection = Enum.FillDirection.Horizontal
	sbLayout.Padding = UDim.new(0, 4)
	sbLayout.Parent = stateButtonsHolder

	local animStates = { "Idle", "Spawn", "Windup", "Attack", "Impact", "Recovery", "Ultimate" }
	for _, stName in ipairs(animStates) do
		local sBtn = Instance.new("TextButton")
		sBtn.Name = "StateBtn_" .. stName
		sBtn.Size = UDim2.new(0, 48, 1, 0)
		sBtn.BackgroundColor3 = Color3.fromRGB(35, 42, 60)
		sBtn.TextColor3 = Color3.fromRGB(220, 230, 250)
		sBtn.Font = Enum.Font.GothamMedium
		sBtn.TextSize = 10
		sBtn.Text = stName
		sBtn.Parent = stateButtonsHolder
		local sCorner = Instance.new("UICorner")
		sCorner.CornerRadius = UDim.new(0, 4)
		sCorner.Parent = sBtn

		sBtn.MouseButton1Click:Connect(function()
			TimelineController.Play(stName, nil)
		end)
	end

	-- Transport Controls (Play, Pause, Stop, Reset)
	local transportHolder = Instance.new("Frame")
	transportHolder.Size = UDim2.new(1, -20, 0, 34)
	transportHolder.Position = UDim2.new(0, 10, 0, 70)
	transportHolder.BackgroundTransparency = 1
	transportHolder.Parent = animPanel
	local tLayout = Instance.new("UIListLayout")
	tLayout.FillDirection = Enum.FillDirection.Horizontal
	tLayout.Padding = UDim.new(0, 6)
	tLayout.Parent = transportHolder

	local function makeTransBtn(name: string, label: string, color: Color3, onClick: () -> ())
		local b = Instance.new("TextButton")
		b.Name = name
		b.Size = UDim2.new(0, 68, 1, 0)
		b.BackgroundColor3 = color
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.Font = Enum.Font.GothamBold
		b.TextSize = 11
		b.Text = label
		b.Parent = transportHolder
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = b
		b.MouseButton1Click:Connect(onClick)
	end

	makeTransBtn("PlayBtn", "▶ PLAY", Color3.fromRGB(45, 125, 75), function()
		TimelineController.Play(nil, nil)
	end)

	makeTransBtn("PauseBtn", "⏸ PAUSE", Color3.fromRGB(150, 110, 40), function()
		TimelineController.Pause()
	end)

	makeTransBtn("StopBtn", "⏹ STOP", Color3.fromRGB(145, 45, 55), function()
		TimelineController.Stop()
	end)

	makeTransBtn("ResetPoseBtn", "↺ RESET", Color3.fromRGB(55, 65, 85), function()
		TimelineController.ResetToRestPose()
	end)

	-- Step Frame Buttons
	makeTransBtn("StepBackBtn", "-1f", Color3.fromRGB(40, 45, 60), function()
		TimelineController.StepFrame(-1)
	end)

	makeTransBtn("StepFwdBtn", "+1f", Color3.fromRGB(40, 45, 60), function()
		TimelineController.StepFrame(1)
	end)

	-- VFX Inspector Panel
	local vfxPanel = Instance.new("Frame")
	vfxPanel.Name = "VFXInspectorSubPanel"
	vfxPanel.Size = UDim2.new(0.45, 0, 1, 0)
	vfxPanel.Position = UDim2.new(0.55, 0, 0, 0)
	vfxPanel.BackgroundTransparency = 1
	vfxPanel.Parent = bottomDock

	local vfxTitle = Instance.new("TextLabel")
	vfxTitle.Size = UDim2.new(1, -20, 0, 26)
	vfxTitle.Position = UDim2.new(0, 10, 0, 6)
	vfxTitle.BackgroundTransparency = 1
	vfxTitle.Font = Enum.Font.GothamBold
	vfxTitle.TextSize = 12
	vfxTitle.TextColor3 = Color3.fromRGB(120, 200, 255)
	vfxTitle.TextXAlignment = Enum.TextXAlignment.Left
	vfxTitle.Text = "VFX INSPECTOR & LAYER TOGGLES"
	vfxTitle.Parent = vfxPanel

	local vfxActions = Instance.new("Frame")
	vfxActions.Size = UDim2.new(1, -20, 0, 32)
	vfxActions.Position = UDim2.new(0, 10, 0, 34)
	vfxActions.BackgroundTransparency = 1
	vfxActions.Parent = vfxPanel
	local vaLayout = Instance.new("UIListLayout")
	vaLayout.FillDirection = Enum.FillDirection.Horizontal
	vaLayout.Padding = UDim.new(0, 6)
	vaLayout.Parent = vfxActions

	local trigAttackBtn = Instance.new("TextButton")
	trigAttackBtn.Size = UDim2.new(0, 110, 1, 0)
	trigAttackBtn.BackgroundColor3 = Color3.fromRGB(45, 90, 160)
	trigAttackBtn.Font = Enum.Font.GothamBold
	trigAttackBtn.TextSize = 10
	trigAttackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	trigAttackBtn.Text = "TRIGGER ATTACK VFX"
	trigAttackBtn.Parent = vfxActions
	local taCorner = Instance.new("UICorner")
	taCorner.CornerRadius = UDim.new(0, 6)
	taCorner.Parent = trigAttackBtn

	trigAttackBtn.MouseButton1Click:Connect(function()
		if currentSelectedModel then
			local root = currentSelectedModel.PrimaryPart
			if root then
				VFXInspector.BuildExecutionContext("AttackImpact", root, root.Position + root.CFrame.LookVector * 15)
			end
		end
	end)

	local qualityHolder = Instance.new("Frame")
	qualityHolder.Size = UDim2.new(1, -20, 0, 28)
	qualityHolder.Position = UDim2.new(0, 10, 0, 74)
	qualityHolder.BackgroundTransparency = 1
	qualityHolder.Parent = vfxPanel
	local qLayout = Instance.new("UIListLayout")
	qLayout.FillDirection = Enum.FillDirection.Horizontal
	qLayout.Padding = UDim.new(0, 6)
	qLayout.Parent = qualityHolder

	for _, qPreset in ipairs({ "Low", "Medium", "High" }) do
		local qBtn = Instance.new("TextButton")
		qBtn.Size = UDim2.new(0, 65, 1, 0)
		qBtn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
		qBtn.Font = Enum.Font.GothamBold
		qBtn.TextSize = 10
		qBtn.TextColor3 = Color3.fromRGB(200, 215, 240)
		qBtn.Text = qPreset
		qBtn.Parent = qualityHolder
		local qCorner = Instance.new("UICorner")
		qCorner.CornerRadius = UDim.new(0, 4)
		qCorner.Parent = qBtn

		qBtn.MouseButton1Click:Connect(function()
			VFXInspector.SetQuality(qPreset :: any)
		end)
	end

	-- 5. Right Sidebar: Debug & Stress Testing
	local rightSidebar = Instance.new("Frame")
	rightSidebar.Name = "RightSidebar_DebugAndPerformance"
	rightSidebar.Size = UDim2.new(0, 300, 1, -48)
	rightSidebar.Position = UDim2.new(1, -300, 0, 48)
	rightSidebar.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
	rightSidebar.BorderSizePixel = 0
	rightSidebar.Parent = mainCanvas

	local stressCard = Instance.new("Frame")
	stressCard.Name = "StressCard"
	stressCard.Size = UDim2.new(1, -20, 0, 220)
	stressCard.Position = UDim2.new(0, 10, 0, 10)
	stressCard.BackgroundColor3 = Color3.fromRGB(28, 32, 44)
	stressCard.BorderSizePixel = 0
	stressCard.Parent = rightSidebar
	local scCorner = Instance.new("UICorner")
	scCorner.CornerRadius = UDim.new(0, 8)
	scCorner.Parent = stressCard

	local scTitle = Instance.new("TextLabel")
	scTitle.Size = UDim2.new(1, -20, 0, 30)
	scTitle.Position = UDim2.new(0, 10, 0, 8)
	scTitle.BackgroundTransparency = 1
	scTitle.Font = Enum.Font.GothamBold
	scTitle.TextSize = 12
	scTitle.TextColor3 = Color3.fromRGB(255, 140, 120)
	scTitle.TextXAlignment = Enum.TextXAlignment.Left
	scTitle.Text = "STRESS BENCHMARK RUNNER"
	scTitle.Parent = stressCard

	local stressBtns = {
		{ label = "1 Character", scenario = "Single" },
		{ label = "10 Characters", scenario = "Ten" },
		{ label = "25 Characters", scenario = "TwentyFive" },
		{ label = "50 Characters", scenario = "Fifty" },
	}

	for sIdx, sData in ipairs(stressBtns) do
		local sb = Instance.new("TextButton")
		sb.Size = UDim2.new(1, -20, 0, 32)
		sb.Position = UDim2.new(0, 10, 0, 40 + (sIdx - 1) * 38)
		sb.BackgroundColor3 = Color3.fromRGB(50, 40, 55)
		sb.Font = Enum.Font.GothamMedium
		sb.TextSize = 11
		sb.TextColor3 = Color3.fromRGB(240, 220, 255)
		sb.Text = "⚡ Run " .. sData.label
		sb.Parent = stressCard
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 6)
		c.Parent = sb

		sb.MouseButton1Click:Connect(function()
			local commandRemote = ReplicatedStorage:FindFirstChild("AnimationLabCommand") :: RemoteFunction?
			if commandRemote then
				pcall(function()
					commandRemote:InvokeServer("RunStressTest", { scenario = sData.scenario })
				end)
			end
		end)
	end

	return screenGui
end

return table.freeze(AnimationLabGui)
