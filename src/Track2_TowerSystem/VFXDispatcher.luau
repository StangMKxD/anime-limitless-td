--!strict
-- src/Track2_TowerSystem/VFXDispatcher.luau
-- Anime Limitless Tower Defense — Phase 5 Core VFX Dispatcher & Resource Ledger (P5-10)
-- Features 100% Guaranteed Cleanup, Quality Preset Caps, Layer Toggles, and Strict Combat Decoupling.

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local VFXContract = require(SharedFolder:WaitForChild("VFXContract")) :: any

local VFXDispatcher = {}

-- Sibling registry reference (lazy load)
local AnimationRegistry: any = nil
local function getRegistry(): any
	if not AnimationRegistry then
		local regInst = script.Parent:FindFirstChild("AnimationRegistry")
		if regInst and regInst:IsA("ModuleScript") then
			AnimationRegistry = require(regInst)
		end
	end
	return AnimationRegistry
end

-- Global configuration state
local currentQuality: VFXContract.VFXQualityPreset = "High"
local currentIntensity: number = VFXContract.DEFAULT_INTENSITY
local currentLayerFlags: VFXContract.VFXLayerFlags = VFXContract.DEFAULT_LAYER_FLAGS

-- Per-Model Owner Resource Ledger
type ModelLedger = {
	instances: { [Instance]: number? },
	tweens: { [Tween]: boolean },
	tasks: { [thread]: boolean },
	connections: { [RBXScriptConnection]: boolean },
	cleanupCallbacks: { () -> () },
	createdCount: number,
	cleanedCount: number,
}

local activeLedgers: { [Model]: ModelLedger } = {}

-- =============================================================================
-- 1. CONFIGURATION ACCESSORS
-- =============================================================================

function VFXDispatcher.SetQualityPreset(preset: VFXContract.VFXQualityPreset)
	if preset == "Low" or preset == "Medium" or preset == "High" then
		currentQuality = preset
	end
end

function VFXDispatcher.GetQualityPreset(): VFXContract.VFXQualityPreset
	return currentQuality
end

function VFXDispatcher.SetGlobalIntensity(intensity: number)
	currentIntensity = VFXContract.ClampIntensity(intensity)
end

function VFXDispatcher.GetGlobalIntensity(): number
	return currentIntensity
end

function VFXDispatcher.SetGlobalLayerFlags(flags: { [string]: boolean })
	currentLayerFlags = VFXContract.MergeLayerFlags(flags)
end

function VFXDispatcher.GetGlobalLayerFlags(): VFXContract.VFXLayerFlags
	return currentLayerFlags
end

-- =============================================================================
-- 2. OWNER RESOURCE LEDGER MANAGEMENT
-- =============================================================================

local function getOrCreateLedger(model: Model): ModelLedger
	local ledger = activeLedgers[model]
	if not ledger then
		ledger = {
			instances = {},
			tweens = {},
			tasks = {},
			connections = {},
			cleanupCallbacks = {},
			createdCount = 0,
			cleanedCount = 0,
		}
		activeLedgers[model] = ledger

		-- Automatically hook destruction events to guarantee 100% cleanup upon unit sale or death
		local destroyingConn: RBXScriptConnection? = nil
		destroyingConn = model.Destroying:Connect(function()
			if destroyingConn then
				destroyingConn:Disconnect()
				ledger.connections[destroyingConn] = nil
			end
			VFXDispatcher.cleanupAllForModel(model)
		end)
		ledger.connections[destroyingConn] = true
	end
	return ledger
end

function VFXDispatcher.cleanupAllForModel(model: Model)
	local ledger = activeLedgers[model]
	if not ledger then return end

	-- 1. Disconnect all connections
	for conn, _ in pairs(ledger.connections) do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	table.clear(ledger.connections)

	-- 2. Cancel all tweens
	for tween, _ in pairs(ledger.tweens) do
		pcall(function()
			tween:Cancel()
		end)
	end
	table.clear(ledger.tweens)

	-- 3. Cancel all tasks
	for t, _ in pairs(ledger.tasks) do
		pcall(function()
			task.cancel(t)
		end)
	end
	table.clear(ledger.tasks)

	-- 4. Execute cleanup callbacks
	for _, cb in ipairs(ledger.cleanupCallbacks) do
		pcall(cb)
	end
	table.clear(ledger.cleanupCallbacks)

	-- 5. Destroy all tracked visual instances
	for inst, _ in pairs(ledger.instances) do
		if inst.Parent then
			pcall(function()
				inst:Destroy()
			end)
		end
		ledger.cleanedCount += 1
	end
	table.clear(ledger.instances)

	-- 6. Notify character VFX module cleanup if registered
	local heroId = model.Name
	local reg = getRegistry()
	if reg and reg.GetVFXModule then
		local vfxModule = reg.GetVFXModule(heroId)
		if vfxModule and type(vfxModule.cleanupAllForModel) == "function" then
			pcall(function()
				vfxModule.cleanupAllForModel(model)
			end)
		end
	end

	-- 7. Reset active aura attribute
	if model.Parent then
		pcall(function()
			model:SetAttribute("HasActivePassiveAura", false)
		end)
	end

	-- Remove ledger
	activeLedgers[model] = nil
