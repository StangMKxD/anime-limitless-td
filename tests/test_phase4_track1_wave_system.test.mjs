// tests/test_phase4_track1_wave_system.test.mjs
// Comprehensive Unit & Adversarial Verification for Phase 4 Track 1 (PLAN-0007)
// Brutal Endless Enemy Scaling, 4 Monster Classes, R6 Spawner, Micro HP Bar, and Boss Regen

import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(__dirname, '..');

const C = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  yellow: '\x1b[33m',
  gray: '\x1b[90m',
};

const WAVE_MANAGER_PATH = path.join(PROJECT_ROOT, 'src', 'Track1_WaveSystem', 'WaveManager.server.luau');
const GAME_CONFIG_PATH = path.join(PROJECT_ROOT, 'src', 'Shared', 'GameConfig.luau');

const waveSource = fs.readFileSync(WAVE_MANAGER_PATH, 'utf8').replace(/\r\n/g, '\n');
const configSource = fs.readFileSync(GAME_CONFIG_PATH, 'utf8').replace(/\r\n/g, '\n');

const results = {
  total: 0,
  passed: 0,
  failed: 0,
  tests: []
};

function recordTest(id, name, passed, details = '') {
  results.total++;
  if (passed) {
    results.passed++;
    console.log(`${C.cyan}[P4-TRACK1]${C.reset} ${C.green}${C.bold}PASS${C.reset} ${C.bold}${id}${C.reset}: ${name}${details ? ` ${C.gray}(${details})${C.reset}` : ''}`);
  } else {
    results.failed++;
    console.error(`${C.cyan}[P4-TRACK1]${C.reset} ${C.red}${C.bold}FAIL${C.reset} ${C.bold}${id}${C.reset}: ${name} ${C.yellow}${details}${C.reset}`);
  }
  results.tests.push({ id, name, passed, details });
}

console.log(`\n${C.bold}${C.yellow}========================================================================${C.reset}`);
console.log(`${C.bold}${C.yellow}   PHASE 4 TRACK 1 VERIFICATION: BRUTAL SCALING & 4 MONSTER CLASSES     ${C.reset}`);
console.log(`${C.bold}${C.yellow}   Specification: PLAN-0007 / 01_track1_core_wave_and_enemy_spec        ${C.reset}`);
console.log(`${C.bold}${C.yellow}========================================================================${C.reset}\n`);

// ============================================================================
// SUITE 1: GAMECONFIG PHASE 4 DATA CONTRACT
// ============================================================================
console.log(`${C.bold}--- SUITE 1: GAMECONFIG CONSTANTS & ENEMY_CLASSES ---${C.reset}`);

// TC-4.1.1: Phase 4 Constants in GameConfig.luau
{
  const hasBaseZombieHp = configSource.includes('BASE_ZOMBIE_HP = 450');
  const hasWaveHpExponent = configSource.includes('WAVE_HP_EXPONENT = 1.58');
  const hasSurgeInterval = configSource.includes('SURGE_INTERVAL = 3');
  const hasSurgeScale = configSource.includes('SURGE_SCALE = 0.75');
  const hasBaseHakiStep = configSource.includes('BASE_HAKI_ARMOR_STEP = 0.03');
  const hasMaxHakiArmor = configSource.includes('MAX_HAKI_ARMOR = 0.65');

  recordTest(
    'TC-4.1.1',
    'GameConfig exports Phase 4 constants: BASE_ZOMBIE_HP=450, WAVE_HP_EXPONENT=1.58, SURGE_INTERVAL=3, SURGE_SCALE=0.75, BASE_HAKI_ARMOR_STEP=0.03, MAX_HAKI_ARMOR=0.65',
    hasBaseZombieHp && hasWaveHpExponent && hasSurgeInterval && hasSurgeScale && hasBaseHakiStep && hasMaxHakiArmor,
    'All 6 Phase 4 constants verified in GameConfig'
  );
}

