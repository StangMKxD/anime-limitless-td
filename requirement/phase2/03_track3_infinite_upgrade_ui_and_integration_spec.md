# ไฟล์ที่ 3: สเปกงานส่วนที่ 3 ระบบสุ่มการ์ดอัปเกรดเด้งขึ้นมาทุกเวฟ (One Piece Roguelike Wave Card Draft) และ Master UAT

เอกสารฉบับนี้อัปเดตใหม่ตามความต้องการล่าสุด: **เปลี่ยนจากร้านค้ากดปุ่มธรรมดา เป็นระบบ "การ์ดสุ่มอัปเกรด 3 ใบเด้งขึ้นมากลางหน้าจอทุกเวฟ (Wave Card Draft System)"** พร้อมระดับความหายากของการ์ด (**COMMON, EPIC, LEGENDARY, MYTHICAL YONKO**) และปุ่มใช้เงินค่าหัว (`Bounty Cash`) เพื่อ **Reroll สุ่มหน้าไพ่ใหม่** หรือ **ซื้อการ์ดพิเศษเพิ่มระหว่างเวฟ** ได้แบบไร้ขีดจำกัด!

---

## 1. รายชื่อการ์ดพลัง One Piece (Devil Fruit & Haki Cards) ที่สุ่มขึ้นมาให้เลือกทุกเวฟ

ทุกครั้งที่เริ่มเวฟใหม่ (หรือเมื่อ `PendingCardDraws > 0`) หน้าจอจะเด้งการ์ดสุ่ม 3 ใบจากคลังการ์ดระดับตำนานด้านล่างนี้:

| ชื่อการ์ดอัปเกรด (Card Title) | ระดับความหายาก (Rarity & สีกรอบการ์ด) | เอฟเฟกต์เมื่อกดเลือกการ์ด (Infinite Stacking Buff) |
| :--- | :--- | :--- |
| **1. Conqueror's Haki: Supreme King** *(ฮาคิราชันย์ขั้นสูง)* | **LEGENDARY (กรอบสีทอง)** | เพิ่มพลังโจมตี **`Damage +45% (+25 Flat)`** และเพิ่มโอกาสคริติคอล **`+8%`** |
| **2. Sun God Nika: Gear 5 Awakening** *(เกียร์ 5 เทพพระอาทิตย์นิกะ)* | **MYTHICAL YONKO (กรอบสีรุ้งแดง-ขาว)** | เพิ่มพลังโจมตี **`Damage +85% (+50 Flat)`** และลดคูลดาวน์โจมตี **`Speed -15%`** |
| **3. Observation Haki: Future Sight** *(ฮาคิสังเกตเห็นอนาคต)* | **EPIC (กรอบสีม่วง)** | เพิ่มระยะโจมตีของทุกตัวละคร **`Range +8 Studs`** และเพิ่มโอกาสคริติคอล **`+10%`** |
| **4. Gura Gura no Mi: Seaquake Impact** *(ผลสั่นสะเทือน หนวดขาว)* | **LEGENDARY (กรอบสีทอง)** | ขยายรัศมีระเบิดหมู่ **`AoE Splash Radius +5 Studs`** และเพิ่ม **`Damage +30%`** |
| **5. Ifrit Jambe & Enma Overdrive** *(เพลิงสีฟ้า & ดาบราชันย์นรก)* | **EPIC (กรอบสีม่วง)** | เร่งความเร็วโจมตี **`Cooldown -18%`** (โจมตีรัวขึ้น) และเพิ่ม **`Damage +20%`** |
| **6. Pirate King's Bounty Jackpot** *(สมบัติวันพีซ & ซ่อมเรือซันนี่)* | **COMMON / TACTICAL (กรอบสีฟ้าคราม)** | รับเงินค่าหัวทันที **`+$250 * Wave`** และฟื้นฟูเลือดฐานหลัก **`+400 HP`** |

---

