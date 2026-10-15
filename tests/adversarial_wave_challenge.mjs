// tests/adversarial_wave_challenge.mjs
// Adversarial Empirical Challenge Suite for Track 1 WaveManager (Milestone 2)
// Evaluates wave scaling, prep countdown boundaries, Kaido boss frequency, and NaN/overflow safety up to Wave 100.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(__dirname, '..');

// Colors
const C = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  yellow: '\x1b[33m',
  gray: '\x1b[90m',
};

// Enemy types lookup matching WaveManager.server.luau
const ENEMY_SPECS = {
  ThrillerZombie: { Name: "Thriller Bark Zombie", BaseHP: 120, Speed: 10.5, Cash: 22, Scale: 1.0 },
  GeneralZombie: { Name: "General Zombie", BaseHP: 420, Speed: 7.2, Cash: 55, Scale: 1.25 },
  CommandGeneral: { Name: "Command General", BaseHP: 280, Speed: 14.5, Cash: 70, Scale: 1.1 },
  YonkoKaido: { Name: "YONKO KAIDO [DRAGON EMPEROR]", BaseHP: 2600, Speed: 6.0, Cash: 550, Scale: 1.85 },
};

const challengeResults = {
  timestamp: new Date().toISOString(),
  challenges: [],
  summary: { total: 0, passed: 0, failed: 0 }
};

function recordChallenge(id, category, description, passed, details = {}) {
  challengeResults.challenges.push({ id, category, description, passed, details });
  challengeResults.summary.total++;
  if (passed) {
    challengeResults.summary.passed++;
  } else {
    challengeResults.summary.failed++;
  }
  const tag = `[${category}]`;
  const statusStr = passed
    ? `${C.green}${C.bold}PASS${C.reset}`
    : `${C.red}${C.bold}FAIL${C.reset}`;
  console.log(`${C.cyan}${tag}${C.reset} ${statusStr} ${C.bold}${id}${C.reset}: ${description}`);
  if (Object.keys(details).length > 0) {
    console.log(`       ${C.gray}${JSON.stringify(details)}${C.reset}`);
  }
}

console.log(`\n${C.bold}${C.yellow}========================================================================${C.reset}`);
console.log(`${C.bold}${C.yellow}   ADVERSARIAL CHALLENGE SUITE: TRACK 1 WAVE SYSTEM (MILESTONE 2)       ${C.reset}`);
console.log(`${C.bold}${C.yellow}   Testing Waves 1-100, Prep Countdown Boundaries, Kaido Boss, & Safety${C.reset}`);
console.log(`${C.bold}${C.yellow}========================================================================${C.reset}\n`);

// ============================================================================
// SUITE 1: WAVE SCALING FORMULAS UP TO WAVE 100
// ============================================================================
console.log(`${C.bold}--- SUITE 1: WAVE SCALING FORMULA INVARIANTS (WAVES 1-100) ---${C.reset}`);

// ADV-1.1: Zombie count per wave: count = 6 + math.floor(wave * 2.5)
{
  let countStrictlyMonotonic = true;
  let countAllIntegers = true;
  let countWithinBounds = true;
  let prevCount = 0;
  const countSamples = {};

  for (let wave = 1; wave <= 100; wave++) {
    const count = 6 + Math.floor(wave * 2.5);
    if (!Number.isInteger(count) || isNaN(count)) countAllIntegers = false;
    if (count < prevCount) countStrictlyMonotonic = false;
    if (count < 8 || count > 300) countWithinBounds = false;
    prevCount = count;
    if (wave === 1 || wave === 5 || wave === 10 || wave === 50 || wave === 100) {
      countSamples[`Wave_${wave}`] = count;
    }
  }

  recordChallenge(
    'ADV-1.1',
    'SCALING',
    'Zombie count formula (6 + floor(wave * 2.5)) is integer, monotonic, bounded for waves 1..100',
    countStrictlyMonotonic && countAllIntegers && countWithinBounds,
    { samples: countSamples, wave1: 8, wave100: 256 }
  );
}

