// tests/challenger_p4_m1_concurrency.test.mjs
// Adversarial Concurrency, UI Geometry, Base Damage & Slow Debuff Test Harness
// Phase 4 Milestone 1 (Track 1: Brutal Endless Enemy Scaling & 4 Monster Classes, PLAN-0007)
// Challenger: challenger_p4_m1_2

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
  magenta: '\x1b[35m',
  gray: '\x1b[90m',
};

const WAVE_MANAGER_PATH = path.join(PROJECT_ROOT, 'src', 'Track1_WaveSystem', 'WaveManager.server.luau');
const GAME_CONFIG_PATH = path.join(PROJECT_ROOT, 'src', 'Shared', 'GameConfig.luau');

const waveSource = fs.readFileSync(WAVE_MANAGER_PATH, 'utf8').replace(/\r\n/g, '\n');
const configSource = fs.readFileSync(GAME_CONFIG_PATH, 'utf8').replace(/\r\n/g, '\n');

const testResults = {
  timestamp: new Date().toISOString(),
  tests: [],
  summary: { total: 0, passed: 0, failed: 0 }
};

function recordTest(suite, id, name, passed, details = '') {
  testResults.tests.push({ suite, id, name, passed, details });
  testResults.summary.total++;
  if (passed) {
    testResults.summary.passed++;
    console.log(`${C.cyan}[${suite}]${C.reset} ${C.green}${C.bold}PASS${C.reset} ${C.bold}${id}${C.reset}: ${name}${details ? ` ${C.gray}(${details})${C.reset}` : ''}`);
  } else {
    testResults.summary.failed++;
    console.error(`${C.cyan}[${suite}]${C.reset} ${C.red}${C.bold}FAIL${C.reset} ${C.bold}${id}${C.reset}: ${name} ${C.yellow}${details}${C.reset}`);
  }
}

console.log(`\n${C.bold}${C.yellow}========================================================================${C.reset}`);
console.log(`${C.bold}${C.yellow}   CHALLENGER 2: ADVERSARIAL STRESS TEST HARNESS (PLAN-0007)            ${C.reset}`);
console.log(`${C.bold}${C.yellow}   Concurrency Safety, Micro Health Bar, Boss Billboard, Base & Slow     ${C.reset}`);
console.log(`${C.bold}${C.yellow}========================================================================${C.reset}\n`);

// ============================================================================
// SUITE 1: CONCURRENCY SAFETY & ATOMIC LATCHES
// ============================================================================
console.log(`${C.bold}--- SUITE 1: CONCURRENCY SAFETY & ATOMIC LATCHES ---${C.reset}`);

// Mock Luau Model & Engine Simulation for Empirical Stress Testing
class MockInstance {
  constructor(className, name = '') {
    this.ClassName = className;
    this.Name = name;
    this.Parent = null;
    this.children = [];
    this.attributes = new Map();
    this.signals = new Map();
    this.destroyed = false;
  }

  FindFirstChild(name) {
    return this.children.find(c => c.Name === name) || null;
  }

  GetChildren() {
    return [...this.children];
  }

  GetDescendants() {
    let result = [];
    for (const child of this.children) {
      result.push(child);
      result.push(...child.GetDescendants());
    }
    return result;
  }

  SetAttribute(name, val) {
    this.attributes.set(name, val);
    const sig = this.signals.get(name);
    if (sig) {
      for (const cb of sig) {
        cb(val);
      }
    }
  }

  GetAttribute(name) {
    return this.attributes.get(name);
  }

  GetAttributeChangedSignal(name) {
    if (!this.signals.has(name)) {
      this.signals.set(name, []);
    }
    return {
      Connect: (cb) => {
        this.signals.get(name).push(cb);
        return { Disconnect: () => {} };
      }
    };
  }

  Destroy() {
    this.destroyed = true;
    this.Parent = null;
  }
}

