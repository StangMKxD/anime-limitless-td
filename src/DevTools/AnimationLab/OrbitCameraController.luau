--!strict
-- src/DevTools/AnimationLab/OrbitCameraController.luau
-- Orbit, Pan, and Preset Camera Controller with 100% Zero-Drift Restitution (MEM-FIX-0003).

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LabConfig = require(script.Parent:WaitForChild("LabConfig")) :: any

local OrbitCameraController = {}

export type CameraSavedState = {
	cameraType: Enum.CameraType,
	cameraSubject: Instance?,
	cframe: CFrame,
	fieldOfView: number,
}

local savedState: CameraSavedState? = nil
local isActive = false
local orbitYaw = 45.0 -- degrees
local orbitPitch = 20.0 -- degrees
local orbitDistance = 18.0 -- studs
local orbitFocus = LabConfig.STAGE_POSITION + Vector3.new(0, 3.5, 0)
local renderConn: RBXScriptConnection? = nil
local inputConn: RBXScriptConnection? = nil

local function updateCameraTransform()
	local cam = Workspace.CurrentCamera
	if not cam or not isActive then
		return
	end

	local rot = CFrame.Angles(0, math.rad(orbitYaw), 0) * CFrame.Angles(math.rad(-orbitPitch), 0, 0)
	local offset = rot * Vector3.new(0, 0, orbitDistance)
	cam.CFrame = CFrame.lookAt(orbitFocus + offset, orbitFocus)
end

function OrbitCameraController.Activate(initialFocus: Vector3?)
	if isActive then
		return
	end
	local cam = Workspace.CurrentCamera
	if not cam then
		return
	end

	-- Save original camera state for lossless restore
	savedState = {
		cameraType = cam.CameraType,
		cameraSubject = cam.CameraSubject,
		cframe = cam.CFrame,
		fieldOfView = cam.FieldOfView,
	}

	isActive = true
	cam.CameraType = Enum.CameraType.Scriptable
	if initialFocus then
		orbitFocus = initialFocus
	else
		orbitFocus = LabConfig.STAGE_POSITION + Vector3.new(0, 3.5, 0)
	end

	updateCameraTransform()

	renderConn = RunService.RenderStepped:Connect(function()
		if isActive then
			updateCameraTransform()
		end
	end)
end

function OrbitCameraController.Deactivate()
	if not isActive then
		return
	end
	isActive = false

	if renderConn then
		renderConn:Disconnect()
		renderConn = nil
	end
	if inputConn then
		inputConn:Disconnect()
		inputConn = nil
	end

	local cam = Workspace.CurrentCamera
	if cam and savedState then
		cam.CameraType = savedState.cameraType
		cam.CameraSubject = savedState.cameraSubject
		cam.CFrame = savedState.cframe
		cam.FieldOfView = savedState.fieldOfView
	end
	savedState = nil
end

function OrbitCameraController.SetPresetView(preset: "Front" | "Side" | "Back" | "Reset" | "Focus")
	if preset == "Front" then
		orbitYaw = 0
		orbitPitch = 10
		orbitDistance = 16
	elseif preset == "Side" then
		orbitYaw = 90
		orbitPitch = 10
		orbitDistance = 16
	elseif preset == "Back" then
		orbitYaw = 180
		orbitPitch = 10
		orbitDistance = 16
	elseif preset == "Reset" then
		orbitYaw = 45
		orbitPitch = 20
		orbitDistance = 18
	elseif preset == "Focus" then
		orbitDistance = 10
	end
	updateCameraTransform()
end

function OrbitCameraController.ApplyPan(deltaX: number, deltaY: number)
	orbitYaw = (orbitYaw - deltaX * 0.4) % 360
	orbitPitch = math.clamp(orbitPitch + deltaY * 0.4, -75, 75)
	updateCameraTransform()
end

function OrbitCameraController.ApplyZoom(deltaZoom: number)
	orbitDistance = math.clamp(orbitDistance - deltaZoom * 2.0, 4, 50)
	updateCameraTransform()
end

function OrbitCameraController.SetFocusPoint(focus: Vector3)
	orbitFocus = focus
	updateCameraTransform()
end

return table.freeze(OrbitCameraController)
