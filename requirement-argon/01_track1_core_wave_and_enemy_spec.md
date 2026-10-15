# ไฟล์ที่ 1: คู่มือตั้งค่า Git Worktree + Rojo + MCP และสเปกงานส่วนที่ 1 (Core Wave & Infinite Zombie Scaling)

เอกสารฉบับนี้เป็นคู่มือจับมือทำแบบละเอียดสำหรับ **งานส่วนที่ 1 (Track 1: ระบบแกนหลัก แมพเส้นทางอัตโนมัติ และฝูงซอมบี้เพิ่มสเตตัสไร้ขีดจำกัด)** รวมถึงการตั้งค่า **GitHub Repository เดียว แยก 3 Git Worktrees** เพื่อให้คุณเปิด AI Agent 3 ตัวรันพร้อมกันได้แบบ **100% ไม่ทับไฟล์กัน (Zero Merge Conflict)** และตรวจสอบสถานะงานได้ตลอดเวลา

---

## 1. ภาพรวมสถาปัตยกรรม: ทำ 3 งานพร้อมกันใน Repo เดียวแบบไม่ชนกันได้อย่างไร?

เพื่อให้คุณทำคนเดียวแต่สั่ง AI 3 หน้าต่างทำงานพร้อมกันได้ภายใน 3 ชั่วโมง เราจะใช้ **Rojo + Git Worktree + MCP (Model Context Protocol)** โดยแบ่งโฟลเดอร์โค้ดออกจากกันอย่างเด็ดขาดตั้งแต่ต้น:

| ชื่องาน (Track) | ชื่อ Git Branch | โฟลเดอร์ Git Worktree | โฟลเดอร์โค้ดที่รับผิดชอบ (ห้ามข้ามเขต) | พอร์ต Rojo สำหรับเทสแยก |
| :--- | :--- | :--- | :--- | :--- |
| **ฐานข้อมูลกลาง (Base Setup)** | `main` | `./anime-td-repo` | `default.project.json`, `src/Shared/GameConfig.luau` | `34872` (ตอนรวมงาน) |
| **งานที่ 1: ระบบเวฟ & ซอมบี้ไร้ขีดจำกัด** | `feat/track1-wave` | `../wt-track1-wave` | `src/Track1_WaveSystem/` เท่านั้น | `34871` |
| **งานที่ 2: ป้อมอนิเมะปล่อยพลัง & VFX** | `feat/track2-towers` | `../wt-track2-towers` | `src/Track2_TowerSystem/` เท่านั้น | `34872` |
| **งานที่ 3: UI อัปเกรดไร้ขีดจำกัด & ร้านค้า** | `feat/track3-ui` | `../wt-track3-ui` | `src/Track3_UISystem/` และ `src/Track3_UpgradeServer/` | `34873` |

### กฎเหล็กป้องกันการแก้ทับกัน (Zero-Conflict Rules)
1. **แยกโฟลเดอร์ 100%**: AI Agent ตัวที่ 1 แก้ไขได้เฉพาะไฟล์ใน `src/Track1_WaveSystem/` เท่านั้น ห้ามแก้ไฟล์นอกโฟลเดอร์เด็ดขาด
2. **สื่อสารผ่าน Data Contract กลาง (`Attributes` & `leaderstats`)**: ทั้ง 3 ระบบไม่ต้อง `require` โค้ดข้ามกันโดยตรง แต่คุยกันผ่าน `Player Attributes`, `Workspace Attributes` และ `ReplicatedStorage.GameConfig` ที่ล็อกชื่อตัวแปรไว้ตายตัวแล้ว
3. **Auto-Bootstrap (เสกแมพและโมเดลด้วยโค้ดอัตโนมัติ)**: ไม่ต้องนั่งปั้น Part ใน Roblox Studio ด้วยมือ เพราะโค้ดในแต่ละ Track จะตรวจสอบเองว่าถ้ายังไม่มีทางเดิน จุดเกิดซอมบี้ หรือแท่นป้อมใน `Workspace` สคริปต์จะเสกขึ้นมาให้อัตโนมัติทันทีที่กด Play

---

