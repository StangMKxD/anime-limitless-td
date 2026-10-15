# ไฟล์ที่ 1: คู่มือตั้งค่า Git Worktree + Rojo + MCP และสเปกงานส่วนที่ 1 (Grand Line Wave System, R6 Thriller Bark Zombies & Wave Card Trigger)

เอกสารฉบับนี้อัปเดตใหม่ตามความต้องการล่าสุด: **เปลี่ยนระบบอัปเกรดเป็น "การ์ดสุ่มอัปเกรดเด้งขึ้นมาทุกเวฟ (Roguelike Wave Card Draft)"** และยกระดับความอลังการเป็นธีม **One Piece (Grand Line / Marineford Defense)** โดยในส่วนที่ 1 นี้ สคริปต์จะปั้นฉากสมรภูมิมารีนฟอร์ด ปั้นหุ่นโครงกระดูก **R6 ซอมบี้ Thriller Bark & บอสจักรพรรดิ (Kaido / Blackbeard)** และส่งสัญญาณแจก **การ์ดอัปเกรด (`PendingCardDraws`)** ให้ผู้เล่นทุกครั้งที่ขึ้นเวฟใหม่!

---

## 1. ภาพรวมสถาปัตยกรรม: ทำ 3 งานพร้อมกันใน Repo เดียวแบบไม่ชนกัน (Zero Merge Conflict)

| ชื่องาน (Track) | ชื่อ Git Branch | โฟลเดอร์ Git Worktree | โฟลเดอร์โค้ดที่รับผิดชอบ (ห้ามข้ามเขต) | พอร์ต Rojo สำหรับเทสแยก |
| :--- | :--- | :--- | :--- | :--- |
| **ฐานข้อมูลกลาง (Base Setup)** | `main` | `./anime-limitless-td` | `default.project.json`, `src/Shared/GameConfig.luau` | `34872` (ตอนรวมงาน) |
| **งานที่ 1: เวฟซอมบี้ R6 & แจกการ์ดทุกเวฟ** | `feat/track1-wave` | `../altd-wt1-wave` | `src/Track1_WaveSystem/` เท่านั้น | `34871` |
| **งานที่ 2: โมเดล 6 ตำนาน One Piece & VFX** | `feat/track2-towers` | `../altd-wt2-towers` | `src/Track2_TowerSystem/` เท่านั้น | `34872` |
| **งานที่ 3: ระบบสุ่มการ์ดอัปเกรดทุกเวฟ (Card UI)** | `feat/track3-ui` | `../altd-wt3-ui` | `src/Track3_UISystem/` และ `src/Track3_UpgradeServer/` | `34873` |

---

## 2. อัปเดตไฟล์สัญญากลาง `src/Shared/GameConfig.luau` (รองรับระบบการ์ดทุกเวฟ + One Piece Stats)

ให้วางโค้ดนี้ใน `src/Shared/GameConfig.luau` บน Branch หลักเพื่อเปิดใช้งานระบบการ์ดสุ่มอัปเกรดทุกเวฟและสเตตัสฮาคิ/ผลปีศาจ:

```luau
-- src/Shared/GameConfig.luau
-- สัญญาข้อมูลกลาง (Data Contract) สำหรับ One Piece Limitless TD (Wave Card Edition)
local GameConfig = {}

-- ชื่อ Attribute บน Workspace
GameConfig.WORKSPACE_ATTRS = {
	CURRENT_WAVE = "CurrentWave",
	BASE_HP = "BaseHP",
	MAX_BASE_HP = "MaxBaseHP",
	ZOMBIES_REMAINING = "ZombiesRemaining",
	GAME_OVER = "GameOver",
}

-- ชื่อ Attribute บนตัว Player (อัปเกรดผ่านการ์ดทุกเวฟได้ไร้ขีดจำกัด)
GameConfig.PLAYER_ATTRS = {
	DAMAGE_STAT = "DamageStat",
	RANGE_STAT = "RangeStat",
	COOLDOWN_STAT = "CooldownStat",
	SPLASH_STAT = "SplashRadiusStat",
	CRIT_CHANCE = "CritChanceStat",
	DAMAGE_LEVEL = "DamageLevel",
	RANGE_LEVEL = "RangeLevel",
	SPEED_LEVEL = "SpeedLevel",
	PENDING_CARD_DRAWS = "PendingCardDraws", -- จำนวนสิทธิ์เปิดการ์ดที่รอให้ผู้เล่นเลือก!
	CARDS_PICKED_TOTAL = "CardsPickedTotal",
}

-- ค่าเริ่มต้นของผู้เล่น
GameConfig.INITIAL_PLAYER_STATS = {
	CASH = 300, -- ค่าหัว (Bounty Belly) สำหรับรีโรลการ์ดหรือซื้อการ์ดพิเศษ
	DAMAGE_STAT = 45,
	RANGE_STAT = 36,
	COOLDOWN_STAT = 0.95,
	SPLASH_STAT = 6,
	CRIT_CHANCE = 15, -- โอกาสติดคริติคอลฮาคิราชันย์ (%)
	MIN_COOLDOWN = 0.12,
	INITIAL_CARD_DRAWS = 1, -- เข้าเกมมาเวฟ 1 ได้เปิดการ์ดฟรีทันที 1 ใบ!
}

-- ค่าเริ่มต้นของฐานและสูตรคูณเวฟซอมบี้ไร้ขีดจำกัด
GameConfig.WAVE_SETTINGS = {
	INITIAL_BASE_HP = 1500,
	BASE_ZOMBIE_HP = 110,
	HP_GROWTH_RATE = 1.30, -- เลือดซอมบี้คูณ 1.30 เท่าทุกเวฟ
	BASE_ZOMBIE_SPEED = 10.5,
	SPEED_INCREMENT_PER_WAVE = 0.25,
	MAX_ZOMBIE_SPEED = 26,
	BASE_CASH_REWARD = 35,
	SPAWN_INTERVAL = 0.85,
	INTERMISSION_TIME = 5,
	EXTRA_CARD_BASE_COST = 150, -- ราคาใช้เงิน Bounty ซื้อสิทธิ์เปิดการ์ดเพิ่ม
}

-- ชื่อโฟลเดอร์และ RemoteEvent มาตรฐาน
GameConfig.FOLDERS = {
	WAYPOINTS = "Waypoints",
	ENEMIES = "ActiveEnemies",
	TOWERS = "AnimeTowers",
}

GameConfig.REMOTES = {
	UPGRADE_REQUEST = "UpgradeStatRequest", -- รับรหัสการ์ดที่ผู้เล่นคลิกเลือก หรือคำสั่งซื้อการ์ดเพิ่ม
}

return GameConfig
```

---

## 3. Spec & Scope ของงานส่วนที่ 1 (`PLAN-0001`: Grand Line Wave & R6 Enemy System)

### ฟีเจอร์สุดอลังการที่ต้องมีใน `src/Track1_WaveSystem/WaveManager.server.luau`
1. **Grand Line / Marineford Map Bootstrap**:
   * สร้างทางเดินหินแกรนิตขอบทองเรืองแสงฮาคิ พิกัดรูปตัว S (`Waypoints 1` ถึง `6`)
   * สร้างซุ้มประตูมิติทมิฬ **Thriller Bark Gate** ที่จุดเกิด (`Waypoint 1`)
   * สร้างฐานทัพหลัก **Road Poneglyph & Thousand Sunny Core** เรืองแสงสีทอง-ฟ้าครามขนาดยักษ์ที่จุดสุดท้าย (`Waypoint 6`)
2. **Wave Card Trigger (แจกการ์ดอัปเกรดทุกเวฟ!)**:
   * เมื่อผู้เล่นเข้าเกมครั้งแรก จะได้รับ `PendingCardDraws = 1` เพื่อเปิดการ์ดใบแรกทันที
   * **ทุกครั้งที่เริ่มเวฟใหม่ (Wave 2, 3, 4... ไปเรื่อยๆ ไม่จำกัด)** สคริปต์จะบวกค่า `PendingCardDraws += 1` ให้ผู้เล่นทุกคนในเซิร์ฟเวอร์ (และถ้าเป็นเวฟบอสทุกๆ 5 เวฟ จะแจกการ์ดพิเศษเพิ่มเป็น `+2` ใบทันที!)
3. **Procedural R6 One Piece Enemies & Yonko Bosses**:
   * ปั้นซอมบี้โครงกระดูก **R6 ครบ 6 ชิ้น** (`Head`, `Torso`, `LeftArm`, `RightArm`, `LeftLeg`, `RightLeg` + ผ้าพันคอโจรสลัด + ดาบโจรสลัด + แอนิเมชันแกว่งแขนขาเวลาเดิน!)
   * ทุกๆ 5 เวฟ (Wave 5, 10, 15...) เสกบอสระดับจักรพรรดิ **Yonko Kaido / Blackbeard Boss** ตัวใหญ่ยักษ์ 2.2 เท่า มีเขามังกร/ผ้าคลุมจักรพรรดิ ออร่าสายฟ้าฮาคิราชันย์สีแดง-ดำ และเลือดคูณ 5 เท่า!

---

## 4. โค้ดตัวเต็ม `src/Track1_WaveSystem/WaveManager.server.luau`

คัดลอกโค้ดด้านล่างไปวางใน `src/Track1_WaveSystem/WaveManager.server.luau` ได้เลย:

```luau
-- src/Track1_WaveSystem/WaveManager.server.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

-- 1. เสกสมรภูมิ Marineford & Poneglyph Base อัตโนมัติ
local function ensureMapAndWaypoints()
	local waypointsFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.WAYPOINTS)
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

	local enemiesFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.ENEMIES)
	if not enemiesFolder then
		enemiesFolder = Instance.new("Folder")
		enemiesFolder.Name = GameConfig.FOLDERS.ENEMIES
		enemiesFolder.Parent = Workspace
	end

	return waypointsFolder, enemiesFolder
end

-- 2. ตั้งค่าผู้เล่นและแจกการ์ดเริ่มต้น
local function setupPlayer(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local cash = leaderstats:FindFirstChild("Cash")
	if not cash then
		cash = Instance.new("IntValue")
		cash.Name = "Cash"
		cash.Value = GameConfig.INITIAL_PLAYER_STATS.CASH
		cash.Parent = leaderstats
	end

	local waveStat = leaderstats:FindFirstChild("Wave")
	if not waveStat then
		waveStat = Instance.new("IntValue")
		waveStat.Name = "Wave"
		waveStat.Value = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE) or 1
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

-- 3. สร้างหุ่นโครงกระดูก R6 ซอมบี้โจรสลัด Thriller Bark & บอสจักรพรรดิ Kaido
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

	local function makeLimb(name: string, size: Vector3, color: Color3, mat: Enum.Material?)
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
	local hornL, hornR, weaponPart
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
	local wp1 = waypointsFolder:FindFirstChild("1")
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
			local cashVal = ls and ls:FindFirstChild("Cash")
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
			local targetWp = waypointsFolder:FindFirstChild(tostring(i))
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
			local currentBaseHp = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) or 1500
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

-- 4. ลูปควบคุมเวฟไร้ขีดจำกัด + แจกการ์ดอัปเกรดทุกเวฟ!
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
			local wStat = ls and ls:FindFirstChild("Wave")
			if wStat then
				wStat.Value = currentWave
			end
			if currentWave > 1 then
				local currentDraws = (plr:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) or 0) :: number
				local bonusDraws = (currentWave % 5 == 0) and 2 or 1 -- เวฟบอสแจกการ์ด 2 ใบ!
				plr:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, currentDraws + bonusDraws)
			end
		end

		local zombieCount = 5 + (currentWave * 2)
		local hasBoss = (currentWave % 5 == 0)
		local totalToSpawn = zombieCount + (hasBoss and 1 or 0)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, totalToSpawn)

		for i = 1, zombieCount do
			if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == true then
				break
			end
			spawnZombie(currentWave, false, waypointsFolder, enemiesFolder)
			task.wait(GameConfig.WAVE_SETTINGS.SPAWN_INTERVAL)
		end

		if hasBoss and not Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) then
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
```

---

## 5. ตารางตรวจรับงานส่วนที่ 1 (UAT Track 1 - One Piece Wave & Card Trigger)

| รหัส UAT | รายการทดสอบ (Test Case) | วิธีทดสอบใน Roblox Studio | ผลลัพธ์ที่ต้องเห็น (Expected Result) | สถานะ |
| :--- | :--- | :--- | :--- | :--- |
| **UAT-1.1** | สมรภูมิแกรนด์ไลน์และฐาน Road Poneglyph | กด Play ในแมพเปล่า | มีถนนหินขอบทอง ซุ้มประตูมิติสีม่วงที่จุดที่ 1 และแท่นศิลาสีแดง `Road Poneglyph` พร้อมดวงอาทิตย์สีทองที่จุดที่ 6 | [ ] ผ่าน |
| **UAT-1.2** | โมเดลซอมบี้โครงกระดูก R6 เดินแกว่งแขนขา | สังเกตซอมบี้ที่เดินออกจากซุ้มประตูมิติ | ซอมบี้มีหัว ลำตัว แขน 2 ข้าง ขา 2 ข้าง ถือดาบโจรสลัด และขยับแขนขาขณะเดินตามทางเลี้ยว | [ ] ผ่าน |
| **UAT-1.3** | การแจกการ์ดอัปเกรดอัตโนมัติทุกเวฟ (`PendingCardDraws`) | ดูค่า Attribute `PendingCardDraws` ของผู้เล่นเมื่อเริ่มเกม และเมื่อจบเวฟ 1 เข้าสู่เวฟ 2 | เริ่มเกมมี `PendingCardDraws = 1` และทุกครั้งที่ขึ้นเวฟใหม่ ค่า `PendingCardDraws` จะบวกเพิ่ม `+1` อัตโนมัติ (เวฟบอสบวก `+2`) | [ ] ผ่าน |
| **UAT-1.4** | บอสจักรพรรดิไคโด (`YONKO KAIDO`) ในเวฟ 5 | เล่นถึงเวฟ 5 | มีบอสตัวใหญ่ยักษ์ 2.1 เท่า มีเขามังกรสีทองคู่บนหัว ถือกระบองยักษ์สีแดงอาบฮาคิราชันย์ เลือดสูงกว่าปกติ 5 เท่า | [ ] ผ่าน |