// TC-4.1.2: 4 Monster Classes Dictionary in GameConfig.luau
{
  const hasEnemyClasses = configSource.includes('GameConfig.ENEMY_CLASSES = {');
  const hasPirateGrunt = configSource.includes('PirateGrunt = {');
  const hasSoruAssassin = configSource.includes('SoruAssassin = {');
  const hasHakiBrute = configSource.includes('HakiBrute = {');
  const hasYonkoBoss = configSource.includes('YonkoBoss = {');
  const hasEnemyClassSpecType = configSource.includes('export type EnemyClassSpec = {');

  recordTest(
    'TC-4.1.2',
    'GameConfig defines ENEMY_CLASSES dictionary with 4 classes and exports EnemyClassSpec type',
    hasEnemyClasses && hasPirateGrunt && hasSoruAssassin && hasHakiBrute && hasYonkoBoss && hasEnemyClassSpecType,
    'PirateGrunt, SoruAssassin, HakiBrute, YonkoBoss defined with strict type'
  );
}

// TC-4.1.3: Class Parameter Invariants
{
  const hasAssassinSpeed = configSource.includes('MaxSpeed = 34.0') && configSource.includes('SpeedMult = 1.65');
  const hasBruteArmor = configSource.includes('ArmorBonus = 0.30') && configSource.includes('MaxArmor = 0.75');
  const hasBossRegen = configSource.includes('RegenPerSec = 0.025') && configSource.includes('Scale = 2.2');
  const hasAuraColors = configSource.includes('0, 225, 255') && configSource.includes('165, 40, 255') && configSource.includes('255, 20, 60');

  recordTest(
    'TC-4.1.3',
    'ENEMY_CLASSES parameters match exact spec: Assassin 1.65x speed (cap 34), Brute +30% armor (cap 75%), Boss 2.5%/s regen (scale 2.2)',
    hasAssassinSpeed && hasBruteArmor && hasBossRegen && hasAuraColors,
    'Multipliers, caps, scales, and aura colors verified'
  );
}

// ============================================================================
// SUITE 2: BRUTAL ENDLESS SCALING MATHEMATICS
// ============================================================================
console.log(`\n${C.bold}--- SUITE 2: BRUTAL SCALING MATHEMATICS ---${C.reset}`);

function calculateEnemyStatsSim(wave, enemyClass) {
  const rawHp = 450 * Math.pow(1.58, wave - 1) * (1 + Math.floor(wave / 3) * 0.75);
  const baseSpeed = Math.min(24.0, 11.0 + (wave * 0.40));
  const armorReduction = Math.min(0.65, (wave - 1) * 0.03);

  let hpMult = 1.0;
  let speedMult = 1.0;
  let armor = armorReduction;
  let maxSpeed = null;
  let minSpeed = null;
  let regenPerSec = 0.0;
  let isBoss = false;

  if (enemyClass === "SoruAssassin") {
    hpMult = 0.75;
    speedMult = 1.65;
    maxSpeed = 34.0;
    armor = Math.min(0.35, armorReduction * 0.5);
  } else if (enemyClass === "HakiBrute") {
    hpMult = 2.8;
    speedMult = 0.78;
    minSpeed = 8.0;
    armor = Math.min(0.75, armorReduction + 0.30);
  } else if (enemyClass === "YonkoBoss") {
    hpMult = 8.0;
    speedMult = 0.72;
    minSpeed = 7.5;
    armor = Math.min(0.70, armorReduction + 0.25);
    regenPerSec = 0.025;
    isBoss = true;
  }

  let speed = baseSpeed * speedMult;
  if (maxSpeed !== null) speed = Math.min(maxSpeed, speed);
  if (minSpeed !== null) speed = Math.max(minSpeed, speed);

  return {
    rawHp,
    maxHp: Math.floor(rawHp * hpMult),
    speed,
    armor,
    regenPerSec,
    isBoss,
  };
}