## 2. โค้ดสำเร็จรูปส่วนที่ 3 (วางทับ 2 ไฟล์ใน Track 3 ได้เลย)

### 2.1 โค้ดฝั่ง Server: `src/Track3_UpgradeServer/UpgradeServer.server.luau`
คัดลอกโค้ดนี้ใส่ไฟล์ `src/Track3_UpgradeServer/UpgradeServer.server.luau`:

```luau
-- src/Track3_UpgradeServer/UpgradeServer.server.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

local upgradeRemote = ReplicatedStorage:FindFirstChild(GameConfig.REMOTES.UPGRADE_REQUEST)
if not upgradeRemote then
	upgradeRemote = Instance.new("RemoteEvent")
	upgradeRemote.Name = GameConfig.REMOTES.UPGRADE_REQUEST
	upgradeRemote.Parent = ReplicatedStorage
end

-- ระบบ Fallback ตั้งค่าเริ่มต้นให้ผู้เล่น (ทำให้เทส Track 3 เดี่ยวๆ ได้ทันทีแม้ไม่มี Track 1)
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
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT, GameConfig.INITIAL_PLAYER_STATS.SPLASH_STAT or 6)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE, GameConfig.INITIAL_PLAYER_STATS.CRIT_CHANCE or 15)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, 1)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL, 1)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL, 1)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, GameConfig.INITIAL_PLAYER_STATS.INITIAL_CARD_DRAWS or 1)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL, 0)
	end
end

Players.PlayerAdded:Connect(ensurePlayerStats)
for _, plr in ipairs(Players:GetPlayers()) do
	ensurePlayerStats(plr)
end

-- รับคำสั่งเลือกการ์ดเมื่อขึ้นเวฟใหม่ หรือคำสั่งใช้เงินซื้อสิทธิ์สุ่มการ์ดเพิ่ม
upgradeRemote.OnServerEvent:Connect(function(player: Player, actionOrCardId: string)
	ensurePlayerStats(player)
	local ls = player:FindFirstChild("leaderstats")
	local cash = ls and ls:FindFirstChild("Cash") :: IntValue?
	if not cash then
		return
	end

	-- กรณีผู้เล่นกดปุ่มใช้เงิน Bounty ซื้อสิทธิ์เปิดการ์ดเพิ่มพิเศษ
	if actionOrCardId == "BuyExtraCardDraw" then
		local totalPicked = (player:GetAttribute(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL) or 0) :: number
		local baseCost = GameConfig.WAVE_SETTINGS.EXTRA_CARD_BASE_COST or 150
		local drawCost = math.floor(baseCost * math.pow(1.25, totalPicked))
		if cash.Value >= drawCost then
			cash.Value -= drawCost
			local pending = (player:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) or 0) :: number
			player:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, pending + 1)
		end
		return
	end

	-- กรณีผู้เล่นกด Reroll เปลี่ยนหน้าไพ่ทั้ง 3 ใบ (ใช้เงิน $50)
	if actionOrCardId == "RerollCards" then
		if cash.Value >= 50 then
			cash.Value -= 50
		end
		return
	end

	-- ตรวจสอบว่ามีสิทธิ์เลือกการ์ดคงเหลือหรือไม่ (PendingCardDraws > 0)
	local pendingDraws = (player:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) or 0) :: number
	if pendingDraws <= 0 then
		return
	end

	local dmg = (player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) or 45) :: number
	local rng = (player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) or 36) :: number
	local cd = (player:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) or 0.95) :: number
	local splash = (player:GetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT) or 6) :: number
	local crit = (player:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE) or 15) :: number
	local dmgLvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL) or 1) :: number
	local rngLvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL) or 1) :: number
	local spdLvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL) or 1) :: number
	local totalPicked = (player:GetAttribute(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL) or 0) :: number

	-- ประมวลผลบัฟจากการ์ดที่ผู้เล่นเลือก
	if actionOrCardId == "Card_ConquerorHaki" or actionOrCardId == "Damage" then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, math.floor(dmg * 1.45 + 25))
		player:SetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE, math.min(100, crit + 8))
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, dmgLvl + 1)
	elseif actionOrCardId == "Card_Gear5Nika" then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, math.floor(dmg * 1.85 + 50))
		player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, math.max(GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN, math.floor(cd * 0.85 * 100) / 100))
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, dmgLvl + 2)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL, spdLvl + 1)
	elseif actionOrCardId == "Card_ObservationHaki" or actionOrCardId == "Range" then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT, rng + 8)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE, math.min(100, crit + 10))
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL, rngLvl + 1)
	elseif actionOrCardId == "Card_GuraQuake" then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT, splash + 5)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, math.floor(dmg * 1.30 + 15))
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, dmgLvl + 1)
	elseif actionOrCardId == "Card_IfritOverdrive" or actionOrCardId == "Speed" then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, math.max(GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN, math.floor(cd * 0.82 * 100) / 100))
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, math.floor(dmg * 1.20 + 10))
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL, spdLvl + 1)
	elseif actionOrCardId == "Card_BountyJackpot" then
		local wave = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE) or 1) :: number
		cash.Value += (250 * wave)
		local baseHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) or 1500) :: number
		local maxBaseHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP) or 1500) :: number
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, math.min(maxBaseHp, baseHp + 400))
	else
		return
	end

	-- หักสิทธิ์การ์ดที่เลือกไป 1 ใบ และบันทึกจำนวนการ์ดที่สะสมทั้งหมด
	player:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, math.max(0, pendingDraws - 1))
	player:SetAttribute(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL, totalPicked + 1)
end)
```

