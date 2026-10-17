--!strict
-- tests/phase5_stress_benchmark.spec.luau
-- Authoritative 1/10/25/50 Character Stress Benchmark Suite (Task P5-22 & Gates G-07, G-10, G-12)
-- Tests 1, 10, 25, 50 concurrent character stress loads, real-time telemetry, part budgets,
-- quality throttling, and 100% zero-leak resource balance.

local roblox = (function()
	local ok, mod = pcall(require, "@lune/roblox")
	return if ok then mod else nil
end)()

local fs = (function()
	local ok, mod = pcall(require, "@lune/fs")
	return if ok then mod else nil
end)()

local luau = (function()
	local ok, mod = pcall(require, "@lune/luau")
	return if ok then mod else nil
end)()

local luneTask = (function()
	local ok, mod = pcall(require, "@lune/task")
	return if ok then mod else nil
end)()

-- Safe global environment setup for Lune CLI compatibility
local origInstance = (typeof(Instance) ~= "nil" and Instance) or (roblox and roblox.Instance)
local CFrame = (typeof(CFrame) ~= "nil" and CFrame) or (roblox and roblox.CFrame)
local Vector3 = (typeof(Vector3) ~= "nil" and Vector3) or (roblox and roblox.Vector3)
local Enum = (typeof(Enum) ~= "nil" and Enum) or (roblox and roblox.Enum)
local Color3 = (typeof(Color3) ~= "nil" and Color3) or (roblox and roblox.Color3)

local customTweenInfo = {
	new = function(time: number?, easingStyle: any?, easingDirection: any?, repeatCount: number?, reverses: boolean?, delayTime: number?)
		return { time = time or 1 }
	end,
}
local TweenInfo = (typeof(TweenInfo) ~= "nil" and TweenInfo) or (roblox and roblox.TweenInfo) or customTweenInfo

local task = (typeof(task) ~= "nil" and task) or luneTask or {
	delay = function(sec: number, fn: () -> ()) return nil end,
	cancel = function(t: any) end,
	spawn = function(fn: () -> ()) end,
	wait = function(sec: number?) return 0 end,
}

local customInstance = {}
if origInstance then
	for k, v in pairs(origInstance) do
		customInstance[k] = v
	end
	customInstance.new = function(className: string, parent: any?)
		local inst = origInstance.new(className, parent)
		if className == "Part" or className == "WedgePart" or className == "MeshPart" then
			inst.Position = Vector3.zero
			inst.Size = Vector3.new(2, 1, 1)
			inst.CFrame = CFrame.identity
		end
		return inst
	end
end
local Instance = customInstance

if roblox then
	pcall(function()
		roblox.implementMethod("Instance", "WaitForChild", function(self, childName, timeout)
			return self:FindFirstChild(childName)
		end)
	end)

	pcall(function()
		roblox.implementMethod("Instance", "PivotTo", function(self, targetCFrame)
			local root = self.PrimaryPart or self:FindFirstChild("HumanoidRootPart") or self:FindFirstChildWhichIsA("BasePart")
			if root then
				root.CFrame = targetCFrame
			end
		end)
	end)

	pcall(function()
		roblox.implementProperty("Instance", "Destroying", function(self)
			return {
				Connect = function(sigSelf, fn)
					return { Disconnect = function() end }
				end,
			}
		end)
	end)
end

local customDebug = {}
for k, v in pairs(debug) do
	customDebug[k] = v
end
customDebug.profilebegin = function(name: string) end
customDebug.profileend = function() end

local env = getfenv()
env.Instance = Instance
env.CFrame = CFrame
env.Vector3 = Vector3
env.Enum = Enum
env.Color3 = Color3
env.TweenInfo = TweenInfo
env.task = task
env.debug = customDebug

-- Mock environment folders
local mockRS = Instance.new("Folder")
mockRS.Name = "ReplicatedStorage"
local mockShared = Instance.new("Folder")
mockShared.Name = "Shared"
mockShared.Parent = mockRS

local mockWS = Instance.new("Workspace")
local defaultCam = Instance.new("Camera")
mockWS.CurrentCamera = defaultCam

local mockRunService = {
	Heartbeat = { Connect = function(self, fn) return { Disconnect = function() end } end },
	RenderStepped = { Connect = function(self, fn) return { Disconnect = function() end } end },
	IsStudio = function(self) return true end,
}