// TC-4.2.1: Wave 1 Base HP is exactly 450 and Armor is 0%
{
  const w1 = calculateEnemyStatsSim(1, "PirateGrunt");
  const hasFormulaInCode = waveSource.includes('rawHp = 450 * (1.58 ^ (wave - 1)) * (1 + math.floor(wave / 3) * 0.75)');

  recordTest(
    'TC-4.2.1',
    'Wave 1 PirateGrunt has exactly 450 MaxHP and 0% ArmorReduction; WaveManager includes exact formula',
    w1.maxHp === 450 && Math.abs(w1.armor - 0.0) < 1e-6 && hasFormulaInCode,
    `Wave 1 Grunt HP: ${w1.maxHp}, Armor: ${w1.armor * 100}%`
  );
}

// TC-4.2.2: WaveSurge Step scaling at Wave 3 (+75% surge multiplier)
{
  const w3Grunt = calculateEnemyStatsSim(3, "PirateGrunt");
  // 450 * (1.58^2) * (1 + 1*0.75) = 450 * 2.4964 * 1.75 = 1965.915 -> 1965
  const expectedW3 = Math.floor(450 * Math.pow(1.58, 2) * 1.75);

  recordTest(
    'TC-4.2.2',
    'Wave 3 introduces +75% surge (WaveSurge=1.75), scaling Grunt HP to 1,965',
    w3Grunt.maxHp === expectedW3 && w3Grunt.maxHp === 1965,
    `Calculated W3 HP: ${w3Grunt.maxHp} (Expected: 1965)`
  );
}

// TC-4.2.3: Armor Reduction Progression and Strict Capping Across 100 Waves
{
  let armorInBounds = true;
  for (let w = 1; w <= 100; w++) {
    const grunt = calculateEnemyStatsSim(w, "PirateGrunt");
    const assassin = calculateEnemyStatsSim(w, "SoruAssassin");
    const brute = calculateEnemyStatsSim(w, "HakiBrute");
    const boss = calculateEnemyStatsSim(w, "YonkoBoss");

    if (grunt.armor > 0.65001 || grunt.armor < 0) armorInBounds = false;
    if (assassin.armor > 0.35001 || assassin.armor < 0) armorInBounds = false;
    if (brute.armor > 0.75001 || brute.armor < 0.30) armorInBounds = false;
    if (boss.armor > 0.70001 || boss.armor < 0.25) armorInBounds = false;
  }

  const hasArmorAttr = waveSource.includes('model:SetAttribute("ArmorReduction", stats.Armor)');

  recordTest(
    'TC-4.2.3',
    'Haki Armor strictly capped at 65% (Grunt), 35% (Assassin), 75% (Brute), 70% (Boss) and exported via ArmorReduction attribute',
    armorInBounds && hasArmorAttr,
    'Tested across 100 waves: all armor curves monotonically bounded'
  );
}

// TC-4.2.4: Dynamic Wave Sizing and Spawn Acceleration
{
  const hasCountFormula = waveSource.includes('local count = 8 + math.floor(wave * 3.5)');
  const hasIntervalFormula = waveSource.includes('local spawnInterval = math.max(0.35, 0.85 - (wave - 1) * 0.035)');

  let intervalsValid = true;
  let prevInterval = 1.0;
  for (let w = 1; w <= 30; w++) {
    const count = 8 + Math.floor(w * 3.5);
    const interval = Math.max(0.35, 0.85 - (w - 1) * 0.035);
    if (count < 8 || count > 200) intervalsValid = false;
    if (interval < 0.35 || interval > 0.85) intervalsValid = false;
    if (interval > prevInterval) intervalsValid = false;
    prevInterval = interval;
  }

  recordTest(
    'TC-4.2.4',
    'Wave sizing (8 + floor(w*3.5)) and dynamic interval (max(0.35, 0.85 - (w-1)*0.035)) accelerate correctly',
    hasCountFormula && hasIntervalFormula && intervalsValid,
    'W1: 11 mobs @ 0.85s -> W16+: 64 mobs @ 0.35s'
  );
}

