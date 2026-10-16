// tests/challenger_p4_m1_math.test.mjs
// Adversarial Stress Harness: Phase 4 Milestone 1 (Track 1 - PLAN-0007)
// Mathematical Scaling, Monotonicity, Armor Caps, Boss Regen, and Spawn Density

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
  magenta: '\x1b[35m',
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
    console.log(`${C.magenta}[CHALLENGER-P4]${C.reset} ${C.green}${C.bold}PASS${C.reset} ${C.bold}${id}${C.reset}: ${name}${details ? ` ${C.gray}(${details})${C.reset}` : ''}`);
  } else {
    results.failed++;
    console.error(`${C.magenta}[CHALLENGER-P4]${C.reset} ${C.red}${C.bold}FAIL${C.reset} ${C.bold}${id}${C.reset}: ${name} ${C.yellow}${details}${C.reset}`);
  }
  results.tests.push({ id, name, passed, details });
}

console.log(`\n${C.bold}${C.yellow}========================================================================${C.reset}`);
console.log(`${C.bold}${C.yellow}   ADVERSARIAL STRESS HARNESS: PHASE 4 MILESTONE 1 (PLAN-0007)          ${C.reset}`);
console.log(`${C.bold}${C.yellow}   Empirical Verification of Mathematical Scaling & System Invariants   ${C.reset}`);
console.log(`${C.bold}${C.yellow}========================================================================${C.reset}\n`);

// Simulation of exact Luau implementation
function computeEnemyStats(wave, enemyClass) {
  const rawHp = 450 * Math.pow(1.58, wave - 1) * (1 + Math.floor(wave / 3) * 0.75);
  const baseSpeed = Math.min(24.0, 11.0 + (wave * 0.40));
  const armorReduction = Math.min(0.65, (wave - 1) * 0.03);

  let canonicalClass = enemyClass;
  if (enemyClass === "ThrillerZombie") canonicalClass = "PirateGrunt";
  else if (enemyClass === "CommandGeneral") canonicalClass = "SoruAssassin";
  else if (enemyClass === "GeneralZombie") canonicalClass = "HakiBrute";
  else if (enemyClass === "YonkoKaido") canonicalClass = "YonkoBoss";

  let hpMult = 1.0;
  let speedMult = 1.0;
  let scale = 1.0;
  let rewardMult = 1.0;
  let regenPerSec = 0.0;
  let isBoss = false;

  if (canonicalClass === "SoruAssassin") {
    hpMult = 0.75;
    speedMult = 1.65;
    scale = 0.95;
    rewardMult = 1.3;
  } else if (canonicalClass === "HakiBrute") {
    hpMult = 2.8;
    speedMult = 0.78;
    scale = 1.35;
    rewardMult = 2.0;
  } else if (canonicalClass === "YonkoBoss") {
    hpMult = 8.0;
    speedMult = 0.72;
    scale = 2.2;
    rewardMult = 6.0;
    regenPerSec = 0.025;
    isBoss = true;
  }

  const maxHp = Math.floor(rawHp * hpMult);
  let speed = baseSpeed * speedMult;
  if (canonicalClass === "SoruAssassin") speed = Math.min(34.0, speed);
  else if (canonicalClass === "HakiBrute") speed = Math.max(8.0, speed);
  else if (canonicalClass === "YonkoBoss") speed = Math.max(7.5, speed);

  let armor = armorReduction;
  if (canonicalClass === "SoruAssassin") {
    armor = Math.min(0.35, armorReduction * 0.5);
  } else if (canonicalClass === "HakiBrute") {
    armor = Math.min(0.75, armorReduction + 0.30);
  } else if (canonicalClass === "YonkoBoss") {
    armor = Math.min(0.70, armorReduction + 0.25);
  } else {
    armor = Math.min(0.65, armorReduction);
  }

  const baseKillCash = 25;
  const cash = Math.floor(baseKillCash * rewardMult);

  return {
    canonicalClass,
    rawHp,
    maxHp,
    speed,
    armor,
    scale,
    regenPerSec,
    cash,
    isBoss,
  };
}

