--!strict
-- src/Track3_UpgradeServer/UpgradeServer.server.luau
-- Author: Google Antigravity (agy teamwork-preview / stang-darkmatter)
-- Plan: PLAN-0003 (Infinite Upgrade UI and Server System)
-- Scope: Track 3 Server Authority Upgrade Handler and Player Stats Auto-Bootstrap

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

-- สร้างหรือดึง RemoteEvent สำหรับรับคำสั่งอัปเกรดจาก UI
local upgradeRemote: RemoteEvent
local existingRemote = ReplicatedStorage:FindFirstChild(GameConfig.REMOTES.UPGRADE_REQUEST)
if existingRemote and existingRemote:IsA("RemoteEvent") then
	upgradeRemote = existingRemote
else
	local newRemote = Instance.new("RemoteEvent")
	newRemote.Name = GameConfig.REMOTES.UPGRADE_REQUEST
	newRemote.Parent = ReplicatedStorage
	upgradeRemote = newRemote
end

-- ระบบ Fallback ตั้งค่าเริ่มต้นให้ผู้เล่น (ทำให้เทส Track 3 เดี่ยวๆ ได้ทันทีแม้ยังไม่ได้รัน Track 1)
local function ensurePlayerStats(player: Player)
	local ls = player:FindFirstChild("leaderstats") :: Folder?
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
	end
	if player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) == nil then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT, GameConfig.INITIAL_PLAYER_STATS.RANGE_STAT)
	end
	if player:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) == nil then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, GameConfig.INITIAL_PLAYER_STATS.COOLDOWN_STAT)
	end
	if player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL) == nil then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, 1)
	end
	if player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL) == nil then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL, 1)
	end
	if player:GetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL) == nil then
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
		return math.floor(75 * (1.35 ^ (currentLevel - 1)))
	elseif upgradeType == "Range" then
		return math.floor(60 * (1.30 ^ (currentLevel - 1)))
	elseif upgradeType == "Speed" then
		return math.floor(90 * (1.40 ^ (currentLevel - 1)))
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
			local currentDmg = (player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) or GameConfig.INITIAL_PLAYER_STATS.DAMAGE_STAT) :: number
			local nextDmg = math.floor(currentDmg * 1.35 + 10)
			player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, nextDmg)
			player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, lvl + 1)
		end
	elseif upgradeType == "Range" then
		local lvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL) or 1) :: number
		local cost = getUpgradeCost("Range", lvl)
		if cash.Value >= cost then
			cash.Value -= cost
			local currentRange = (player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) or GameConfig.INITIAL_PLAYER_STATS.RANGE_STAT) :: number
			player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT, currentRange + 4)
			player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL, lvl + 1)
		end
	elseif upgradeType == "Speed" then
		local lvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL) or 1) :: number
		local cost = getUpgradeCost("Speed", lvl)
		local currentCd = (player:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) or GameConfig.INITIAL_PLAYER_STATS.COOLDOWN_STAT) :: number
		if cash.Value >= cost and currentCd > GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN then
			cash.Value -= cost
			local nextCd = math.max(GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN, math.floor(currentCd * 0.90 * 100) / 100)
			player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, nextCd)
			player:SetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL, lvl + 1)
		end
	end
end)