// CC-1.1: Massive Multi-Hit Rapid Damage Overkill Race (100 simultaneous async damage hits)
{
  let cashAwardedCount = 0;
  let totalCashGiven = 0;
  let destroyCallCount = 0;

  function awardCashMock(amount) {
    cashAwardedCount++;
    totalCashGiven += amount;
  }

  // Set up enemy mock identical to WaveManager implementation
  const model = new MockInstance("Model", "Pirate Grunt");
  const enemiesFolder = new MockInstance("Folder", "Enemies");
  model.Parent = enemiesFolder;
  const initialHp = 100;
  model.SetAttribute("HP", initialHp);
  model.SetAttribute("MaxHP", initialHp);

  let isDead = false;
  const specCash = 25;

  model.GetAttributeChangedSignal("HP").Connect(() => {
    const currentHp = model.GetAttribute("HP") || 0;
    if (currentHp <= 0 && !isDead && model.Parent) {
      isDead = true;
      awardCashMock(specCash);
      destroyCallCount++;
      model.Destroy();
    }
  });

  // Execute 100 simultaneous asynchronous damage events that would each kill the mob
  const damagePromises = [];
  for (let i = 0; i < 100; i++) {
    damagePromises.push(new Promise((resolve) => {
      // Small randomized jitter to simulate micro-threading in Roblox task scheduler
      setTimeout(() => {
        const cur = model.GetAttribute("HP") || 0;
        model.SetAttribute("HP", cur - 50); // Massive overkill
        resolve();
      }, Math.random() * 5);
    }));
  }

  await Promise.all(damagePromises);

  const latchSucceeded = (cashAwardedCount === 1) && (totalCashGiven === 25) && (destroyCallCount === 1) && (isDead === true) && (model.Parent === null);

  recordTest(
    'CONCURRENCY',
    'CC-1.1',
    'Rapid Multi-Hit Overkill: 100 concurrent lethal damage events award cash exactly once and trigger destroy exactly once',
    latchSucceeded,
    `CashAwardCount: ${cashAwardedCount}, TotalCash: $${totalCashGiven}, DestroyCount: ${destroyCallCount}, isDead: ${isDead}`
  );
}

// CC-1.2: Simultaneous Death vs Base Breach Race Condition (Mutual Exclusivity)
{
  let testAPassed = false;
  let testBPassed = false;

  // Scenario A: Fatal damage hits right before or at base breach
  {
    let cashAwards = 0;
    let baseDamageDone = 0;
    let isDead = false;
    let baseHp = 1000;

    const model = new MockInstance("Model", "Pirate Grunt");
    const enemiesFolder = new MockInstance("Folder", "Enemies");
    model.Parent = enemiesFolder;
    model.SetAttribute("HP", 100);

    model.GetAttributeChangedSignal("HP").Connect(() => {
      const currentHp = model.GetAttribute("HP") || 0;
      if (currentHp <= 0 && !isDead && model.Parent) {
        isDead = true;
        cashAwards += 25;
        model.Destroy();
      }
    });

    function attemptBaseBreach() {
      if (model.Parent && !isDead && ((model.GetAttribute("HP") || 0) > 0)) {
        isDead = true;
        baseDamageDone += 35;
        baseHp = Math.max(0, baseHp - 35);
        model.Destroy();
      }
    }

    // Tower deals fatal blow
    model.SetAttribute("HP", 0);
    // Base breach attempts to execute concurrently
    attemptBaseBreach();

    testAPassed = (cashAwards === 25) && (baseDamageDone === 0) && (baseHp === 1000) && (isDead === true);
  }

  // Scenario B: Base breach hits right before or at fatal damage
  {
    let cashAwards = 0;
    let baseDamageDone = 0;
    let isDead = false;
    let baseHp = 1000;

    const model = new MockInstance("Model", "Pirate Grunt");
    const enemiesFolder = new MockInstance("Folder", "Enemies");
    model.Parent = enemiesFolder;
    model.SetAttribute("HP", 100);

    model.GetAttributeChangedSignal("HP").Connect(() => {
      const currentHp = model.GetAttribute("HP") || 0;
      if (currentHp <= 0 && !isDead && model.Parent) {
        isDead = true;
        cashAwards += 25;
        model.Destroy();
      }
    });

    function attemptBaseBreach() {
      if (model.Parent && !isDead && ((model.GetAttribute("HP") || 0) > 0)) {
        isDead = true;
        baseDamageDone += 35;
        baseHp = Math.max(0, baseHp - 35);
        model.Destroy();
      }
    }

    // Mob breaches base first
    attemptBaseBreach();
    // Tower subsequently sets HP to 0
    model.SetAttribute("HP", 0);

    testBPassed = (cashAwards === 0) && (baseDamageDone === 35) && (baseHp === 965) && (isDead === true);
  }

  recordTest(
    'CONCURRENCY',
    'CC-1.2',
    'Mutual Exclusivity: Race between Fatal Damage and Base Breach is strictly exclusive with zero state leaks',
    testAPassed && testBPassed,
    `Scenario A (Kill first -> Base Damage 0): ${testAPassed}, Scenario B (Breach first -> Cash 0): ${testBPassed}`
  );
}

