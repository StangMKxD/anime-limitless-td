--!strict
-- src/Track1_WaveSystem/WaveManager.server.luau
-- Phase 3: Grand Line Wave System with First-Summon Prep Window, R6 Walk Animation & Bounty Multiplier
-- Milestone 2 Production Code: Zero-Conflict Architecture

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(SharedFolder:WaitForChild("GameConfig")) :: any

local WAYPOINT_COORDS: { Vector3 } = {
	Vector3.new(-65, 3, -42),
	Vector3.new(-22, 3, -42),
	Vector3.new(-22, 3, 22),
	Vector3.new(22, 3, 22),
	Vector3.new(22, 3, -32),
	Vector3.new(65, 3, -32),
}

export type EnemySpec = {
	Name: string,
	BaseHP: number,
	Speed: number,
	Cash: number,
	Scale: number,
	Color: Color3,
}

local ENEMY_TYPES: { [string]: EnemySpec } = {
	ThrillerZombie = { Name = "Thriller Bark Zombie", BaseHP = 120, Speed = 10.5, Cash = 22, Scale = 1.0, Color = Color3.fromRGB(95, 135, 105) },
	GeneralZombie = { Name = "General Zombie", BaseHP = 420, Speed = 7.2, Cash = 55, Scale = 1.25, Color = Color3.fromRGB(75, 60, 110) },
	CommandGeneral = { Name = "Command General", BaseHP = 280, Speed = 14.5, Cash = 70, Scale = 1.1, Color = Color3.fromRGB(185, 45, 55) },
	YonkoKaido = { Name = "YONKO KAIDO [DRAGON EMPEROR]", BaseHP = 2600, Speed = 6.0, Cash = 550, Scale = 1.85, Color = Color3.fromRGB(45, 125, 220) },
}

-- ============================================================================
-- 1. เสกสมรภูมิ Marineford & Poneglyph Base อัตโนมัติ (Map Bootstrap)
-- ============================================================================
local function ensureMapAndWaypoints(): (Folder, Folder)
	local mapFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.MAP or "GrandLineMap") :: Folder?
	if not mapFolder then
		mapFolder = Instance.new("Folder")
		mapFolder.Name = GameConfig.FOLDERS.MAP or "GrandLineMap"
		mapFolder.Parent = Workspace

		local ground = Instance.new("Part")
		ground.Name = "MarinefordPlaza"
		ground.Size = Vector3.new(220, 2, 180)
		ground.Position = Vector3.new(0, 0, 0)
		ground.Anchored = true
		ground.Material = Enum.Material.Cobblestone
		ground.Color = Color3.fromRGB(48, 52, 62)
		ground.Parent = mapFolder

		local baseCore = Instance.new("Part")
		baseCore.Name = "PoneglyphBase"
		baseCore.Size = Vector3.new(14, 16, 14)
		baseCore.Position = WAYPOINT_COORDS[#WAYPOINT_COORDS] + Vector3.new(8, 6, 0)
		baseCore.Anchored = true
		baseCore.Material = Enum.Material.Neon
		baseCore.Color = Color3.fromRGB(55, 185, 255)
		baseCore.Parent = mapFolder
	end

	local wpFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.WAYPOINTS or "Waypoints") :: Folder?
	if not wpFolder then
		wpFolder = Instance.new("Folder")
		wpFolder.Name = GameConfig.FOLDERS.WAYPOINTS or "Waypoints"
		wpFolder.Parent = Workspace

		for idx, pos in ipairs(WAYPOINT_COORDS) do
			local wp = Instance.new("Part")
			wp.Name = "Waypoint_" .. tostring(idx)
			wp.Size = Vector3.new(4, 1, 4)
			wp.Position = pos
			wp.Anchored = true
			wp.CanCollide = false
			wp.Transparency = 0.5
			wp.Material = Enum.Material.Neon
			wp.Color = Color3.fromRGB(255, 200, 60)
			wp.Parent = wpFolder
		end
	end

	local enemiesFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.ENEMIES or "Enemies") :: Folder?
	if not enemiesFolder then
		enemiesFolder = Instance.new("Folder")
		enemiesFolder.Name = GameConfig.FOLDERS.ENEMIES or "Enemies"
		enemiesFolder.Parent = Workspace
	end

	local towersFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.TOWERS or "AnimeTowers") :: Folder?
	if not towersFolder then
		towersFolder = Instance.new("Folder")
		towersFolder.Name = GameConfig.FOLDERS.TOWERS or "AnimeTowers"
		towersFolder.Parent = Workspace
	end

	return mapFolder :: Folder, wpFolder :: Folder
end

