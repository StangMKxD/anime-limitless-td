--!strict
-- src/Presentation/PresentationPreferences.luau
-- Anime Limitless Tower Defense — Phase 6 Client-Local Presentation Preferences
-- Manages per-player visual fidelity, camera feedback, accessibility, and UI scale settings.
-- Strictly client-local; never modifies server combat stats or persistence without authorization.

export type QualityPreset = "Low" | "Medium" | "High"
export type FeedbackMode = "Off" | "Reduced" | "Full"

export type PreferencesSnapshot = {
	schemaVersion: number,
	quality: QualityPreset,
	cameraShakeMode: FeedbackMode,
	flashMode: FeedbackMode,
	decorativeAura: boolean,
	reducedMotion: boolean,
	uiScale: number,
}

local DEFAULT_PREFERENCES: PreferencesSnapshot = {
	schemaVersion = 1,
	quality = "Medium",
	cameraShakeMode = "Full",
	flashMode = "Full",
	decorativeAura = true,
	reducedMotion = false,
	uiScale = 1.0,
}

local currentPreferences: PreferencesSnapshot = table.clone(DEFAULT_PREFERENCES)
local listeners: { [number]: (PreferencesSnapshot) -> () } = {}
local nextListenerId = 1

local PresentationPreferences = {}

function PresentationPreferences.GetSnapshot(): PreferencesSnapshot
	return table.clone(currentPreferences)
end

function PresentationPreferences.Get(key: string): any
	return (currentPreferences :: any)[key]
end

function PresentationPreferences.Subscribe(listener: (PreferencesSnapshot) -> ()): any
	local id = nextListenerId
	nextListenerId += 1
	listeners[id] = listener

	local disconnectFn = function()
		listeners[id] = nil
	end

	local conn = {
		Disconnect = disconnectFn,
	}
	setmetatable(conn, {
		__call = function()
			disconnectFn()
		end,
	})

	return conn
end

local function notifyListeners()
	local snapshot = table.clone(currentPreferences)
	for _, fn in pairs(listeners) do
		pcall(fn, snapshot)
	end
end

function PresentationPreferences.SetLocal(key: string, value: any): (boolean, string?)
	if key == "quality" then
		if value == "Low" or value == "Medium" or value == "High" then
			currentPreferences.quality = value
		else
			return false, "Invalid quality preset (must be Low, Medium, or High)"
		end
	elseif key == "cameraShakeMode" then
		if value == "Off" or value == "Reduced" or value == "Full" then
			currentPreferences.cameraShakeMode = value
		else
			return false, "Invalid cameraShakeMode (must be Off, Reduced, or Full)"
		end
	elseif key == "flashMode" then
		if value == "Off" or value == "Reduced" or value == "Full" then
			currentPreferences.flashMode = value
		else
			return false, "Invalid flashMode (must be Off, Reduced, or Full)"
		end
	elseif key == "decorativeAura" then
		if typeof(value) == "boolean" then
			currentPreferences.decorativeAura = value
		else
			return false, "decorativeAura must be a boolean"
		end
	elseif key == "reducedMotion" then
		if typeof(value) == "boolean" then
			currentPreferences.reducedMotion = value
		else
			return false, "reducedMotion must be a boolean"
		end
	elseif key == "uiScale" then
		if typeof(value) == "number" and value >= 0.75 and value <= 1.50 then
			currentPreferences.uiScale = math.clamp(value, 0.75, 1.50)
		else
			return false, "uiScale must be a number between 0.75 and 1.50"
		end
	else
		return false, "Unknown preference key: " .. tostring(key)
	end

	notifyListeners()
	return true, nil
end

function PresentationPreferences.ResetLocal()
	currentPreferences = table.clone(DEFAULT_PREFERENCES)
	notifyListeners()
end

return table.freeze(PresentationPreferences)