## 2. ขั้นตอนที่ 0: จับมือทำตั้งค่า GitHub Repo + Rojo + Git Worktree + MCP (ทำครั้งเดียว 15 นาที)

### 2.1 ติดตั้งเครื่องมือพื้นฐาน (Rojo & Git)
เปิด Terminal (PowerShell หรือ Command Prompt หรือ Terminal ใน VS Code / Cursor) แล้วรันคำสั่งตรวจสอบหรือติดตั้ง Rojo:

```bash
# หากยังไม่มี Aftman หรือ Rojo ให้ติดตั้งผ่าน Aftman หรือ Rokit
# ตรวจสอบว่ามี git และ rojo พร้อมใช้งาน
git --version
rojo --version
```
*(หมายเหตุ: ใน Roblox Studio ให้ติดตั้งปลั๊กอิน **Rojo** จากแท็บ Plugins หรือดาวน์โหลดผ่านคำสั่ง `rojo plugin install`)*

### 2.2 สร้าง Repository หลักและไฟล์สัญญาข้อมูลกลาง (`main` branch)
คัดลอกคำสั่งด้านล่างไปรันใน Terminal ทีละบล็อกเพื่อสร้างโครงสร้างโปรเจกต์หลัก:

```bash
mkdir anime-td-repo
cd anime-td-repo
git init -b main

# สร้างโฟลเดอร์แยกสำหรับทั้ง 3 งานล่วงหน้า
mkdir -p src/Shared
mkdir -p src/Track1_WaveSystem
mkdir -p src/Track2_TowerSystem
mkdir -p src/Track3_UISystem
mkdir -p src/Track3_UpgradeServer
```

#### สร้างไฟล์ `default.project.json` (หัวใจสำคัญของ Rojo)
สร้างไฟล์ชื่อ `default.project.json` ที่รากของโฟลเดอร์ `anime-td-repo` ด้วยเนื้อหาต่อไปนี้:

```json
{
  "name": "AnimeTowerDefenseUnlimited",
  "tree": {
    "$className": "DataModel",
    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "Shared": {
        "$path": "src/Shared"
      }
    },
    "ServerScriptService": {
      "$className": "ServerScriptService",
      "Track1_WaveSystem": {
        "$path": "src/Track1_WaveSystem"
      },
      "Track2_TowerSystem": {
        "$path": "src/Track2_TowerSystem"
      },
      "Track3_UpgradeServer": {
        "$path": "src/Track3_UpgradeServer"
      }
    },
    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "$className": "StarterPlayerScripts",
        "Track3_UISystem": {
          "$path": "src/Track3_UISystem"
        }
      }
    }
  }
}
```

#### สร้างไฟล์สัญญาข้อมูลกลาง `src/Shared/GameConfig.luau`
สร้างไฟล์ `src/Shared/GameConfig.luau` เพื่อให้ทั้ง 3 งานอ้างอิงชื่อตัวแปรและสูตรคำนวณชุดเดียวกันโดยไม่ต้องเดาชื่อเอง:

```luau
-- src/Shared/GameConfig.luau
-- ไฟล์สัญญากลาง (Data Contract) ห้ามให้ Worktree ใดแก้ไขไฟล์นี้โดยพลการ
local GameConfig = {}

-- ชื่อ Attribute บน Workspace
GameConfig.WORKSPACE_ATTRS = {
	CURRENT_WAVE = "CurrentWave",
	BASE_HP = "BaseHP",
	MAX_BASE_HP = "MaxBaseHP",
	ZOMBIES_REMAINING = "ZombiesRemaining",
	GAME_OVER = "GameOver",
}

-- ชื่อ Attribute บนตัว Player (สำหรับอัปเกรดสเตตัสไร้ขีดจำกัด)
GameConfig.PLAYER_ATTRS = {
	DAMAGE_STAT = "DamageStat",
	RANGE_STAT = "RangeStat",
	COOLDOWN_STAT = "CooldownStat",
	DAMAGE_LEVEL = "DamageLevel",
	RANGE_LEVEL = "RangeLevel",
	SPEED_LEVEL = "SpeedLevel",
}

-- ค่าเริ่มต้นของผู้เล่น
GameConfig.INITIAL_PLAYER_STATS = {
	CASH = 300,
	DAMAGE_STAT = 35,
	RANGE_STAT = 32,
	COOLDOWN_STAT = 1.0,
	MIN_COOLDOWN = 0.12,
}

-- ค่าเริ่มต้นของฐานและสูตรคูณเวฟซอมบี้ไร้ขีดจำกัด
GameConfig.WAVE_SETTINGS = {
	INITIAL_BASE_HP = 1000,
	BASE_ZOMBIE_HP = 100,
	HP_GROWTH_RATE = 1.28, -- เลือดซอมบี้คูณ 1.28 เท่าทุกเวฟ
	BASE_ZOMBIE_SPEED = 10,
	SPEED_INCREMENT_PER_WAVE = 0.25,
	MAX_ZOMBIE_SPEED = 26,
	BASE_CASH_REWARD = 25,
	SPAWN_INTERVAL = 0.9,
	INTERMISSION_TIME = 4,
}

-- ชื่อโฟลเดอร์และ RemoteEvent มาตรฐาน
GameConfig.FOLDERS = {
	WAYPOINTS = "Waypoints",
	ENEMIES = "ActiveEnemies",
	TOWERS = "AnimeTowers",
}

GameConfig.REMOTES = {
	UPGRADE_REQUEST = "UpgradeStatRequest",
}

return GameConfig
```

#### สร้างไฟล์ `.gitignore` และ Commit ลง `main` พร้อมแตก 3 Git Worktrees
รันคำสั่งนี้ใน Terminal เพื่อล็อกโครงสร้างหลักและแตกออกเป็น 3 โฟลเดอร์ทำงานคู่ขนาน:

```bash
# สร้างไฟล์ .gitignore และ .gitkeep
echo "*.rbxl*" > .gitignore
touch src/Track1_WaveSystem/.gitkeep
touch src/Track2_TowerSystem/.gitkeep
touch src/Track3_UISystem/.gitkeep
touch src/Track3_UpgradeServer/.gitkeep

git add .
git commit -m "chore: init Rojo project and shared GameConfig contract"

# แตก 3 Git Worktrees ออกเป็น 3 โฟลเดอร์ข้างเคียงกัน
git worktree add ../wt-track1-wave -b feat/track1-wave
git worktree add ../wt-track2-towers -b feat/track2-towers
git worktree add ../wt-track3-ui -b feat/track3-ui

# ตรวจสอบรายการ Worktree ทั้งหมด
git worktree list
```

### 2.3 ตั้งค่า MCP (Model Context Protocol) สำหรับสั่ง AI 3 หน้าต่างพร้อมกัน
หากคุณใช้ **Claude Code CLI**, **Cursor**, หรือ **Windsurf**:
1. เปิดหน้าต่างโปรแกรม/Terminal **3 หน้าต่างแยกกัน**:
   * **หน้าต่างที่ 1**: เปิดที่โฟลเดอร์ `../wt-track1-wave` (สำหรับรันสเปกไฟล์ที่ 1 นี้)
   * **หน้าต่างที่ 2**: เปิดที่โฟลเดอร์ `../wt-track2-towers` (สำหรับรันสเปกไฟล์ที่ 2)
   * **หน้าต่างที่ 3**: เปิดที่โฟลเดอร์ `../wt-track3-ui` (สำหรับรันสเปกไฟล์ที่ 3)
