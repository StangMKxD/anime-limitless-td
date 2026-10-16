# ไฟล์ที่ 1: สเปกสั่งแก้ `PLAN-0007` (Track 1 — ปรับศัตรูโหดขึ้นทุกเวฟแบบทวีคูณ + มอนสเตอร์ฮาคิเกราะ/นักฆ่าโซล + หลอดเลือดมินิมอลไม่บังจอ)

> **อ้างอิงจากโค้ดจริงใน Repo**: [StangMKxD/anime-limitless-td](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td) (Commit `3c0e950` / Phase 3 Full System)  
> **ไฟล์เป้าหมายที่ต้องแก้**: [src/Shared/GameConfig.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FShared%2FGameConfig.luau) และ [src/Track1\_WaveSystem/WaveManager.server.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack1_WaveSystem%2FWaveManager.server.luau) (351 บรรทัด)  
> **รหัสแผนงาน**: `PLAN-0007` (Overhaul Enemy Difficulty, R6 Humanoid Rig & Micro HP Bar)  
> **กฎการทำงาน (`AGENTS.md`)**: `COMBO-07` | Strict SoD (`R01–R05`) — แก้ไขใน Working Tree และส่งมอบ `RESULT.md` ให้ Reviewer (`Codex CLI / stang-luna`)

---

## 1. วิเคราะห์ปัญหาจากโค้ดจริงใน Repo ปัจจุบัน (`WaveManager.server.luau` & `GameConfig.luau`)

จากการเข้าไปตรวจโค้ดจริงใน [src/Track1\_WaveSystem/WaveManager.server.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack1_WaveSystem%2FWaveManager.server.luau) และ [src/Shared/GameConfig.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FShared%2FGameConfig.luau) พบสาเหตุหลัก 3 ข้อที่ทำให้เกมดูไม่สมดุลและรกหน้าจอ:

1. **ศัตรูอ่อนเกินไปมากเมื่อเทียบกับป้อม 16 จุด (`Pad1`–`Pad16`) และการ์ด 12 ใบ**:
   * ในโค้ดปัจจุบัน ผู้เล่นสามารถวางตัวละคร One Piece ได้สูงสุดถึง 16 แท่น พร้อมบัฟจากการ์ดและอัปเกรดสเตตัส แต่ซอมบี้มีแค่แบบเดียว เลือดเริ่มต้นต่ำ และอัตราคูณต่อเวฟเบาเกินไป ทำให้ป้อมรุมยิงซอมบี้ตายตั้งแต่วินาทีแรกที่ก้าวออกจากจุดเกิด
2. **โมเดลศัตรูเป็นก้อน Part ต่อกันหลวมๆ**:
   * การสร้างศัตรูด้วย `Instance.new("Part")` ธรรมดาทำให้รูปร่างไม่เหมือนตัวละคร Roblox จริงๆ
3. **ป้าย `BillboardGui` บนหัวศัตรูใหญ่เกินไป**:
   * เมื่อซอมบี้เกิดพร้อมกัน 15–30 ตัว ป้ายชื่อและหลอดเลือดขนาดใหญ่ที่มี `AlwaysOnTop = true` ซ้อนทับกันจนบังโมเดลและสนามรบมิด

---

## 2. สเปกการแก้ไขใน `PLAN-0007` (โหดขึ้นทุกเวฟ + มอนสเตอร์ 4 ระดับ + หลอดเลือดเส้นจิ๋ว)

### 2.1 ปรับสูตรความโหดของเวฟซอมบี้ (`Brutal Endless Scaling Formula`)
ให้แก้สูตรคำนวณเลือด จำนวน และความเร็วของศัตรูใน `GameConfig.luau` และ `WaveManager.server.luau` ดังนี้:

| ค่าพารามิเตอร์ | ค่าเดิม (อ่อนเกินไป) | ค่าใหม่ใน `PLAN-0007` (โหดสะใจทุกเวฟ) | ผลลัพธ์ความยากที่เพิ่มขึ้นจริง |
| :--- | :--- | :--- | :--- |
| **เลือดพื้นฐาน (`BASE_ZOMBIE_HP`)** | `100` | **`450`** | เวฟ 1 ไม่ตายในนัดเดียว ต้องช่วยกันยิง |
| **ตัวคูณเลือดต่อเวฟ (`HP_GROWTH_RATE`)** | `1.25 - 1.28` | **`1.58 ^ (Wave - 1)` คูณกับ `WaveSurge`** | โดย `WaveSurge = 1 + math.floor(Wave / 3) * 0.75` เลือดพุ่งทวีคูณทุกเวฟ! |
| **เกราะฮาคิ (`HakiArmorReduction`)** | `0%` (ไม่มีเกราะ) | **เพิ่มขึ้นเวฟละ `+3%` (สูงสุด `65%`)** | ยิ่งเวฟสูง ศัตรูยิ่งถึกขึ้น บังคับให้ผู้เล่นต้องเลือกการ์ดเจาะเกราะ/คริติคอล |
| **จำนวนศัตรูต่อเวฟ (`EnemyCount`)** | `5 + (Wave * 2)` | **`8 + math.floor(Wave * 3.5)`** | ออกมาเป็นกองทัพถี่ขึ้น (`SPAWN_INTERVAL` ลดลงจาก `0.85s` เหลือ `0.35s` ในเวฟสูง) |

### 2.2 เพิ่มศัตรู 4 สายพันธุ์ที่เกิดผสมกันและเก่งขึ้นทุกเวฟ
แทนที่จะเสกซอมบี้ธรรมดาเหมือนกันหมด ให้ `WaveManager.server.luau` สุ่มและปล่อยศัตรู 4 ระดับตามเลขเวฟ:
1. **Pirate Grunt (ทหารโจรสลัดทั่วไป - ทุกเวฟ)**: เลือด `1.0x`, ความเร็วปกติ
2. **Soru Assassin (นักฆ่าวิชาหกรูปแบบ - เริ่มเกิดตั้งแต่ Wave 2+)**: ตัวเพรียวออร่าสีฟ้า วิ่งเร็ว **`1.65x`** (สูงสุด `32 Studs/s`) พุ่งทะลวงแนวหน้า
3. **Armored Haki Brute (จอมพลังหุ้มเกราะฮาคิทั้งตัว - เริ่มเกิดตั้งแต่ Wave 3+)**: ตัวใหญ่ `1.35x` ตัวสีดำเงาขอบม่วง เลือด **`2.8x`** และลดดาเมจที่ได้รับลง **`35%`**
4. **Yonko Calamity Boss (บอสจักรพรรดิไคโด/หนวดดำ - เกิดทุกๆ 3 เวฟ และทุกเวฟตั้งแต่ Wave 10+)**:
   * เลือด **`8.0x`** ของเวฟนั้น!
   * มีสกิล **Haki Regeneration**: ฟื้นฟูเลือดตัวเอง **`2.5% ของ MaxHP ทุกๆ 1 วินาที`** (ถ้า DPS ของทีมผู้เล่นต่ำกว่าอัตราฟื้นเลือด บอสจะไม่มีวันตาย!)

### 2.3 เปลี่ยนการสร้างหุ่นศัตรูเป็น `Players:CreateHumanoidModelFromDescription` (R6 ของแท้) + หลอดเลือดจิ๋ว
* ใช้ `Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R6)` เพื่อสร้างหุ่นโครงกระดูก R6 ของแท้จากเอนจิน Roblox (หัวมน แขนขาสมส่วน ไม่ใช่กล่องสี่เหลี่ยมเพี้ยนๆ)
* **ย่อ `BillboardGui` หลอดเลือดบนหัวศัตรู**:
  * ขนาดลดลงเหลือเพียง **`52x6 px`** (`Size = UDim2.new(0, 52, 0, 6)`)
  * ตั้งค่า **`AlwaysOnTop = false`** และ **`MaxDistance = 85`** เพื่อไม่ให้หลอดเลือดทะลุขึ้นมาบังหน้าจอ UI หรือบังเอฟเฟกต์สกิล!
  * ซ่อนตัวหนังสือรกๆ บนหัวมอนสเตอร์ทั่วไป (แสดงชื่อเฉพาะตัว `BOSS` ด้วยฟอนต์เล็กคมชัดขนาด `10px`)

---