-- ============================================================================
-- 2. แจกเงินรางวัลคูณด้วย BountyMultiplierStat ให้ผู้เล่นทุกคน
-- ============================================================================
local function awardCashToAllPlayers(baseAmount: number): ()
	for _, player in ipairs(Players:GetPlayers()) do
		local mult = (player:GetAttribute(GameConfig.PLAYER_ATTRS.BOUNTY_MULT) :: number?) or 1.0
		local finalCash = math.floor(baseAmount * mult)
		local ls = player:FindFirstChild("leaderstats")
		if not ls then
			local newLs = Instance.new("Folder")
			newLs.Name = "leaderstats"
			newLs.Parent = player
			ls = newLs
		end
		local cashVal = ls:FindFirstChild("Cash") :: IntValue?
		if not cashVal then
			cashVal = Instance.new("IntValue")
			cashVal.Name = "Cash"
			cashVal.Value = (GameConfig.INITIAL_PLAYER_STATS and GameConfig.INITIAL_PLAYER_STATS.CASH) or 500
			cashVal.Parent = ls
		end
		cashVal.Value += finalCash
	end
end

-- ============================================================================
-- 3. เสกซอมบี้โจรสลัด Thriller Bark & บอสจักรพรรดิ Kaido พร้อมระบบสโลว์หนวดขาว
-- ============================================================================
local function spawnEnemy(enemyKey: string, waveNum: number, enemiesFolder: Folder): ()
	local spec = ENEMY_TYPES[enemyKey] or ENEMY_TYPES.ThrillerZombie
	local hpMult = math.pow(1.18, waveNum - 1)
	local maxHp = math.floor(spec.BaseHP * hpMult)

	local model = Instance.new("Model")
	model.Name = spec.Name
	model:SetAttribute("HP", maxHp)
	model:SetAttribute("MaxHP", maxHp)
	model:SetAttribute("Speed", spec.Speed)
	model:SetAttribute("CashReward", spec.Cash)
	model:SetAttribute("SlowUntil", 0)

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2.2 * spec.Scale, 4.2 * spec.Scale, 1.4 * spec.Scale)
	root.Position = WAYPOINT_COORDS[1]
	root.Anchored = true
	root.CanCollide = false
	root.Material = Enum.Material.SmoothPlastic
	root.Color = spec.Color
	root.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.6 * spec.Scale, 1.6 * spec.Scale, 1.6 * spec.Scale)
	head.Position = root.Position + Vector3.new(0, 2.9 * spec.Scale, 0)
	head.Anchored = true
	head.CanCollide = false
	head.Color = Color3.fromRGB(215, 225, 205)
	head.Parent = model

	-- Boss Dragon Horn Aura for Kaido
	if enemyKey == "YonkoKaido" then
		local aura = Instance.new("Part")
		aura.Name = "KaidoDragonAura"
		aura.Shape = Enum.PartType.Ball
		aura.Size = Vector3.new(8, 8, 8)
		aura.Position = root.Position
		aura.Anchored = true
		aura.CanCollide = false
		aura.Material = Enum.Material.Neon
		aura.Color = Color3.fromRGB(175, 50, 255)
		aura.Transparency = 0.65
		aura.Parent = model
	end

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(140, 38)
	bb.StudsOffset = Vector3.new(0, 4.5 * spec.Scale, 0)
	bb.AlwaysOnTop = true
	bb.Parent = root

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.fromScale(1, 1)
	nameLbl.BackgroundTransparency = 0.35
	nameLbl.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
	nameLbl.TextColor3 = Color3.fromRGB(255, 235, 120)
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextScaled = true
	nameLbl.Text = string.format("%s [%d HP]", spec.Name, maxHp)
	nameLbl.Parent = bb

	model.PrimaryPart = root
	model.Parent = enemiesFolder

	local isDead = false

	model:GetAttributeChangedSignal("HP"):Connect(function()
		local currentHp = (model:GetAttribute("HP") :: number?) or 0
		nameLbl.Text = string.format("%s [%d/%d]", spec.Name, math.max(0, math.floor(currentHp)), maxHp)
		if currentHp <= 0 and not isDead and model.Parent then
			isDead = true
			awardCashToAllPlayers(spec.Cash)
			model:Destroy()
		end
	end)

	task.spawn(function()
		local stepTick = 0
		for i = 2, #WAYPOINT_COORDS do
			local targetPos = WAYPOINT_COORDS[i]
			while model.Parent and not isDead and ((model:GetAttribute("HP") :: number?) or 0) > 0 do
				local curPos = root.Position
				local diff = targetPos - curPos
				local dist = diff.Magnitude
				if dist <= 1.2 then
					break
				end
				local slowUntil = (model:GetAttribute("SlowUntil") :: number?) or 0
				local speedMult = (os.clock() < slowUntil) and 0.45 or 1.0
				local stepDist = math.min(dist, spec.Speed * speedMult * 0.05)
				local nextPos = curPos + diff.Unit * stepDist
				stepTick += 1
				local bobOffset = math.sin(stepTick * 0.6) * 0.35
				root.CFrame = CFrame.lookAt(nextPos + Vector3.new(0, bobOffset, 0), targetPos)
				head.CFrame = root.CFrame * CFrame.new(0, 2.9 * spec.Scale, 0)
				local kaidoAura = model:FindFirstChild("KaidoDragonAura") :: BasePart?
				if kaidoAura then
					kaidoAura.Position = root.Position
				end
				task.wait(0.05)
			end
		end

		if model.Parent and not isDead and ((model:GetAttribute("HP") :: number?) or 0) > 0 then
			isDead = true
			local curBaseHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) :: number?) or 1000
			local dmgToBase = (enemyKey == "YonkoKaido") and 180 or 35
			local newBaseHp = math.max(0, curBaseHp - dmgToBase)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, newBaseHp)
			if newBaseHp <= 0 then
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, true)
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, "MARINEFORD FALLEN - GAME OVER")
			end
			model:Destroy()
		end
	end)
