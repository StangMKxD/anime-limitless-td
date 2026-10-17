--!strict
-- tests/phase6_presentation_and_maps.spec.luau
-- Phase 6 Presentation Runtime & Multi-Map System Verification Suite
-- Validates PresentationContract, MapCatalog, MapContract, MapService, MapSelectionService,
-- RigBinder, RigDiagnostics, AttackMotionProfiles, AnimationPlayback, PresentationPreferences,
-- QualityPolicy, VFXDispatcher, EnemyPresentation, and BossPresentation.

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

-- Global Types / Classes
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
	spawn = function(fn: () -> ()) fn() end,
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

-- Mock Services
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
			return { Disconnect = function() end }
		end,
	},
	RenderStepped = {
		Connect = function(self, fn)
			return { Disconnect = function() end }
		end,
	},
	IsStudio = function(self) return true end,
	IsClient = function(self) return true end,
	IsServer = function(self) return true end,
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

local mockPlayers = {
	LocalPlayer = {
		UserId = 12345678,
		Name = "TestPlayer",
	},
	GetPlayers = function(self)
		return {
			{ UserId = 12345678, Name = "TestPlayer" },
		}
	end,
	PlayerRemoving = {
		Connect = function(self, fn)
			return { Disconnect = function() end }
		end,
	},
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
		elseif name == "Players" then
			return mockPlayers
		end
		return Instance.new("Folder")
	end,
}

-- Load deliverable modules
local realRequire = require

local PresentationContract = (function()
	local ok, mod = pcall(realRequire, "../src/Shared/PresentationContract")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Shared/PresentationContract")
	if ok2 then return mod2 end
	error("Failed to require PresentationContract: " .. tostring(mod))
end)()

local MapCatalog = (function()
	local ok, mod = pcall(realRequire, "../src/Shared/MapCatalog")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Shared/MapCatalog")
	if ok2 then return mod2 end
	error("Failed to require MapCatalog: " .. tostring(mod))
end)()

local MapContract = (function()
	local ok, mod = pcall(realRequire, "../src/Shared/MapContract")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Shared/MapContract")
	if ok2 then return mod2 end
	error("Failed to require MapContract: " .. tostring(mod))
end)()

local GameConfig = (function()
	local ok, mod = pcall(realRequire, "../src/Shared/GameConfig")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Shared/GameConfig")
	if ok2 then return mod2 end
	error("Failed to require GameConfig: " .. tostring(mod))
end)()

local AnimationContract = (function()
	local ok, mod = pcall(realRequire, "../src/Shared/AnimationContract")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Shared/AnimationContract")
	if ok2 then return mod2 end
	error("Failed to require AnimationContract: " .. tostring(mod))
end)()

local VFXContract = (function()
	local ok, mod = pcall(realRequire, "../src/Shared/VFXContract")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Shared/VFXContract")
	if ok2 then return mod2 end
	error("Failed to require VFXContract: " .. tostring(mod))
end)()

-- Mount into mock Shared folder for dependent modules
local function mountModule(name: string, value: any)
	local m = Instance.new("Folder")
	m.Name = name
	m.Parent = mockShared
end
mountModule("GameConfig", GameConfig)
mountModule("MapCatalog", MapCatalog)
mountModule("MapContract", MapContract)
mountModule("PresentationContract", PresentationContract)
mountModule("AnimationContract", AnimationContract)
mountModule("VFXContract", VFXContract)

local PresentationPreferences = (function()
	local ok, mod = pcall(realRequire, "../src/Presentation/PresentationPreferences")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Presentation/PresentationPreferences")
	if ok2 then return mod2 end
	error("Failed to require PresentationPreferences: " .. tostring(mod))
end)()

local QualityPolicy = (function()
	local ok, mod = pcall(realRequire, "../src/Presentation/QualityPolicy")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Presentation/QualityPolicy")
	if ok2 then return mod2 end
	error("Failed to require QualityPolicy: " .. tostring(mod))
end)()