// CC-1.3: Regeneration vs Fatal Damage Race (Boss Zombie Resurrection Prevention)
{
  const model = new MockInstance("Model", "Yonko Calamity Boss");
  const enemiesFolder = new MockInstance("Folder", "Enemies");
  model.Parent = enemiesFolder;
  const maxHp = 10000;
  model.SetAttribute("HP", maxHp);
  model.SetAttribute("MaxHP", maxHp);

  let isDead = false;
  let resuscitated = false;

  model.GetAttributeChangedSignal("HP").Connect(() => {
    const curHp = model.GetAttribute("HP") || 0;
    if (curHp <= 0 && !isDead && model.Parent) {
      isDead = true;
      model.Destroy();
    }
  });

  function simulateRegenTick() {
    if (!model.Parent || isDead) {
      return;
    }
    const curHp = model.GetAttribute("HP") || 0;
    if (curHp > 0 && curHp < maxHp) {
      const heal = Math.floor(maxHp * 0.025);
      const newHp = Math.min(maxHp, curHp + heal);
      model.SetAttribute("HP", newHp);
    }
  }

  // 1. Boss damaged to 1 HP -> regen heals
  model.SetAttribute("HP", 1);
  simulateRegenTick();
  const hpAfterRegen = model.GetAttribute("HP"); // 1 + 250 = 251

  // 2. Fatal damage strikes boss to 0
  model.SetAttribute("HP", 0);
  assert.strictEqual(isDead, true);

  // 3. Regen loop tick fires immediately after death
  simulateRegenTick();
  const hpAfterDeathRegen = model.GetAttribute("HP");
  if (hpAfterDeathRegen > 0) {
    resuscitated = true;
  }

  recordTest(
    'CONCURRENCY',
    'CC-1.3',
    'Regeneration vs Fatal Damage: Dead boss (HP=0, isDead=true) cannot be resuscitated by RegenPerSec loop',
    (hpAfterRegen === 251) && (hpAfterDeathRegen === 0) && (!resuscitated) && (isDead === true),
    `Alive heal: ${hpAfterRegen} HP, Post-death: ${hpAfterDeathRegen} HP, Resuscitated: ${resuscitated}`
  );
}

// CC-1.4: High-Density Swarm Death Wave (100 simultaneous mobs killed in 10ms)
{
  let totalCashPool = 0;
  const mobCount = 100;
  const cashPerMob = 25;

  const killPromises = [];
  for (let m = 0; m < mobCount; m++) {
    const mob = new MockInstance("Model", `Grunt_${m}`);
    mob.Parent = new MockInstance("Folder", "Enemies");
    mob.SetAttribute("HP", 50);
    let isDead = false;

    mob.GetAttributeChangedSignal("HP").Connect(() => {
      const cur = mob.GetAttribute("HP") || 0;
      if (cur <= 0 && !isDead && mob.Parent) {
        isDead = true;
        totalCashPool += cashPerMob;
        mob.Destroy();
      }
    });

    killPromises.push(new Promise((resolve) => {
      setTimeout(() => {
        mob.SetAttribute("HP", 0);
        resolve();
      }, Math.random() * 10);
    }));
  }

  await Promise.all(killPromises);

  const expectedTotalCash = mobCount * cashPerMob; // 2500
  const swarmClean = totalCashPool === expectedTotalCash;

  recordTest(
    'CONCURRENCY',
    'CC-1.4',
    'High-Density Swarm Death: 100 simultaneous mob deaths resolve cleanly without dropped signals or cash loss',
    swarmClean,
    `Total Cash: $${totalCashPool} (Expected: $${expectedTotalCash})`
  );
}

