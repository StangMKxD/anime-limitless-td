--!strict
-- src/DevTools/AnimationLab/AnimationLabGui.luau
-- Programmatic ScreenGui Developer Dashboard for Roblox Studio.

local LabConfig = require(script.Parent:WaitForChild("LabConfig")) :: any

local AnimationLabGui = {}

function AnimationLabGui.Create(): ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AnimationLabGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 999

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
	titleLabel.Size = UDim2.new(0, 450, 1, 0)
	titleLabel.Position = UDim2.new(0, 16, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "ANIME LIMITLESS TD — ANIMATION & VFX LAB"
	titleLabel.TextColor3 = Color3.fromRGB(245, 185, 60)
	titleLabel.TextSize = 16
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = header

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

	local modelList = Instance.new("ScrollingFrame")
	modelList.Name = "ModelList"
	modelList.Size = UDim2.new(1, -20, 1, -55)
	modelList.Position = UDim2.new(0, 10, 0, 48)
	modelList.BackgroundTransparency = 1
	modelList.ScrollBarThickness = 4
	modelList.Parent = leftSidebar

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = modelList

	-- 3. Center Stage Overlays
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

	local camLayout = Instance.new("UIListLayout")
	camLayout.FillDirection = Enum.FillDirection.Horizontal
	camLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	camLayout.Padding = UDim.new(0, 6)
	camLayout.Parent = camToolbar

	for _, preset in ipairs({ "Orbit", "Front", "Side", "Back", "Reset", "Focus" }) do
		local btn = Instance.new("TextButton")
		btn.Name = "CamBtn_" .. preset
		btn.Size = UDim2.new(0, 52, 1, -8)
		btn.BackgroundColor3 = Color3.fromRGB(36, 42, 58)
		btn.Text = preset
		btn.TextColor3 = Color3.fromRGB(220, 220, 220)
		btn.TextSize = 11
		btn.Font = Enum.Font.GothamMedium
		btn.Parent = camToolbar
	end

	-- 4. Bottom Dock: Animation & VFX (Height: 250px)
	local bottomDock = Instance.new("Frame")
	bottomDock.Name = "BottomCenter_AnimationAndVFXDock"
	bottomDock.Size = UDim2.new(1, -560, 0, 250)
	bottomDock.Position = UDim2.new(0, 260, 1, -252)
	bottomDock.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
	bottomDock.BorderSizePixel = 0
	bottomDock.Parent = mainCanvas

	local animPanel = Instance.new("Frame")
	animPanel.Name = "AnimationPlayerSubPanel"
	animPanel.Size = UDim2.new(0.55, 0, 1, 0)
	animPanel.BackgroundTransparency = 1
	animPanel.Parent = bottomDock

	local vfxPanel = Instance.new("Frame")
	vfxPanel.Name = "VFXInspectorSubPanel"
	vfxPanel.Size = UDim2.new(0.45, 0, 1, 0)
	vfxPanel.Position = UDim2.new(0.55, 0, 0, 0)
	vfxPanel.BackgroundTransparency = 1
	vfxPanel.Parent = bottomDock

	-- 5. Right Sidebar: Debug & Telemetry (Width: 300px)
	local rightSidebar = Instance.new("Frame")
	rightSidebar.Name = "RightSidebar_DebugAndPerformance"
	rightSidebar.Size = UDim2.new(0, 300, 1, -48)
	rightSidebar.Position = UDim2.new(1, -300, 0, 48)
	rightSidebar.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
	rightSidebar.BorderSizePixel = 0
	rightSidebar.Parent = mainCanvas

	local telemetryCard = Instance.new("Frame")
	telemetryCard.Name = "TelemetryCard"
	telemetryCard.Size = UDim2.new(1, -20, 0, 200)
	telemetryCard.Position = UDim2.new(0, 10, 0, 10)
	telemetryCard.BackgroundColor3 = Color3.fromRGB(28, 32, 44)
	telemetryCard.BorderSizePixel = 0
	telemetryCard.Parent = rightSidebar

	local stressCard = Instance.new("Frame")
	stressCard.Name = "StressCard"
	stressCard.Size = UDim2.new(1, -20, 1, -230)
	stressCard.Position = UDim2.new(0, 10, 0, 220)
	stressCard.BackgroundColor3 = Color3.fromRGB(28, 32, 44)
	stressCard.BorderSizePixel = 0
	stressCard.Parent = rightSidebar

	return screenGui
end

return table.freeze(AnimationLabGui)