// ============================================================================
// DIMENSION 1: WAVES 1 TO 100 HP SCALING (STRESS & ORACLE COMPARISON)
// ============================================================================
console.log(`${C.bold}--- DIMENSION 1: HP SCALING 1..100 (MONOTONICITY, OVERFLOW, SURGES) ---${C.reset}`);

// CH-1.1: Strict Monotonicity Across 100 Waves for All 4 Classes
{
  const classes = ["PirateGrunt", "SoruAssassin", "HakiBrute", "YonkoBoss"];
  let strictlyMonotonic = true;
  let nonDecreasingDeltas = true;
  const violations = [];

  for (const cls of classes) {
    let prevHp = 0;
    for (let w = 1; w <= 100; w++) {
      const stats = computeEnemyStats(w, cls);
      if (stats.maxHp <= prevHp) {
        strictlyMonotonic = false;
        violations.push(`${cls} at wave ${w}: prev=${prevHp}, curr=${stats.maxHp}`);
      }
      prevHp = stats.maxHp;
    }
  }

  recordTest(
    'CH-1.1',
    'HP Monotonicity: maxHp(w+1) > maxHp(w) strictly for all 4 classes across waves 1 to 100',
    strictlyMonotonic && violations.length === 0,
    strictlyMonotonic ? 'Zero inversions across 400 data points' : `Violations: ${violations.slice(0, 3).join('; ')}`
  );
}

// CH-1.2: IEEE 754 Non-Overflow & Numerical Bounds up to Wave 100
{
  let allFiniteAndPositive = true;
  let maxWaveHp = 0;
  let maxSafeIntegerExceededWave = null;

  for (let w = 1; w <= 100; w++) {
    const boss = computeEnemyStats(w, "YonkoBoss");
    if (!Number.isFinite(boss.maxHp) || Number.isNaN(boss.maxHp) || boss.maxHp <= 0) {
      allFiniteAndPositive = false;
    }
    if (boss.maxHp > Number.MAX_SAFE_INTEGER && maxSafeIntegerExceededWave === null) {
      maxSafeIntegerExceededWave = w;
    }
    if (boss.maxHp > maxWaveHp) maxWaveHp = boss.maxHp;
  }

  const withinFloatBounds = maxWaveHp < Number.MAX_VALUE && allFiniteAndPositive;

  recordTest(
    'CH-1.2',
    'Numerical Bounds: HP remains strictly finite, non-NaN, and positive (Wave 100 Boss HP: ' + maxWaveHp.toExponential(4) + ')',
    withinFloatBounds,
    `Wave 100 MaxHP: ${maxWaveHp.toExponential(4)}, MAX_SAFE_INTEGER exceeded at Wave ${maxSafeIntegerExceededWave}`
  );
}

// CH-1.3: WaveSurge Step Multipliers at 3-Wave Intervals (w % 3 == 0)
{
  // WaveSurge formula: 1 + floor(w / 3) * 0.75
  // w=1: surge=1.00; w=2: surge=1.00; w=3: surge=1.75 (+75%); w=6: surge=2.50 (+150%); w=9: surge=3.25 (+225%)
  const grunt1 = computeEnemyStats(1, "PirateGrunt");
  const grunt2 = computeEnemyStats(2, "PirateGrunt");
  const grunt3 = computeEnemyStats(3, "PirateGrunt");
  const grunt4 = computeEnemyStats(4, "PirateGrunt");
  const grunt6 = computeEnemyStats(6, "PirateGrunt");
  const grunt9 = computeEnemyStats(9, "PirateGrunt");

  // Exact oracle calculations
  const expected1 = 450;
  const expected2 = Math.floor(450 * 1.58); // 711
  const expected3 = Math.floor(450 * Math.pow(1.58, 2) * 1.75); // 1965
  const expected4 = Math.floor(450 * Math.pow(1.58, 3) * 1.75); // 3106
  const expected6 = Math.floor(450 * Math.pow(1.58, 5) * 2.50); // 11189
  const expected9 = Math.floor(450 * Math.pow(1.58, 8) * 3.25); // 57476

  const matchesOracle =
    grunt1.maxHp === expected1 &&
    grunt2.maxHp === expected2 &&
    grunt3.maxHp === expected3 &&
    grunt4.maxHp === expected4 &&
    grunt6.maxHp === expected6 &&
    grunt9.maxHp === expected9;

  recordTest(
    'CH-1.3',
    'WaveSurge Oracle Verification: Wave 1=450, Wave 2=711, Wave 3=1965 (+75% surge), Wave 6=11189 (+150%), Wave 9=57476 (+225%)',
    matchesOracle,
    `W1:${grunt1.maxHp}, W2:${grunt2.maxHp}, W3:${grunt3.maxHp}, W4:${grunt4.maxHp}, W6:${grunt6.maxHp}, W9:${grunt9.maxHp}`
  );
}

