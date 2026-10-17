--!strict
-- src/Presentation/VFXDispatcher.luau
-- Anime Limitless Tower Defense — Phase 6 Neutral Presentation VFX Dispatcher
-- Client-safe and server-safe VFX lifecycle orchestration, resource ledger, and quality caps.

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local VFXContract = (function()
	local ok, mod = pcall(function()
		return require(SharedFolder:WaitForChild("VFXContract"))
	end)
	if ok and mod then return mod end
	local ok2, mod2 = pcall(require, "./VFXContract")
	if ok2 and mod2 then return mod2 end
	local ok3, mod3 = pcall(require, "../Shared/VFXContract")
	if ok3 and mod3 then return mod3 end
	local ok4, mod4 = pcall(require, "../src/Shared/VFXContract")
	if ok4 and mod4 then return mod4 end
	error("Failed to resolve VFXContract")
end)()
local QualityPolicy = (function()
	local ok, mod = pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local pres = rs:WaitForChild("Presentation")
		return require(pres:WaitForChild("QualityPolicy"))
	end)
	if ok and mod then return mod end
	if typeof(script) ~= "nil" and script.Parent then
		local ok2, mod2 = pcall(function()
			return require(script.Parent:WaitForChild("QualityPolicy"))
		end)
		if ok2 and mod2 then return mod2 end
	end
	local ok3, mod3 = pcall(require, "./QualityPolicy")
	if ok3 and mod3 then return mod3 end
	local ok4, mod4 = pcall(require, "../src/Presentation/QualityPolicy")
	if ok4 and mod4 then return mod4 end
	error("Failed to resolve QualityPolicy")
end)()

local PresentationPreferences = (function()
	local ok, mod = pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		local pres = rs:WaitForChild("Presentation")
		return require(pres:WaitForChild("PresentationPreferences"))
	end)
	if ok and mod then return mod end
	if typeof(script) ~= "nil" and script.Parent then
		local ok2, mod2 = pcall(function()
			return require(script.Parent:WaitForChild("PresentationPreferences"))
		end)
		if ok2 and mod2 then return mod2 end
	end
	local ok3, mod3 = pcall(require, "./PresentationPreferences")
	if ok3 and mod3 then return mod3 end
	local ok4, mod4 = pcall(require, "../src/Presentation/PresentationPreferences")
	if ok4 and mod4 then return mod4 end
	error("Failed to resolve PresentationPreferences")
end)()

local VFXDispatcher = {}

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
	if not ledger then
		return
	end

	for _, cb in ipairs(ledger.cleanupCallbacks) do
		pcall(cb)
	end
	table.clear(ledger.cleanupCallbacks)

	for conn, _ in pairs(ledger.connections) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(ledger.connections)

	for tween, _ in pairs(ledger.tweens) do
		pcall(function()
			tween:Cancel()
		end)
	end
	table.clear(ledger.tweens)

	for t, _ in pairs(ledger.tasks) do
		pcall(function()
			task.cancel(t)
		end)
	end
	table.clear(ledger.tasks)

	for inst, _ in pairs(ledger.instances) do
		ledger.cleanedCount += 1
		pcall(function()
			if inst.Parent then
				inst:Destroy()
			end
		end)
	end
	table.clear(ledger.instances)

	activeLedgers[model] = nil
end

function VFXDispatcher.GetActiveLedger(model: Model): ModelLedger?
	return activeLedgers[model]
end