### 2.2 โค้ดฝั่ง Client: `src/Track3_UISystem/UpgradeHUD.client.luau`
คัดลอกโค้ดนี้ใส่ไฟล์ `src/Track3_UISystem/UpgradeHUD.client.luau`:

```luau
-- src/Track3_UISystem/UpgradeHUD.client.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local upgradeRemote = ReplicatedStorage:WaitForChild(GameConfig.REMOTES.UPGRADE_REQUEST) :: RemoteEvent

-- คลังการ์ด One Piece สำหรับสุ่มขึ้นมาทุกเวฟ
local CARD_POOL = {
	{
		Id = "Card_ConquerorHaki",
		Rarity = "LEGENDARY HAKI",
		Title = "CONQUEROR'S HAKI: SUPREME KING",
		Subtitle = "ฮาคิราชันย์หุ้มการโจมตีขั้นสูง",
		Desc = "+45% DAMAGE (+25 Flat)\n+8% CRITICAL CHANCE",
		BorderColor = Color3.fromRGB(255, 200, 40),
		BgColor = Color3.fromRGB(55, 35, 15),
	},
	{
		Id = "Card_Gear5Nika",
		Rarity = "MYTHICAL YONKO",
		Title = "SUN GOD NIKA: GEAR 5 AWAKENING",
		Subtitle = "พลังตื่นผลฮิโตะฮิโตะ โมเดลนิกะ",
		Desc = "+85% DAMAGE (+50 Flat)\n-15% ATTACK COOLDOWN",
		BorderColor = Color3.fromRGB(255, 45, 85),
		BgColor = Color3.fromRGB(65, 18, 35),
	},
	{
		Id = "Card_ObservationHaki",
		Rarity = "EPIC HAKI",
		Title = "OBSERVATION HAKI: FUTURE SIGHT",
		Subtitle = "ฮาคิสังเกตมองเห็นอนาคต",
		Desc = "+8 STUDS ATTACK RANGE\n+10% CRITICAL CHANCE",
		BorderColor = Color3.fromRGB(185, 70, 255),
		BgColor = Color3.fromRGB(38, 20, 60),
	},
	{
		Id = "Card_GuraQuake",
		Rarity = "LEGENDARY DEVIL FRUIT",
		Title = "GURA GURA NO MI: SEAQUAKE",
		Subtitle = "ผลสั่นสะเทือน ถล่มสมรภูมิวงกว้าง",
		Desc = "+5 STUDS AoE SPLASH RADIUS\n+30% DAMAGE (+15 Flat)",
		BorderColor = Color3.fromRGB(255, 180, 30),
		BgColor = Color3.fromRGB(50, 38, 18),
	},
	{
		Id = "Card_IfritOverdrive",
		Rarity = "EPIC COMBAT ARTS",
		Title = "IFRIT JAMBE & ENMA OVERDRIVE",
		Subtitle = "เร่งความเร็วโจมตีทะลุขีดจำกัด",
		Desc = "-18% ATTACK COOLDOWN\n+20% DAMAGE (+10 Flat)",
		BorderColor = Color3.fromRGB(0, 215, 255),
		BgColor = Color3.fromRGB(16, 40, 58),
	},
	{
		Id = "Card_BountyJackpot",
		Rarity = "GRAND LINE TREASURE",
		Title = "PIRATE KING BOUNTY JACKPOT",
		Subtitle = "รับค่าหัวก้อนโต & ซ่อมแซมฐานซันนี่",
		Desc = "+$250 x WAVE BOUNTY CASH\n+400 BASE HP RESTORE",
		BorderColor = Color3.fromRGB(70, 245, 130),
		BgColor = Color3.fromRGB(18, 48, 30),
	},
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OnePieceTD_CardHUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 1. แถบด้านบนแสดง Wave และเลือดฐาน Road Poneglyph
local topFrame = Instance.new("Frame")
topFrame.Name = "TopWaveBar"
topFrame.Size = UDim2.new(0, 480, 0, 82)
topFrame.Position = UDim2.new(0.5, -240, 0, 10)
topFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
topFrame.BorderSizePixel = 0
topFrame.Parent = screenGui

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topFrame

local topStroke = Instance.new("UIStroke")
topStroke.Color = Color3.fromRGB(255, 195, 45)
topStroke.Thickness = 2
topStroke.Parent = topFrame

local waveLabel = Instance.new("TextLabel")
waveLabel.Size = UDim2.new(1, -20, 0, 34)
waveLabel.Position = UDim2.new(0, 10, 0, 6)
waveLabel.BackgroundTransparency = 1
waveLabel.Font = Enum.Font.GothamBlack
waveLabel.TextColor3 = Color3.fromRGB(255, 215, 60)
waveLabel.TextScaled = true
waveLabel.Text = "GRAND LINE WAVE 1 | ENEMIES: 0"
waveLabel.Parent = topFrame

local hpBarBg = Instance.new("Frame")
hpBarBg.Size = UDim2.new(1, -24, 0, 26)
hpBarBg.Position = UDim2.new(0, 12, 0, 44)
hpBarBg.BackgroundColor3 = Color3.fromRGB(45, 20, 28)
hpBarBg.BorderSizePixel = 0
hpBarBg.Parent = topFrame

local hpBarFill = Instance.new("Frame")
hpBarFill.Size = UDim2.new(1, 0, 1, 0)
hpBarFill.BackgroundColor3 = Color3.fromRGB(255, 195, 40)
hpBarFill.BorderSizePixel = 0
hpBarFill.Parent = hpBarBg

local hpText = Instance.new("TextLabel")
hpText.Size = UDim2.new(1, 0, 1, 0)
hpText.BackgroundTransparency = 1
hpText.Font = Enum.Font.GothamBold
hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
hpText.TextScaled = true
hpText.Text = "THOUSAND SUNNY BASE HP: 1500 / 1500"
hpText.Parent = hpBarBg

-- 2. แผงสรุปสเตตัสทีมหมวกฟาง + ปุ่มซื้อการ์ดเพิ่มด้านซ้ายจอ
local sidePanel = Instance.new("Frame")
sidePanel.Name = "CrewStatsPanel"
sidePanel.Size = UDim2.new(0, 265, 0, 240)
sidePanel.Position = UDim2.new(0, 16, 0.5, -120)
sidePanel.BackgroundColor3 = Color3.fromRGB(16, 18, 28)
sidePanel.BorderSizePixel = 0
sidePanel.Parent = screenGui

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 12)
sideCorner.Parent = sidePanel

local sideStroke = Instance.new("UIStroke")
sideStroke.Color = Color3.fromRGB(0, 210, 255)
sideStroke.Thickness = 2
sideStroke.Parent = sidePanel

local statsTitle = Instance.new("TextLabel")
statsTitle.Size = UDim2.new(1, -16, 0, 30)
statsTitle.Position = UDim2.new(0, 8, 0, 8)
statsTitle.BackgroundTransparency = 1
statsTitle.Font = Enum.Font.GothamBlack
statsTitle.TextColor3 = Color3.fromRGB(0, 225, 255)
statsTitle.TextScaled = true
statsTitle.Text = "STRAW HAT CREW STATS"
statsTitle.Parent = sidePanel

local statsBody = Instance.new("TextLabel")
statsBody.Size = UDim2.new(1, -20, 0, 125)
statsBody.Position = UDim2.new(0, 10, 0, 42)
statsBody.BackgroundTransparency = 1
statsBody.Font = Enum.Font.GothamBold
statsBody.TextColor3 = Color3.fromRGB(240, 245, 255)
statsBody.TextXAlignment = Enum.TextXAlignment.Left
statsBody.TextScaled = true
statsBody.Parent = sidePanel

local buyCardBtn = Instance.new("TextButton")
buyCardBtn.Name = "BuyExtraCardBtn"
buyCardBtn.Size = UDim2.new(1, -20, 0, 54)
buyCardBtn.Position = UDim2.new(0, 10, 1, -64)
buyCardBtn.BackgroundColor3 = Color3.fromRGB(215, 145, 20)
buyCardBtn.Font = Enum.Font.GothamBlack
buyCardBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
buyCardBtn.TextScaled = true
buyCardBtn.Text = "DRAW BONUS HAKI CARD ($150)"
buyCardBtn.Parent = sidePanel

local buyBtnCorner = Instance.new("UICorner")
buyBtnCorner.CornerRadius = UDim.new(0, 8)
buyBtnCorner.Parent = buyCardBtn

buyCardBtn.MouseButton1Click:Connect(function()
	upgradeRemote:FireServer("BuyExtraCardDraw")
end)

-- 3. หน้าต่างการ์ดสุ่มอัปเกรด 3 ใบกลางหน้าจอ (เด้งขึ้นมาทุกเวฟ!)
local draftOverlay = Instance.new("Frame")
draftOverlay.Name = "WaveCardDraftModal"
draftOverlay.Size = UDim2.new(0, 760, 0, 410)
draftOverlay.Position = UDim2.new(0.5, -380, 0.5, -185)
draftOverlay.BackgroundColor3 = Color3.fromRGB(12, 14, 22)
draftOverlay.BackgroundTransparency = 0.06
draftOverlay.BorderSizePixel = 0
draftOverlay.Visible = false
draftOverlay.Parent = screenGui

local draftCorner = Instance.new("UICorner")
draftCorner.CornerRadius = UDim.new(0, 16)
draftCorner.Parent = draftOverlay

local draftStroke = Instance.new("UIStroke")
draftStroke.Color = Color3.fromRGB(255, 210, 55)
draftStroke.Thickness = 3
draftStroke.Parent = draftOverlay

local draftHeader = Instance.new("TextLabel")
draftHeader.Size = UDim2.new(1, -30, 0, 44)
draftHeader.Position = UDim2.new(0, 15, 0, 12)
draftHeader.BackgroundTransparency = 1
draftHeader.Font = Enum.Font.GothamBlack
draftHeader.TextColor3 = Color3.fromRGB(255, 220, 60)
draftHeader.TextScaled = true
draftHeader.Text = "WAVE CLEAR! SELECT YOUR ONE PIECE POWER CARD (1 LEFT)"
draftHeader.Parent = draftOverlay

local rerollBtn = Instance.new("TextButton")
rerollBtn.Name = "RerollCardsBtn"
rerollBtn.Size = UDim2.new(0, 240, 0, 40)
rerollBtn.Position = UDim2.new(0.5, -120, 1, -50)
rerollBtn.BackgroundColor3 = Color3.fromRGB(50, 95, 195)
rerollBtn.Font = Enum.Font.GothamBlack
rerollBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rerollBtn.TextScaled = true
rerollBtn.Text = "REROLL CARDS ($50 BOUNTY)"
rerollBtn.Parent = draftOverlay

local rerollCorner = Instance.new("UICorner")
rerollCorner.CornerRadius = UDim.new(0, 8)
rerollCorner.Parent = rerollBtn

-- สร้างการ์ด 3 ใบเรียงกันกลางจอ
local cardSlots = {}
for i = 1, 3 do
	local cardBtn = Instance.new("TextButton")
	cardBtn.Name = "UpgradeCard_" .. i
	cardBtn.Size = UDim2.new(0, 225, 0, 275)
	cardBtn.Position = UDim2.new(0, 25 + (i - 1) * 242, 0, 66)
	cardBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 45)
	cardBtn.Text = ""
	cardBtn.AutoButtonColor = true
	cardBtn.Parent = draftOverlay

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 14)
	cCorner.Parent = cardBtn

	local cStroke = Instance.new("UIStroke")
	cStroke.Thickness = 3
	cStroke.Color = Color3.fromRGB(255, 200, 50)
	cStroke.Parent = cardBtn

	local rarityLbl = Instance.new("TextLabel")
	rarityLbl.Size = UDim2.new(1, -16, 0, 26)
	rarityLbl.Position = UDim2.new(0, 8, 0, 10)
	rarityLbl.BackgroundTransparency = 1
	rarityLbl.Font = Enum.Font.GothamBlack
	rarityLbl.TextScaled = true
	rarityLbl.Parent = cardBtn

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -16, 0, 62)
	titleLbl.Position = UDim2.new(0, 8, 0, 42)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Font = Enum.Font.GothamBlack
	titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLbl.TextScaled = true
	titleLbl.Parent = cardBtn

	local subLbl = Instance.new("TextLabel")
	subLbl.Size = UDim2.new(1, -16, 0, 28)
	subLbl.Position = UDim2.new(0, 8, 0, 108)
	subLbl.BackgroundTransparency = 1
	subLbl.Font = Enum.Font.GothamBold
	subLbl.TextColor3 = Color3.fromRGB(210, 215, 230)
	subLbl.TextScaled = true
	subLbl.Parent = cardBtn

	local descBox = Instance.new("TextLabel")
	descBox.Size = UDim2.new(1, -20, 0, 85)
	descBox.Position = UDim2.new(0, 10, 0, 142)
	descBox.BackgroundColor3 = Color3.fromRGB(15, 16, 24)
	descBox.BackgroundTransparency = 0.25
	descBox.Font = Enum.Font.GothamBlack
	descBox.TextColor3 = Color3.fromRGB(90, 255, 145)
	descBox.TextScaled = true
	descBox.Parent = cardBtn

	local chooseBadge = Instance.new("TextLabel")
	chooseBadge.Size = UDim2.new(1, -24, 0, 32)
	chooseBadge.Position = UDim2.new(0, 12, 1, -40)
	chooseBadge.BackgroundColor3 = Color3.fromRGB(255, 200, 40)
	chooseBadge.Font = Enum.Font.GothamBlack
	chooseBadge.TextColor3 = Color3.fromRGB(20, 20, 25)
	chooseBadge.TextScaled = true
	chooseBadge.Text = "CLICK TO AWAKEN"
	chooseBadge.Parent = cardBtn

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 6)
	badgeCorner.Parent = chooseBadge

	cardSlots[i] = {
		Button = cardBtn,
		Stroke = cStroke,
		Rarity = rarityLbl,
		Title = titleLbl,
		Subtitle = subLbl,
		Desc = descBox,
		Badge = chooseBadge,
		CurrentCardId = "Card_ConquerorHaki",
	}

	cardBtn.MouseButton1Click:Connect(function()
		upgradeRemote:FireServer(cardSlots[i].CurrentCardId)
	end)
end

-- สุ่มการ์ด 3 ใบไม่ซ้ำกันขึ้นมาแสดงบนหน้าจอ
local function rollThreeCards()
	local indices = { 1, 2, 3, 4, 5, 6 }
	for i = #indices, 2, -1 do
		local j = math.random(1, i)
		indices[i], indices[j] = indices[j], indices[i]
	end

	for slotIdx = 1, 3 do
		local cardData = CARD_POOL[indices[slotIdx]]
		local slot = cardSlots[slotIdx]
		slot.CurrentCardId = cardData.Id
		slot.Button.BackgroundColor3 = cardData.BgColor
		slot.Stroke.Color = cardData.BorderColor
		slot.Rarity.TextColor3 = cardData.BorderColor
		slot.Rarity.Text = "★ " .. cardData.Rarity .. " ★"
		slot.Title.Text = cardData.Title
		slot.Subtitle.Text = cardData.Subtitle
		slot.Desc.Text = cardData.Desc
		slot.Badge.BackgroundColor3 = cardData.BorderColor
	end
end

rerollBtn.MouseButton1Click:Connect(function()
	local ls = localPlayer:FindFirstChild("leaderstats")
	local cash = ls and ls:FindFirstChild("Cash") :: IntValue?
	if cash and cash.Value >= 50 then
		upgradeRemote:FireServer("RerollCards")
		rollThreeCards()
	end
end)

local lastPendingCount = 0

local function refreshUI()
	local wave = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE) or 1
	local zombiesLeft = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING) or 0
	local baseHp = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) or 1500
	local maxBaseHp = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP) or 1500
	local isGameOver = Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == true

	if isGameOver then
		waveLabel.Text = "SUNNY DESTROYED! REBUILDING AT WAVE 1..."
	else
		waveLabel.Text = string.format("GRAND LINE WAVE %d  |  ENEMIES: %d", wave, zombiesLeft)
	end

	local hpRatio = math.clamp(baseHp / math.max(1, maxBaseHp), 0, 1)
	hpBarFill.Size = UDim2.new(hpRatio, 0, 1, 0)
	hpText.Text = string.format("THOUSAND SUNNY BASE HP: %d / %d", baseHp, maxBaseHp)

	local ls = localPlayer:FindFirstChild("leaderstats")
	local cashVal = ls and ls:FindFirstChild("Cash")
	local currentCash = cashVal and cashVal.Value or 0

	local dmg = localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) or 45
	local rng = localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) or 36
	local cd = localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) or 0.95
	local splash = localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT) or 6
	local crit = localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE) or 15
	local pendingDraws = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) or 0) :: number
	local totalPicked = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL) or 0) :: number

	local dps = math.floor(dmg / math.max(0.12, cd))
	statsBody.Text = string.format(
		"BOUNTY: $%d\nCREW DPS: %d/s\nHAKI DMG: %d  |  CRIT: %d%%\nRANGE: %d  |  AoE: %d\nSPEED: %.2fs  |  CARDS: %d",
		currentCash,
		dps,
		dmg,
		crit,
		rng,
		splash,
		cd,
		totalPicked
	)

	local baseDrawCost = GameConfig.WAVE_SETTINGS.EXTRA_CARD_BASE_COST or 150
	local nextDrawCost = math.floor(baseDrawCost * math.pow(1.25, totalPicked))
	buyCardBtn.Text = string.format("BUY EXTRA HAKI CARD\nCost: $%d Bounty", nextDrawCost)

	-- แสดงหรือซ่อนหน้าต่างการ์ดสุ่มอัปเกรด 3 ใบเมื่อมี PendingCardDraws > 0
	if pendingDraws > 0 then
		if not draftOverlay.Visible or pendingDraws ~= lastPendingCount then
			rollThreeCards()
		end
		draftOverlay.Visible = true
		draftHeader.Text = string.format("WAVE %d AWAKENING! CHOOSE 1 ONE PIECE CARD (%d DRAW LEFT)", wave, pendingDraws)
	else
		draftOverlay.Visible = false
	end
	lastPendingCount = pendingDraws
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

rollThreeCards()
refreshUI()
```

