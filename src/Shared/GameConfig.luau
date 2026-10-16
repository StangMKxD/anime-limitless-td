--!strict
-- src/Shared/GameConfig.luau
-- Phase 3 Data Contract: Gacha Summon, Tactical Slot Placement, Bag/Sell, 8 One Piece Heroes & 12 Roguelike Cards

-- =============================================================================
-- EXPORTED STRICT LUAU TYPES
-- =============================================================================

export type HeroSpec = {
	Id: string,
	Name: string,
	Subtitle: string,
	Rarity: string,
	Weight: number,
	DamageMult: number,
	RangeBonus: number,
	CooldownMult: number,
	SplashBonus: number,
	SellValue: number,
	AttackStyle: string,
	Onomatopoeia: string,
	PrimaryColor: Color3,
	SecondaryColor: Color3,
}

export type SlotDef = {
	SlotId: string,
	Label: string,
	Position: Vector3,
}

export type CardDef = {
	Id: string,
	Rarity: string,
	Category: string,
	Title: string,
	Desc: string,
	BorderColor: Color3,
	BgColor: Color3,
	DamagePct: number?,
	DamageFlat: number?,
	RangeFlat: number?,
	CooldownMult: number?,
	SplashFlat: number?,
	CritChanceFlat: number?,
	CritDamageFlat: number?,
	BountyMultFlat: number?,
	ExtraTowerSlot: number?,
	InstantCash: number?,
	BonusRerolls: number?,
	BaseHeal: number?,
}

export type BagUnit = {
	Uid: string,
	HeroId: string,
	Name: string,
	Rarity: string,
	SellValue: number,
}

export type EnemyClassSpec = {
	Id: string,
	Name: string,
	MinWave: number,
	UnlockWave: number,
	HpMult: number,
	SpeedMult: number,
	MaxSpeed: number?,
	MinSpeed: number?,
	ArmorMod: number,
	ArmorBonus: number,
	MaxArmor: number,
	Scale: number,
	AuraColor: Color3,
	BossFlag: boolean,
	IsBoss: boolean,
	RegenPerSec: number,
	RewardMult: number,
	BodyColor: Color3,
}

local GameConfig = {}

-- =============================================================================
-- WORKSPACE & PLAYER ATTRIBUTES CONTRACT
-- =============================================================================

GameConfig.WORKSPACE_ATTRS = {
	CURRENT_WAVE = "CurrentWave",
	WAVE_STATUS = "WaveStatus",
	BASE_HP = "BaseHP",
	MAX_BASE_HP = "MaxBaseHP",
	ZOMBIES_REMAINING = "ZombiesRemaining",
	GAME_OVER = "GameOver",
	PENDING_CARD_DRAWS = "PendingCardDraws",
	PREP_COUNTDOWN = "PrepCountdown",
}

GameConfig.PLAYER_ATTRS = {
	DAMAGE_STAT = "DamageStat",
	RANGE_STAT = "RangeStat",
	COOLDOWN_STAT = "CooldownStat",
	SPLASH_STAT = "SplashRadiusStat",
	CRIT_CHANCE = "CritChanceStat",
	CRIT_DAMAGE = "CritDamageStat",
	BOUNTY_MULT = "BountyMultiplierStat",
	DAMAGE_LEVEL = "DamageLevel",
	RANGE_LEVEL = "RangeLevel",
	SPEED_LEVEL = "SpeedLevel",
	PENDING_CARD_DRAWS = "PendingCardDraws",
	CARDS_PICKED_TOTAL = "CardsPickedTotal",
	-- Phase 3 Gacha, Bag & Slot Attributes
	REROLL_TOKENS = "RerollTokens",
	FREE_SUMMON_TICKETS = "FreeSummonTickets",
	MAX_PLACED_TOWERS = "MaxPlacedTowersStat",
	PLACED_TOWERS_COUNT = "PlacedTowersCount",
	INVENTORY_JSON = "HeroInventoryJson",
	LAST_ROLLED_HERO_ID = "LastRolledHeroId",
	LAST_ROLLED_UNIT_UID = "LastRolledUnitUid",
	SELECTED_BAG_UID = "SelectedBagUnitUid",
}

