-- src/Shared/GameConfig.luau
-- ไฟล์สัญญากลาง (Data Contract) สำหรับโปรเจกต์ Anime Limitless Tower Defense
local GameConfig = {}

-- ชื่อ Attribute บน Workspace
GameConfig.WORKSPACE_ATTRS = {
	CURRENT_WAVE = "CurrentWave",
	BASE_HP = "BaseHP",
	MAX_BASE_HP = "MaxBaseHP",
	ZOMBIES_REMAINING = "ZombiesRemaining",
	GAME_OVER = "GameOver",
}

-- ชื่อ Attribute บนตัว Player (สำหรับอัปเกรดสเตตัสไร้ขีดจำกัด)
GameConfig.PLAYER_ATTRS = {
	DAMAGE_STAT = "DamageStat",
	RANGE_STAT = "RangeStat",
	COOLDOWN_STAT = "CooldownStat",
	DAMAGE_LEVEL = "DamageLevel",
	RANGE_LEVEL = "RangeLevel",
	SPEED_LEVEL = "SpeedLevel",
}

-- ค่าเริ่มต้นของผู้เล่น
GameConfig.INITIAL_PLAYER_STATS = {
	CASH = 300,
	DAMAGE_STAT = 35,
	RANGE_STAT = 32,
	COOLDOWN_STAT = 1.0,
	MIN_COOLDOWN = 0.12,
}

-- ค่าเริ่มต้นของฐานและสูตรคูณเวฟซอมบี้ไร้ขีดจำกัด
GameConfig.WAVE_SETTINGS = {
	INITIAL_BASE_HP = 1000,
	BASE_ZOMBIE_HP = 100,
	HP_GROWTH_RATE = 1.28, -- เลือดซอมบี้คูณ 1.28 เท่าทุกเวฟ
	BASE_ZOMBIE_SPEED = 10,
	SPEED_INCREMENT_PER_WAVE = 0.25,
	MAX_ZOMBIE_SPEED = 26,
	BASE_CASH_REWARD = 25,
	SPAWN_INTERVAL = 0.9,
	INTERMISSION_TIME = 4,
}

-- ชื่อโฟลเดอร์และ RemoteEvent มาตรฐาน
GameConfig.FOLDERS = {
	WAYPOINTS = "Waypoints",
	ENEMIES = "ActiveEnemies",
	TOWERS = "AnimeTowers",
}

GameConfig.REMOTES = {
	UPGRADE_REQUEST = "UpgradeStatRequest",
}

return GameConfig
