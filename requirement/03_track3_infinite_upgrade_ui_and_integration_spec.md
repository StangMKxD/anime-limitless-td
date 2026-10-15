# ไฟล์ที่ 3: สเปกงานส่วนที่ 3 ระบบ UI อัปเกรดสเตตัสไร้ขีดจำกัด ขั้นตอนรวมทั้ง 3 Worktree และ Master UAT ตรวจรับเกมสมบูรณ์

เอกสารฉบับนี้เป็นคู่มือจับมือทำแบบละเอียดสำหรับ **งานส่วนที่ 3 (Track 3: หน้าจอ HUD แสดงสถานะเวฟ/เลือดฐาน และร้านค้าอัปเกรดสเตตัสไร้ขีดจำกัดทั้งฝั่ง Client และ Server)** พร้อม **ขั้นตอนการ Merge รวมงานทั้ง 3 Worktrees เข้าด้วยกันใน 1 นาที** และตาราง **Master UAT** สำหรับตรวจรับเกมฉบับสมบูรณ์

---

## 1. ขอบเขตงานและข้อตกลงการแยกไฟล์ (Spec & Scope - Track 3)

| หัวข้อ | รายละเอียดของงานส่วนที่ 3 |
| :--- | :--- |
| **Git Branch** | `feat/track3-ui` |
| **โฟลเดอร์ Worktree** | `../wt-track3-ui` |
| **ไฟล์ที่อนุญาตให้สร้าง/แก้ไข** | 1. `src/Track3_UpgradeServer/UpgradeServer.server.luau`<br>2. `src/Track3_UISystem/UpgradeHUD.client.luau`<br>*(ห้ามแตะโฟลเดอร์ของ Track 1 และ Track 2 เด็ดขาด)* |
| **พอร์ต Rojo สำหรับเทสแยก** | `34873` (`rojo serve --port 34873`) |
| **ฟีเจอร์ที่รับผิดชอบ** | สร้าง `RemoteEvent` สำหรับซื้ออัปเกรด คำนวณราคาอัปเกรดแบบทวีคูณไร้ขีดจำกัด หัก `Cash` ของผู้เล่น เพิ่มค่า `DamageStat`, `RangeStat`, `CooldownStat` และสร้างหน้าจอ UI สไตล์อนิเมะอัตโนมัติ |

### สูตรการคำนวณอัปเกรดไร้ขีดจำกัด (Infinite Progression Formulas)
1. **Upgrade Anime Damage (อัปเกรดพลังโจมตีไร้ขีดจำกัด)**:
   * ราคาเริ่มต้น `75 Cash` | ราคาครั้งถัดไป = `math.floor(75 * (1.35 ^ (DamageLevel - 1)))`
   * พลังโจมตีใหม่ = เพิ่มขึ้น `+35%` ต่อเลเวล (`math.floor(CurrentDamage * 1.35 + 10)`)
2. **Upgrade Spirit Range (อัปเกรดระยะยิง)**:
   * ราคาเริ่มต้น `60 Cash` | ราคาครั้งถัดไป = `math.floor(60 * (1.30 ^ (RangeLevel - 1)))`
   * ระยะยิงใหม่ = เพิ่มขึ้น `+4 Studs` ต่อเลเวลเรื่อยๆ ไม่จำกัด
3. **Upgrade Attack Speed (อัปเกรดความเร็วปล่อยพลัง)**:
   * ราคาเริ่มต้น `90 Cash` | ราคาครั้งถัดไป = `math.floor(90 * (1.40 ^ (SpeedLevel - 1)))`
   * คูลดาวน์ใหม่ = ลดเวลาชาร์จยิงลง `10%` ต่อเลเวล (`math.max(0.12, CurrentCooldown * 0.90)`)

---

## 2. ขั้นตอนจับมือทำ: สั่ง AI หน้าต่างที่ 3 (`../wt-track3-ui`)

### 2.1 เปิดหน้าต่าง AI Agent ตัวที่ 3
1. เปิด Terminal หรือหน้าต่างโปรแกรม AI (Cursor / Claude Code / Windsurf) หน้าต่างที่ 3
2. เข้าไปยังโฟลเดอร์ Worktree ที่ 3:
   ```bash
   cd ../wt-track3-ui
   git branch
   # ต้องขึ้นว่า * feat/track3-ui
   ```