GameConfig.ATTRIBUTES = {
	WORKSPACE = GameConfig.WORKSPACE_ATTRS,
	PLAYER = GameConfig.PLAYER_ATTRS,
	-- Direct workspace attribute aliases
	CURRENT_WAVE = "CurrentWave",
	WAVE_STATUS = "WaveStatus",
	BASE_HP = "BaseHP",
	MAX_BASE_HP = "MaxBaseHP",
	ZOMBIES_REMAINING = "ZombiesRemaining",
	GAME_OVER = "GameOver",
	PENDING_CARD_DRAWS = "PendingCardDraws",
	PREP_COUNTDOWN = "PrepCountdown",
	-- Direct player attribute aliases
	DAMAGE_STAT = "DamageStat",
	RANGE_STAT = "RangeStat",
	COOLDOWN_STAT = "CooldownStat",
	SPLASH_STAT = "SplashRadiusStat",
	CRIT_CHANCE = "CritChanceStat",
	CRIT_DAMAGE = "CritDamageStat",
	BOUNTY_MULT = "BountyMultiplierStat",
	DAMAGE_LEVEL = "DamageLevel",
	RANGE_LEVEL = "RangeLevel",
	SPEED_LEVEL = "SpeedLevel",
	CARDS_PICKED_TOTAL = "CardsPickedTotal",
	REROLL_TOKENS = "RerollTokens",
	FREE_SUMMON_TICKETS = "FreeSummonTickets",
	MAX_PLACED_TOWERS = "MaxPlacedTowersStat",
	PLACED_TOWERS_COUNT = "PlacedTowersCount",
	INVENTORY_JSON = "HeroInventoryJson",
	LAST_ROLLED_HERO_ID = "LastRolledHeroId",
	LAST_ROLLED_UNIT_UID = "LastRolledUnitUid",
	SELECTED_BAG_UID = "SelectedBagUnitUid",
}

-- =============================================================================
-- INITIAL STATS & SYSTEM CONSTANTS
-- =============================================================================

GameConfig.INITIAL_PLAYER_STATS = {
	-- Canonical Phase 3 Contract
	DAMAGE = 50,
	RANGE = 30,
	COOLDOWN = 1.15,
	SPLASH_RADIUS = 7,
	CRIT_CHANCE = 0.08,
	CRIT_DAMAGE = 2.0,
	BOUNTY_MULT = 1.0,
	CASH = 500,
	REROLL_TOKENS = 3,
	FREE_SUMMON_TICKETS = 1,
	MAX_PLACED_TOWERS = 4,
	SUMMON_COST_CASH = 100,
	REROLL_COST_CASH = 80,
	MIN_COOLDOWN = 0.15,
	MAX_CRIT_CHANCE = 0.95,
	MAX_TOWERS_LIMIT = 8,
	MAX_TOWER_CAP_LIMIT = 8,
	INITIAL_CARD_DRAWS = 0,

	-- Backward-compatibility & casing aliases
	DAMAGE_STAT = 50,
	RANGE_STAT = 30,
	COOLDOWN_STAT = 1.15,
	SPLASH_STAT = 7,
	Cash = 500,
	FreeSummonTickets = 1,
	RerollTokens = 3,
	MaxPlacedTowers = 4,
	Damage = 50,
	Range = 30,
	Cooldown = 1.15,
	SplashRadius = 7,
	CritChance = 0.08,
	CritDamage = 2.0,
	BountyMultiplier = 1.0,
}

GameConfig.BASE_STATS = {
	BASE_HP = 1000,
	MAX_BASE_HP = 1000,
	PREP_COUNTDOWN = 15,
	MAX_WAVES = 15,
	BaseHP = 1000,
	MaxBaseHP = 1000,
	PrepCountdown = 15,
	MaxWaves = 15,
}