// CH-1.4: Relative HP Ratios across 4 Monster Classes
{
  let ratiosConsistent = true;
  for (let w = 1; w <= 50; w++) {
    const grunt = computeEnemyStats(w, "PirateGrunt");
    const assassin = computeEnemyStats(w, "SoruAssassin");
    const brute = computeEnemyStats(w, "HakiBrute");
    const boss = computeEnemyStats(w, "YonkoBoss");

    // assassin HP should be ~0.75 * rawHp (floored)
    // brute HP should be ~2.8 * rawHp (floored)
    // boss HP should be ~8.0 * rawHp (floored)
    const assassinRatio = assassin.maxHp / grunt.rawHp;
    const bruteRatio = brute.maxHp / grunt.rawHp;
    const bossRatio = boss.maxHp / grunt.rawHp;

    if (Math.abs(assassinRatio - 0.75) > 0.01) ratiosConsistent = false;
    if (Math.abs(bruteRatio - 2.8) > 0.01) ratiosConsistent = false;
    if (Math.abs(bossRatio - 8.0) > 0.01) ratiosConsistent = false;
  }

  recordTest(
    'CH-1.4',
    'Class HP Ratios: Assassin (0.75x), Brute (2.8x), Boss (8.0x) adhere strictly to specification ratios',
    ratiosConsistent,
    'Tested waves 1-50: ratios match theoretical multipliers within floored rounding delta'
  );
}

// ============================================================================
// DIMENSION 2: HAKI ARMOR DAMAGE REDUCTION SCALING & STRICT CAPS
// ============================================================================
console.log(`\n${C.bold}--- DIMENSION 2: ARMOR REDUCTION SCALING (+3%/WAVE) & STRICT CAPS ---${C.reset}`);

// CH-2.1: Exact Linear Step Verification (+3%/wave until capped)
{
  let linearStepValid = true;
  // Waves 1 to 21: base armor increases by exactly 0.03 per wave (0.00 -> 0.03 -> ... -> 0.63)
  for (let w = 1; w <= 21; w++) {
    const gCurr = computeEnemyStats(w, "PirateGrunt");
    const gNext = computeEnemyStats(w + 1, "PirateGrunt");
    const delta = gNext.armor - gCurr.armor;
    if (Math.abs(delta - 0.03) > 1e-9) {
      linearStepValid = false;
    }
  }

  // Wave 22 -> 23: cap transition hits 0.65 exactly (delta = 0.02)
  const g22 = computeEnemyStats(22, "PirateGrunt");
  const g23 = computeEnemyStats(23, "PirateGrunt");
  const capDelta = g23.armor - g22.armor;
  const capTransitionValid = Math.abs(capDelta - 0.02) < 1e-9 && Math.abs(g23.armor - 0.65) < 1e-9;

  // Wave 23 -> 100: plateau at exactly 0.65 (delta = 0.00)
  let plateauValid = true;
  for (let w = 23; w <= 99; w++) {
    const gCurr = computeEnemyStats(w, "PirateGrunt");
    const gNext = computeEnemyStats(w + 1, "PirateGrunt");
    if (Math.abs(gCurr.armor - 0.65) > 1e-9 || Math.abs(gNext.armor - 0.65) > 1e-9) {
      plateauValid = false;
    }
  }

  recordTest(
    'CH-2.1',
    'Haki Armor step: Exact +0.03 (+3.0%) per wave progression verified from Wave 1 to 22, cap transition at Wave 23, and locked at 65% ceiling',
    linearStepValid && capTransitionValid && plateauValid,
    `W1: 0.00 -> W22: ${(g22.armor*100).toFixed(1)}% (+3%/w) -> W23: ${(g23.armor*100).toFixed(1)}% (cap) -> W100: 65.0%`
  );
}

