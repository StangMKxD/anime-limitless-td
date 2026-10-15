# ไฟล์ที่ 2: สเปกงานส่วนที่ 2 ระบบยูนิตอนิเมะปล่อยพลัง เอฟเฟกต์ VFX และการเปลี่ยนร่างตามสเตตัส (Anime Towers & Combat System)

เอกสารฉบับนี้เป็นคู่มือจับมือทำแบบละเอียดสำหรับ **งานส่วนที่ 2 (Track 2: ระบบยูนิตอนิเมะค้นหาเป้าหมาย ปล่อยลำแสงพลังโจมตีอัตโนมัติ และเปลี่ยนสีออร่าตามค่าสเตตัสไร้ขีดจำกัด)** ซึ่งรันคู่ขนานไปพร้อมกับงานส่วนที่ 1 และ 3 บน **Git Worktree ที่ 2 (`../wt-track2-towers`)** โดยไม่แก้ไฟล์ทับกันแม้แต่บรรทัดเดียว

---

## 1. ขอบเขตงานและข้อตกลงการแยกไฟล์ (Spec & Scope - Track 2)

| หัวข้อ | รายละเอียดของงานส่วนที่ 2 |
| :--- | :--- |
| **Git Branch** | `feat/track2-towers` |
| **โฟลเดอร์ Worktree** | `../wt-track2-towers` |
| **ไฟล์ที่อนุญาตให้สร้าง/แก้ไข** | `src/Track2_TowerSystem/TowerController.server.luau` เท่านั้น (ห้ามแตะโฟลเดอร์อื่นเด็ดขาด) |
| **พอร์ต Rojo สำหรับเทสแยก** | `34872` (`rojo serve --port 34872`) |
| **ข้อมูลที่อ่านเข้ามา (Inputs)** | อ่านค่า `DamageStat`, `RangeStat`, `CooldownStat` จาก Attributes ของผู้เล่น และค้นหามอนสเตอร์ใน `Workspace.ActiveEnemies` |
| **ผลลัพธ์ที่ส่งออก (Outputs)** | สร้างแท่นยูนิตอนิเมะ 6 จุดข้างทางเดิน ยิงลำแสงพลังลด `Humanoid.Health` ของซอมบี้ และแสดงป้ายสเตตัส/ร่างวิวัฒนาการบนหัวยูนิต |

### ฟีเจอร์หลักที่ต้องทำให้ครบใน Track 2
1. **Auto-Spawn Anime Hero Units**: เมื่อรันสคริปต์ หากใน `Workspace` ยังไม่มีโฟลเดอร์ `AnimeTowers` สคริปต์จะสร้างแท่นอัญเชิญพร้อมหุ่นผู้พิทักษ์อนิเมะ 6 ตัววางขนาบข้างเส้นทางเดินซอมบี้ให้อัตโนมัติ พร้อมวงแหวนแสดงระยะยิง (`Range Ring`) รอบฐาน
2. **Real-Time Infinite Stat Sync**: ดึงค่าพลังรวม/ค่าสูงสุดของผู้เล่นในเซิร์ฟเวอร์ (`DamageStat`, `RangeStat`, `CooldownStat`) มาอัปเดตให้ยูนิตอนิเมะทุกตัวแบบเรียลไทม์ ทันทีที่ผู้เล่นกดอัปเกรดสเตตัสใน UI (Track 3) วงแหวนระยะยิงและดาเมจของป้อมจะขยายขึ้นทันที
3. **Anime Evolution Tiers (เปลี่ยนร่างออร่าตามความเก่งแบบไร้ขีดจำกัด)**:
   * **Tier 1 (Spirit Novice - Damage < 100)**: ออร่าและลำแสงสีฟ้าคราม (`Cyan Ki Blast`) ยิงเป้าหมายเดี่ยว
   * **Tier 2 (Awakened Sorcerer - Damage 100 ถึง 399)**: ออร่าและลำแสงสีม่วงอัสนี (`Void Purple Slash`) พร้อมระเบิดคลื่นกระแทก
   * **Tier 3 (Super Golden Form - Damage 400 ถึง 1,499)**: ออร่าสีทองอร่าม (`Golden Kamehameha`) โจมตีเป็นวงกว้าง (AoE Splash Damage รัศมี 10 Studs)
   * **Tier 4 (God of Destruction - Damage >= 1,500+)**: ออร่าสีแดงเพลิงจักรวาล (`Crimson Meteor Burst`) โจมตีทะลุทะลวงเป็นวงกว้างพิเศษ (AoE รัศมี 16 Studs)