GameConfig.WAVE_SETTINGS = {
	INITIAL_BASE_HP = 1000,
	BASE_ZOMBIE_HP = 450,
	WAVE_HP_EXPONENT = 1.58,
	SURGE_INTERVAL = 3,
	SURGE_SCALE = 0.75,
	BASE_HAKI_ARMOR_STEP = 0.03,
	MAX_HAKI_ARMOR = 0.65,
	HP_GROWTH_RATE = 1.18, -- Legacy alias for Phase 3 test compatibility
	WAVE_SURGE_STEP = 0.75,
	WAVE_SURGE_INTERVAL = 3,
	BASE_SPEED_MIN = 11.0,
	BASE_SPEED_INC = 0.40,
	MAX_ZOMBIE_SPEED = 24.0,
	BASE_ZOMBIE_SPEED = 10.5,
	SPEED_INCREMENT_PER_WAVE = 0.25,
	HAKI_ARMOR_INC = 0.03,
	BASE_ENEMY_COUNT = 8,
	ENEMY_COUNT_SLOPE = 3.5,
	SPAWN_INTERVAL_MAX = 0.85,
	SPAWN_INTERVAL_MIN = 0.35,
	SPAWN_INTERVAL = 0.85,
	INTERMISSION_TIME = 5,
	PREP_COUNTDOWN = 15,
	PrepCountdown = 15,
	BOSS_WAVE_INTERVAL = 5, -- Legacy alias for Phase 3 test compatibility
	PHASE4_BOSS_WAVE_INTERVAL = 3,
	BOSS_ENDLESS_START = 10,
	BOSS_REGEN_PER_SEC = 0.025,
	MAX_WAVES = 15,
	MaxWaves = 15,
	BASE_CASH_REWARD = 25,
	EXTRA_CARD_BASE_COST = 150,
}

-- Phase 4 Endless Scaling Constants (PLAN-0007)
GameConfig.BASE_ZOMBIE_HP = 450
GameConfig.WAVE_HP_EXPONENT = 1.58
GameConfig.SURGE_INTERVAL = 3
GameConfig.SURGE_SCALE = 0.75
GameConfig.BASE_HAKI_ARMOR_STEP = 0.03
GameConfig.MAX_HAKI_ARMOR = 0.65

-- =============================================================================
-- 4 MONSTER CLASSES CONTRACT (PLAN-0007)
-- =============================================================================

GameConfig.ENEMY_CLASSES = {
	PirateGrunt = {
		Id = "PirateGrunt",
		Name = "Pirate Grunt",
		MinWave = 1,
		UnlockWave = 1,
		HpMult = 1.0,
		SpeedMult = 1.0,
		ArmorMod = 0.0,
		ArmorBonus = 0.0,
		MaxArmor = 0.65,
		Scale = 1.0,
		RegenPerSec = 0.0,
		RewardMult = 1.0,
		BodyColor = Color3.fromRGB(55, 95, 65),
		AuraColor = Color3.fromRGB(90, 40, 140),
		BossFlag = false,
		IsBoss = false,
	},
	SoruAssassin = {
		Id = "SoruAssassin",
		Name = "Soru Assassin",
		MinWave = 2,
		UnlockWave = 2,
		HpMult = 0.75,
		SpeedMult = 1.65,
		MaxSpeed = 34.0,
		ArmorMod = -0.5,
		ArmorBonus = -0.5,
		MaxArmor = 0.35,
		Scale = 0.95,
		RegenPerSec = 0.0,
		RewardMult = 1.3,
		BodyColor = Color3.fromRGB(30, 95, 190),
		AuraColor = Color3.fromRGB(0, 225, 255),
		BossFlag = false,
		IsBoss = false,
	},
	HakiBrute = {
		Id = "HakiBrute",
		Name = "Armored Haki Brute",
		MinWave = 3,
		UnlockWave = 3,
		HpMult = 2.8,
		SpeedMult = 0.78,
		MinSpeed = 8.0,
		ArmorMod = 0.30,
		ArmorBonus = 0.30,
		MaxArmor = 0.75,
		Scale = 1.35,
		RegenPerSec = 0.0,
		RewardMult = 2.0,
		BodyColor = Color3.fromRGB(22, 20, 28),
		AuraColor = Color3.fromRGB(165, 40, 255),
		BossFlag = false,
		IsBoss = false,
	},
	YonkoBoss = {
		Id = "YonkoBoss",
		Name = "Yonko Calamity Boss",
		MinWave = 3,
		UnlockWave = 3,
		HpMult = 8.0,
		SpeedMult = 0.72,
		MinSpeed = 7.5,
		ArmorMod = 0.25,
		ArmorBonus = 0.25,
		MaxArmor = 0.70,
		Scale = 2.2,
		RegenPerSec = 0.025,
		RewardMult = 6.0,
		BodyColor = Color3.fromRGB(130, 18, 35),
		AuraColor = Color3.fromRGB(255, 20, 60),
		BossFlag = true,
		IsBoss = true,
	},
}

