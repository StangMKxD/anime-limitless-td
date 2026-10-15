--!strict
-- src/Track1_WaveSystem/WaveManager.server.luau
-- Author: Google Antigravity (agy teamwork-preview / stang-darkmatter)
-- Plan: PLAN-0001 (Phase 2: Grand Line Wave System, R6 Thriller Bark Zombies & Wave Card Trigger)
-- Scope: Track 1 Grand Line Map, R6 Pirate Enemies, Yonko Kaido Boss, Infinite Stat Scaling, and Card Draw Signals

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

-- ============================================================================
-- 1. เสกสมรภูมิ Marineford & Poneglyph Base อัตโนมัติ (Grand Line Map Bootstrap)
-- ============================================================================
local function ensureMapAndWaypoints(): (Folder, Folder)
	local waypointsFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.WAYPOINTS) :: Folder?
	if not waypointsFolder then
		waypointsFolder = Instance.new("Folder")
		waypointsFolder.Name = GameConfig.FOLDERS.WAYPOINTS
		waypointsFolder.Parent = Workspace

		local coords = {
			Vector3.new(-65, 3, -42),
			Vector3.new(-22, 3, -42),
			Vector3.new(-22, 3, 22),
			Vector3.new(22, 3, 22),
			Vector3.new(22, 3, -32),
			Vector3.new(65, 3, -32),
		}

		for i, pos in ipairs(coords) do
			local wp = Instance.new("Part")
			wp.Name = tostring(i)
			wp.Size = Vector3.new(4, 1, 4)
			wp.Position = pos
			wp.Anchored = true
			wp.CanCollide = false
			wp.Material = Enum.Material.Neon
			wp.Color = (i == 1 and Color3.fromRGB(255, 50, 80))
				or (i == #coords and Color3.fromRGB(255, 215, 0))
				or Color3.fromRGB(0, 210, 255)
			wp.Transparency = 0.25
			wp.Parent = waypointsFolder

			if i > 1 then
				local prevPos = coords[i - 1]
				local dist = (pos - prevPos).Magnitude
				local mid = (prevPos + pos) / 2 - Vector3.new(0, 2.5, 0)

				-- ถนนหินสมรภูมิแกรนด์ไลน์
				local road = Instance.new("Part")
				road.Name = "GrandLineRoad_" .. (i - 1)
				road.Size = Vector3.new(10, 0.6, dist + 10)
				road.CFrame = CFrame.lookAt(mid, pos - Vector3.new(0, 2.5, 0))
				road.Anchored = true
				road.Material = Enum.Material.Cobblestone
				road.Color = Color3.fromRGB(40, 44, 58)
				road.Parent = Workspace

				-- ขอบถนนเรืองแสงสีทองโจรสลัด
				local border = Instance.new("Part")
				border.Name = "RoadGoldTrim_" .. (i - 1)
				border.Size = Vector3.new(11.2, 0.3, dist + 10.6)
				border.CFrame = road.CFrame * CFrame.new(0, -0.1, 0)
				border.Anchored = true
				border.Material = Enum.Material.Neon
				border.Color = Color3.fromRGB(255, 190, 40)
				border.Transparency = 0.4
				border.Parent = Workspace
			end
		end

		-- ซุ้มประตู Thriller Bark Dark Gate ที่จุดเกิดซอมบี้
		local gateLeft = Instance.new("Part")
		gateLeft.Name = "DarkGatePillarL"
		gateLeft.Size = Vector3.new(3, 18, 3)
		gateLeft.Position = coords[1] + Vector3.new(-6, 6, 0)
		gateLeft.Anchored = true
		gateLeft.Material = Enum.Material.Basalt
		gateLeft.Color = Color3.fromRGB(30, 15, 45)
		gateLeft.Parent = Workspace

		local gateRight = gateLeft:Clone()
		gateRight.Name = "DarkGatePillarR"
		gateRight.Position = coords[1] + Vector3.new(6, 6, 0)
		gateRight.Parent = Workspace

		local gatePortal = Instance.new("Part")
		gatePortal.Name = "DarkPortalVortex"
		gatePortal.Shape = Enum.PartType.Cylinder
		gatePortal.Size = Vector3.new(1, 14, 14)
		gatePortal.CFrame = CFrame.new(coords[1] + Vector3.new(0, 6, 0)) * CFrame.Angles(0, 0, math.rad(90))
		gatePortal.Anchored = true
		gatePortal.CanCollide = false
		gatePortal.Material = Enum.Material.Neon
		gatePortal.Color = Color3.fromRGB(160, 30, 255)
		gatePortal.Transparency = 0.35
		gatePortal.Parent = Workspace

		-- ฐานหลัก Road Poneglyph & Thousand Sunny Core ที่จุดที่ 6
		local poneglyph = Instance.new("Part")
		poneglyph.Name = "AnimeBaseCrystal"
		poneglyph.Size = Vector3.new(9, 14, 9)
		poneglyph.Position = coords[#coords] + Vector3.new(0, 4.5, 0)
		poneglyph.Anchored = true
		poneglyph.Material = Enum.Material.Slate
		poneglyph.Color = Color3.fromRGB(180, 25, 40)
		poneglyph.Parent = Workspace

		local sunnyHalo = Instance.new("Part")
		sunnyHalo.Name = "SunnyGoldenCore"
		sunnyHalo.Shape = Enum.PartType.Ball
		sunnyHalo.Size = Vector3.new(7, 7, 7)
		sunnyHalo.Position = coords[#coords] + Vector3.new(0, 15, 0)
		sunnyHalo.Anchored = true
		sunnyHalo.CanCollide = false
		sunnyHalo.Material = Enum.Material.Neon
		sunnyHalo.Color = Color3.fromRGB(255, 215, 50)
		sunnyHalo.Parent = Workspace
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
-- 2. ตั้งค่าผู้เล่นและแจกการ์ดเริ่มต้น (Player Setup & Initial Card Draw)
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

	if player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) == nil then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, GameConfig.INITIAL_PLAYER_STATS.DAMAGE_STAT)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT, GameConfig.INITIAL_PLAYER_STATS.RANGE_STAT)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, GameConfig.INITIAL_PLAYER_STATS.COOLDOWN_STAT)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT, GameConfig.INITIAL_PLAYER_STATS.SPLASH_STAT)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE, GameConfig.INITIAL_PLAYER_STATS.CRIT_CHANCE)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, 1)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL, 1)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL, 1)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, GameConfig.INITIAL_PLAYER_STATS.INITIAL_CARD_DRAWS)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL, 0)
	end
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