### 2.2 Prompt สำหรับก๊อปปี้ไปสั่ง AI Agent หน้าต่างที่ 3
> "คุณกำลังทำงานใน Git Worktree `feat/track3-ui` ให้สร้างไฟล์ 2 ไฟล์คือ `src/Track3_UpgradeServer/UpgradeServer.server.luau` และ `src/Track3_UISystem/UpgradeHUD.client.luau` เท่านั้น (ห้ามแก้ไขไฟล์นอก 2 โฟลเดอร์นี้เด็ดขาด) โดยอ้างอิงค่าจาก `ReplicatedStorage.Shared.GameConfig`:
> 1. ใน `UpgradeServer.server.luau` ให้สร้าง `RemoteEvent` ชื่อ `UpgradeStatRequest` ใน `ReplicatedStorage` พร้อมระบบตรวจสอบและตั้งค่าเริ่มต้นของ `leaderstats.Cash` และ Player Attributes (เผื่อกรณีรันเทสแยกเดี่ยวๆ) และเมื่อผู้เล่นส่งคำขออัปเกรด (`Damage`, `Range`, `Speed`) ให้เช็คเงิน หักเงิน และคูณเพิ่มค่าสเตตัสแบบไร้ขีดจำกัด
> 2. ใน `UpgradeHUD.client.luau` ให้สร้าง `ScreenGui` ด้วยโค้ดทั้งหมด มีแถบด้านบนแสดง `WAVE`, `ZOMBIES LEFT`, `BASE HP` (พร้อมหลอดเลือดฐาน) และมีแผงร้านค้าด้านซ้ายมือสำหรับกดปุ่มอัปเกรดทั้ง 3 สาย แสดงเลเวลปัจจุบัน ค่าสเตตัส ราคาอัปเกรด และค่า `DPS` รวมแบบสดๆ เมื่อเขียนเสร็จให้ git add และ git commit ลง branch `feat/track3-ui`"

### 2.3 โค้ดสำเร็จรูปไฟล์ที่ 3.1: `src/Track3_UpgradeServer/UpgradeServer.server.luau`
คัดลอกโค้ดนี้ใส่ไฟล์ `src/Track3_UpgradeServer/UpgradeServer.server.luau`:

```luau
-- src/Track3_UpgradeServer/UpgradeServer.server.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

-- สร้าง RemoteEvent สำหรับรับคำสั่งอัปเกรดจาก UI
local upgradeRemote = ReplicatedStorage:FindFirstChild(GameConfig.REMOTES.UPGRADE_REQUEST)
if not upgradeRemote then
	upgradeRemote = Instance.new("RemoteEvent")
	upgradeRemote.Name = GameConfig.REMOTES.UPGRADE_REQUEST
	upgradeRemote.Parent = ReplicatedStorage
end

-- ระบบ Fallback ตั้งค่าเริ่มต้นให้ผู้เล่น (ทำให้เทส Worktree ที่ 3 เดี่ยวๆ ได้ทันทีแม้ยังไม่ได้รวม Track 1)
local function ensurePlayerStats(player: Player)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then
		ls = Instance.new("Folder")
		ls.Name = "leaderstats"
		ls.Parent = player
	end

	local cash = ls:FindFirstChild("Cash")
	if not cash then
		cash = Instance.new("IntValue")
		cash.Name = "Cash"
		cash.Value = GameConfig.INITIAL_PLAYER_STATS.CASH
		cash.Parent = ls
	end

	if player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) == nil then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, GameConfig.INITIAL_PLAYER_STATS.DAMAGE_STAT)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT, GameConfig.INITIAL_PLAYER_STATS.RANGE_STAT)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, GameConfig.INITIAL_PLAYER_STATS.COOLDOWN_STAT)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, 1)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL, 1)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL, 1)
	end
end

Players.PlayerAdded:Connect(ensurePlayerStats)
for _, plr in ipairs(Players:GetPlayers()) do
	ensurePlayerStats(plr)
end

-- ฟังก์ชันคำนวณราคาอัปเกรดตามเลเวลปัจจุบัน
local function getUpgradeCost(upgradeType: string, currentLevel: number): number
	if upgradeType == "Damage" then
		return math.floor(75 * math.pow(1.35, currentLevel - 1))
	elseif upgradeType == "Range" then
		return math.floor(60 * math.pow(1.30, currentLevel - 1))
	elseif upgradeType == "Speed" then
		return math.floor(90 * math.pow(1.40, currentLevel - 1))
	end
	return 999999
end

upgradeRemote.OnServerEvent:Connect(function(player: Player, upgradeType: string)
	ensurePlayerStats(player)
	local ls = player:FindFirstChild("leaderstats")
	local cash = ls and ls:FindFirstChild("Cash") :: IntValue?
	if not cash then
		return
	end

	if upgradeType == "Damage" then
		local lvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL) or 1) :: number
		local cost = getUpgradeCost("Damage", lvl)
		if cash.Value >= cost then
			cash.Value -= cost
			local currentDmg = (player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) or 35) :: number
			local nextDmg = math.floor(currentDmg * 1.35 + 10)
			player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, nextDmg)
			player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, lvl + 1)
		end
	elseif upgradeType == "Range" then
		local lvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL) or 1) :: number
		local cost = getUpgradeCost("Range", lvl)
		if cash.Value >= cost then
			cash.Value -= cost
			local currentRange = (player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) or 32) :: number
			player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT, currentRange + 4)
			player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL, lvl + 1)
		end
	elseif upgradeType == "Speed" then
		local lvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL) or 1) :: number
		local cost = getUpgradeCost("Speed", lvl)
		local currentCd = (player:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) or 1.0) :: number
		if cash.Value >= cost and currentCd > GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN then
			cash.Value -= cost
			local nextCd = math.max(GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN, math.floor(currentCd * 0.90 * 100) / 100)
			player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, nextCd)
			player:SetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL, lvl + 1)
		end
	end
end)
```