end

function VFXDispatcher.GetLedgerReport(model: Model?): VFXContract.ResourceLedgerReport
	if model then
		local ledger = activeLedgers[model]
		if not ledger then
			return {
				trackedInstances = 0,
				trackedTweens = 0,
				trackedTasks = 0,
				trackedConnections = 0,
				createdCount = 0,
				cleanedCount = 0,
				activeCount = 0,
			}
		end
		local activeInst = 0
		for _ in pairs(ledger.instances) do activeInst += 1 end
		local activeTw = 0
		for _ in pairs(ledger.tweens) do activeTw += 1 end
		local activeTk = 0
		for _ in pairs(ledger.tasks) do activeTk += 1 end
		local activeCn = 0
		for conn in pairs(ledger.connections) do
			if conn.Connected then
				activeCn += 1
			else
				ledger.connections[conn] = nil
			end
		end

		return {
			trackedInstances = activeInst,
			trackedTweens = activeTw,
			trackedTasks = activeTk,
			trackedConnections = activeCn,
			createdCount = ledger.createdCount,
			cleanedCount = ledger.cleanedCount,
			activeCount = activeInst,
		}
	else
		-- Aggregate report across all active ledgers
		local totInst = 0
		local totTw = 0
		local totTk = 0
		local totCn = 0
		local totCreated = 0
		local totCleaned = 0
		for _, l in pairs(activeLedgers) do
			for _ in pairs(l.instances) do totInst += 1 end
			for _ in pairs(l.tweens) do totTw += 1 end
			for _ in pairs(l.tasks) do totTk += 1 end
			for conn in pairs(l.connections) do
				if conn.Connected then
					totCn += 1
				else
					l.connections[conn] = nil
				end
			end
			totCreated += l.createdCount
			totCleaned += l.cleanedCount
		end
		return {
			trackedInstances = totInst,
			trackedTweens = totTw,
			trackedTasks = totTk,
			trackedConnections = totCn,
			createdCount = totCreated,
			cleanedCount = totCleaned,
			activeCount = totInst,
		}
	end
end

-- =============================================================================
-- 3. CUE TRIGGERING & QUALITY ENFORCEMENT
-- =============================================================================