## 3. โค้ดฟังก์ชันหลักสำหรับอัปเดตใน `src/Track1_WaveSystem/WaveManager.server.luau`

ให้ AI Implementer นำตรรกะการคำนวณสเตตัสความโหดระดับ Nightmare และการสร้างหุ่น R6 แท้พร้อมหลอดเลือดจิ๋วชุดนี้ไปอัปเดตใน `src/Track1_WaveSystem/WaveManager.server.luau` (โดยคงการเชื่อมโยงกับ `PREP_COUNTDOWN`, `WAVE_STATUS`, `EarlyStartEvent` และ `BOUNTY_MULT` ที่มีอยู่ใน Repo ปัจจุบันไว้ครบถ้วน):

```luau
-- ฟังก์ชันคำนวณสเตตัสศัตรูแบบโหดขึ้นทุกเวฟ (Brutal Wave Scaling)
local function calculateEnemyStats(wave: number, enemyClass: string)
	local baseHp = 450
	local expGrowth = math.pow(1.58, wave - 1)
	local waveSurge = 1 + (math.floor(wave / 3) * 0.75)
	local rawHp = baseHp * expGrowth * waveSurge

	local baseSpeed = math.min(24, 11 + (wave * 0.40))
	local armorReduction = math.min(0.65, (wave - 1) * 0.03) -- ลดดาเมจสูงสุด 65%

	if enemyClass == "SoruAssassin" then
		return {
			MaxHP = math.floor(rawHp * 0.75),
			Speed = math.min(34, baseSpeed * 1.65),
			Armor = armorReduction * 0.5,
			Scale = 0.95,
			RegenPerSec = 0,
			RewardMult = 1.3,
			BodyColor = Color3.fromRGB(30, 95, 190),
			AuraColor = Color3.fromRGB(0, 225, 255),
			IsBoss = false,
		}
	elseif enemyClass == "HakiBrute" then
		return {
			MaxHP = math.floor(rawHp * 2.8),
			Speed = math.max(8, baseSpeed * 0.78),
			Armor = math.min(0.75, armorReduction + 0.30),
			Scale = 1.35,
			RegenPerSec = 0,
			RewardMult = 2.0,
			BodyColor = Color3.fromRGB(22, 20, 28),
			AuraColor = Color3.fromRGB(165, 40, 255),
			IsBoss = false,
		}
	elseif enemyClass == "YonkoBoss" then
		return {
			MaxHP = math.floor(rawHp * 8.0),
			Speed = math.max(7.5, baseSpeed * 0.72),
			Armor = math.min(0.70, armorReduction + 0.25),
			Scale = 2.2,
			RegenPerSec = 0.025, -- ฟื้นเลือด 2.5% ต่อวินาที!
			RewardMult = 6.0,
			BodyColor = Color3.fromRGB(130, 18, 35),
			AuraColor = Color3.fromRGB(255, 20, 60),
			IsBoss = true,
		}
	else
		return {
			MaxHP = math.floor(rawHp),
			Speed = baseSpeed,
			Armor = armorReduction,
			Scale = 1.0,
			RegenPerSec = 0,
			RewardMult = 1.0,
			BodyColor = Color3.fromRGB(55, 95, 65),
			AuraColor = Color3.fromRGB(90, 40, 140),
			IsBoss = false,
		}
	end
end

-- ฟังก์ชันสร้างหุ่น R6 แท้ (หรือดึงจาก ReplicatedStorage.EnemyModels) พร้อมหลอดเลือดมินิมอลไม่บังจอ
local function createEnemyR6Model(wave: number, enemyClass: string, stats)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")

	local customTemplates = ReplicatedStorage:FindFirstChild("EnemyModels")
	local model: Model? = nil

	if customTemplates and customTemplates:FindFirstChild(enemyClass) then
		model = customTemplates:FindFirstChild(enemyClass):Clone()
	else
		local ok, rig = pcall(function()
			local desc = Instance.new("HumanoidDescription")
			desc.HeadColor = stats.BodyColor
			desc.TorsoColor = Color3.fromRGB(30, 32, 42)
			desc.LeftArmColor = stats.BodyColor
			desc.RightArmColor = stats.BodyColor
			desc.LeftLegColor = Color3.fromRGB(25, 25, 30)
			desc.RightLegColor = Color3.fromRGB(25, 25, 30)
			return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
		end)
		if ok and rig then
			model = rig
		end
	end

	-- Fallback กรณีรันใน Headless Test Runner ที่ไม่มี CreateHumanoidModelFromDescription
	if not model then
		model = Instance.new("Model")
		local root = Instance.new("Part")
		root.Name = "HumanoidRootPart"
		root.Size = Vector3.new(2, 2, 1) * stats.Scale
		root.Parent = model
		local head = Instance.new("Part")
		head.Name = "Head"
		head.Size = Vector3.new(1.2, 1.2, 1.2) * stats.Scale
		head.Parent = model
		local hum = Instance.new("Humanoid")
		hum.Parent = model
		model.PrimaryPart = root
	end

	model:ScaleTo(stats.Scale)
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			desc.Anchored = true
			desc.CanCollide = false
		end
	end

	-- เก็บค่าเกราะฮาคิไว้ใน Attribute เพื่อให้ป้อมคำนวณลดดาเมจได้ หรือคืนเลือดส่วนที่เกราะกันไว้
	model:SetAttribute("ArmorReduction", stats.Armor)
	model:SetAttribute("EnemyClass", enemyClass)

	-- สร้างหลอดเลือดมินิมอลเส้นบางเฉียบ (ไม่บังจอ!)
	local head = model:FindFirstChild("Head") or model.PrimaryPart
	if head then
		local bb = Instance.new("BillboardGui")
		bb.Name = "HPBarGui"
		bb.Size = stats.IsBoss and UDim2.new(0, 96, 0, 16) or UDim2.new(0, 48, 0, 5)
		bb.StudsOffset = Vector3.new(0, 2.4 * stats.Scale, 0)
		bb.AlwaysOnTop = false -- ปิด AlwaysOnTop เพื่อไม่ให้ทะลุบัง UI และเอฟเฟกต์
		bb.MaxDistance = 90
		bb.Adornee = head
		bb.Parent = model

		local bg = Instance.new("Frame")
		bg.Size = UDim2.new(1, 0, 1, 0)
		bg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
		bg.BackgroundTransparency = 0.25
		bg.BorderSizePixel = 0
		bg.Parent = bb

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.new(1, 0, 1, 0)
		fill.BackgroundColor3 = stats.IsBoss and Color3.fromRGB(255, 45, 70) or Color3.fromRGB(50, 230, 110)
		fill.BorderSizePixel = 0
		fill.Parent = bg
	end

	return model
end
```