### 2.4 โค้ดสำเร็จรูปไฟล์ที่ 3.2: `src/Track3_UISystem/UpgradeHUD.client.luau`
คัดลอกโค้ดนี้ใส่ไฟล์ `src/Track3_UISystem/UpgradeHUD.client.luau`:

```luau
-- src/Track3_UISystem/UpgradeHUD.client.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local upgradeRemote = ReplicatedStorage:WaitForChild(GameConfig.REMOTES.UPGRADE_REQUEST) :: RemoteEvent

-- สร้าง ScreenGui หลัก
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimeTD_HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 1. แถบด้านบนแสดง Wave และเลือดฐานคริสตัล (Top Status Bar)
local topFrame = Instance.new("Frame")
topFrame.Name = "TopWaveBar"
topFrame.Size = UDim2.new(0, 420, 0, 76)
topFrame.Position = UDim2.new(0.5, -210, 0, 12)
topFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 34)
topFrame.BorderSizePixel = 0
topFrame.Parent = screenGui

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topFrame

local waveLabel = Instance.new("TextLabel")
waveLabel.Size = UDim2.new(1, -20, 0, 32)
waveLabel.Position = UDim2.new(0, 10, 0, 6)
waveLabel.BackgroundTransparency = 1
waveLabel.Font = Enum.Font.GothamBlack
waveLabel.TextColor3 = Color3.fromRGB(255, 215, 60)
waveLabel.TextScaled = true
waveLabel.Text = "WAVE 1 | ZOMBIES: 0"
waveLabel.Parent = topFrame

local hpBarBg = Instance.new("Frame")
hpBarBg.Size = UDim2.new(1, -24, 0, 24)
hpBarBg.Position = UDim2.new(0, 12, 0, 42)
hpBarBg.BackgroundColor3 = Color3.fromRGB(45, 25, 30)
hpBarBg.BorderSizePixel = 0
hpBarBg.Parent = topFrame

local hpBarFill = Instance.new("Frame")
hpBarFill.Size = UDim2.new(1, 0, 1, 0)
hpBarFill.BackgroundColor3 = Color3.fromRGB(0, 215, 255)
hpBarFill.BorderSizePixel = 0
hpBarFill.Parent = hpBarBg

local hpText = Instance.new("TextLabel")
hpText.Size = UDim2.new(1, 0, 1, 0)
hpText.BackgroundTransparency = 1
hpText.Font = Enum.Font.GothamBold
hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
hpText.TextScaled = true
hpText.Text = "CRYSTAL BASE HP: 1000 / 1000"
hpText.Parent = hpBarBg

-- 2. แผงร้านค้าอัปเกรดสเตตัสไร้ขีดจำกัดด้านซ้ายจอ (Infinite Upgrade Panel)
local shopFrame = Instance.new("Frame")
shopFrame.Name = "UpgradeShopFrame"
shopFrame.Size = UDim2.new(0, 290, 0, 340)
shopFrame.Position = UDim2.new(0, 16, 0.5, -170)
shopFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
shopFrame.BorderSizePixel = 0
shopFrame.Parent = screenGui

local shopCorner = Instance.new("UICorner")
shopCorner.CornerRadius = UDim.new(0, 12)
shopCorner.Parent = shopFrame

local shopHeader = Instance.new("TextLabel")
shopHeader.Size = UDim2.new(1, -16, 0, 36)
shopHeader.Position = UDim2.new(0, 8, 0, 8)
shopHeader.BackgroundTransparency = 1
shopHeader.Font = Enum.Font.GothamBlack
shopHeader.TextColor3 = Color3.fromRGB(0, 230, 255)
shopHeader.TextScaled = true
shopHeader.Text = "ANIME POWER UPGRADES"
shopHeader.Parent = shopFrame

local cashDisplay = Instance.new("TextLabel")
cashDisplay.Size = UDim2.new(1, -16, 0, 28)
cashDisplay.Position = UDim2.new(0, 8, 0, 44)
cashDisplay.BackgroundTransparency = 1
cashDisplay.Font = Enum.Font.GothamBold
cashDisplay.TextColor3 = Color3.fromRGB(80, 255, 130)
cashDisplay.TextScaled = true
cashDisplay.Text = "CASH: $300 | DPS: 35/s"
cashDisplay.Parent = shopFrame

local function createUpgradeButton(name: string, yPos: number, accentColor: Color3, upgradeType: string)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(1, -24, 0, 74)
	btn.Position = UDim2.new(0, 12, 0, yPos)
	btn.BackgroundColor3 = accentColor
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.AutoButtonColor = true
	btn.Parent = shopFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		upgradeRemote:FireServer(upgradeType)
	end)

	return btn
end

local dmgBtn = createUpgradeButton("DamageBtn", 82, Color3.fromRGB(190, 45, 70), "Damage")
local rangeBtn = createUpgradeButton("RangeBtn", 168, Color3.fromRGB(45, 115, 200), "Range")
local speedBtn = createUpgradeButton("SpeedBtn", 254, Color3.fromRGB(130, 50, 200), "Speed")

-- 3. ฟังก์ชันอัปเดตตัวเลขบน UI แบบเรียลไทม์
local function refreshUI()
	local wave = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE) or 1
	local zombiesLeft = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING) or 0
	local baseHp = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) or 1000
	local maxBaseHp = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP) or 1000
	local isGameOver = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == true

	if isGameOver then
		waveLabel.Text = "BASE DESTROYED! RESTARTING WAVE 1..."
	else
		waveLabel.Text = string.format("WAVE %d  |  ZOMBIES: %d", wave, zombiesLeft)
	end

	local hpRatio = math.clamp(baseHp / math.max(1, maxBaseHp), 0, 1)
	hpBarFill.Size = UDim2.new(hpRatio, 0, 1, 0)
	hpText.Text = string.format("CRYSTAL BASE HP: %d / %d", baseHp, maxBaseHp)

	local ls = localPlayer:FindFirstChild("leaderstats")
	local cashVal = ls and ls:FindFirstChild("Cash")
	local currentCash = cashVal and cashVal.Value or 0

	local dmg = localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) or 35
	local rng = localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) or 32
	local cd = localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) or 1.0

	local dmgLvl = localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL) or 1
	local rngLvl = localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL) or 1
	local spdLvl = localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL) or 1

	local dmgCost = math.floor(75 * math.pow(1.35, dmgLvl - 1))
	local rngCost = math.floor(60 * math.pow(1.30, rngLvl - 1))
	local spdCost = math.floor(90 * math.pow(1.40, spdLvl - 1))

	local dps = math.floor(dmg / math.max(0.12, cd))
	cashDisplay.Text = string.format("CASH: $%d  |  TOWER DPS: %d/s", currentCash, dps)

	dmgBtn.Text = string.format("[Lv.%d] UPGRADE ANIME DAMAGE\nDMG: %d -> %d  |  Cost: $%d", dmgLvl, dmg, math.floor(dmg * 1.35 + 10), dmgCost)
	rangeBtn.Text = string.format("[Lv.%d] UPGRADE SPIRIT RANGE\nRange: %d -> %d  |  Cost: $%d", rngLvl, rng, rng + 4, rngCost)

	if cd <= GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN then
		speedBtn.Text = string.format("[MAX] ATTACK SPEED LIMIT\nCooldown: %.2fs (MAX SPEED)", cd)
	else
		speedBtn.Text = string.format("[Lv.%d] UPGRADE ATTACK SPEED\nCooldown: %.2fs -> %.2fs  |  Cost: $%d", spdLvl, cd, math.max(0.12, cd * 0.9), spdCost)
	end
end

Workspace.AttributeChanged:Connect(refreshUI)
localPlayer.AttributeChanged:Connect(refreshUI)

task.spawn(function()
	local ls = localPlayer:WaitForChild("leaderstats", 10)
	if ls then
		local cash = ls:WaitForChild("Cash", 10) :: IntValue?
		if cash then
			cash.Changed:Connect(refreshUI)
		end
	end
	refreshUI()
end)

refreshUI()
```

