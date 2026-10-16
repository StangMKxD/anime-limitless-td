--!strict
-- src/DevTools/AnimationLab/SandboxStageManager.luau
-- Manages the isolated 3D Workspace sandbox stage at Y=5000 with studio lighting, grid, dummy, and clean teardown.

local Workspace = game:GetService("Workspace")
local LabConfig = require(script.Parent:WaitForChild("LabConfig")) :: any

local SandboxStageManager = {}

export type StageSession = {
	sessionId: string,
	container: Folder,
	stagePlatform: Part,
	lightingFolder: Folder,
	charactersFolder: Folder,
	vfxFolder: Folder,
	dummyTarget: Model?,
	jointMarkersFolder: Folder,
	activeModel: Model?,
	activeScale: number,
	isGridVisible: boolean,
	areJointMarkersVisible: boolean,
	isBoundingBoxVisible: boolean,
	areAccessoriesVisible: boolean,
	isDummyVisible: boolean,
}

local activeSessions: { [string]: StageSession } = {}

local function getOrCreateRootSandboxFolder(): Folder
	local root = Workspace:FindFirstChild(LabConfig.SANDBOX_FOLDER_NAME) :: Folder?
	if not root then
		root = Instance.new("Folder")
		root.Name = LabConfig.SANDBOX_FOLDER_NAME
		root.Parent = Workspace
	end
	return root
end

function SandboxStageManager.CreateSession(sessionId: string): StageSession
	SandboxStageManager.CleanupSession(sessionId)

	local root = getOrCreateRootSandboxFolder()
	local sessionFolder = Instance.new("Folder")
	sessionFolder.Name = "Session_" .. sessionId
	sessionFolder.Parent = root

	-- Stage Floor Platform
	local stage = Instance.new("Part")
	stage.Name = "StagePlatform"
	stage.Size = LabConfig.STAGE_SIZE
	stage.CFrame = CFrame.new(LabConfig.STAGE_POSITION)
	stage.Anchored = true
	stage.CanCollide = true
	stage.Material = Enum.Material.SmoothPlastic
	stage.Color = Color3.fromRGB(25, 28, 36)
	stage.TopSurface = Enum.SurfaceType.Smooth
	stage.BottomSurface = Enum.SurfaceType.Smooth
	stage.Parent = sessionFolder

	-- Grid Texture
	local texture = Instance.new("Texture")
	texture.Name = "GridTexture"
	texture.Texture = "rbxassetid://6372755229" -- Clean dev grid line pattern
	texture.Face = Enum.NormalId.Top
	texture.StudsPerTileU = 4
	texture.StudsPerTileV = 4
	texture.Transparency = 0.4
	texture.Parent = stage

	-- Studio Lighting Rig
	local lightingFolder = Instance.new("Folder")
	lightingFolder.Name = "StudioLighting"
	lightingFolder.Parent = sessionFolder

	local keyLightPart = Instance.new("Part")
	keyLightPart.Name = "KeyLightPart"
	keyLightPart.Size = Vector3.new(1, 1, 1)
	keyLightPart.CFrame = CFrame.new(LabConfig.STAGE_POSITION + Vector3.new(0, 25, 10))
	keyLightPart.Transparency = 1
	keyLightPart.Anchored = true
	keyLightPart.CanCollide = false
	keyLightPart.Parent = lightingFolder

	local keyLight = Instance.new("PointLight")
	keyLight.Name = "KeyLight"
	keyLight.Range = 60
	keyLight.Brightness = 2.2
	keyLight.Color = Color3.fromRGB(255, 250, 240)
	keyLight.Shadows = true
	keyLight.Parent = keyLightPart

	-- Containers
	local charactersFolder = Instance.new("Folder")
	charactersFolder.Name = "Characters"
	charactersFolder.Parent = sessionFolder

	local vfxFolder = Instance.new("Folder")
	vfxFolder.Name = "ActiveVFX"
	vfxFolder.Parent = sessionFolder

	local jointMarkersFolder = Instance.new("Folder")
	jointMarkersFolder.Name = "JointMarkers"
	jointMarkersFolder.Parent = sessionFolder

	-- Dummy Target (Isolated from combat and wave manager)
	local dummyModel = Instance.new("Model")
	dummyModel.Name = "AnimationLabDummyTarget"
	dummyModel:SetAttribute("IsAnimationLabDummy", true)
	dummyModel:SetAttribute("IsLabDummy", true)

	local dummyRoot = Instance.new("Part")
	dummyRoot.Name = "HumanoidRootPart"
	dummyRoot.Size = Vector3.new(2, 5, 2)
	dummyRoot.CFrame = CFrame.new(LabConfig.STAGE_POSITION + LabConfig.DUMMY_DEFAULT_OFFSET)
	dummyRoot.Anchored = true
	dummyRoot.CanCollide = false
	dummyRoot.Material = Enum.Material.Neon
	dummyRoot.Color = Color3.fromRGB(240, 80, 80)
	dummyRoot.Transparency = 0.3
	dummyRoot.Parent = dummyModel
	dummyModel.PrimaryPart = dummyRoot

	local dummyHighlight = Instance.new("Highlight")
	dummyHighlight.Name = "DummyHighlight"
	dummyHighlight.FillColor = Color3.fromRGB(255, 100, 100)
	dummyHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	dummyHighlight.FillTransparency = 0.5
	dummyHighlight.OutlineTransparency = 0.1
	dummyHighlight.Parent = dummyModel

	dummyModel.Parent = sessionFolder

	local session: StageSession = {
		sessionId = sessionId,
		container = sessionFolder,
		stagePlatform = stage,
		lightingFolder = lightingFolder,
		charactersFolder = charactersFolder,
		vfxFolder = vfxFolder,
		dummyTarget = dummyModel,
		jointMarkersFolder = jointMarkersFolder,
		activeModel = nil,
		activeScale = 1.0,
		isGridVisible = true,
		areJointMarkersVisible = true,
		isBoundingBoxVisible = false,
		areAccessoriesVisible = true,
		isDummyVisible = true,
	}

	activeSessions[sessionId] = session
	return session
