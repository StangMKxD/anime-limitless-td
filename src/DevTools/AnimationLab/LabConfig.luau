--!strict
-- src/DevTools/AnimationLab/LabConfig.luau
-- Authoritative configuration for Animation Lab: Asset Catalog, Stage Constants, and Performance Budgets.

local LabConfig = {}

LabConfig.VERSION = "5.0.0"

-- =============================================================================
-- STAGE & ENVIRONMENT CONSTANTS
-- =============================================================================

LabConfig.STAGE_Y = 5000
LabConfig.STAGE_POSITION = Vector3.new(0, LabConfig.STAGE_Y, 0)
LabConfig.STAGE_SIZE = Vector3.new(60, 2, 60)
LabConfig.DUMMY_DEFAULT_OFFSET = Vector3.new(0, 0, 15)
LabConfig.SANDBOX_FOLDER_NAME = "__AnimationLabSandbox"

-- =============================================================================
-- 19-ASSET INVENTORY CATALOG (Authoritative Audit Mapping)
-- =============================================================================

export type AssetCategory = "HeroModels" | "EnemyModels" | "MapModels"

export type AssetCatalogEntry = {
	id: string,
	displayName: string,
	category: AssetCategory,
	assetPath: string,
	expectedBaseParts: number,
	isStaticMapAsset: boolean,
	hasSignatureAnim: boolean,
	hasSignatureVFX: boolean,
	defaultScale: number,
}

