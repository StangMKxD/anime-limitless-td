# ไฟล์ที่ 2: สเปกสั่งแก้ `PLAN-0008` (Track 2 — แก้โมเดลตัวละคร One Piece ให้สมจริง + ท่าไม้ตายอลังการระดับถล่มจอ + ซ่อนป้ายชื่อบนหัวไม่ให้บังสนามรบ)

> **อ้างอิงจากโค้ดจริงใน Repo**: [StangMKxD/anime-limitless-td](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td)  
> **ไฟล์เป้าหมายที่ต้องแก้**: [src/Track2\_TowerSystem/TowerController.server.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack2_TowerSystem%2FTowerController.server.luau) (1,433 บรรทัด)  
> **รหัสแผนงาน**: `PLAN-0008` (Authentic R6 / Toolbox Model Loader, Cataclysmic One Piece VFX & Zero-Clutter 3D Labels)  
> **กฎการทำงาน (`AGENTS.md`)**: `COMBO-07` | Strict SoD (`R01–R05`)

---

## 1. ทำไมโมเดลใน `TowerController.server.luau` ปัจจุบันถึงดูแปลกๆ ("โมเดลอะไรไม่รู้") และต้องทำโมเดลยังไง?

จากการตรวจโค้ดจริง 1,433 บรรทัดใน [src/Track2\_TowerSystem/TowerController.server.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack2_TowerSystem%2FTowerController.server.luau) สาเหตุที่โมเดลดูประหลาดและไม่เว่อร์เกิดจาก 3 จุดนี้ครับ:

1. **โค้ดปัจจุบันใช้ `Instance.new("Part")` เอากล่องสี่เหลี่ยมมาต่อกันเป็นตัวคน**:
   * ใน Roblox การเขียนโค้ดสร้าง `Part` ทรงกล่องมาวางซ้อนกันเป็นหมวกฟาง ผม หรือหน้าตา จะได้แค่ **"หุ่นกระป๋องเหลี่ยมๆ"** ไม่มีทางเหมือนโมเดล 3D Mesh ของตัวการ์ตูน One Piece จริงๆ
2. **วิธีทำโมเดล One Piece ใน Roblox ให้สวยเป๊ะ 100% (ใช้เวลาแค่ 2 นาทีใน Studio)**:
   * **ขั้นตอนใน Roblox Studio (สำหรับคุณ)**:
     1. ในหน้าต่าง Explorer ให้สร้างโฟลเดอร์ชื่อ **`HeroModels`** ไว้ใน **`ReplicatedStorage`**
     2. เปิดแท็บ **Toolbox** -> เลือกหมวด **Models** -> พิมพ์ค้นหาชื่อตัวละครทั้ง 8 ตัวตามที่มีใน `GameConfig.luau`: **`Luffy`**, **`Zoro`**, **`Nami`**, **`Usopp`**, **`Sanji`**, **`Chopper`**, **`Robin`**, **`Shanks`**
     3. ลากโมเดลตัวละคร One Piece สวยๆ จาก Toolbox เข้าไปใส่ในโฟลเดอร์ `ReplicatedStorage.HeroModels` แล้วเปลี่ยนชื่อโมเดลให้ตรงกับชื่อตัวละคร (`Luffy`, `Zoro`, `Nami`, `Usopp`, `Sanji`, `Chopper`, `Robin`, `Shanks`) *(อย่าลืมลบ Script ติดไวรัสในโมเดล Toolbox ออก เหลือไว้แต่ตัวหุ่น R6/Mesh)*
   * **ขั้นตอนในโค้ด (`PLAN-0008` สำหรับสั่ง AI แก้)**:
     * สั่งแก้ `TowerController.server.luau` ให้เช็ค **`ReplicatedStorage:FindFirstChild("HeroModels"):FindFirstChild(heroId)`** ก่อนเสมอ! ถ้ามีโมเดลที่คุณลากมาจาก Toolbox โค้ดจะดึงโมเดล 3D ของจริงนั้นมาวางบนแท่นทันที!
     * และถ้าตัวไหนยังไม่ได้ลากใส่ `HeroModels` โค้ดจะใช้ **`Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)`** สร้างหุ่นอวตาร Roblox R6 ของแท้ (หัวมน ข้อต่อ `Motor6D` ครบ) แทนการใช้กล่องสี่เหลี่ยมต่อกัน!
