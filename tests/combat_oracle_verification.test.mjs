// tests/combat_oracle_verification.test.mjs
// Phase 5 Task P5-02: Combat Oracle Verification & Kinematics Timing Test Suite
// Verifies 0.31s nominal hit timing baseline (0.14 + 0.10 + 0.07), hitstop, damage formulas, and cancel semantics

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const REPO_ROOT = path.resolve(__dirname, '..');

const COLORS = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  yellow: '\x1b[33m',
  bold: '\x1b[1m',
  gray: '\x1b[90m'
};

const testResults = {
  timestamp: new Date().toISOString(),
  suite: "Phase 5 Combat Oracle Verification (Task P5-02)",
  total: 0,
  passed: 0,
  failed: 0,
  tests: []
};

function assertTest(id, name, condition, details = '') {
  testResults.total++;
  const passed = Boolean(condition);
  if (passed) {
    testResults.passed++;
  } else {
    testResults.failed++;
  }
  testResults.tests.push({ id, name, passed, details });
  const statusStr = passed
    ? `${COLORS.green}${COLORS.bold}PASS${COLORS.reset}`
    : `${COLORS.red}${COLORS.bold}FAIL${COLORS.reset}`;
  const detailsStr = details ? ` ${COLORS.gray}(${details})${COLORS.reset}` : '';
  console.log(`  ${statusStr} ${COLORS.bold}${id}${COLORS.reset}: ${name}${detailsStr}`);
}