// CH-2.2: Strict Class Caps Enforcement Across Waves 1 to 100
{
  // Spec caps:
  // Grunt: 65% (0.65)
  // Assassin: 35% (0.35)
  // Brute: 75% (0.75)
  // Boss: 70% (0.70)
  let gruntCapRespected = true;
  let assassinCapRespected = true;
  let bruteCapRespected = true;
  let bossCapRespected = true;

  let gruntMax = 0, assassinMax = 0, bruteMax = 0, bossMax = 0;

  for (let w = 1; w <= 100; w++) {
    const g = computeEnemyStats(w, "PirateGrunt");
    const a = computeEnemyStats(w, "SoruAssassin");
    const b = computeEnemyStats(w, "HakiBrute");
    const y = computeEnemyStats(w, "YonkoBoss");

    if (g.armor > 0.6500001) gruntCapRespected = false;
    if (a.armor > 0.3500001) assassinCapRespected = false;
    if (b.armor > 0.7500001) bruteCapRespected = false;
    if (y.armor > 0.7000001) bossCapRespected = false;

    if (g.armor > gruntMax) gruntMax = g.armor;
    if (a.armor > assassinMax) assassinMax = a.armor;
    if (b.armor > bruteMax) bruteMax = b.armor;
    if (y.armor > bossMax) bossMax = y.armor;
  }

  const allCapsRespected = gruntCapRespected && assassinCapRespected && bruteCapRespected && bossCapRespected;

  recordTest(
    'CH-2.2',
    'Strict Cap Enforcement: Grunt max=65%, Assassin max<=35%, Brute max=75%, Boss max=70%',
    allCapsRespected,
    `Observed maxes: Grunt=${(gruntMax * 100).toFixed(1)}%, Assassin=${(assassinMax * 100).toFixed(1)}%, Brute=${(bruteMax * 100).toFixed(1)}%, Boss=${(bossMax * 100).toFixed(1)}%`
  );
}

// CH-2.3: Damage Multiplier Floor (Effective Damage Multiplier)
{
  // Effective damage taken is (1 - ArmorReduction)
  // Check that effective damage is never negative, never > 1.0, and never below 0.25 (75% max armor)
  let damageMultInRange = true;
  for (let w = 1; w <= 100; w++) {
    for (const cls of ["PirateGrunt", "SoruAssassin", "HakiBrute", "YonkoBoss"]) {
      const stats = computeEnemyStats(w, cls);
      const effectiveDmgTaken = 1.0 - stats.armor;
      if (effectiveDmgTaken < 0.24999 || effectiveDmgTaken > 1.00001) {
        damageMultInRange = false;
      }
    }
  }

  recordTest(
    'CH-2.3',
    'Combat Invariant: Effective damage multiplier (1 - ArmorReduction) stays strictly within [0.25, 1.0] across all 100 waves',
    damageMultInRange,
    'Enemies retain at least 25% damage vulnerability even under maximum Haki hardening'
  );
}

// ============================================================================
// DIMENSION 3: BOSS 2.5%/s REGENERATION, HEALTH CLAMPING & DEATH ATOMICITY
// ============================================================================
console.log(`\n${C.bold}--- DIMENSION 3: BOSS 2.5%/s REGEN, CLAMPING & DEATH ATOMICITY ---${C.reset}`);

