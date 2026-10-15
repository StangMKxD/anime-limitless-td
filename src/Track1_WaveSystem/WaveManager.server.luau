--!strict
-- src/Track1_WaveSystem/WaveManager.server.luau
-- Author: Google Antigravity (agy teamwork-preview / stang-darkmatter)
-- Plan: PLAN-0001 (Core Wave & Scaling Enemies System)
-- Scope: Track 1 Core Wave Loop, Auto-Map Waypoints, Stat Scaling, Bosses, Movement, and Rewards

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

-- ============================================================================
-- 1. สร้างโฟลเดอร์และแมพเส้นทางเดินอัตโนมัติ (Auto-Bootstrap)
-- ============================================================================
local function ensureMapAndWaypoints(): (Folder, Folder)
	local waypointsFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.WAYPOINTS) :: Folder?
	if not waypointsFolder then
		waypointsFolder = Instance.new("Folder")
		waypointsFolder.Name = GameConfig.FOLDERS.WAYPOINTS
		waypointsFolder.Parent = Workspace

		-- พิกัดจุดเลี้ยวรูปตัว S สำหรับทางเดินซอมบี้ (Waypoints 1 ถึง 6)
		local coords = {
			Vector3.new(-60, 3, -40),
			Vector3.new(-20, 3, -40),
			Vector3.new(-20, 3, 20),
			Vector3.new(20, 3, 20),
			Vector3.new(20, 3, -30),
			Vector3.new(60, 3, -30),
		}

		for i, pos in ipairs(coords) do
			local wp = Instance.new("Part")
			wp.Name = tostring(i)
			wp.Size = Vector3.new(4, 1, 4)
			wp.Position = pos
			wp.Anchored = true
			wp.CanCollide = false
			wp.Material = Enum.Material.Neon
			wp.Color = (i == 1 and Color3.fromRGB(255, 80, 80))
				or (i == #coords and Color3.fromRGB(80, 200, 255))
				or Color3.fromRGB(255, 220, 100)
			wp.Transparency = 0.3
			wp.Parent = waypointsFolder

			-- สร้างพื้นถนนเชื่อมระหว่างจุด
			if i > 1 then
				local prevPos = coords[i - 1]
				local dist = (pos - prevPos).Magnitude
				local road = Instance.new("Part")
				road.Name = "PathSegment_" .. (i - 1)
				road.Size = Vector3.new(8, 0.5, dist + 8)
				road.CFrame = CFrame.lookAt((prevPos + pos) / 2 - Vector3.new(0, 2.5, 0), pos - Vector3.new(0, 2.5, 0))
				road.Anchored = true
				road.Material = Enum.Material.Slate
				road.Color = Color3.fromRGB(45, 45, 55)
				road.Parent = Workspace
			end
		end

		-- สร้างคริสตัลฐานทัพอนิเมะที่จุดสุดท้าย
		local baseCrystal = Instance.new("Part")
		baseCrystal.Name = "AnimeBaseCrystal"
		baseCrystal.Size = Vector3.new(6, 14, 6)
		baseCrystal.Position = coords[#coords] + Vector3.new(0, 5, 0)
		baseCrystal.Anchored = true
		baseCrystal.Material = Enum.Material.Neon
		baseCrystal.Color = Color3.fromRGB(0, 220, 255)
		baseCrystal.Parent = Workspace
	end

	local enemiesFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.ENEMIES) :: Folder?
	if not enemiesFolder then
		enemiesFolder = Instance.new("Folder")
		enemiesFolder.Name = GameConfig.FOLDERS.ENEMIES
		enemiesFolder.Parent = Workspace
	end

	return waypointsFolder, enemiesFolder
end

-- ============================================================================
-- 2. ตั้งค่าผู้เล่นเมื่อเข้าเกม (Leaderstats & Player Attributes)
-- ============================================================================
local function setupPlayer(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local cash = leaderstats:FindFirstChild("Cash") :: IntValue?
	if not cash then
		cash = Instance.new("IntValue")
		cash.Name = "Cash"
		cash.Value = GameConfig.INITIAL_PLAYER_STATS.CASH
		cash.Parent = leaderstats
	end

	local waveStat = leaderstats:FindFirstChild("Wave") :: IntValue?
	if not waveStat then
		waveStat = Instance.new("IntValue")
		waveStat.Name = "Wave"
		waveStat.Value = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE) :: number?) or 1
		waveStat.Parent = leaderstats
	end

	-- ตั้งค่า Attributes เริ่มต้นถ้ายังไม่มี
	if player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) == nil then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, GameConfig.INITIAL_PLAYER_STATS.DAMAGE_STAT)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT, GameConfig.INITIAL_PLAYER_STATS.RANGE_STAT)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, GameConfig.INITIAL_PLAYER_STATS.COOLDOWN_STAT)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, 1)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL, 1)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL, 1)
	end
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