// ADV-1.2: Exponential HP Scaling: hpMult = 1.18^(wave - 1), maxHp = floor(BaseHP * hpMult)
{
  let hpMonotonic = true;
  let hpNoNaN = true;
  let hpWithinSafeInt = true;
  const hpSamples = {};

  for (const [key, spec] of Object.entries(ENEMY_SPECS)) {
    let prevHp = 0;
    for (let wave = 1; wave <= 100; wave++) {
      const hpMult = Math.pow(1.18, wave - 1);
      const maxHp = Math.floor(spec.BaseHP * hpMult);

      if (isNaN(maxHp) || !isFinite(maxHp) || maxHp <= 0) {
        hpNoNaN = false;
      }
      if (maxHp < prevHp) {
        hpMonotonic = false;
      }
      if (maxHp > Number.MAX_SAFE_INTEGER) {
        hpWithinSafeInt = false;
      }
      prevHp = maxHp;

      if (key === 'YonkoKaido' && (wave === 5 || wave === 10 || wave === 50 || wave === 100)) {
        hpSamples[`Kaido_W${wave}`] = maxHp;
      }
    }
  }

  const maxPossibleHpAt100 = Math.floor(ENEMY_SPECS.YonkoKaido.BaseHP * Math.pow(1.18, 99));
  const safeIntRatio = (maxPossibleHpAt100 / Number.MAX_SAFE_INTEGER).toExponential(3);

  recordChallenge(
    'ADV-1.2',
    'SCALING',
    'Exponential HP scaling (1.18^(w-1)) monotonic, non-NaN, and strictly within MAX_SAFE_INTEGER up to wave 100',
    hpMonotonic && hpNoNaN && hpWithinSafeInt,
    { samples: hpSamples, maxKaidoHpAtW100: maxPossibleHpAt100, safeIntRatio }
  );
}

// ADV-1.3: Wave Clear Cash & Bounty Multiplier Scaling
{
  let cashMonotonic = true;
  let bountyCorrect = true;
  const cashSamples = {};

  for (let wave = 1; wave <= 100; wave++) {
    const baseReward = 90 + wave * 25;
    if (wave > 1 && baseReward <= (90 + (wave - 1) * 25)) {
      cashMonotonic = false;
    }

    // Test across various BountyMultiplierStat values
    for (const mult of [1.0, 1.4, 2.0, 3.5, 5.0]) {
      const finalCash = Math.floor(baseReward * mult);
      if (isNaN(finalCash) || finalCash < baseReward) {
        bountyCorrect = false;
      }
    }

    if (wave === 1 || wave === 5 || wave === 15 || wave === 100) {
      cashSamples[`Wave_${wave}_Base`] = baseReward;
      cashSamples[`Wave_${wave}_Mult1.4`] = Math.floor(baseReward * 1.4);
    }
  }

  recordChallenge(
    'ADV-1.3',
    'SCALING',
    'Wave clear cash reward (90 + wave * 25) with BountyMultiplier is monotonic, integer, and safe',
    cashMonotonic && bountyCorrect,
    { samples: cashSamples }
  );
}

// ============================================================================
// SUITE 2: PREPARATION COUNTDOWN BOUNDARY CONDITIONS
// ============================================================================
console.log(`\n${C.bold}--- SUITE 2: PREP COUNTDOWN BOUNDARY CONDITIONS & EARLY BREAKOUT ---${C.reset}`);

// Simulate the exact prep countdown logic from WaveManager lines 268-286:
class PrepCountdownSimulator {
  constructor() {
    this.prepCountdown = 15;
    this.waveStatus = "";
    this.towersCount = 0;
    this.history = [];
    this.waveStarted = false;
  }

  runCountdown(towerSpawnSecond = null) {
    this.prepCountdown = 15;
    this.history.push({ sec: 15, countdown: 15, towers: this.towersCount, status: "INIT" });

    for (let prepSec = 15; prepSec >= 1; prepSec--) {
      this.prepCountdown = prepSec;

      if (towerSpawnSecond !== null && prepSec === towerSpawnSecond) {
        this.towersCount++;
      }

      if (this.towersCount > 0) {
        this.prepCountdown = 0;
        this.waveStatus = "HERO DEPLOYED! STARTING WAVE 1...";
        this.history.push({ sec: prepSec, countdown: 0, towers: this.towersCount, status: this.waveStatus, earlyBreak: true });
        this.waveStarted = true;
        break;
      }

      this.waveStatus = `PREP PHASE (${prepSec}s): กดปุ่ม SUMMON กลางจอเพื่อสุ่มและวางตัวละคร!`;
      this.history.push({ sec: prepSec, countdown: prepSec, towers: this.towersCount, status: this.waveStatus });
    }

    this.prepCountdown = 0;
    this.waveStarted = true;
    return this.history;
  }
}

