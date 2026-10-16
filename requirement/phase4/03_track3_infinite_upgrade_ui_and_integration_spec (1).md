# ไฟล์ที่ 3: สเปกสั่งแก้ `PLAN-0009` (Track 3 — ย่อและจัดระเบียบ UI ใหม่ทั้งหมดเป็น Minimalist Flat HUD ไม่บังหน้าจอ)

> **อ้างอิงจากโค้ดจริงใน Repo**: [StangMKxD/anime-limitless-td](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td)  
> **ไฟล์เป้าหมายที่ต้องแก้**: [src/Track3\_UISystem/UpgradeHUD.client.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack3_UISystem%2FUpgradeHUD.client.luau) (1,263 บรรทัด) และ [src/Track3\_UpgradeServer/UpgradeServer.server.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack3_UpgradeServer%2FUpgradeServer.server.luau)  
> **รหัสแผนงาน**: `PLAN-0009` (Minimalist Non-Intrusive Flat UI Overhaul & Compact Wave Card Modal)  
> **กฎการทำงาน (`AGENTS.md`)**: `COMBO-07` | Strict SoD (`R01–R05`)

---

## 1. วิเคราะห์ปัญหาจากโค้ดจริงใน `UpgradeHUD.client.luau` (ทำไม UI ถึงใหญ่และบังกันมิด?)

จากการตรวจโค้ดจริง 1,263 บรรทัดใน [src/Track3\_UISystem/UpgradeHUD.client.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack3_UISystem%2FUpgradeHUD.client.luau) พบว่าหน้าจอถูกยัดด้วยกรอบ UI ขนาดใหญ่ถึง 5 ส่วนที่เปิดซ้อนกันตลอดเวลา:
1. **Top Wave Bar**: สูงและกว้างเกินไป กินพื้นที่กลางจอด้านบน
2. **Left Infinite Stat Upgrade Panel**: เปิดค้างไว้ด้านซ้ายตลอดเวลา กินพื้นที่ด้านซ้ายเกือบครึ่งจอ
3. **Bottom 8-Slot Unit Bag Deployment Bar**: การ์ดตัวละครด้านล่างใหญ่เกินไป กินพื้นที่ด้านล่างขึ้นมาสูงมาก
4. **Wanted Poster Gacha Modal & 3-Card Wave Draft Modal**: เมื่อเด้งขึ้นมาพร้อมกันหรือทับกับแผงซ้าย/ล่าง ทำให้มองไม่เห็นสนามรบตรงกลางและกดปุ่มวางป้อมไม่ได้เลย!

---

## 2. สเปกการจัดวาง UI ใหม่แบบ Minimalist Flat HUD (`PLAN-0009` — โล่งสบายตา เห็นสนามรบ 85% ของจอ!)

สั่งให้ AI แก้ไข `src/Track3_UISystem/UpgradeHUD.client.luau` โดยล็อกสัดส่วนพื้นที่หน้าจอ (Screen Budget) ไม่ให้เกิน **15% ของหน้าจอ** ในเวลาปกติ ตามตารางนี้:

| ส่วนประกอบ UI | ขนาดเดิม (ใหญ่บังจอ) | ขนาดและการจัดวางใหม่ใน `PLAN-0009` (Minimalist Flat) |
| :--- | :--- | :--- |
| **1. Top Status Pill (แถบเวฟ & เลือดฐานด้านบน)** | กล่องใหญ่ `480x82 px` | **แถบแคปซูลบางเฉียบบรรทัดเดียว ขนาด `340x30 px`** ชิดขอบบน (`Y = 6px`) พื้นหลังโปร่งแสง `0.35` แสดง `Wave 1 | HP: 1500 | $300` พร้อมปุ่ม `Skip` เล็กๆ ข้างขวา |
| **2. Bottom Hero Dock (แถบตัวละคร 8 ช่องด้านล่าง)** | การ์ดใบใหญ่สูงเกิน `90-110 px` | **แถบไอคอนสี่เหลี่ยมมินิมอลเรียบๆ ขนาดช่องละ `46x46 px`** (รวม 8 ช่องกว้างแค่ `396x52 px`) ชิดขอบล่างสุด (`Y = 1 - 58px`) แสดงเฉพาะสีประจำตัว ชื่อย่อ (`LUF`, `ZOR`, `SAN`, `SHA`) และราคาค่าวาง |
| **3. Side Upgrade & Gacha Panels (ร้านค้า & สุ่มกาชา)** | เปิดแผงใหญ่ค้างไว้ด้านซ้ายตลอดเวลา | **ซ่อนเก็บเป็นปุ่มไอคอนจิ๋ว 2 ปุ่มมุมซ้ายล่าง (`[▲ UPGRADE]` และ `[★ SUMMON]`) ขนาด `95x28 px`** เมื่อไม่ได้กดจะไม่มีแผงใดๆ บังด้านซ้ายจอเลย! พอกดถึงจะเปิดแผงขนาดกะทัดรัด (`220x210 px`) และกดซ้ำเพื่อพับเก็บได้ทันที |
| **4. Wave Card Draft Modal (การ์ดสุ่มอัปเกรดทุกเวฟ)** | หน้าต่างยักษ์ทับเต็มจอ | **แถบการ์ดแนวนอนขนาดกะทัดรัด `520x190 px`** ลอยอยู่ตรงกลางค่อนบน (`Position = UDim2.new(0.5, -260, 0, 52)`) การ์ดแต่ละใบขนาดเพียง `158x140 px` ดีไซน์แบนเรียบ (Flat Minimal) ไม่บังแถบวางตัวละครด้านล่าง และมีปุ่ม `[-]` ย่อ/ขยายได้! |

---

## 3. โค้ดโครงสร้าง Minimalist Flat Layout สำหรับอัปเดต `src/Track3_UISystem/UpgradeHUD.client.luau`

ให้ AI Implementer ปรับขนาด (`Size`), ตำแหน่ง (`Position`), และระบบพับเก็บหน้าต่าง (`Toggle Drawer`) ใน `src/Track3_UISystem/UpgradeHUD.client.luau` ตามสเปกโค้ดชุดนี้ (โดยคงการเชื่อมต่อ `RemoteEvent` ทั้งหมดไว้เหมือนเดิม 100%):

