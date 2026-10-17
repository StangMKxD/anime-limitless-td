--!strict
-- src/Track3_UISystem/Views/MapSelectionView.luau
-- Anime Limitless Tower Defense — Phase 6 Map Selection & Voting View
-- Displays 4 map cards, realtime vote counts, preparation countdown, and voting buttons.

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local MapCatalog = require(SharedFolder:WaitForChild("MapCatalog")) :: any
local MapContract = require(SharedFolder:WaitForChild("MapContract")) :: any

local MapSelectionView = {}

function MapSelectionView.Create(parentGui: ScreenGui): Frame
	local frame = Instance.new("Frame")
	frame.Name = "MapSelectionModalFrame"
	frame.Size = UDim2.new(0, 720, 0, 460)
	frame.Position = UDim2.new(0.5, -360, 0.5, -230)
	frame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
	frame.BorderSizePixel = 0
	frame.ZIndex = 60
	frame.Visible = false
	frame.Parent = parentGui

	local uic = Instance.new("UICorner")
	uic.CornerRadius = UDim.new(0, 12)
	uic.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(90, 120, 180)
	stroke.Thickness = 2
	stroke.Parent = frame

	-- Header
	local header = Instance.new("TextLabel")
	header.Name = "HeaderTitle"
	header.Size = UDim2.new(1, -60, 0, 40)
	header.Position = UDim2.new(0, 20, 0, 12)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.GothamBold
	header.TextSize = 18
	header.TextColor3 = Color3.fromRGB(255, 230, 100)
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Text = "🗺️ BATTLEFIELD SELECTION — VOTE FOR MAP"
	header.Parent = frame

	local countdownLbl = Instance.new("TextLabel")
	countdownLbl.Name = "CountdownLabel"
	countdownLbl.Size = UDim2.new(0, 150, 0, 30)
	countdownLbl.Position = UDim2.new(1, -220, 0, 16)
	countdownLbl.BackgroundTransparency = 1
	countdownLbl.Font = Enum.Font.GothamMedium
	countdownLbl.TextSize = 13
	countdownLbl.TextColor3 = Color3.fromRGB(200, 210, 230)
	countdownLbl.Text = "Selection: 15s"
	countdownLbl.Parent = frame

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

	-- 4 Map Cards Grid Container
	local cardsContainer = Instance.new("Frame")
	cardsContainer.Name = "CardsContainer"
	cardsContainer.Size = UDim2.new(1, -40, 1, -80)
	cardsContainer.Position = UDim2.new(0, 20, 0, 64)
	cardsContainer.BackgroundTransparency = 1
	cardsContainer.Parent = frame

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 160, 0, 350)
	grid.CellPadding = UDim2.new(0, 12, 0, 12)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = cardsContainer

	local cardWidgets: { [string]: { voteCountLabel: TextLabel, voteBtn: TextButton, cardFrame: Frame } } = {}
	local currentRevision = 1
	local currentDeadline = 0

	local allMaps = MapCatalog.GetAllMaps()
	for idx, mapDef in ipairs(allMaps) do
		local card = Instance.new("Frame")
		card.Name = "Card_" .. mapDef.id
		card.BackgroundColor3 = Color3.fromRGB(30, 34, 45)
		card.LayoutOrder = idx
		card.Parent = cardsContainer

		local cCorner = Instance.new("UICorner")
		cCorner.CornerRadius = UDim.new(0, 8)
		cCorner.Parent = card

		local cStroke = Instance.new("UIStroke")
		cStroke.Color = Color3.fromRGB(60, 75, 105)
		cStroke.Thickness = 1.5
		cStroke.Parent = card

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -16, 0, 40)
		title.Position = UDim2.new(0, 8, 0, 8)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBold
		title.TextSize = 13
		title.TextColor3 = Color3.fromRGB(240, 245, 255)
		title.TextWrapped = true
		title.Text = mapDef.displayName
		title.Parent = card

		local themeBadge = Instance.new("TextLabel")
		themeBadge.Size = UDim2.new(1, -16, 0, 20)
		themeBadge.Position = UDim2.new(0, 8, 0, 52)
		themeBadge.BackgroundColor3 = Color3.fromRGB(45, 52, 70)
		themeBadge.Font = Enum.Font.GothamMedium
		themeBadge.TextSize = 10
		themeBadge.TextColor3 = Color3.fromRGB(120, 200, 255)
		themeBadge.Text = mapDef.theme
		themeBadge.Parent = card
		local tbCorner = Instance.new("UICorner")
		tbCorner.CornerRadius = UDim.new(0, 4)
		tbCorner.Parent = themeBadge

		local desc = Instance.new("TextLabel")
		desc.Size = UDim2.new(1, -16, 0, 160)
		desc.Position = UDim2.new(0, 8, 0, 80)
		desc.BackgroundTransparency = 1
		desc.Font = Enum.Font.Gotham
		desc.TextSize = 11
		desc.TextColor3 = Color3.fromRGB(170, 180, 200)
		desc.TextWrapped = true
		desc.TextYAlignment = Enum.TextYAlignment.Top
		desc.Text = mapDef.description
		desc.Parent = card

		local votes = Instance.new("TextLabel")
		votes.Name = "VotesLabel"
		votes.Size = UDim2.new(1, -16, 0, 24)
		votes.Position = UDim2.new(0, 8, 1, -74)
		votes.BackgroundTransparency = 1
		votes.Font = Enum.Font.GothamBold
		votes.TextSize = 12
		votes.TextColor3 = Color3.fromRGB(255, 215, 80)
		votes.Text = "Votes: 0"
		votes.Parent = card

		local voteBtn = Instance.new("TextButton")
		voteBtn.Name = "VoteButton"
		voteBtn.Size = UDim2.new(1, -16, 0, 36)
		voteBtn.Position = UDim2.new(0, 8, 1, -46)
		voteBtn.BackgroundColor3 = Color3.fromRGB(50, 110, 220)
		voteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		voteBtn.Font = Enum.Font.GothamBold
		voteBtn.TextSize = 12
		voteBtn.Text = "VOTE"
		voteBtn.Parent = card
		local vbCorner = Instance.new("UICorner")
		vbCorner.CornerRadius = UDim.new(0, 6)
		vbCorner.Parent = voteBtn

		voteBtn.MouseButton1Click:Connect(function()
			local voteRemote = ReplicatedStorage:FindFirstChild("MapVoteRequest") :: RemoteEvent?
			if voteRemote then
				voteRemote:FireServer({
					version = MapContract.VERSION,
					mapId = mapDef.id,
					selectionRevision = currentRevision,
					requestId = HttpService:GenerateGUID(false),
				})
			end
		end)

		cardWidgets[mapDef.id] = {
			voteCountLabel = votes,
			voteBtn = voteBtn,
			cardFrame = card,
		}
	end

	-- Connect to MapSelectionState updates
	local selectionRemote = ReplicatedStorage:WaitForChild("MapSelectionState", 10) :: RemoteEvent?
	if selectionRemote and selectionRemote:IsA("RemoteEvent") then
		selectionRemote.OnClientEvent:Connect(function(state: any)
			if not state then return end
			currentRevision = state.selectionRevision or currentRevision
			currentDeadline = state.deadlineServerTime or currentDeadline

			if state.votes then
				for mapId, count in pairs(state.votes) do
					local w = cardWidgets[mapId]
					if w then
						w.voteCountLabel.Text = "Votes: " .. tostring(count)
					end
				end
			end

			if state.lifecycleState == "Locked" or state.lifecycleState == "Ready" then
				countdownLbl.Text = "Locked: " .. tostring(state.selectedMapId or state.lockedMapId)
				for _, w in pairs(cardWidgets) do
					w.voteBtn.Visible = false
				end
			end
		end)
	end

	return frame
end

return table.freeze(MapSelectionView)