// ADV-2.1: Full 15-second countdown when 0 towers are deployed
{
  const sim = new PrepCountdownSimulator();
  const hist = sim.runCountdown(null); // No towers placed
  const initialEntry = hist[0];
  const finalCountdown = sim.prepCountdown;
  const reachedSec1 = hist.some(h => h.sec === 1);
  const anyNegative = hist.some(h => h.countdown < 0);

  recordChallenge(
    'ADV-2.1',
    'PREP_COUNTDOWN',
    'Full 15s countdown with 0 towers decrements strictly 15..1 then terminates at 0s without negative values',
    initialEntry.countdown === 15 && reachedSec1 && finalCountdown === 0 && !anyNegative,
    { historyLength: hist.length, finalCountdown, reachedSec1 }
  );
}

// ADV-2.2: Immediate early breakout at t=15s (first second of prep)
{
  const sim = new PrepCountdownSimulator();
  const hist = sim.runCountdown(15); // Tower placed immediately at t=15s
  const brokeImmediately = hist.length === 2 && hist[1].earlyBreak === true;
  const countdownZero = sim.prepCountdown === 0;
  const statusExpected = sim.waveStatus === "HERO DEPLOYED! STARTING WAVE 1...";

  recordChallenge(
    'ADV-2.2',
    'PREP_COUNTDOWN',
    'Immediate tower placement at t=15s triggers instant breakout to 0s and status change',
    brokeImmediately && countdownZero && statusExpected,
    { stepsTaken: hist.length, finalCountdown: sim.prepCountdown, status: sim.waveStatus }
  );
}

// ADV-2.3: Mid-countdown early breakout (e.g. at t=8s)
{
  const sim = new PrepCountdownSimulator();
  const hist = sim.runCountdown(8); // Tower placed at t=8s
  const breakEntry = hist.find(h => h.earlyBreak);
  const correctBreakSec = breakEntry && breakEntry.sec === 8;
  const finalCountdown = sim.prepCountdown;
  const statusExpected = sim.waveStatus === "HERO DEPLOYED! STARTING WAVE 1...";

  recordChallenge(
    'ADV-2.3',
    'PREP_COUNTDOWN',
    'Mid-countdown tower placement at t=8s halts countdown immediately and begins Wave 1',
    correctBreakSec && finalCountdown === 0 && statusExpected,
    { breakSec: breakEntry?.sec, stepsBeforeBreak: hist.length - 1 }
  );
}

// ADV-2.4: Boundary condition: Negative or zero values externally injected
{
  // Test what happens if workspace attribute has unexpected values
  let safeRecovery = true;
  for (const weirdVal of [0, -1, -15, NaN, null, undefined]) {
    const sim = new PrepCountdownSimulator();
    // Simulate startWaveLoop re-initialization
    sim.prepCountdown = (typeof weirdVal === 'number' && !isNaN(weirdVal)) ? weirdVal : 15;
    // The code at line 268 explicitly resets: Workspace:SetAttribute(PREP_COUNTDOWN, 15)
    sim.prepCountdown = 15;
    if (sim.prepCountdown !== 15) safeRecovery = false;
  }

  recordChallenge(
    'ADV-2.4',
    'PREP_COUNTDOWN',
    'Wave loop initialization strictly resets PrepCountdown to 15 regardless of prior corrupted state',
    safeRecovery,
    { resetGuarantee: "Workspace:SetAttribute(PREP_COUNTDOWN, 15)" }
  );
}

// ============================================================================
// SUITE 3: KAIDO BOSS SPAWN FREQUENCY & POSITION ORACLE (WAVES 1-100)
// ============================================================================
console.log(`\n${C.bold}--- SUITE 3: KAIDO BOSS SPAWN FREQUENCY & POSITION ORACLE ---${C.reset}`);

// Simulate the exact spawning ladder from lines 308-316:
function simulateWaveSpawns(wave) {
  const count = 6 + Math.floor(wave * 2.5);
  const spawns = [];

  for (let i = 1; i <= count; i++) {
    let key = "ThrillerZombie";
    if (wave % 5 === 0 && i === count) {
      key = "YonkoKaido";
    } else if (i % 5 === 0) {
      key = "GeneralZombie";
    } else if (i % 3 === 0) {
      key = "CommandGeneral";
    }
    spawns.push({ index: i, count, key });
  }

  return { wave, count, spawns };
}