2. หากต้องการผูก **Filesystem & Git MCP** ในไฟล์ `.mcp.json` (หรือ `claude_desktop_config.json`) ให้ตั้งค่าดังนี้เพื่อให้ AI อ่าน/เขียนไฟล์และเช็ค Git status ใน Worktree ของตัวเองได้อัตโนมัติ:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."]
    },
    "git": {
      "command": "uvx",
      "args": ["mcp-server-git", "--repository", "."]
    }
  }
}
```

---

## 3. Spec & Scope ของงานส่วนที่ 1 (Track 1: Core Wave & Enemy System)

### ขอบเขตงาน (In-Scope)
* **ผู้รับผิดชอบ**: AI Agent หน้าต่างที่ 1 (ทำงานใน `../wt-track1-wave`)
* **ไฟล์ที่อนุญาตให้สร้าง/แก้ไข**: `src/Track1_WaveSystem/WaveManager.server.luau` เท่านั้น
* **ฟีเจอร์ที่ต้องทำให้ครบ**:
  1. **Auto-Map & Waypoint Bootstrap**: เมื่อเริ่มเกม หากใน `Workspace` ยังไม่มีโฟลเดอร์ `Waypoints`, `ActiveEnemies` หรือฐาน `AnimeBase` ให้สคริปต์สร้างถนนเส้นทางเดิน จุดเลี้ยว `1` ถึง `6` และปราสาทคริสตัลอนิเมะปลายทางให้อัตโนมัติ
  2. **Player Leaderstats & Attributes**: เมื่อผู้เล่นเข้าเกม สร้าง `leaderstats.Cash` และตั้งค่า Attributes เริ่มต้น (`DamageStat`, `RangeStat`, `CooldownStat`, `DamageLevel`, `RangeLevel`, `SpeedLevel`) บนตัวผู้เล่น (ถ้ายังไม่มี)
  3. **Unlimited Wave Loop**: รันลูปเวฟ `1, 2, 3...` ไปเรื่อยๆ ไม่มีที่สิ้นสุด อัปเดต `Workspace:SetAttribute("CurrentWave", wave)` และ `ZombiesRemaining` แบบเรียลไทม์
  4. **Infinite Zombie Stat Scaling**:
     * จำนวนซอมบี้ต่อเวฟ = `5 + (CurrentWave * 2)`
     * เลือดซอมบี้ (`MaxHealth`) = `math.floor(100 * (1.28 ^ (CurrentWave - 1)))`
     * ความเร็วเดิน (`WalkSpeed`) = เพิ่มขึ้นเวฟละ `0.25` (สูงสุดไม่เกิน `26`)
     * ทุกๆ เวฟที่หารด้วย 5 ลงตัว (Wave 5, 10, 15...) จะมี **Anime Boss Zombie** ตัวใหญ่สีแดงทมิฬ เลือดคูณ 4 เท่าของซอมบี้ปกติในเวฟนั้น!
  5. **Zombie Movement & Reward System**:
     * ซอมบี้มีป้าย `BillboardGui` บนหัว แสดงชื่อเวฟและหลอดเลือด `HP / MaxHP` แบบสดๆ
     * ซอมบี้เคลื่อนที่เรียงตามจุด `Waypoints` (`1 -> 2 -> 3 -> 4 -> 5 -> 6`)
     * หากเลือดซอมบี้ลดเหลือ `<= 0` ให้แจก `Cash` (`25 * CurrentWave`) ให้ผู้เล่นทุกคนในเซิร์ฟเวอร์ทันที
     * หากซอมบี้เดินถึงจุดที่ `6` (ฐานหลัก) ให้หัก `BaseHP` ของ `Workspace` แล้วทำลายตัวซอมบี้ทิ้ง

### นอกขอบเขตงาน (Out-of-Scope - ห้ามทำใน Track 1)
* ห้ามสร้างสคริปต์ป้อมปืนอนิเมะ (อยู่ใน Track 2)
* ห้ามสร้างหน้าจอ ScreenGui ปุ่มกดอัปเกรดของผู้เล่น (อยู่ใน Track 3)

---

## 4. Prompt สั่ง AI Agent หน้าต่างที่ 1 และโค้ดตัวเต็มพร้อมใช้งาน

### 4.1 Prompt สำหรับก๊อปปี้ไปวางใน AI Agent หน้าต่างที่ 1 (`../wt-track1-wave`)
> "คุณกำลังทำงานใน Git Worktree `feat/track1-wave` ให้สร้างไฟล์ `src/Track1_WaveSystem/WaveManager.server.luau` เท่านั้น (ห้ามแก้ไขไฟล์นอกโฟลเดอร์ `src/Track1_WaveSystem` เด็ดขาด) โดยอ้างอิงค่าจาก `ReplicatedStorage.Shared.GameConfig` ให้เขียนระบบ Auto-Map Waypoints (1 ถึง 6), ระบบ `leaderstats.Cash` และ Player Attributes เริ่มต้น, ระบบสปอว์นซอมบี้เป็นเวฟไร้ขีดจำกัดพร้อมหลอดเลือด BillboardGui บนหัว, ระบบบอสทุกๆ 5 เวฟ, ระบบเดินตาม Waypoints ด้วย TweenService/PivotTo ที่ลื่นไหลไม่ติดบั๊กฟิสิกส์ และระบบแจกเงินเมื่อซอมบี้ตายหรือลดเลือดฐานเมื่อซอมบี้ถึงจุดสุดท้าย เมื่อเขียนเสร็จให้ git add และ git commit ลง branch `feat/track1-wave`"

### 4.2 โค้ดสำเร็จรูป `src/Track1_WaveSystem/WaveManager.server.luau`
หากต้องการความชัวร์ 100% ให้ AI เขียนโค้ดชุดนี้ลงใน `src/Track1_WaveSystem/WaveManager.server.luau` ได้เลย:

```luau
-- src/Track1_WaveSystem/WaveManager.server.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

