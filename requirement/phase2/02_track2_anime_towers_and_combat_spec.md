# ไฟล์ที่ 2: สเปกงานส่วนที่ 2 ปั้นโมเดล 6 ตัวละครตำนาน One Piece (R6 Rig) และท่าไม้ตายปล่อยพลังสุดอลังการ

เอกสารฉบับนี้อัปเดตใหม่ตามความต้องการล่าสุด: **ให้โค้ดปั้นหุ่น R6 ตัวละครจาก One Piece ทั้ง 6 ตัวพร้อมเครื่องแต่งกายและอาวุธเอกลักษณ์ (ลูฟี่, โซโล, ซันจิ, เอส, ลอว์, แชงคูส)** และ **ปล่อยท่าไม้ตายเอฟเฟกต์อลังการระดับจักรพรรดิ (หมัดยักษ์เกียร์ 5, พายุคลื่นดาบเอ็นมะ, เสาเพลิงเอส, โดมผ่าตัด ROOM ของลอว์, และสายฟ้าฮาคิราชันย์สีแดง-ดำของแชงคูส)**

---

## 1. รายชื่อ 6 ตัวละคร One Piece ที่สคริปต์ปั้นโมเดล R6 และเสกท่าไม้ตายให้อัตโนมัติ

| ตำแหน่งป้อม | ชื่อตัวละคร One Piece | จุดเด่นโมเดล R6 ที่โค้ดปั้นให้ (Procedural 3D Parts) | ท่าไม้ตายปล่อยพลัง (Signature Ultimate VFX) |
| :--- | :--- | :--- | :--- |
| **Unit 1** | **Monkey D. Luffy** *(ลูฟี่ หมวกฟาง / Gear 5)* | เสื้อกั๊กแดง กางเกงน้ำเงิน **หมวกฟางสีเหลืองคาดแถบแดง** และวงแหวนเมฆขาวเกียร์ 5 ลอยรอบคอ | **Gomu Gomu no Bajrang Gun**: หมัดยักษ์ติดฮาคิพุ่งกระแทกเป้าหมายพร้อมสายฟ้าฮาคิสีแดง-ดำ |
| **Unit 2** | **Roronoa Zoro** *(โซโล 3 ดาบราชันย์นรก)* | ชุดคลุมสีเขียว ผ้าโพกหัวดำ **ดาบคาบที่ปาก 1 เล่ม + ดาบเอ็นมะเรืองแสงสีม่วงในมือ 2 เล่ม** | **King of Hell: Onigiri**: พายุคลื่นดาบสีเขียวมรกต-ม่วงทมิฬหมุนฟัน 360 องศา |
| **Unit 3** | **Vinsmoke Sanji** *(ซันจิ ขาดำ อิฟริตแจมบ์)* | สูทสีดำ เนคไทเหลือง ผมสีทองปาดข้าง **ขาขวาติดไฟสีฟ้าคราม (`Ifrit Jambe`) ตลอดเวลา** | **Boeuf Burst Blue Flame**: คลื่นลูกเตะเพลิงสีฟ้าครามระเบิดเสาไฟเผาซอมบี้เป็นกลุ่ม |
| **Unit 4** | **Portgas D. Ace** *(เอส หมัดอัคคี)* | หมวกคาวบอยสีส้ม กางเกงดำ สร้อยลูกปัดแดง **มือขวาถือลูกไฟดวงอาทิตย์ยักษ์** | **Dai Enkai: Entei (จักรพรรดิเพลิง)**: ปล่อยลูกบอลพระอาทิตย์เพลิงยักษ์ระเบิดคลื่นไฟวงกว้าง |
| **Unit 5** | **Trafalgar Law** *(ลอว์ ศัลยแพทย์แห่งความตาย)* | หมวกขนสัตว์ลายจุดขาว-ดำ เสื้อฮู้ดเหลือง-ดำ **ถือดาบยาว Kikoku คาดหลัง** | **K-ROOM: Shock Wille**: กางโดมโปร่งแสงสีฟ้า `ROOM` ครอบศัตรูแล้วผ่าด้วยสายฟ้าศัลยกรรมสีฟ้า |
| **Unit 6** | **Red-Haired Shanks** *(แชงคูส ผมแดง)* | ผมสีแดงเข้ม เสื้อคลุมไหล่จักรพรรดิสีดำ **ถือดาบ Gryphon อาบออร่าฮาคิราชันย์สีแดงฉาน** | **Kamusari (เทวทัณฑ์)**: ฟาดคลื่นดาบสายฟ้าฮาคิราชันย์สีแดง-ดำซิกแซกผ่าทะลวงเป้าหมาย |