3. **ป้ายชื่อ `BillboardGui` บนหัวป้อมทั้ง 16 แท่น (`Pad1`–`Pad16`) ใหญ่บังจอ**:
   * ในโค้ดเดิม ป้อมทุกตัวมีป้าย `BillboardGui` เปิดค้างไว้ตลอดเวลา (`AlwaysOnTop = true`) พอวางป้อมหลายตัว ป้ายชื่อจะซ้อนทับกันเต็มกลางจอ
   * **วิธีแก้**: ปิด `BillboardGui` ยักษ์ทิ้ง! เปลี่ยนเป็นป้ายมินิมอลจิ๋วที่ **ซ่อนอยู่ (`Enabled = false`) และจะแสดงขึ้นมาเฉพาะตอนที่ผู้เล่นเอาเมาส์ชี้หรือคลิกเลือกป้อมนั้น** เท่านั้น!

---

## 2. สเปกอัปเกรดเอฟเฟกต์ท่าไม้ตายทั้ง 8 ตัวละครให้ "เว่อร์อลังการระดับถล่มจอ" (Cataclysmic VFX)

สั่งให้ AI อัปเกรดฟังก์ชันแสดงผล VFX ใน `src/Track2_TowerSystem/TowerController.server.luau` ให้ใหญ่ขึ้น 4–6 เท่า พร้อมเอฟเฟกต์หลายเลเยอร์ (`ParticleEmitter` + `Beam` + `PointLight` + `Multi-Ring Shockwave`):

| ตัวละคร (`HeroId`) | ท่าไม้ตายเดิม (เบาเกินไป) | ท่าไม้ตายใหม่ใน `PLAN-0008` (เว่อร์อลังการเต็มจอ) |
| :--- | :--- | :--- |
| **`Luffy`** | ก้อนหมัดเล็กๆ พุ่งชน | **Gomu Gomu no Bajrang Gun (หมัดเทพนิกะขนาดยักษ์ `26x26x26 Studs`)**: เสกหมัดยักษ์สีขาว-แดงหุ้มสายฟ้าฮาคิราชันย์ 10 เส้นผ่าลงมาจากท้องฟ้าเหนือหัวซอมบี้ พร้อมวงแหวนเมฆขาวกระแทกพื้น 3 ชั้น (รัศมี `35 Studs`) |
| **`Zoro`** | เส้นคลื่นดาบเล็กๆ | **King of Hell: Dragon Damnation (พายุทอร์นาโดมังกร 3 เสา + รอยฟันกากบาทม่วง-เขียว)**: เสกเสาพายุหมุนสีเขียวมรกต-ม่วงทมิฬสูง `38 Studs` หมุนกวาดศัตรู พร้อมรอยฟันดาบยักษ์ขนาด `30 Studs` |
| **`Sanji`** | ก้อนไฟสีฟ้าเล็กๆ | **Ifrit Jambe: Hell Memories (เสาเพลิงนรกสีฟ้าครามยักษ์)**: เสกเสาไฟสีฟ้าครามพุ่งจากพื้นสูง `42 Studs` พร้อมวงแหวนไฟสีฟ้า-ขาวระเบิดซ้อนกัน 4 ชั้นและแสง `PointLight` สว่างวาบ |
| **`Shanks`** | คลื่นดาบสีแดงธรรมดา | **Divine Departure: Kamusari (เทวทัณฑ์ฮาคิราชันย์ผ่าสมรภูมิ)**: ฟาดคลื่นดาบยักษ์สีแดง-ดำกว้าง `42 Studs` พร้อมเสาสายฟ้าฮาคิราชันย์สีแดงทมิฬผ่าลงมารอบเป้าหมาย 12 เส้นรวด! |
| **`Nami`** | สายฟ้าเส้นเดียว | **Zeus Breeze Tempo (เมฆดำซุสยักษ์ลอยเหนือหัว + มหาสายฟ้าฟาด 8 เส้น)**: เสกเมฆพายุสีดำตาเรืองแสงลอยเหนือกลุ่มซอมบี้แล้วผ่าเสาสายฟ้าสีเหลืองทองขนาดใหญ่ลงมาพร้อมกัน |
| **`Usopp`** | กระสุนหนังสติ๊กเล็กๆ | **Firebird Star & Skull Exploding Grass (วิหคเพลิงยักษ์ + ดงระเบิดหัวกะโหลกสีเขียว)**: ยิงนกเพลิงขนาดยักษ์พุ่งชนแล้วแตกตัวเป็นระเบิดพุ่มไม้สีเขียวมรกต 6 ลูกซ้อน |
| **`Chopper`** | วงกระแทกเล็กๆ | **Monster Point: Kokutei Palme (ฝ่ามืออสูรยักษ์ทุบพสุธา)**: เสกเงาร่างยักษ์และรอยอุ้งเท้าสีชมพู-ทองขนาด `28 Studs` ทุบพื้นแตกร้าว |
| **`Robin`** | มือเล็กๆ โผล่ | **Demonio Fleur: Giganteco Mano (มือปีศาจทมิฬยักษ์คู่ตบประกบ)**: เสกเสามือปีศาจสีม่วง-ดำขนาดยักษ์โผล่ขึ้นมาจากพื้นขนาบข้างศัตรูแล้วตบอัดเข้าหากันพร้อมคลื่นความมืด |