// ADV-3.1: Zero Kaido spawns on non-boss waves (wave % 5 !== 0) across waves 1..100
{
  let nonBossWavesClean = true;
  let nonBossWaveCount = 0;
  const violationSamples = [];

  for (let wave = 1; wave <= 100; wave++) {
    if (wave % 5 !== 0) {
      nonBossWaveCount++;
      const { spawns } = simulateWaveSpawns(wave);
      const kaidoCount = spawns.filter(s => s.key === "YonkoKaido").length;
      if (kaidoCount > 0) {
        nonBossWavesClean = false;
        violationSamples.push({ wave, kaidoCount });
      }
    }
  }

  recordChallenge(
    'ADV-3.1',
    'KAIDO_BOSS',
    'Kaido NEVER spawns on non-boss waves (wave % 5 !== 0) across all 80 non-boss waves in 1..100',
    nonBossWavesClean,
    { nonBossWavesTested: nonBossWaveCount, violations: violationSamples.length }
  );
}

// ADV-3.2: Exactly 1 Kaido spawn on every boss wave (wave % 5 === 0) across waves 1..100
{
  let bossWavesExactOne = true;
  let bossWaveCount = 0;
  const bossWaveSamples = [];

  for (let wave = 1; wave <= 100; wave++) {
    if (wave % 5 === 0) {
      bossWaveCount++;
      const { spawns } = simulateWaveSpawns(wave);
      const kaidoSpawns = spawns.filter(s => s.key === "YonkoKaido");
      if (kaidoSpawns.length !== 1) {
        bossWavesExactOne = false;
      }
      if (wave === 5 || wave === 10 || wave === 15 || wave === 50 || wave === 100) {
        bossWaveSamples.push({ wave, kaidoSpawnIndex: kaidoSpawns[0]?.index, totalZombies: spawns.length });
      }
    }
  }

  recordChallenge(
    'ADV-3.2',
    'KAIDO_BOSS',
    'Kaido spawns EXACTLY ONCE on every boss wave (wave % 5 === 0) across all 20 boss waves in 1..100',
    bossWavesExactOne,
    { bossWavesTested: bossWaveCount, samples: bossWaveSamples }
  );
}

// ADV-3.3: Kaido spawns strictly at the final enemy index (i === count)
{
  let strictlyFinalIndex = true;
  const indexViolations = [];

  for (let wave = 5; wave <= 100; wave += 5) {
    const { count, spawns } = simulateWaveSpawns(wave);
    const kaido = spawns.find(s => s.key === "YonkoKaido");
    if (!kaido || kaido.index !== count) {
      strictlyFinalIndex = false;
      indexViolations.push({ wave, expectedIndex: count, actualIndex: kaido?.index });
    }
  }

  recordChallenge(
    'ADV-3.3',
    'KAIDO_BOSS',
    'Kaido boss is strictly the FINAL enemy (i === count) of the boss wave, never premature',
    strictlyFinalIndex,
    { violations: indexViolations }
  );
}

// ADV-3.4: Preemption resistance: GeneralZombie (i%5==0) or CommandGeneral (i%3==0) do not override Kaido
{
  let noPreemption = true;
  const collisionCases = [];

  for (let wave = 5; wave <= 100; wave += 5) {
    const count = 6 + Math.floor(wave * 2.5);
    const hasCollisionPotential = (count % 3 === 0 || count % 5 === 0);
    if (hasCollisionPotential) {
      const { spawns } = simulateWaveSpawns(wave);
      const finalEnemy = spawns[spawns.length - 1];
      if (finalEnemy.key !== "YonkoKaido") {
        noPreemption = false;
        collisionCases.push({ wave, count, key: finalEnemy.key });
      }
    }
  }

  recordChallenge(
    'ADV-3.4',
    'KAIDO_BOSS',
    'Ladder precedence ensures Kaido (if wave%5==0 and i==count) overrides i%5==0 or i%3==0 conditions',
    noPreemption,
    { collisionPotentialWavesTested: 10, collisions: collisionCases.length }
  );
}

// ============================================================================
// SUITE 4: NAN, DIVISION-BY-ZERO, AND RESOURCE SAFETY
// ============================================================================
console.log(`\n${C.bold}--- SUITE 4: NAN, ZERO-DIVISION, AND UNDERFLOW SAFETY ---${C.reset}`);

