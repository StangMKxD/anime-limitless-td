--!strict
-- src/DevTools/AnimationLab/init.luau
-- Anime Limitless Tower Defense — Animation Lab Module Package

local LabConfig = require(script:WaitForChild("LabConfig"))
local ModelValidator = require(script:WaitForChild("ModelValidator"))
local SandboxStageManager = require(script:WaitForChild("SandboxStageManager"))
local OrbitCameraController = require(script:WaitForChild("OrbitCameraController"))
local TimelineController = require(script:WaitForChild("TimelineController"))
local VFXInspector = require(script:WaitForChild("VFXInspector"))
local TelemetryCollector = require(script:WaitForChild("TelemetryCollector"))
local StressTestRunner = require(script:WaitForChild("StressTestRunner"))
local AnimationLabGui = require(script:WaitForChild("AnimationLabGui"))

return table.freeze({
	LabConfig = LabConfig,
	ModelValidator = ModelValidator,
	SandboxStageManager = SandboxStageManager,
	OrbitCameraController = OrbitCameraController,
	TimelineController = TimelineController,
	VFXInspector = VFXInspector,
	TelemetryCollector = TelemetryCollector,
	StressTestRunner = StressTestRunner,
	AnimationLabGui = AnimationLabGui,
})