---

## 3. โค้ดโมดูลหลักสำหรับอัปเดตใน `src/Track2_TowerSystem/TowerController.server.luau`

ให้ AI Implementer นำฟังก์ชัน **Hybrid Model Loader (`loadAuthenticHeroModel`)** และ **Cataclysmic VFX (`playCataclysmicOnePieceVFX`)** ไปแทนที่ฟังก์ชันสร้างหุ่นและ VFX เดิมใน `src/Track2_TowerSystem/TowerController.server.luau`:

```luau
-- 1. Hybrid Hero Model Loader: ดึงโมเดล 3D ของจริงจาก ReplicatedStorage.HeroModels ก่อน
-- หากยังไม่ได้ลากโมเดลจาก Toolbox มาใส่ จะสร้างหุ่น R6 ของแท้ด้วย CreateHumanoidModelFromDescription
local function loadAuthenticHeroModel(heroSpec, padPos: Vector3): Model
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")

	local heroModelsFolder = ReplicatedStorage:FindFirstChild("HeroModels")
		or game:GetService("Workspace"):FindFirstChild("HeroModels")

	local model: Model? = nil
	if heroModelsFolder then
		local template = heroModelsFolder:FindFirstChild(heroSpec.Id)
		if template and template:IsA("Model") then
			model = template:Clone()
		end
	end

	-- ถ้ายังไม่มีโมเดลใน HeroModels ให้ใช้เอนจิน Roblox สร้างหุ่น R6 แท้ (หัวมน ข้อต่อ Motor6D ครบ)
	if not model then
		local ok, rig = pcall(function()
			local desc = Instance.new("HumanoidDescription")
			desc.HeadColor = Color3.fromRGB(255, 220, 185)
			desc.TorsoColor = heroSpec.PrimaryColor or Color3.fromRGB(210, 35, 45)
			desc.LeftArmColor = Color3.fromRGB(255, 220, 185)
			desc.RightArmColor = Color3.fromRGB(255, 220, 185)
			desc.LeftLegColor = heroSpec.SecondaryColor or Color3.fromRGB(40, 85, 175)
			desc.RightLegColor = heroSpec.SecondaryColor or Color3.fromRGB(40, 85, 175)
			return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
		end)
		if ok and rig then
			model = rig
		end
	end

	-- Fallback สำหรับ Headless Test CLI
	if not model then
		model = Instance.new("Model")
		local torso = Instance.new("Part")
		torso.Name = "Torso"
		torso.Size = Vector3.new(2, 2, 1)
		torso.Parent = model
		local head = Instance.new("Part")
		head.Name = "Head"
		head.Size = Vector3.new(1.2, 1.2, 1.2)
		head.Parent = model
		model.PrimaryPart = torso
	end

	model.Name = "HeroTower_" .. heroSpec.Id

	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
		elseif part:IsA("Script") or part:IsA("LocalScript") then
			-- ลบสคริปต์แปลกปลอมที่อาจติดมากับโมเดล Toolbox เพื่อความปลอดภัย
			part:Destroy()
		end
	end

	model:PivotTo(CFrame.new(padPos + Vector3.new(0, 3.0, 0)))

	-- ใส่ออร่า ParticleEmitter พลังฮาคิพวยพุ่งรอบตัวละคร (เท่กว่าก้อนสี่เหลี่ยม!)
	local rootPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
	if rootPart and rootPart:IsA("BasePart") then
		local auraEmitter = Instance.new("ParticleEmitter")
		auraEmitter.Name = "HakiAuraParticles"
		auraEmitter.Color = ColorSequence.new(
			heroSpec.PrimaryColor or Color3.fromRGB(255, 50, 80),
			heroSpec.SecondaryColor or Color3.fromRGB(255, 215, 0)
		)
		auraEmitter.LightEmission = 1
		auraEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.5, 2.2),
			NumberSequenceKeypoint.new(1, 0),
		})
		auraEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(1, 1),
		})
		auraEmitter.Lifetime = NumberRange.new(0.4, 0.8)
		auraEmitter.Rate = 28
		auraEmitter.Speed = NumberRange.new(4, 9)
		auraEmitter.SpreadAngle = Vector2.new(35, 35)
		auraEmitter.Parent = rootPart
	end

	-- ป้ายชื่อบนหัวป้อมแบบ Minimal ซ่อนไว้ตามปกติ (โชว์เฉพาะระยะใกล้มาก หรือตอนคลิกเลือก เพื่อไม่ให้บังจอ!)
	local head = model:FindFirstChild("Head") or rootPart
	if head and head:IsA("BasePart") then
		local bb = Instance.new("BillboardGui")
		bb.Name = "TowerStatGui"
		bb.Size = UDim2.new(0, 90, 0, 22)
		bb.StudsOffset = Vector3.new(0, 2.6, 0)
		bb.AlwaysOnTop = false -- ห้ามบังหน้าจอ UI หลักเด็ดขาด
		bb.MaxDistance = 38 -- มองเห็นเฉพาะตอนซูมเข้าไปใกล้ๆ
		bb.Adornee = head
		bb.Parent = model

		local lbl = Instance.new("TextLabel")
		lbl.Name = "InfoText"
		lbl.Size = UDim2.new(1, 0, 1, 0)
		lbl.BackgroundTransparency = 0.35
		lbl.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextColor3 = Color3.fromRGB(255, 235, 120)
		lbl.TextScaled = true
		lbl.Text = heroSpec.Id:upper()
		lbl.Parent = bb

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = lbl
	end

	return model
end

-- 2. Cataclysmic Screen-Filling One Piece Ultimate VFX (เว่อร์อลังการระดับจักรพรรดิ!)
local function playCataclysmicOnePieceVFX(heroId: string, originPos: Vector3, targetPos: Vector3, pColor: Color3, sColor: Color3, splashRadius: number, isCrit: boolean)
	local TweenService = game:GetService("TweenService")
	local Workspace = game:GetService("Workspace")
	local scale = isCrit and 1.5 or 1.0
	local aoe = math.max(14, splashRadius * 2.5) * scale

	-- 2.1 เสาแสงระเบิดพสุธา (Sky-Piercing Haki Pillar สูง 45 Studs!)
	local pillar = Instance.new("Part")
	pillar.Name = "CataclysmPillar"
	pillar.Shape = Enum.PartType.Cylinder
	pillar.Anchored = true
	pillar.CanCollide = false
	pillar.Material = Enum.Material.Neon
	pillar.Color = pColor
	pillar.Size = Vector3.new(45 * scale, 2, 2)
	pillar.CFrame = CFrame.new(targetPos + Vector3.new(0, 20 * scale, 0)) * CFrame.Angles(0, 0, math.rad(90))
	pillar.Parent = Workspace

	local light = Instance.new("PointLight")
	light.Color = pColor
	light.Brightness = 6
	light.Range = 35
	light.Parent = pillar

	TweenService:Create(pillar, TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = Vector3.new(55 * scale, aoe * 0.9, aoe * 0.9),
		Transparency = 1,
	}):Play()

	-- 2.2 วงแหวนคลื่นกระแทกฮาคิ 3 ชั้นซ้อนกัน (Triple Expanding Shockwave Rings)
	for ringIdx = 1, 3 do
		local ring = Instance.new("Part")
		ring.Name = "ShockwaveRing_" .. ringIdx
		ring.Shape = Enum.PartType.Cylinder
		ring.Anchored = true
		ring.CanCollide = false
		ring.Material = Enum.Material.Neon
		ring.Color = (ringIdx % 2 == 1) and pColor or sColor
		ring.Size = Vector3.new(0.5, 3, 3)
		ring.CFrame = CFrame.new(targetPos + Vector3.new(0, ringIdx * 1.2, 0)) * CFrame.Angles(0, 0, math.rad(90))
		ring.Parent = Workspace

		local targetDiameter = aoe * (0.8 + ringIdx * 0.35)
		TweenService:Create(ring, TweenInfo.new(0.25 + ringIdx * 0.08, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.1, targetDiameter, targetDiameter),
			Transparency = 1,
		}):Play()

		task.delay(0.5, function()
			if ring then ring:Destroy() end
		end)
	end

	-- 2.3 สายฟ้าฮาคิราชันย์ผ่าลงมารอบจุดปะทะ 8 เส้น!
	for boltIdx = 1, 8 do
		local angle = (boltIdx / 8) * math.pi * 2
		local offset = Vector3.new(math.cos(angle) * (aoe * 0.4), math.random(12, 26), math.sin(angle) * (aoe * 0.4))
		local boltEnd = targetPos + offset
		local dist = (boltEnd - targetPos).Magnitude

		local bolt = Instance.new("Part")
		bolt.Name = "ConquerorBolt"
		bolt.Anchored = true
		bolt.CanCollide = false
		bolt.Material = Enum.Material.Neon
		bolt.Color = (boltIdx % 2 == 0) and Color3.fromRGB(255, 15, 50) or sColor
		bolt.Size = Vector3.new(0.65 * scale, 0.65 * scale, dist)
		bolt.CFrame = CFrame.lookAt((targetPos + boltEnd) / 2, boltEnd)
		bolt.Parent = Workspace

		TweenService:Create(bolt, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.05, 0.05, dist * 1.2),
			Transparency = 1,
		}):Play()

		task.delay(0.35, function()
			if bolt then bolt:Destroy() end
		end)
	end

	-- 2.4 เอฟเฟกต์เอกลักษณ์เฉพาะตัวละคร (หมัดยักษ์ Bajrang Gun / บอลพระอาทิตย์ / พายุโซโล)
	if heroId == "Luffy" or heroId == "Chopper" or heroId == "Robin" then
		-- หมัดเทพพระอาทิตย์นิกะยักษ์ตกจากฟ้า!
		local giantFist = Instance.new("Part")
		giantFist.Name = "GiantGodFist"
		giantFist.Shape = Enum.PartType.Ball
		giantFist.Anchored = true
		giantFist.CanCollide = false
		giantFist.Material = Enum.Material.Neon
		giantFist.Color = Color3.fromRGB(255, 245, 250)
		giantFist.Size = Vector3.new(18 * scale, 18 * scale, 18 * scale)
		giantFist.Position = targetPos + Vector3.new(0, 32, 0)
		giantFist.Parent = Workspace

		TweenService:Create(giantFist, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = targetPos,
			Size = Vector3.new(26 * scale, 26 * scale, 26 * scale),
			Transparency = 0.85,
		}):Play()
		task.delay(0.28, function()
			if giantFist then giantFist:Destroy() end
		end)
	elseif heroId == "Zoro" or heroId == "Shanks" then
		-- รอยฟันดาบกากบาทขนาดยักษ์ผ่าครึ่งสมรภูมิ!
		for slashIdx = -1, 1, 2 do
			local slash = Instance.new("Part")
			slash.Name = "YonkoCrossSlash"
			slash.Anchored = true
			slash.CanCollide = false
			slash.Material = Enum.Material.Neon
			slash.Color = pColor
			slash.Size = Vector3.new(0.8, 18 * scale, 32 * scale)
			slash.CFrame = CFrame.lookAt(originPos, targetPos) * CFrame.Angles(0, 0, math.rad(35 * slashIdx))
			slash.Parent = Workspace

			TweenService:Create(slash, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				CFrame = CFrame.lookAt(targetPos, targetPos + (targetPos - originPos).Unit) * CFrame.Angles(0, 0, math.rad(35 * slashIdx)),
				Size = Vector3.new(0.1, 26 * scale, 44 * scale),
				Transparency = 1,
			}):Play()
			task.delay(0.32, function()
				if slash then slash:Destroy() end
			end)
		end
	end

	task.delay(0.42, function()
		if pillar then pillar:Destroy() end
	end)
end
```