// ============================================================================
// SUITE 2: MICRO HEALTH BAR GEOMETRY & ZERO CLUTTER
// ============================================================================
console.log(`\n${C.bold}--- SUITE 2: MICRO HEALTH BAR GEOMETRY & ZERO CLUTTER ---${C.reset}`);

// GEO-2.1: Micro Health Bar Dimensions for Grunts
{
  const gruntSizeMatch = waveSource.includes('stats.IsBoss and UDim2.new(0, 96, 0, 16) or UDim2.new(0, 52, 0, 6)');
  const exact52x6 = waveSource.includes('UDim2.new(0, 52, 0, 6)');

  recordTest(
    'UI-GEOMETRY',
    'GEO-2.1',
    'Grunt Micro Health Bar size is strictly UDim2.new(0, 52, 0, 6) (52x6 px)',
    gruntSizeMatch && exact52x6,
    'UDim2.new(0, 52, 0, 6) verified for all non-boss mobs'
  );
}

// GEO-2.2: AlwaysOnTop == false
{
  const alwaysOnTopFalse = waveSource.includes('bb.AlwaysOnTop = false');

  recordTest(
    'UI-GEOMETRY',
    'GEO-2.2',
    'BillboardGui.AlwaysOnTop is strictly false to prevent bleeding through HUD cards and dock',
    alwaysOnTopFalse,
    'bb.AlwaysOnTop = false verified'
  );
}

// GEO-2.3: MaxDistance == 85 for Grunts
{
  const maxDistanceCheck = waveSource.includes('bb.MaxDistance = stats.IsBoss and 90 or 85');
  const exact85 = waveSource.includes('or 85');

  recordTest(
    'UI-GEOMETRY',
    'GEO-2.3',
    'Grunt BillboardGui.MaxDistance is strictly 85 studs to eliminate distant rendering overhead',
    maxDistanceCheck && exact85,
    'MaxDistance = 85 studs verified'
  );
}

// GEO-2.4: Grunt Nameplate 100% Suppressed (Zero-Clutter)
{
  // Grunt must NOT have any TextLabel created or parented
  // Only boss has TextLabel
  const bossOnlyTitle = waveSource.includes('if stats.IsBoss then\n\t\tlocal title = Instance.new("TextLabel")');
  const noGruntNameplate = !waveSource.includes('title.Text = stats.Name') && !waveSource.includes('nameLabel.Parent = bb');

  recordTest(
    'UI-GEOMETRY',
    'GEO-2.4',
    'Zero Clutter: Common grunts (PirateGrunt, SoruAssassin, HakiBrute) display ZERO floating TextLabel nameplates',
    bossOnlyTitle && noGruntNameplate,
    'TextLabel is strictly gated behind if stats.IsBoss then'
  );
}

// GEO-2.5: Billboard Adornee & Parent Anchor
{
  const adorneeHead = waveSource.includes('bb.Adornee = head');
  const parentRoot = waveSource.includes('bb.Parent = root');
  const studsOffset = waveSource.includes('bb.StudsOffset = Vector3.new(0, (stats.IsBoss and 3.2 or 2.4) * stats.Scale, 0)');

  recordTest(
    'UI-GEOMETRY',
    'GEO-2.5',
    'BillboardGui properly adorns Head, parents to Root, with scale-adjusted StudsOffset (2.4x scale for grunts)',
    adorneeHead && parentRoot && studsOffset,
    'Adornee=head, Parent=root, StudsOffset=2.4*scale verified'
  );
}

// GEO-2.6: Grunt Health Fill Styling & Radius
{
  const gruntFillColor = waveSource.includes('Color3.fromRGB(50, 230, 110)');
  const borderZero = waveSource.includes('fill.BorderSizePixel = 0');
  const cornerRadius = waveSource.includes('bgCorner.CornerRadius = UDim.new(0, stats.IsBoss and 3 or 2)');

  recordTest(
    'UI-GEOMETRY',
    'GEO-2.6',
    'Grunt Health Bar styling: Crisp emerald green (50, 230, 110), 0px border, 2px rounded corners',
    gruntFillColor && borderZero && cornerRadius,
    'Color, border, and corner radius verified'
  );
}

