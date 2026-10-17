--!strict
-- src/Shared/PresentationContract.luau
-- Anime Limitless Tower Defense — Phase 6 Presentation Contract
-- Formal schema definitions for Server->Client decoupled attack presentation,
-- camera feedback sink, quality policies, and error handling.

export type AttackPresentationPayload = {
	version: number,
	attackId: string,
	unitUid: string,
	heroId: string,
	startedAtServerTime: number,
	impactAtServerTime: number,
	logicalOriginCFrame: CFrame,
	targetPositionSnapshot: Vector3,
	visualSeed: number,
	presentationRevision: number,
}

export type FeedbackShakePayload = {
	intensity: number,
	color: Color3?,
	duration: number?,
	profile: string?,
}

export type FeedbackFlashPayload = {
	color: Color3?,
	maxTransparency: number?,
	duration: number?,
}

export type CameraAcquirePayload = {
	ownerToken: string,
	priority: number, -- Higher preempts lower (Lab = 100, Lobby = 50, Gameplay = 10)
}

export type CameraReleasePayload = {
	ownerToken: string,
}

local PresentationContract = {
	VERSION = 1,

	REMOTES = {
		TOWER_PRESENTATION_EVENT = "TowerPresentationEvent", -- Server -> Client RemoteEvent
		MAP_SELECTION_STATE = "MapSelectionState",           -- Server -> Client RemoteEvent
		MAP_VOTE_REQUEST = "MapVoteRequest",                 -- Client -> Server RemoteEvent
		ANIMATION_LAB_COMMAND = "AnimationLabCommand",       -- Client <-> Server RemoteFunction
	},

	PORTS = {
		PRESENTATION_FEEDBACK = "PresentationFeedback",     -- Client-local BindableEvent in PlayerGui
	},

	FEEDBACK_ACTIONS = {
		SHAKE = "Shake",
		FLASH = "Flash",
		ACQUIRE_CAMERA = "AcquireCamera",
		RELEASE_CAMERA = "ReleaseCamera",
	},

	CAMERA_PRIORITIES = {
		GAMEPLAY = 10,
		AMBIENT_COMBAT = 20,
		LOBBY_PREVIEW = 50,
		ULTIMATE_CINEMATIC = 80,
		ANIMATION_LAB = 100,
		AmbientCombat = 20,
		UltimateCinematic = 80,
		Gameplay = 10,
		LobbyPreview = 50,
		AnimationLab = 100,
	},

	QUALITY_PRESETS = {
		LOW = "Low",
		MEDIUM = "Medium",
		HIGH = "High",
	},

	SHAKE_MODES = {
		OFF = "Off",
		REDUCED = "Reduced",
		FULL = "Full",
	},

	FLASH_MODES = {
		OFF = "Off",
		REDUCED = "Reduced",
		FULL = "Full",
	},

	ERROR_CODES = {
		INVALID_PAYLOAD = "INVALID_PAYLOAD",
		STALE_REVISION = "STALE_REVISION",
		UNKNOWN_HERO = "UNKNOWN_HERO",
		UNKNOWN_MAP = "UNKNOWN_MAP",
		VOTE_LOCKED = "VOTE_LOCKED",
		RATE_LIMITED = "RATE_LIMITED",
		NOT_STUDIO = "NOT_STUDIO",
		SESSION_NOT_FOUND = "SESSION_NOT_FOUND",
	},
}

function PresentationContract.ValidateAttackPayload(payload: any): (boolean, string?)
	if typeof(payload) ~= "table" then
		return false, "Payload must be a table"
	end
	if typeof(payload.attackId) ~= "string" or #payload.attackId == 0 then
		return false, "Missing or invalid attackId"
	end
	if typeof(payload.unitUid) ~= "string" or #payload.unitUid == 0 then
		return false, "Missing or invalid unitUid"
	end
	if typeof(payload.heroId) ~= "string" or #payload.heroId == 0 then
		return false, "Missing or invalid heroId"
	end
	if typeof(payload.startedAtServerTime) ~= "number" then
		return false, "Invalid startedAtServerTime"
	end
	if typeof(payload.impactAtServerTime) ~= "number" then
		return false, "Invalid impactAtServerTime"
	end
	if typeof(payload.targetPositionSnapshot) ~= "Vector3" then
		return false, "Invalid targetPositionSnapshot"
	end
	return true, nil
end

PresentationContract.ValidatePresentationEvent = PresentationContract.ValidateAttackPayload

function PresentationContract.CanOverrideCamera(newPrio: any, currentPrio: any): boolean
	local numNew = if typeof(newPrio) == "number" then newPrio else (PresentationContract.CAMERA_PRIORITIES[newPrio] or 0)
	local numCur = if typeof(currentPrio) == "number" then currentPrio else (PresentationContract.CAMERA_PRIORITIES[currentPrio] or 0)
	return numNew >= numCur
end

return table.freeze(PresentationContract)