---

## 3. ตารางตรวจรับงานเฉพาะส่วนที่ 3 (UAT Track 3 - เทสแยกเดี่ยวได้ทันที)

ใน Terminal หน้าต่างที่ 3 (`../wt-track3-ui`) ให้รัน `rojo serve --port 34873` แล้วกด Connect ใน Studio เพื่อตรวจตามตารางนี้:

| รหัส UAT | รายการทดสอบ (Test Case) | วิธีทดสอบใน Roblox Studio | ผลลัพธ์ที่ต้องเห็น (Expected Result) | สถานะ |
| :--- | :--- | :--- | :--- | :--- |
| **UAT-3.1** | การแสดงผลหน้าจอ HUD และร้านค้าอัปเกรด | กด Play ใน Roblox Studio | มีแถบสถานะ `WAVE 1` และหลอดเลือด `CRYSTAL BASE HP` ด้านบนจอ พร้อมแผงปุ่มอัปเกรด 3 ปุ่มด้านซ้ายจอ | [ ] ผ่าน |
| **UAT-3.2** | การกดอัปเกรด Damage และหักเงินอัตโนมัติ | คลิกปุ่มสีแดง `UPGRADE ANIME DAMAGE` (ราคา `$75`) | เงิน `CASH` ลดจาก `$300` เหลือ `$225` ทันที เลเวลปุ่มเพิ่มเป็น `[Lv.2]` ค่า `DMG` เพิ่มจาก `35` เป็น `57` และราคาครั้งถัดไปปรับเป็น `$101` | [ ] ผ่าน |
| **UAT-3.3** | การกดอัปเกรด Range และ Speed | คลิกปุ่มสีน้ำเงิน (`Range`) และปุ่มสีม่วง (`Speed`) อย่างละ 1 ครั้ง | ค่า `Range` เพิ่มจาก `32` เป็น `36` และค่า `Cooldown` ลดจาก `1.00s` เหลือ `0.90s` พร้อมตัวเลข `TOWER DPS` ที่คำนวณใหม่ทันที | [ ] ผ่าน |
| **UAT-3.4** | การป้องกันการกดซื้อเมื่อเงินไม่พอ | กดปุ่มอัปเกรดรัวๆ จนเงิน `CASH` น้อยกว่าราคาปุ่ม | เมื่อเงินไม่พอ กดปุ่มแล้วเงินไม่ติดลบ และเลเวลไม่อัปเกรดมั่ว | [ ] ผ่าน |
| **UAT-3.5** | การแยกไฟล์ไม่ชนกับงานอื่น (Git Isolation Check) | รันคำสั่ง `git status` ในโฟลเดอร์ `../wt-track3-ui` | มีไฟล์เฉพาะใน `src/Track3_UpgradeServer/` และ `src/Track3_UISystem/` เท่านั้น | [ ] ผ่าน |