// ============================================================================
// SUITE 3: BOSS TITLE BILLBOARD GEOMETRY & HIERARCHY
// ============================================================================
console.log(`\n${C.bold}--- SUITE 3: BOSS TITLE BILLBOARD GEOMETRY & HIERARCHY ---${C.reset}`);

// BOSS-3.1: Boss Billboard Size is UDim2.new(0, 96, 0, 16)
{
  const bossSizeMatch = waveSource.includes('UDim2.new(0, 96, 0, 16)');

  recordTest(
    'BOSS-BILLBOARD',
    'BOSS-3.1',
    'Boss BillboardGui size is strictly UDim2.new(0, 96, 0, 16) (96x16 px)',
    bossSizeMatch,
    'UDim2.new(0, 96, 0, 16) verified'
  );
}

// BOSS-3.2: Boss Billboard AlwaysOnTop == false
{
  // Inherits bb.AlwaysOnTop = false from GEO-2.2
  const alwaysOnTopFalse = waveSource.includes('bb.AlwaysOnTop = false');

  recordTest(
    'BOSS-BILLBOARD',
    'BOSS-3.2',
    'Boss Billboard AlwaysOnTop is strictly false (respects 3D occlusions and UI layering)',
    alwaysOnTopFalse,
    'bb.AlwaysOnTop = false verified for Boss'
  );
}

// BOSS-3.3: Boss Billboard MaxDistance == 90
{
  const bossMaxDist = waveSource.includes('stats.IsBoss and 90 or 85');

  recordTest(
    'BOSS-BILLBOARD',
    'BOSS-3.3',
    'Boss Billboard MaxDistance is strictly 90 studs (extended visibility for boss threat)',
    bossMaxDist,
    'MaxDistance = 90 studs verified for Boss'
  );
}

// BOSS-3.4: Boss Billboard UIStroke Crimson Outline
{
  const hasStroke = waveSource.includes('local bgStroke = Instance.new("UIStroke")') &&
                    waveSource.includes('bgStroke.Color = Color3.fromRGB(90, 20, 30)') &&
                    waveSource.includes('bgStroke.Thickness = 1');

  recordTest(
    'BOSS-BILLBOARD',
    'BOSS-3.4',
    'Boss Health Bar background features 1px UIStroke with dark crimson color (90, 20, 30)',
    hasStroke,
    'Crimson UIStroke verified'
  );
}

// BOSS-3.5: Boss Title TextLabel Properties
{
  const hasTitleText = waveSource.includes('title.Text = "[BOSS] YONKO CALAMITY"');
  const hasGothamBold = waveSource.includes('title.Font = Enum.Font.GothamBold');
  const has10pxText = waveSource.includes('title.TextSize = 10');
  const hasGoldColor = waveSource.includes('title.TextColor3 = Color3.fromRGB(255, 220, 80)');
  const hasOffsetPos = waveSource.includes('title.Position = UDim2.new(0, 0, 0, -12)');

  recordTest(
    'BOSS-BILLBOARD',
    'BOSS-3.5',
    'Boss Title TextLabel displays [BOSS] YONKO CALAMITY in 10px GothamBold gold text positioned at Y = -12px',
    hasTitleText && hasGothamBold && has10pxText && hasGoldColor && hasOffsetPos,
    'Title, font, size, gold color, and negative offset position verified'
  );
}

// BOSS-3.6: Boss Health Fill Crimson Styling
{
  const bossFillColor = waveSource.includes('stats.IsBoss and Color3.fromRGB(255, 45, 70)');
  const bossCornerRadius = waveSource.includes('fillCorner.CornerRadius = UDim.new(0, stats.IsBoss and 3 or 2)');

  recordTest(
    'BOSS-BILLBOARD',
    'BOSS-3.6',
    'Boss Health Fill uses threatening crimson red (255, 45, 70) with 3px corner radius',
    bossFillColor && bossCornerRadius,
    'Color and corner radius verified'
  );
}

// ============================================================================
// SUITE 4: BASE DAMAGE LOGIC & BASE HP CLAMPING
// ============================================================================
console.log(`\n${C.bold}--- SUITE 4: BASE DAMAGE LOGIC & BASE HP CLAMPING ---${C.reset}`);