---

## 2. โค้ดสำเร็จรูป `src/Track2_TowerSystem/TowerController.server.luau`

คัดลอกโค้ดด้านล่างไปวางทับในไฟล์ `src/Track2_TowerSystem/TowerController.server.luau` ได้เลย:

```luau
-- src/Track2_TowerSystem/TowerController.server.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

-- 1. ข้อมูลตัวละคร One Piece ทั้ง 6 ตัว (สีชุด อาวุธ และสีท่าไม้ตาย)
local ONE_PIECE_HEROES = {
	{
		Id = "Luffy",
		DisplayName = "MONKEY D. LUFFY",
		Title = "SUN GOD NIKA [GEAR 5]",
		Position = Vector3.new(-42, 3, -28),
		TorsoColor = Color3.fromRGB(210, 35, 45),
		LegsColor = Color3.fromRGB(40, 85, 175),
		HairColor = Color3.fromRGB(20, 20, 25),
		PrimaryVFXColor = Color3.fromRGB(255, 40, 75),
		SecondaryVFXColor = Color3.fromRGB(255, 255, 255),
		AttackStyle = "BajrangFist",
	},
	{
		Id = "Zoro",
		DisplayName = "RORONOA ZORO",
		Title = "KING OF HELL [ENMA]",
		Position = Vector3.new(-32, 3, -8),
		TorsoColor = Color3.fromRGB(30, 105, 55),
		LegsColor = Color3.fromRGB(25, 30, 35),
		HairColor = Color3.fromRGB(60, 210, 95),
		PrimaryVFXColor = Color3.fromRGB(50, 255, 130),
		SecondaryVFXColor = Color3.fromRGB(185, 60, 255),
		AttackStyle = "EnmaSlash",
	},
	{
		Id = "Sanji",
		DisplayName = "VINSMOKE SANJI",
		Title = "IFRIT JAMBE [BLUE FLAME]",
		Position = Vector3.new(-10, 3, 8),
		TorsoColor = Color3.fromRGB(25, 25, 35),
		LegsColor = Color3.fromRGB(20, 20, 30),
		HairColor = Color3.fromRGB(255, 215, 55),
		PrimaryVFXColor = Color3.fromRGB(0, 195, 255),
		SecondaryVFXColor = Color3.fromRGB(200, 245, 255),
		AttackStyle = "IfritKick",
	},
	{
		Id = "Ace",
		DisplayName = "PORTGAS D. ACE",
		Title = "FLAME EMPEROR [MERA MERA]",
		Position = Vector3.new(10, 3, 8),
		TorsoColor = Color3.fromRGB(235, 185, 145),
		LegsColor = Color3.fromRGB(30, 30, 35),
		HairColor = Color3.fromRGB(25, 25, 30),
		PrimaryVFXColor = Color3.fromRGB(255, 110, 20),
		SecondaryVFXColor = Color3.fromRGB(255, 220, 60),
		AttackStyle = "EnteiSun",
	},
	{
		Id = "Law",
		DisplayName = "TRAFALGAR LAW",
		Title = "SURGEON OF DEATH [K-ROOM]",
		Position = Vector3.new(32, 3, -5),
		TorsoColor = Color3.fromRGB(240, 190, 40),
		LegsColor = Color3.fromRGB(35, 45, 75),
		HairColor = Color3.fromRGB(245, 245, 250),
		PrimaryVFXColor = Color3.fromRGB(65, 225, 255),
		SecondaryVFXColor = Color3.fromRGB(180, 100, 255),
		AttackStyle = "RoomShock",
	},
	{
		Id = "Shanks",
		DisplayName = "RED-HAIRED SHANKS",
		Title = "CONQUEROR HAKI [KAMUSARI]",
		Position = Vector3.new(44, 3, -18),
		TorsoColor = Color3.fromRGB(235, 235, 240),
		LegsColor = Color3.fromRGB(115, 45, 45),
		HairColor = Color3.fromRGB(200, 30, 40),
		PrimaryVFXColor = Color3.fromRGB(255, 15, 45),
		SecondaryVFXColor = Color3.fromRGB(25, 10, 20),
		AttackStyle = "KamusariHaki",
	},
}

-- 2. ดึงค่าสเตตัสรวมที่ผู้เล่นอัปเกรดจากการ์ดทุกเวฟ
local function getCurrentCombatStats()
	local maxDamage = GameConfig.INITIAL_PLAYER_STATS.DAMAGE_STAT
	local maxRange = GameConfig.INITIAL_PLAYER_STATS.RANGE_STAT
	local minCooldown = GameConfig.INITIAL_PLAYER_STATS.COOLDOWN_STAT
	local maxSplash = GameConfig.INITIAL_PLAYER_STATS.SPLASH_STAT or 6
	local maxCrit = GameConfig.INITIAL_PLAYER_STATS.CRIT_CHANCE or 15

	for _, plr in ipairs(Players:GetPlayers()) do
		local d = plr:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT)
		local r = plr:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT)
		local c = plr:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT)
		local s = plr:GetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT)
		local cr = plr:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE)
		if typeof(d) == "number" and d > maxDamage then maxDamage = d end
		if typeof(r) == "number" and r > maxRange then maxRange = r end
		if typeof(c) == "number" and c < minCooldown then minCooldown = c end
		if typeof(s) == "number" and s > maxSplash then maxSplash = s end
		if typeof(cr) == "number" and cr > maxCrit then maxCrit = cr end
	end

	return maxDamage, maxRange, math.max(GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN, minCooldown), maxSplash, maxCrit
end

-- 3. ฟังก์ชันสร้างสายฟ้าฮาคิราชันย์ซิกแซก (Conqueror's Haki Lightning)
local function spawnHakiLightning(startPos: Vector3, endPos: Vector3, color: Color3)
	local segments = 4
	local prev = startPos
	for i = 1, segments do
		local alpha = i / segments
		local jitter = (i < segments)
				and Vector3.new(math.random(-25, 25) / 10, math.random(-15, 25) / 10, math.random(-25, 25) / 10)
			or Vector3.zero
		local nextPos = startPos:Lerp(endPos, alpha) + jitter
		local dist = (nextPos - prev).Magnitude
		local bolt = Instance.new("Part")
		bolt.Name = "HakiLightningBolt"
		bolt.Anchored = true
		bolt.CanCollide = false
		bolt.Material = Enum.Material.Neon
		bolt.Color = color
		bolt.Size = Vector3.new(0.45, 0.45, dist)
		bolt.CFrame = CFrame.lookAt((prev + nextPos) / 2, nextPos)
		bolt.Parent = Workspace

		TweenService:Create(bolt, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.05, 0.05, dist),
			Transparency = 1,
		}):Play()
		task.delay(0.28, function()
			if bolt then bolt:Destroy() end
		end)
		prev = nextPos
	end
end

-- 4. ระบบปล่อยท่าไม้ตาย One Piece สุดอลังการแยกตามตัวละคร!
local function playOnePieceUltimateVFX(heroConfig, originPos: Vector3, targetPos: Vector3, splashRadius: number, isCrit: boolean)
	local style = heroConfig.AttackStyle
	local pColor = heroConfig.PrimaryVFXColor
	local sColor = heroConfig.SecondaryVFXColor
	local effectScale = isCrit and 1.45 or 1.0

	-- ปล่อยสายฟ้าฮาคิราชันย์ทุกครั้งที่โจมตีติดคริติคอล หรือเป็นท่าของลูฟี่/แชงคูส
	if isCrit or style == "KamusariHaki" or style == "BajrangFist" then
		spawnHakiLightning(originPos, targetPos, Color3.fromRGB(255, 20, 55))
		spawnHakiLightning(targetPos, targetPos + Vector3.new(0, 12 * effectScale, 0), Color3.fromRGB(25, 10, 20))
	end

	if style == "RoomShock" then
		-- ท่าของ Trafalgar Law: กางโดมทรงกลมสีฟ้า ROOM แล้วผ่าด้วยเสาสายฟ้าศัลยกรรม
		local roomDome = Instance.new("Part")
		roomDome.Name = "OpeOpeRoomDome"
		roomDome.Shape = Enum.PartType.Ball
		roomDome.Anchored = true
		roomDome.CanCollide = false
		roomDome.Material = Enum.Material.ForceField
		roomDome.Color = pColor
		roomDome.Size = Vector3.new(2, 2, 2)
		roomDome.Position = targetPos
		roomDome.Transparency = 0.25
		roomDome.Parent = Workspace

		local domeSize = math.max(14, splashRadius * 2.2) * effectScale
		TweenService:Create(roomDome, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new(domeSize, domeSize, domeSize),
			Transparency = 0.95,
		}):Play()
		task.delay(0.35, function()
			if roomDome then roomDome:Destroy() end
		end)
	elseif style == "EnteiSun" then
		-- ท่าของ Portgas D. Ace: ลูกบอลพระอาทิตย์เพลิงยักษ์ Dai Enkai: Entei พุ่งตกใส่เป้าหมาย
		local sunBall = Instance.new("Part")
		sunBall.Name = "AceEnteiSun"
		sunBall.Shape = Enum.PartType.Ball
		sunBall.Anchored = true
		sunBall.CanCollide = false
		sunBall.Material = Enum.Material.Neon
		sunBall.Color = pColor
		sunBall.Size = Vector3.new(7, 7, 7) * effectScale
		sunBall.Position = originPos + Vector3.new(0, 8, 0)
		sunBall.Parent = Workspace

		TweenService:Create(sunBall, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = targetPos,
			Size = Vector3.new(splashRadius * 2.1, splashRadius * 2.1, splashRadius * 2.1) * effectScale,
			Transparency = 0.85,
		}):Play()
		task.delay(0.22, function()
			if sunBall then sunBall:Destroy() end
		end)
	elseif style == "EnmaSlash" or style == "KamusariHaki" then
		-- ท่าคลื่นดาบยักษ์ของ Zoro และ Shanks: จันทร์เสี้ยวคลื่นดาบ + เสาพายุหมุน
		local crescent = Instance.new("Part")
		crescent.Name = "HakiSwordSlashWave"
		crescent.Anchored = true
		crescent.CanCollide = false
		crescent.Material = Enum.Material.Neon
		crescent.Color = pColor
		crescent.Size = Vector3.new(0.6, 8 * effectScale, 10 * effectScale)
		crescent.CFrame = CFrame.lookAt(originPos, targetPos)
		crescent.Parent = Workspace

		TweenService:Create(crescent, TweenInfo.new(0.22, Enum.EasingStyle.Linear), {
			CFrame = CFrame.lookAt(targetPos, targetPos + (targetPos - originPos).Unit) * CFrame.Angles(0, 0, math.rad(45)),
			Size = Vector3.new(0.2, 12 * effectScale, 16 * effectScale),
			Transparency = 1,
		}):Play()
		task.delay(0.25, function()
			if crescent then crescent:Destroy() end
		end)
	end

	-- ลำแสงหลักและวงแหวนคลื่นกระแทก (Shockwave Ring) ที่จุดปะทะสำหรับทุกตัวละคร
	local dist = (targetPos - originPos).Magnitude
	local beam = Instance.new("Part")
	beam.Name = "OnePieceSignatureBeam"
	beam.Anchored = true
	beam.CanCollide = false
	beam.Material = Enum.Material.Neon
	beam.Color = pColor
	beam.Size = Vector3.new(1.6 * effectScale, 1.6 * effectScale, dist)
	beam.CFrame = CFrame.lookAt((originPos + targetPos) / 2, targetPos)
	beam.Parent = Workspace

	local shockRing = Instance.new("Part")
	shockRing.Name = "HakiShockwave"
	shockRing.Shape = Enum.PartType.Cylinder
	shockRing.Anchored = true
	shockRing.CanCollide = false
	shockRing.Material = Enum.Material.Neon
	shockRing.Color = sColor
	shockRing.Size = Vector3.new(0.4, 3, 3)
	shockRing.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, 0, math.rad(90))
	shockRing.Parent = Workspace

	local endDiameter = math.max(10, splashRadius * 2.2) * effectScale
	TweenService:Create(beam, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.1, 0.1, dist),
		Transparency = 1,
	}):Play()

	TweenService:Create(shockRing, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.1, endDiameter, endDiameter),
		Transparency = 1,
	}):Play()

	task.delay(0.3, function()
		if beam then beam:Destroy() end
		if shockRing then shockRing:Destroy() end
	end)
end

-- 5. ฟังก์ชันปั้นหุ่น R6 ตัวละคร One Piece ทั้ง 6 ตัวพร้อมหมวกฟาง ดาบ 3 เล่ม และผ้าคลุม!
local function buildOnePieceHeroR6(heroConfig, index: number, parentFolder: Folder)
	local pos = heroConfig.Position
	local towerModel = Instance.new("Model")
	towerModel.Name = "OnePieceUnit_" .. index .. "_" .. heroConfig.Id

	local function createPart(name: string, size: Vector3, color: Color3, mat: Enum.Material?)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Color = color
		p.Material = mat or Enum.Material.SmoothPlastic
		p.Anchored = true
		p.CanCollide = false
		p.Parent = towerModel
		return p
	end

	-- แท่นยืนหินอ่อนสลักทอง
	local pedestal = createPart("Pedestal", Vector3.new(1.6, 6.5, 6.5), Color3.fromRGB(30, 32, 48), Enum.Material.Marble)
	pedestal.Shape = Enum.PartType.Cylinder
	pedestal.CFrame = CFrame.new(pos - Vector3.new(0, 2.2, 0)) * CFrame.Angles(0, 0, math.rad(90))

	local skinColor = Color3.fromRGB(255, 220, 185)
	local torso = createPart("Torso", Vector3.new(2, 2, 1), heroConfig.TorsoColor)
	local head = createPart("Head", Vector3.new(1.25, 1.25, 1.25), skinColor)
	local leftArm = createPart("LeftArm", Vector3.new(1, 2, 1), skinColor)
	local rightArm = createPart("RightArm", Vector3.new(1, 2, 1), skinColor)
	local leftLeg = createPart("LeftLeg", Vector3.new(1, 2, 1), heroConfig.LegsColor)
	local rightLeg = createPart("RightLeg", Vector3.new(1, 2, 1), heroConfig.LegsColor)
	local hair = createPart("Hair", Vector3.new(1.38, 0.65, 1.38), heroConfig.HairColor)

	-- ลูกแก้ว/จุดปล่อยพลังประจำตัว
	local orb = createPart("SpiritOrb", Vector3.new(1.4, 1.4, 1.4), heroConfig.PrimaryVFXColor, Enum.Material.Neon)
	orb.Shape = Enum.PartType.Ball

	-- สร้างเครื่องประดับและอาวุธเอกลักษณ์เฉพาะตัวละคร One Piece (เก็บ Offset สัมพัทธ์กับ Torso)
	local accessories = {}
	local function addAccessory(name: string, size: Vector3, color: Color3, mat: Enum.Material, offsetCF: CFrame, shape: Enum.PartType?)
		local acc = createPart(name, size, color, mat)
		if shape then
			acc.Shape = shape
		end
		table.insert(accessories, { Part = acc, Offset = offsetCF })
		return acc
	end

	if heroConfig.Id == "Luffy" then
		-- หมวกฟางลูฟี่ (ปีกหมวก + ตัวหมวก + แถบผ้าสีแดง + วงแหวนเมฆขาว Gear 5)
		addAccessory("StrawHatBrim", Vector3.new(0.2, 2.8, 2.8), Color3.fromRGB(245, 205, 70), Enum.Material.Fabric, CFrame.new(0, 2.2, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.PartType.Cylinder)
		addAccessory("StrawHatDome", Vector3.new(1.5, 1.5, 1.5), Color3.fromRGB(245, 205, 70), Enum.Material.Fabric, CFrame.new(0, 2.45, 0), Enum.PartType.Ball)
		addAccessory("StrawHatRedRibbon", Vector3.new(0.25, 1.6, 1.6), Color3.fromRGB(220, 30, 40), Enum.Material.SmoothPlastic, CFrame.new(0, 2.3, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.PartType.Cylinder)
		addAccessory("Gear5CloudScarf", Vector3.new(3.2, 3.2, 0.5), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, CFrame.new(0, 1.2, 0.5))
	elseif heroConfig.Id == "Zoro" then
		-- ดาบ 3 เล่มของโซโล (คาบที่ปาก 1 เล่ม + ถือในมือซ้าย-ขวาอาบฮาคิสีม่วง-เขียว)
		addAccessory("MouthKatanaWado", Vector3.new(3.8, 0.18, 0.25), Color3.fromRGB(255, 255, 255), Enum.Material.Neon, CFrame.new(0.6, 1.35, -0.75))
		addAccessory("RightKatanaEnma", Vector3.new(0.2, 0.25, 4.2), Color3.fromRGB(185, 50, 255), Enum.Material.Neon, CFrame.new(1.6, 0.2, -1.8))
		addAccessory("LeftKatanaSandai", Vector3.new(0.2, 0.25, 4.2), Color3.fromRGB(50, 255, 130), Enum.Material.Neon, CFrame.new(-1.6, 0.2, -1.8))
	elseif heroConfig.Id == "Sanji" then
		-- ขาขวาติดไฟสีฟ้า Ifrit Jambe + เนคไทสีทอง
		addAccessory("GoldenTie", Vector3.new(0.35, 1.3, 0.15), Color3.fromRGB(255, 210, 50), Enum.Material.SmoothPlastic, CFrame.new(0, 0.2, -0.55))
		addAccessory("IfritBlueFlameLeg", Vector3.new(1.35, 2.2, 1.35), Color3.fromRGB(0, 200, 255), Enum.Material.Neon, CFrame.new(0.55, -1.8, -0.2))
	elseif heroConfig.Id == "Ace" then
		-- หมวกคาวบอยสีส้มของเอส + สร้อยลูกปัดแดง + ลูกไฟบนมือ
		addAccessory("AceOrangeHat", Vector3.new(0.25, 2.7, 2.7), Color3.fromRGB(240, 115, 30), Enum.Material.SmoothPlastic, CFrame.new(0, 2.2, 0) * CFrame.Angles(0, 0, math.rad(90)), Enum.PartType.Cylinder)
		addAccessory("RedBeadNecklace", Vector3.new(1.5, 0.3, 1.3), Color3.fromRGB(220, 25, 35), Enum.Material.Neon, CFrame.new(0, 0.95, 0))
	elseif heroConfig.Id == "Law" then
		-- หมวกขนสัตว์สีขาวของลอว์ + ดาบยาว Kikoku
		addAccessory("LawFurHat", Vector3.new(1.55, 1.1, 1.55), Color3.fromRGB(245, 245, 250), Enum.Material.SmoothPlastic, CFrame.new(0, 2.2, 0))
		addAccessory("KikokuNodachi", Vector3.new(0.22, 5.2, 0.35), Color3.fromRGB(65, 225, 255), Enum.Material.Neon, CFrame.new(1.6, 0.8, -0.8) * CFrame.Angles(math.rad(35), 0, 0))
	elseif heroConfig.Id == "Shanks" then
		-- ผ้าคลุมไหล่จักรพรรดิสีดำ + ดาบ Gryphon อาบฮาคิราชันย์สีแดงทมิฬ
		addAccessory("YonkoBlackCape", Vector3.new(2.8, 3.8, 0.35), Color3.fromRGB(20, 20, 28), Enum.Material.SmoothPlastic, CFrame.new(0, -0.4, 0.7) * CFrame.Angles(math.rad(12), 0, 0))
		addAccessory("GryphonHakiSaber", Vector3.new(0.25, 0.35, 4.6), Color3.fromRGB(255, 20, 50), Enum.Material.Neon, CFrame.new(1.6, 0.3, -2.0))
	end

	-- วงแหวนแสดงระยะยิงบนพื้น
	local initRange = GameConfig.INITIAL_PLAYER_STATS.RANGE_STAT
	local rangeRing = createPart("RangeIndicator", Vector3.new(0.15, initRange * 2, initRange * 2), heroConfig.PrimaryVFXColor, Enum.Material.ForceField)
	rangeRing.Shape = Enum.PartType.Cylinder
	rangeRing.CFrame = CFrame.new(pos - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
	rangeRing.Transparency = 0.68

	-- ออร่าตัวละคร
	local aura = Instance.new("Highlight")
	aura.Name = "AnimeAura"
	aura.FillColor = heroConfig.PrimaryVFXColor
	aura.OutlineColor = heroConfig.SecondaryVFXColor
	aura.FillTransparency = 0.55
	aura.Parent = towerModel

	-- ป้ายชื่อตัวละคร One Piece และค่าพลัง
	local bb = Instance.new("BillboardGui")
	bb.Name = "TowerStatGui"
	bb.Size = UDim2.new(0, 175, 0, 48)
	bb.StudsOffset = Vector3.new(0, 3.8, 0)
	bb.AlwaysOnTop = true
	bb.Adornee = head
	bb.Parent = towerModel

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "InfoText"
	titleLabel.Size = UDim2.new(1, 0, 1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextColor3 = heroConfig.PrimaryVFXColor
	titleLabel.TextStrokeTransparency = 0.05
	titleLabel.TextScaled = true
	titleLabel.Text = string.format("%s\n%s", heroConfig.DisplayName, heroConfig.Title)
	titleLabel.Parent = bb

	local function orientR6Hero(lookTarget: Vector3)
		local centerPos = pos + Vector3.new(0, 1.2, 0)
		local flatTarget = Vector3.new(lookTarget.X, centerPos.Y, lookTarget.Z)
		if (flatTarget - centerPos).Magnitude < 0.05 then
			flatTarget = centerPos + Vector3.new(0, 0, -1)
		end
		local baseCF = CFrame.lookAt(centerPos, flatTarget)
		torso.CFrame = baseCF
		head.CFrame = baseCF * CFrame.new(0, 1.6, 0)
		hair.CFrame = baseCF * CFrame.new(0, 2.05, 0)
		leftArm.CFrame = baseCF * CFrame.new(-1.5, 0, -0.2) * CFrame.Angles(math.rad(25), 0, 0)
		rightArm.CFrame = baseCF * CFrame.new(1.5, 0.2, -0.5) * CFrame.Angles(math.rad(75), 0, 0)
		leftLeg.CFrame = baseCF * CFrame.new(-0.5, -2.0, 0)
		rightLeg.CFrame = baseCF * CFrame.new(0.5, -2.0, 0)
		orb.CFrame = baseCF * CFrame.new(0, 0.6, -2.4)

		for _, item in ipairs(accessories) do
			item.Part.CFrame = baseCF * item.Offset
		end
	end

	orientR6Hero(pos + Vector3.new(0, 0, -10))
	towerModel.PrimaryPart = torso
	towerModel.Parent = parentFolder

	return towerModel, orientR6Hero
end

-- 6. โหมดสร้างหุ่นซ้อมอัตโนมัติ (เมื่อรันเทส Worktree ที่ 2 แยกเดี่ยวๆ)
local function ensureTestDummyIfStandalone()
	task.delay(3, function()
		local enemiesFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.ENEMIES)
		if not enemiesFolder then
			enemiesFolder = Instance.new("Folder")
			enemiesFolder.Name = GameConfig.FOLDERS.ENEMIES
			enemiesFolder.Parent = Workspace

			local dummy = Instance.new("Model")
			dummy.Name = "PacifistaTrainingDummy"

			local root = Instance.new("Part")
			root.Name = "HumanoidRootPart"
			root.Size = Vector3.new(3, 5, 2)
			root.Position = Vector3.new(-28, 3, -18)
			root.Anchored = true
			root.Color = Color3.fromRGB(200, 60, 60)
			root.Parent = dummy

			local hum = Instance.new("Humanoid")
			hum.MaxHealth = 999999
			hum.Health = 999999
			hum.Parent = dummy

			dummy.PrimaryPart = root
			dummy.Parent = enemiesFolder

			hum.HealthChanged:Connect(function(hp)
				if hp < 100000 then
					hum.Health = 999999
				end
			end)
		end
	end)
end

-- 7. เริ่มสร้างทั้ง 6 ตัวละคร One Piece และรันลูปปล่อยพลัง
local towersFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.TOWERS)
if not towersFolder then
	towersFolder = Instance.new("Folder")
	towersFolder.Name = GameConfig.FOLDERS.TOWERS
	towersFolder.Parent = Workspace
end

ensureTestDummyIfStandalone()

for idx, heroConfig in ipairs(ONE_PIECE_HEROES) do
	local towerModel, orientR6Hero = buildOnePieceHeroR6(heroConfig, idx, towersFolder)

	task.spawn(function()
		local torso = towerModel:WaitForChild("Torso") :: BasePart
		local orb = towerModel:WaitForChild("SpiritOrb") :: BasePart
		local rangeRing = towerModel:WaitForChild("RangeIndicator") :: BasePart
		local infoText = towerModel:WaitForChild("TowerStatGui"):WaitForChild("InfoText") :: TextLabel

		while towerModel.Parent do
			local dmg, range, cooldown, splashRadius, critChance = getCurrentCombatStats()
			rangeRing.Size = Vector3.new(0.15, range * 2, range * 2)
			infoText.Text = string.format(
				"%s [%s]\nDMG: %d | AoE: %d | SPD: %.2fs",
				heroConfig.DisplayName,
				heroConfig.Id:upper(),
				math.floor(dmg),
				math.floor(splashRadius),
				cooldown
			)

			local enemiesFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.ENEMIES)
			local nearestEnemy: Model? = nil
			local shortestDist = range

			if enemiesFolder then
				for _, enemy in ipairs(enemiesFolder:GetChildren()) do
					local eRoot = enemy:FindFirstChild("HumanoidRootPart") :: BasePart?
					local eHum = enemy:FindFirstChildOfClass("Humanoid")
					if eRoot and eHum and eHum.Health > 0 then
						local d = (eRoot.Position - torso.Position).Magnitude
						if d <= shortestDist then
							shortestDist = d
							nearestEnemy = enemy
						end
					end
				end
			end

			if nearestEnemy then
				local targetRoot = nearestEnemy:FindFirstChild("HumanoidRootPart") :: BasePart
				local targetHum = nearestEnemy:FindFirstChildOfClass("Humanoid")
				if targetRoot and targetHum and targetHum.Health > 0 then
					orientR6Hero(targetRoot.Position)

					local isCrit = (math.random(1, 100) <= critChance)
					local finalDamage = isCrit and math.floor(dmg * 2.0) or dmg

					playOnePieceUltimateVFX(heroConfig, orb.Position, targetRoot.Position, splashRadius, isCrit)

					if splashRadius > 0 and enemiesFolder then
						for _, otherEnemy in ipairs(enemiesFolder:GetChildren()) do
							local oRoot = otherEnemy:FindFirstChild("HumanoidRootPart") :: BasePart?
							local oHum = otherEnemy:FindFirstChildOfClass("Humanoid")
							if oRoot and oHum and oHum.Health > 0 then
								if (oRoot.Position - targetRoot.Position).Magnitude <= splashRadius then
									oHum:TakeDamage(finalDamage)
								end
							end
						end
					else
						targetHum:TakeDamage(finalDamage)
					end

					task.wait(cooldown)
				else
					task.wait(0.1)
				end
			else
				task.wait(0.15)
			end
		end
	end)
end
```

