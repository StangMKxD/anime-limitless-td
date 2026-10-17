--!strict
-- src/Track3_UISystem/Views/LobbyHubView.luau
-- Anime Limitless Tower Defense — Phase 6 Lobby Hub Overlay View
-- Central navigation portal providing access to battlefield, map selection, settings, and developer lab.

local RunService = game:GetService("RunService")

local LobbyHubView = {}

function LobbyHubView.Create(
	parentGui: ScreenGui,
	onOpenMapSelector: () -> (),
	onOpenSettings: () -> ()
): Frame
	local frame = Instance.new("Frame")
	frame.Name = "LobbyHubOverlayFrame"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Position = UDim2.new(0, 0, 0, 0)
	frame.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
	frame.BackgroundTransparency = 0.25
	frame.BorderSizePixel = 0
	frame.ZIndex = 50
	frame.Visible = false
	frame.Parent = parentGui

	local centerBox = Instance.new("Frame")
	centerBox.Name = "CenterBox"
	centerBox.Size = UDim2.new(0, 500, 0, 420)
	centerBox.Position = UDim2.new(0.5, -250, 0.5, -210)
	centerBox.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
	centerBox.Parent = frame
	local cbCorner = Instance.new("UICorner")
	cbCorner.CornerRadius = UDim.new(0, 14)
	cbCorner.Parent = centerBox
	local cbStroke = Instance.new("UIStroke")
	cbStroke.Color = Color3.fromRGB(80, 100, 150)
	cbStroke.Thickness = 2
	cbStroke.Parent = centerBox

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 0, 50)
	title.Position = UDim2.new(0, 20, 0, 20)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 22
	title.TextColor3 = Color3.fromRGB(255, 220, 80)
	title.Text = "ANIME LIMITLESS TD"
	title.Parent = centerBox

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, -40, 0, 24)
	subtitle.Position = UDim2.new(0, 20, 0, 68)
	subtitle.BackgroundTransparency = 1
	subtitle.Font = Enum.Font.GothamMedium
	subtitle.TextSize = 13
	subtitle.TextColor3 = Color3.fromRGB(160, 175, 205)
	subtitle.Text = "Phase 6 Presentation & Battlefield Hub"
	subtitle.Parent = centerBox

	-- 1. Enter Battle Button
	local playBtn = Instance.new("TextButton")
	playBtn.Name = "EnterBattleButton"
	playBtn.Size = UDim2.new(1, -60, 0, 50)
	playBtn.Position = UDim2.new(0, 30, 0, 120)
	playBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 80)
	playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	playBtn.Font = Enum.Font.GothamBold
	playBtn.TextSize = 16
	playBtn.Text = "⚔️ ENTER BATTLEFIELD"
	playBtn.Parent = centerBox
	local pCorner = Instance.new("UICorner")
	pCorner.CornerRadius = UDim.new(0, 8)
	pCorner.Parent = playBtn

	playBtn.MouseButton1Click:Connect(function()
		frame.Visible = false
	end)

	-- 2. Map Selection Button
	local mapBtn = Instance.new("TextButton")
	mapBtn.Name = "VoteMapButton"
	mapBtn.Size = UDim2.new(1, -60, 0, 46)
	mapBtn.Position = UDim2.new(0, 30, 0, 185)
	mapBtn.BackgroundColor3 = Color3.fromRGB(45, 95, 180)
	mapBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	mapBtn.Font = Enum.Font.GothamBold
	mapBtn.TextSize = 14
	mapBtn.Text = "🗺️ VOTE FOR MAP"
	mapBtn.Parent = centerBox
	local mCorner = Instance.new("UICorner")
	mCorner.CornerRadius = UDim.new(0, 8)
	mCorner.Parent = mapBtn

	mapBtn.MouseButton1Click:Connect(function()
		onOpenMapSelector()
	end)

	-- 3. Settings Button
	local settingsBtn = Instance.new("TextButton")
	settingsBtn.Name = "SettingsButton"
	settingsBtn.Size = UDim2.new(1, -60, 0, 46)
	settingsBtn.Position = UDim2.new(0, 30, 0, 245)
	settingsBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
	settingsBtn.TextColor3 = Color3.fromRGB(220, 230, 255)
	settingsBtn.Font = Enum.Font.GothamBold
	settingsBtn.TextSize = 14
	settingsBtn.Text = "⚙️ VISUAL SETTINGS"
	settingsBtn.Parent = centerBox
	local sCorner = Instance.new("UICorner")
	sCorner.CornerRadius = UDim.new(0, 8)
	sCorner.Parent = settingsBtn

	settingsBtn.MouseButton1Click:Connect(function()
		onOpenSettings()
	end)

	-- 4. Studio Animation Lab Button (if in Studio)
	if RunService:IsStudio() then
		local labBtn = Instance.new("TextButton")
		labBtn.Name = "AnimationLabButton"
		labBtn.Size = UDim2.new(1, -60, 0, 46)
		labBtn.Position = UDim2.new(0, 30, 0, 305)
		labBtn.BackgroundColor3 = Color3.fromRGB(65, 45, 95)
		labBtn.TextColor3 = Color3.fromRGB(255, 220, 100)
		labBtn.Font = Enum.Font.GothamBold
		labBtn.TextSize = 14
		labBtn.Text = "🧪 ANIMATION LAB [F4]"
		labBtn.Parent = centerBox
		local lCorner = Instance.new("UICorner")
		lCorner.CornerRadius = UDim.new(0, 8)
		lCorner.Parent = labBtn

		labBtn.MouseButton1Click:Connect(function()
			frame.Visible = false
			-- Trigger Studio Lab
			local launcher = parentGui:FindFirstChild("StudioLabLauncherGui")
			if launcher then
				local btn = launcher:FindFirstChild("OpenLabButton") :: TextButton?
				if btn then
					-- simulate click
				end
			end
		end)
	end

	return frame
end

return table.freeze(LobbyHubView)