-- Backward compatibility aliases for legacy enemy lookups
GameConfig.ENEMY_CLASSES.ThrillerZombie = GameConfig.ENEMY_CLASSES.PirateGrunt
GameConfig.ENEMY_CLASSES.CommandGeneral = GameConfig.ENEMY_CLASSES.SoruAssassin
GameConfig.ENEMY_CLASSES.GeneralZombie = GameConfig.ENEMY_CLASSES.HakiBrute
GameConfig.ENEMY_CLASSES.YonkoKaido = GameConfig.ENEMY_CLASSES.YonkoBoss

-- Standard Workspace Folders
GameConfig.FOLDERS = {
	WAYPOINTS = "Waypoints",
	ENEMIES = "Enemies",
	TOWERS = "AnimeTowers",
	PADS = "TowerPlacementPads",
	PLACEMENT_PADS = "TowerPlacementPads",
	MAP = "GrandLineMap",
}

-- Standard RemoteEvents & RemoteFunctions
GameConfig.REMOTES = {
	UPGRADE_REQUEST = "UpgradeStatRequest",
	CARD_DRAFT_SELECT = "CardDraftSelectRequest",
	TOWER_SUMMON_REROLL = "TowerSummonRerollRequest",
	TOWER_PLACEMENT_ACTION = "TowerPlacementActionRequest",
	VFX_CAMERA_SHAKE = "VFXCameraShakeEvent",
	-- Direct string aliases matching event names
	UpgradeStatRequest = "UpgradeStatRequest",
	CardDraftSelectRequest = "CardDraftSelectRequest",
	TowerSummonRerollRequest = "TowerSummonRerollRequest",
	TowerPlacementActionRequest = "TowerPlacementActionRequest",
	VFXCameraShakeEvent = "VFXCameraShakeEvent",
}

-- =============================================================================
-- 8 TACTICAL PLACEMENT SLOTS ALONG GRAND LINE MARINEFORD PATH
-- =============================================================================

GameConfig.PLACEMENT_SLOTS = {
	{ SlotId = "Slot_1", Label = "PAD 1 [FRONT LEFT]", Position = Vector3.new(-42, 3, -28) },
	{ SlotId = "Slot_2", Label = "PAD 2 [CENTER LEFT]", Position = Vector3.new(-10, 3, -28) },
	{ SlotId = "Slot_3", Label = "PAD 3 [INNER TURN]", Position = Vector3.new(-34, 3, 0) },
	{ SlotId = "Slot_4", Label = "PAD 4 [CENTER CORE]", Position = Vector3.new(0, 3, 6) },
	{ SlotId = "Slot_5", Label = "PAD 5 [SOUTH BEND]", Position = Vector3.new(-10, 3, 34) },
	{ SlotId = "Slot_6", Label = "PAD 6 [EAST BEND]", Position = Vector3.new(10, 3, 34) },
	{ SlotId = "Slot_7", Label = "PAD 7 [EAST GUARD]", Position = Vector3.new(34, 3, 0) },
	{ SlotId = "Slot_8", Label = "PAD 8 [BASE GUARD]", Position = Vector3.new(38, 3, -20) },
} :: { SlotDef }

-- =============================================================================
-- 8 ICONIC ONE PIECE HERO TOWERS (WEIGHT SUM = 100)
-- =============================================================================