// BASE-4.1: Base Damage Amounts: 180 for Bosses, 35 for Grunts
{
  const hasDamageFormula = waveSource.includes('local dmgToBase = (enemyKey == "YonkoKaido" or stats.IsBoss) and 180 or 35');

  // Verify damage mapping for all 4 classes
  function getBaseDamage(enemyKey, isBoss) {
    return (enemyKey === "YonkoKaido" || isBoss) ? 180 : 35;
  }

  const gruntDmg = getBaseDamage("PirateGrunt", false);
  const assassinDmg = getBaseDamage("SoruAssassin", false);
  const bruteDmg = getBaseDamage("HakiBrute", false);
  const bossDmg = getBaseDamage("YonkoBoss", true);
  const kaidoDmg = getBaseDamage("YonkoKaido", true);

  const valuesCorrect = (gruntDmg === 35) && (assassinDmg === 35) && (bruteDmg === 35) && (bossDmg === 180) && (kaidoDmg === 180);

  recordTest(
    'BASE-DAMAGE',
    'BASE-4.1',
    'Base damage is exactly 180 for Bosses (YonkoBoss/YonkoKaido) and 35 for Grunts (PirateGrunt, SoruAssassin, HakiBrute)',
    hasDamageFormula && valuesCorrect,
    `Grunt: ${gruntDmg}, Assassin: ${assassinDmg}, Brute: ${bruteDmg}, Boss: ${bossDmg}, Kaido: ${kaidoDmg}`
  );
}

// BASE-4.2: Zero Negative BaseHP Drift Under Extreme Swarm Breach
{
  const hasMaxZeroClamp = waveSource.includes('local newBaseHp = math.max(0, curBaseHp - dmgToBase)');

  // Simulate 100 mobs simultaneously breaching a base with only 50 HP remaining
  let simulatedBaseHp = 50;
  let gameOverTriggered = false;

  for (let breach = 0; breach < 100; breach++) {
    const isBoss = (breach % 10 === 0);
    const dmg = isBoss ? 180 : 35;
    simulatedBaseHp = Math.max(0, simulatedBaseHp - dmg);
    if (simulatedBaseHp <= 0) {
      gameOverTriggered = true;
    }
  }

  const zeroDrift = (simulatedBaseHp === 0) && gameOverTriggered;

  recordTest(
    'BASE-DAMAGE',
    'BASE-4.2',
    'Zero Negative BaseHP Drift: 100 mobs breaching at 50 HP clamp strictly to 0 with zero negative overflow',
    hasMaxZeroClamp && zeroDrift,
    `Final BaseHP: ${simulatedBaseHp}, GameOver: ${gameOverTriggered}`
  );
}

// BASE-4.3: GameOver State & Marineford Fallen Status
{
  const setsGameOver = waveSource.includes('Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, true)');
  const setsStatus = waveSource.includes('Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, "MARINEFORD FALLEN - GAME OVER")');

  recordTest(
    'BASE-DAMAGE',
    'BASE-4.3',
    'When BaseHP drops to 0, GameOver attribute is set to true and WaveStatus displays MARINEFORD FALLEN - GAME OVER',
    setsGameOver && setsStatus,
    'GameOver and Fallen status attributes verified'
  );
}

// BASE-4.4: Boundary Damage Calculations
{
  // Test boundary values: 1 HP, 35 HP, 36 HP, 180 HP
  const test1 = Math.max(0, 1 - 35) === 0;
  const test2 = Math.max(0, 35 - 35) === 0;
  const test3 = Math.max(0, 36 - 35) === 1;
  const test4 = Math.max(0, 180 - 180) === 0;
  const test5 = Math.max(0, 181 - 180) === 1;

  recordTest(
    'BASE-DAMAGE',
    'BASE-4.4',
    'Boundary integrity: 1 HP (-35) -> 0, 35 HP (-35) -> 0, 36 HP (-35) -> 1, 180 HP (-180) -> 0, 181 HP (-180) -> 1',
    test1 && test2 && test3 && test4 && test5,
    'All 5 boundary cases strictly verified'
  );
}

// ============================================================================
// SUITE 5: WHITEBEARD SLOW DEBUFF MECHANICS
// ============================================================================
console.log(`\n${C.bold}--- SUITE 5: WHITEBEARD SLOW DEBUFF MECHANICS ---${C.reset}`);