end

function SandboxStageManager.GetSession(sessionId: string): StageSession?
	return activeSessions[sessionId]
end

function SandboxStageManager.SpawnModelOnStage(sessionId: string, templateModel: Model, scale: number?): Model
	local session = activeSessions[sessionId] or SandboxStageManager.CreateSession(sessionId)
	session.charactersFolder:ClearAllChildren()

	local clone = templateModel:Clone()
	clone.Name = templateModel.Name
	local actualScale = math.clamp(scale or 1.0, 0.5, 2.5)
	session.activeScale = actualScale

	local root = clone.PrimaryPart or clone:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root then
		root = clone:FindFirstChildWhichIsA("BasePart")
	end

	if root then
		local spawnCFrame = CFrame.new(LabConfig.STAGE_POSITION + Vector3.new(0, 3.5 * actualScale, 0))
		clone:PivotTo(spawnCFrame)
		root.Anchored = true
	end

	clone.Parent = session.charactersFolder
	session.activeModel = clone

	SandboxStageManager.RefreshJointMarkers(sessionId)
	return clone
end

function SandboxStageManager.RefreshJointMarkers(sessionId: string)
	local session = activeSessions[sessionId]
	if not session or not session.activeModel then
		return
	end

	session.jointMarkersFolder:ClearAllChildren()
	if not session.areJointMarkersVisible then
		return
	end

	local model = session.activeModel
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("Motor6D") and desc.Part1 then
			local marker = Instance.new("SphereHandleAdornment")
			marker.Name = "Marker_" .. desc.Name
			marker.Adornee = desc.Part1
			marker.Radius = 0.25 * session.activeScale
			marker.AlwaysOnTop = true
			marker.ZIndex = 5

			if desc.Name == "Neck" then
				marker.Color3 = Color3.fromRGB(60, 220, 240)
			elseif desc.Name:find("Shoulder") then
				marker.Color3 = Color3.fromRGB(245, 215, 60)
			elseif desc.Name:find("Hip") then
				marker.Color3 = Color3.fromRGB(80, 230, 110)
			elseif desc.Name:find("Weapon") then
				marker.Color3 = Color3.fromRGB(220, 90, 240)
			else
				marker.Color3 = Color3.fromRGB(255, 255, 255)
			end

			marker.Parent = session.jointMarkersFolder
		end
	end
end

function SandboxStageManager.SetDummyDistance(sessionId: string, distanceStuds: number)
	local session = activeSessions[sessionId]
	if not session or not session.dummyTarget or not session.dummyTarget.PrimaryPart then
		return
	end
	local clampedDist = math.clamp(distanceStuds, 5, 45)
	session.dummyTarget:PivotTo(CFrame.new(LabConfig.STAGE_POSITION + Vector3.new(0, 2.5, clampedDist)))
end

function SandboxStageManager.SetAccessoriesVisible(sessionId: string, visible: boolean)
	local session = activeSessions[sessionId]
	if not session or not session.activeModel then
		return
	end
	session.areAccessoriesVisible = visible

	for _, desc in ipairs(session.activeModel:GetDescendants()) do
		if desc:IsA("BasePart") then
			local name = desc.Name:lower()
			if name:find("hat") or name:find("sword") or name:find("blade") or name:find("scarf") or name:find("bead") or name:find("cape") then
				desc.Transparency = if visible then 0 else 1
			end
		end
	end
end

function SandboxStageManager.CleanupSession(sessionId: string)
	local session = activeSessions[sessionId]
	if session then
		if session.container and session.container.Parent then
			session.container:Destroy()
		end
		activeSessions[sessionId] = nil
	end
end

function SandboxStageManager.CleanupAll()
	for sessionId, _ in pairs(activeSessions) do
		SandboxStageManager.CleanupSession(sessionId)
	end
	local root = Workspace:FindFirstChild(LabConfig.SANDBOX_FOLDER_NAME)
	if root then
		root:Destroy()
	end
end

return table.freeze(SandboxStageManager)
