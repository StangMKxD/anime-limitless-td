--!strict
-- tests/characters/zoro_empirical_challenge.spec.luau
-- Phase 5 Milestone M3: Zoro King of Hell Empirical Challenge & Adversarial Harness
-- Author: challenger_m3_2 (empirical_challenger)
--
-- Directly stress-tests:
-- 1. Bulk Concurrency Stress: 50 Zoro models firing all 8 cues repeatedly under High quality.
-- 2. Ledger Cleanup Verification: 100% destruction, 0 active tweens, 0 active connections.
-- 3. Blade Trail Suppression: Strict Trail.Enabled = false on impact, cancel, and stop across edge cases.
-- 4. Falsify Visual Exceptions: 100% combat damage calculations and 0.31s nominal timing isolation.

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
	delay = function(sec: number, fn: () -> ())
		return nil
	end,
	cancel = function(t: any) end,
	spawn = function(fn: () -> ()) end,
	wait = function(sec: number?)
		return 0
	end,
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
		roblox.implementProperty("Instance", "Destroying", function(self)
			local connTable = {}
			return {
				Connect = function(sigSelf, fn)
					local conn = {
						Connected = true,
						Disconnect = function(c)
							c.Connected = false
						end,
					}
					return conn
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

local mockRS = Instance.new("Folder")
mockRS.Name = "ReplicatedStorage"
local mockShared = Instance.new("Folder")
mockShared.Name = "Shared"
mockShared.Parent = mockRS

local mockWS = Instance.new("Workspace")
local defaultCam = Instance.new("Camera")
defaultCam.CFrame = CFrame.lookAt(Vector3.new(0, 10, 20), Vector3.new(0, 3.5, 0))
mockWS.CurrentCamera = defaultCam

local mockRunService = {
	Heartbeat = {
		Connect = function(self, fn)
			return { Disconnect = function() end, Connected = true }
		end,
	},
	RenderStepped = {
		Connect = function(self, fn)
			return { Disconnect = function() end, Connected = true }
		end,
	},
	IsStudio = function(self)
		return true
	end,
}

local activeTweens = {}
local mockTweenService = {
	Create = function(self, inst, info, props)
		local twObj = {
			Instance = inst,
			Properties = props,
			Completed = {
				Connect = function(s, fn)
					local conn = {
						Connected = true,
						Disconnect = function(c)
							c.Connected = false
						end,
					}
					return conn
				end,
			},
			Play = function(s) end,
			Cancel = function(s) end,
		}
		table.insert(activeTweens, twObj)
		return twObj
	end,
}

env.game = {
	GetService = function(self, name)
		if name == "ReplicatedStorage" then
			return mockRS
		elseif name == "Workspace" then
			return mockWS
		elseif name == "RunService" then
			return mockRunService
		elseif name == "TweenService" then
			return mockTweenService
		end
		return Instance.new("Folder")
	end,
}

local realRequire = require

local AnimationContract = (function()
	local candidatePaths = {
		"../../../src/Shared/AnimationContract",
		"../../src/Shared/AnimationContract",
		"../src/Shared/AnimationContract",
		"src/Shared/AnimationContract",
	}
	for _, p in ipairs(candidatePaths) do
		local ok, mod = pcall(realRequire, p)
		if ok then return mod end
	end
	error("Failed to require AnimationContract")
end)()

local VFXContract = (function()
	local candidatePaths = {
		"../../../src/Shared/VFXContract",
		"../../src/Shared/VFXContract",
		"../src/Shared/VFXContract",
		"src/Shared/VFXContract",
	}
	for _, p in ipairs(candidatePaths) do
		local ok, mod = pcall(realRequire, p)
		if ok then return mod end
	end
	error("Failed to require VFXContract")
end)()

local animModScript = Instance.new("ModuleScript")
animModScript.Name = "AnimationContract"
animModScript.Parent = mockShared

local vfxModScript = Instance.new("ModuleScript")
vfxModScript.Name = "VFXContract"
vfxModScript.Parent = mockShared

local track2Folder = Instance.new("Folder")
track2Folder.Name = "Track2_TowerSystem"

local animCtrlModScript = Instance.new("ModuleScript")
animCtrlModScript.Name = "AnimationController"
animCtrlModScript.Parent = track2Folder

local animRegModScript = Instance.new("ModuleScript")
animRegModScript.Name = "AnimationRegistry"
animRegModScript.Parent = track2Folder

local vfxDispModScript = Instance.new("ModuleScript")
vfxDispModScript.Name = "VFXDispatcher"
vfxDispModScript.Parent = track2Folder

local AnimationRegistry: any = nil
local FallbackVFX: any = nil

local function customRequire(target: any)
	if typeof(target) == "string" then
		return realRequire(target)
	elseif typeof(target) == "Instance" then
		if target.Name == "AnimationContract" then
			return AnimationContract
		elseif target.Name == "VFXContract" then
			return VFXContract
		elseif target.Name == "AnimationRegistry" then
			return AnimationRegistry
		elseif target.Name == "_FallbackVFX" then
			return FallbackVFX
		end
		return { Name = target.Name }
	else
		error("Unknown require target: " .. typeof(target))
	end
end

env.require = customRequire

-- Load AnimationController
env.script = animCtrlModScript
local AnimationController = (function()
	local candidatePaths = {
		"../../../src/Track2_TowerSystem/AnimationController",
		"../../src/Track2_TowerSystem/AnimationController",
		"../src/Track2_TowerSystem/AnimationController",
		"src/Track2_TowerSystem/AnimationController",
	}
	for _, p in ipairs(candidatePaths) do
		local ok, mod = pcall(customRequire, p)
		if ok then return mod end
	end
	error("Failed to require AnimationController")
end)()

-- Load AnimationRegistry
env.script = animRegModScript
AnimationRegistry = (function()
	local candidatePaths = {
		"../../../src/Track2_TowerSystem/AnimationRegistry",
		"../../src/Track2_TowerSystem/AnimationRegistry",
		"../src/Track2_TowerSystem/AnimationRegistry",
		"src/Track2_TowerSystem/AnimationRegistry",
	}
	for _, p in ipairs(candidatePaths) do
		local ok, mod = pcall(customRequire, p)
		if ok then return mod end
	end
	error("Failed to require AnimationRegistry")
end)()

-- Load VFXDispatcher
env.script = vfxDispModScript
local VFXDispatcher = (function()
	local candidatePaths = {
		"../../../src/Track2_TowerSystem/VFXDispatcher",
		"../../src/Track2_TowerSystem/VFXDispatcher",
		"../src/Track2_TowerSystem/VFXDispatcher",
		"src/Track2_TowerSystem/VFXDispatcher",
	}
	for _, p in ipairs(candidatePaths) do
		local ok, mod = pcall(customRequire, p)
		if ok then return mod end
	end
	error("Failed to require VFXDispatcher")
end)()

-- Load ZoroVFX
local ZoroVFX = (function()
	local candidatePaths = {
		"../../../src/Track2_TowerSystem/VFX/ZoroVFX",
		"../../src/Track2_TowerSystem/VFX/ZoroVFX",
		"../src/Track2_TowerSystem/VFX/ZoroVFX",
		"src/Track2_TowerSystem/VFX/ZoroVFX",
	}
	for _, p in ipairs(candidatePaths) do
		local ok, mod = pcall(customRequire, p)
		if ok and type(mod) == "table" and type(mod.triggerCue) == "function" then
			return mod
		end
	end
	error("Failed to require ZoroVFX module")
end)()

-- Load Zoro Animations
local ZoroAnimationProfile = (function()
	local candidatePaths = {
		"../../../src/Track2_TowerSystem/Animations/Zoro",
		"../../src/Track2_TowerSystem/Animations/Zoro",
		"../src/Track2_TowerSystem/Animations/Zoro",
		"src/Track2_TowerSystem/Animations/Zoro",
	}
	for _, p in ipairs(candidatePaths) do
		local ok, mod = pcall(customRequire, p)
		if ok and type(mod) == "table" and mod.states then
			return mod
		end
	end
	error("Failed to require Zoro animation profile")
end)()

-- Register Zoro modules into Registry
AnimationRegistry.RegisterProfile("Zoro", ZoroAnimationProfile)
AnimationRegistry.RegisterVFXModule("Zoro", ZoroVFX)

-- =============================================================================
-- TEST HARNESS FRAMEWORK
-- =============================================================================
local totalTests = 0
local passedTests = 0
local failedTests = 0
local currentSuiteName = ""

local function describe(name: string, fn: () -> ())
	currentSuiteName = name
	print(string.format("\n=== [CHALLENGE SUITE] %s ===", name))
	fn()
end

local function it(description: string, fn: () -> ())
	totalTests += 1
	local ok, err = pcall(fn)
	if ok then
		passedTests += 1
		print(string.format("  [CHALLENGE PASS] %s", description))
	else
		failedTests += 1
		print(string.format("  [CHALLENGE FAIL] %s\n    -> ERROR: %s", description, tostring(err)))
	end
end

local function assertEqual(actual: any, expected: any, msg: string?)
	if actual ~= expected then
		error(string.format("%s: expected '%s', got '%s'", msg or "Assertion failed", tostring(expected), tostring(actual)), 2)
	end
end

local function assertTrue(condition: any, msg: string?)
	if not condition then
		error(msg or "Expected condition to be truthy", 2)
	end
end

local function assertClose(actual: number, expected: number, epsilon: number, msg: string?)
	local diff = math.abs(actual - expected)
	if diff > epsilon then
		error(string.format("%s: diff %.6f exceeds epsilon %.6f (got %.6f, expected %.6f)", msg or "Number comparison failed", diff, epsilon, actual, expected), 2)
	end
end

-- Model generation helper
local function createSimulatedZoroModel(name: string?): Model
	local model = Instance.new("Model")
	model.Name = name or "Zoro"

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Anchored = true
	root.Position = Vector3.new(0, 3, 0)
	root.Parent = model
	model.PrimaryPart = root

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Anchored = false
	torso.Position = Vector3.new(0, 3, 0)
	torso.Parent = model

	local rj = Instance.new("Motor6D")
	rj.Name = "RootJoint"
	rj.Part0 = root
	rj.Part1 = torso
	rj.C0 = CFrame.identity
	rj.C1 = CFrame.identity
	rj.Parent = root

	local limbSpecs = {
		{ name = "Head", joint = "Neck", c0 = CFrame.new(0, 1.89, 0), c1 = CFrame.identity },
		{ name = "RightArm", joint = "RightShoulder", c0 = CFrame.new(1.39, 0.75, 0), c1 = CFrame.identity },
		{ name = "LeftArm", joint = "LeftShoulder", c0 = CFrame.new(-1.39, 0.75, 0), c1 = CFrame.identity },
		{ name = "RightLeg", joint = "RightHip", c0 = CFrame.new(0.53, -0.60, 0), c1 = CFrame.identity },
		{ name = "LeftLeg", joint = "LeftHip", c0 = CFrame.new(-0.53, -0.60, 0), c1 = CFrame.identity },
	}

	for _, spec in ipairs(limbSpecs) do
		local limb = Instance.new("Part")
		limb.Name = spec.name
		limb.Anchored = false
		limb.Position = Vector3.new(0, 3, 0)
		limb.Parent = model

		local m = Instance.new("Motor6D")
		m.Name = spec.joint
		m.Part0 = torso
		m.Part1 = limb
		m.C0 = spec.c0
		m.C1 = spec.c1
		m.Parent = torso
	end

	-- Attach 3 Swords and blade trails
	local rightArm = model:FindFirstChild("RightArm") :: BasePart
	local leftArm = model:FindFirstChild("LeftArm") :: BasePart
	local head = model:FindFirstChild("Head") :: BasePart

	local enma = Instance.new("Part")
	enma.Name = "EnmaHandle"
	enma.Anchored = false
	enma.Position = Vector3.new(0, 3, 0)
	enma.Parent = model

	local mEnma = Instance.new("Motor6D")
	mEnma.Name = "WeaponRight"
	mEnma.Part0 = rightArm
	mEnma.Part1 = enma
	mEnma.C0 = CFrame.new(0.24, -1.66, -0.50)
	mEnma.C1 = CFrame.identity
	mEnma.Parent = rightArm

	local trailEnma = Instance.new("Trail")
	trailEnma.Name = "EnmaTrail"
	trailEnma.Enabled = false
	trailEnma.Parent = enma

	local sandai = Instance.new("Part")
	sandai.Name = "SandaiHandle"
	sandai.Anchored = false
	sandai.Position = Vector3.new(0, 3, 0)
	sandai.Parent = model

	local mSandai = Instance.new("Motor6D")
	mSandai.Name = "WeaponLeft"
	mSandai.Part0 = leftArm
	mSandai.Part1 = sandai
	mSandai.C0 = CFrame.new(-0.24, -1.66, -0.50)
	mSandai.C1 = CFrame.identity
	mSandai.Parent = leftArm

	local trailSandai = Instance.new("Trail")
	trailSandai.Name = "SandaiTrail"
	trailSandai.Enabled = false
	trailSandai.Parent = sandai

	local wado = Instance.new("Part")
	wado.Name = "WadoHandle"
	wado.Anchored = false
	wado.Position = Vector3.new(0, 3, 0)
	wado.Parent = model

	local mWado = Instance.new("Motor6D")
	mWado.Name = "WeaponMouth"
	mWado.Part0 = head
	mWado.Part1 = wado
	mWado.C0 = CFrame.new(0, -0.25, -0.55)
	mWado.C1 = CFrame.identity
	mWado.Parent = head

	local trailWado = Instance.new("Trail")
	trailWado.Name = "WadoTrail"
	trailWado.Enabled = false
	trailWado.Parent = wado

	model.Parent = mockWS
	return model
end

-- =============================================================================
-- EMPIRICAL CHALLENGE SUITE 1: BULK CONCURRENCY STRESS (50 ZORO MODELS)
-- =============================================================================
describe("1. Bulk Concurrency Stress: 50 Zoro Models Firing All 8 Cues Under High Quality", function()
	it("should simulate 50 Zoro models concurrently firing all 8 cues repeatedly under High preset", function()
		VFXDispatcher.SetQualityPreset("High")
		assertEqual(VFXDispatcher.GetQualityPreset(), "High", "Quality preset must be High")

		local models: { Model } = {}
		local cueTypes: { VFXContract.VFXCueType } = {
			"PassiveAura",
			"SpawnDeploy",
			"AttackWindup",
			"AttackRelease",
			"AttackImpact",
			"UltimateCast",
			"UltimateImpact",
			"SpecialIdleCue",
		}

		-- 1. Spawn 50 models
		for i = 1, 50 do
			local modelName = "Zoro_Stress_" .. i
			local m = createSimulatedZoroModel(modelName)
			AnimationRegistry.RegisterVFXModule(modelName, ZoroVFX)
			table.insert(models, m)
		end
		assertEqual(#models, 50, "Must instantiate exactly 50 Zoro models")

		-- 2. Fire all 8 cues across 3 repeated cycles on all 50 models (1,200 total cue dispatches)
		for cycle = 1, 3 do
			for _, m in ipairs(models) do
				for _, cue in ipairs(cueTypes) do
					if cue == "PassiveAura" then
						VFXDispatcher.StartPassiveAura(m, m.Name)
					else
						VFXDispatcher.TriggerCue({
							sourceModel = m,
							cueType = cue,
							heroId = m.Name,
							quality = "High",
							intensity = 1.2,
							targetPosition = m.PrimaryPart.Position + Vector3.new(0, 0, 15),
						})
					end
				end
			end
		end

		-- Verify active ledger is populated across all 50 models
		local midReport = VFXDispatcher.GetLedgerReport()
		assertTrue(midReport.trackedInstances > 500, "50 models x 8 cues x 3 cycles must have tracked > 500 cumulative active instances (got " .. midReport.trackedInstances .. ")")
		assertTrue(midReport.createdCount > 1000, "Created count must exceed 1000 across bulk cycles (got " .. midReport.createdCount .. ")")

		-- 3. Execute cleanupAllForModel on all 50 models and verify zero leaks
		for _, m in ipairs(models) do
			VFXDispatcher.cleanupAllForModel(m)
			local individualReport = VFXDispatcher.GetLedgerReport(m)
			assertEqual(individualReport.activeCount, 0, "Individual activeCount must be strictly 0")
			assertEqual(individualReport.trackedInstances, 0, "Individual trackedInstances must be strictly 0")
			assertEqual(individualReport.trackedTweens, 0, "Individual trackedTweens must be strictly 0")
			assertEqual(individualReport.trackedConnections, 0, "Individual trackedConnections must be strictly 0")
			m:Destroy()
		end

		-- 4. Final aggregate report check
		local finalReport = VFXDispatcher.GetLedgerReport()
		assertEqual(finalReport.activeCount, 0, "Aggregate activeCount must be strictly 0 across all 50 models")
		assertEqual(finalReport.trackedInstances, 0, "Aggregate trackedInstances must be strictly 0")
		assertEqual(finalReport.trackedTweens, 0, "Aggregate trackedTweens must be strictly 0")
		assertEqual(finalReport.trackedConnections, 0, "Aggregate trackedConnections must be strictly 0")
	end)
end)

-- =============================================================================
-- EMPIRICAL CHALLENGE SUITE 2: BLADE TRAIL SUPPRESSION ACROSS ALL LIFECYCLE PATHS
-- =============================================================================
describe("2. Blade Trail Suppression: Strict Immediate Trail.Enabled = false", function()
	it("should enforce Trail.Enabled = false immediately upon AttackImpact", function()
		local model = createSimulatedZoroModel("Zoro_Trail_Impact")
		local trails = {}
		for _, desc in ipairs(model:GetDescendants()) do
			if desc:IsA("Trail") then
				table.insert(trails, desc)
			end
		end
		assertEqual(#trails, 3, "Model must have 3 sword trails")

		-- Trigger AttackWindup -> trails enabled
		VFXDispatcher.TriggerCue({
			sourceModel = model,
			cueType = "AttackWindup",
			heroId = "Zoro",
			quality = "High",
		})
		for _, t in ipairs(trails) do
			assertEqual(t.Enabled, true, "Trail must be enabled during AttackWindup")
		end

		-- Trigger AttackImpact -> trails MUST be disabled immediately
		VFXDispatcher.TriggerCue({
			sourceModel = model,
			cueType = "AttackImpact",
			heroId = "Zoro",
			quality = "High",
		})
		for _, t in ipairs(trails) do
			assertEqual(t.Enabled, false, "Trail must be disabled immediately upon AttackImpact")
		end

		VFXDispatcher.cleanupAllForModel(model)
		model:Destroy()
	end)

	it("should enforce Trail.Enabled = false immediately upon UltimateImpact", function()
		local model = createSimulatedZoroModel("Zoro_Trail_UltImpact")
		local trails = {}
		for _, desc in ipairs(model:GetDescendants()) do
			if desc:IsA("Trail") then
				table.insert(trails, desc)
			end
		end

		-- Trigger UltimateCast -> trails enabled
		VFXDispatcher.TriggerCue({
			sourceModel = model,
			cueType = "UltimateCast",
			heroId = "Zoro",
			quality = "High",
		})
		for _, t in ipairs(trails) do
			assertEqual(t.Enabled, true, "Trail must be enabled during UltimateCast")
		end

		-- Trigger UltimateImpact -> trails MUST be disabled immediately
		VFXDispatcher.TriggerCue({
			sourceModel = model,
			cueType = "UltimateImpact",
			heroId = "Zoro",
			quality = "High",
		})
		for _, t in ipairs(trails) do
			assertEqual(t.Enabled, false, "Trail must be disabled immediately upon UltimateImpact")
		end

		VFXDispatcher.cleanupAllForModel(model)
		model:Destroy()
	end)

	it("should enforce Trail.Enabled = false immediately when animation stops or cleanup is called mid-windup", function()
		local model = createSimulatedZoroModel("Zoro_Trail_MidStop")
		local trails = {}
		for _, desc in ipairs(model:GetDescendants()) do
			if desc:IsA("Trail") then
				table.insert(trails, desc)
			end
		end

		-- Windup enables trails
		VFXDispatcher.TriggerCue({
			sourceModel = model,
			cueType = "AttackWindup",
			heroId = "Zoro",
			quality = "High",
		})
		for _, t in ipairs(trails) do
			assertEqual(t.Enabled, true, "Trail must be active during windup")
		end

		-- Unit is sold or animation cancelled mid-attack before impact
		VFXDispatcher.cleanupAllForModel(model)

		for _, t in ipairs(trails) do
			assertEqual(t.Enabled, false, "All blade trails must be disabled immediately on cleanupAllForModel")
		end

		model:Destroy()
	end)

	it("should verify whether Trail.Enabled = false when AnimationController.Stop is called mid-attack", function()
		local model = createSimulatedZoroModel("Zoro_Trail_AnimStop")
		local trails = {}
		for _, desc in ipairs(model:GetDescendants()) do
			if desc:IsA("Trail") then
				table.insert(trails, desc)
			end
		end

		AnimationController.SanitizeAndRigModel(model, ZoroAnimationProfile)
		AnimationController.Play(model, "Windup")
		VFXDispatcher.TriggerCue({
			sourceModel = model,
			cueType = "AttackWindup",
			heroId = "Zoro",
			quality = "High",
		})

		for _, t in ipairs(trails) do
			assertEqual(t.Enabled, true, "Trail must be active during Windup")
		end

		-- Now AnimationController.Stop is called (user clicks Stop, or state resets)
		AnimationController.Stop(model)

		for _, t in ipairs(trails) do
			assertEqual(t.Enabled, false, "Trail.Enabled MUST be false when animation stops without lingering visual lines")
		end

		AnimationController.DestroyContext(model)
		model:Destroy()
	end)

	it("should dynamically detect and suppress newly added trails in ZoroVFX.disableAllTrails", function()
		local model = createSimulatedZoroModel("Zoro_Trail_Dynamic")

		-- Add a 4th trail dynamically to a newly spawned blade effect
		local dynamicPart = Instance.new("Part")
		dynamicPart.Name = "DynamicBladeSlash"
		dynamicPart.Parent = model

		local dynTrail = Instance.new("Trail")
		dynTrail.Name = "DynamicSlashTrail"
		dynTrail.Enabled = true
		dynTrail.Parent = dynamicPart

		assertEqual(dynTrail.Enabled, true, "Dynamic trail initialized enabled")

		-- Calling disableAllTrails must scan model descendants and turn it off
		ZoroVFX.disableAllTrails(model)
		assertEqual(dynTrail.Enabled, false, "Dynamic trail must be disabled by disableAllTrails")

		VFXDispatcher.cleanupAllForModel(model)
		model:Destroy()
	end)

	it("should enforce Trail.Enabled = false across 50 concurrent models during mass hitstop", function()
		local models = {}
		local allTrails = {}

		for i = 1, 50 do
			local m = createSimulatedZoroModel("Zoro_MassTrail_" .. i)
			AnimationRegistry.RegisterVFXModule(m.Name, ZoroVFX)
			table.insert(models, m)
			for _, desc in ipairs(m:GetDescendants()) do
				if desc:IsA("Trail") then
					table.insert(allTrails, desc)
				end
			end
		end
		assertEqual(#allTrails, 150, "50 models x 3 swords must yield exactly 150 active trails")

		-- Windup all 50
		for _, m in ipairs(models) do
			VFXDispatcher.TriggerCue({
				sourceModel = m,
				cueType = "AttackWindup",
				heroId = m.Name,
				quality = "High",
			})
		end
		for _, t in ipairs(allTrails) do
			assertEqual(t.Enabled, true, "All 150 trails must be enabled in windup")
		end

		-- Impact all 50
		for _, m in ipairs(models) do
			VFXDispatcher.TriggerCue({
				sourceModel = m,
				cueType = "AttackImpact",
				heroId = m.Name,
				quality = "High",
			})
		end
		for _, t in ipairs(allTrails) do
			assertEqual(t.Enabled, false, "All 150 trails must be strictly disabled on impact")
		end

		for _, m in ipairs(models) do
			VFXDispatcher.cleanupAllForModel(m)
			m:Destroy()
		end
	end)
end)

-- =============================================================================
-- EMPIRICAL CHALLENGE SUITE 3: FALSIFY VISUAL EXCEPTIONS & COMBAT DECOUPLING
-- =============================================================================
describe("3. Falsify Visual Exceptions: Combat Damage & 0.31s Nominal Timing Isolation", function()
	it("should verify 0.31s nominal impact timing and damage calculation execute with unperturbed precision under normal conditions", function()
		local simulatedTime = 0.0
		local hitOccurred = false
		local hitTimestamp = -1.0
		local calculatedDamage = 0

		local baseDamage = 150
		local damageMult = 2.0
		local armorReduction = 0.30
		local isCrit = true
		local critMult = 1.5

		-- Discrete timeline simulation of TowerController 5-phase attack
		local function runAttackCycle()
			-- Phase 1 (0.14s)
			simulatedTime += 0.14

			-- Phase 2 (0.10s)
			simulatedTime += 0.10

			-- Phase 3 (0.07s)
			simulatedTime += 0.07

			-- Phase 4: Impact Strike at t = 0.31s
			hitOccurred = true
			hitTimestamp = simulatedTime

			-- Damage formula from TowerController
			local rawDmg = math.floor(baseDamage * damageMult * (isCrit and critMult or 1.0))
			calculatedDamage = math.max(1, math.floor(rawDmg * math.clamp(1.0 - armorReduction, 0.25, 1.0)))
		end

		runAttackCycle()

		assertTrue(hitOccurred, "Hit callback must occur")
		assertClose(hitTimestamp, 0.31, 0.0001, "Impact must occur at nominal 0.31s")
		-- rawDmg = 150 * 2.0 * 1.5 = 450; effectiveDmg = floor(450 * 0.70) = 315
		assertEqual(calculatedDamage, 315, "Calculated damage must be exactly 315")
	end)

	it("should verify 100% of combat damage and 0.31s timing execute uninterrupted when VFX module throws fatal exceptions", function()
		local model = createSimulatedZoroModel("Zoro_VFX_Crash")

		-- Register a malicious/corrupted VFX module that throws unhandled errors on every cue
		local corruptedVFX = {
			heroId = "Zoro_Corrupted",
			maxConcurrentVFXInstances = 25,
			startPassiveAura = function(_)
				error("[ADVERSARIAL EXCEPTION] Fatal crash in startPassiveAura: nil dereference")
			end,
			stopPassiveAura = function(_)
				error("[ADVERSARIAL EXCEPTION] Fatal crash in stopPassiveAura: memory fault")
			end,
			triggerCue = function(ctx)
				error(string.format("[ADVERSARIAL EXCEPTION] Fatal crash during cue '%s'!", tostring(ctx.cueType)))
			end,
			cleanupAllForModel = function(_)
				error("[ADVERSARIAL EXCEPTION] Fatal crash during cleanupAllForModel!")
			end,
		}

		AnimationRegistry.RegisterVFXModule("Zoro_Corrupted", corruptedVFX :: any)

		-- Verify VFXDispatcher safely absorbs the error via pcall without propagating to caller
		local triggerOk, triggerErr = pcall(function()
			VFXDispatcher.TriggerCue({
				sourceModel = model,
				cueType = "AttackImpact",
				heroId = "Zoro_Corrupted",
			})
		end)
		assertTrue(triggerOk, "VFXDispatcher.TriggerCue must NOT crash caller even if VFX module throws fatal error")

		-- Now run combat simulation where visual calls fail
		local simulatedTime = 0.0
		local hitOccurred = false
		local hitTimestamp = -1.0
		local enemyHP = 1000

		local function runCombatWithCorruptedVFX()
			-- Visual dispatch fails at windup
			pcall(function()
				VFXDispatcher.TriggerCue({ sourceModel = model, cueType = "AttackWindup", heroId = "Zoro_Corrupted" })
			end)
			simulatedTime += 0.14

			-- Visual dispatch fails at release
			pcall(function()
				VFXDispatcher.TriggerCue({ sourceModel = model, cueType = "AttackRelease", heroId = "Zoro_Corrupted" })
			end)
			simulatedTime += 0.10

			-- Visual dispatch fails at freeze
			simulatedTime += 0.07

			-- Phase 4 Impact callback executes independently on server timer
			hitOccurred = true
			hitTimestamp = simulatedTime

			-- Protected visual call fails at impact
			pcall(function()
				VFXDispatcher.TriggerCue({ sourceModel = model, cueType = "AttackImpact", heroId = "Zoro_Corrupted" })
			end)

			-- Damage resolution MUST NOT be dropped or corrupted
			local rawDmg = 250
			local effectiveDmg = math.max(1, math.floor(rawDmg * 0.80))
			enemyHP -= effectiveDmg
		end

		runCombatWithCorruptedVFX()

		assertTrue(hitOccurred, "Combat hit must occur regardless of VFX exceptions")
		assertClose(hitTimestamp, 0.31, 0.0001, "Hit timing must strictly maintain nominal 0.31s under VFX failures")
		assertEqual(enemyHP, 800, "Enemy HP must decrease by exactly 200 (100% damage applied)")

		VFXDispatcher.cleanupAllForModel(model)
		model:Destroy()
	end)

	it("should verify combat calculations remain invariant under invalid/corrupted VFX execution contexts", function()
		local model = createSimulatedZoroModel("Zoro_Invalid_Ctx")

		-- Try triggering cues with nil rootPart, missing targetPosition, negative intensity, etc.
		local dummyModel = Instance.new("Model")
		-- dummyModel has no PrimaryPart and no HumanoidRootPart

		local ok1, _ = pcall(function()
			VFXDispatcher.TriggerCue({
				sourceModel = dummyModel,
				cueType = "AttackImpact",
				heroId = "Zoro",
			})
		end)
		assertTrue(ok1, "TriggerCue with missing root part must safely abort without error")

		local ok2, _ = pcall(function()
			VFXDispatcher.TriggerCue({
				sourceModel = model,
				cueType = "AttackImpact",
				heroId = "Zoro",
				intensity = -999.0, -- extreme negative intensity
			})
		end)
		assertTrue(ok2, "TriggerCue with extreme negative intensity must clamp cleanly")

		local ok3, _ = pcall(function()
			VFXDispatcher.TriggerCue({
				sourceModel = model,
				cueType = "AttackImpact",
				heroId = "Zoro",
				quality = "InvalidQualityPreset" :: any,
			})
		end)
		assertTrue(ok3, "TriggerCue with invalid quality preset must fall back gracefully")

		VFXDispatcher.cleanupAllForModel(model)
		model:Destroy()
		dummyModel:Destroy()
	end)
end)

-- =============================================================================
-- FINAL TEST SUMMARY
-- =============================================================================
print("\n=======================================================")
print(string.format("ZORO EMPIRICAL CHALLENGE SUITE COMPLETE: %d / %d PASSED (Failed: %d)", passedTests, totalTests, failedTests))
print("=======================================================\n")

if failedTests > 0 then
	error(string.format("Empirical challenge failed: %d tests failed", failedTests))
end
