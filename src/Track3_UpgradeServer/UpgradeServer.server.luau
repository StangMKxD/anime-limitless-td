--!strict
-- src/Track3_UpgradeServer/UpgradeServer.server.luau
-- Anime Limitless Tower Defense — Phase 3: Grand Line Infinite Stat Upgrades & 12 Roguelike Wave Cards Server
-- Modular Zero-Conflict Architecture & Canonical Rules R01-R08 (Turnkey Production Candidate)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(SharedFolder:WaitForChild("GameConfig")) :: any

-- =============================================================================
-- TYPE DEFINITIONS
-- =============================================================================

export type UpgradeResult = {
	success: boolean,
	statType: string,
	newLevel: number,
	newCost: number,
	newStat: number,
	remainingCash: number,
	reason: string?,
}

export type CardSelectionResult = {
	success: boolean,
	cardId: string,
	reason: string?,
}

-- =============================================================================
-- CARD CATALOG CACHE & DUAL-RESOLUTION ALIAS ENGINE
-- =============================================================================

local CARD_MAP: { [string]: any } = {}

local function initializeCardMap()
	if GameConfig.CARD_POOL and typeof(GameConfig.CARD_POOL) == "table" then
		for _, card in ipairs(GameConfig.CARD_POOL) do
			if card.Id then
				CARD_MAP[card.Id] = card
			end
		end
	end

	-- Backward-compatibility aliases for legacy Phase 2 card IDs
	if not CARD_MAP["Card_GuraQuake"] and CARD_MAP["Card_GuraQuakeResonance"] then
		CARD_MAP["Card_GuraQuake"] = CARD_MAP["Card_GuraQuakeResonance"]
	end
	if not CARD_MAP["Card_IfritOverdrive"] and CARD_MAP["Card_PikaLightSpeed"] then
		-- Fallback to speed-enhancing card if legacy ID referenced
		CARD_MAP["Card_IfritOverdrive"] = CARD_MAP["Card_PikaLightSpeed"]
	end
	if not CARD_MAP["Card_BountyJackpot"] and CARD_MAP["Card_YonkoBounty"] then
		CARD_MAP["Card_BountyJackpot"] = CARD_MAP["Card_YonkoBounty"]
	end

	-- Dual-Resolution Prompt Aliases (Prompt requirement: RedHairHaki, FlameEmperor, etc.)
	local promptAliases: { [string]: any } = {
		RedHairHaki = { Id = "RedHairHaki", DamagePct = 0.35 },
		FlameEmperor = { Id = "FlameEmperor", DamageFlat = 18 },
		OpOpAmputate = { Id = "OpOpAmputate", RangeFlat = 8 },
		GuraSeismic = { Id = "GuraSeismic", SplashFlat = 12 },
		PikaSpeed = { Id = "PikaSpeed", CooldownMult = 0.82 },
		KingOfHellAsura = CARD_MAP["Card_KingOfHellAsura"] or { Id = "KingOfHellAsura", CritChanceFlat = 0.15, CritDamageFlat = 0.85, DamagePct = 0.40, DamageFlat = 25 },
		DemonFleurCrit = { Id = "DemonFleurCrit", CritDamageFlat = 0.65 },
		NamiBountyGreed = { Id = "NamiBountyGreed", BountyMultFlat = 0.50 },
		ThousandSunnyReinforce = { Id = "ThousandSunnyReinforce", ExtraTowerSlot = 1 },
		LoguetownExecution = { Id = "LoguetownExecution", BonusRerolls = 2 },
		MeatRecovery = { Id = "MeatRecovery", BaseHealOnly = 25 },
		GoldRogerLegacy = { Id = "GoldRogerLegacy", InstantCash = 500 },
	}

	for aliasKey, aliasDef in pairs(promptAliases) do
		if not CARD_MAP[aliasKey] then
			CARD_MAP[aliasKey] = aliasDef
		end
		local withPrefix = "Card_" .. aliasKey
		if not CARD_MAP[withPrefix] then
			CARD_MAP[withPrefix] = aliasDef
		end
	end