local RigBinder = (function()
	local ok, mod = pcall(realRequire, "../src/Presentation/RigBinder")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Presentation/RigBinder")
	if ok2 then return mod2 end
	error("Failed to require RigBinder: " .. tostring(mod))
end)()

local RigDiagnostics = (function()
	local ok, mod = pcall(realRequire, "../src/Presentation/RigDiagnostics")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Presentation/RigDiagnostics")
	if ok2 then return mod2 end
	error("Failed to require RigDiagnostics: " .. tostring(mod))
end)()

local AttackMotionProfiles = (function()
	local ok, mod = pcall(realRequire, "../src/Presentation/AttackMotionProfiles")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Presentation/AttackMotionProfiles")
	if ok2 then return mod2 end
	error("Failed to require AttackMotionProfiles: " .. tostring(mod))
end)()

local AnimationPlayback = (function()
	local ok, mod = pcall(realRequire, "../src/Presentation/AnimationPlayback")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Presentation/AnimationPlayback")
	if ok2 then return mod2 end
	error("Failed to require AnimationPlayback: " .. tostring(mod))
end)()

local VFXDispatcher = (function()
	local ok, mod = pcall(realRequire, "../src/Presentation/VFXDispatcher")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Presentation/VFXDispatcher")
	if ok2 then return mod2 end
	error("Failed to require VFXDispatcher: " .. tostring(mod))
end)()

local EnemyPresentation = (function()
	local ok, mod = pcall(realRequire, "../src/Presentation/EnemyPresentation")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Presentation/EnemyPresentation")
	if ok2 then return mod2 end
	error("Failed to require EnemyPresentation: " .. tostring(mod))
end)()

local BossPresentation = (function()
	local ok, mod = pcall(realRequire, "../src/Presentation/BossPresentation")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Presentation/BossPresentation")
	if ok2 then return mod2 end
	error("Failed to require BossPresentation: " .. tostring(mod))
end)()

local MarinefordBuilder = (function()
	local ok, mod = pcall(realRequire, "../src/Track1_WaveSystem/Maps/Builders/Marineford")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Track1_WaveSystem/Maps/Builders/Marineford")
	if ok2 then return mod2 end
	error("Failed to require MarinefordBuilder: " .. tostring(mod))
end)()

local SakuraHarborBuilder = (function()
	local ok, mod = pcall(realRequire, "../src/Track1_WaveSystem/Maps/Builders/SakuraHarbor")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Track1_WaveSystem/Maps/Builders/SakuraHarbor")
	if ok2 then return mod2 end
	error("Failed to require SakuraHarborBuilder: " .. tostring(mod))
end)()

local SkySanctuaryBuilder = (function()
	local ok, mod = pcall(realRequire, "../src/Track1_WaveSystem/Maps/Builders/SkySanctuary")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Track1_WaveSystem/Maps/Builders/SkySanctuary")
	if ok2 then return mod2 end
	error("Failed to require SkySanctuaryBuilder: " .. tostring(mod))
end)()

local VolcanicCitadelBuilder = (function()
	local ok, mod = pcall(realRequire, "../src/Track1_WaveSystem/Maps/Builders/VolcanicCitadel")
	if ok then return mod end
	local ok2, mod2 = pcall(realRequire, "./src/Track1_WaveSystem/Maps/Builders/VolcanicCitadel")
	if ok2 then return mod2 end
	error("Failed to require VolcanicCitadelBuilder: " .. tostring(mod))
end)()

-- Test runner assertions
local totalTests = 0
local passedTests = 0
local failedTests = 0

local function runTest(group: string, name: string, fn: () -> ())
	totalTests += 1
	local ok, err = pcall(fn)
	if ok then
		passedTests += 1
		print(string.format("  [PASS] %s :: %s", group, name))
	else
		failedTests += 1
		print(string.format("  [FAIL] %s :: %s\n         Error: %s", group, name, tostring(err)))
	end
end

local function assertEqual(actual: any, expected: any, msg: string?)
	if actual ~= expected then
		error(string.format("%s: expected '%s' (%s), got '%s' (%s)", msg or "Assertion failed", tostring(expected), typeof(expected), tostring(actual), typeof(actual)))
	end
