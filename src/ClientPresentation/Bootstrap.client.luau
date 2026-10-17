--!strict
-- src/ClientPresentation/Bootstrap.client.luau
-- Anime Limitless Tower Defense — Phase 6 Client Presentation Bootstrap
-- Listens to authoritative server combat events and dispatches cosmetic dash, poses, and VFX.
-- Client-safe: completely isolated from damage calculation and server game state.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local PresentationContract = require(SharedFolder:WaitForChild("PresentationContract")) :: any
local RigBinder = require(ReplicatedStorage:WaitForChild("Presentation"):WaitForChild("RigBinder")) :: any
local AnimationPlayback = require(ReplicatedStorage:WaitForChild("Presentation"):WaitForChild("AnimationPlayback")) :: any
local VFXDispatcher = require(ReplicatedStorage:WaitForChild("Presentation"):WaitForChild("VFXDispatcher")) :: any
local EnemyPresentation = require(ReplicatedStorage:WaitForChild("Presentation"):WaitForChild("EnemyPresentation")) :: any
local BossPresentation = require(ReplicatedStorage:WaitForChild("Presentation"):WaitForChild("BossPresentation")) :: any

-- Setup Feedback Port in PlayerGui
local feedbackPort = playerGui:FindFirstChild(PresentationContract.PORTS.PRESENTATION_FEEDBACK) :: BindableEvent?
if not feedbackPort then
	local be = Instance.new("BindableEvent")
	be.Name = PresentationContract.PORTS.PRESENTATION_FEEDBACK
	be.Parent = playerGui
	feedbackPort = be
end

-- Deduplication ledger for received attack IDs
local processedAttackIds: { [string]: number } = {}

-- Listen to Server TowerPresentationEvent
local presentationRemote = ReplicatedStorage:WaitForChild(PresentationContract.REMOTES.TOWER_PRESENTATION_EVENT, 10) :: RemoteEvent?
if presentationRemote and presentationRemote:IsA("RemoteEvent") then
	presentationRemote.OnClientEvent:Connect(function(payload: any)
		local ok, err = PresentationContract.ValidateAttackPayload(payload)
		if not ok or not payload then
			return
		end

		if processedAttackIds[payload.attackId] then
			return
		end
		processedAttackIds[payload.attackId] = os.clock()

		-- Find tower model in Workspace
		local towersFolder = Workspace:FindFirstChild("AnimeTowers") or Workspace:FindFirstChild("GrandLineMap")
		if not towersFolder then
			return
		end

		local towerModel: Model? = nil
		for _, child in ipairs(towersFolder:GetChildren()) do
			if child:IsA("Model") and (child:GetAttribute("UnitUid") == payload.unitUid or child.Name == payload.heroId) then
				towerModel = child
				break
			end
		end

		if not towerModel then
			return
		end

		-- Bind model to Presentation Rig
		local ctx, report = RigBinder.Bind(towerModel, payload.heroId)
		if not ctx then
			return
		end

		-- Play cosmetic melee attack animation
		AnimationPlayback.PlayAttack(ctx, function(cue: string)
			-- Fire client-local VFX
			VFXDispatcher.TriggerCue({
				sourceModel = towerModel,
				cueType = cue,
				heroId = payload.heroId,
				targetPosition = payload.targetPositionSnapshot,
			})

			-- If Impact cue, notify camera feedback sink
			if cue == "AttackImpact" and feedbackPort then
				feedbackPort:Fire(PresentationContract.FEEDBACK_ACTIONS.SHAKE, {
					intensity = 0.50,
					duration = 0.35,
				})
			end
		end)
	end)
end

-- Observe enemies for procedural locomotion presentation
local enemiesFolder = Workspace:WaitForChild("Enemies", 10) :: Folder?
if enemiesFolder then
	enemiesFolder.ChildAdded:Connect(function(child: Instance)
		if child:IsA("Model") then
			task.defer(function()
				local className = child.Name
				if string.find(className, "Boss") or string.find(className, "Kaido") then
					BossPresentation.TriggerBossSpawnPresentation(child, className)
				end
				EnemyPresentation.BindEnemy(child, className)
			end)
		end
	end)

	enemiesFolder.ChildRemoved:Connect(function(child: Instance)
		if child:IsA("Model") then
			EnemyPresentation.UnbindEnemy(child)
		end
	end)
end

-- Periodically prune stale processed attack IDs
task.spawn(function()
	while true do
		task.wait(10)
		local now = os.clock()
		for id, t in pairs(processedAttackIds) do
			if now - t > 30 then
				processedAttackIds[id] = nil
			end
		end
	end
end)