---

## 4. ตารางตรวจรับงาน `PLAN-0007` (UAT Track 1)

| รหัส UAT | รายการทดสอบ | เกณฑ์การตรวจรับ (Acceptance Criteria) | สถานะ |
| :--- | :--- | :--- | :---: |
| **UAT-7.1** | ความโหดของศัตรูเพิ่มขึ้นทุกเวฟ | เลือดมอนสเตอร์เริ่มต้น `450` และคูณ `1.58^W * WaveSurge` พร้อมมี `SoruAssassin` (วิ่งไว) และ `HakiBrute` (ถึกมีเกราะ) ออกมาผสมทุกเวฟ | [ ] ผ่าน |
| **UAT-7.2** | บอสฟื้นเลือดและเกิดถี่ขึ้น | บอสเกิดทุก 3 เวฟ (แทนที่จะรอ 5 เวฟ) เลือด `8x` และมีระบบ Regen ฟื้นเลือดตัวเอง `2.5%/s` | [ ] ผ่าน |
| **UAT-7.3** | หลอดเลือดมินิมอลไม่บังจอ | หลอดเลือดศัตรูทั่วไปเป็นเส้นเล็กขนาด `48x5 px` ตั้ง `AlwaysOnTop = false` ไม่ซ้อนทับบังตัวละครหรือ UI | [ ] ผ่าน |
| **UAT-7.4** | รันผ่าน Headless Test Suite เดิมใน Repo | โค้ดยังคงรองรับ Headless Test (`Fallback` เมื่อ `CreateHumanoidModelFromDescription` ไม่ทำงานใน CLI) และรักษา Workspace Attributes ครบทุกตัว | [ ] ผ่าน |