-- ============================================================================
-- 3. ฟังก์ชันสร้างโมเดลซอมบี้อนิเมะพร้อมหลอดเลือด BillboardGui และการเคลื่อนที่
-- ============================================================================
local function spawnZombie(wave: number, isBoss: boolean, waypointsFolder: Folder, enemiesFolder: Folder)
	local hpMultiplier = math.pow(GameConfig.WAVE_SETTINGS.HP_GROWTH_RATE, wave - 1)
	local maxHp = math.floor(GameConfig.WAVE_SETTINGS.BASE_ZOMBIE_HP * hpMultiplier * (isBoss and 4 or 1))
	local speed = math.min(
		GameConfig.WAVE_SETTINGS.MAX_ZOMBIE_SPEED,
		GameConfig.WAVE_SETTINGS.BASE_ZOMBIE_SPEED + (wave * GameConfig.WAVE_SETTINGS.SPEED_INCREMENT_PER_WAVE)
	)
	if isBoss then
		speed = math.max(8, speed * 0.8)
	end

	local model = Instance.new("Model")
	model.Name = isBoss and ("CursedBoss_Wave" .. wave) or ("CursedZombie_Wave" .. wave)

	local scale = isBoss and 1.8 or 1.0
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2.5 * scale, 5 * scale, 1.5 * scale)
	root.Anchored = true
	root.CanCollide = false
	root.Material = Enum.Material.SmoothPlastic
	root.Color = isBoss and Color3.fromRGB(140, 20, 40) or Color3.fromRGB(60, 110, 75)
	root.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.8 * scale, 1.8 * scale, 1.8 * scale)
	head.Anchored = true
	head.CanCollide = false
	head.Color = isBoss and Color3.fromRGB(220, 40, 60) or Color3.fromRGB(90, 150, 100)
	head.Parent = model

	-- ออร่าคำสาปอนิเมะรอบตัวซอมบี้ (Anime Cursed Aura)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = isBoss and Color3.fromRGB(255, 0, 50) or Color3.fromRGB(80, 0, 140)
	highlight.OutlineColor = isBoss and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(170, 80, 255)
	highlight.FillTransparency = 0.55
	highlight.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = maxHp
	humanoid.Health = maxHp
	humanoid.Parent = model

	-- สร้างป้ายหลอดเลือดบนหัว (BillboardGui)
	local bb = Instance.new("BillboardGui")
	bb.Name = "HPBarGui"
	bb.Size = UDim2.new(0, 120, 0, 40)
	bb.StudsOffset = Vector3.new(0, 4 * scale, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = head
	bb.Parent = model

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 0.45, 0)
	bg.Position = UDim2.new(0, 0, 0.5, 0)
	bg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	bg.BorderSizePixel = 0
	bg.Parent = bb

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = isBoss and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 230, 110)
	fill.BorderSizePixel = 0
	fill.Parent = bg

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0.5, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.2
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = string.format("%s [%d/%d]", isBoss and "BOSS" or ("Lv." .. wave), maxHp, maxHp)
	label.Parent = bb

	model.PrimaryPart = root
	local wp1 = waypointsFolder:FindFirstChild("1") :: BasePart?
	local startPos = wp1 and wp1.Position or Vector3.new(0, 3, 0)
	root.Position = startPos
	head.Position = startPos + Vector3.new(0, 3.2 * scale, 0)
	model.Parent = enemiesFolder

	local rewardGiven = false
	local function awardPlayers()
		if rewardGiven then
			return
		end
		rewardGiven = true
		local reward = GameConfig.WAVE_SETTINGS.BASE_CASH_REWARD * wave * (isBoss and 3 or 1)
		for _, plr in ipairs(Players:GetPlayers()) do
			local ls = plr:FindFirstChild("leaderstats")
			local cashVal = ls and ls:FindFirstChild("Cash") :: IntValue?
			if cashVal then
				cashVal.Value += reward
			end
		end
	end

	humanoid.HealthChanged:Connect(function(newHp)
		local ratio = math.clamp(newHp / maxHp, 0, 1)
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		label.Text = string.format("%s [%d/%d]", isBoss and "BOSS" or ("Lv." .. wave), math.max(0, math.floor(newHp)), maxHp)
		if newHp <= 0 and not rewardGiven then
			awardPlayers()
			task.delay(0.1, function()
				if model and model.Parent then
					model:Destroy()
				end
			end)
		end
	end)

	-- เดินตาม Waypoints อย่างแม่นยำ (Waypoints 2 ถึง N)
	task.spawn(function()
		local totalWps = #waypointsFolder:GetChildren()
		for i = 2, totalWps do
			if not model.Parent or humanoid.Health <= 0 then
				return
			end
			local targetWp = waypointsFolder:FindFirstChild(tostring(i)) :: BasePart?
			if targetWp then
				local targetPos = targetWp.Position
				while model.Parent and humanoid.Health > 0 do
					local currentPos = root.Position
					local diff = targetPos - currentPos
					local dist = diff.Magnitude
					if dist <= 1.0 then
						break
					end
					local dt = task.wait(0.03)
					local step = math.min(dist, speed * dt)
					local nextPos = currentPos + diff.Unit * step
					root.CFrame = CFrame.lookAt(nextPos, targetPos)
					head.Position = nextPos + Vector3.new(0, 3.2 * scale, 0)
				end
			end
		end

		-- ถ้าเดินถึงจุดสุดท้ายแล้วยังไม่ตาย ให้หักเลือดฐานหลัก
		if model.Parent and humanoid.Health > 0 then
			local currentBaseHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) :: number?) or 1000
			local dmgToBase = isBoss and 150 or 50
			local nextBaseHp = math.max(0, currentBaseHp - dmgToBase)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, nextBaseHp)
			if nextBaseHp <= 0 then
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, true)
			end
			model:Destroy()
		end
	end)