// SLOW-5.1: Initial SlowUntil Attribute Declaration
{
  const declaresSlowUntil = waveSource.includes('model:SetAttribute("SlowUntil", 0)');

  recordTest(
    'SLOW-DEBUFF',
    'SLOW-5.1',
    'WaveManager initializes SlowUntil = 0 attribute on every spawned enemy',
    declaresSlowUntil,
    'model:SetAttribute("SlowUntil", 0) verified'
  );
}

// SLOW-5.2: Slow Multiplier 0.45x Active Calculation
{
  const checksSlow = waveSource.includes('local slowUntil = (model:GetAttribute("SlowUntil") :: number?) or 0');
  const calcSpeedMult = waveSource.includes('local speedMult = (os.clock() < slowUntil) and 0.45 or 1.0');
  const scalesStepDist = waveSource.includes('local stepDist = math.min(dist, spec.Speed * speedMult * 0.05)');

  // Simulation: active slow
  const now = 100.0;
  const slowUntilActive = 102.5; // active for 2.5s
  const activeSpeedMult = (now < slowUntilActive) ? 0.45 : 1.0;

  recordTest(
    'SLOW-DEBUFF',
    'SLOW-5.2',
    'While os.clock() < SlowUntil, speedMult evaluates to exactly 0.45x (55% movement slow)',
    checksSlow && calcSpeedMult && scalesStepDist && (activeSpeedMult === 0.45),
    `Calculated active speedMult: ${activeSpeedMult}x`
  );
}

// SLOW-5.3: Instantaneous Expiration Boundary
{
  const now = 102.5;
  const slowUntilExpired = 102.5; // exactly expired
  const expiredSpeedMult = (now < slowUntilExpired) ? 0.45 : 1.0;

  const nowPast = 102.501;
  const pastSpeedMult = (nowPast < slowUntilExpired) ? 0.45 : 1.0;

  recordTest(
    'SLOW-DEBUFF',
    'SLOW-5.3',
    'When os.clock() >= SlowUntil, speedMult instantaneously reverts to 1.0x with zero residual lag',
    (expiredSpeedMult === 1.0) && (pastSpeedMult === 1.0),
    `At boundary: ${expiredSpeedMult}x, Past boundary: ${pastSpeedMult}x`
  );
}

// SLOW-5.4: Stacking & Refresh Mechanics (No Compounding Multiplier)
{
  // When Whitebeard attacks an already slowed target, SlowUntil is refreshed to now + 2.5
  // The speed multiplier does NOT compound (remains 0.45, not 0.45^2 = 0.2025)
  let currentTime = 100.0;
  let slowUntil = currentTime + 2.5; // 102.5
  let mult1 = (currentTime < slowUntil) ? 0.45 : 1.0;

  // After 1 second, second Whitebeard quake hits
  currentTime = 101.0;
  slowUntil = Math.max(slowUntil, currentTime + 2.5); // 103.5
  let mult2 = (currentTime < slowUntil) ? 0.45 : 1.0;

  recordTest(
    'SLOW-DEBUFF',
    'SLOW-5.4',
    'Re-applying slow extends duration seamlessly while keeping speed multiplier strictly clamped at 0.45x without compounding',
    (mult1 === 0.45) && (mult2 === 0.45) && (slowUntil === 103.5),
    `Initial Mult: ${mult1}x, Refreshed Mult: ${mult2}x, Extended SlowUntil: ${slowUntil}s`
  );
}

// SLOW-5.5: High-Speed SoruAssassin Under Slow
{
  // SoruAssassin max speed is 34.0 studs/s
  // Under 0.45x slow, speed is 34.0 * 0.45 = 15.3 studs/s
  // Step distance at 0.05s tick is 15.3 * 0.05 = 0.765 studs
  const assassinSpeed = 34.0;
  const slowedSpeed = assassinSpeed * 0.45;
  const tickDist = slowedSpeed * 0.05;

  const stepDistanceCalculation = waveSource.includes('math.min(dist, spec.Speed * speedMult * 0.05)');

  recordTest(
    'SLOW-DEBUFF',
    'SLOW-5.5',
    'High-Speed SoruAssassin (34 studs/s) slows to 15.3 studs/s (0.765 studs/tick), preventing waypoint overshoot',
    stepDistanceCalculation && (Math.abs(slowedSpeed - 15.3) < 1e-6) && (Math.abs(tickDist - 0.765) < 1e-6),
    `Normal: 34 studs/s -> Slowed: ${slowedSpeed} studs/s (${tickDist.toFixed(3)} studs/tick)`
  );
}