function VFXDispatcher.TriggerCue(options: {
	sourceModel: Model,
	cueType: VFXContract.VFXCueType,
	heroId: string?,
	originCFrame: CFrame?,
	targetPosition: Vector3?,
	targetModel: Model?,
	intensity: number?,
	quality: VFXContract.VFXQualityPreset?,
	layerFlags: { [string]: boolean }?,
	sandboxContainer: Folder?,
})
	debug.profilebegin("ALT_Phase5_VFXDispatch")

	local sourceModel = options.sourceModel
	if not sourceModel or not sourceModel:IsA("Model") or not sourceModel.Parent then
		debug.profileend()
		return
	end

	local rootPart = sourceModel:FindFirstChild("HumanoidRootPart") :: BasePart? or sourceModel.PrimaryPart
	if not rootPart then
		debug.profileend()
		return
	end

	local heroId = options.heroId or sourceModel.Name
	local cue = options.cueType or "AttackImpact"
	local quality = options.quality or currentQuality
	local qConfig = VFXContract.ResolveQuality(quality)
	local intensity = VFXContract.ClampIntensity(options.intensity or currentIntensity)
	local layerFlags = if options.layerFlags then VFXContract.MergeLayerFlags(options.layerFlags) else currentLayerFlags

	local ledger = getOrCreateLedger(sourceModel)

	-- Build Execution Context with registered ledger delegates
	local ctx: VFXContract.VFXExecutionContext = {
		heroId = heroId,
		cueType = cue,
		sourceModel = sourceModel,
		rootPart = rootPart,
		originCFrame = options.originCFrame or rootPart.CFrame,
		targetPosition = options.targetPosition or (rootPart.Position + rootPart.CFrame.LookVector * 15),
		targetModel = options.targetModel,
		intensity = intensity,
		quality = quality,
		layerFlags = layerFlags,
		sandboxContainer = options.sandboxContainer,

		registerInstance = function(inst: Instance, ttlSeconds: number?)
			if not inst then return end

			-- Enforce maxParts quality ceiling
			local activeCount = 0
			for _ in pairs(ledger.instances) do activeCount += 1 end
			if activeCount >= qConfig.maxParts and inst:IsA("BasePart") then
				inst:Destroy()
				return
			end

			-- Enforce quality and layer restrictions (point lights, beams, trails)
			if inst:IsA("PointLight") and not qConfig.allowPointLights then
				inst:Destroy()
				return
			end
			if inst:IsA("Trail") and (not qConfig.allowTrails or not layerFlags.enableTrailOrBeam) then
				inst:Destroy()
				return
			end
			if inst:IsA("Beam") and (not qConfig.allowBeams or not layerFlags.enableTrailOrBeam) then
				inst:Destroy()
				return
			end

			ledger.createdCount += 1
			ledger.instances[inst] = os.clock()

			-- Hook Destroying event to safely unregister if destroyed early and cancel scheduled TTL task
			local ttlTask: thread? = nil
			local destroyConn: RBXScriptConnection? = nil
			destroyConn = inst.Destroying:Connect(function()
				if destroyConn then
					destroyConn:Disconnect()
					ledger.connections[destroyConn] = nil
				end
				if ttlTask then
					pcall(function()
						task.cancel(ttlTask)
					end)
					ledger.tasks[ttlTask] = nil
					ttlTask = nil
				end
				if ledger.instances[inst] then
					ledger.instances[inst] = nil
					ledger.cleanedCount += 1
				end
			end)
			ledger.connections[destroyConn] = true

			if ttlSeconds and ttlSeconds > 0 then
				ttlTask = task.delay(ttlSeconds, function()
					if ttlTask then
						ledger.tasks[ttlTask] = nil
						ttlTask = nil
					end
					if inst.Parent then
						inst:Destroy()
					end
				end)
				ledger.tasks[ttlTask] = true
			end
		end,

		registerTween = function(tween: Tween)
			if not tween then return end
			ledger.tweens[tween] = true
			local conn: RBXScriptConnection? = nil
			conn = tween.Completed:Connect(function()
				if conn then
					conn:Disconnect()
					ledger.connections[conn] = nil
				end
				ledger.tweens[tween] = nil
			end)
			ledger.connections[conn] = true
		end,

		registerTask = function(taskRef: any)
			if taskRef then
				ledger.tasks[taskRef] = true
			end
		end,

		registerConnection = function(conn: RBXScriptConnection)
			if conn then
				ledger.connections[conn] = true
			end
		end,

		registerCleanupCallback = function(cb: () -> ())
			if cb then
				table.insert(ledger.cleanupCallbacks, cb)
			end
		end,
	}

	-- Resolve character VFX module via dynamic registry
	local reg = getRegistry()
	local vfxModule: VFXContract.CharacterVFXModule? = nil
	if reg and reg.GetVFXModule then
		vfxModule = reg.GetVFXModule(heroId)
	end

	if vfxModule and type(vfxModule.triggerCue) == "function" then
		-- Strictly protected call: visual failure NEVER crashes or delays combat
		local ok, err = pcall(function()
			vfxModule.triggerCue(ctx)
		end)
		if not ok then
			warn(string.format("[VFXDispatcher] Visual execution error on '%s' for cue '%s': %s", heroId, tostring(cue), tostring(err)))
		end
	end

	debug.profileend()
end

-- =============================================================================
-- 4. PASSIVE AURA MANAGEMENT
-- =============================================================================

function VFXDispatcher.StartPassiveAura(model: Model, heroId: string)
	if model:GetAttribute("HasActivePassiveAura") == true then
		return -- Prevent duplicate aura stacking
	end

	model:SetAttribute("HasActivePassiveAura", true)
	VFXDispatcher.TriggerCue({
		sourceModel = model,
		cueType = "PassiveAura",
		heroId = heroId,
	})
end

function VFXDispatcher.StopPassiveAura(model: Model, heroId: string)
	model:SetAttribute("HasActivePassiveAura", false)
	local reg = getRegistry()
	if reg and reg.GetVFXModule then
		local vfxModule = reg.GetVFXModule(heroId)
		if vfxModule and type(vfxModule.stopPassiveAura) == "function" then
			pcall(function()
				vfxModule.stopPassiveAura(model)
			end)
		end
	end
end

function VFXDispatcher.CleanupAll()
	for model, _ in pairs(activeLedgers) do
		VFXDispatcher.cleanupAllForModel(model)
	end
	table.clear(activeLedgers)
end

return VFXDispatcher