---

## 4. ขั้นตอนรวมร่างทั้ง 3 Worktrees เข้าด้วยกัน (Zero-Conflict Merge ภายใน 1 นาที)

เมื่อ AI ทั้ง 3 หน้าต่างทำงานเสร็จและ Commit ลง Branch ของตัวเองเรียบร้อยแล้ว ให้คุณกลับมาที่โฟลเดอร์หลัก (`anime-td-repo` บน Branch `main`) แล้วรันคำสั่งรวมงานดังนี้:

```bash
# 1. กลับมาที่โฟลเดอร์หลัก (main branch)
cd ../anime-td-repo

# 2. เช็คสถานะของทุก Worktree ว่า Commit งานครบหรือยัง
git worktree list
git branch -a

# 3. Merge ทั้ง 3 Branches เข้าสู่ main (จะไม่มี Conflict เลยเพราะแยกโฟลเดอร์กัน 100%)
git merge feat/track1-wave -m "feat: merge Track 1 wave and infinite zombie system"
git merge feat/track2-towers -m "feat: merge Track 2 anime towers and evolution VFX"
git merge feat/track3-ui -m "feat: merge Track 3 infinite upgrade UI and server handler"

# 4. รัน Rojo Serve ตัวสมบูรณ์เพื่อซิงค์ทั้ง 3 ระบบเข้า Roblox Studio พร้อมกัน!
rojo serve --port 34872
```