```luau
-- สเปกค่าคงที่สำหรับ Minimalist Flat UI (ใส่ไว้ต้นไฟล์ src/Track3_UISystem/UpgradeHUD.client.luau)
local UI_THEME = {
	BgDark = Color3.fromRGB(14, 16, 22),
	BgCard = Color3.fromRGB(22, 25, 34),
	AccentGold = Color3.fromRGB(245, 195, 55),
	AccentCyan = Color3.fromRGB(60, 200, 255),
	AccentRed = Color3.fromRGB(235, 65, 85),
	TextLight = Color3.fromRGB(240, 244, 250),
	TextMuted = Color3.fromRGB(160, 170, 185),
}

-- 1. Top Status Pill (บางเฉียบ 340x30 px ชิดขอบบนสุด ไม่บังสนามรบ)
local function createMinimalTopBar(screenGui: ScreenGui)
	local topPill = Instance.new("Frame")
	topPill.Name = "TopWaveBar"
	topPill.Size = UDim2.new(0, 360, 0, 30)
	topPill.Position = UDim2.new(0.5, -180, 0, 6)
	topPill.BackgroundColor3 = UI_THEME.BgDark
	topPill.BackgroundTransparency = 0.25
	topPill.BorderSizePixel = 0
	topPill.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0) -- ทรงแคปซูลโค้งมนเรียบหรู
	corner.Parent = topPill

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(60, 68, 85)
	stroke.Thickness = 1
	stroke.Parent = topPill

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusText"
	statusLabel.Size = UDim2.new(1, -80, 1, 0)
	statusLabel.Position = UDim2.new(0, 14, 0, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.GothamBold
	statusLabel.TextSize = 13
	statusLabel.TextColor3 = UI_THEME.TextLight
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.Text = "WAVE 1  •  HP 1500  •  $300"
	statusLabel.Parent = topPill

	local skipBtn = Instance.new("TextButton")
	skipBtn.Name = "EarlyStartBtn"
	skipBtn.Size = UDim2.new(0, 64, 0, 22)
	skipBtn.Position = UDim2.new(1, -68, 0.5, -11)
	skipBtn.BackgroundColor3 = UI_THEME.AccentGold
	skipBtn.Font = Enum.Font.GothamBlack
	skipBtn.TextSize = 11
	skipBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
	skipBtn.Text = "START"
	skipBtn.Parent = topPill

	local skipCorner = Instance.new("UICorner")
	skipCorner.CornerRadius = UDim.new(1, 0)
	skipCorner.Parent = skipBtn

	return topPill, statusLabel, skipBtn
end

-- 2. Bottom Compact Hero Dock (แถบสล็อตตัวละคร 8 ช่อง ขนาดเล็กเรียบหรู 46x46 px ต่อช่อง)
local function createCompactHeroDock(screenGui: ScreenGui)
	local dock = Instance.new("Frame")
	dock.Name = "CompactHeroDock"
	dock.Size = UDim2.new(0, 404, 0, 52)
	dock.Position = UDim2.new(0.5, -202, 1, -58)
	dock.BackgroundColor3 = UI_THEME.BgDark
	dock.BackgroundTransparency = 0.25
	dock.BorderSizePixel = 0
	dock.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = dock

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(55, 62, 78)
	stroke.Thickness = 1
	stroke.Parent = dock

	local slots = {}
	for i = 1, 8 do
		local btn = Instance.new("TextButton")
		btn.Name = "Slot_" .. i
		btn.Size = UDim2.new(0, 44, 0, 44)
		btn.Position = UDim2.new(0, 6 + (i - 1) * 49, 0, 4)
		btn.BackgroundColor3 = UI_THEME.BgCard
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 11
		btn.TextColor3 = UI_THEME.TextLight
		btn.Text = "-"
		btn.Parent = dock

		local sCorner = Instance.new("UICorner")
		sCorner.CornerRadius = UDim.new(0, 6)
		sCorner.Parent = btn

		local sStroke = Instance.new("UIStroke")
		sStroke.Color = Color3.fromRGB(70, 78, 95)
		sStroke.Thickness = 1
		sStroke.Parent = btn

		slots[i] = { Button = btn, Stroke = sStroke }
	end

	return dock, slots
end

-- 3. Collapsible Side Drawer (ซ่อนแผง Upgrade & Summon ไว้เป็นปุ่มเล็กๆ มุมซ้ายล่าง ไม่บังจอ!)
local function createCollapsibleDrawer(screenGui: ScreenGui)
	local toggleBar = Instance.new("Frame")
	toggleBar.Name = "MiniActionToggles"
	toggleBar.Size = UDim2.new(0, 100, 0, 64)
	toggleBar.Position = UDim2.new(0, 10, 1, -128)
	toggleBar.BackgroundTransparency = 1
	toggleBar.Parent = screenGui

	local upgToggle = Instance.new("TextButton")
	upgToggle.Name = "ToggleUpgradeBtn"
	upgToggle.Size = UDim2.new(1, 0, 0, 28)
	upgToggle.Position = UDim2.new(0, 0, 0, 0)
	upgToggle.BackgroundColor3 = UI_THEME.BgDark
	upgToggle.BackgroundTransparency = 0.2
	upgToggle.Font = Enum.Font.GothamBold
	upgToggle.TextSize = 11
	upgToggle.TextColor3 = UI_THEME.AccentCyan
	upgToggle.Text = "▲ STATS"
	upgToggle.Parent = toggleBar

	local uCorner = Instance.new("UICorner")
	uCorner.CornerRadius = UDim.new(0, 6)
	uCorner.Parent = upgToggle

	local gachaToggle = Instance.new("TextButton")
	gachaToggle.Name = "ToggleGachaBtn"
	gachaToggle.Size = UDim2.new(1, 0, 0, 28)
	gachaToggle.Position = UDim2.new(0, 0, 0, 34)
	gachaToggle.BackgroundColor3 = UI_THEME.BgDark
	gachaToggle.BackgroundTransparency = 0.2
	gachaToggle.Font = Enum.Font.GothamBold
	gachaToggle.TextSize = 11
	gachaToggle.TextColor3 = UI_THEME.AccentGold
	gachaToggle.Text = "★ SUMMON"
	gachaToggle.Parent = toggleBar

	local gCorner = Instance.new("UICorner")
	gCorner.CornerRadius = UDim.new(0, 6)
	gCorner.Parent = gachaToggle

	-- แผง Upgrade ขนาดกะทัดรัด (210x185 px) ซ่อนไว้เป็นค่าเริ่มต้น (Visible = false)
	local drawerFrame = Instance.new("Frame")
	drawerFrame.Name = "UpgradeShopFrame"
	drawerFrame.Size = UDim2.new(0, 210, 0, 185)
	drawerFrame.Position = UDim2.new(0, 10, 1, -320)
	drawerFrame.BackgroundColor3 = UI_THEME.BgDark
	drawerFrame.BackgroundTransparency = 0.15
	drawerFrame.Visible = false -- ซ่อนไว้ไม่ให้บังจอ กดปุ่ม ▲ STATS ค่อยเปิด
	drawerFrame.Parent = screenGui

	local dCorner = Instance.new("UICorner")
	dCorner.CornerRadius = UDim.new(0, 8)
	dCorner.Parent = drawerFrame

	upgToggle.MouseButton1Click:Connect(function()
		drawerFrame.Visible = not drawerFrame.Visible
	end)

	return drawerFrame, upgToggle, gachaToggle
end

-- 4. Compact Wave Card Draft Modal (แถบการ์ด 3 ใบขนาดเล็ก 500x175 px ลอยใต้ Top Bar ไม่บังป้อมและไม่ทับ Dock ด้านล่าง!)
local function createCompactWaveCardModal(screenGui: ScreenGui)
	local modal = Instance.new("Frame")
	modal.Name = "WaveCardDraftModal"
	modal.Size = UDim2.new(0, 500, 0, 175)
	modal.Position = UDim2.new(0.5, -250, 0, 44)
	modal.BackgroundColor3 = UI_THEME.BgDark
	modal.BackgroundTransparency = 0.15
	modal.BorderSizePixel = 0
	modal.Visible = false
	modal.Parent = screenGui

	local mCorner = Instance.new("UICorner")
	mCorner.CornerRadius = UDim.new(0, 10)
	mCorner.Parent = modal

	local mStroke = Instance.new("UIStroke")
	mStroke.Color = UI_THEME.AccentGold
	mStroke.Thickness = 1.5
	mStroke.Parent = modal

	local header = Instance.new("TextLabel")
	header.Name = "HeaderTitle"
	header.Size = UDim2.new(1, -110, 0, 24)
	header.Position = UDim2.new(0, 12, 0, 4)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.GothamBold
	header.TextSize = 12
	header.TextColor3 = UI_THEME.AccentGold
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Text = "SELECT WAVE UPGRADE CARD"
	header.Parent = modal

	local rerollBtn = Instance.new("TextButton")
	rerollBtn.Name = "RerollCardsBtn"
	rerollBtn.Size = UDim2.new(0, 88, 0, 20)
	rerollBtn.Position = UDim2.new(1, -96, 0, 6)
	rerollBtn.BackgroundColor3 = Color3.fromRGB(45, 85, 165)
	rerollBtn.Font = Enum.Font.GothamBold
	rerollBtn.TextSize = 10
	rerollBtn.TextColor3 = UI_THEME.TextLight
	rerollBtn.Text = "Reroll ($50)"
	rerollBtn.Parent = modal

	local rCorner = Instance.new("UICorner")
	rCorner.CornerRadius = UDim.new(0, 4)
	rCorner.Parent = rerollBtn

	local cards = {}
	for i = 1, 3 do
		local cBtn = Instance.new("TextButton")
		cBtn.Name = "UpgradeCard_" .. i
		cBtn.Size = UDim2.new(0, 154, 0, 134)
		cBtn.Position = UDim2.new(0, 10 + (i - 1) * 163, 0, 32)
		cBtn.BackgroundColor3 = UI_THEME.BgCard
		cBtn.Text = ""
		cBtn.Parent = modal

		local cCorner = Instance.new("UICorner")
		cCorner.CornerRadius = UDim.new(0, 8)
		cCorner.Parent = cBtn

		local cStroke = Instance.new("UIStroke")
		cStroke.Thickness = 1.5
		cStroke.Color = UI_THEME.AccentGold
		cStroke.Parent = cBtn

		local title = Instance.new("TextLabel")
		title.Name = "CardTitle"
		title.Size = UDim2.new(1, -12, 0, 36)
		title.Position = UDim2.new(0, 6, 0, 8)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBlack
		title.TextSize = 12
		title.TextWrapped = true
		title.TextColor3 = UI_THEME.TextLight
		title.Parent = cBtn

		local desc = Instance.new("TextLabel")
		desc.Name = "CardDesc"
		desc.Size = UDim2.new(1, -12, 0, 74)
		desc.Position = UDim2.new(0, 6, 0, 48)
		desc.BackgroundTransparency = 1
		desc.Font = Enum.Font.GothamMedium
		desc.TextSize = 11
		desc.TextWrapped = true
		desc.TextColor3 = Color3.fromRGB(110, 240, 155)
		desc.Parent = cBtn

		cards[i] = { Button = cBtn, Stroke = cStroke, Title = title, Desc = desc }
	end

	return modal, header, rerollBtn, cards
end
```