GameConfig.HERO_CATALOG = {
	{
		Id = "Tower_Luffy_G5",
		Name = "MONKEY D. LUFFY",
		Subtitle = "SUN GOD NIKA [GEAR 5]",
		Rarity = "MYTHICAL YONKO",
		Weight = 8,
		DamageMult = 2.30,
		RangeBonus = 6,
		CooldownMult = 0.85,
		SplashBonus = 5,
		SellValue = 480,
		AttackStyle = "BajrangFist",
		Onomatopoeia = "DOOM!! (หมัดเทพนิกะ!!)",
		PrimaryColor = Color3.fromRGB(255, 250, 255),
		SecondaryColor = Color3.fromRGB(255, 45, 95),
	},
	{
		Id = "Tower_Shanks_Kamusari",
		Name = "RED-HAIRED SHANKS",
		Subtitle = "EMPEROR [KAMUSARI]",
		Rarity = "MYTHICAL YONKO",
		Weight = 7,
		DamageMult = 2.50,
		RangeBonus = 10,
		CooldownMult = 0.90,
		SplashBonus = 4,
		SellValue = 500,
		AttackStyle = "Kamusari",
		Onomatopoeia = "KAMUSARI!! (เทวะอาสัญ!!)",
		PrimaryColor = Color3.fromRGB(220, 25, 45),
		SecondaryColor = Color3.fromRGB(25, 10, 15),
	},
	{
		Id = "Tower_Whitebeard_Gura",
		Name = "EDWARD NEWGATE",
		Subtitle = "WHITEBEARD [GURA GURA]",
		Rarity = "MYTHICAL YONKO",
		Weight = 7,
		DamageMult = 2.60,
		RangeBonus = 8,
		CooldownMult = 1.10,
		SplashBonus = 8,
		SellValue = 500,
		AttackStyle = "GuraQuake",
		Onomatopoeia = "CRACK!! (สั่นสะเทือนโลกา!!)",
		PrimaryColor = Color3.fromRGB(240, 248, 255),
		SecondaryColor = Color3.fromRGB(110, 200, 255),
	},
	{
		Id = "Tower_Zoro_KingOfHell",
		Name = "RORONOA ZORO",
		Subtitle = "KING OF HELL [ENMA]",
		Rarity = "LEGENDARY HAKI",
		Weight = 14,
		DamageMult = 1.75,
		RangeBonus = 2,
		CooldownMult = 0.80,
		SplashBonus = 3,
		SellValue = 260,
		AttackStyle = "KingOfHell360",
		Onomatopoeia = "ONIGIRI!! (ราชานรก!!)",
		PrimaryColor = Color3.fromRGB(40, 235, 115),
		SecondaryColor = Color3.fromRGB(165, 55, 255),
	},
	{
		Id = "Tower_Ace_Entei",
		Name = "PORTGAS D. ACE",
		Subtitle = "FLAME EMPEROR [ENTEI]",
		Rarity = "LEGENDARY HAKI",
		Weight = 14,
		DamageMult = 1.80,
		RangeBonus = 8,
		CooldownMult = 0.95,
		SplashBonus = 6,
		SellValue = 250,
		AttackStyle = "Entei",
		Onomatopoeia = "ENTEI!! (มหาจักรพรรดิอัคคี!!)",
		PrimaryColor = Color3.fromRGB(255, 115, 20),
		SecondaryColor = Color3.fromRGB(255, 225, 60),
	},
	{
		Id = "Tower_Law_KRoom",
		Name = "TRAFALGAR LAW",
		Subtitle = "SURGEON OF DEATH [K-ROOM]",
		Rarity = "LEGENDARY HAKI",
		Weight = 14,
		DamageMult = 1.70,
		RangeBonus = 12,
		CooldownMult = 0.88,
		SplashBonus = 4,
		SellValue = 260,
		AttackStyle = "GammaKnife",
		Onomatopoeia = "K-ROOM!! (พังก์เจอร์ วิลเล!!)",
		PrimaryColor = Color3.fromRGB(65, 215, 255),
		SecondaryColor = Color3.fromRGB(170, 255, 120),
	},
	{
		Id = "Tower_Kizaru_Pika",
		Name = "ADMIRAL KIZARU",
		Subtitle = "BORSALINO [PIKA PIKA]",
		Rarity = "LEGENDARY HAKI",
		Weight = 14,
		DamageMult = 1.65,
		RangeBonus = 16,
		CooldownMult = 0.72,
		SplashBonus = 4,
		SellValue = 270,
		AttackStyle = "YasakaniLight",
		Onomatopoeia = "FLASH!! (ลำแสงความเร็วแสง!!)",
		PrimaryColor = Color3.fromRGB(255, 240, 75),
		SecondaryColor = Color3.fromRGB(255, 195, 25),
	},
	{
		Id = "Tower_Sanji_Ifrit",
		Name = "VINSMOKE SANJI",
		Subtitle = "IFRIT JAMBE [BLUE FLAME]",
		Rarity = "EPIC HAKI",
		Weight = 22,
		DamageMult = 1.45,
		RangeBonus = 0,
		CooldownMult = 0.68,
		SplashBonus = 2,
		SellValue = 140,
		AttackStyle = "BoeufBurst",
		Onomatopoeia = "IFRIT!! (ลูกเตะเพลิงสีคราม!!)",
		PrimaryColor = Color3.fromRGB(35, 145, 255),
		SecondaryColor = Color3.fromRGB(220, 245, 255),
	},
} :: { HeroSpec }

