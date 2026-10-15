--!strict
-- src/Track3_UpgradeServer/UpgradeServer.server.luau
-- Author: Google Antigravity (agy teamwork-preview / stang-darkmatter)
-- Plan: PLAN-0003 (One Piece Roguelike Wave Card Draft UI & Server - Phase 2)
-- Scope: Track 3 Server Authority Wave Card Draft & Upgrade Handler

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

local upgradeRemote = ReplicatedStorage:FindFirstChild(GameConfig.REMOTES.UPGRADE_REQUEST)
if not upgradeRemote then
	local newRemote = Instance.new("RemoteEvent")
	newRemote.Name = GameConfig.REMOTES.UPGRADE_REQUEST
	newRemote.Parent = ReplicatedStorage
	upgradeRemote = newRemote
end

-- ระบบ Fallback ตั้งค่าเริ่มต้นให้ผู้เล่น (ทำให้เทส Track 3 เดี่ยวๆ ได้ทันทีแม้ไม่มี Track 1)
local function ensurePlayerStats(player: Player)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then
		local newLs = Instance.new("Folder")
		newLs.Name = "leaderstats"
		newLs.Parent = player
		ls = newLs
	end

	local cash = ls:FindFirstChild("Cash") :: IntValue?
	if not cash then
		local newCash = Instance.new("IntValue")
		newCash.Name = "Cash"
		newCash.Value = GameConfig.INITIAL_PLAYER_STATS.CASH
		newCash.Parent = ls
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
