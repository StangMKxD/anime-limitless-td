--!strict
-- src/DevTools/AnimationLab/VFXInspector.luau
-- 6-Layer VFX Toggles, Quality Selector, Intensity Slider, and Trigger Controls.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local VFXContract = require(SharedFolder:WaitForChild("VFXContract")) :: any

local VFXInspector = {}

export type InspectorState = {
	activeQuality: VFXContract.VFXQualityPreset,
	activeIntensity: number,
	layerFlags: VFXContract.VFXLayerFlags,
	activeModel: Model?,
	activeContainer: Folder?,
}

local state: InspectorState = {
	activeQuality = "High",
	activeIntensity = 1.0,
	layerFlags = VFXContract.DEFAULT_LAYER_FLAGS,
	activeModel = nil,
	activeContainer = nil,
}

function VFXInspector.BindModel(model: Model?, container: Folder?)
	state.activeModel = model
	state.activeContainer = container
end

function VFXInspector.SetQuality(preset: VFXContract.VFXQualityPreset)
	state.activeQuality = preset
end

function VFXInspector.SetIntensity(intensity: number)
	state.activeIntensity = VFXContract.ClampIntensity(intensity)
end

function VFXInspector.SetLayerFlag(flagName: string, enabled: boolean)
	local flags = table.clone(state.layerFlags) :: any
	if flags[flagName] ~= nil then
		flags[flagName] = enabled
		state.layerFlags = flags
	end
end

function VFXInspector.GetState(): InspectorState
	return state
end

function VFXInspector.BuildExecutionContext(cueType: string, rootPart: BasePart, targetPos: Vector3): any
	return {
		heroId = state.activeModel and state.activeModel.Name or "Unknown",
		cueType = cueType,
		sourceModel = state.activeModel,
		rootPart = rootPart,
		originCFrame = rootPart.CFrame,
		targetPosition = targetPos,
		targetModel = nil,
		intensity = state.activeIntensity,
		quality = state.activeQuality,
		layerFlags = state.layerFlags,
		sandboxContainer = state.activeContainer,
		registerInstance = function(inst: Instance, ttl: number?) end,
		registerTween = function(tw: Tween) end,
		registerTask = function(tk: any) end,
		registerConnection = function(cn: RBXScriptConnection) end,
		registerCleanupCallback = function(cb: () -> ()) end,
	}
end

return table.freeze(VFXInspector)