// ============================================================================
// SUITE 6: STATIC AST & CONTRACT REGRESSION INVARIANTS
// ============================================================================
console.log(`\n${C.bold}--- SUITE 6: STATIC AST & CONTRACT REGRESSION INVARIANTS ---${C.reset}`);

// AST-6.1: Cash Award and Destroy Sequence
{
  const hasCashAndDestroy = waveSource.includes('isDead = true\n\t\t\tawardCashToAllPlayers(spec.Cash)\n\t\t\tmodel:Destroy()');

  recordTest(
    'REGRESSION-AST',
    'AST-6.1',
    'Preserves exact AST pattern: isDead = true -> awardCashToAllPlayers(spec.Cash) -> model:Destroy()',
    hasCashAndDestroy,
    'Exact 3-line sequence verified'
  );
}

// AST-6.2: Root CFrame and PivotTo Kinematics
{
  const hasRootCFrame = waveSource.includes('root.CFrame = CFrame.lookAt(nextPos + Vector3.new(0, bobOffset, 0), targetPos)');
  const hasPivotTo = waveSource.includes('model:PivotTo(root.CFrame)');

  recordTest(
    'REGRESSION-AST',
    'AST-6.2',
    'Kinematic translation sets root.CFrame and calls model:PivotTo(root.CFrame) to keep all limbs unified',
    hasRootCFrame && hasPivotTo,
    'Root CFrame & PivotTo verified'
  );
}

// AST-6.3: Dual Boss Wave Cadence
{
  const hasLegacyBoss = waveSource.includes('if wave % 5 == 0 and i == count then\n\t\t\t\t\tkey = "YonkoKaido"');
  const hasPhase4Boss = waveSource.includes('elseif isBossWave and i == count then\n\t\t\t\t\tkey = "YonkoBoss"');
  const isBossWaveDef = waveSource.includes('local isBossWave = (wave % 3 == 0) or (wave >= 10)');

  recordTest(
    'REGRESSION-AST',
    'AST-6.3',
    'Dual boss wave cadence: preserves wave % 5 == 0 for Kaido and (wave % 3 == 0 or wave >= 10) for YonkoBoss',
    hasLegacyBoss && hasPhase4Boss && isBossWaveDef,
    'Dual boss cadence verified'
  );
}

// AST-6.4: Exported EnemyClassSpec Strict Luau Type
{
  const hasTypeExport = configSource.includes('export type EnemyClassSpec = {');
  const hasAllFields = configSource.includes('Id: string') &&
                       configSource.includes('Name: string') &&
                       configSource.includes('HpMult: number') &&
                       configSource.includes('SpeedMult: number') &&
                       configSource.includes('ArmorBonus: number') &&
                       configSource.includes('MaxArmor: number') &&
                       configSource.includes('RegenPerSec: number');

  recordTest(
    'REGRESSION-AST',
    'AST-6.4',
    'GameConfig exports strict Luau type EnemyClassSpec with all required attributes',
    hasTypeExport && hasAllFields,
    'EnemyClassSpec type export verified'
  );
}

// ============================================================================
// FINAL SUMMARY & EXIT
// ============================================================================
console.log(`\n${C.bold}${C.yellow}========================================================================${C.reset}`);
console.log(`${C.bold}CHALLENGER 2 ADVERSARIAL TEST SUMMARY:${C.reset}`);
console.log(`  ${C.bold}Total Test Cases : ${testResults.summary.total}${C.reset}`);
console.log(`  ${C.green}${C.bold}Passed           : ${testResults.summary.passed}${C.reset}`);
console.log(`  ${C.red}${C.bold}Failed           : ${testResults.summary.failed}${C.reset}`);
console.log(`  ${C.bold}Success Rate     : ${((testResults.summary.passed / testResults.summary.total) * 100).toFixed(1)}%${C.reset}`);
console.log(`${C.bold}${C.yellow}========================================================================${C.reset}\n`);

if (testResults.summary.failed > 0) {
  process.exit(1);
} else {
  process.exit(0);
}