end

initializeCardMap()

local function findCard(cardId: string): any?
	if CARD_MAP[cardId] then
		return CARD_MAP[cardId]
	end
	if GameConfig.CARD_POOL and typeof(GameConfig.CARD_POOL) == "table" then
		for _, card in ipairs(GameConfig.CARD_POOL) do
			if card.Id == cardId then
				CARD_MAP[cardId] = card
				return card
			end
		end
	end
	return nil
end

-- =============================================================================
-- REMOTE EVENTS & REMOTE FUNCTIONS INITIALIZATION (IDEMPOTENT BOOTSTRAP)
-- =============================================================================

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes") :: Folder?
if not remotesFolder then
	local folder = Instance.new("Folder")
	folder.Name = "Remotes"
	folder.Parent = ReplicatedStorage
	remotesFolder = folder
end

local function getOrCreateRemoteEvent(name: string, parentContainer: Instance): RemoteEvent
	local existing = parentContainer:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local rem = Instance.new("RemoteEvent")
	rem.Name = name
	rem.Parent = parentContainer
	return rem
end

local function getOrCreateRemoteFunction(name: string, parentContainer: Instance): RemoteFunction
	local existing = parentContainer:FindFirstChild(name)
	if existing and existing:IsA("RemoteFunction") then
		return existing
	end
	local rf = Instance.new("RemoteFunction")
	rf.Name = name
	rf.Parent = parentContainer
	return rf
end

-- Primary Remotes as declared in PROJECT.md & DISPATCH.md
-- 1. RemoteFunction UpgradeStatRequest (yielding client invokes)
-- 2. RemoteEvent UpgradeRequest (event-based client requests)
-- 3. RemoteEvent CardDraftSelectRequest (event-based 12-card selections)
local upgradeStatFunction = getOrCreateRemoteFunction("UpgradeStatRequest", ReplicatedStorage)
local upgradeEvent = getOrCreateRemoteEvent("UpgradeRequest", ReplicatedStorage)
local cardDraftEvent = getOrCreateRemoteEvent("CardDraftSelectRequest", ReplicatedStorage)

-- Mirror inside ReplicatedStorage.Remotes for structural resilience
if remotesFolder then
	if not remotesFolder:FindFirstChild("UpgradeStatRequest") then
		getOrCreateRemoteFunction("UpgradeStatRequest", remotesFolder)
	end
	if not remotesFolder:FindFirstChild("UpgradeRequest") then
		getOrCreateRemoteEvent("UpgradeRequest", remotesFolder)
	end
	if not remotesFolder:FindFirstChild("CardDraftSelectRequest") then
		getOrCreateRemoteEvent("CardDraftSelectRequest", remotesFolder)
	end
end

-- =============================================================================
-- PLAYER BOOTSTRAPPING & LEADERSTATS / ATTRIBUTES FALLBACK
-- =============================================================================

local function getCash(player: Player): number
	local ls = player:FindFirstChild("leaderstats")
	local cashObj = ls and ls:FindFirstChild("Cash") :: IntValue?
	if cashObj then
		return cashObj.Value
	end
	local attrCash = player:GetAttribute("Cash") :: number?
	return attrCash or 500
end

local function setCash(player: Player, newCash: number)
	local ls = player:FindFirstChild("leaderstats")
	local cashObj = ls and ls:FindFirstChild("Cash") :: IntValue?
	if cashObj then
		cashObj.Value = newCash
	end
	player:SetAttribute("Cash", newCash)
end