local mockTweenService = {
	Create = function(self, inst, info, props)
		return {
			Play = function(s) end,
			Cancel = function(s) end,
			Completed = { Connect = function(s, fn) return { Disconnect = function() end } end },
		}
	end,
}

env.game = {
	GetService = function(self, name)
		if name == "ReplicatedStorage" then return mockRS
		elseif name == "Workspace" then return mockWS
		elseif name == "RunService" then return mockRunService
		elseif name == "TweenService" then return mockTweenService
		end
		return Instance.new("Folder")
	end,
}

local realRequire = require

-- Load Deliverables
local AnimationContract = (function()
	local paths = { "../src/Shared/AnimationContract", "src/Shared/AnimationContract", "../../src/Shared/AnimationContract", "../../../src/Shared/AnimationContract" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	error("Cannot load AnimationContract")
end)()

local VFXContract = (function()
	local paths = { "../src/Shared/VFXContract", "src/Shared/VFXContract", "../../src/Shared/VFXContract", "../../../src/Shared/VFXContract" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	error("Cannot load VFXContract")
end)()

local LabConfig = (function()
	local paths = { "../src/DevTools/AnimationLab/LabConfig", "src/DevTools/AnimationLab/LabConfig", "../../src/DevTools/AnimationLab/LabConfig", "../../../src/DevTools/AnimationLab/LabConfig" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	if fs and luau then
		local fpaths = { "src/DevTools/AnimationLab/LabConfig.luau", "../src/DevTools/AnimationLab/LabConfig.luau", "../../../src/DevTools/AnimationLab/LabConfig.luau" }
		for _, fp in ipairs(fpaths) do
			local ok, content = pcall(fs.readFile, fp)
			if ok then
				local clean = string.gsub(content, "LabConfig%.ASSET_CATALOG: %{ %[string%]: AssetCatalogEntry %} =", "LabConfig.ASSET_CATALOG =")
				local fn = luau.load(clean)
				return fn()
			end
		end
	end
	error("Cannot load LabConfig")
end)()

local animModScript = Instance.new("ModuleScript") animModScript.Name = "AnimationContract" animModScript.Parent = mockShared
local vfxModScript = Instance.new("ModuleScript") vfxModScript.Name = "VFXContract" vfxModScript.Parent = mockShared
local devToolsFolder = Instance.new("Folder") devToolsFolder.Name = "AnimationLab"
local labConfigScript = Instance.new("ModuleScript") labConfigScript.Name = "LabConfig" labConfigScript.Parent = devToolsFolder
local stageMgrScript = Instance.new("ModuleScript") stageMgrScript.Name = "SandboxStageManager" stageMgrScript.Parent = devToolsFolder
local stressRunnerScript = Instance.new("ModuleScript") stressRunnerScript.Name = "StressTestRunner" stressRunnerScript.Parent = devToolsFolder
local telemetryScript = Instance.new("ModuleScript") telemetryScript.Name = "TelemetryCollector" telemetryScript.Parent = devToolsFolder
local track2Folder = Instance.new("Folder") track2Folder.Name = "Track2_TowerSystem"
local animCtrlScript = Instance.new("ModuleScript") animCtrlScript.Name = "AnimationController" animCtrlScript.Parent = track2Folder
local animRegScript = Instance.new("ModuleScript") animRegScript.Name = "AnimationRegistry" animRegScript.Parent = track2Folder
local vfxDispScript = Instance.new("ModuleScript") vfxDispScript.Name = "VFXDispatcher" vfxDispScript.Parent = track2Folder

local SandboxStageManager: any = nil
local StressTestRunner: any = nil
local TelemetryCollector: any = nil
local AnimationRegistry: any = nil
local FallbackVFX: any = nil
local FallbackProfile: any = nil
local LuffyProfile: any = nil
local LuffyVFX: any = nil
local ZoroProfile: any = nil
local ZoroVFX: any = nil
local AceProfile: any = nil
local AceVFX: any = nil

local function customRequire(target: any)
	if typeof(target) == "string" then
		return realRequire(target)
	elseif typeof(target) == "Instance" then
		if target.Name == "AnimationContract" then return AnimationContract
		elseif target.Name == "VFXContract" then return VFXContract
		elseif target.Name == "LabConfig" then return LabConfig
		elseif target.Name == "AnimationRegistry" then return AnimationRegistry
		elseif target.Name == "_FallbackVFX" then return FallbackVFX
		elseif target.Name == "_FallbackProfile" then return FallbackProfile
		elseif target.Name == "Luffy" then return LuffyProfile
		elseif target.Name == "LuffyVFX" then return LuffyVFX
		elseif target.Name == "Zoro" then return ZoroProfile
		elseif target.Name == "ZoroVFX" then return ZoroVFX
		elseif target.Name == "Ace" then return AceProfile
		elseif target.Name == "AceVFX" then return AceVFX
		elseif target.Name == "SandboxStageManager" then return SandboxStageManager
		elseif target.Name == "StressTestRunner" then return StressTestRunner
		elseif target.Name == "TelemetryCollector" then return TelemetryCollector
		end
		return { Name = target.Name }
	end
	error("Unknown target")
end

env.require = customRequire
env.script = animCtrlScript

-- Load AnimationController
local AnimationController = (function()
	local paths = { "../src/Track2_TowerSystem/AnimationController", "src/Track2_TowerSystem/AnimationController", "../../src/Track2_TowerSystem/AnimationController", "../../../src/Track2_TowerSystem/AnimationController" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	error("Cannot load AnimationController")
end)()

-- Load AnimationRegistry & Fallbacks
AnimationRegistry = (function()
	local paths = { "../src/Track2_TowerSystem/AnimationRegistry", "src/Track2_TowerSystem/AnimationRegistry", "../../src/Track2_TowerSystem/AnimationRegistry", "../../../src/Track2_TowerSystem/AnimationRegistry" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	error("Cannot load AnimationRegistry")
end)()

FallbackVFX = (function()
	local paths = { "../src/Track2_TowerSystem/VFX/_FallbackVFX", "src/Track2_TowerSystem/VFX/_FallbackVFX", "../../src/Track2_TowerSystem/VFX/_FallbackVFX", "../../../src/Track2_TowerSystem/VFX/_FallbackVFX" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	error("Cannot load FallbackVFX")
end)()

FallbackProfile = (function()
	local paths = { "../src/Track2_TowerSystem/Animations/_FallbackProfile", "src/Track2_TowerSystem/Animations/_FallbackProfile", "../../src/Track2_TowerSystem/Animations/_FallbackProfile", "../../../src/Track2_TowerSystem/Animations/_FallbackProfile" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	error("Cannot load FallbackProfile")
end)()

-- Load Signature Profiles & VFX
LuffyProfile = (function()
	local paths = { "../src/Track2_TowerSystem/Animations/Luffy", "src/Track2_TowerSystem/Animations/Luffy", "../../src/Track2_TowerSystem/Animations/Luffy", "../../../src/Track2_TowerSystem/Animations/Luffy" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	return nil
end)()

LuffyVFX = (function()
	local paths = { "../src/Track2_TowerSystem/VFX/LuffyVFX", "src/Track2_TowerSystem/VFX/LuffyVFX", "../../src/Track2_TowerSystem/VFX/LuffyVFX", "../../../src/Track2_TowerSystem/VFX/LuffyVFX" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	return nil
end)()

ZoroProfile = (function()
	local paths = { "../src/Track2_TowerSystem/Animations/Zoro", "src/Track2_TowerSystem/Animations/Zoro", "../../src/Track2_TowerSystem/Animations/Zoro", "../../../src/Track2_TowerSystem/Animations/Zoro" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	return nil
end)()

ZoroVFX = (function()
	local paths = { "../src/Track2_TowerSystem/VFX/ZoroVFX", "src/Track2_TowerSystem/VFX/ZoroVFX", "../../src/Track2_TowerSystem/VFX/ZoroVFX", "../../../src/Track2_TowerSystem/VFX/ZoroVFX" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	return nil
end)()

AceProfile = (function()
	local paths = { "../src/Track2_TowerSystem/Animations/Ace", "src/Track2_TowerSystem/Animations/Ace", "../../src/Track2_TowerSystem/Animations/Ace", "../../../src/Track2_TowerSystem/Animations/Ace" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	return nil
end)()

AceVFX = (function()
	local paths = { "../src/Track2_TowerSystem/VFX/AceVFX", "src/Track2_TowerSystem/VFX/AceVFX", "../../src/Track2_TowerSystem/VFX/AceVFX", "../../../src/Track2_TowerSystem/VFX/AceVFX" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	return nil
end)()

-- Load VFXDispatcher
local VFXDispatcher = (function()
	local paths = { "../src/Track2_TowerSystem/VFXDispatcher", "src/Track2_TowerSystem/VFXDispatcher", "../../src/Track2_TowerSystem/VFXDispatcher", "../../../src/Track2_TowerSystem/VFXDispatcher" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	error("Cannot load VFXDispatcher")
end)()

-- Load TelemetryCollector
TelemetryCollector = (function()
	local paths = { "../src/DevTools/AnimationLab/TelemetryCollector", "src/DevTools/AnimationLab/TelemetryCollector", "../../src/DevTools/AnimationLab/TelemetryCollector", "../../../src/DevTools/AnimationLab/TelemetryCollector" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	error("Cannot load TelemetryCollector")
end)()

SandboxStageManager = (function()
	env.script = stageMgrScript
	local paths = { "../src/DevTools/AnimationLab/SandboxStageManager", "src/DevTools/AnimationLab/SandboxStageManager", "../../src/DevTools/AnimationLab/SandboxStageManager", "../../../src/DevTools/AnimationLab/SandboxStageManager" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	error("Cannot load SandboxStageManager")
end)()

StressTestRunner = (function()
	env.script = stressRunnerScript
	local paths = { "../src/DevTools/AnimationLab/StressTestRunner", "src/DevTools/AnimationLab/StressTestRunner", "../../src/DevTools/AnimationLab/StressTestRunner", "../../../src/DevTools/AnimationLab/StressTestRunner" }
	for _, p in ipairs(paths) do local ok, m = pcall(realRequire, p) if ok then return m end end
	error("Cannot load StressTestRunner")
end)()

env.script = animCtrlScript

-- Test framework
local totalTests = 0
local passedTests = 0
local failedTests = 0
local failures: { string } = {}

local function describe(suiteName: string, fn: () -> ())
	print(string.format("\n=== [STRESS SUITE] %s ===", suiteName))
	fn()
end

local function it(testName: string, fn: () -> ())
	totalTests += 1
	local ok, err = pcall(fn)
	if ok then
		passedTests += 1
		print(string.format("  [PASS] %s", testName))
	else
		failedTests += 1
		local failMsg = string.format("  [FAIL] %s: %s", testName, tostring(err))
		print(failMsg)
		table.insert(failures, failMsg)
	end
end

local function assertEqual(actual: any, expected: any, msg: string?)
	if actual ~= expected then
		error(string.format("%s (Expected %s, got %s)", msg or "Assertion failed", tostring(expected), tostring(actual)))
	end
end

local function assertTrue(cond: boolean, msg: string?)
	if not cond then
		error(msg or "Expected condition to be true")
	end
end

local function assertClose(actual: number, expected: number, tol: number?, msg: string?)
	local tolerance = tol or 0.001
	if math.abs(actual - expected) > tolerance then
		error(string.format("%s (Expected %.4f ~= %.4f within tolerance %.4f)", msg or "Values not close", actual, expected, tolerance))
	end
end

-- Helper: Create a representative articulated character model
local function createCharacterModel(name: string, partCount: number, isWeaponRig: boolean): Model
	local model = Instance.new("Model")
	model.Name = name

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Anchored = true
	root.Parent = model
	model.PrimaryPart = root

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Parent = model

	local limbs = { "Head", "RightArm", "LeftArm", "RightLeg", "LeftLeg" }
	for _, limbName in ipairs(limbs) do
		local p = Instance.new("Part")
		p.Name = limbName
		p.Parent = model
	end

	if isWeaponRig then
		local swords = { "WadoIchimonji", "Enma", "SandaiKitetsu" }
		for _, sw in ipairs(swords) do
			local p = Instance.new("Part")
			p.Name = sw
			p.Parent = model
		end
	end

	-- Pad remaining parts to reach representative partCount
	local currentParts = #model:GetChildren()
	for i = currentParts + 1, partCount do
		local extra = Instance.new("Part")
		extra.Name = "DecoPart_" .. i
		extra.Parent = model
	end

	return model
end

-- =============================================================================
-- SUITE 1: TIER 1 - SINGLE CHARACTER BENCHMARK (1 UNIT)
-- =============================================================================
describe("Tier 1: Single Character Stress Benchmark (1 Unit)", function()
	it("should initialize, animate, dispatch VFX, and teardown single character within budget", function()
		local budget = LabConfig.STRESS_BUDGETS.Single
		local startTime = os.clock()

		local luffy = createCharacterModel("Luffy", 122, false)
		luffy.Parent = mockWS

		local ctx, report = AnimationController.SanitizeAndRigModel(luffy, nil)
		assertTrue(ctx ~= nil, "Luffy must obtain RigContext")
		assertEqual(luffy:GetAttribute("Track2RigOwned"), true, "Must have Track2RigOwned attribute")

		-- Play full animation cycle
		AnimationController.PlayAttack(luffy, { Id = "Tower_Luffy_G5" })

		-- Dispatch VFX
		if LuffyVFX then
			AnimationRegistry.RegisterVFXModule("Luffy", LuffyVFX)
		end
		VFXDispatcher.TriggerCue({
			sourceModel = luffy,
			cueType = "SpawnDeploy",
		})
		VFXDispatcher.TriggerCue({
			sourceModel = luffy,
			cueType = "AttackWindup",
		})

		-- Measure telemetry
		local sample = TelemetryCollector.Sample(luffy, nil)
		local elapsedMs = (os.clock() - startTime) * 1000

		print(string.format("    -> [METRICS 1 UNIT] BaseParts: %d (Budget: %d), ActiveVFX: %d, FrameTime: %.2fms (Target: %.2fms)",
			sample.basePartCount, budget.maxActiveParts, sample.activeVFXInstances, elapsedMs, budget.targetFrameTimeMs))

		assertTrue(sample.basePartCount <= budget.maxActiveParts, "BaseParts must be <= budget")
		assertTrue(sample.activeVFXInstances <= budget.maxActiveVFXInstances, "VFX instances must be <= budget")

		-- Full Teardown & 0-Leak Check
		VFXDispatcher.cleanupAllForModel(luffy)
		AnimationController.DestroyContext(luffy)
		luffy:Destroy()

		local postReport = VFXDispatcher.GetLedgerReport(luffy)
		assertEqual(postReport.activeCount, 0, "Active ledger count must be 0 after teardown")
		assertEqual(postReport.trackedInstances, 0, "Tracked instances must be 0")
		assertEqual(postReport.trackedConnections, 0, "Tracked connections must be 0")
	end)
end)

-- =============================================================================
-- SUITE 2: TIER 2 - 10 CONCURRENT CHARACTERS BENCHMARK
-- =============================================================================
describe("Tier 2: 10 Concurrent Characters Stress Benchmark", function()
	it("should simulate 10 concurrent heterogeneous units with 0-leak balance", function()
		local budget = LabConfig.STRESS_BUDGETS.Chars10
		local models: { Model } = {}
		local startTime = os.clock()

		local archetypes = {
			{ name = "Luffy", parts = 122, weapon = false, vfx = LuffyVFX },
			{ name = "Zoro", parts = 139, weapon = true, vfx = ZoroVFX },
			{ name = "Ace", parts = 128, weapon = false, vfx = AceVFX },
			{ name = "Chopper", parts = 81, weapon = false, vfx = FallbackVFX },
		}

		for i = 1, 10 do
			local arch = archetypes[((i - 1) % #archetypes) + 1]
			local m = createCharacterModel(string.format("%s_%d", arch.name, i), arch.parts, arch.weapon)
			m.Parent = mockWS
			table.insert(models, m)

			AnimationController.SanitizeAndRigModel(m, nil)
			if arch.vfx then
				AnimationRegistry.RegisterVFXModule(m.Name, arch.vfx)
			end

			-- Trigger concurrent animation & VFX
			AnimationController.PlayAttack(m, { Id = "Tower_" .. arch.name })
			VFXDispatcher.TriggerCue({
				sourceModel = m,
				cueType = "AttackWindup",
			})
			VFXDispatcher.TriggerCue({
				sourceModel = m,
				cueType = "AttackImpact",
			})
		end

		local ledgerReport = VFXDispatcher.GetLedgerReport()
		local elapsedMs = (os.clock() - startTime) * 1000

		print(string.format("    -> [METRICS 10 UNITS] Active Ledger Instances: %d (Budget: %d), Step Time: %.2fms",
			ledgerReport.trackedInstances, budget.maxActiveVFXInstances, elapsedMs))

		assertTrue(ledgerReport.trackedInstances <= budget.maxActiveVFXInstances, "Active VFX must be within budget")

		-- Full Teardown
		for _, m in ipairs(models) do
			VFXDispatcher.cleanupAllForModel(m)
			AnimationController.DestroyContext(m)
			m:Destroy()
		end

		local finalReport = VFXDispatcher.GetLedgerReport()
		assertEqual(finalReport.activeCount, 0, "10-unit aggregate activeCount must be 0 after cleanup")
		assertEqual(finalReport.trackedInstances, 0, "10-unit aggregate trackedInstances must be 0")
	end)
end)

-- =============================================================================
-- SUITE 3: TIER 3 - 25 CONCURRENT CHARACTERS BENCHMARK
-- =============================================================================
describe("Tier 3: 25 Concurrent Characters Stress Benchmark", function()
	it("should simulate 25 concurrent units with multi-state animations and 0-leak balance", function()
		local budget = LabConfig.STRESS_BUDGETS.Chars25
		local models: { Model } = {}
		local startTime = os.clock()

		for i = 1, 25 do
			local heroName = if i % 3 == 1 then "Luffy" elseif i % 3 == 2 then "Zoro" else "Ace"
			local parts = if i % 3 == 1 then 122 elseif i % 3 == 2 then 139 else 128
			local isWeapon = (i % 3 == 2)
			local m = createCharacterModel(string.format("Hero25_%s_%d", heroName, i), parts, isWeapon)
			m.Parent = mockWS
			table.insert(models, m)

			AnimationController.SanitizeAndRigModel(m, nil)
			AnimationRegistry.RegisterVFXModule(m.Name, FallbackVFX)

			-- Concurrent action
			VFXDispatcher.TriggerCue({ sourceModel = m, cueType = "SpawnDeploy" })
		end

		local midReport = VFXDispatcher.GetLedgerReport()
		local elapsedMs = (os.clock() - startTime) * 1000

		print(string.format("    -> [METRICS 25 UNITS] Active Models: %d, Tracked Instances: %d (Budget: %d), Elapsed: %.2fms",
			#models, midReport.trackedInstances, budget.maxActiveVFXInstances, elapsedMs))

		assertTrue(midReport.trackedInstances <= budget.maxActiveVFXInstances, "25-unit VFX within budget")

		-- Teardown
		for _, m in ipairs(models) do
			VFXDispatcher.cleanupAllForModel(m)
			AnimationController.DestroyContext(m)
			m:Destroy()
		end

		local finalReport = VFXDispatcher.GetLedgerReport()
		assertEqual(finalReport.activeCount, 0, "25-unit final activeCount must be 0")
		assertEqual(finalReport.trackedInstances, 0, "25-unit final trackedInstances must be 0")
	end)
end)

-- =============================================================================
-- SUITE 4: TIER 4 - 50 CONCURRENT CHARACTERS BENCHMARK (MAX STRESS)
-- =============================================================================
describe("Tier 4: 50 Concurrent Characters Stress Benchmark (Max Stress Load)", function()
	it("should execute 50 concurrent units under heavy combat and verify zero-leak cleanup", function()
		local budget = LabConfig.STRESS_BUDGETS.Chars50
		local models: { Model } = {}
		local startTime = os.clock()

		-- Spawn 50 heterogeneous models
		for i = 1, 50 do
			local charType = ((i - 1) % 5) + 1
			local name = if charType == 1 then "Luffy"
				elseif charType == 2 then "Zoro"
				elseif charType == 3 then "Ace"
				elseif charType == 4 then "Whitebeard"
				else "YonkoBoss"
			local parts = if charType == 1 then 122
				elseif charType == 2 then 139
				elseif charType == 3 then 128
				elseif charType == 4 then 105
				else 124

			local m = createCharacterModel(string.format("Stress50_%s_%d", name, i), parts, (charType == 2))
			m.Parent = mockWS
			table.insert(models, m)

			AnimationController.SanitizeAndRigModel(m, nil)
			AnimationRegistry.RegisterVFXModule(m.Name, FallbackVFX)

			-- Dispatch concurrent visual load
			VFXDispatcher.TriggerCue({ sourceModel = m, cueType = "AttackWindup" })
			VFXDispatcher.TriggerCue({ sourceModel = m, cueType = "AttackImpact" })
		end

		assertEqual(#models, 50, "Must instantiate 50 distinct models")

		-- Sample Peak Telemetry
		local peakReport = VFXDispatcher.GetLedgerReport()
		local elapsedMs = (os.clock() - startTime) * 1000

		print(string.format("    -> [METRICS 50 UNITS] Active Units: 50, Peak VFX Tracked: %d (Budget: %d), Total Exec Time: %.2fms",
			peakReport.trackedInstances, budget.maxActiveVFXInstances, elapsedMs))

		assertTrue(peakReport.trackedInstances <= budget.maxActiveVFXInstances, "50-unit VFX instances must obey budget")

		-- Full 100% Teardown
		for _, m in ipairs(models) do
			VFXDispatcher.cleanupAllForModel(m)
			AnimationController.DestroyContext(m)
			m:Destroy()
		end

		local postReport = VFXDispatcher.GetLedgerReport()
		assertEqual(postReport.activeCount, 0, "50-unit activeCount must be 0 after teardown")
		assertEqual(postReport.trackedInstances, 0, "50-unit trackedInstances must be 0")
		assertEqual(postReport.trackedConnections, 0, "50-unit trackedConnections must be 0")
		assertEqual(postReport.createdCount - postReport.cleanedCount, 0, "Aggregate created vs cleaned delta must equal strictly 0")
	end)
end)

-- =============================================================================
-- SUITE 5: QUALITY PRESET THROTTLING UNDER CONCURRENCY
-- =============================================================================
describe("Quality Preset Throttling Under Concurrency", function()
	it("should throttle part budgets per unit under Low (<= 8), Medium (<= 16), and High (<= 30)", function()
		local lowCfg = VFXContract.ResolveQuality("Low")
		local medCfg = VFXContract.ResolveQuality("Medium")
		local highCfg = VFXContract.ResolveQuality("High")

		assertEqual(lowCfg.maxParts, 8, "Low maxParts must be <= 8")
		assertEqual(medCfg.maxParts, 16, "Medium maxParts must be <= 16")
		assertEqual(highCfg.maxParts, 30, "High maxParts must be <= 30")

		assertEqual(lowCfg.particleRate, 0.35, "Low particle rate must be 0.35")
		assertEqual(medCfg.particleRate, 0.70, "Medium particle rate must be 0.70")
		assertEqual(highCfg.particleRate, 1.00, "High particle rate must be 1.00")
	end)
end)

-- =============================================================================
-- SUITE 6: OFFICIAL STRESSTESTRUNNER AUTOMATED SCENARIOS
-- =============================================================================
describe("Suite 6: Official StressTestRunner Scenarios", function()
	it("should execute StressTestRunner across Single, Chars10, Chars25, and Chars50 scenarios", function()
		local templateLuffy = createCharacterModel("TemplateLuffy", 122, false)
		local templateZoro = createCharacterModel("TemplateZoro", 139, true)
		local templateAce = createCharacterModel("TemplateAce", 128, false)
		local templates = { templateLuffy, templateZoro, templateAce }

		local scenarios: { "Single" | "Chars10" | "Chars25" | "Chars50" } = { "Single", "Chars10", "Chars25", "Chars50" }
		for _, scen in ipairs(scenarios) do
			local res = StressTestRunner.RunTest("BenchSession_" .. scen, scen, templates)
			assertTrue(res.isLeakFree, "Scenario " .. scen .. " must be leak-free")
			assertTrue(res.passed, "Scenario " .. scen .. " must pass stress assertions: " .. tostring(res.notes))
			assertEqual(res.remainingSandboxInstances, 0, "Scenario " .. scen .. " remaining sandbox instances must be 0")
			print(string.format("    -> [STRESS RUNNER %s] PeakParts: %d, PeakVFX: %d, Remaining: %d, Passed: %s",
				scen, res.peakParts, res.peakVFXInstances, res.remainingSandboxInstances, tostring(res.passed)))
		end

		SandboxStageManager.CleanupAll()
	end)
end)

-- =============================================================================
-- SUITE 7: HIGH-FREQUENCY TIMELINE SCRUB RESTITUTION UNDER CONCURRENCY
-- =============================================================================
describe("Suite 7: High-Frequency Timeline Scrub Restitution Under Concurrency", function()
	it("should maintain zero cumulative drift (delta < 0.001) across 50 scrubs per unit on 10 concurrent models", function()
		local models: { Model } = {}
		for i = 1, 10 do
			local name = if i % 3 == 1 then "Luffy" elseif i % 3 == 2 then "Zoro" else "Ace"
			local m = createCharacterModel("ScrubModel_" .. i, 122, (i % 3 == 2))
			m.Parent = mockWS
			table.insert(models, m)
			AnimationController.SanitizeAndRigModel(m, nil)
		end

		for scrubRound = 1, 50 do
			local randomTime = (scrubRound * 0.173) % 2.0
			for _, m in ipairs(models) do
				AnimationController.EvaluateAtTime(m, "Attack", randomTime)
			end
		end

		-- Reset all models to rest pose
		for _, m in ipairs(models) do
			local okReset = AnimationController.ResetRestPose(m)
			assertTrue(okReset, "ResetRestPose must succeed and restore delta < 0.001 studs")
			AnimationController.DestroyContext(m)
			m:Destroy()
		end

		print("    -> [SCRUB RESTITUTION] 500 scrub evaluations across 10 models: All models restored rest pose with delta < 0.001")
	end)
end)

-- =============================================================================
-- SUITE 8: MEMORY LEAK ENDURANCE & AGGREGATE LEDGER ZERO-BALANCE
-- =============================================================================
describe("Suite 8: Memory Leak Endurance & Aggregate Ledger Zero-Balance", function()
	it("should execute 3 consecutive combat cycles on 50 models and guarantee 100% destruction", function()
		local models: { Model } = {}
		for i = 1, 50 do
			local m = createCharacterModel("EnduranceModel_" .. i, 120, false)
			m.Parent = mockWS
			table.insert(models, m)
			AnimationController.SanitizeAndRigModel(m, nil)
			AnimationRegistry.RegisterVFXModule(m.Name, FallbackVFX)
		end

		-- 3 consecutive combat attack cycles
		for cycle = 1, 3 do
			for _, m in ipairs(models) do
				VFXDispatcher.TriggerCue({ sourceModel = m, cueType = "AttackWindup" })
				VFXDispatcher.TriggerCue({ sourceModel = m, cueType = "AttackImpact" })
			end
		end

		local midReport = VFXDispatcher.GetLedgerReport()
		assertTrue(midReport.createdCount >= 300, "Must have created at least 300 visual instances across 3 cycles")

		-- Teardown
		for _, m in ipairs(models) do
			VFXDispatcher.cleanupAllForModel(m)
			AnimationController.DestroyContext(m)
			m:Destroy()
		end

		local finalReport = VFXDispatcher.GetLedgerReport()
		assertEqual(finalReport.activeCount, 0, "Endurance final activeCount must be 0")
		assertEqual(finalReport.trackedInstances, 0, "Endurance final trackedInstances must be 0")
		assertEqual(finalReport.trackedConnections, 0, "Endurance final trackedConnections must be 0")
		assertEqual(finalReport.createdCount - finalReport.cleanedCount, 0, "Endurance created vs cleaned balance must equal 0")
		print(string.format("    -> [ENDURANCE ZERO-LEAK] Total Created: %d, Total Cleaned: %d, Active Remaining: %d (Zero Leak)",
			finalReport.createdCount, finalReport.cleanedCount, finalReport.activeCount))
	end)
end)

-- =============================================================================
-- FINAL SUMMARY
-- =============================================================================
print("\n=======================================================")
print(string.format("STRESS BENCHMARK TEST RUN COMPLETE: %d / %d PASSED (Failed: %d)", passedTests, totalTests, failedTests))
print("=======================================================\n")

if failedTests > 0 then
	error(string.format("Stress Benchmark Failed: %d tests failed", failedTests))
end
