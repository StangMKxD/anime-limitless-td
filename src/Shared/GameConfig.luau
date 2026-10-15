-- src/Shared/GameConfig.luau
-- สัญญาข้อมูลกลาง (Data Contract) สำหรับ One Piece Limitless TD (Wave Card Edition - Phase 2)
local GameConfig = {}

-- ชื่อ Attribute บน Workspace
GameConfig.WORKSPACE_ATTRS = {
	CURRENT_WAVE = "CurrentWave",
	BASE_HP = "BaseHP",
	MAX_BASE_HP = "MaxBaseHP",
	ZOMBIES_REMAINING = "ZombiesRemaining",
	GAME_OVER = "GameOver",
}

-- ชื่อ Attribute บนตัว Player (อัปเกรดผ่านการ์ดทุกเวฟได้ไร้ขีดจำกัด)
GameConfig.PLAYER_ATTRS = {
	DAMAGE_STAT = "DamageStat",
	RANGE_STAT = "RangeStat",
	COOLDOWN_STAT = "CooldownStat",
	SPLASH_STAT = "SplashRadiusStat",
	CRIT_CHANCE = "CritChanceStat",
	DAMAGE_LEVEL = "DamageLevel",
	RANGE_LEVEL = "RangeLevel",
	SPEED_LEVEL = "SpeedLevel",
	PENDING_CARD_DRAWS = "PendingCardDraws", -- จำนวนสิทธิ์เปิดการ์ดที่รอให้ผู้เล่นเลือก!
	CARDS_PICKED_TOTAL = "CardsPickedTotal",
}

-- ค่าเริ่มต้นของผู้เล่น
GameConfig.INITIAL_PLAYER_STATS = {
	CASH = 300, -- ค่าหัว (Bounty Belly) สำหรับรีโรลการ์ดหรือซื้อการ์ดพิเศษ
	DAMAGE_STAT = 45,
	RANGE_STAT = 36,
	COOLDOWN_STAT = 0.95,
	SPLASH_STAT = 6,
	CRIT_CHANCE = 15, -- โอกาสติดคริติคอลฮาคิราชันย์ (%)
	MIN_COOLDOWN = 0.12,
	INITIAL_CARD_DRAWS = 1, -- เข้าเกมมาเวฟ 1 ได้เปิดการ์ดฟรีทันที 1 ใบ!
}

-- ค่าเริ่มต้นของฐานและสูตรคูณเวฟซอมบี้ไร้ขีดจำกัด
GameConfig.WAVE_SETTINGS = {
	INITIAL_BASE_HP = 1500,
	BASE_ZOMBIE_HP = 110,
	HP_GROWTH_RATE = 1.30, -- เลือดซอมบี้คูณ 1.30 เท่าทุกเวฟ
	BASE_ZOMBIE_SPEED = 10.5,
	SPEED_INCREMENT_PER_WAVE = 0.25,
	MAX_ZOMBIE_SPEED = 26,
	BASE_CASH_REWARD = 35,
	SPAWN_INTERVAL = 0.85,
	INTERMISSION_TIME = 5,
	EXTRA_CARD_BASE_COST = 150, -- ราคาใช้เงิน Bounty ซื้อสิทธิ์เปิดการ์ดเพิ่ม
}

-- ชื่อโฟลเดอร์และ RemoteEvent มาตรฐาน
GameConfig.FOLDERS = {
	WAYPOINTS = "Waypoints",
	ENEMIES = "ActiveEnemies",
	TOWERS = "AnimeTowers",
}

GameConfig.REMOTES = {
	UPGRADE_REQUEST = "UpgradeStatRequest", -- รับรหัสการ์ดที่ผู้เล่นคลิกเลือก หรือคำสั่งซื้อการ์ดเพิ่ม
}

return GameConfig