4. **Standalone Dummy Mode (โหมดเทสแยกอิสระ)**: หากคุณเปิดเทสเฉพาะ Worktree ที่ 2 เดี่ยวๆ (โดยยังไม่ได้รวมโค้ดซอมบี้จาก Track 1) สคริปต์จะตรวจพบเองว่าไม่มี `WaveManager` และจะเสก **หุ่นซ้อมอนิเมะ (`TrainingDummy`)** ออกมาให้ป้อมยิงโชว์ทันที เพื่อให้คุณตรวจงานที่ 2 ได้โดยไม่ต้องรองานที่ 1!

---

## 2. ขั้นตอนจับมือทำ: สั่ง AI หน้าต่างที่ 2 (`../wt-track2-towers`)

### 2.1 เปิดหน้าต่าง AI Agent ตัวที่ 2
1. เปิด Terminal หรือหน้าต่างโปรแกรม AI (Cursor / Claude Code / Windsurf) หน้าต่างที่ 2
2. เข้าไปยังโฟลเดอร์ Worktree ที่ 2:
   ```bash
   cd ../wt-track2-towers
   git branch
   # ต้องขึ้นว่า * feat/track2-towers
   ```

### 2.2 Prompt สำหรับก๊อปปี้ไปสั่ง AI Agent หน้าต่างที่ 2
> "คุณกำลังทำงานใน Git Worktree `feat/track2-towers` ให้สร้างไฟล์ `src/Track2_TowerSystem/TowerController.server.luau` เท่านั้น (ห้ามแก้ไขไฟล์นอกโฟลเดอร์ `src/Track2_TowerSystem` เด็ดขาด) โดยอ้างอิงค่าจาก `ReplicatedStorage.Shared.GameConfig` ให้เขียนระบบเสกยูนิตอนิเมะ 6 จุดข้างทางเดินอัตโนมัติพร้อมวงแหวนแสดงระยะยิง, ระบบค้นหามอนสเตอร์ที่ใกล้ที่สุดในโฟลเดอร์ `Workspace.ActiveEnemies`, ระบบปล่อยลำแสงอนิเมะและระเบิดคลื่นพลังด้วย `TweenService`, ระบบเปลี่ยนสีออร่าและปลดล็อกการโจมตีหมู่ (AoE) ตามระดับ `DamageStat` 4 ขั้น (ฟ้า -> ม่วง -> ทอง -> แดงทมิฬ) และมีระบบเสกหุ่นซ้อม `TrainingDummy` อัตโนมัติหากรันเทสแยกเดี่ยวๆ เมื่อเขียนเสร็จให้ git add และ git commit ลง branch `feat/track2-towers`"

### 2.3 โค้ดสำเร็จรูป `src/Track2_TowerSystem/TowerController.server.luau`
คัดลอกโค้ดด้านล่างไปวางในไฟล์ `src/Track2_TowerSystem/TowerController.server.luau` ได้เลย:

```luau
-- src/Track2_TowerSystem/TowerController.server.luau
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

-- 1. กำหนดระดับร่างวิวัฒนาการอนิเมะตามค่า DamageStat ไร้ขีดจำกัด
local function getEvolutionTier(damage: number)
	if damage >= 1500 then
		return {
			Name = "GOD OF DESTRUCTION",
			Color = Color3.fromRGB(255, 35, 65),
			SecondaryColor = Color3.fromRGB(255, 200, 50),
			SplashRadius = 16,
			BeamWidth = 2.8,
		}
	elseif damage >= 400 then
		return {
			Name = "SUPER GOLDEN FORM",
			Color = Color3.fromRGB(255, 210, 40),
			SecondaryColor = Color3.fromRGB(255, 255, 180),
			SplashRadius = 10,
			BeamWidth = 2.0,
		}
	elseif damage >= 100 then
		return {
			Name = "AWAKENED SORCERER",
			Color = Color3.fromRGB(185, 60, 255),
			SecondaryColor = Color3.fromRGB(230, 150, 255),
			SplashRadius = 5,
			BeamWidth = 1.4,
		}
	else
		return {
			Name = "SPIRIT NOVICE",
			Color = Color3.fromRGB(0, 215, 255),
			SecondaryColor = Color3.fromRGB(160, 245, 255),
			SplashRadius = 0,
			BeamRadius = 1.0,
		}
	end
end

-- 2. ดึงสเตตัสปัจจุบันจากผู้เล่นในเซิร์ฟเวอร์ (รองรับทั้งเล่นคนเดียวและหลายคน)
local function getCurrentCombatStats()
	local maxDamage = GameConfig.INITIAL_PLAYER_STATS.DAMAGE_STAT
	local maxRange = GameConfig.INITIAL_PLAYER_STATS.RANGE_STAT
	local minCooldown = GameConfig.INITIAL_PLAYER_STATS.COOLDOWN_STAT

	for _, plr in ipairs(Players:GetPlayers()) do
		local d = plr:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT)
		local r = plr:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT)
		local c = plr:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT)
		if typeof(d) == "number" and d > maxDamage then
			maxDamage = d
		end
		if typeof(r) == "number" and r > maxRange then
			maxRange = r
		end
		if typeof(c) == "number" and c < minCooldown then
			minCooldown = c
		end
	end

	return maxDamage, maxRange, math.max(GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN, minCooldown)
end

-- 3. สร้างเอฟเฟกต์ปล่อยคลื่นพลังอนิเมะ (Procedural Anime VFX)
local function playAnimeBlastVFX(originPos: Vector3, targetPos: Vector3, tierInfo)
	local dist = (targetPos - originPos).Magnitude
	local midPoint = (originPos + targetPos) / 2

	-- ลำแสงคลื่นพลังหลัก
	local beamPart = Instance.new("Part")
	beamPart.Name = "AnimeEnergyBeam"
	beamPart.Anchored = true
	beamPart.CanCollide = false
	beamPart.Material = Enum.Material.Neon
	beamPart.Color = tierInfo.Color
	local width = tierInfo.BeamWidth or 1.0
	beamPart.Size = Vector3.new(width, width, dist)
	beamPart.CFrame = CFrame.lookAt(midPoint, targetPos)
	beamPart.Parent = Workspace

	-- ลูกแก้วระเบิดที่จุดปะทะ
	local impactSphere = Instance.new("Part")
	impactSphere.Name = "AnimeImpactOrb"
	impactSphere.Shape = Enum.PartType.Ball
	impactSphere.Anchored = true
	impactSphere.CanCollide = false
	impactSphere.Material = Enum.Material.Neon
	impactSphere.Color = tierInfo.SecondaryColor
	impactSphere.Size = Vector3.new(2, 2, 2)
	impactSphere.Position = targetPos
	impactSphere.Parent = Workspace

	local endSize = math.max(6, (tierInfo.SplashRadius or 3) * 1.5)
	TweenService:Create(beamPart, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.1, 0.1, dist),
		Transparency = 1,
	}):Play()

	TweenService:Create(impactSphere, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = Vector3.new(endSize, endSize, endSize),
		Transparency = 1,
	}):Play()

	task.delay(0.3, function()
		if beamPart then
			beamPart:Destroy()
		end
		if impactSphere then
			impactSphere:Destroy()
		end
	end)
end

-- 4. สร้างโมเดลแท่นยูนิตอนิเมะ 6 จุดข้างทางเดินอัตโนมัติ
local function ensureAnimeTowers()
	local towersFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.TOWERS)
	if towersFolder then
		return towersFolder
	end

	towersFolder = Instance.new("Folder")
	towersFolder.Name = GameConfig.FOLDERS.TOWERS
	towersFolder.Parent = Workspace

	local towerPositions = {
		Vector3.new(-40, 3, -28),
		Vector3.new(-32, 3, -10),
		Vector3.new(-8, 3, 8),
		Vector3.new(8, 3, 8),
		Vector3.new(32, 3, -5),
		Vector3.new(42, 3, -18),
	}

	for idx, pos in ipairs(towerPositions) do
		local towerModel = Instance.new("Model")
		towerModel.Name = "AnimeUnit_" .. idx

		-- แท่นยืนอัญเชิญ
		local pedestal = Instance.new("Part")
		pedestal.Name = "Pedestal"
		pedestal.Shape = Enum.PartType.Cylinder
		pedestal.Size = Vector3.new(1.5, 6, 6)
		pedestal.CFrame = CFrame.new(pos - Vector3.new(0, 2.2, 0)) * CFrame.Angles(0, 0, math.rad(90))
		pedestal.Anchored = true
		pedestal.Material = Enum.Material.Marble
		pedestal.Color = Color3.fromRGB(35, 35, 50)
		pedestal.Parent = towerModel

		-- ลำตัวยูนิตอนิเมะ
		local torso = Instance.new("Part")
		torso.Name = "Torso"
		torso.Size = Vector3.new(2.2, 4.5, 1.4)
		torso.Position = pos + Vector3.new(0, 0.8, 0)
		torso.Anchored = true
		torso.CanCollide = false
		torso.Material = Enum.Material.SmoothPlastic
		torso.Color = Color3.fromRGB(25, 30, 45)
		torso.Parent = towerModel

		-- ศีรษะยูนิตอนิเมะ
		local head = Instance.new("Part")
		head.Name = "Head"
		head.Size = Vector3.new(1.8, 1.8, 1.8)
		head.Position = pos + Vector3.new(0, 4.0, 0)
		head.Anchored = true
		head.CanCollide = false
		head.Color = Color3.fromRGB(255, 225, 195)
		head.Parent = towerModel

		-- ลูกแก้วปล่อยพลังด้านหน้าตัวละคร
		local orb = Instance.new("Part")
		orb.Name = "SpiritOrb"
		orb.Shape = Enum.PartType.Ball
		orb.Size = Vector3.new(1.5, 1.5, 1.5)
		orb.Position = pos + Vector3.new(0, 2.0, -2.0)
		orb.Anchored = true
		orb.CanCollide = false
		orb.Material = Enum.Material.Neon
		orb.Color = Color3.fromRGB(0, 215, 255)
		orb.Parent = towerModel

		-- วงแหวนแสดงระยะโจมตีบนพื้น
		local rangeRing = Instance.new("Part")
		rangeRing.Name = "RangeIndicator"
		rangeRing.Shape = Enum.PartType.Cylinder
		local initRange = GameConfig.INITIAL_PLAYER_STATS.RANGE_STAT
		rangeRing.Size = Vector3.new(0.15, initRange * 2, initRange * 2)
		rangeRing.CFrame = CFrame.new(pos - Vector3.new(0, 2.8, 0)) * CFrame.Angles(0, 0, math.rad(90))
		rangeRing.Anchored = true
		rangeRing.CanCollide = false
		rangeRing.Material = Enum.Material.ForceField
		rangeRing.Color = Color3.fromRGB(0, 215, 255)
		rangeRing.Transparency = 0.65
		rangeRing.Parent = towerModel

		-- ออร่ารอบตัวยูนิต
		local aura = Instance.new("Highlight")
		aura.Name = "AnimeAura"
		aura.FillColor = Color3.fromRGB(0, 215, 255)
		aura.OutlineColor = Color3.fromRGB(255, 255, 255)
		aura.FillTransparency = 0.45
		aura.Parent = towerModel

		-- ป้ายแสดงชื่อร่างและค่าพลังบนหัวยูนิต
		local bb = Instance.new("BillboardGui")
		bb.Name = "TowerStatGui"
		bb.Size = UDim2.new(0, 150, 0, 42)
		bb.StudsOffset = Vector3.new(0, 3.5, 0)
		bb.AlwaysOnTop = true
		bb.Adornee = head
		bb.Parent = towerModel

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "InfoText"
		titleLabel.Size = UDim2.new(1, 0, 1, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Font = Enum.Font.GothamBlack
		titleLabel.TextColor3 = Color3.fromRGB(0, 230, 255)
		titleLabel.TextStrokeTransparency = 0.1
		titleLabel.TextScaled = true
		titleLabel.Text = "SPIRIT NOVICE\nDMG: 35 | RNG: 32"
		titleLabel.Parent = bb

		towerModel.PrimaryPart = torso
		towerModel.Parent = towersFolder
	end

	return towersFolder
end

-- 5. โหมดสร้างหุ่นซ้อมอัตโนมัติ (ทำงานเฉพาะตอนรันเทส Worktree ที่ 2 แยกเดี่ยวๆ)
local function ensureTestDummyIfStandalone()
	task.delay(3, function()
		local enemiesFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.ENEMIES)
		if not enemiesFolder then
			enemiesFolder = Instance.new("Folder")
			enemiesFolder.Name = GameConfig.FOLDERS.ENEMIES
			enemiesFolder.Parent = Workspace

			-- เสกหุ่นซ้อมอมตะเพื่อให้เห็นเอฟเฟกต์ป้อมยิงทันทีแม้ไม่มี Track 1
			local dummy = Instance.new("Model")
			dummy.Name = "StandaloneTrainingDummy"

			local root = Instance.new("Part")
			root.Name = "HumanoidRootPart"
			root.Size = Vector3.new(3, 5, 2)
			root.Position = Vector3.new(-30, 3, -20)
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

-- 6. ลูปควบคุมการยิงและการวิวัฒนาการของยูนิตอนิเมะแต่ละตัว
local towersFolder = ensureAnimeTowers()
ensureTestDummyIfStandalone()

for _, towerModel in ipairs(towersFolder:GetChildren()) do
	task.spawn(function()
		local torso = towerModel:WaitForChild("Torso") :: BasePart
		local head = towerModel:WaitForChild("Head") :: BasePart
		local orb = towerModel:WaitForChild("SpiritOrb") :: BasePart
		local rangeRing = towerModel:WaitForChild("RangeIndicator") :: BasePart
		local aura = towerModel:WaitForChild("AnimeAura") :: Highlight
		local infoText = towerModel:WaitForChild("TowerStatGui"):WaitForChild("InfoText") :: TextLabel

		while towerModel.Parent do
			local dmg, range, cooldown = getCurrentCombatStats()
			local tier = getEvolutionTier(dmg)

			-- อัปเดตสีออร่า ป้ายสเตตัส และขนาดวงแหวนระยะยิงแบบสดๆ
			aura.FillColor = tier.Color
			orb.Color = tier.Color
			rangeRing.Color = tier.Color
			rangeRing.Size = Vector3.new(0.15, range * 2, range * 2)
			infoText.TextColor3 = tier.Color
			infoText.Text = string.format("%s\nDMG: %d | SPD: %.2fs", tier.Name, math.floor(dmg), cooldown)

			-- ค้นหาซอมบี้ที่ใกล้ที่สุดในระยะยิง
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
					-- หันหน้ายูนิตอนิเมะไปทางเป้าหมาย
					local lookPos = Vector3.new(targetRoot.Position.X, torso.Position.Y, targetRoot.Position.Z)
					torso.CFrame = CFrame.lookAt(torso.Position, lookPos)
					head.Position = torso.Position + Vector3.new(0, 3.2, 0)
					orb.Position = torso.Position + (torso.CFrame.LookVector * 2.2) + Vector3.new(0, 1.0, 0)

					-- ปล่อยเอฟเฟกต์ลำแสงอนิเมะ
					playAnimeBlastVFX(orb.Position, targetRoot.Position, tier)

					-- ทำดาเมจเดี่ยวหรือดาเมจระเบิดวงกว้าง (AoE Splash)
					if tier.SplashRadius and tier.SplashRadius > 0 and enemiesFolder then
						for _, otherEnemy in ipairs(enemiesFolder:GetChildren()) do
							local oRoot = otherEnemy:FindFirstChild("HumanoidRootPart") :: BasePart?
							local oHum = otherEnemy:FindFirstChildOfClass("Humanoid")
							if oRoot and oHum and oHum.Health > 0 then
								if (oRoot.Position - targetRoot.Position).Magnitude <= tier.SplashRadius then
									oHum:TakeDamage(dmg)
								end
							end
						end
					else
						targetHum:TakeDamage(dmg)
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

## 3. วิธีรันเทสแยกเฉพาะงานที่ 2 และตารางตรวจรับงาน (UAT Track 2)

คุณสามารถทดสอบป้อมอนิเมะปล่อยพลังใน Worktree ที่ 2 ได้ทันทีโดยไม่ต้องรอให้งานที่ 1 หรือ 3 เสร็จ:

### ขั้นตอนการรันเทสแยกของ Worktree ที่ 2
1. ใน Terminal หน้าต่างที่ 2 (`../wt-track2-towers`) รันคำสั่ง:
   ```bash
   rojo serve --port 34872
   ```
2. เปิด Roblox Studio -> เชื่อมต่อปลั๊กอิน **Rojo** ที่พอร์ต `34872` แล้วกด **Play (F5)**
3. รอ 3 วินาที สคริปต์จะเสก `StandaloneTrainingDummy` ออกมาให้ยูนิตอนิเมะยิงโชว์อัตโนมัติ

### ตาราง UAT (User Acceptance Test) สำหรับงานส่วนที่ 2

| รหัส UAT | รายการทดสอบ (Test Case) | วิธีทดสอบใน Roblox Studio | ผลลัพธ์ที่ต้องเห็น (Expected Result) | สถานะ |
| :--- | :--- | :--- | :--- | :--- |
| **UAT-2.1** | การเสกยูนิตอนิเมะทั้ง 6 จุดพร้อมวงแหวนระยะยิง | กด Play แล้วดูในโฟลเดอร์ `Workspace.AnimeTowers` | มียูนิต `AnimeUnit_1` ถึง `AnimeUnit_6` พร้อมออร่าสีฟ้า ป้ายชื่อ `SPIRIT NOVICE` และวงแหวนระยะยิงบนพื้น | [ ] ผ่าน |
| **UAT-2.2** | การล็อกเป้าและปล่อยลำแสงอนิเมะอัตโนมัติ | สังเกตยูนิตที่อยู่ใกล้ `StandaloneTrainingDummy` (หรือใกล้ซอมบี้) | ยูนิตหันหน้าเข้าหาเป้าหมายและยิงลำแสงสีฟ้าเรืองแสงพร้อมระเบิดลูกแก้วที่ตัวเป้าหมายทุกๆ `1.0` วินาที | [ ] ผ่าน |
| **UAT-2.3** | การเปลี่ยนร่างอนิเมะ (Evolution Tier) ตามค่า `DamageStat` | คลิกที่ชื่อผู้เล่นตัวเองใน `Players` แล้วแก้ Attribute `DamageStat` เป็น `150`, `500`, และ `2000` ตามลำดับ | ป้ายชื่อและสีลำแสงเปลี่ยนทันที: `150` = สีม่วง (`AWAKENED SORCERER`), `500` = สีทอง (`SUPER GOLDEN FORM`), `2000` = สีแดงทมิฬ (`GOD OF DESTRUCTION`) | [ ] ผ่าน |
| **UAT-2.4** | การขยายวงแหวนระยะยิงและความเร็วโจมตีแบบเรียลไทม์ | แก้ Attribute `RangeStat` เป็น `60` และ `CooldownStat` เป็น `0.2` บนตัวผู้เล่น | วงแหวนบนพื้นขยายกว้างขึ้นทันที และยูนิตระดมยิงลำแสงรัวเร็วขึ้นเป็นทุกๆ `0.2` วินาที | [ ] ผ่าน |
| **UAT-2.5** | การแยกไฟล์ไม่ชนกับงานอื่น (Git Isolation Check) | รันคำสั่ง `git status` ในโฟลเดอร์ `../wt-track2-towers` | มีการแก้ไขเฉพาะใน `src/Track2_TowerSystem/` เท่านั้น ไม่กระทบไฟล์ของ Track 1 และ Track 3 | [ ] ผ่าน |