function VFXDispatcher.TriggerCue(request: {
	sourceModel: Model,
	cueType: string,
	heroId: string?,
	targetPosition: Vector3?,
	intensity: number?,
})
	local model = request.sourceModel
	if not model or not model.Parent then
		return
	end

	local ledger = getOrCreateLedger(model)
	local caps = QualityPolicy.GetActiveCaps()

	-- Enforce part budget
	local activeCount = 0
	for _ in pairs(ledger.instances) do
		activeCount += 1
	end
	if activeCount >= caps.maxVFXPartsPerModel then
		return
	end

	local originCF = model.PrimaryPart and model.PrimaryPart.CFrame or CFrame.identity
	local targetPos = request.targetPosition or (originCF.Position + originCF.LookVector * 15)

	local ctx = {
		sourceModel = model,
		cueType = request.cueType,
		heroId = request.heroId or model.Name,
		originCFrame = originCF,
		targetPosition = targetPos,
		intensity = request.intensity or 1.0,
		quality = PresentationPreferences.GetSnapshot().quality,
		layerFlags = {
			enableParticles = true,
			enableAura = caps.enableAuras,
			enableTrailOrBeam = caps.enableTrails,
			enableImpactEffect = true,
			enableCameraShake = (caps.shakeScale > 0),
			enableScreenFlash = (caps.flashAlpha > 0),
		},

		registerInstance = function(inst: Instance, ttlSeconds: number?)
			if not inst then return end
			ledger.createdCount += 1
			ledger.instances[inst] = os.clock()

			local destroyConn: RBXScriptConnection? = nil
			local ttlTask: thread? = nil

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
				end
				if ledger.instances[inst] then
					ledger.instances[inst] = nil
					ledger.cleanedCount += 1
				end
			end)
			ledger.connections[destroyConn] = true

			if ttlSeconds and ttlSeconds > 0 then
				ttlTask = task.delay(ttlSeconds, function()
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

	-- Trigger generic visual shockwave / impact cue if impact
	if request.cueType == "AttackImpact" and caps.enableAuras then
		local shockwave = Instance.new("Part")
		shockwave.Name = "VFXShockwave"
		shockwave.Shape = Enum.PartType.Ball
		shockwave.Size = Vector3.new(2, 2, 2)
		shockwave.Position = targetPos
		shockwave.Anchored = true
		shockwave.CanCollide = false
		shockwave.Material = Enum.Material.Neon
		shockwave.Transparency = 0.3
		shockwave.Color = Color3.fromRGB(255, 220, 120)
		shockwave.Parent = Workspace

		ctx.registerInstance(shockwave, 0.25)
		local tw = TweenService:Create(shockwave, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(8, 8, 8),
			Transparency = 1,
		})
		tw:Play()
		ctx.registerTween(tw)
	end
end

function VFXDispatcher.TriggerVFX(model: Model, options: any)
	local cue = (options and (options.cue or options.cueType)) or "AttackImpact"
	local heroId = options and options.heroId
	local impactPos = options and (options.impactPosition or options.targetPosition)
	local intensity = options and options.intensity
	VFXDispatcher.TriggerCue({
		sourceModel = model,
		cueType = cue,
		heroId = heroId,
		targetPosition = impactPos,
		intensity = intensity,
	})
end

VFXDispatcher.CleanupModel = VFXDispatcher.cleanupAllForModel

function VFXDispatcher.GetLedgerReport(model: Model?): any
	if model then
		local ledger = activeLedgers[model]
		if not ledger then
			return {
				activeCount = 0,
				trackedInstances = 0,
				trackedConnections = 0,
				createdCount = 0,
				cleanedCount = 0,
			}
		end
		local activeInst = 0
		for _ in pairs(ledger.instances) do activeInst += 1 end
		local activeConn = 0
		for _ in pairs(ledger.connections) do activeConn += 1 end
		return {
			activeCount = activeInst,
			trackedInstances = activeInst,
			trackedConnections = activeConn,
			createdCount = ledger.createdCount,
			cleanedCount = ledger.cleanedCount,
		}
	else
		local totalActive = 0
		local totalTracked = 0
		local totalCreated = 0
		local totalCleaned = 0
		for _, l in pairs(activeLedgers) do
			for _ in pairs(l.instances) do
				totalActive += 1
				totalTracked += 1
			end
			totalCreated += l.createdCount
			totalCleaned += l.cleanedCount
		end
		return {
			activeCount = totalActive,
			trackedInstances = totalTracked,
			trackedConnections = 0,
			createdCount = totalCreated,
			cleanedCount = totalCleaned,
		}
	end
end

return table.freeze(VFXDispatcher)
