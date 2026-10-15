--!strict
-- src/Track2_TowerSystem/TowerController.server.luau
-- Anime Limitless Tower Defense: Track 2 Anime Hero Towers & Combat System
-- Auto-spawn hero units, real-time stat synchronization, procedural VFX, and 4-tier evolution.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

type EvolutionTier = {
	Name: string,
	Color: Color3,
	SecondaryColor: Color3,
	SplashRadius: number,
	BeamWidth: number,
}

-- 1. กำหนดระดับร่างวิวัฒนาการอนิเมะตามค่า DamageStat ไร้ขีดจำกัด
local function getEvolutionTier(damage: number): EvolutionTier
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
			BeamWidth = 1.0,
		}
	end
end

-- 2. ดึงสเตตัสปัจจุบันจากผู้เล่นในเซิร์ฟเวอร์ (รองรับทั้งเล่นคนเดียวและหลายคน)
local function getCurrentCombatStats(): (number, number, number)
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
local function playAnimeBlastVFX(originPos: Vector3, targetPos: Vector3, tierInfo: EvolutionTier)
	local dist = (targetPos - originPos).Magnitude
	if dist < 0.05 then
		return
	end

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
local function ensureAnimeTowers(): Folder
	local towersFolder = Workspace:FindFirstChild(GameConfig.FOLDERS.TOWERS)
	if towersFolder and towersFolder:IsA("Folder") then
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
		if not enemiesFolder or #enemiesFolder:GetChildren() == 0 then
			if not enemiesFolder then
				enemiesFolder = Instance.new("Folder")
				enemiesFolder.Name = GameConfig.FOLDERS.ENEMIES
				enemiesFolder.Parent = Workspace
			end

			-- ตรวจสอบซ้ำอีกครั้งว่ามีหุ่นซ้อมอยู่แล้วหรือไม่
			if not enemiesFolder:FindFirstChild("StandaloneTrainingDummy") then
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
		end
	end)
end

-- 6. เริ่มต้นสร้างหอคอยและลูปควบคุมการยิงและการวิวัฒนาการ
local towersFolder = ensureAnimeTowers()
ensureTestDummyIfStandalone()

for _, towerChild in ipairs(towersFolder:GetChildren()) do
	if not towerChild:IsA("Model") then
		continue
	end
	local towerModel = towerChild

	task.spawn(function()
		local torso = towerModel:WaitForChild("Torso") :: BasePart
		local head = towerModel:WaitForChild("Head") :: BasePart
		local orb = towerModel:WaitForChild("SpiritOrb") :: BasePart
		local rangeRing = towerModel:WaitForChild("RangeIndicator") :: BasePart
		local aura = towerModel:WaitForChild("AnimeAura") :: Highlight
		local statGui = towerModel:WaitForChild("TowerStatGui")
		local infoText = statGui:WaitForChild("InfoText") :: TextLabel

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
					if not enemy:IsA("Model") then
						continue
					end
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
				local targetRoot = nearestEnemy:FindFirstChild("HumanoidRootPart") :: BasePart?
				local targetHum = nearestEnemy:FindFirstChildOfClass("Humanoid")
				if targetRoot and targetHum and targetHum.Health > 0 then
					-- หันหน้ายูนิตอนิเมะไปทางเป้าหมาย
					local lookPos = Vector3.new(targetRoot.Position.X, torso.Position.Y, targetRoot.Position.Z)
					if (lookPos - torso.Position).Magnitude > 0.05 then
						torso.CFrame = CFrame.lookAt(torso.Position, lookPos)
					end
					head.Position = torso.Position + Vector3.new(0, 3.2, 0)
					orb.Position = torso.Position + (torso.CFrame.LookVector * 2.2) + Vector3.new(0, 1.0, 0)

					-- ปล่อยเอฟเฟกต์ลำแสงอนิเมะ
					playAnimeBlastVFX(orb.Position, targetRoot.Position, tier)

					-- ทำดาเมจเดี่ยวหรือดาเมจระเบิดวงกว้าง (AoE Splash)
					if tier.SplashRadius and tier.SplashRadius > 0 and enemiesFolder then
						for _, otherEnemy in ipairs(enemiesFolder:GetChildren()) do
							if not otherEnemy:IsA("Model") then
								continue
							end
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