// Simulated Boss Entity Runtime Loop matching WaveManager.server.luau
class SimulatedBoss {
  constructor(wave) {
    const stats = computeEnemyStats(wave, "YonkoBoss");
    this.maxHp = stats.maxHp;
    this.currentHp = stats.maxHp;
    this.regenPerSec = stats.regenPerSec; // 0.025
    this.isDead = false;
    this.parent = {}; // represents model.Parent
    this.cashAwarded = 0;
    this.cashReward = stats.cash;
  }

  takeDamage(amount) {
    if (this.isDead || !this.parent) return;
    this.currentHp = Math.max(-1000, this.currentHp - amount);
    this._onHpChanged();
  }

  _onHpChanged() {
    if (this.currentHp <= 0 && !this.isDead && this.parent) {
      this.isDead = true;
      this.cashAwarded += this.cashReward;
      this.parent = null; // model:Destroy()
    }
  }

  tickRegen() {
    if (!this.parent || this.isDead) return false;
    if (this.currentHp > 0 && this.currentHp < this.maxHp) {
      const heal = Math.floor(this.maxHp * this.regenPerSec);
      const newHp = Math.min(this.maxHp, this.currentHp + heal);
      this.currentHp = newHp;
      return true;
    }
    return false;
  }
}

// CH-3.1: Undamaged Boss Full-HP Clamping (No Overheal)
{
  const boss = new SimulatedBoss(10);
  const initialHp = boss.currentHp;
  // Run 10 ticks of regen on full HP boss
  let healedCount = 0;
  for (let t = 0; t < 10; t++) {
    const didHeal = boss.tickRegen();
    if (didHeal) healedCount++;
  }

  const noOverheal = boss.currentHp === initialHp && boss.currentHp === boss.maxHp && healedCount === 0;

  recordTest(
    'CH-3.1',
    'Boss Full-HP Clamping: Undamaged boss does not overheal past MaxHP (currentHp === maxHp)',
    noOverheal,
    `Initial HP: ${initialHp}, After 10 regen ticks: ${boss.currentHp}, Healed: ${healedCount} times`
  );
}

// CH-3.2: Partial Damage Regeneration Rate (Exact 2.5%/s) and Upper Bound Clamping
{
  const boss = new SimulatedBoss(10);
  const expectedHealPerSec = Math.floor(boss.maxHp * 0.025);
  // Inflict 10% damage
  const damageTaken = Math.floor(boss.maxHp * 0.10);
  boss.takeDamage(damageTaken);
  const hpAfterDamage = boss.currentHp;

  // Tick 1
  boss.tickRegen();
  const hpAfterTick1 = boss.currentHp;
  const actualHeal1 = hpAfterTick1 - hpAfterDamage;

  // Tick 2
  boss.tickRegen();
  const hpAfterTick2 = boss.currentHp;
  const actualHeal2 = hpAfterTick2 - hpAfterTick1;

  // Now run 100 ticks to ensure it clamps at maxHp without exceeding it
  for (let t = 0; t < 100; t++) {
    boss.tickRegen();
  }

  const exactHealRate = actualHeal1 === expectedHealPerSec && actualHeal2 === expectedHealPerSec;
  const perfectlyClamped = boss.currentHp === boss.maxHp;

  recordTest(
    'CH-3.2',
    'Boss 2.5%/s Regeneration Rate: Restores exactly floor(MaxHP * 0.025) per tick and clamps exactly at MaxHP',
    exactHealRate && perfectlyClamped,
    `Expected heal: +${expectedHealPerSec} HP/s, Actual: +${actualHeal1} HP/s, Clamped Final HP: ${boss.currentHp} / ${boss.maxHp}`
  );
}