local function ensurePlayerStats(player: Player)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then
		local newLs = Instance.new("Folder")
		newLs.Name = "leaderstats"
		newLs.Parent = player
		ls = newLs
	end

	local cashObj = ls:FindFirstChild("Cash") :: IntValue?
	if not cashObj then
		cashObj = Instance.new("IntValue")
		cashObj.Name = "Cash"
		cashObj.Value = 500
		cashObj.Parent = ls
	end

	-- Mirror attribute Cash and listen to leaderstats changes bidirectionally
	if player:GetAttribute("Cash") == nil then
		player:SetAttribute("Cash", cashObj.Value)
	end

	cashObj.Changed:Connect(function(newVal: number)
		if player:GetAttribute("Cash") ~= newVal then
			player:SetAttribute("Cash", newVal)
		end
	end)

	player:GetAttributeChangedSignal("Cash"):Connect(function()
		local attrVal = player:GetAttribute("Cash") :: number?
		if attrVal and cashObj.Value ~= attrVal then
			cashObj.Value = attrVal
		end
	end)

	local function initAttr(attrName: string, defaultValue: any)
		if player:GetAttribute(attrName) == nil then
			player:SetAttribute(attrName, defaultValue)
		end
	end

	-- Phase 3 Canonical Player Attributes (All 19 attributes)
	initAttr(GameConfig.PLAYER_ATTRS.FREE_SUMMON_TICKETS, 1)
	initAttr(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, 3)
	initAttr(GameConfig.PLAYER_ATTRS.MAX_PLACED_TOWERS, 4)
	initAttr(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, 45)
	initAttr(GameConfig.PLAYER_ATTRS.RANGE_STAT, 36)
	initAttr(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, 0.95)
	initAttr(GameConfig.PLAYER_ATTRS.CRIT_CHANCE, 0.15)
	initAttr(GameConfig.PLAYER_ATTRS.CRIT_DAMAGE, 1.50)
	initAttr(GameConfig.PLAYER_ATTRS.SPLASH_STAT, 6)
	initAttr(GameConfig.PLAYER_ATTRS.BOUNTY_MULT, 1.0)
	initAttr(GameConfig.PLAYER_ATTRS.INVENTORY_JSON, "[]")
	initAttr(GameConfig.PLAYER_ATTRS.PLACED_TOWERS_COUNT, 0)
	initAttr(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, 0)
	initAttr(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL, 0)
	initAttr(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, 1)
	initAttr(GameConfig.PLAYER_ATTRS.RANGE_LEVEL, 1)
	initAttr(GameConfig.PLAYER_ATTRS.SPEED_LEVEL, 1)
	initAttr(GameConfig.PLAYER_ATTRS.LAST_ROLLED_HERO_ID, "")
	initAttr(GameConfig.PLAYER_ATTRS.LAST_ROLLED_UNIT_UID, "")
	initAttr(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, "")
end

local function ensureWorkspaceAttributes()
	if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE) == nil then
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE, 1)
	end
	if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) == nil then
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, 1000)
	end
	if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP) == nil then
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP, 1000)
	end
	if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS) == nil then
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, "PREP PHASE")
	end
	if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) == nil then
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, false)
	end
	if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN) == nil then
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN, 15)
	end
end

ensureWorkspaceAttributes()

Players.PlayerAdded:Connect(ensurePlayerStats)
for _, plr in ipairs(Players:GetPlayers()) do
	ensurePlayerStats(plr)
end

-- =============================================================================
-- EXPONENTIAL CASH STAT UPGRADE ENGINE
-- =============================================================================