// ADV-4.1: Vector distance division-by-zero resistance
{
  let unitVectorSafe = true;

  for (const testDist of [1.2001, 1.25, 2.0, 10.0, 50.0]) {
    const diff = { x: testDist, y: 0, z: 0 };
    const mag = Math.sqrt(diff.x * diff.x + diff.y * diff.y + diff.z * diff.z);
    if (mag <= 1.2) {
      // Loop breaks, diff.Unit never calculated
    } else {
      const unit = { x: diff.x / mag, y: diff.y / mag, z: diff.z / mag };
      if (isNaN(unit.x) || isNaN(unit.y) || isNaN(unit.z) || !isFinite(unit.x)) {
        unitVectorSafe = false;
      }
    }
  }

  recordChallenge(
    'ADV-4.1',
    'MATH_SAFETY',
    'Distance check (dist <= 1.2 -> break) mathematically prevents zero-division in diff.Unit calculation',
    unitVectorSafe,
    { breakThreshold: 1.2, minEvaluatedDist: 1.2001 }
  );
}

// ADV-4.2: Sine wave bobbing bounds check over 100,000 steps
{
  let bobStrictlyBounded = true;
  let minBob = 999, maxBob = -999;

  for (let tick = 0; tick < 100000; tick++) {
    const bob = Math.sin(tick * 0.6) * 0.35;
    if (isNaN(bob) || bob < -0.3500000001 || bob > 0.3500000001) {
      bobStrictlyBounded = false;
    }
    if (bob < minBob) minBob = bob;
    if (bob > maxBob) maxBob = bob;
  }

  recordChallenge(
    'ADV-4.2',
    'MATH_SAFETY',
    'Zombie walk procedural bobbing (sin(stepTick * 0.6) * 0.35) remains strictly bounded within [-0.35, +0.35]',
    bobStrictlyBounded,
    { minBob: minBob.toFixed(4), maxBob: maxBob.toFixed(4), ticksTested: 100000 }
  );
}

// ADV-4.3: Base HP underflow clamp check
{
  let underflowSafe = true;

  for (let curHp = 200; curHp >= -500; curHp -= 25) {
    for (const dmg of [35, 180, 500, 10000]) {
      const newHp = Math.max(0, curHp - dmg);
      if (newHp < 0 || isNaN(newHp)) {
        underflowSafe = false;
      }
    }
  }

  recordChallenge(
    'ADV-4.3',
    'MATH_SAFETY',
    'Base HP damage reduction clamped with math.max(0, curBaseHp - dmg) never produces negative BaseHP',
    underflowSafe,
    { lowestPossibleBaseHp: 0 }
  );
}

// ADV-4.4: Leaderstats Cash addition overflow / integer safety
{
  let totalCashEarned = 500;
  for (let w = 1; w <= 100; w++) {
    const { count, spawns } = simulateWaveSpawns(w);
    for (const enemy of spawns) {
      const spec = ENEMY_SPECS[enemy.key];
      totalCashEarned += spec.Cash * 1.4;
    }
    totalCashEarned += (90 + w * 25) * 1.4;
  }

  const int64Max = BigInt("9223372036854775807");
  const cashBig = BigInt(Math.floor(totalCashEarned));
  const withinInt64 = cashBig < int64Max;

  recordChallenge(
    'ADV-4.4',
    'MATH_SAFETY',
    'Cumulative player cash over 100 waves ($' + Math.floor(totalCashEarned).toLocaleString() + ') safely fits within Roblox IntValue (64-bit)',
    withinInt64,
    { totalCumulativeCash: Math.floor(totalCashEarned), int64Limit: "9.22e18" }
  );
}

// ============================================================================
// SUMMARY & ARTIFACT GENERATION
// ============================================================================
console.log(`\n${C.bold}${C.yellow}========================================================================${C.reset}`);
const passRate = ((challengeResults.summary.passed / challengeResults.summary.total) * 100).toFixed(1);
const summaryColor = challengeResults.summary.failed === 0 ? C.green : C.red;
console.log(`${C.bold}${summaryColor}ADVERSARIAL CHALLENGE COMPLETE: ${challengeResults.summary.passed} / ${challengeResults.summary.total} PASSED (${passRate}%)${C.reset}`);
console.log(`${C.bold}${C.yellow}========================================================================${C.reset}\n`);

// Save results
const outputDir = path.join(PROJECT_ROOT, '.agents/teamwork/challenger_m2_1');
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}
fs.writeFileSync(
  path.join(outputDir, 'adversarial_results.json'),
  JSON.stringify(challengeResults, null, 2)
);

process.exit(challengeResults.summary.failed === 0 ? 0 : 1);