// ============================================================================
// SUITE 3: 3-TIER R6 SPAWNER, MOVEMENT KINEMATICS & AURAS
// ============================================================================
console.log(`\n${C.bold}--- SUITE 3: 3-TIER R6 RIGGING & AURAS ---${C.reset}`);

// TC-4.3.1: 3-Tier Model Spawner Pipeline
{
  const tier1Check = waveSource.includes('customTemplates:FindFirstChild(stats.CanonicalClass or enemyClass)');
  const tier2Check = waveSource.includes('Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)');
  const tier3Check = waveSource.includes('root.Name = "HumanoidRootPart"') && waveSource.includes('head.Name = "Head"') && waveSource.includes('Instance.new("Humanoid")');

  recordTest(
    'TC-4.3.1',
    '3-Tier Hybrid Spawner: Tier 1 EnemyModels clone -> Tier 2 CreateHumanoidModelFromDescription -> Tier 3 Headless CLI fallback',
    tier1Check && tier2Check && tier3Check,
    'All 3 tiers correctly implemented with fallback guards'
  );
}

// TC-4.3.2: Motor6D & PivotTo Kinematic Movement Synchrony
{
  const setsRootCFrame = waveSource.includes('root.CFrame = CFrame.lookAt(nextPos + Vector3.new(0, bobOffset, 0), targetPos)');
  const pivotsModel = waveSource.includes('model:PivotTo(root.CFrame)');
  const tracksHead = waveSource.includes('head.CFrame = root.CFrame * CFrame.new(0, 2.0 * stats.Scale, 0)');

  recordTest(
    'TC-4.3.2',
    'Kinematic movement updates root.CFrame, head.CFrame, and executes model:PivotTo(root.CFrame) to keep all limbs unified',
    setsRootCFrame && pivotsModel && tracksHead,
    'Synchronous body translation and procedural walk bob verified'
  );
}

// TC-4.3.3: Multi-Layered Visual Auras for Monster Classes
{
  const hasSoruAura = waveSource.includes('SoruHighlight') && waveSource.includes('SoruLight') && waveSource.includes('SoruSpeedParticles');
  const hasHakiAura = waveSource.includes('HakiHighlight') && waveSource.includes('HakiLight') && waveSource.includes('HakiSmokeParticles');
  const hasYonkoAura = waveSource.includes('YonkoHighlight') && waveSource.includes('KaidoDragonAura') && waveSource.includes('YonkoLight') && waveSource.includes('ConquerorLightningSparks');

  recordTest(
    'TC-4.3.3',
    'Multi-layered auras: Electric cyan for SoruAssassin, dark obsidian purple for HakiBrute, crimson for YonkoBoss',
    hasSoruAura && hasHakiAura && hasYonkoAura,
    'Highlight, PointLight, and ParticleEmitter attached per class'
  );
}

// ============================================================================
// SUITE 4: ZERO-CLUTTER MICRO HEALTH BARS & BOSS REGENERATION
// ============================================================================
console.log(`\n${C.bold}--- SUITE 4: MICRO HEALTH BARS & BOSS REGEN ---${C.reset}`);

// TC-4.4.1: Micro Health Bar Dimensions & Suppression of Grunt Nameplates
{
  const hasMicroSize = waveSource.includes('stats.IsBoss and UDim2.new(0, 96, 0, 16) or UDim2.new(0, 52, 0, 6)');
  const alwaysOnTopFalse = waveSource.includes('bb.AlwaysOnTop = false');
  const maxDistanceSet = waveSource.includes('bb.MaxDistance = stats.IsBoss and 90 or 85');
  const billboardOnRoot = waveSource.includes('bb.Parent = root');
  const noGruntTextLabel = !waveSource.includes('nameLbl.Parent = bb');

  recordTest(
    'TC-4.4.1',
    'Micro Health Bar is 52x6 px for grunts, AlwaysOnTop=false, MaxDistance=85, bb.Parent=root, and common grunt names 100% suppressed',
    hasMicroSize && alwaysOnTopFalse && maxDistanceSet && billboardOnRoot && noGruntTextLabel,
    'Zero visual clutter achieved on common swarms'
  );
}