end

-- ============================================================================
-- 4. ลูปควบคุมเวฟไร้ขีดจำกัด (Main Infinite Wave Loop)
-- ============================================================================
task.spawn(function()
	local waypointsFolder, enemiesFolder = ensureMapAndWaypoints()

	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, GameConfig.WAVE_SETTINGS.INITIAL_BASE_HP)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP, GameConfig.WAVE_SETTINGS.INITIAL_BASE_HP)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE, 1)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, 0)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, false)

	local currentWave = 1
	while true do
		-- เช็คกรณีเลือดฐานหมด ให้รีเซ็ตเริ่มเวฟ 1 ใหม่อัตโนมัติหลังพัก 5 วินาที
		if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == true then
			task.wait(5)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, GameConfig.WAVE_SETTINGS.INITIAL_BASE_HP)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, false)
			currentWave = 1
		end

		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE, currentWave)
		for _, plr in ipairs(Players:GetPlayers()) do
			local ls = plr:FindFirstChild("leaderstats")
			local wStat = ls and ls:FindFirstChild("Wave") :: IntValue?
			if wStat then
				wStat.Value = currentWave
			end
		end

		local zombieCount = 5 + (currentWave * 2)
		local hasBoss = (currentWave % 5 == 0)
		local totalToSpawn = zombieCount + (hasBoss and 1 or 0)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, totalToSpawn)

		-- ปล่อยซอมบี้ลูกกระจ๊อก
		for _ = 1, zombieCount do
			if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == true then
				break
			end
			spawnZombie(currentWave, false, waypointsFolder, enemiesFolder)
			task.wait(GameConfig.WAVE_SETTINGS.SPAWN_INTERVAL)
		end

		-- ปล่อยบอส (ถ้าเป็นเวฟ 5, 10, 15...)
		if hasBoss and not (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == true) then
			spawnZombie(currentWave, true, waypointsFolder, enemiesFolder)
		end

		-- รอจนกว่าศัตรูในเวฟจะตายหรือเข้าฐานจนหมด
		while #enemiesFolder:GetChildren() > 0 do
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, #enemiesFolder:GetChildren())
			if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == true then
				enemiesFolder:ClearAllChildren()
				break
			end
			task.wait(0.3)
		end

		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, 0)
		task.wait(GameConfig.WAVE_SETTINGS.INTERMISSION_TIME)
		currentWave += 1
	end
end)