-- =============================================================================
-- 12 DIVERSE ROGUELIKE WAVE-CLEAR CARDS
-- =============================================================================

GameConfig.CARD_POOL = {
	{
		Id = "Card_Gear5Nika",
		Rarity = "MYTHICAL YONKO",
		Category = "ALL-OUT OFFENSE",
		Title = "SUN GOD NIKA: GEAR 5 AWAKENING",
		Desc = "+85% GLOBAL DAMAGE (+50 Flat)\n-15% ATTACK COOLDOWN | +3 AOE RADIUS",
		BorderColor = Color3.fromRGB(255, 55, 95),
		BgColor = Color3.fromRGB(60, 16, 32),
		DamagePct = 0.85,
		DamageFlat = 50,
		CooldownMult = 0.85,
		SplashFlat = 3,
	},
	{
		Id = "Card_GrandFleetCommand",
		Rarity = "MYTHICAL SYNERGY",
		Category = "FLEET COMMAND & ALL-STATS",
		Title = "STRAW HAT GRAND FLEET ALLIANCE",
		Desc = "+1 MAX PLACED TOWER SLOT\n+35% DAMAGE | +6 RANGE | -12% COOLDOWN | +6% CRIT",
		BorderColor = Color3.fromRGB(255, 215, 65),
		BgColor = Color3.fromRGB(55, 42, 12),
		ExtraTowerSlot = 1,
		DamagePct = 0.35,
		DamageFlat = 20,
		RangeFlat = 6,
		CooldownMult = 0.88,
		CritChanceFlat = 0.06,
	},
	{
		Id = "Card_DevilFruitAwakening",
		Rarity = "MYTHICAL YONKO",
		Category = "SUPREME AOE CATACLYSM",
		Title = "DEVIL FRUIT AWAKENING: MASTERY",
		Desc = "+6 STUDS SPLASH AOE RADIUS\n+55% GLOBAL DAMAGE (+35 Flat) | -10% COOLDOWN",
		BorderColor = Color3.fromRGB(230, 65, 255),
		BgColor = Color3.fromRGB(48, 15, 60),
		SplashFlat = 6,
		DamagePct = 0.55,
		DamageFlat = 35,
		CooldownMult = 0.90,
	},
	{
		Id = "Card_KingOfHellAsura",
		Rarity = "MYTHICAL CRIT",
		Category = "LETHAL HAKI CRITICAL",
		Title = "NINE-SWORD STYLE: ASURA DEMON AURA",
		Desc = "+15% CRITICAL CHANCE | +0.85x CRIT DAMAGE\n+40% GLOBAL DAMAGE (+25 Flat)",
		BorderColor = Color3.fromRGB(50, 255, 130),
		BgColor = Color3.fromRGB(15, 50, 30),
		CritChanceFlat = 0.15,
		CritDamageFlat = 0.85,
		DamagePct = 0.40,
		DamageFlat = 25,
	},
	{
		Id = "Card_ConquerorHaki",
		Rarity = "LEGENDARY HAKI",
		Category = "SUPREME KING POWER",
		Title = "CONQUEROR'S HAKI: SUPREME KING",
		Desc = "+45% GLOBAL DAMAGE (+25 Flat)\n+8% CRITICAL CHANCE | +0.25x CRIT DAMAGE",
		BorderColor = Color3.fromRGB(255, 195, 40),
		BgColor = Color3.fromRGB(55, 35, 15),
		DamagePct = 0.45,
		DamageFlat = 25,
		CritChanceFlat = 0.08,
		CritDamageFlat = 0.25,
	},
	{
		Id = "Card_GuraQuakeResonance",
		Rarity = "LEGENDARY AOE",
		Category = "TREMOR SHOCKWAVE",
		Title = "TREMOR-TREMOR SEA QUAKE RESONANCE",
		Desc = "+5 STUDS SPLASH AOE RADIUS\n+35% GLOBAL DAMAGE (+30 Flat)",
		BorderColor = Color3.fromRGB(95, 210, 255),
		BgColor = Color3.fromRGB(18, 42, 60),
		SplashFlat = 5,
		DamagePct = 0.35,
		DamageFlat = 30,
	},
	{
		Id = "Card_PikaLightSpeed",
		Rarity = "LEGENDARY SPEED",
		Category = "HYPER ATTACK SPEED",
		Title = "GLINT-GLINT LIGHT SPEED REFLEXES",
		Desc = "-22% ATTACK COOLDOWN (HYPER SPEED)\n+5 STUDS GLOBAL RANGE",
		BorderColor = Color3.fromRGB(255, 240, 80),
		BgColor = Color3.fromRGB(55, 50, 15),
		CooldownMult = 0.78,
		RangeFlat = 5,
	},
	{
		Id = "Card_YonkoBounty",
		Rarity = "LEGENDARY ECONOMY",
		Category = "BOUNTY & REROLL ENGINE",
		Title = "CROSS GUILD & YONKO BOUNTY HUNTER",
		Desc = "+40% WAVE & KILL CASH MULTIPLIER\n+$350 INSTANT CASH | +2 REROLL TOKENS",
		BorderColor = Color3.fromRGB(255, 170, 30),
		BgColor = Color3.fromRGB(50, 32, 10),
		BountyMultFlat = 0.40,
		InstantCash = 350,
		BonusRerolls = 2,
	},
	{
		Id = "Card_ObservationHaki",
		Rarity = "EPIC HAKI",
		Category = "SNIPER PRECISION",
		Title = "OBSERVATION HAKI: FUTURE SIGHT",
		Desc = "+8 STUDS GLOBAL RANGE\n-10% ATTACK COOLDOWN | +5% CRIT CHANCE",
		BorderColor = Color3.fromRGB(175, 85, 255),
		BgColor = Color3.fromRGB(38, 20, 58),
		RangeFlat = 8,
		CooldownMult = 0.90,
		CritChanceFlat = 0.05,
	},
	{
		Id = "Card_ArmamentRyou",
		Rarity = "EPIC HAKI",
		Category = "INTERNAL DESTRUCTION",
		Title = "ADVANCED ARMAMENT: INTERNAL RYOU",
		Desc = "+30% GLOBAL DAMAGE (+20 Flat)\n+0.50x CRIT DAMAGE | +2 AOE RADIUS",
		BorderColor = Color3.fromRGB(255, 95, 60),
		BgColor = Color3.fromRGB(52, 22, 18),
		DamagePct = 0.30,
		DamageFlat = 20,
		CritDamageFlat = 0.50,
		SplashFlat = 2,
	},
	{
		Id = "Card_PoneglyphWisdom",
		Rarity = "EPIC UTILITY",
		Category = "FORTRESS & GLOBAL BUFF",
		Title = "ANCIENT PONEGLYPH INSCRIPTION",
		Desc = "HEAL +250 BASE HP (+250 MAX BASE HP)\n+20% GLOBAL DAMAGE | +4 STUDS RANGE",
		BorderColor = Color3.fromRGB(80, 235, 210),
		BgColor = Color3.fromRGB(16, 48, 46),
		BaseHeal = 250,
		DamagePct = 0.20,
		DamageFlat = 15,
		RangeFlat = 4,
	},
	{
		Id = "Card_ShandoraGold",
		Rarity = "EPIC GACHA",
		Category = "TREASURE & REROLLS",
		Title = "CITY OF GOLD SHANDORA TREASURE",
		Desc = "+$600 INSTANT CASH | +4 REROLL TOKENS\n+15% GLOBAL DAMAGE",
		BorderColor = Color3.fromRGB(255, 225, 90),
		BgColor = Color3.fromRGB(48, 42, 14),
		InstantCash = 600,
		BonusRerolls = 4,
		DamagePct = 0.15,
		DamageFlat = 10,
	},
} :: { CardDef }

return GameConfig
