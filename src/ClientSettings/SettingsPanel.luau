--!strict
-- src/ClientSettings/SettingsPanel.luau
-- Anime Limitless Tower Defense — Phase 6 Settings & Accessibility UI Panel
-- Controls VFX Quality, Camera Shake, Screen Flash, Reduced Motion, UI Scale, and Defaults Reset.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PresentationPreferences = require(ReplicatedStorage:WaitForChild("Presentation"):WaitForChild("PresentationPreferences")) :: any

local SettingsPanel = {}

function SettingsPanel.Create(parentGui: ScreenGui): Frame
	local frame = Instance.new("Frame")
	frame.Name = "SettingsModalFrame"
	frame.Size = UDim2.new(0, 420, 0, 520)
	frame.Position = UDim2.new(0.5, -210, 0.5, -260)
	frame.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
	frame.BorderSizePixel = 0
	frame.ZIndex = 80
	frame.Visible = false
	frame.Parent = parentGui

	local uic = Instance.new("UICorner")
	uic.CornerRadius = UDim.new(0, 12)
	uic.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(70, 85, 125)
	stroke.Thickness = 2
	stroke.Parent = frame

	-- Header
	local header = Instance.new("TextLabel")
	header.Name = "HeaderTitle"
	header.Size = UDim2.new(1, -60, 0, 44)
	header.Position = UDim2.new(0, 20, 0, 10)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.GothamBold
	header.TextSize = 18
	header.TextColor3 = Color3.fromRGB(255, 235, 120)
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Text = "⚙️ SETTINGS & ACCESSIBILITY"
	header.Parent = frame

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.Position = UDim2.new(1, -44, 0, 16)
	closeBtn.BackgroundColor3 = Color3.fromRGB(50, 55, 70)
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Text = "X"
	closeBtn.Parent = frame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		frame.Visible = false
	end)

	-- Content Scroll or Container
	local container = Instance.new("ScrollingFrame")
	container.Name = "OptionsContainer"
	container.Size = UDim2.new(1, -40, 1, -120)
	container.Position = UDim2.new(0, 20, 0, 60)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.CanvasSize = UDim2.new(0, 0, 0, 480)
	container.ScrollBarThickness = 4
	container.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 14)
	layout.Parent = container

	local function createSection(order: number, title: string, options: { string }, currentVal: string, onSelect: (string) -> ())
		local row = Instance.new("Frame")
		row.Name = "Row_" .. title
		row.Size = UDim2.new(1, -10, 0, 64)
		row.BackgroundColor3 = Color3.fromRGB(32, 35, 46)
		row.LayoutOrder = order
		row.Parent = container

		local rCorner = Instance.new("UICorner")
		rCorner.CornerRadius = UDim.new(0, 8)
		rCorner.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -20, 0, 24)
		lbl.Position = UDim2.new(0, 12, 0, 6)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.GothamMedium
		lbl.TextSize = 13
		lbl.TextColor3 = Color3.fromRGB(200, 210, 230)
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Text = title
		lbl.Parent = row

		local btnsHolder = Instance.new("Frame")
		btnsHolder.Size = UDim2.new(1, -24, 0, 28)
		btnsHolder.Position = UDim2.new(0, 12, 0, 30)
		btnsHolder.BackgroundTransparency = 1
		btnsHolder.Parent = row

		local bLayout = Instance.new("UIListLayout")
		bLayout.FillDirection = Enum.FillDirection.Horizontal
		bLayout.Padding = UDim.new(0, 8)
		bLayout.Parent = btnsHolder

		local buttons: { [string]: TextButton } = {}

		local function updateHighlights(selected: string)
			for optName, btn in pairs(buttons) do
				if optName == selected then
					btn.BackgroundColor3 = Color3.fromRGB(60, 120, 240)
					btn.TextColor3 = Color3.fromRGB(255, 255, 255)
				else
					btn.BackgroundColor3 = Color3.fromRGB(45, 48, 62)
					btn.TextColor3 = Color3.fromRGB(160, 170, 190)
				end
			end
		end

		local optWidth = math.floor((340 - (#options - 1) * 8) / #options)
		for _, opt in ipairs(options) do
			local optBtn = Instance.new("TextButton")
			optBtn.Name = "Btn_" .. opt
			optBtn.Size = UDim2.new(0, optWidth, 1, 0)
			optBtn.Font = Enum.Font.GothamBold
			optBtn.TextSize = 11
			optBtn.Text = opt
			optBtn.Parent = btnsHolder
			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 6)
			bCorner.Parent = optBtn

			buttons[opt] = optBtn

			optBtn.MouseButton1Click:Connect(function()
				onSelect(opt)
				updateHighlights(opt)
			end)
		end

		updateHighlights(currentVal)
	end

	local snap = PresentationPreferences.GetSnapshot()

	-- 1. VFX Quality
	createSection(1, "VFX QUALITY PRESET", { "Low", "Medium", "High" }, snap.quality, function(val)
		PresentationPreferences.SetLocal("quality", val)
	end)

	-- 2. Camera Shake
	createSection(2, "CAMERA SHAKE MODE", { "Off", "Reduced", "Full" }, snap.cameraShakeMode, function(val)
		PresentationPreferences.SetLocal("cameraShakeMode", val)
	end)

	-- 3. Screen Flash
	createSection(3, "SCREEN IMPACT FLASH", { "Off", "Reduced", "Full" }, snap.flashMode, function(val)
		PresentationPreferences.SetLocal("flashMode", val)
	end)

	-- 4. Reduced Motion
	createSection(4, "REDUCED MOTION ACCESSIBILITY", { "Off", "On" }, if snap.reducedMotion then "On" else "Off", function(val)
		PresentationPreferences.SetLocal("reducedMotion", val == "On")
	end)

	-- 5. Decorative Aura
	createSection(5, "DECORATIVE HERO AURA", { "Off", "On" }, if snap.decorativeAura then "On" else "Off", function(val)
		PresentationPreferences.SetLocal("decorativeAura", val == "On")
	end)

	-- 6. Reset Defaults Button
	local resetBtn = Instance.new("TextButton")
	resetBtn.Name = "ResetDefaultsButton"
	resetBtn.Size = UDim2.new(1, -40, 0, 38)
	resetBtn.Position = UDim2.new(0, 20, 1, -50)
	resetBtn.BackgroundColor3 = Color3.fromRGB(65, 35, 40)
	resetBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
	resetBtn.Font = Enum.Font.GothamBold
	resetBtn.TextSize = 12
	resetBtn.Text = "↺ RESET SETTINGS TO DEFAULT"
	resetBtn.Parent = frame

	local resetCorner = Instance.new("UICorner")
	resetCorner.CornerRadius = UDim.new(0, 8)
	resetCorner.Parent = resetBtn

	resetBtn.MouseButton1Click:Connect(function()
		PresentationPreferences.ResetLocal()
		frame.Visible = false
	end)

	return frame
end

return table.freeze(SettingsPanel)