---

## 5. ตารางตรวจรับเกมฉบับสมบูรณ์ (Master End-to-End UAT ทั้ง 3 งานรวมกัน)

หลังจากรัน `rojo serve --port 34872` จาก Branch `main` ที่รวมทั้ง 3 งานแล้ว ให้กด **Play (F5)** ใน Roblox Studio เพื่อตรวจเช็คความสมบูรณ์ของเกมทั้งหมด:

| รหัส Master UAT | การทำงานร่วมกันของทั้ง 3 ระบบ | วิธีทดสอบจริงในเกม | ผลลัพธ์ที่คาดหวัง (Expected Outcome) | สถานะ |
| :--- | :--- | :--- | :--- | :--- |
| **M-UAT-01** | **Track 1 + Track 2**: ซอมบี้เกิดตามเวฟและป้อมอนิเมะยิงสกัดอัตโนมัติ | กด Play แล้วดูซอมบี้เดินออกจากจุดที่ 1 ผ่านหน้าป้อมอนิเมะทั้ง 6 ตัว | ยูนิตอนิเมะหันหน้าล็อกเป้าซอมบี้แล้วยิงลำแสงสีฟ้าใส่ซอมบี้จนหลอดเลือดบนหัวซอมบี้ลดลงเรื่อยๆ | [ ] ผ่าน |
| **M-UAT-02** | **Track 1 + Track 3**: ซอมบี้ตายแล้วเงินเข้ากระเป๋า นำไปกดอัปเกรดต่อได้ | รอให้ป้อมยิงซอมบี้ตาย 2-3 ตัว แล้วสังเกตตัวเลข `CASH` บน UI ด้านซ้าย | ทุกครั้งที่ซอมบี้ตาย ค่า `CASH` บน UI เพิ่มขึ้นทันที และสามารถกดปุ่มอัปเกรดสเตตัสได้ต่อเนื่อง | [ ] ผ่าน |
| **M-UAT-03** | **Track 3 + Track 2**: กดปุ่มอัปเกรดบน UI แล้วป้อมอนิเมะเก่งขึ้นและเปลี่ยนร่างทันที | กดปุ่ม `UPGRADE ANIME DAMAGE` และ `UPGRADE SPIRIT RANGE` จน `DMG` เกิน `100` และ `400` | ทันทีที่กดปุ่ม วงแหวนระยะยิงของป้อมขยายกว้างขึ้นทันที และเมื่อ `DMG >= 100` ออร่าป้อมเปลี่ยนเป็นสีม่วง (`AWAKENED SORCERER`) เมื่อ `DMG >= 400` เปลี่ยนเป็นสีทองพร้อมยิงระเบิดหมู่ (AoE) | [ ] ผ่าน |
| **M-UAT-04** | **All Tracks (Wave 5 Boss Test)**: ทดสอบบอสประจำทุกๆ 5 เวฟ | เล่นไปจนถึง `WAVE 5` (หรือปรับ `CurrentWave` เป็น `5`) | มีซอมบี้บอสตัวใหญ่สีแดงออร่าทอง (`BOSS`) เลือดสูงกว่าปกติ 4 เท่าเดินออกมา และเมื่อช่วยกันยิงตายจะได้เงินรางวัลคูณ 3 เท่า | [ ] ผ่าน |
| **M-UAT-05** | **Endless Loop Recovery**: ระบบรีเซ็ตเวฟเมื่อฐานแตกโดยสเตตัสผู้เล่นไม่หาย | ปล่อยให้ซอมบี้หลุดเข้าคริสตัลจน `CRYSTAL BASE HP` เหลือ `0` | ป้ายด้านบนขึ้นว่า `BASE DESTROYED! RESTARTING WAVE 1...` พัก 5 วินาทีแล้วเริ่มเวฟ 1 ใหม่ โดยที่เลเวลอัปเกรดและร่างอนิเมะของผู้เล่นยังคงอยู่ครบ | [ ] ผ่าน |