---

## 4. ตารางตรวจรับงาน `PLAN-0008` (UAT Track 2)

| รหัส UAT | รายการทดสอบ | เกณฑ์การตรวจรับ (Acceptance Criteria) | สถานะ |
| :--- | :--- | :--- | :---: |
| **UAT-8.1** | โมเดลตัวละครสมจริง (`HeroModels` + `R6 HumanoidDescription`) | โค้ดดึงโมเดลจาก `ReplicatedStorage.HeroModels` หากมีวางไว้ หรือใช้ `CreateHumanoidModelFromDescription` สร้างหุ่น R6 แท้พร้อมออร่า `ParticleEmitter` | [ ] ผ่าน |
| **UAT-8.2** | ท่าไม้ตายอลังการเต็มจอ (Cataclysmic VFX) | ทุกครั้งที่โจมตี มีเสาพลังงานสูง `45 Studs`, วงแหวนคลื่นกระแทก 3 ชั้น, สายฟ้าฮาคิราชันย์ 8 เส้น และหมัดยักษ์/คลื่นดาบกากบาทขนาด `30-44 Studs` | [ ] ผ่าน |
| **UAT-8.3** | ป้ายชื่อบนหัวป้อมไม่บังหน้าจอ | ป้าย `TowerStatGui` ตั้ง `AlwaysOnTop = false` ขนาดเล็กกะทัดรัด `90x22 px` และซ่อนเมื่ออยู่ไกลเกิน `38 Studs` | [ ] ผ่าน |