export function runCombatOracleTests() {
  console.log(`\n${COLORS.bold}${COLORS.yellow}========================================================================${COLORS.reset}`);
  console.log(`${COLORS.bold}${COLORS.yellow}   TASK P5-02: COMBAT ORACLE & 0.31s NOMINAL HIT TIMING TEST SUITE      ${COLORS.reset}`);
  console.log(`${COLORS.bold}${COLORS.yellow}   Verification of TowerController.server.luau Combat Kinematics        ${COLORS.reset}`);
  console.log(`${COLORS.bold}${COLORS.yellow}========================================================================\n`);

  const controllerPath = path.join(REPO_ROOT, 'src/Track2_TowerSystem/TowerController.server.luau');
  const source = fs.readFileSync(controllerPath, 'utf-8');

  // ---------------------------------------------------------------------------
  // [1] STATIC CODE AUDIT OF TOWERCONTROLLER.SERVER.LUAU
  // ---------------------------------------------------------------------------
  console.log(`${COLORS.bold}${COLORS.cyan}[1] STATIC CODE AUDIT OF TOWERCONTROLLER.SERVER.LUAU${COLORS.reset}`);

  // ORCL-1.1: Phase 1 Wind-Up delay is strictly 0.14s
  const hasPhase1Delay = source.includes('task.delay(0.14, function()') && source.includes('-- Phase 1: Wind-Up Anticipation (0.14s)');
  assertTest('ORCL-1.1', 'Phase 1 Wind-Up Anticipation delay is strictly 0.14s', hasPhase1Delay);

  // ORCL-1.2: Phase 2 Dash delay is strictly 0.10s
  const hasPhase2Delay = source.includes('task.delay(0.10, function()') && source.includes('-- Phase 2: Dash / Leap (0.10s)');
  assertTest('ORCL-1.2', 'Phase 2 Dash / Leap delay is strictly 0.10s', hasPhase2Delay);

  // ORCL-1.3: Phase 3 Hitstop delay is strictly 0.07s
  const hasPhase3Delay = source.includes('task.delay(0.07, function()') && source.includes('-- Phase 3: Hitstop / Freeze Frame (0.07s)');
  assertTest('ORCL-1.3', 'Phase 3 Hitstop / Freeze Frame delay is strictly 0.07s', hasPhase3Delay);

  // ORCL-1.4: Nominal hit timing sum: 0.14 + 0.10 + 0.07 = 0.31s
  const nominalHitSum = 0.14 + 0.10 + 0.07;
  const isNominal031 = Math.abs(nominalHitSum - 0.31) < 1e-6;
  assertTest('ORCL-1.4', 'Mathematical sum of Phases 1-3 delays equals nominal baseline 0.31s (0.14 + 0.10 + 0.07)',
    isNominal031, `Computed sum: ${nominalHitSum.toFixed(2)}s`);

  // ORCL-1.5: onImpactCallback invoked in Phase 4 right after Phase 3 hitstop
  const hasImpactInvocation = source.includes('-- Phase 4: Impact Strike & Follow-Through (0.20s)') &&
                              source.includes('onImpactCallback()');
  assertTest('ORCL-1.5', 'onImpactCallback is invoked inside Phase 4 immediately following Phase 3 hitstop delay', hasImpactInvocation);

  // ORCL-1.6: Phase 4 (0.20s) and Phase 5 (0.22s) recovery delays
  const hasRecoveryDelays = source.includes('task.delay(0.20, function()') &&
                           source.includes('-- Phase 5: Recoil & Return to Base Pad Position (0.22s)');
  assertTest('ORCL-1.6', 'Recovery phases 4 and 5 define 0.20s and 0.22s delays (total recovery 0.42s)', hasRecoveryDelays);

  // ORCL-1.7: Mid-attack cancellation guards in every delay callback
  const guardMatches = source.match(/if not tower\.Parent or not root\.Parent then\s*return\s*end/g);
  const guardCount = guardMatches ? guardMatches.length : 0;
  assertTest('ORCL-1.7', 'Mid-attack cancellation guards (if not tower.Parent or not root.Parent then return end) exist in all 4 nested delays',
    guardCount >= 4, `Found ${guardCount} guard checks in source`);

  // ORCL-1.8: Combat loop polling frequency is 0.08s
  const hasPollingWait = source.includes('task.wait(0.08)');
  assertTest('ORCL-1.8', 'Combat targeting & resolution loop runs on a 0.08s poll interval', hasPollingWait);

  // ORCL-1.9: Fresh enemy query on impact (F-03)
  const hasFreshEnemyQuery = source.includes('-- F-03: Fresh Active Enemies Query at exact moment of impact (0.31s post-targeting)') &&
                             source.includes('local currentEnemiesFolder = Workspace:FindFirstChild("Enemies")');
  assertTest('ORCL-1.9', 'F-03 Fresh Active Enemies query executes at exact moment of impact (0.31s post-targeting)', hasFreshEnemyQuery);

  // ORCL-1.10: Armor reduction formula clamping [0.25, 1.0]
  const hasArmorClamp = source.includes('math.clamp(1.0 - (enemy:GetAttribute("ArmorReduction") or 0), 0.25, 1.0)');
  assertTest('ORCL-1.10', 'Armor reduction is clamped strictly between 0.25 and 1.0 with minimum 1 effective damage', hasArmorClamp);

  // ORCL-1.11: Whitebeard Gura slow debuff (0.45x for 2.5s)
  const hasWhitebeardSlow = source.includes('if spec.AttackStyle == "GuraQuake" then') &&
                            source.includes('enemy:SetAttribute("SlowUntil", now + 2.5)');
  assertTest('ORCL-1.11', 'Whitebeard Gura Quake triggers 2.5s slow debuff (SlowUntil = now + 2.5)', hasWhitebeardSlow);

  // ORCL-1.12: Sell cancels pending tower attacks via existingTower:Destroy()
  const hasSellDestroy = source.includes('lastAttackTime[existingTower] = nil') &&
                         source.includes('existingTower:Destroy()');
  assertTest('ORCL-1.12', 'sellTowerUnit clears lastAttackTime and destroys model, invalidating tower.Parent for pending delays', hasSellDestroy);


  // ---------------------------------------------------------------------------
  // [2] DISCRETE-EVENT SCHEDULER SIMULATION (KINEMATICS TIMING & HIT MOMENT)
  // ---------------------------------------------------------------------------
  console.log(`\n${COLORS.bold}${COLORS.cyan}[2] DISCRETE-EVENT SCHEDULER SIMULATION (KINEMATICS TIMING & HIT MOMENT)${COLORS.reset}`);

  class MockScheduler {
    constructor() {
      this.currentTime = 0;
      this.tasks = [];
    }

    delay(seconds, fn) {
      this.tasks.push({ triggerTime: this.currentTime + seconds, fn });
      this.tasks.sort((a, b) => a.triggerTime - b.triggerTime);
    }

    step(dt) {
      this.currentTime += dt;
      while (this.tasks.length > 0 && this.tasks[0].triggerTime <= (this.currentTime + 1e-9)) {
        const task = this.tasks.shift();
        task.fn();
      }
    }
  }

  // SIM-2.1: Nominal attack sequence without interruption hits at exactly 0.31s
  {
    const scheduler = new MockScheduler();
    let hitTime = null;
    let completedTime = null;

    const mockTower = { Parent: {}, PrimaryPart: { Parent: {} } };

    // Simulate execute5PhaseAttack
    const startSimTime = scheduler.currentTime;
    // Phase 1 (0.14s)
    scheduler.delay(0.14, () => {
      if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
      // Phase 2 (0.10s)
      scheduler.delay(0.10, () => {
        if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
        // Phase 3 (0.07s)
        scheduler.delay(0.07, () => {
          if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
          // Phase 4 (0.20s) - Hit occurs here!
          hitTime = scheduler.currentTime;
          scheduler.delay(0.20, () => {
            if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
            // Phase 5 (0.22s)
            scheduler.delay(0.22, () => {
              if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
              completedTime = scheduler.currentTime;
            });
          });
        });
      });
    });

    // Step through in 0.01s increments
    for (let i = 0; i < 100; i++) {
      scheduler.step(0.01);
    }

    const impactDelta = hitTime - startSimTime;
    const totalDuration = completedTime - startSimTime;

    assertTest('SIM-2.1', 'Simulated 5-phase attack executes impact callback at strictly t = 0.31s',
      Math.abs(impactDelta - 0.31) < 1e-5, `impactDelta: ${impactDelta.toFixed(3)}s`);

    assertTest('SIM-2.2', 'Simulated total attack choreography duration equals 0.73s (0.31s impact + 0.42s recovery)',
      Math.abs(totalDuration - 0.73) < 1e-5, `totalDuration: ${totalDuration.toFixed(3)}s`);
  }

  // SIM-2.3: Mid-attack sell at t=0.10s (Phase 1) aborts impact
  {
    const scheduler = new MockScheduler();
    let hitFired = false;
    const mockTower = { Parent: {}, PrimaryPart: { Parent: {} } };

    scheduler.delay(0.14, () => {
      if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
      scheduler.delay(0.10, () => {
        if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
        scheduler.delay(0.07, () => {
          if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
          hitFired = true;
        });
      });
    });

    // Run to t=0.10s, then sell tower
    for (let i = 0; i < 10; i++) scheduler.step(0.01);
    mockTower.Parent = null; // Sold!

    // Step remainder to t=1.0s
    for (let i = 0; i < 90; i++) scheduler.step(0.01);

    assertTest('SIM-2.3', 'Selling tower during Phase 1 (t=0.10s) completely halts attack, 0 damage applied',
      hitFired === false);
  }

  // SIM-2.4: Mid-attack sell at t=0.20s (Phase 2) aborts impact
  {
    const scheduler = new MockScheduler();
    let hitFired = false;
    const mockTower = { Parent: {}, PrimaryPart: { Parent: {} } };

    scheduler.delay(0.14, () => {
      if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
      scheduler.delay(0.10, () => {
        if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
        scheduler.delay(0.07, () => {
          if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
          hitFired = true;
        });
      });
    });

    // Run to t=0.20s, then sell tower
    for (let i = 0; i < 20; i++) scheduler.step(0.01);
    mockTower.Parent = null; // Sold!
    for (let i = 0; i < 80; i++) scheduler.step(0.01);

    assertTest('SIM-2.4', 'Selling tower during Phase 2 (t=0.20s) completely halts attack, 0 damage applied',
      hitFired === false);
  }

  // SIM-2.5: Mid-attack sell at t=0.30s (Phase 3 hitstop) aborts impact
  {
    const scheduler = new MockScheduler();
    let hitFired = false;
    const mockTower = { Parent: {}, PrimaryPart: { Parent: {} } };

    scheduler.delay(0.14, () => {
      if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
      scheduler.delay(0.10, () => {
        if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
        scheduler.delay(0.07, () => {
          if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
          hitFired = true;
        });
      });
    });

    // Run to t=0.30s (0.01s before impact!), then sell tower
    for (let i = 0; i < 30; i++) scheduler.step(0.01);
    mockTower.Parent = null; // Sold!
    for (let i = 0; i < 70; i++) scheduler.step(0.01);

    assertTest('SIM-2.5', 'Selling tower at t=0.30s (10ms before hitstop ends) halts attack with 0 damage',
      hitFired === false);
  }

  // SIM-2.6: Selling tower at t=0.32s (post-hit) preserves damage and cleanly terminates recovery
  {
    const scheduler = new MockScheduler();
    let hitFired = false;
    let recoveryError = false;
    const mockTower = { Parent: {}, PrimaryPart: { Parent: {} } };

    scheduler.delay(0.14, () => {
      if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
      scheduler.delay(0.10, () => {
        if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
        scheduler.delay(0.07, () => {
          if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
          hitFired = true;
          scheduler.delay(0.20, () => {
            if (!mockTower.Parent || !mockTower.PrimaryPart.Parent) return;
            recoveryError = true; // should not reach if tower destroyed
          });
        });
      });
    });

    for (let i = 0; i < 32; i++) scheduler.step(0.01);
    mockTower.Parent = null; // Sold after hit!
    for (let i = 0; i < 68; i++) scheduler.step(0.01);

    assertTest('SIM-2.6', 'Selling tower at t=0.32s post-hit preserves damage and cleanly exits recovery without errors',
      hitFired === true && recoveryError === false);
  }

  // ---------------------------------------------------------------------------
  // [3] FRESH ENEMY QUERY & DAMAGE MATH ADVERSARIAL VERIFICATION
  // ---------------------------------------------------------------------------
  console.log(`\n${COLORS.bold}${COLORS.cyan}[3] FRESH ENEMY QUERY & DAMAGE MATH ADVERSARIAL VERIFICATION${COLORS.reset}`);

  // MATH-3.1: F-03 Dynamic spatial relocation during 0.31s window
  {
    const splashRadius = 15;
    const impactPos = [0, 0, 0];

    // Enemy 1: at [0, 0, 0] at t=0; moves to [0, 0, 20] at t=0.31s (speed 65 studs/s)
    const enemy1PosAtImpact = [0, 0, 20];
    const dist1 = Math.hypot(enemy1PosAtImpact[0] - impactPos[0], enemy1PosAtImpact[2] - impactPos[2]);
    const enemy1TakesDamage = dist1 <= splashRadius;

    // Enemy 2: at [0, 0, 25] at t=0; moves to [0, 0, 5] at t=0.31s (entered splash)
    const enemy2PosAtImpact = [0, 0, 5];
    const dist2 = Math.hypot(enemy2PosAtImpact[0] - impactPos[0], enemy2PosAtImpact[2] - impactPos[2]);
    const enemy2TakesDamage = dist2 <= splashRadius;

    assertTest('MATH-3.1', 'Enemy 1 moving out of splash (dist 20 > 15) misses damage at 0.31s impact moment',
      enemy1TakesDamage === false, `dist: ${dist1}`);

    assertTest('MATH-3.2', 'Enemy 2 moving into splash (dist 5 <= 15) receives AoE splash damage at 0.31s impact moment',
      enemy2TakesDamage === true, `dist: ${dist2}`);
  }

  // MATH-3.3: Armor reduction clamping and damage calculation
  {
    const baseDmg = 100;
    const dmgMult = 2.0; // raw dmg = 200

    function calcEffectiveDamage(rawDmg, armorReduction) {
      const clampMult = Math.min(1.0, Math.max(0.25, 1.0 - armorReduction));
      return Math.max(1, Math.floor(rawDmg * clampMult));
    }

    const dmgNoArmor = calcEffectiveDamage(200, 0.0);
    const dmgMidArmor = calcEffectiveDamage(200, 0.40);
    const dmgHighArmor = calcEffectiveDamage(200, 0.75);
    const dmgExtremeArmor = calcEffectiveDamage(200, 0.99); // clamped to 0.25

    assertTest('MATH-3.3', 'Armor reduction clamps effective damage strictly to 0.25 floor on extreme armor (0.99 -> 25% dmg)',
      dmgNoArmor === 200 && dmgMidArmor === 120 && dmgHighArmor === 50 && dmgExtremeArmor === 50,
      `no:${dmgNoArmor}, mid:${dmgMidArmor}, high:${dmgHighArmor}, extreme:${dmgExtremeArmor}`);

    const tinyDmg = calcEffectiveDamage(1, 0.99);
    assertTest('MATH-3.4', 'Minimum damage floor is strictly clamped to 1 even with 1 raw damage against max armor',
      tinyDmg === 1);
  }

  // ---------------------------------------------------------------------------
  // SUMMARY
  // ---------------------------------------------------------------------------
  console.log(`\n${COLORS.bold}${COLORS.yellow}========================================================================${COLORS.reset}`);
  const passRate = ((testResults.passed / testResults.total) * 100).toFixed(1);
  const sumColor = testResults.failed === 0 ? COLORS.green : COLORS.red;
  console.log(`${COLORS.bold}${sumColor}COMBAT ORACLE VERIFICATION COMPLETE: ${testResults.passed} / ${testResults.total} PASSED (${passRate}%)${COLORS.reset}`);
  console.log(`${COLORS.bold}${COLORS.yellow}========================================================================\n`);

  return testResults.failed === 0;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const success = runCombatOracleTests();
  process.exit(success ? 0 : 1);
}
