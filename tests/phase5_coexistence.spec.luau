--!strict
-- tests/phase5_coexistence.spec.luau
-- Phase 5 Milestone M5: Task P5-20 Mixed 3 Signatures + 16 Legacy Assets Coexistence Test Suite
-- Formally verifies the coexistence of all 19 assets (3 Signatures, 9 Legacy Heroes, 4 Enemies, 3 Static Map Assets)
-- Asserts zero cross-contamination of joints, attachments, or ledgers, truthful fallback routing, and 100% cleanup.

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
		return coroutine.create(fn)
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
			return {
				Connect = function(sigSelf, fn)
					return {
						Disconnect = function() end,
					}
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

-- Setup mock game services
local mockRS = Instance.new("Folder")
mockRS.Name = "ReplicatedStorage"
local mockShared = Instance.new("Folder")
mockShared.Name = "Shared"
mockShared.Parent = mockRS

local mockWS = Instance.new("Workspace")
local defaultCam = Instance.new("Camera")
mockWS.CurrentCamera = defaultCam

local mockRunService = {
	Heartbeat = { Connect = function() return { Disconnect = function() end } end },
	RenderStepped = { Connect = function() return { Disconnect = function() end } end },
	IsStudio = function() return true end,
}

local mockTweenService = {
	Create = function(self, inst, info, props)
		return {
			Play = function(s) end,
			Cancel = function(s) end,
			Completed = {
				Connect = function(s, fn)
					return { Disconnect = function() end }
				end,
			},
		}
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

-- Module candidate resolution helper
local function safeRequire(paths: { string }): any
	for _, p in ipairs(paths) do
		local ok, mod = pcall(realRequire, p)
		if ok then return mod end
	end
	error("Failed to require module from paths: " .. table.concat(paths, ", "))
end

-- 1. AnimationContract (Shared)
local AnimationContract = safeRequire({
	"src/Shared/AnimationContract",
	"../src/Shared/AnimationContract",
	"../../src/Shared/AnimationContract",
})

-- 2. VFXContract (Shared)
local VFXContract = safeRequire({
	"src/Shared/VFXContract",
	"../src/Shared/VFXContract",
	"../../src/Shared/VFXContract",
})

-- 3. LabConfig (DevTools/AnimationLab)
local LabConfig = safeRequire({
	"src/DevTools/AnimationLab/LabConfig",
	"../src/DevTools/AnimationLab/LabConfig",
	"../../src/DevTools/AnimationLab/LabConfig",
})

-- Setup ModuleScripts for mock tree
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

local animFolder = Instance.new("Folder")
animFolder.Name = "Animations"
animFolder.Parent = track2Folder

local vfxFolder = Instance.new("Folder")
vfxFolder.Name = "VFX"
vfxFolder.Parent = track2Folder

local devToolsFolder = Instance.new("Folder")
devToolsFolder.Name = "AnimationLab"

local validatorModScript = Instance.new("ModuleScript")
validatorModScript.Name = "ModelValidator"
validatorModScript.Parent = devToolsFolder

local labConfigModScript = Instance.new("ModuleScript")
labConfigModScript.Name = "LabConfig"
labConfigModScript.Parent = devToolsFolder

-- References to be populated
local AnimationRegistry: any = nil
local FallbackVFX: any = nil
local FallbackProfile: any = nil
local LuffyProfile: any = nil
local ZoroProfile: any = nil
local AceProfile: any = nil
local LuffyVFX: any = nil
local ZoroVFX: any = nil
local AceVFX: any = nil
local ModelValidator: any = nil

local function customRequire(target: any)
	if typeof(target) == "string" then
		return realRequire(target)
	elseif typeof(target) == "Instance" then
		if target.Name == "AnimationContract" then
			return AnimationContract
		elseif target.Name == "VFXContract" then
			return VFXContract
		elseif target.Name == "LabConfig" then
			return LabConfig
		elseif target.Name == "AnimationRegistry" then
			return AnimationRegistry
		elseif target.Name == "_FallbackVFX" then
			return FallbackVFX
		elseif target.Name == "_FallbackProfile" then
			return FallbackProfile
		elseif target.Name == "Luffy" then
			return LuffyProfile
		elseif target.Name == "Zoro" then
			return ZoroProfile
		elseif target.Name == "Ace" then
			return AceProfile
		elseif target.Name == "LuffyVFX" then
			return LuffyVFX
		elseif target.Name == "ZoroVFX" then
			return ZoroVFX
		elseif target.Name == "AceVFX" then
			return AceVFX
		elseif target.Name == "ModelValidator" then
			return ModelValidator
		end
		return { Name = target.Name }
	else
		error("Unknown require target: " .. typeof(target))
	end
end

env.require = customRequire

-- Preload deliverables
FallbackProfile = safeRequire({ "src/Track2_TowerSystem/Animations/_FallbackProfile", "../src/Track2_TowerSystem/Animations/_FallbackProfile" })
FallbackVFX = safeRequire({ "src/Track2_TowerSystem/VFX/_FallbackVFX", "../src/Track2_TowerSystem/VFX/_FallbackVFX" })
LuffyProfile = safeRequire({ "src/Track2_TowerSystem/Animations/Luffy", "../src/Track2_TowerSystem/Animations/Luffy" })
LuffyVFX = safeRequire({ "src/Track2_TowerSystem/VFX/LuffyVFX", "../src/Track2_TowerSystem/VFX/LuffyVFX" })
ZoroProfile = safeRequire({ "src/Track2_TowerSystem/Animations/Zoro", "../src/Track2_TowerSystem/Animations/Zoro" })
ZoroVFX = safeRequire({ "src/Track2_TowerSystem/VFX/ZoroVFX", "../src/Track2_TowerSystem/VFX/ZoroVFX" })
AceProfile = safeRequire({ "src/Track2_TowerSystem/Animations/Ace", "../src/Track2_TowerSystem/Animations/Ace" })
AceVFX = safeRequire({ "src/Track2_TowerSystem/VFX/AceVFX", "../src/Track2_TowerSystem/VFX/AceVFX" })

-- Populate ModuleScripts inside Animations/ and VFX/
for _, name in ipairs({ "Luffy", "Zoro", "Ace", "_FallbackProfile" }) do
	local ms = Instance.new("ModuleScript")
	ms.Name = name
	ms.Parent = animFolder
end

for _, name in ipairs({ "LuffyVFX", "ZoroVFX", "AceVFX", "_FallbackVFX" }) do
	local ms = Instance.new("ModuleScript")
	ms.Name = name
	ms.Parent = vfxFolder
end

-- Load AnimationRegistry
env.script = animRegModScript
AnimationRegistry = safeRequire({ "src/Track2_TowerSystem/AnimationRegistry", "../src/Track2_TowerSystem/AnimationRegistry" })

-- Load AnimationController
env.script = animCtrlModScript
local AnimationController = safeRequire({ "src/Track2_TowerSystem/AnimationController", "../src/Track2_TowerSystem/AnimationController" })

-- Load VFXDispatcher
env.script = vfxDispModScript
local VFXDispatcher = safeRequire({ "src/Track2_TowerSystem/VFXDispatcher", "../src/Track2_TowerSystem/VFXDispatcher" })

-- Load ModelValidator
env.script = validatorModScript
ModelValidator = safeRequire({ "src/DevTools/AnimationLab/ModelValidator", "../src/DevTools/AnimationLab/ModelValidator" })

-- Keep script pointing to AnimationRegistry for runtime fallback discovery
env.script = animRegModScript

-- Register signatures into AnimationRegistry for dynamic discovery
AnimationRegistry.RegisterProfile("Luffy", LuffyProfile)
AnimationRegistry.RegisterProfile("Zoro", ZoroProfile)
AnimationRegistry.RegisterProfile("Ace", AceProfile)
AnimationRegistry.RegisterVFXModule("Luffy", LuffyVFX)
AnimationRegistry.RegisterVFXModule("Zoro", ZoroVFX)
AnimationRegistry.RegisterVFXModule("Ace", AceVFX)

-- Helper to find asset file path
local function resolveAssetPath(relPath: string): string
	local candidates = {
		relPath,
		"../" .. relPath,
		"../../" .. relPath,
	}
	for _, p in ipairs(candidates) do
		if fs and fs.isFile(p) then
			return p
		end
	end
	error("Cannot find asset file: " .. relPath)
end

-- Canonical 19-Asset Catalog Definition
type AssetTestDef = {
	path: string,
	name: string,
	category: string,
	expectedBaseParts: number,
	isSignature: boolean,
	isStaticMap: boolean,
	expectedJoints: number,
}

local ALL_19_ASSETS: { AssetTestDef } = {
	-- 12 Heroes (3 Signatures + 9 Legacy)
	{ path = "assets/rojo/HeroModels/Luffy.rbxmx", name = "Luffy", category = "HeroModels", expectedBaseParts = 122, isSignature = true, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/HeroModels/Zoro.rbxmx", name = "Zoro", category = "HeroModels", expectedBaseParts = 139, isSignature = true, isStaticMap = false, expectedJoints = 9 },
	{ path = "assets/rojo/HeroModels/Ace.rbxmx", name = "Ace", category = "HeroModels", expectedBaseParts = 128, isSignature = true, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/HeroModels/Chopper.rbxmx", name = "Chopper", category = "HeroModels", expectedBaseParts = 76, isSignature = false, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/HeroModels/Kizaru.rbxmx", name = "Kizaru", category = "HeroModels", expectedBaseParts = 103, isSignature = false, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/HeroModels/Law.rbxmx", name = "Law", category = "HeroModels", expectedBaseParts = 98, isSignature = false, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/HeroModels/Nami.rbxmx", name = "Nami", category = "HeroModels", expectedBaseParts = 94, isSignature = false, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/HeroModels/Robin.rbxmx", name = "Robin", category = "HeroModels", expectedBaseParts = 101, isSignature = false, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/HeroModels/Sanji.rbxmx", name = "Sanji", category = "HeroModels", expectedBaseParts = 102, isSignature = false, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/HeroModels/Shanks.rbxmx", name = "Shanks", category = "HeroModels", expectedBaseParts = 94, isSignature = false, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/HeroModels/Usopp.rbxmx", name = "Usopp", category = "HeroModels", expectedBaseParts = 102, isSignature = false, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/HeroModels/Whitebeard.rbxmx", name = "Whitebeard", category = "HeroModels", expectedBaseParts = 104, isSignature = false, isStaticMap = false, expectedJoints = 6 },

	-- 4 Enemies
	{ path = "assets/rojo/EnemyModels/HakiBrute.rbxmx", name = "HakiBrute", category = "EnemyModels", expectedBaseParts = 76, isSignature = false, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/EnemyModels/PirateGrunt.rbxmx", name = "PirateGrunt", category = "EnemyModels", expectedBaseParts = 70, isSignature = false, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/EnemyModels/SoruAssassin.rbxmx", name = "SoruAssassin", category = "EnemyModels", expectedBaseParts = 62, isSignature = false, isStaticMap = false, expectedJoints = 6 },
	{ path = "assets/rojo/EnemyModels/YonkoBoss.rbxmx", name = "YonkoBoss", category = "EnemyModels", expectedBaseParts = 129, isSignature = false, isStaticMap = false, expectedJoints = 6 },

	-- 3 Map Assets
	{ path = "assets/rojo/MapModels/AnimeBaseCrystal.rbxmx", name = "AnimeBaseCrystal", category = "MapModels", expectedBaseParts = 40, isSignature = false, isStaticMap = true, expectedJoints = 0 },
	{ path = "assets/rojo/MapModels/EnemySpawnGate.rbxmx", name = "EnemySpawnGate", category = "MapModels", expectedBaseParts = 23, isSignature = false, isStaticMap = true, expectedJoints = 0 },
	{ path = "assets/rojo/MapModels/PlacementPadTemplate.rbxmx", name = "PlacementPadTemplate", category = "MapModels", expectedBaseParts = 13, isSignature = false, isStaticMap = true, expectedJoints = 0 },
}

-- =============================================================================
-- TEST HARNESS FRAMEWORK
-- =============================================================================
local totalTests = 0
local passedTests = 0
local failedTests = 0
local failures: { string } = {}

local function describe(suiteName: string, fn: () -> ())
	print(string.format("\n=== [SUITE] %s ===", suiteName))
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

-- =============================================================================
-- SUITE 1: 19-ASSET CATALOG INTEGRITY & DESERIALIZATION AUDIT (Task P5-20)
-- =============================================================================
describe("SUITE 1: 19-Asset Catalog Integrity & Deserialization Audit (Task P5-20)", function()
	it("should verify exactly 19 assets exist in Rojo assets across 3 categories", function()
		assertEqual(#ALL_19_ASSETS, 19, "Total assets must be exactly 19")
		local counts = { HeroModels = 0, EnemyModels = 0, MapModels = 0 }
		for _, asset in ipairs(ALL_19_ASSETS) do
			counts[asset.category] = (counts[asset.category] or 0) + 1
		end
		assertEqual(counts.HeroModels, 12, "HeroModels count must be 12")
		assertEqual(counts.EnemyModels, 4, "EnemyModels count must be 4")
		assertEqual(counts.MapModels, 3, "MapModels count must be 3")
	end)

	it("should deserialize all 19 .rbxmx models without errors and verify part counts and HumanoidRootPart", function()
		local totalParts = 0
		for _, asset in ipairs(ALL_19_ASSETS) do
			local absPath = resolveAssetPath(asset.path)
			local xml = fs.readFile(absPath)
			local deserialized = roblox.deserializeModel(xml)
			assertTrue(#deserialized >= 1, "Model must deserialize at least 1 root instance: " .. asset.name)

			local model = deserialized[1]
			assertEqual(model.Name, asset.name, "Deserialized model name must match asset definition")

			local partCount = 0
			for _, desc in ipairs(model:GetDescendants()) do
				if desc:IsA("BasePart") then
					partCount += 1
				end
			end
			totalParts += partCount
			assertEqual(partCount, asset.expectedBaseParts, string.format("Part count mismatch for '%s'", asset.name))

			local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
			assertTrue(root ~= nil, string.format("Model '%s' must contain HumanoidRootPart", asset.name))
		end

		assertEqual(totalParts, 1676, "Total BaseParts across all 19 models must strictly equal 1676")
	end)
end)

-- =============================================================================
-- SUITE 2: ANIMATION REGISTRY ALIAS RESOLUTION & FALLBACK MAPPING (Task P5-20)
-- =============================================================================
describe("SUITE 2: Animation Registry Alias Resolution & Fallback Mapping (Task P5-20)", function()
	local aliasMappings = {
		{ raw = "Tower_Luffy_G5", expectedNorm = "Luffy", isSig = true },
		{ raw = "Tower_Zoro_KingOfHell", expectedNorm = "Zoro", isSig = true },
		{ raw = "Tower_Ace_Entei", expectedNorm = "Ace", isSig = true },
		{ raw = "Luffy", expectedNorm = "Luffy", isSig = true },
		{ raw = "Zoro", expectedNorm = "Zoro", isSig = true },
		{ raw = "Ace", expectedNorm = "Ace", isSig = true },
		{ raw = "Tower_Chopper_Monster", expectedNorm = "Chopper", isSig = false },
		{ raw = "Tower_Kizaru_Pika", expectedNorm = "Kizaru", isSig = false },
		{ raw = "Tower_Law_KRoom", expectedNorm = "Law", isSig = false },
		{ raw = "Tower_Nami_Zeus", expectedNorm = "Nami", isSig = false },
		{ raw = "Tower_Robin_Demonio", expectedNorm = "Robin", isSig = false },
		{ raw = "Tower_Sanji_Ifrit", expectedNorm = "Sanji", isSig = false },
		{ raw = "Tower_Shanks_Kamusari", expectedNorm = "Shanks", isSig = false },
		{ raw = "Tower_Usopp_Kabuto", expectedNorm = "Usopp", isSig = false },
		{ raw = "Tower_Whitebeard_Gura", expectedNorm = "Whitebeard", isSig = false },
		{ raw = "PirateGrunt", expectedNorm = "PirateGrunt", isSig = false },
		{ raw = "HakiBrute", expectedNorm = "HakiBrute", isSig = false },
		{ raw = "SoruAssassin", expectedNorm = "SoruAssassin", isSig = false },
		{ raw = "YonkoBoss", expectedNorm = "YonkoBoss", isSig = false },
		{ raw = "AnimeBaseCrystal", expectedNorm = "AnimeBaseCrystal", isSig = false },
	}

	it("should normalize all raw hero IDs and aliases deterministically", function()
		for _, map in ipairs(aliasMappings) do
			local norm = AnimationRegistry.NormalizeHeroId(map.raw)
			assertEqual(norm, map.expectedNorm, "NormalizeHeroId mismatch for " .. map.raw)
		end
	end)

	it("should resolve signature profiles for Luffy, Zoro, Ace and fallback profiles for others without errors", function()
		for _, map in ipairs(aliasMappings) do
			local prof, isSig, reason = AnimationRegistry.GetAnimationProfile(map.raw)
			assertTrue(prof ~= nil, "Profile must not be nil for " .. map.raw)
			assertEqual(isSig, map.isSig, "Profile signature flag mismatch for " .. map.raw)
			if map.isSig then
				assertTrue(reason == "SignatureLoaded" or reason == "CachedSignature", "Must be loaded or cached signature")
				assertEqual(prof.contractVersion, "5.0.0", "Signature must have contractVersion 5.0.0")
			else
				assertTrue(string.find(reason, "Fallback") ~= nil, "Must indicate fallback reason")
				assertEqual(prof.rigType, "Articulated6Joint", "Fallback must provide standard Articulated6Joint rigType")
			end
		end
	end)

	it("should resolve signature VFX for Luffy, Zoro, Ace and fallback VFX for others without errors", function()
		for _, map in ipairs(aliasMappings) do
			local vfx, isSig, reason = AnimationRegistry.GetVFXModule(map.raw)
			assertTrue(vfx ~= nil, "VFX module must not be nil for " .. map.raw)
			assertEqual(isSig, map.isSig, "VFX signature flag mismatch for " .. map.raw)
			assertTrue(type(vfx.triggerCue) == "function", "VFX module must provide triggerCue function")
			assertTrue(type(vfx.cleanupAllForModel) == "function", "VFX module must provide cleanupAllForModel function")
		end
	end)
end)

-- =============================================================================
-- SUITE 3: CONCURRENT RIGGING & STATIC MAP ISOLATION (Task P5-20)
-- =============================================================================
describe("SUITE 3: Concurrent Rigging & Static Map Isolation (Task P5-20)", function()
	local instantiatedModels: { [string]: Model } = {}
	local rigContexts: { [string]: any } = {}

	it("should concurrently instantiate all 19 models into the Workspace without collisions", function()
		for _, asset in ipairs(ALL_19_ASSETS) do
			local absPath = resolveAssetPath(asset.path)
			local xml = fs.readFile(absPath)
			local m = roblox.deserializeModel(xml)[1]
			m.Name = asset.name

			for _, d in ipairs(m:GetDescendants()) do
				if d:IsA("BasePart") then
					d.Position = d.CFrame.Position
				end
			end

			m.Parent = mockWS
			instantiatedModels[asset.name] = m
		end
		assertEqual(#mockWS:GetChildren(), 19, "Workspace must contain all 19 instantiated models simultaneously")
	end)

	it("should rig 16 character/enemy models with proper joints and bypass 3 static map assets cleanly", function()
		for _, asset in ipairs(ALL_19_ASSETS) do
			local m = instantiatedModels[asset.name]
			local ctx, report = AnimationController.SanitizeAndRigModel(m)
			rigContexts[asset.name] = ctx

			if asset.isStaticMap then
				assertTrue(ctx == nil, "Static map asset must receive nil RigContext")
				assertEqual(report.code, "STATIC_MAP_ASSET", "Static map asset must report STATIC_MAP_ASSET")
				assertEqual(report.isValid, false, "Rig report isValid is false for static map assets (non-humanoid)")
			else
				assertTrue(ctx ~= nil, "Character model must receive valid RigContext: " .. asset.name)
				assertTrue(report.isValid, "Rig report must be valid for: " .. asset.name)

				local motorCount = 0
				for _ in pairs(ctx.motors) do
					motorCount += 1
				end
				assertTrue(motorCount >= asset.expectedJoints,
					string.format("Model '%s' expected >= %d joints, got %d", asset.name, asset.expectedJoints, motorCount))

				-- Invariant: HumanoidRootPart anchored; all non-root BaseParts unanchored and massless
				local root = m.PrimaryPart
				assertTrue(root.Anchored, "RootPart must remain anchored")
				for _, desc in ipairs(m:GetDescendants()) do
					if desc:IsA("BasePart") and desc ~= root then
						assertTrue(not desc.Anchored, "Child BasePart must be unanchored: " .. desc.Name)
						assertTrue(desc.Massless, "Child BasePart must be massless: " .. desc.Name)
					end
				end
			end
		end
	end)

	it("should assert zero cross-contamination of joints and parts between any of the 19 models", function()
		for nameA, ctxA in pairs(rigContexts) do
			if ctxA then
				local modelA = instantiatedModels[nameA]
				for _, motor in pairs(ctxA.motors) do
					assertTrue(motor.Part0:IsDescendantOf(modelA) or motor.Part0 == modelA.PrimaryPart,
						"Motor Part0 must be within its parent model")
					assertTrue(motor.Part1:IsDescendantOf(modelA) or motor.Part1 == modelA.PrimaryPart,
						"Motor Part1 must be within its parent model")

					for nameB, ctxB in pairs(rigContexts) do
						if nameA ~= nameB and ctxB then
							local modelB = instantiatedModels[nameB]
							assertTrue(not motor:IsDescendantOf(modelB), "Cross-contamination: motor in another model")
							assertTrue(not motor.Part0:IsDescendantOf(modelB), "Cross-contamination: Part0 in another model")
							assertTrue(not motor.Part1:IsDescendantOf(modelB), "Cross-contamination: Part1 in another model")
						end
					end
				end
			end
		end
	end)
end)

-- =============================================================================
-- SUITE 4: CONCURRENT ANIMATION & VFX DISPATCH (Task P5-20)
-- =============================================================================
describe("SUITE 4: Concurrent Animation & VFX Dispatch (Task P5-20)", function()
	it("should concurrently evaluate animation states for all characters without state bleeding", function()
		for _, asset in ipairs(ALL_19_ASSETS) do
			if not asset.isStaticMap then
				local prof = AnimationRegistry.GetAnimationProfile(asset.name)
				for _, stateName in ipairs({ "Idle", "Spawn", "Windup", "Attack", "Impact", "Recovery", "Ultimate" }) do
					local track = prof.states[stateName]
					if track then
						local pose = AnimationContract.EvaluatePoseAtTime(track, track.duration * 0.5)
						assertTrue(type(pose) == "table", "Pose evaluation must return table for " .. asset.name)
						assertTrue(pose.RootJoint ~= nil or pose.RightShoulder ~= nil, "Pose must contain joint offsets")
					end
				end
			end
		end
	end)

	it("should concurrently trigger multiple VFX cues across all models and maintain ledger isolation", function()
		local cues = { "AttackWindup", "AttackRelease", "AttackImpact", "UltimateCast", "UltimateImpact", "PassiveAura" }
		for _, asset in ipairs(ALL_19_ASSETS) do
			local m = mockWS:FindFirstChild(asset.name) :: Model?
			if m and not asset.isStaticMap then
				for _, cue in ipairs(cues) do
					VFXDispatcher.TriggerCue({
						sourceModel = m,
						cueType = cue :: any,
						heroId = asset.name,
					})
				end
			end
		end

		local sumIndividual = 0
		for _, asset in ipairs(ALL_19_ASSETS) do
			local m = mockWS:FindFirstChild(asset.name) :: Model?
			if m then
				local rep = VFXDispatcher.GetLedgerReport(m)
				if not asset.isStaticMap then
					assertTrue(rep.trackedInstances > 0, "Rigged character must have active VFX instances: " .. asset.name)
					sumIndividual += rep.trackedInstances
				else
					assertEqual(rep.trackedInstances, 0, "Static map asset must have 0 VFX instances: " .. asset.name)
				end
			end
		end

		local agg = VFXDispatcher.GetLedgerReport()
		assertEqual(agg.trackedInstances, sumIndividual, "Aggregate ledger must equal sum of individual model ledgers")
		assertTrue(agg.trackedInstances > 50, "Total concurrent VFX instances across 16 characters must be > 50")
	end)
end)

-- =============================================================================
-- SUITE 5: MODELVALIDATOR TRUTHFULNESS ACROSS ALL 19 MODELS (Task P5-20)
-- =============================================================================
describe("SUITE 5: ModelValidator Truthfulness Across All 19 Models (Task P5-20)", function()
	it("should truthfully validate all 19 models distinguishing Signatures, Fallbacks, and Static Map Assets", function()
		for _, asset in ipairs(ALL_19_ASSETS) do
			local m = mockWS:FindFirstChild(asset.name) :: Model?
			assertTrue(m ~= nil, "Model must exist in Workspace: " .. asset.name)

			local report = ModelValidator.ValidateModel(m)
			assertTrue(report.isValid, "Model validation must be valid for: " .. asset.name)

			if asset.isStaticMap then
				assertEqual(report.statusCode, "STATIC_MAP_ASSET", "Static map asset must report STATIC_MAP_ASSET")
				assertEqual(report.statusBadge, "N/A (Static Map Asset)", "Static map badge must be 'N/A (Static Map Asset)'")
				assertTrue(report.isStaticMapAsset, "isStaticMapAsset flag must be true")
				assertEqual(report.motor6DCount, 0, "Static map asset must have 0 Motor6D joints")
			elseif asset.isSignature then
				assertEqual(report.statusCode, "VALID", "Signature model must report VALID status code")
				assertEqual(report.statusBadge, "VALID (Signature)", "Signature model badge must be 'VALID (Signature)'")
				assertTrue(report.hasSignatureAnim, "hasSignatureAnim must be true for signature: " .. asset.name)
				assertTrue(report.hasSignatureVFX, "hasSignatureVFX must be true for signature: " .. asset.name)
				assertTrue(report.motor6DCount >= 5, "Signature must have >= 5 Motor6D joints")
			else
				assertTrue(report.statusCode == "VALID" or report.statusCode == "FALLBACK_PROFILE",
					"Legacy model must report VALID or FALLBACK_PROFILE: " .. asset.name)
				assertTrue(report.motor6DCount >= 5, "Rigged legacy model must have >= 5 Motor6D joints")
			end
		end
	end)
end)

-- =============================================================================
-- SUITE 6: SIMULTANEOUS REST POSE RESTITUTION & ZERO-DRIFT (Task P5-20)
-- =============================================================================
describe("SUITE 6: Simultaneous Rest Pose Restitution & Zero-Drift (Task P5-20)", function()
	it("should restore rest pose across all 16 rigged characters with delta < 0.001 studs", function()
		for _, asset in ipairs(ALL_19_ASSETS) do
			if not asset.isStaticMap then
				local m = mockWS:FindFirstChild(asset.name) :: Model?
				assertTrue(m ~= nil, "Character model must exist: " .. asset.name)

				local ctx = AnimationController.GetRigContext(m)
				assertTrue(ctx ~= nil, "RigContext must exist for: " .. asset.name)

				-- Mutate joints to simulate arbitrary active combat animations
				for jName, motor in pairs(ctx.motors) do
					motor.C0 = ctx.restPose.baseC0[jName] * CFrame.new(0.5, 0.2, -0.3) * CFrame.Angles(math.rad(25), math.rad(-15), 0)
				end

				-- Execute ResetRestPose
				AnimationController.ResetRestPose(m)

				-- Verify strictly delta < 0.001 restitution
				for jName, motor in pairs(ctx.motors) do
					local baseC0 = ctx.restPose.baseC0[jName]
					local delta = (motor.C0.Position - baseC0.Position).Magnitude
					assertTrue(delta < 0.001, string.format("Restitution delta must be < 0.001 studs on %s.%s (got %.6f)", asset.name, jName, delta))
				end
			end
		end
	end)
end)

-- =============================================================================
-- SUITE 7: SIMULTANEOUS 100% CLEANUP & ZERO LEAK BALANCE (Task P5-20)
-- =============================================================================
describe("SUITE 7: Simultaneous 100% Cleanup & Zero Leak Balance (Task P5-20)", function()
	it("should execute 100% cleanup across all 19 models simultaneously leaving 0 active instances", function()
		VFXDispatcher.CleanupAll()

		local aggPost = VFXDispatcher.GetLedgerReport()
		assertEqual(aggPost.activeCount, 0, "Active VFX instances must be 0 after CleanupAll")
		assertEqual(aggPost.trackedTweens, 0, "Active tweens must be 0 after CleanupAll")
		assertEqual(aggPost.trackedTasks, 0, "Active tasks must be 0 after CleanupAll")
		assertEqual(aggPost.trackedConnections, 0, "Active connections must be 0 after CleanupAll")

		for _, asset in ipairs(ALL_19_ASSETS) do
			local m = mockWS:FindFirstChild(asset.name) :: Model?
			if m then
				AnimationController.DestroyContext(m)
				m:Destroy()
			end
		end

		assertEqual(#mockWS:GetChildren(), 0, "Workspace must contain 0 leftover instances after model destruction")
	end)
end)

-- =============================================================================
-- SUMMARY REPORT
-- =============================================================================
print("\n" .. string.rep("=", 65))
print(string.format("PHASE 5 COEXISTENCE TEST SUITE COMPLETE: %d / %d PASSED (Failed: %d)",
	passedTests, totalTests, failedTests))
print(string.rep("=", 65))

if failedTests > 0 then
	error(string.format("%d tests failed in coexistence test suite!", failedTests))
end