local function processCashUpgrade(player: Player, statType: string): UpgradeResult
	ensurePlayerStats(player)
	local curCash = getCash(player)
	local normalizedType = string.lower(statType)

	if normalizedType == "damage" then
		local curLvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL) or 1) :: number
		local curStat = (player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) or 45) :: number
		local cost = math.floor(75 * math.pow(1.35, curLvl - 1))

		if curCash < cost then
			return {
				success = false,
				statType = "Damage",
				newLevel = curLvl,
				newCost = cost,
				newStat = curStat,
				remainingCash = curCash,
				reason = "InsufficientCash",
			}
		end

		local nextCash = curCash - cost
		local nextStat = math.floor(curStat * 1.35 + 10)
		local nextLvl = curLvl + 1
		local nextCost = math.floor(75 * math.pow(1.35, nextLvl - 1))

		setCash(player, nextCash)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, nextStat)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, nextLvl)

		return {
			success = true,
			statType = "Damage",
			newLevel = nextLvl,
			newCost = nextCost,
			newStat = nextStat,
			remainingCash = nextCash,
		}

	elseif normalizedType == "range" then
		local curLvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL) or 1) :: number
		local curStat = (player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) or 36) :: number
		local cost = math.floor(60 * math.pow(1.30, curLvl - 1))

		if curCash < cost then
			return {
				success = false,
				statType = "Range",
				newLevel = curLvl,
				newCost = cost,
				newStat = curStat,
				remainingCash = curCash,
				reason = "InsufficientCash",
			}
		end

		local nextCash = curCash - cost
		local nextStat = curStat + 4
		local nextLvl = curLvl + 1
		local nextCost = math.floor(60 * math.pow(1.30, nextLvl - 1))

		setCash(player, nextCash)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT, nextStat)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL, nextLvl)

		return {
			success = true,
			statType = "Range",
			newLevel = nextLvl,
			newCost = nextCost,
			newStat = nextStat,
			remainingCash = nextCash,
		}

	elseif normalizedType == "speed" then
		local curLvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL) or 1) :: number
		local curStat = (player:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) or 0.95) :: number
		local minCd = (GameConfig.INITIAL_PLAYER_STATS and GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN) or 0.15
		local cost = math.floor(90 * math.pow(1.40, curLvl - 1))

		if curCash < cost then
			return {
				success = false,
				statType = "Speed",
				newLevel = curLvl,
				newCost = cost,
				newStat = curStat,
				remainingCash = curCash,
				reason = "InsufficientCash",
			}
		end

		local nextCash = curCash - cost
		local nextStat = math.max(minCd, math.floor(curStat * 0.90 * 100) / 100)
		local nextLvl = curLvl + 1
		local nextCost = math.floor(90 * math.pow(1.40, nextLvl - 1))

		setCash(player, nextCash)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, nextStat)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL, nextLvl)

		return {
			success = true,
			statType = "Speed",
			newLevel = nextLvl,
			newCost = nextCost,
			newStat = nextStat,
			remainingCash = nextCash,
		}
	else
		return {
			success = false,
			statType = statType,
			newLevel = 1,
			newCost = 0,
			newStat = 0,
			remainingCash = curCash,
			reason = "InvalidStatType",
		}
	end
end

-- =============================================================================
-- 12 ROGUELIKE WAVE CARD DRAFT ENGINE
-- =============================================================================