-- ============================================================================
-- 3. สร้างหุ่นโครงกระดูก R6 ซอมบี้โจรสลัด Thriller Bark & บอสจักรพรรดิ Kaido
-- ============================================================================
local function spawnZombie(wave: number, isBoss: boolean, waypointsFolder: Folder, enemiesFolder: Folder)
	local hpMultiplier = math.pow(GameConfig.WAVE_SETTINGS.HP_GROWTH_RATE, wave - 1)
	local maxHp = math.floor(GameConfig.WAVE_SETTINGS.BASE_ZOMBIE_HP * hpMultiplier * (isBoss and 5 or 1))
	local speed = math.min(
		GameConfig.WAVE_SETTINGS.MAX_ZOMBIE_SPEED,
		GameConfig.WAVE_SETTINGS.BASE_ZOMBIE_SPEED + (wave * GameConfig.WAVE_SETTINGS.SPEED_INCREMENT_PER_WAVE)
	)
	if isBoss then
		speed = math.max(8.5, speed * 0.82)
	end

	local scale = isBoss and 2.1 or 1.0
	local model = Instance.new("Model")
	model.Name = isBoss and ("YonkoKaidoBoss_W" .. wave) or ("ThrillerPirateZombie_W" .. wave)

	local function makeLimb(name: string, size: Vector3, color: Color3, mat: Enum.Material?): Part
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size * scale
		p.Color = color
		p.Material = mat or Enum.Material.SmoothPlastic
		p.Anchored = true
		p.CanCollide = false
		p.Parent = model
		return p
	end

	local skinColor = isBoss and Color3.fromRGB(195, 140, 115) or Color3.fromRGB(95, 145, 110)
	local coatColor = isBoss and Color3.fromRGB(95, 20, 120) or Color3.fromRGB(45, 50, 70)
	local pantsColor = isBoss and Color3.fromRGB(30, 20, 35) or Color3.fromRGB(35, 35, 45)

	local root = makeLimb("HumanoidRootPart", Vector3.new(2, 2, 1), coatColor)
	root.Transparency = 1
	local torso = makeLimb("Torso", Vector3.new(2, 2, 1), coatColor)
	local head = makeLimb("Head", Vector3.new(1.25, 1.25, 1.25), skinColor)
	local leftArm = makeLimb("LeftArm", Vector3.new(1, 2, 1), skinColor)
	local rightArm = makeLimb("RightArm", Vector3.new(1, 2, 1), skinColor)
	local leftLeg = makeLimb("LeftLeg", Vector3.new(1, 2, 1), pantsColor)
	local rightLeg = makeLimb("RightLeg", Vector3.new(1, 2, 1), pantsColor)

	-- พร็อพพิเศษ: ถ้าเป็นบอสจักรพรรดิไคโด มีเขามังกรคู่ + กระบองยักษ์อาบฮาคิราชันย์
	local hornL: Part?, hornR: Part?, weaponPart: Part?
	if isBoss then
		hornL = makeLimb("DragonHornL", Vector3.new(0.35, 1.6, 0.35), Color3.fromRGB(255, 210, 60), Enum.Material.Neon)
		hornR = makeLimb("DragonHornR", Vector3.new(0.35, 1.6, 0.35), Color3.fromRGB(255, 210, 60), Enum.Material.Neon)
		weaponPart = makeLimb("HakiKanabo", Vector3.new(0.9, 4.2, 0.9), Color3.fromRGB(255, 20, 60), Enum.Material.Neon)
	else
		-- ซอมบี้โจรสลัดใส่ผ้าโพกหัวแดง + ถือดาบโจรสลัด
		weaponPart = makeLimb("CutlassBlade", Vector3.new(0.25, 2.6, 0.5), Color3.fromRGB(190, 220, 255), Enum.Material.Neon)
	end

	local highlight = Instance.new("Highlight")
	highlight.FillColor = isBoss and Color3.fromRGB(255, 20, 50) or Color3.fromRGB(90, 20, 160)
	highlight.OutlineColor = isBoss and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(180, 90, 255)
	highlight.FillTransparency = 0.5
	highlight.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = maxHp
	humanoid.Health = maxHp
	humanoid.Parent = model

	local bb = Instance.new("BillboardGui")
	bb.Name = "HPBarGui"
	bb.Size = UDim2.new(0, isBoss and 170 or 125, 0, 44)
	bb.StudsOffset = Vector3.new(0, 3.2 * scale, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = head
	bb.Parent = model

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 0.45, 0)
	bg.Position = UDim2.new(0, 0, 0.5, 0)
	bg.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	bg.BorderSizePixel = 0
	bg.Parent = bb

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = isBoss and Color3.fromRGB(255, 45, 70) or Color3.fromRGB(60, 235, 115)
	fill.BorderSizePixel = 0
	fill.Parent = bg

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0.5, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = isBoss and Color3.fromRGB(255, 220, 60) or Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	local titlePrefix = isBoss and "YONKO KAIDO" or ("Thriller Zombie Lv." .. wave)
	label.Text = string.format("%s [%d/%d]", titlePrefix, maxHp, maxHp)
	label.Parent = bb

	-- ฟังก์ชันจัดวางชิ้นส่วน R6 พร้อมแอนิเมชันเดินแกว่งแขนขา
	local function updateR6Pose(centerCF: CFrame, walkCycle: number)
		local swing = math.sin(walkCycle) * 0.55
		root.CFrame = centerCF
		torso.CFrame = centerCF
		head.CFrame = centerCF * CFrame.new(0, 1.65 * scale, 0)
		leftArm.CFrame = centerCF * CFrame.new(-1.5 * scale, 0, 0) * CFrame.Angles(swing, 0, 0)
		rightArm.CFrame = centerCF * CFrame.new(1.5 * scale, 0, 0) * CFrame.Angles(-swing + 0.5, 0, 0)
		leftLeg.CFrame = centerCF * CFrame.new(-0.5 * scale, -2.0 * scale, 0) * CFrame.Angles(-swing, 0, 0)
		rightLeg.CFrame = centerCF * CFrame.new(0.5 * scale, -2.0 * scale, 0) * CFrame.Angles(swing, 0, 0)

		if isBoss and hornL and hornR then
			hornL.CFrame = head.CFrame * CFrame.new(-0.5 * scale, 0.8 * scale, 0) * CFrame.Angles(0, 0, math.rad(25))
			hornR.CFrame = head.CFrame * CFrame.new(0.5 * scale, 0.8 * scale, 0) * CFrame.Angles(0, 0, math.rad(-25))
		end
		if weaponPart then
			weaponPart.CFrame = rightArm.CFrame * CFrame.new(0, -0.8 * scale, -1.2 * scale) * CFrame.Angles(math.rad(75), 0, 0)
		end
	end

	model.PrimaryPart = root
	local wp1 = waypointsFolder:FindFirstChild("1") :: BasePart?
	local startPos = wp1 and wp1.Position or Vector3.new(0, 3, 0)
	updateR6Pose(CFrame.new(startPos), 0)
	model.Parent = enemiesFolder

	local rewardGiven = false
	local function awardPlayers()
		if rewardGiven then
			return
		end
		rewardGiven = true
		local reward = GameConfig.WAVE_SETTINGS.BASE_CASH_REWARD * wave * (isBoss and 4 or 1)
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
		label.Text = string.format("%s [%d/%d]", titlePrefix, math.max(0, math.floor(newHp)), maxHp)
		if newHp <= 0 and not rewardGiven then
			awardPlayers()
			task.delay(0.08, function()
				if model and model.Parent then
					model:Destroy()
				end
			end)
		end
	end)

	task.spawn(function()
		local walkPhase = 0
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
					walkPhase += dt * speed * 1.4
					local step = math.min(dist, speed * dt)
					local nextPos = currentPos + diff.Unit * step
					updateR6Pose(CFrame.lookAt(nextPos, targetPos), walkPhase)
				end
			end
		end

		if model.Parent and humanoid.Health > 0 then
			local currentBaseHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) :: number?) or 1500
			local dmgToBase = isBoss and 250 or 60
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
-- 4. ลูปควบคุมเวฟไร้ขีดจำกัด + แจกการ์ดอัปเกรดทุกเวฟ! (Main Wave Loop)
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
		if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == true then
			task.wait(5)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, GameConfig.WAVE_SETTINGS.INITIAL_BASE_HP)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, false)
			currentWave = 1
		end

		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE, currentWave)

		-- แจกการ์ดอัปเกรดให้ผู้เล่นทุกคนทุกครั้งที่ขึ้นเวฟใหม่ (ตั้งแต่เวฟ 2 เป็นต้นไป เวฟ 1 แจกตอนเข้าเกมแล้ว)
		for _, plr in ipairs(Players:GetPlayers()) do
			local ls = plr:FindFirstChild("leaderstats")
			local wStat = ls and ls:FindFirstChild("Wave") :: IntValue?
			if wStat then
				wStat.Value = currentWave
			end
			if currentWave > 1 then
				local currentDraws = ((plr:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) or 0) :: any) :: number
				local bonusDraws = (currentWave % 5 == 0) and 2 or 1 -- เวฟบอสแจกการ์ด 2 ใบ!
				plr:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, currentDraws + bonusDraws)
			end
		end

		local zombieCount = 5 + (currentWave * 2)
		local hasBoss = (currentWave % 5 == 0)
		local totalToSpawn = zombieCount + (hasBoss and 1 or 0)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, totalToSpawn)

		for _ = 1, zombieCount do
			if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == true then
				break
			end
			spawnZombie(currentWave, false, waypointsFolder, enemiesFolder)
			task.wait(GameConfig.WAVE_SETTINGS.SPAWN_INTERVAL)
		end

		if hasBoss and not (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == true) then
			spawnZombie(currentWave, true, waypointsFolder, enemiesFolder)
		end

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