end

-- ============================================================================
-- 4. ลูปควบคุมเวฟ + ช่วงเตรียมตัว 15 วิ + รางวัลการ์ด & เหรียญสุ่มทุกเวฟ
-- ============================================================================
local function startWaveLoop(): ()
	local _, _ = ensureMapAndWaypoints()
	local enemiesFolder = Workspace:WaitForChild(GameConfig.FOLDERS.ENEMIES or "Enemies") :: Folder
	local towersFolder = Workspace:WaitForChild(GameConfig.FOLDERS.TOWERS or "AnimeTowers") :: Folder

	while true do
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE, 1)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, 1000)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP, 1000)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, 0)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, false)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PENDING_CARD_DRAWS, 0)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN, 15)

		-- Phase 3 Preparation Phase: Wait up to 15s or until player summons & places their first tower
		for prepSec = 15, 1, -1 do
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN, prepSec)
			if #towersFolder:GetChildren() > 0 then
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN, 0)
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, "HERO DEPLOYED! STARTING WAVE 1...")
				task.wait(1.5)
				break
			end
			Workspace:SetAttribute(
				GameConfig.WORKSPACE_ATTRS.WAVE_STATUS,
				string.format("PREP PHASE (%ds): กดปุ่ม SUMMON กลางจอเพื่อสุ่มและวางตัวละคร!", prepSec)
			)
			task.wait(1)
		end
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN, 0)

		local wave = 1
		while not (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) :: boolean) do
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE, wave)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, string.format("WAVE %d IN PROGRESS", wave))

			-- Update player leaderstats Wave if present
			for _, player in ipairs(Players:GetPlayers()) do
				local ls = player:FindFirstChild("leaderstats")
				local waveVal = ls and ls:FindFirstChild("Wave") :: IntValue?
				if waveVal then
					waveVal.Value = wave
				end
			end

			local count = 6 + math.floor(wave * 2.5)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, count)

			for i = 1, count do
				if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) then
					break
				end
				local key = "ThrillerZombie"
				if wave % 5 == 0 and i == count then
					key = "YonkoKaido"
				elseif i % 5 == 0 then
					key = "GeneralZombie"
				elseif i % 3 == 0 then
					key = "CommandGeneral"
				end
				spawnEnemy(key, wave, enemiesFolder)
				task.wait(0.85)
			end

			while #enemiesFolder:GetChildren() > 0 and not (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) :: boolean) do
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, #enemiesFolder:GetChildren())
				task.wait(0.3)
			end
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, 0)

			if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) then
				break
			end

			-- Wave Cleared: Grant wave clear cash + trigger Roguelike Card Draft for all players
			awardCashToAllPlayers(90 + wave * 25)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, string.format("WAVE %d CLEARED! SELECT YOUR UPGRADE CARD!", wave))

			for _, player in ipairs(Players:GetPlayers()) do
				local pending = (player:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) :: number?) or 0
				player:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, pending + 1)
				local curTokens = (player:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
				player:SetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, curTokens + 1)
			end

			task.wait(4)
			wave += 1
		end

		-- Game Over Cleanup: Clear remaining enemies and wait before restart
		enemiesFolder:ClearAllChildren()
		task.wait(5)
	end
end

task.spawn(startWaveLoop)