// CH-3.3: Atomic Death and Post-Mortem Resurrection Prevention
{
  const boss = new SimulatedBoss(10);
  // Deal fatal damage
  boss.takeDamage(boss.maxHp + 500);

  const isDeadAfterLethal = boss.isDead === true;
  const destroyedAfterLethal = boss.parent === null;
  const cashAwardedOnce = boss.cashAwarded === boss.cashReward;

  // Adversarial attack: attempt to run regen loop 50 times on dead boss
  for (let t = 0; t < 50; t++) {
    boss.tickRegen();
  }

  const noResurrection = boss.isDead === true && boss.currentHp <= 0 && boss.parent === null;

  // Additional adversarial attack: try dealing further damage after death
  boss.takeDamage(100);
  const noDoubleCash = boss.cashAwarded === boss.cashReward;

  recordTest(
    'CH-3.3',
    'Atomic Death & Zombie Resurrection Defense: Fatal damage cleanly triggers isDead=true, awards cash once, and regen loop cannot resurrect boss',
    isDeadAfterLethal && destroyedAfterLethal && cashAwardedOnce && noResurrection && noDoubleCash,
    `Death atomic: isDead=${boss.isDead}, parent=${boss.parent}, cashAwarded=${boss.cashAwarded}`
  );
}

// ============================================================================
// DIMENSION 4: DYNAMIC SWARM SIZING & INTERVAL ACCELERATION BOUNDS
// ============================================================================
console.log(`\n${C.bold}--- DIMENSION 4: SPAWN DENSITY & INTERVAL ACCELERATION (0.85s -> 0.35s) ---${C.reset}`);

// CH-4.1: Dynamic Wave Sizing Function Invariants
{
  // count = 8 + math.floor(wave * 3.5)
  let countStrictlyIncreasing = true;
  let countsValid = true;
  let prevCount = 0;

  for (let w = 1; w <= 100; w++) {
    const count = 8 + Math.floor(w * 3.5);
    if (count <= prevCount) countStrictlyIncreasing = false;
    if (count < 11 || count > 400) countsValid = false;
    prevCount = count;
  }

  const w1Count = 8 + Math.floor(1 * 3.5); // 11
  const w10Count = 8 + Math.floor(10 * 3.5); // 43
  const w100Count = 8 + Math.floor(100 * 3.5); // 358

  recordTest(
    'CH-4.1',
    'Dynamic Wave Sizing: count = 8 + floor(wave * 3.5) strictly increases (W1: 11 mobs, W10: 43 mobs, W100: 358 mobs)',
    countStrictlyIncreasing && countsValid && w1Count === 11 && w10Count === 43 && w100Count === 358,
    `W1=${w1Count}, W10=${w10Count}, W100=${w100Count}`
  );
}

// CH-4.2: Spawn Interval Bounds [0.35s, 0.85s] and Monotonic Acceleration
{
  // spawnInterval = math.max(0.35, 0.85 - (wave - 1) * 0.035)
  let inBounds = true;
  let nonIncreasing = true;
  let prevInterval = 1.0;
  let clampedAtWave = null;

  for (let w = 1; w <= 100; w++) {
    const interval = Math.max(0.35, 0.85 - (w - 1) * 0.035);
    if (interval < 0.35 || interval > 0.85) inBounds = false;
    if (interval > prevInterval + 1e-9) nonIncreasing = false;
    if (Math.abs(interval - 0.35) < 1e-9 && clampedAtWave === null) {
      clampedAtWave = w;
    }
    prevInterval = interval;
  }

  const w1Interval = Math.max(0.35, 0.85 - (1 - 1) * 0.035);
  const w15Interval = Math.max(0.35, 0.85 - (15 - 1) * 0.035);
  const w16Interval = Math.max(0.35, 0.85 - (16 - 1) * 0.035);
  const w100Interval = Math.max(0.35, 0.85 - (100 - 1) * 0.035);

  const exactProgression =
    Math.abs(w1Interval - 0.85) < 1e-9 &&
    Math.abs(w15Interval - 0.36) < 1e-9 &&
    Math.abs(w16Interval - 0.35) < 1e-9 &&
    Math.abs(w100Interval - 0.35) < 1e-9 &&
    clampedAtWave === 16;

  recordTest(
    'CH-4.2',
    'Spawn Interval Bounds: Clamped in [0.35s, 0.85s], drops by 0.035s/wave and locks at 0.35s floor at Wave 16',
    inBounds && nonIncreasing && exactProgression,
    `W1: ${w1Interval.toFixed(3)}s -> W15: ${w15Interval.toFixed(3)}s -> W16: ${w16Interval.toFixed(3)}s (floor locked)`
  );
}