---

## 4. ตารางตรวจรับงาน `PLAN-0009` และ Master UAT (UI เรียบหรู ไม่บังจอ + เกมสมดุลโหดสะใจ)

| รหัส UAT | รายการทดสอบ | วิธีทดสอบใน Roblox Studio | ผลลัพธ์ที่ต้องเห็น (Expected Result) | สถานะ |
| :--- | :--- | :--- | :--- | :---: |
| **UAT-9.1** | หน้าจอหลักโล่งสบายตา (Minimalist HUD) | กด Play เข้าเกมแล้วมองภาพรวมหน้าจอ | แถบด้านบนเป็นแคปซูลเล็ก `360x30 px` แถบตัวละครด้านล่างสูงแค่ `52 px` และไม่มีแผงใหญ่ค้างบังด้านซ้ายจอ (เห็นสนามรบชัดเจนเกิน 85% ของจอ) | [ ] ผ่าน |
| **UAT-9.2** | ระบบพับเก็บแผง `STATS` และ `SUMMON` | คลิกปุ่ม `▲ STATS` และ `★ SUMMON` มุมซ้ายล่าง | กดแล้วเปิดแผงขนาดกะทัดรัด กดซ้ำหรือคลิกปิดแล้วพับเก็บหายไปทันที ไม่เกะกะเวลาวางป้อม | [ ] ผ่าน |
| **UAT-9.3** | การ์ดสุ่มอัปเกรดทุกเวฟแบบ Compact (`500x175 px`) | รอขึ้นเวฟใหม่ให้หน้าต่างเลือกการ์ดเด้งขึ้นมา | หน้าต่างการ์ด 3 ใบมีขนาดกะทัดรัด เรียบหรู ลอยอยู่ใต้ Top Bar ไม่บังแถบเลือกตัวละครด้านล่าง และหุบหายทันทีที่คลิกเลือก | [ ] ผ่าน |
| **UAT-9.4** | ทดสอบรวม 3 ระบบ (`PLAN-0007` + `0008` + `0009`) | วางตัวละคร One Piece ยิงซอมบี้ตั้งแต่เวฟ 1 ถึงเวฟ 5 | โมเดลตัวละครเป็นหุ่น R6 แท้ (หรือโมเดลจาก `HeroModels`), ปล่อยสกิลเสาแสง/หมัดยักษ์เต็มจอ, ศัตรูถึกขึ้นทุกเวฟอย่างท้าทาย และไม่มีป้ายชื่อหรือ UI ซ้อนทับกัน | [ ] ผ่าน |
