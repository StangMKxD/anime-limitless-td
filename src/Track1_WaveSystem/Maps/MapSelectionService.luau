--!strict
-- src/Track1_WaveSystem/Maps/MapSelectionService.luau
-- Anime Limitless Tower Defense — Phase 6 Map Selection & Voting Service
-- Orchestrates player map votes before Wave 1, resolves ties, and coordinates with MapService.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local MapCatalog = require(SharedFolder:WaitForChild("MapCatalog")) :: any
local MapContract = require(SharedFolder:WaitForChild("MapContract")) :: any
local MapService = (function()
	if typeof(script) ~= "nil" and script.Parent then
		local s = script.Parent:FindFirstChild("MapService")
		if s then
			return require(s)
		end
	end
	local ok, mod = pcall(require, "./MapService")
	if ok and mod then return mod end
	local ok2, mod2 = pcall(require, "../src/Track1_WaveSystem/Maps/MapService")
	if ok2 and mod2 then return mod2 end
	local ok3, mod3 = pcall(require, "./src/Track1_WaveSystem/Maps/MapService")
	if ok3 and mod3 then return mod3 end
	error("Failed to load MapService")
end)()

local currentRevision: number = 1
local currentState: any = MapContract.LIFECYCLE_STATES.PREPARATION_SELECTION
local selectedMapId: string = MapCatalog.DEFAULT_MAP_ID
local lockedMapId: string? = nil
local deadlineServerTime: number = 0

local playerVotes: { [number]: string } = {} -- UserId -> mapId
local voteCounts: { [string]: number } = {}
local processedRequestIds: { [string]: boolean } = {}

for _, mapId in ipairs(MapCatalog.GetAllMapIds()) do
	voteCounts[mapId] = 0
end

local selectionStateRemote: RemoteEvent? = nil
local voteRequestRemote: RemoteEvent? = nil

local function getOrCreateRemotes()
	if not selectionStateRemote then
		local existing = ReplicatedStorage:FindFirstChild("MapSelectionState")
		if existing and existing:IsA("RemoteEvent") then
			selectionStateRemote = existing
		else
			local r = Instance.new("RemoteEvent")
			r.Name = "MapSelectionState"
			r.Parent = ReplicatedStorage
			selectionStateRemote = r
		end
	end

	if not voteRequestRemote then
		local existing = ReplicatedStorage:FindFirstChild("MapVoteRequest")
		if existing and existing:IsA("RemoteEvent") then
			voteRequestRemote = existing
		else
			local r = Instance.new("RemoteEvent")
			r.Name = "MapVoteRequest"
			r.Parent = ReplicatedStorage
			voteRequestRemote = r
		end
	end
end

local MapSelectionService = {}

function MapSelectionService.GetSnapshot(): any
	return {
		version = MapContract.VERSION,
		selectionRevision = currentRevision,
		lifecycleState = currentState,
		selectedMapId = selectedMapId,
		lockedMapId = lockedMapId,
		allowedMapIds = MapCatalog.GetAllMapIds(),
		votes = table.clone(voteCounts),
		deadlineServerTime = deadlineServerTime,
	}
end

function MapSelectionService.BroadcastState()
	getOrCreateRemotes()
	local snapshot = MapSelectionService.GetSnapshot()
	if selectionStateRemote then
		selectionStateRemote:FireAllClients(snapshot)
	end
end

function MapSelectionService.StartSelectionWindow(durationSec: number?)
	currentRevision += 1
	currentState = MapContract.LIFECYCLE_STATES.PREPARATION_SELECTION
	lockedMapId = nil
	table.clear(playerVotes)
	table.clear(processedRequestIds)

	for _, mapId in ipairs(MapCatalog.GetAllMapIds()) do
		voteCounts[mapId] = 0
	end

	local window = durationSec or MapContract.PREPARATION_SELECTION_WINDOW_SEC
	deadlineServerTime = os.clock() + window

	MapSelectionService.BroadcastState()
end

function MapSelectionService.RegisterVote(
	player: Player,
	mapId: string,
	revision: number,
	requestId: string
): (boolean, string?)
	-- 1. State check
	if currentState ~= MapContract.LIFECYCLE_STATES.PREPARATION_SELECTION then
		return false, MapContract.ERROR_CODES.VOTE_LOCKED
	end

	-- 2. Revision check
	if revision ~= currentRevision then
		return false, MapContract.ERROR_CODES.STALE_REVISION
	end

	-- 3. Map validation
	if not MapCatalog.ValidateMapId(mapId) then
		return false, MapContract.ERROR_CODES.INVALID_MAP
	end

	-- 4. Idempotency check
	if processedRequestIds[requestId] then
		return true, nil
	end
	processedRequestIds[requestId] = true

	local userId = player.UserId
	local oldVote = playerVotes[userId]
	if oldVote and voteCounts[oldVote] then
		voteCounts[oldVote] = math.max(0, voteCounts[oldVote] - 1)
	end

	playerVotes[userId] = mapId
	voteCounts[mapId] = (voteCounts[mapId] or 0) + 1

	-- Determine leading map (ties default to current selected or Marineford)
	local maxVotes = 0
	local leadingMap = MapCatalog.DEFAULT_MAP_ID
	for _, mId in ipairs(MapCatalog.GetAllMapIds()) do
		local count = voteCounts[mId] or 0
		if count > maxVotes then
			maxVotes = count
			leadingMap = mId
		end
	end
	selectedMapId = leadingMap

	MapSelectionService.BroadcastState()
	return true, nil
end

function MapSelectionService.LockSelection(): string
	if currentState == MapContract.LIFECYCLE_STATES.LOCKED or currentState == MapContract.LIFECYCLE_STATES.READY then
		return lockedMapId or selectedMapId
	end

	currentState = MapContract.LIFECYCLE_STATES.LOCKED
	lockedMapId = selectedMapId

	-- Transition to Loading -> Ready
	currentState = MapContract.LIFECYCLE_STATES.LOADING
	MapSelectionService.BroadcastState()

	local ok = MapService.BuildMap(lockedMapId)
	if not ok then
		warn("[MapSelectionService] Build failed on chosen map, falling back to default")
		lockedMapId = MapCatalog.DEFAULT_MAP_ID
		MapService.BuildMap(lockedMapId)
	end

	currentState = MapContract.LIFECYCLE_STATES.READY
	MapSelectionService.BroadcastState()

	return lockedMapId
end

function MapSelectionService.Init()
	getOrCreateRemotes()

	if voteRequestRemote then
		voteRequestRemote.OnServerEvent:Connect(function(player: Player, payload: any)
			local ok, err = MapContract.ValidateVoteRequest(payload)
			if not ok or not payload then
				return
			end
			MapSelectionService.RegisterVote(player, payload.mapId, payload.selectionRevision, payload.requestId)
		end)
	end

	Players.PlayerRemoving:Connect(function(player: Player)
		local oldVote = playerVotes[player.UserId]
		if oldVote and currentState == MapContract.LIFECYCLE_STATES.PREPARATION_SELECTION then
			playerVotes[player.UserId] = nil
			voteCounts[oldVote] = math.max(0, (voteCounts[oldVote] or 1) - 1)
			MapSelectionService.BroadcastState()
		end
	end)
end

return table.freeze(MapSelectionService)