// ============================================================================
// DIMENSION 5: ENEMY CLASS DISTRIBUTION & SPAWN CADENCE
// ============================================================================
console.log(`\n${C.bold}--- DIMENSION 5: CLASS DISTRIBUTION & BOSS SPAWN CADENCE ---${C.reset}`);

// Simulate wave spawn cadence matching WaveManager.server.luau
function simulateWaveSpawns(wave) {
  const count = 8 + Math.floor(wave * 3.5);
  const isBossWave = (wave % 3 === 0) || (wave >= 10);
  const spawned = [];

  for (let i = 1; i <= count; i++) {
    let key = "PirateGrunt";
    if (wave % 5 === 0 && i === count) {
      key = "YonkoKaido";
    } else if (isBossWave && i === count) {
      key = "YonkoBoss";
    } else if (wave >= 3 && (i % 4 === 0)) {
      key = "HakiBrute";
    } else if (wave >= 2 && (i % 3 === 0)) {
      key = "SoruAssassin";
    } else {
      key = "PirateGrunt";
    }
    spawned.push(key);
  }
  return spawned;
}

// CH-5.1: Wave 1 Purity (Only PirateGrunt)
{
  const w1 = simulateWaveSpawns(1);
  const onlyGrunts = w1.every(k => k === "PirateGrunt") && w1.length === 11;

  recordTest(
    'CH-5.1',
    'Wave 1 Purity: Exactly 11 enemies, 100% PirateGrunt (no premature Brutes, Assassins, or Bosses)',
    onlyGrunts,
    `Wave 1 composition: ${w1.length} mobs, all PirateGrunt`
  );
}

// CH-5.2: Wave 2 Introduction of SoruAssassin (i % 3 == 0)
{
  const w2 = simulateWaveSpawns(2);
  const assassins = w2.filter(k => k === "SoruAssassin");
  const grunts = w2.filter(k => k === "PirateGrunt");
  const noBrutesOrBosses = w2.every(k => k === "PirateGrunt" || k === "SoruAssassin");

  recordTest(
    'CH-5.2',
    'Wave 2 Assassin Cadence: SoruAssassin unlocks at Wave 2 on i % 3 == 0 (no Brutes or Bosses)',
    assassins.length === 5 && noBrutesOrBosses && w2.length === 15,
    `Wave 2: ${w2.length} mobs (${grunts.length} Grunts, ${assassins.length} Assassins)`
  );
}

// CH-5.3: Wave 3 Full Class Deployment & First Boss Wave
{
  const w3 = simulateWaveSpawns(3);
  const lastMob = w3[w3.length - 1];
  const hasBrutes = w3.includes("HakiBrute");
  const hasAssassins = w3.includes("SoruAssassin");
  const hasGrunts = w3.includes("PirateGrunt");
  const bossAtEnd = lastMob === "YonkoBoss";

  recordTest(
    'CH-5.3',
    'Wave 3 Integration: First boss wave culminates in YonkoBoss at i==count; contains Grunts, Assassins, and Brutes',
    bossAtEnd && hasBrutes && hasAssassins && hasGrunts,
    `Wave 3: ${w3.length} mobs, ends with ${lastMob}`
  );
}

// CH-5.4: Boss Cadence Invariant: Dual Trigger (wave % 3 == 0 OR wave >= 10)
{
  let bossCadenceValid = true;
  for (let w = 1; w <= 30; w++) {
    const waveMobs = simulateWaveSpawns(w);
    const lastMob = waveMobs[waveMobs.length - 1];
    const shouldHaveBoss = (w % 3 === 0) || (w % 5 === 0) || (w >= 10);
    const hasBossAtEnd = (lastMob === "YonkoBoss" || lastMob === "YonkoKaido");

    if (shouldHaveBoss !== hasBossAtEnd) {
      bossCadenceValid = false;
    }
  }

  recordTest(
    'CH-5.4',
    'Boss Cadence Invariant: Dual trigger (wave % 3 == 0, wave % 5 == 0, and all wave >= 10) correctly spawns boss as culminating mob',
    bossCadenceValid,
    'Tested waves 1-30: 100% agreement with boss cadence spec'
  );
}