-- 1. สร้างโฟลเดอร์และแมพเส้นทางเดินอัตโนมัติ (Auto-Bootstrap)
local function ensureMapAndWaypoints()
	local waypointsFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.WAYPOINTS)
	if not waypointsFolder then
		waypointsFolder = Instance.new("Folder")
		waypointsFolder.Name = GameConfig.FOLDERS.WAYPOINTS
		waypointsFolder.Parent = Workspace

		-- พิกัดจุดเลี้ยวรูปตัว S สำหรับทางเดินซอมบี้
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

	local enemiesFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.ENEMIES)
	if not enemiesFolder then
		enemiesFolder = Instance.new("Folder")
		enemiesFolder.Name = GameConfig.FOLDERS.ENEMIES
		enemiesFolder.Parent = Workspace
	end

	return waypointsFolder, enemiesFolder
end

-- 2. ตั้งค่าผู้เล่นเมื่อเข้าเกม
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

-- 3. ฟังก์ชันสร้างโมเดลซอมบี้อนิเมะพร้อมหลอดเลือด BillboardGui
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

	-- ออร่าคำสาปอนิเมะรอบตัวซอมบี้
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
	local wp1 = waypointsFolder:FindFirstChild("1")
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
			local cashVal = ls and ls:FindFirstChild("Cash")
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

	-- เดินตาม Waypoints อย่างแม่นยำ
	task.spawn(function()
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
					local step = math.min(dist, speed * dt)
					local nextPos = currentPos + diff.Unit * step
					root.CFrame = CFrame.lookAt(nextPos, targetPos)
					head.Position = nextPos + Vector3.new(0, 3.2 * scale, 0)
				end
			end
		end

		-- ถ้าเดินถึงจุดสุดท้ายแล้วยังไม่ตาย ให้ลดเลือดฐานหลัก
		if model.Parent and humanoid.Health > 0 then
			local currentBaseHp = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) or 1000
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

-- 4. ลูปควบคุมเวฟไร้ขีดจำกัด (Main Infinite Wave Loop)
task.spawn(function()
	local waypointsFolder, enemiesFolder = ensureMapAndWaypoints()

	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, GameConfig.WAVE_SETTINGS.INITIAL_BASE_HP)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP, GameConfig.WAVE_SETTINGS.INITIAL_BASE_HP)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE, 1)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, 0)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, false)

	local currentWave = 1
	while true do
		-- เช็คกรณีเลือดฐานหมด ให้รีเซ็ตเริ่มเวฟ 1 ใหม่อัตโนมัติหลังพัก 5 วินาที (ผู้เล่นเก็บสเตตัสที่อัปไว้ต่อได้!)
		if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == true then
			task.wait(5)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, GameConfig.WAVE_SETTINGS.INITIAL_BASE_HP)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, false)
			currentWave = 1
		end

		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE, currentWave)
		for _, plr in ipairs(Players:GetPlayers()) do
			local ls = plr:FindFirstChild("leaderstats")
			local wStat = ls and ls:FindFirstChild("Wave")
			if wStat then
				wStat.Value = currentWave
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

		-- รอจนกว่าซอมบี้ในเวฟจะตายหรือเข้าฐานหมด
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