---

## 3. ตารางตรวจรับงานส่วนที่ 2 (UAT Track 2 - One Piece R6 Heroes & Ultimate VFX)

| รหัส UAT | รายการทดสอบ (Test Case) | วิธีทดสอบใน Roblox Studio | ผลลัพธ์ที่ต้องเห็น (Expected Result) | สถานะ |
| :--- | :--- | :--- | :--- | :--- |
| **UAT-2.1** | โมเดล R6 ตัวละคร One Piece ทั้ง 6 ตัวพร้อมเครื่องแต่งกาย | กด Play แล้วซูมดูหุ่นทั้ง 6 ตัวข้างทางเดิน | เห็น **Luffy** ใส่หมวกฟาง+เมฆขาว, **Zoro** คาบดาบ+ถือดาบเอ็นมะ, **Sanji** ขาติดไฟสีฟ้า, **Ace** หมวกส้ม, **Law** หมวกขาว, และ **Shanks** ผ้าคลุมดำถือดาบแดง | [ ] ผ่าน |
| **UAT-2.2** | ท่าไม้ตายประจำตัวละคร (Signature VFX) | สังเกตตอนซอมบี้เดินผ่านหน้าตัวละครแต่ละตัว | **Law** กางโดมสีฟ้า `ROOM`, **Ace** ปล่อยบอลพระอาทิตย์เพลิง, **Zoro/Shanks** ฟาดคลื่นดาบและสายฟ้าฮาคิราชันย์สีแดง-ดำ | [ ] ผ่าน |
| **UAT-2.3** | การรับบัฟจากการ์ดอัปเกรด (`Damage`, `Range`, `SplashRadius`, `Crit`) | เลือกการ์ดอัปเกรดเมื่อขึ้นเวฟใหม่ (หรือปรับ Attributes) | วงแหวนระยะยิงขยายทันที ตัวเลข `DMG` และ `AoE` บนหัวตัวละครทั้ง 6 ตัวเพิ่มขึ้นพร้อมกันแบบเรียลไทม์ | [ ] ผ่าน |