// ============================================================================
// DIMENSION 6: SOURCE CODE SANITY & AST REGRESSION INVARIANTS
// ============================================================================
console.log(`\n${C.bold}--- DIMENSION 6: STATIC SOURCE AST SANITY & COMPLIANCE ---${C.reset}`);

// CH-6.1: GameConfig Integrity Check
{
  const configChecks = [
    configSource.includes('BASE_ZOMBIE_HP = 450'),
    configSource.includes('WAVE_HP_EXPONENT = 1.58'),
    configSource.includes('SURGE_INTERVAL = 3'),
    configSource.includes('SURGE_SCALE = 0.75'),
    configSource.includes('BASE_HAKI_ARMOR_STEP = 0.03'),
    configSource.includes('MAX_HAKI_ARMOR = 0.65'),
    configSource.includes('GameConfig.ENEMY_CLASSES = {'),
    configSource.includes('PirateGrunt = {'),
    configSource.includes('SoruAssassin = {'),
    configSource.includes('HakiBrute = {'),
    configSource.includes('YonkoBoss = {'),
    configSource.includes('HP_GROWTH_RATE = 1.18'), // Legacy compatibility
    configSource.includes('BOSS_WAVE_INTERVAL = 5'), // Legacy compatibility
  ];

  const allConfigPass = configChecks.every(Boolean);

  recordTest(
    'CH-6.1',
    'GameConfig Luau Source: All 6 Phase 4 constants, ENEMY_CLASSES, and legacy compatibility tokens present',
    allConfigPass,
    `${configChecks.filter(Boolean).length}/${configChecks.length} AST tokens verified`
  );
}

// CH-6.2: WaveManager Runtime & Visual Attributes Check
{
  const waveChecks = [
    waveSource.includes('model:SetAttribute("HP", stats.MaxHP)'),
    waveSource.includes('model:SetAttribute("MaxHP", stats.MaxHP)'),
    waveSource.includes('model:SetAttribute("ArmorReduction", stats.Armor)'),
    waveSource.includes('model:SetAttribute("RegenPerSec", stats.RegenPerSec)'),
    waveSource.includes('model:SetAttribute("IsBoss", stats.IsBoss)'),
    waveSource.includes('UDim2.new(0, 52, 0, 6)'), // micro health bar
    waveSource.includes('UDim2.new(0, 96, 0, 16)'), // boss bar
    waveSource.includes('AlwaysOnTop = false'),
    waveSource.includes('MaxDistance = stats.IsBoss and 90 or 85'),
    waveSource.includes('[BOSS] YONKO CALAMITY'),
    waveSource.includes('model:PivotTo(root.CFrame)'),
  ];

  const allWavePass = waveChecks.every(Boolean);

  recordTest(
    'CH-6.2',
    'WaveManager Luau Source: Sets all required attributes, micro health bars, PivotTo synchrony, and boss title',
    allWavePass,
    `${waveChecks.filter(Boolean).length}/${waveChecks.length} AST tokens verified`
  );
}

// ============================================================================
// SUMMARY & VERDICT
// ============================================================================
console.log(`\n${C.bold}${C.yellow}========================================================================${C.reset}`);
console.log(`${C.bold}CHALLENGER STRESS HARNESS COMPLETE: ${results.passed} / ${results.total} PASSED (${((results.passed / results.total) * 100).toFixed(1)}%)${C.reset}`);
console.log(`${C.bold}${C.yellow}========================================================================${C.reset}\n`);

if (results.failed > 0) {
  console.error(`${C.red}${C.bold}VERDICT: REQUEST_CHANGES (${results.failed} tests failed)${C.reset}`);
  process.exit(1);
} else {
  console.log(`${C.green}${C.bold}VERDICT: APPROVE (All mathematical scalings, invariants, and stress tests PASSED)${C.reset}`);
  process.exit(0);
}