LabConfig.ASSET_CATALOG = table.freeze({
	-- 12 Heroes
	Luffy = {
		id = "Luffy",
		displayName = "Monkey D. Luffy (Gear 5)",
		category = "HeroModels",
		assetPath = "HeroModels.Luffy",
		expectedBaseParts = 122,
		isStaticMapAsset = false,
		hasSignatureAnim = true,
		hasSignatureVFX = true,
		defaultScale = 1.0,
	},
	Zoro = {
		id = "Zoro",
		displayName = "Roronoa Zoro (King of Hell)",
		category = "HeroModels",
		assetPath = "HeroModels.Zoro",
		expectedBaseParts = 139,
		isStaticMapAsset = false,
		hasSignatureAnim = true,
		hasSignatureVFX = true,
		defaultScale = 1.0,
	},
	Ace = {
		id = "Ace",
		displayName = "Portgas D. Ace (Flame Emperor)",
		category = "HeroModels",
		assetPath = "HeroModels.Ace",
		expectedBaseParts = 128,
		isStaticMapAsset = false,
		hasSignatureAnim = true,
		hasSignatureVFX = true,
		defaultScale = 1.0,
	},
	Chopper = {
		id = "Chopper",
		displayName = "Tony Tony Chopper",
		category = "HeroModels",
		assetPath = "HeroModels.Chopper",
		expectedBaseParts = 81,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},
	Kizaru = {
		id = "Kizaru",
		displayName = "Borsalino (Kizaru)",
		category = "HeroModels",
		assetPath = "HeroModels.Kizaru",
		expectedBaseParts = 104,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},
	Law = {
		id = "Law",
		displayName = "Trafalgar D. Water Law",
		category = "HeroModels",
		assetPath = "HeroModels.Law",
		expectedBaseParts = 100,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},
	Nami = {
		id = "Nami",
		displayName = "Nami (Cat Burglar)",
		category = "HeroModels",
		assetPath = "HeroModels.Nami",
		expectedBaseParts = 96,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},
	Robin = {
		id = "Robin",
		displayName = "Nico Robin (Devil Child)",
		category = "HeroModels",
		assetPath = "HeroModels.Robin",
		expectedBaseParts = 103,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},
	Sanji = {
		id = "Sanji",
		displayName = "Vinsmoke Sanji (Ifrit Jambe)",
		category = "HeroModels",
		assetPath = "HeroModels.Sanji",
		expectedBaseParts = 106,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},
	Shanks = {
		id = "Shanks",
		displayName = "Red-Haired Shanks",
		category = "HeroModels",
		assetPath = "HeroModels.Shanks",
		expectedBaseParts = 95,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},
	Usopp = {
		id = "Usopp",
		displayName = "God Usopp (Sogeking)",
		category = "HeroModels",
		assetPath = "HeroModels.Usopp",
		expectedBaseParts = 104,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},
	Whitebeard = {
		id = "Whitebeard",
		displayName = "Edward Newgate (Whitebeard)",
		category = "HeroModels",
		assetPath = "HeroModels.Whitebeard",
		expectedBaseParts = 105,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},

	-- 4 Enemies
	HakiBrute = {
		id = "HakiBrute",
		displayName = "General Zombie (Haki Brute)",
		category = "EnemyModels",
		assetPath = "EnemyModels.HakiBrute",
		expectedBaseParts = 78,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.1,
	},
	PirateGrunt = {
		id = "PirateGrunt",
		displayName = "Thriller Bark Pirate Grunt",
		category = "EnemyModels",
		assetPath = "EnemyModels.PirateGrunt",
		expectedBaseParts = 71,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},
	SoruAssassin = {
		id = "SoruAssassin",
		displayName = "Command General (Soru Assassin)",
		category = "EnemyModels",
		assetPath = "EnemyModels.SoruAssassin",
		expectedBaseParts = 64,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 0.95,
	},
	YonkoBoss = {
		id = "YonkoBoss",
		displayName = "Yonko Kaido (Dragon Emperor Boss)",
		category = "EnemyModels",
		assetPath = "EnemyModels.YonkoBoss",
		expectedBaseParts = 124,
		isStaticMapAsset = false,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.35,
	},

	-- 3 Map Assets
	AnimeBaseCrystal = {
		id = "AnimeBaseCrystal",
		displayName = "Anime Defense Base Crystal",
		category = "MapModels",
		assetPath = "MapModels.AnimeBaseCrystal",
		expectedBaseParts = 41,
		isStaticMapAsset = true,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},
	EnemySpawnGate = {
		id = "EnemySpawnGate",
		displayName = "Torii Void Enemy Spawn Gate",
		category = "MapModels",
		assetPath = "MapModels.EnemySpawnGate",
		expectedBaseParts = 25,
		isStaticMapAsset = true,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},
	PlacementPadTemplate = {
		id = "PlacementPadTemplate",
		displayName = "Tactical Placement Pad Template",
		category = "MapModels",
		assetPath = "MapModels.PlacementPadTemplate",
		expectedBaseParts = 10,
		isStaticMapAsset = true,
		hasSignatureAnim = false,
		hasSignatureVFX = false,
		defaultScale = 1.0,
	},
})

-- =============================================================================
-- PERFORMANCE BENCHMARK BUDGETS (Empirical Calibration)
-- =============================================================================

LabConfig.STRESS_BUDGETS = table.freeze({
	Single = {
		characterCount = 1,
		maxActiveParts = 160,
		maxActiveVFXInstances = 30,
		targetFrameTimeMs = 16.67, -- 60 FPS
		requiredLeakCount = 0,
	},
	Chars10 = {
		characterCount = 10,
		maxActiveParts = 1600,
		maxActiveVFXInstances = 200,
		targetFrameTimeMs = 16.67,
		requiredLeakCount = 0,
	},
	Chars25 = {
		characterCount = 25,
		maxActiveParts = 3800,
		maxActiveVFXInstances = 400,
		targetFrameTimeMs = 20.0, -- >= 50 FPS
		requiredLeakCount = 0,
	},
	Chars50 = {
		characterCount = 50,
		maxActiveParts = 7500,
		maxActiveVFXInstances = 600,
		targetFrameTimeMs = 25.0, -- >= 40 FPS
		requiredLeakCount = 0,
	},
})

return table.freeze(LabConfig)