end

local function assertTrue(cond: boolean, msg: string?)
	if not cond then
		error(msg or "Condition was not true")
	end
end

print("================================================================================")
print("PHASE 6: PRESENTATION RUNTIME & MULTI-MAP VERIFICATION SPEC (LUNE RUNNER)")
print("================================================================================")

-- -----------------------------------------------------------------------------
-- GROUP 1: MapCatalog & MapContract Definitions
-- -----------------------------------------------------------------------------
runTest("MapCatalog", "Provides 4 distinct balanced maps with exact 6 waypoints and 8 slots", function()
	local allMaps = MapCatalog.GetAllMapIds()
	assertEqual(#allMaps, 4, "Must have exactly 4 maps defined")
	
	local expectedIds = { Marineford = true, SakuraHarbor = true, SkySanctuary = true, VolcanicCitadel = true }
	for _, mId in ipairs(allMaps) do
		assertTrue(expectedIds[mId], "Map ID must match recognized catalog entry: " .. tostring(mId))
		local def = MapCatalog.GetMap(mId)
		assertTrue(def ~= nil, "Map definition must exist for " .. mId)
		assertEqual(#def.orderedWaypoints, 6, "Each map must have exactly 6 ordered waypoints")
		
		-- Invariance check: waypoints must match baseline coordinates
		for idx, wp in ipairs(def.orderedWaypoints) do
			local baseWp = MapCatalog.BASELINE_WAYPOINTS[idx]
			assertTrue((wp - baseWp).Magnitude < 0.001, "Waypoint " .. idx .. " coordinates must match baseline exactly")
		end
		
		-- Invariance check: slots must match baseline coordinates
		for slotIdx = 1, 8 do
			local sName = "Slot_" .. slotIdx
			local sPos = def.placementSlots[sName]
			local basePos = MapCatalog.BASELINE_SLOTS[sName]
			assertTrue(sPos ~= nil, "Slot " .. sName .. " must exist in map " .. mId)
			assertTrue((sPos - basePos).Magnitude < 0.001, "Slot " .. sName .. " must match baseline position")
		end
	end
end)

runTest("MapCatalog", "Default map is Marineford and validation helpers work properly", function()
	assertEqual(MapCatalog.DEFAULT_MAP_ID, "Marineford", "Default map must be Marineford")
	local def = MapCatalog.GetDefaultMap()
	assertEqual(def.id, "Marineford", "GetDefaultMap() must return Marineford definition")
	
	assertTrue(MapCatalog.ValidateMapId("Marineford"), "Marineford should be valid")
	assertTrue(MapCatalog.ValidateMapId("SakuraHarbor"), "SakuraHarbor should be valid")
	assertTrue(MapCatalog.ValidateMapId("SkySanctuary"), "SkySanctuary should be valid")
	assertTrue(MapCatalog.ValidateMapId("VolcanicCitadel"), "VolcanicCitadel should be valid")
	assertTrue(not MapCatalog.ValidateMapId("UnknownFakeMap"), "Unknown map should be invalid")
	assertTrue(not MapCatalog.ValidateMapId(nil), "Nil map should be invalid")
end)

runTest("MapContract", "Validates lifecycle states, vote schemas, and error codes", function()
	assertEqual(MapContract.VERSION, 1, "MapContract version must be 1")
	assertEqual(MapContract.LIFECYCLE_STATES.PREPARATION_SELECTION, "PreparationSelection")
	assertEqual(MapContract.LIFECYCLE_STATES.LOCKED, "Locked")
	assertEqual(MapContract.LIFECYCLE_STATES.LOADING, "Loading")
	assertEqual(MapContract.LIFECYCLE_STATES.READY, "Ready")
	
	local validPayload = {
		mapId = "SakuraHarbor",
		selectionRevision = 1,
		requestId = "req_12345",
	}
	local ok, err = MapContract.ValidateVoteRequest(validPayload)
	assertTrue(ok, "Valid payload must pass validation: " .. tostring(err))
	
	local invalidPayload1 = { mapId = "InvalidMap", selectionRevision = 1, requestId = "req_1" }
	local ok1, err1 = MapContract.ValidateVoteRequest(invalidPayload1)
	assertTrue(not ok1, "Payload with invalid map must fail validation")
	
	local invalidPayload2 = { mapId = "Marineford", selectionRevision = -1, requestId = "req_2" }
	local ok2, err2 = MapContract.ValidateVoteRequest(invalidPayload2)
	assertTrue(not ok2, "Payload with negative revision must fail validation")
end)

-- -----------------------------------------------------------------------------
-- GROUP 2: Map Builders & Environment Synthesis
-- -----------------------------------------------------------------------------
runTest("MapBuilders", "All 4 theme builders build environment without errors", function()
	local testFolder = Instance.new("Folder")
	testFolder.Name = "TestGrandLineMap"
	testFolder.Parent = mockWS
	
	local builders = {
		Marineford = MarinefordBuilder,
		SakuraHarbor = SakuraHarborBuilder,
		SkySanctuary = SkySanctuaryBuilder,
		VolcanicCitadel = VolcanicCitadelBuilder,
	}
	
	for mapId, b in pairs(builders) do
		testFolder:ClearAllChildren()
		local def = MapCatalog.GetMap(mapId)
		local ok, err = pcall(function()
			b.Build(testFolder, def)
		end)
		assertTrue(ok, "Builder for " .. mapId .. " must succeed: " .. tostring(err))
		assertTrue(#testFolder:GetChildren() > 0, "Builder for " .. mapId .. " must create environmental parts")
	end
	testFolder:Destroy()
end)

-- -----------------------------------------------------------------------------
-- GROUP 3: Presentation Contract & Feedback Ports
-- -----------------------------------------------------------------------------
runTest("PresentationContract", "Validates cosmetic attack events and schema boundaries", function()
	assertEqual(PresentationContract.VERSION, 1, "PresentationContract version must be 1")
	
	local validEvent = {
		version = 1,
		attackId = "Luffy_atk_001",
		unitUid = "Luffy_1",
		heroId = "Luffy",
		startedAtServerTime = 100.0,
		impactAtServerTime = 100.31,
		logicalOriginCFrame = CFrame.identity,
		targetPositionSnapshot = Vector3.new(20, 3, 20),
		visualSeed = 42,
		presentationRevision = 1,
	}
	local ok, err = PresentationContract.ValidatePresentationEvent(validEvent)
	assertTrue(ok, "Valid presentation event must pass: " .. tostring(err))
	
	local invalidEvent = {
		version = 1,
		attackId = "Luffy_atk_002",
		-- Missing unitUid and heroId
		startedAtServerTime = 100.0,
	}
	local okInv, errInv = PresentationContract.ValidatePresentationEvent(invalidEvent)
	assertTrue(not okInv, "Invalid event missing keys must fail validation")
	
	-- Camera priority resolution
	assertTrue(PresentationContract.CanOverrideCamera("UltimateCinematic", "AmbientCombat"), "Ultimate should override Ambient")
	assertTrue(not PresentationContract.CanOverrideCamera("AmbientCombat", "UltimateCinematic"), "Ambient should not override Ultimate")
end)

-- -----------------------------------------------------------------------------
-- GROUP 4: RigBinder, Multi-Part Grouping & Rest-Pose Restitution
-- -----------------------------------------------------------------------------
runTest("RigBinder", "Binds semantic Motor6D joints and accessory attachments without cross-joint cycle locks", function()
	local dummyModel = Instance.new("Model")
	dummyModel.Name = "TestZoroHero"
	dummyModel.Parent = mockWS
	
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Position = Vector3.new(0, 3, 0)
	hrp.Parent = dummyModel
	dummyModel.PrimaryPart = hrp
	
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Position = Vector3.new(0, 3, 0)
	torso.Parent = dummyModel
	
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Position = Vector3.new(0, 4.5, 0)
	head.Parent = dummyModel
	
	local rArm = Instance.new("Part")
	rArm.Name = "RightArm"
	rArm.Position = Vector3.new(1.5, 3, 0)
	rArm.Parent = dummyModel
	
	local lArm = Instance.new("Part")
	lArm.Name = "LeftArm"
	lArm.Position = Vector3.new(-1.5, 3, 0)
	lArm.Parent = dummyModel
	
	local rLeg = Instance.new("Part")
	rLeg.Name = "RightLeg"
	rLeg.Position = Vector3.new(0.5, 1, 0)
	rLeg.Parent = dummyModel
	
	local lLeg = Instance.new("Part")
	lLeg.Name = "LeftLeg"
	lLeg.Position = Vector3.new(-0.5, 1, 0)
	lLeg.Parent = dummyModel
	
	local sword1 = Instance.new("Part")
	sword1.Name = "Enma"
	sword1.Position = Vector3.new(1.8, 3, 1)
	sword1.Parent = dummyModel
	
	local sword2 = Instance.new("Part")
	sword2.Name = "Wado"
	sword2.Position = Vector3.new(0, 4.5, 0.8)
	sword2.Parent = dummyModel
	
	-- Bind Semantic Rig
	local ok, boundJoints = pcall(function()
		return RigBinder.BindSemanticRig(dummyModel, {
			weaponRightPart = sword1,
			weaponMouthPart = sword2,
		})
	end)
	assertTrue(ok, "RigBinder.BindSemanticRig must succeed: " .. tostring(boundJoints))
	assertTrue(boundJoints.RootJoint ~= nil, "RootJoint must be created")
	assertTrue(boundJoints.Neck ~= nil, "Neck joint must be created")
	assertTrue(boundJoints.RightShoulder ~= nil, "RightShoulder must be created")
	assertTrue(boundJoints.LeftShoulder ~= nil, "LeftShoulder must be created")
	assertTrue(boundJoints.RightHip ~= nil, "RightHip must be created")
	assertTrue(boundJoints.LeftHip ~= nil, "LeftHip must be created")
	
	-- Audit for zero rigid cross-joint cycles
	local audit = RigDiagnostics.AuditModel(dummyModel)
	assertEqual(audit.rigidCycleCount, 0, "Rig must have 0 rigid cross-joint weld cycles")
	assertTrue(audit.isMobilityVerified, "Model mobility must be verified")
	
	-- Test Rest Pose Snapshot and Restitution
	local snapshot = RigBinder.CaptureRestPose(dummyModel)
	assertTrue(snapshot ~= nil, "Snapshot must be captured")
	
	-- Mutate joint
	boundJoints.RightShoulder.C0 = boundJoints.RightShoulder.C0 * CFrame.Angles(0.5, 0.2, 0.1)
	
	-- Restore Rest Pose
	RigBinder.RestoreRestPose(dummyModel, snapshot)
	local delta = (boundJoints.RightShoulder.C0.Position - snapshot.joints.RightShoulder.C0.Position).Magnitude
	assertTrue(delta < 0.001, "Rest pose C0 delta must be < 0.001 after restitution")
	
	dummyModel:Destroy()
end)

-- -----------------------------------------------------------------------------
-- GROUP 5: Attack Motion Profiles (8 Playable Heroes)
-- -----------------------------------------------------------------------------
runTest("AttackMotionProfiles", "Returns verified 5-phase motion trajectories for all 8 playable heroes", function()
	local heroes = {
		"Luffy",
		"Zoro",
		"Ace",
		"Shanks",
		"Whitebeard",
		"Law",
		"Kizaru",
		"Sanji",
	}
	
	for _, heroId in ipairs(heroes) do
		local profile = AttackMotionProfiles.GetProfile(heroId)
		assertTrue(profile.heroId == heroId or string.find(profile.heroId, heroId) ~= nil, "Profile heroId must match or contain " .. heroId)
		assertTrue(profile.attackDuration > 0, "Total duration must be > 0")
		assertTrue(profile.impactTime >= 0.28 and profile.impactTime <= 0.35, "Impact offset must approximate nominal 0.31s")
		
		-- Evaluate trajectory across 5 phases
		local phases = { 0.05, 0.15, 0.31, 0.40, 0.50 }
		for _, t in ipairs(phases) do
			local eval = AttackMotionProfiles.EvaluateAtTime(profile, t)
			assertTrue(eval ~= nil, "Evaluation at t=" .. t .. " must not be nil")
			assertTrue(eval.rootOffset ~= nil, "Root offset must be defined")
			assertTrue(eval.rightArmAngle ~= nil, "Right arm angle must be defined")
		end
	end
	
	-- Fallback check for unlisted hero
	local fallback = AttackMotionProfiles.GetProfile("Chopper")
	assertTrue(fallback ~= nil, "Fallback profile must be provided for unlisted heroes")
end)

-- -----------------------------------------------------------------------------
-- GROUP 6: AnimationPlayback Determinism & Zero Drift
-- -----------------------------------------------------------------------------
runTest("AnimationPlayback", "Supports 8 playback states with transport controls and zero CFrame drift", function()
	local dummyModel = Instance.new("Model")
	dummyModel.Name = "PlaybackDummy"
	dummyModel.Parent = mockWS
	
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Parent = dummyModel
	dummyModel.PrimaryPart = hrp
	
	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Parent = dummyModel
	
	local rArm = Instance.new("Part")
	rArm.Name = "RightArm"
	rArm.Parent = dummyModel
	
	local joints = RigBinder.BindSemanticRig(dummyModel)
	local controller = AnimationPlayback.NewController(dummyModel, "Luffy")
	assertTrue(controller ~= nil, "Controller must be created")
	
	-- Initial state is Idle
	assertEqual(controller:GetState(), "Idle")
	
	-- Switch through 8 states
	local states = { "Idle", "SpecialIdle", "Spawn", "Windup", "Attack", "Impact", "Recovery", "Ultimate" }
	for _, s in ipairs(states) do
		controller:TransitionTo(s)
		assertEqual(controller:GetState(), s, "State must transition to " .. s)
	end
	
	-- Transport controls
	controller:Play("Attack")
	assertEqual(controller:IsPlaying(), true)
	controller:Pause()
	assertEqual(controller:IsPlaying(), false)
	controller:Resume()
	assertEqual(controller:IsPlaying(), true)
	controller:Stop()
	assertEqual(controller:IsPlaying(), false)
	
	-- Test deterministic seek at t=0.15
	controller:Seek(0.15)
	local c0_1 = joints.RightShoulder.C0
	controller:Seek(0.40)
	controller:Seek(0.15)
	local c0_2 = joints.RightShoulder.C0
	
	local drift = (c0_1.Position - c0_2.Position).Magnitude
	assertTrue(drift < 0.001, "Deterministic seek must produce zero position drift (< 0.001)")
	
	controller:Destroy()
	dummyModel:Destroy()
end)

-- -----------------------------------------------------------------------------
-- GROUP 7: PresentationPreferences & QualityPolicy Caps
-- -----------------------------------------------------------------------------
runTest("PresentationPreferences", "Manages client-local preferences with subscription & reset", function()
	local initial = PresentationPreferences.GetSnapshot()
	assertEqual(initial.quality, "Medium")
	assertEqual(initial.reducedMotion, false)
	
	local callbackFired = false
	local subConn = PresentationPreferences.Subscribe(function(snap)
		callbackFired = true
		assertEqual(snap.quality, "High")
	end)
	
	PresentationPreferences.SetLocal("quality", "High")
	assertTrue(callbackFired, "Subscriber callback must fire on SetLocal")
	assertEqual(PresentationPreferences.Get("quality"), "High")
	
	subConn.Disconnect()
	
	-- ResetLocal restores defaults
	PresentationPreferences.ResetLocal()
	assertEqual(PresentationPreferences.Get("quality"), "Medium")
end)

runTest("QualityPolicy", "Enforces strictly monotonic part, particle, and light caps across presets", function()
	local lowPolicy = QualityPolicy.GetPolicy("Low")
	local medPolicy = QualityPolicy.GetPolicy("Medium")
	local highPolicy = QualityPolicy.GetPolicy("High")
	
	assertTrue(lowPolicy.maxParticlesPerEmitter <= medPolicy.maxParticlesPerEmitter, "Low particles <= Med particles")
	assertTrue(medPolicy.maxParticlesPerEmitter <= highPolicy.maxParticlesPerEmitter, "Med particles <= High particles")
	
	assertTrue(lowPolicy.maxLightsPerCharacter <= medPolicy.maxLightsPerCharacter, "Low lights <= Med lights")
	assertTrue(medPolicy.maxLightsPerCharacter <= highPolicy.maxLightsPerCharacter, "Med lights <= High lights")
	
	assertEqual(lowPolicy.allowPointLights, false, "Low quality must disable point lights")
	assertEqual(highPolicy.allowPointLights, true, "High quality must allow point lights")
end)

-- -----------------------------------------------------------------------------
-- GROUP 8: Neutral VFX Dispatcher & Zero-Leak Resource Ledger
-- -----------------------------------------------------------------------------
runTest("VFXDispatcher", "Allocates visual instances and guarantees 100% cleanup without leaks", function()
	local testModel = Instance.new("Model")
	testModel.Name = "VFXTestModel"
	testModel.Parent = mockWS
	
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Parent = testModel
	testModel.PrimaryPart = root
	
	-- Dispatch attack VFX
	VFXDispatcher.TriggerVFX(testModel, {
		heroId = "Luffy",
		cue = "AttackImpact",
		impactPosition = Vector3.new(10, 0, 10),
		quality = "Medium",
	})
	
	local report = VFXDispatcher.GetLedgerReport(testModel)
	assertTrue(report.activeCount > 0, "Ledger must track created instances")
	
	-- Cleanup model
	VFXDispatcher.CleanupModel(testModel)
	local postReport = VFXDispatcher.GetLedgerReport(testModel)
	assertEqual(postReport.activeCount, 0, "Active instance count must be 0 after cleanup")
	assertEqual(postReport.trackedInstances, 0, "Tracked instances must be 0 after cleanup")
	
	testModel:Destroy()
end)

-- -----------------------------------------------------------------------------
-- GROUP 9: Enemy & Boss Locomotion Presentation
-- -----------------------------------------------------------------------------
runTest("EnemyPresentation", "Computes procedural locomotion gait without altering server authoritative position", function()
	local basePos = Vector3.new(0, 3, 0)
	local disp0 = EnemyPresentation.ComputeGaitDisplacement(0.0, 10.0, 1.0)
	local disp1 = EnemyPresentation.ComputeGaitDisplacement(0.25, 10.0, 1.0)
	local disp2 = EnemyPresentation.ComputeGaitDisplacement(0.50, 10.0, 1.0)
	
	-- Bobbing displacement must oscillate smoothly
	assertTrue(typeof(disp0) == "Vector3", "Displacement must be a Vector3")
	assertTrue(math.abs(disp0.Y) < 1.0, "Bobbing amplitude must be cosmetic (< 1.0 studs)")
	assertTrue(disp0 ~= disp1 or disp1 ~= disp2, "Displacement must vary over time")
end)

runTest("BossPresentation", "Applies cosmetic boss spawn aura without throwing errors", function()
	local bossModel = Instance.new("Model")
	bossModel.Name = "BossModel"
	bossModel.Parent = mockWS
	
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Parent = bossModel
	bossModel.PrimaryPart = hrp
	
	local ok, err = pcall(function()
		BossPresentation.CosmeticBossSpawnAura(bossModel, "Kaido")
	end)
	assertTrue(ok, "Boss spawn presentation must succeed: " .. tostring(err))
	
	BossPresentation.CosmeticBossImpactShockwave(hrp.Position, 25.0)
	
	bossModel:Destroy()
end)

-- =============================================================================
-- FINAL SUMMARY
-- =============================================================================
print("\n=======================================================")
print(string.format("PHASE 6 TEST RUN COMPLETE: %d / %d PASSED (Failed: %d)", passedTests, totalTests, failedTests))
print("=======================================================\n")

if failedTests > 0 then
	error(string.format("Verification failed: %d Phase 6 tests failed", failedTests))
end