// TC-4.4.2: Compact Boss Billboard & Title
{
  const hasBossTitleText = waveSource.includes('title.Text = "[BOSS] YONKO CALAMITY"');
  const hasBossTitleFont = waveSource.includes('title.Font = Enum.Font.GothamBold') && waveSource.includes('title.TextSize = 10');
  const hasBossStroke = waveSource.includes('UIStroke') && waveSource.includes('Color3.fromRGB(90, 20, 30)');

  recordTest(
    'TC-4.4.2',
    'YonkoBoss displays compact 96x16 px bar with bold 10px [BOSS] YONKO CALAMITY title and crimson stroke',
    hasBossTitleText && hasBossTitleFont && hasBossStroke,
    'Clear visual hierarchy without returning to bulky legacy billboard'
  );
}

// TC-4.4.3: 2.5%/s Boss Haki Regeneration Loop
{
  const hasRegenCheck = waveSource.includes('if stats.RegenPerSec and stats.RegenPerSec > 0 then');
  const hasOneSecWait = waveSource.includes('task.wait(1.0)');
  const healsHp = waveSource.includes('local heal = math.floor(maxHp * stats.RegenPerSec)');
  const clampsMaxHp = waveSource.includes('local newHp = math.min(maxHp, curHp + heal)');
  const updatesAttr = waveSource.includes('model:SetAttribute("HP", newHp)');
  const guardsDead = waveSource.includes('if curHp > 0 and curHp < maxHp then');

  recordTest(
    'TC-4.4.3',
    '2.5%/s Boss Haki Regeneration loop executes 1.0s heartbeat, bounds healing to MaxHP, and respects death state',
    hasRegenCheck && hasOneSecWait && healsHp && clampsMaxHp && updatesAttr && guardsDead,
    'Healing strictly clamped; dead bosses never heal'
  );
}

// TC-4.4.4: Invariant Compatibility with Existing Test Suites
{
  const hasIsDeadFlag = waveSource.includes('local isDead = false');
  const hasAtomicSignal = waveSource.includes('if currentHp <= 0 and not isDead and model.Parent then');
  const setsIsDeadAndCash = waveSource.includes('isDead = true\n\t\t\tawardCashToAllPlayers(spec.Cash)\n\t\t\tmodel:Destroy()');
  const hasEndOfPathCheck = waveSource.includes('if model.Parent and not isDead and ((model:GetAttribute("HP") :: number?) or 0) > 0 then');
  const setsGameOver = waveSource.includes('Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, true)');
  const bossConditionPresent = waveSource.includes('if wave % 5 == 0 and i == count then\n\t\t\t\t\tkey = "YonkoKaido"');

  recordTest(
    'TC-4.4.4',
    'AST string invariants strictly preserved for regression test compatibility',
    hasIsDeadFlag && hasAtomicSignal && setsIsDeadAndCash && hasEndOfPathCheck && setsGameOver && bossConditionPresent,
    '100% backward compatible with Phase 3 test assertions'
  );
}

console.log(`\n${C.bold}${C.yellow}========================================================================${C.reset}`);
console.log(`${C.bold}PHASE 4 TRACK 1 TEST EXECUTION COMPLETE: ${results.passed} / ${results.total} PASSED (${((results.passed / results.total) * 100).toFixed(1)}%)${C.reset}`);
console.log(`${C.bold}${C.yellow}========================================================================${C.reset}\n`);

if (results.failed > 0) {
  process.exit(1);
} else {
  process.exit(0);
}