local function handleCardSelect(player: Player, cardId: string): (boolean, string?)
	ensurePlayerStats(player)
	local pendingDraws = (player:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) or 0) :: number
	if pendingDraws <= 0 then
		return false, "NoPendingDraws"
	end

	local card = findCard(cardId)
	if not card then
		return false, "CardNotFound"
	end

	-- Decrement pending card draws & increment total picked
	player:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, math.max(0, pendingDraws - 1))
	local pickedTotal = (player:GetAttribute(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL) or 0) :: number
	player:SetAttribute(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL, pickedTotal + 1)

	-- Apply Card Modifiers with Domain Clamps & Invariants
	if card.DamagePct or card.DamageFlat then
		local curDmg = (player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) or 45) :: number
		local pct = card.DamagePct or 0
		local flat = card.DamageFlat or 0
		local nextDmg = math.floor(curDmg * (1 + pct) + flat)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, nextDmg)
	end

	if card.RangeFlat then
		local curRng = (player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) or 36) :: number
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT, curRng + card.RangeFlat)
	end

	if card.CooldownMult then
		local curCd = (player:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) or 0.95) :: number
		local minCd = (GameConfig.INITIAL_PLAYER_STATS and GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN) or 0.15
		local nextCd = math.max(minCd, curCd * card.CooldownMult)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, nextCd)
	end

	if card.SplashFlat then
		local curSplash = (player:GetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT) or 6) :: number
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT, curSplash + card.SplashFlat)
	end

	if card.CritChanceFlat then
		local curCrit = (player:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE) or 0.15) :: number
		local maxCrit = (GameConfig.INITIAL_PLAYER_STATS and GameConfig.INITIAL_PLAYER_STATS.MAX_CRIT_CHANCE) or 0.95
		local nextCrit = math.min(maxCrit, curCrit + card.CritChanceFlat)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE, nextCrit)
	end

	if card.CritDamageFlat then
		local curCritDmg = (player:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_DAMAGE) or 1.50) :: number
		player:SetAttribute(GameConfig.PLAYER_ATTRS.CRIT_DAMAGE, curCritDmg + card.CritDamageFlat)
	end

	if card.BountyMultFlat then
		local curBounty = (player:GetAttribute(GameConfig.PLAYER_ATTRS.BOUNTY_MULT) or 1.0) :: number
		player:SetAttribute(GameConfig.PLAYER_ATTRS.BOUNTY_MULT, curBounty + card.BountyMultFlat)
	end

	if card.BonusRerolls then
		local curTokens = (player:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) or 0) :: number
		player:SetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, curTokens + card.BonusRerolls)
	end

	if card.ExtraTowerSlot then
		local curMaxTowers = (player:GetAttribute(GameConfig.PLAYER_ATTRS.MAX_PLACED_TOWERS) or 4) :: number
		local maxCap = (GameConfig.INITIAL_PLAYER_STATS and GameConfig.INITIAL_PLAYER_STATS.MAX_TOWERS_LIMIT) or 8
		player:SetAttribute(GameConfig.PLAYER_ATTRS.MAX_PLACED_TOWERS, math.min(maxCap, curMaxTowers + card.ExtraTowerSlot))
	end

	if card.InstantCash then
		local curCash = getCash(player)
		setCash(player, curCash + card.InstantCash)
	end

	if card.BaseHeal then
		local curMaxHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP) or 1000) :: number
		local curHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) or curMaxHp) :: number
		local newMaxHp = curMaxHp + card.BaseHeal
		local newHp = curHp + card.BaseHeal
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP, newMaxHp)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, newHp)
	elseif card.BaseHealOnly then
		local curMaxHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP) or 1000) :: number
		local curHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) or curMaxHp) :: number
		local newHp = math.min(curMaxHp, curHp + card.BaseHealOnly)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, newHp)
	end

	return true, nil
end

-- =============================================================================
-- LEGACY UTILITY ACTIONS (EXTRA DRAWS & CARD REROLL)
-- =============================================================================

local function handleBuyExtraCardDraw(player: Player): boolean
	ensurePlayerStats(player)
	local curCash = getCash(player)
	local totalPicked = (player:GetAttribute(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL) or 0) :: number
	local baseCost = (GameConfig.WAVE_SETTINGS and GameConfig.WAVE_SETTINGS.EXTRA_CARD_BASE_COST) or 150
	local drawCost = math.floor(baseCost * math.pow(1.25, totalPicked))
	if curCash >= drawCost then
		setCash(player, curCash - drawCost)
		local pending = (player:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) or 0) :: number
		player:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, pending + 1)
		return true
	end
	return false
end

local function handleRerollCards(player: Player): boolean
	ensurePlayerStats(player)
	local curCash = getCash(player)
	if curCash >= 50 then
		setCash(player, curCash - 50)
		return true
	end
	return false
end

