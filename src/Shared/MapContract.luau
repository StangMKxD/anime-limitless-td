--!strict
-- src/Shared/MapContract.luau
-- Anime Limitless Tower Defense — Phase 6 Map Contract
-- Protocol and lifecycle definitions for pre-wave map voting and server orchestration.

export type MapLifecycleState = "PreparationSelection" | "Locked" | "Loading" | "Ready" | "Playing" | "Results"

export type MapVoteRequest = {
	version: number,
	mapId: string,
	selectionRevision: number,
	requestId: string,
}

export type MapSelectionState = {
	version: number,
	selectionRevision: number,
	lifecycleState: MapLifecycleState,
	selectedMapId: string,
	lockedMapId: string?,
	allowedMapIds: { string },
	votes: { [string]: number }, -- mapId -> vote count
	playerVotes: { [number]: string }?, -- userId -> mapId
	deadlineServerTime: number,
}

local MapContract = {
	VERSION = 1,
	PREPARATION_SELECTION_WINDOW_SEC = 15.0,

	LIFECYCLE_STATES = {
		PREPARATION_SELECTION = "PreparationSelection" :: MapLifecycleState,
		LOCKED = "Locked" :: MapLifecycleState,
		LOADING = "Loading" :: MapLifecycleState,
		READY = "Ready" :: MapLifecycleState,
		PLAYING = "Playing" :: MapLifecycleState,
		RESULTS = "Results" :: MapLifecycleState,
	},

	ERROR_CODES = {
		INVALID_MAP = "INVALID_MAP",
		VOTE_LOCKED = "VOTE_LOCKED",
		STALE_REVISION = "STALE_REVISION",
		RATE_LIMITED = "RATE_LIMITED",
		BUILD_FAILED = "BUILD_FAILED",
	},
}

local KNOWN_MAP_IDS = {
	Marineford = true,
	SakuraHarbor = true,
	SkySanctuary = true,
	VolcanicCitadel = true,
}

function MapContract.ValidateVoteRequest(req: any): (boolean, string?)
	if typeof(req) ~= "table" then
		return false, "Payload must be a table"
	end
	if typeof(req.mapId) ~= "string" or not KNOWN_MAP_IDS[req.mapId] then
		return false, "Invalid mapId"
	end
	if typeof(req.selectionRevision) ~= "number" or req.selectionRevision < 0 then
		return false, "Invalid selectionRevision"
	end
	if typeof(req.requestId) ~= "string" or #req.requestId == 0 then
		return false, "Invalid requestId"
	end
	return true, nil
end

return table.freeze(MapContract)