## 5. วิธีรันเทสแยกเฉพาะงานที่ 1 และตารางตรวจรับงาน (UAT Track 1)

คุณสามารถตรวจสอบงานของ AI หน้าต่างที่ 1 ได้ทันทีโดยไม่ต้องรองานที่ 2 และ 3 เสร็จ:

### ขั้นตอนการรันเทสแยกของ Worktree ที่ 1
1. ใน Terminal หน้าต่างที่ 1 (`../wt-track1-wave`) รันคำสั่ง:
   ```bash
   rojo serve --port 34871
   ```
2. เปิด Roblox Studio (สร้าง Baseplate เปล่าๆ) -> เปิดปลั๊กอิน **Rojo** -> เปลี่ยนพอร์ตเป็น `34871` แล้วกด **Connect**
3. กดปุ่ม **Play (F5)** ใน Roblox Studio แล้วตรวจเช็คตามตาราง UAT ด้านล่าง

### ตาราง UAT (User Acceptance Test) สำหรับงานส่วนที่ 1

| รหัส UAT | รายการทดสอบ (Test Case) | วิธีทดสอบใน Roblox Studio | ผลลัพธ์ที่ต้องเห็น (Expected Result) | สถานะ |
| :--- | :--- | :--- | :--- | :--- |
| **UAT-1.1** | การสร้างถนนและจุด Waypoints อัตโนมัติ | กด Play ในแมพ Baseplate เปล่าๆ แล้วมองไปที่กลางแมพ | มีถนนรูปตัว S จุดเรืองแสง 6 จุด (`Workspace.Waypoints`) และแท่งคริสตัลสีฟ้า `AnimeBaseCrystal` ถูกเสกขึ้นมาเองทันที | [ ] ผ่าน |
| **UAT-1.2** | ระบบ `leaderstats` และ Player Attributes เริ่มต้น | ดูตารางผู้เล่นมุมขวาบน และคลิกชื่อตัวเองใน `Players` ดูหน้าต่าง Properties ด้านล่าง | มีค่า `Cash = 300`, `Wave = 1` บนตารางคะแนน และมี Attributes `DamageStat = 35`, `RangeStat = 32`, `CooldownStat = 1` | [ ] ผ่าน |
| **UAT-1.3** | การเกิดซอมบี้พร้อมหลอดเลือดและการเดินตามเส้นทาง | สังเกตจุดเกิดสีแดง (`Waypoints.1`) | ซอมบี้มีออร่าคำสาปสีม่วง มีป้าย `Lv.1 [100/100]` บนหัว และเดินเลี้ยวตามถนนไปจนถึงคริสตัลสีฟ้าอย่างลื่นไหล | [ ] ผ่าน |
| **UAT-1.4** | ระบบลดเลือดฐานและการเพิ่มสเตตัสซอมบี้ในเวฟถัดไป | ปล่อยให้ซอมบี้เดินชนคริสตัลจนจบเวฟ 1 เข้าสู่เวฟ 2 | ค่า `BaseHP` ใน Attributes ของ `Workspace` ลดลง และเมื่อขึ้นเวฟ 2 เลือดซอมบี้บนหัวเพิ่มเป็น `Lv.2 [128/128]` อัตโนมัติ | [ ] ผ่าน |
| **UAT-1.5** | ระบบแจกเงินเมื่อซอมบี้ตาย | ใช้เครื่องมือใน Studio ปรับค่า `Humanoid.Health` ของซอมบี้ให้เป็น `0` | ตัวซอมบี้หายไปทันที และค่า `Cash` ของผู้เล่นบนตารางคะแนนเพิ่มขึ้น `+25` (คูณตามเลขเวฟ) | [ ] ผ่าน |
| **UAT-1.6** | การแยกไฟล์ไม่ชนกับงานอื่น (Git Isolation Check) | รันคำสั่ง `git status` ในโฟลเดอร์ `../wt-track1-wave` | มีการเปลี่ยนแปลงเฉพาะไฟล์ใน `src/Track1_WaveSystem/` เท่านั้น ไม่มีไฟล์ของ Track 2 หรือ Track 3 ปะปน | [ ] ผ่าน |