local function handleEarlyStart(player: Player): boolean
	local prepAttr = GameConfig.WORKSPACE_ATTRS.PREP_COUNTDOWN or "PrepCountdown"
	Workspace:SetAttribute(prepAttr, 0)
	local waveStatusAttr = GameConfig.WORKSPACE_ATTRS.WAVE_STATUS or "WaveStatus"
	Workspace:SetAttribute(waveStatusAttr, "HERO READY! STARTING WAVE 1...")
	Workspace:SetAttribute("EarlyStartTriggered", true)
	return true
end

-- =============================================================================
-- REMOTE EVENT & REMOTE FUNCTION DISPATCH HANDLERS
-- =============================================================================

-- 1. RemoteFunction UpgradeStatRequest Handler (Yielding invoke from Client UI)
local function onUpgradeStatInvoke(player: Player, statTypeOrAction: any): any
	if typeof(statTypeOrAction) ~= "string" then
		return { success = false, reason = "InvalidArguments" }
	end
	local actionStr = statTypeOrAction :: string

	if actionStr == "EarlyStart" then
		local ok = handleEarlyStart(player)
		return { success = ok, action = actionStr }
	elseif actionStr == "BuyExtraCardDraw" then
		local ok = handleBuyExtraCardDraw(player)
		return { success = ok, action = actionStr }
	elseif actionStr == "RerollCards" then
		local ok = handleRerollCards(player)
		return { success = ok, action = actionStr, remainingCash = getCash(player) }
	elseif string.sub(actionStr, 1, 5) == "Card_" or findCard(actionStr) ~= nil then
		local ok, errReason = handleCardSelect(player, actionStr)
		return { success = ok, cardId = actionStr, reason = errReason }
	else
		return processCashUpgrade(player, actionStr)
	end
end

upgradeStatFunction.OnServerInvoke = onUpgradeStatInvoke

-- Also attach invoke handler to Remotes folder instance if separate
local remoteFolderFunction = remotesFolder and remotesFolder:FindFirstChild("UpgradeStatRequest") :: RemoteFunction?
if remoteFolderFunction and remoteFolderFunction ~= upgradeStatFunction then
	remoteFolderFunction.OnServerInvoke = onUpgradeStatInvoke
end

-- 2. RemoteEvent UpgradeRequest Handler (FireServer from Client UI / Legacy remotes)
local function onUpgradeEvent(player: Player, statTypeOrAction: any)
	if typeof(statTypeOrAction) ~= "string" then
		return
	end
	local actionStr = statTypeOrAction :: string

	if actionStr == "EarlyStart" then
		handleEarlyStart(player)
	elseif actionStr == "BuyExtraCardDraw" then
		handleBuyExtraCardDraw(player)
	elseif actionStr == "RerollCards" then
		handleRerollCards(player)
	elseif string.sub(actionStr, 1, 5) == "Card_" or findCard(actionStr) ~= nil then
		handleCardSelect(player, actionStr)
	else
		processCashUpgrade(player, actionStr)
	end
end

upgradeEvent.OnServerEvent:Connect(onUpgradeEvent)

local remoteFolderEvent = remotesFolder and remotesFolder:FindFirstChild("UpgradeRequest") :: RemoteEvent?
if remoteFolderEvent and remoteFolderEvent ~= upgradeEvent then
	remoteFolderEvent.OnServerEvent:Connect(onUpgradeEvent)
end

-- 3. RemoteEvent CardDraftSelectRequest Handler
local function onCardDraftEvent(player: Player, cardId: any)
	if typeof(cardId) == "string" then
		handleCardSelect(player, cardId)
	end
end

cardDraftEvent.OnServerEvent:Connect(onCardDraftEvent)

local remoteFolderCardDraft = remotesFolder and remotesFolder:FindFirstChild("CardDraftSelectRequest") :: RemoteEvent?
if remoteFolderCardDraft and remoteFolderCardDraft ~= cardDraftEvent then
	remoteFolderCardDraft.OnServerEvent:Connect(onCardDraftEvent)
end

print("[UpgradeServer] Phase 3 Grand Line Upgrade Server initialized successfully.")