---

## 3. ตารางตรวจรับเกมฉบับสมบูรณ์ (Master UAT - One Piece & Wave Card Edition)

| รหัส Master UAT | การทำงานร่วมกันของทั้ง 3 ระบบ | วิธีทดสอบจริงใน Roblox Studio | ผลลัพธ์ที่คาดหวัง (Expected Outcome) | สถานะ |
| :--- | :--- | :--- | :--- | :--- |
| **M-UAT-01** | **Wave Card Pop-up**: การ์ดสุ่มอัปเกรด 3 ใบเด้งขึ้นมาทุกเวฟ | กด Play เข้าเกมเวฟ 1 และรอจนจบเวฟ 1 เข้าสู่เวฟ 2 | ทันทีที่เริ่มเกมและทุกครั้งที่ขึ้นเวฟใหม่ หน้าต่าง **การ์ดพลัง One Piece 3 ใบ** จะเด้งขึ้นมาให้เลือกตรงกลางจออัตโนมัติ | [ ] ผ่าน |
| **M-UAT-02** | **Card Selection & Buff**: คลิกเลือกการ์ดแล้วสเตตัสกลุ่มหมวกฟางพุ่งขึ้นทันที | คลิกเลือกการ์ด `GEAR 5 AWAKENING` หรือ `CONQUEROR'S HAKI` | หน้าต่างการ์ดปิดลง ค่า `HAKI DMG`, `CRIT`, `AoE` หรือ `RANGE` ด้านซ้ายเพิ่มขึ้นทันที และป้อมตัวละคร One Piece ทั้ง 6 ตัวเก่งขึ้นทันที | [ ] ผ่าน |
| **M-UAT-03** | **One Piece R6 Models & VFX**: โมเดล 6 ตำนานวันพีซปล่อยท่าไม้ตาย | ซูมดูป้อมทั้ง 6 ตัวขณะซอมบี้เดินผ่าน | เห็น **Luffy, Zoro, Sanji, Ace, Law, Shanks** โครงกระดูก R6 ปล่อยหมัดสายฟ้าฮาคิราชันย์ โดม `ROOM` และลูกไฟ `Entei` | [ ] ผ่าน |
| **M-UAT-04** | **Reroll & Bonus Card Draw**: ใช้เงิน Bounty สุ่มไพ่ใหม่หรือซื้อการ์ดเพิ่ม | กดปุ่ม `REROLL CARDS ($50)` หรือกดปุ่มสีทอง `BUY EXTRA HAKI CARD` ด้านซ้ายจอ | เมื่อกด Reroll หน้าไพ่ทั้ง 3 ใบจะสุ่มใหม่ทันที และเมื่อกดซื้อการ์ดเพิ่ม หน้าต่างเลือกการ์ดจะเด้งขึ้นมาให้เลือกเพิ่มได้เรื่อยๆ ไม่จำกัด | [ ] ผ่าน |
| **M-UAT-05** | **Wave 5 Yonko Kaido Boss**: บอสจักรพรรดิไคโดและการ์ดรางวัล 2 ใบ | เล่นไปจนถึง `WAVE 5` | มีบอส `YONKO KAIDO` ตัวใหญ่มีเขามังกรสีทองเดินออกมา พร้อมแจกสิทธิ์เลือกการ์ดอัปเกรดพิเศษ `2 ใบ` ในเวฟบอส! | [ ] ผ่าน |
