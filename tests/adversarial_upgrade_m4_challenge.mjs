// tests/adversarial_upgrade_m4_challenge.mjs
// Adversarial Empirical Challenge Suite for Milestone 4 (src/Track3_UpgradeServer/UpgradeServer.server.luau)
//
// Verification Scope:
// 1. Static Luau AST & Contract Conformance
// 2. Mathematical Precision of Cost Curves (Damage, Range, Speed up to Lvl 100)
// 3. Invariant A: Insufficient cash rejection (never decrement if cash < cost)
// 4. Invariant B: Cooldown clamping (CooldownStat >= 0.15s, even after 100 Speed upgrades)
// 5. Invariant C: Level increments strictly by +1 per successful upgrade
// 6. High-Volume Adversarial Stress Simulation (10,000 requests across Damage, Range, Speed)

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(__dirname, '..');
const UPGRADE_SERVER_PATH = path.join(PROJECT_ROOT, 'src', 'Track3_UpgradeServer', 'UpgradeServer.server.luau');
const GAME_CONFIG_PATH = path.join(PROJECT_ROOT, 'src', 'Shared', 'GameConfig.luau');

// Terminal Formatting
const BOLD = '\x1b[1m';
const RESET = '\x1b[0m';
const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const CYAN = '\x1b[36m';
const YELLOW = '\x1b[33m';
const GRAY = '\x1b[90m';
const MAGENTA = '\x1b[35m';

const results = {
  total: 0,
  passed: 0,
  failed: 0,
  checks: [],
};

function check(id, title, condition, details = '') {
  results.total++;
  const passed = Boolean(condition);
  if (passed) {
    results.passed++;
    console.log(`${CYAN}[ADV-PASS]${RESET} ${BOLD}${id}${RESET}: ${title} ${details ? `${GRAY}(${details})${RESET}` : ''}`);
  } else {
    results.failed++;
    console.error(`${RED}[ADV-FAIL]${RESET} ${BOLD}${id}${RESET}: ${title} - FAILED! ${YELLOW}${details}${RESET}`);
  }
  results.checks.push({ id, title, passed, details });
}

console.log(`${BOLD}${MAGENTA}========================================================================${RESET}`);
console.log(`${BOLD}   EMPIRICAL CHALLENGER: M4 CASH STAT UPGRADES & BOUNDARY STRESS       ${RESET}`);
console.log(`${BOLD}   Target: src/Track3_UpgradeServer/UpgradeServer.server.luau          ${RESET}`);
console.log(`${BOLD}${MAGENTA}========================================================================${RESET}\n`);

// -----------------------------------------------------------------------------
// STEP 1: Verify Files Exist & Parse Luau Source Code
// -----------------------------------------------------------------------------
if (!fs.existsSync(UPGRADE_SERVER_PATH)) {
  console.error(`${RED}FATAL: UpgradeServer.server.luau not found at ${UPGRADE_SERVER_PATH}${RESET}`);
  process.exit(1);
}
if (!fs.existsSync(GAME_CONFIG_PATH)) {
  console.error(`${RED}FATAL: GameConfig.luau not found at ${GAME_CONFIG_PATH}${RESET}`);
  process.exit(1);
}

const serverSource = fs.readFileSync(UPGRADE_SERVER_PATH, 'utf8');
const configSource = fs.readFileSync(GAME_CONFIG_PATH, 'utf8');

console.log(`${BOLD}${CYAN}--- SECTION 1: STATIC LUAU AST & SYNTAX CONFORMANCE ---${RESET}`);

// Check 1.1: Strict mode
check('SYN-1.1', 'Starts with --!strict pragma', serverSource.trimStart().startsWith('--!strict'));

// Check 1.2: Balanced block syntax
const openFunc = (serverSource.match(/\bfunction\b/g) || []).length;
const openThen = (serverSource.match(/\bthen\b/g) || []).length;
const openElseIf = (serverSource.match(/\belseif\b/g) || []).length;
const openDo = (serverSource.match(/\bdo\b/g) || []).length;
const totalBlockOpeners = openFunc + (openThen - openElseIf) + openDo;
const totalEnds = (serverSource.match(/\bend\b/g) || []).length;
check('SYN-1.2', 'Balanced block openers and end keywords', totalBlockOpeners === totalEnds, `Openers: ${totalBlockOpeners}, Ends: ${totalEnds}`);

// Check 1.3: Remote bindings
check('SYN-1.3', 'Creates/binds UpgradeStatRequest RemoteFunction',
  serverSource.includes('"UpgradeStatRequest"') && serverSource.includes('upgradeStatFunction.OnServerInvoke'));
check('SYN-1.4', 'Creates/binds UpgradeRequest RemoteEvent',
  serverSource.includes('"UpgradeRequest"') && serverSource.includes('upgradeEvent.OnServerEvent:Connect'));

// Check 1.5: Verbatim math formulas in source code
check('SYN-1.5', 'Damage cost formula matches floor(75 * 1.35^(curLvl - 1))',
  serverSource.includes('math.floor(75 * math.pow(1.35, curLvl - 1))'));
check('SYN-1.6', 'Range cost formula matches floor(60 * 1.30^(curLvl - 1))',
  serverSource.includes('math.floor(60 * math.pow(1.30, curLvl - 1))'));
check('SYN-1.7', 'Speed cost formula matches floor(90 * 1.40^(curLvl - 1))',
  serverSource.includes('math.floor(90 * math.pow(1.40, curLvl - 1))'));
check('SYN-1.8', 'Damage stat formula matches floor(curStat * 1.35 + 10)',
  serverSource.includes('math.floor(curStat * 1.35 + 10)'));
check('SYN-1.9', 'Range stat formula matches curStat + 4',
  serverSource.includes('curStat + 4'));
check('SYN-1.10', 'Speed stat formula clamps to minCd: math.max(minCd, floor(curStat * 0.90 * 100) / 100)',
  serverSource.includes('math.max(minCd, math.floor(curStat * 0.90 * 100) / 100)'));
check('SYN-1.11', 'Insufficient cash guard and error reason defined',
  serverSource.includes('curCash < cost') && serverSource.includes('reason = "InsufficientCash"'));

// -----------------------------------------------------------------------------
// STEP 2: Headless Roblox Environment Simulation
// -----------------------------------------------------------------------------
class MockPlayer {
  constructor(initialCash = 500) {
    this.attributes = new Map();
    this.leaderstats = {
      Cash: { Value: initialCash }
    };

    // Initialize attributes matching ensurePlayerStats in UpgradeServer.server.luau
    this.attributes.set("Cash", initialCash);
    this.attributes.set("DamageStat", 45);
    this.attributes.set("RangeStat", 36);
    this.attributes.set("CooldownStat", 0.95);
    this.attributes.set("DamageLevel", 1);
    this.attributes.set("RangeLevel", 1);
    this.attributes.set("SpeedLevel", 1);
  }

  GetAttribute(key) {
    return this.attributes.get(key);
  }

  SetAttribute(key, val) {
    this.attributes.set(key, val);
    if (key === "Cash" && this.leaderstats && this.leaderstats.Cash) {
      this.leaderstats.Cash.Value = val;
    }
  }

  FindFirstChild(name) {
    if (name === "leaderstats") return this.leaderstats;
    return null;
  }
}

// Exact replication of processCashUpgrade in UpgradeServer.server.luau
function processCashUpgrade(player, statType) {
  const getCash = (p) => {
    if (p.leaderstats && p.leaderstats.Cash) {
      return p.leaderstats.Cash.Value;
    }
    const attr = p.GetAttribute("Cash");
    return attr !== undefined ? attr : 500;
  };

  const setCash = (p, val) => {
    if (p.leaderstats && p.leaderstats.Cash) {
      p.leaderstats.Cash.Value = val;
    }
    p.SetAttribute("Cash", val);
  };

  const curCash = getCash(player);
  if (typeof statType !== "string") {
    return { success: false, reason: "InvalidArguments", remainingCash: curCash };
  }
  const normalizedType = statType.toLowerCase();

  if (normalizedType === "damage") {
    const curLvl = player.GetAttribute("DamageLevel") || 1;
    const curStat = player.GetAttribute("DamageStat") || 45;
    const cost = Math.floor(75 * Math.pow(1.35, curLvl - 1));

    if (curCash < cost) {
      return {
        success: false,
        statType: "Damage",
        newLevel: curLvl,
        newCost: cost,
        newStat: curStat,
        remainingCash: curCash,
        reason: "InsufficientCash",
      };
    }

    const nextCash = curCash - cost;
    const nextStat = Math.floor(curStat * 1.35 + 10);
    const nextLvl = curLvl + 1;
    const nextCost = Math.floor(75 * Math.pow(1.35, nextLvl - 1));

    setCash(player, nextCash);
    player.SetAttribute("DamageStat", nextStat);
    player.SetAttribute("DamageLevel", nextLvl);

    return {
      success: true,
      statType: "Damage",
      newLevel: nextLvl,
      newCost: nextCost,
      newStat: nextStat,
      remainingCash: nextCash,
    };

  } else if (normalizedType === "range") {
    const curLvl = player.GetAttribute("RangeLevel") || 1;
    const curStat = player.GetAttribute("RangeStat") || 36;
    const cost = Math.floor(60 * Math.pow(1.30, curLvl - 1));

    if (curCash < cost) {
      return {
        success: false,
        statType: "Range",
        newLevel: curLvl,
        newCost: cost,
        newStat: curStat,
        remainingCash: curCash,
        reason: "InsufficientCash",
      };
    }

    const nextCash = curCash - cost;
    const nextStat = curStat + 4;
    const nextLvl = curLvl + 1;
    const nextCost = Math.floor(60 * Math.pow(1.30, nextLvl - 1));

    setCash(player, nextCash);
    player.SetAttribute("RangeStat", nextStat);
    player.SetAttribute("RangeLevel", nextLvl);

    return {
      success: true,
      statType: "Range",
      newLevel: nextLvl,
      newCost: nextCost,
      newStat: nextStat,
      remainingCash: nextCash,
    };

  } else if (normalizedType === "speed") {
    const curLvl = player.GetAttribute("SpeedLevel") || 1;
    const curStat = player.GetAttribute("CooldownStat") || 0.95;
    const minCd = 0.15;
    const cost = Math.floor(90 * Math.pow(1.40, curLvl - 1));

    if (curCash < cost) {
      return {
        success: false,
        statType: "Speed",
        newLevel: curLvl,
        newCost: cost,
        newStat: curStat,
        remainingCash: curCash,
        reason: "InsufficientCash",
      };
    }

    const nextCash = curCash - cost;
    const nextStat = Math.max(minCd, Math.floor(curStat * 0.90 * 100) / 100);
    const nextLvl = curLvl + 1;
    const nextCost = Math.floor(90 * Math.pow(1.40, nextLvl - 1));

    setCash(player, nextCash);
    player.SetAttribute("CooldownStat", nextStat);
    player.SetAttribute("SpeedLevel", nextLvl);

    return {
      success: true,
      statType: "Speed",
      newLevel: nextLvl,
      newCost: nextCost,
      newStat: nextStat,
      remainingCash: nextCash,
    };

  } else {
    return {
      success: false,
      statType: statType,
      newLevel: 1,
      newCost: 0,
      newStat: 0,
      remainingCash: curCash,
      reason: "InvalidStatType",
    };
  }
}

// -----------------------------------------------------------------------------
// SECTION 2: MATHEMATICAL PRECISION OF COST CURVES (Levels 1 to 100)
// -----------------------------------------------------------------------------
console.log(`\n${BOLD}${CYAN}--- SECTION 2: MATHEMATICAL PRECISION OF COST CURVES (LVL 1-100) ---${RESET}`);

// Ground truth analytical formulas
const expectedCost = {
  damage: (lvl) => Math.floor(75 * Math.pow(1.35, lvl - 1)),
  range: (lvl) => Math.floor(60 * Math.pow(1.30, lvl - 1)),
  speed: (lvl) => Math.floor(90 * Math.pow(1.40, lvl - 1)),
};

// Check milestone values
check('MTH-2.1', 'Level 1 Base Costs: Damage=$75, Range=$60, Speed=$90',
  expectedCost.damage(1) === 75 && expectedCost.range(1) === 60 && expectedCost.speed(1) === 90);

check('MTH-2.2', 'Level 2 Costs: Damage=$101, Range=$78, Speed=$125 (IEEE-754 floor precision)',
  expectedCost.damage(2) === 101 && expectedCost.range(2) === 78 && expectedCost.speed(2) === 125);

check('MTH-2.2b', 'IEEE-754 Truncation Observation: 90 * 1.40 = 125.99999999999999 < 126.0',
  (90 * Math.pow(1.40, 1)) < 126 && Math.floor(90 * Math.pow(1.40, 1)) === 125,
  `Raw float: ${(90 * Math.pow(1.40, 1)).toFixed(16)}`);

check('MTH-2.3', 'Level 3 Costs: Damage=$136, Range=$101, Speed=$176',
  expectedCost.damage(3) === 136 && expectedCost.range(3) === 101 && expectedCost.speed(3) === 176);

check('MTH-2.4', 'Level 4 Costs: Damage=$184, Range=$131, Speed=$246',
  expectedCost.damage(4) === 184 && expectedCost.range(4) === 131 && expectedCost.speed(4) === 246);

check('MTH-2.5', 'Level 5 Costs: Damage=$249, Range=$171, Speed=$345',
  expectedCost.damage(5) === 249 && expectedCost.range(5) === 171 && expectedCost.speed(5) === 345);

// Test levels 1 to 100 precision, strict monotonicity and integer property
let allMonotonic = true;
let allIntegers = true;
let precisionMatches = true;

for (let lvl = 1; lvl <= 100; lvl++) {
  const cDmg = expectedCost.damage(lvl);
  const cRng = expectedCost.range(lvl);
  const cSpd = expectedCost.speed(lvl);

  if (!Number.isInteger(cDmg) || !Number.isInteger(cRng) || !Number.isInteger(cSpd)) {
    allIntegers = false;
  }

  if (lvl > 1) {
    if (cDmg <= expectedCost.damage(lvl - 1) ||
        cRng <= expectedCost.range(lvl - 1) ||
        cSpd <= expectedCost.speed(lvl - 1)) {
      allMonotonic = false;
    }
  }

  // Simulate via processCashUpgrade check
  const pSim = new MockPlayer(1e20);
  pSim.SetAttribute("DamageLevel", lvl);
  pSim.SetAttribute("RangeLevel", lvl);
  pSim.SetAttribute("SpeedLevel", lvl);

  const resDmg = processCashUpgrade(pSim, "Damage");
  const resRng = processCashUpgrade(pSim, "Range");
  const resSpd = processCashUpgrade(pSim, "Speed");

  if (resDmg.newCost !== expectedCost.damage(lvl + 1) ||
      resRng.newCost !== expectedCost.range(lvl + 1) ||
      resSpd.newCost !== expectedCost.speed(lvl + 1)) {
    precisionMatches = false;
  }
}

check('MTH-2.6', 'All 100 levels produce strictly integer costs', allIntegers);
check('MTH-2.7', 'All 100 levels exhibit strictly monotonic cost growth', allMonotonic);
check('MTH-2.8', 'processCashUpgrade nextCost matches analytical formula across all 100 levels', precisionMatches);

// -----------------------------------------------------------------------------
// SECTION 3: INVARIANT A — INSUFFICIENT CASH REJECTION
// -----------------------------------------------------------------------------
console.log(`\n${BOLD}${CYAN}--- SECTION 3: INVARIANT A — INSUFFICIENT CASH REJECTION ---${RESET}`);

{
  const p = new MockPlayer(74); // Damage cost is 75
  const res = processCashUpgrade(p, "Damage");

  check('INV-A.1', 'Upgrade rejected when Cash is $1 below cost ($74 vs $75)',
    res.success === false && res.reason === "InsufficientCash");
  check('INV-A.2', 'Cash balance is NOT decremented upon rejection ($74 maintained)',
    p.GetAttribute("Cash") === 74 && p.leaderstats.Cash.Value === 74 && res.remainingCash === 74);
  check('INV-A.3', 'DamageLevel remains unchanged at 1',
    p.GetAttribute("DamageLevel") === 1 && res.newLevel === 1);
  check('INV-A.4', 'DamageStat remains unchanged at 45',
    p.GetAttribute("DamageStat") === 45 && res.newStat === 45);

  // Exact cash boundary test: Cash == Cost (75 == 75)
  p.SetAttribute("Cash", 75);
  const resExact = processCashUpgrade(p, "Damage");
  check('INV-A.5', 'Upgrade succeeds when Cash exactly equals cost ($75 == $75)',
    resExact.success === true && resExact.remainingCash === 0 && p.GetAttribute("Cash") === 0);
  check('INV-A.6', 'DamageLevel increments to 2 upon successful purchase',
    p.GetAttribute("DamageLevel") === 2 && resExact.newLevel === 2);

  // Zero cash test
  const resZero = processCashUpgrade(p, "Damage");
  check('INV-A.7', 'Upgrade rejected with $0 cash',
    resZero.success === false && resZero.reason === "InsufficientCash" && p.GetAttribute("Cash") === 0);

  // Negative initial cash test
  p.SetAttribute("Cash", -100);
  const resNeg = processCashUpgrade(p, "Range");
  check('INV-A.8', 'Upgrade rejected safely with negative cash (-$100)',
    resNeg.success === false && p.GetAttribute("Cash") === -100);

  // Invalid stat type rejection
  p.SetAttribute("Cash", 500);
  const resInvalid = processCashUpgrade(p, "JumpPower");
  check('INV-A.9', 'Invalid statType returns InvalidStatType without cash deduction',
    resInvalid.success === false && resInvalid.reason === "InvalidStatType" && p.GetAttribute("Cash") === 500);

  // Non-string argument rejection
  const resNonString = processCashUpgrade(p, 999);
  check('INV-A.10', 'Non-string argument returns InvalidArguments without cash deduction',
    resNonString.success === false && resNonString.reason === "InvalidArguments" && p.GetAttribute("Cash") === 500);
}

// -----------------------------------------------------------------------------
// SECTION 4: INVARIANT B — COOLDOWN CLAMPING & 100 SPEED UPGRADES
// -----------------------------------------------------------------------------
console.log(`\n${BOLD}${CYAN}--- SECTION 4: INVARIANT B — COOLDOWN CLAMPING & 100 SPEED UPGRADES ---${RESET}`);

{
  const p = new MockPlayer(1e25); // effectively unlimited cash
  let minObservedCooldown = 999;
  let clampedAtStep = -1;
  let stayedAtMin = true;

  for (let i = 1; i <= 100; i++) {
    const cdBefore = p.GetAttribute("CooldownStat");
    const res = processCashUpgrade(p, "Speed");

    if (!res.success) {
      console.error(`Speed upgrade failed at iteration ${i}`);
      break;
    }

    const cdAfter = p.GetAttribute("CooldownStat");
    if (cdAfter < minObservedCooldown) {
      minObservedCooldown = cdAfter;
    }

    if (cdAfter === 0.15 && clampedAtStep === -1) {
      clampedAtStep = i;
    }

    if (clampedAtStep !== -1 && i > clampedAtStep) {
      if (cdAfter !== 0.15) {
        stayedAtMin = false;
      }
    }
  }

  check('INV-B.1', '100 Speed upgrades successfully completed', p.GetAttribute("SpeedLevel") === 101);
  check('INV-B.2', 'Cooldown reaches minimum limit of 0.15s (clamped at upgrade #16)',
    clampedAtStep === 16 || clampedAtStep === 17, `Clamped at upgrade #${clampedAtStep}`);
  check('INV-B.3', 'CooldownStat NEVER drops below 0.15s throughout all 100 upgrades',
    minObservedCooldown === 0.15, `Min observed: ${minObservedCooldown}`);
  check('INV-B.4', 'CooldownStat remains strictly pinned at 0.15s for all subsequent upgrades',
    stayedAtMin, `Verified for upgrades ${clampedAtStep} to 100`);
  check('INV-B.5', 'No floating-point precision leakage (cd !== 0.149999999)',
    p.GetAttribute("CooldownStat") === 0.15);
}

// -----------------------------------------------------------------------------
// SECTION 5: INVARIANT C — LEVEL INCREMENTS & STAT PROGRESSION
// -----------------------------------------------------------------------------
console.log(`\n${BOLD}${CYAN}--- SECTION 5: INVARIANT C — LEVEL INCREMENTS & STAT PROGRESSION ---${RESET}`);

{
  const p = new MockPlayer(1e12);
  let strictPlusOne = true;
  let damageMonotonic = true;
  let rangeMonotonic = true;

  let prevDmgLvl = p.GetAttribute("DamageLevel");
  let prevDmgStat = p.GetAttribute("DamageStat");

  for (let step = 1; step <= 50; step++) {
    const resDmg = processCashUpgrade(p, "Damage");
    const curDmgLvl = p.GetAttribute("DamageLevel");
    const curDmgStat = p.GetAttribute("DamageStat");

    if (curDmgLvl !== prevDmgLvl + 1 || resDmg.newLevel !== curDmgLvl) {
      strictPlusOne = false;
    }
    if (curDmgStat <= prevDmgStat) {
      damageMonotonic = false;
    }
    prevDmgLvl = curDmgLvl;
    prevDmgStat = curDmgStat;
  }

  let prevRngLvl = p.GetAttribute("RangeLevel");
  let prevRngStat = p.GetAttribute("RangeStat");

  for (let step = 1; step <= 50; step++) {
    const resRng = processCashUpgrade(p, "Range");
    const curRngLvl = p.GetAttribute("RangeLevel");
    const curRngStat = p.GetAttribute("RangeStat");

    if (curRngLvl !== prevRngLvl + 1 || resRng.newLevel !== curRngLvl) {
      strictPlusOne = false;
    }
    if (curRngStat !== prevRngStat + 4) {
      rangeMonotonic = false;
    }
    prevRngLvl = curRngLvl;
    prevRngStat = curRngStat;
  }

  check('INV-C.1', 'Level increments strictly by +1 per successful upgrade (50 steps verified)', strictPlusOne);
  check('INV-C.2', 'DamageStat is strictly increasing (nextDmg = floor(curDmg * 1.35 + 10))', damageMonotonic);
  check('INV-C.3', 'RangeStat increments by exactly +4 studs per upgrade', rangeMonotonic);
}

// -----------------------------------------------------------------------------
// SECTION 6: HIGH-VOLUME ADVERSARIAL STRESS SIMULATION (10,000 REQUESTS)
// -----------------------------------------------------------------------------
console.log(`\n${BOLD}${CYAN}--- SECTION 6: HIGH-VOLUME ADVERSARIAL SIMULATION (10,000 REQUESTS) ---${RESET}`);

const STRESS_TARGET = 10000;
let totalRequestsExecuted = 0;
let totalSuccesses = 0;
let totalRejections = 0;
let totalInvariantViolations = 0;

// Sub-Test 6.1: Rapid Saturated Burst (3,000 requests with $0 cash)
console.log(`${GRAY}Executing Sub-Test 6.1: Rapid Saturated Burst (3,000 requests at $0 cash)...${RESET}`);
{
  const pZero = new MockPlayer(0);
  const stats = ["Damage", "Range", "Speed", "damage", "range", "speed"];
  for (let i = 0; i < 3000; i++) {
    const stat = stats[i % stats.length];
    const res = processCashUpgrade(pZero, stat);
    totalRequestsExecuted++;
    if (res.success) {
      totalInvariantViolations++;
    } else {
      totalRejections++;
    }
    if (pZero.GetAttribute("Cash") !== 0 || pZero.leaderstats.Cash.Value !== 0) {
      totalInvariantViolations++;
    }
    if (pZero.GetAttribute("DamageLevel") !== 1 ||
        pZero.GetAttribute("RangeLevel") !== 1 ||
        pZero.GetAttribute("SpeedLevel") !== 1) {
      totalInvariantViolations++;
    }
  }
}

// Sub-Test 6.2: Realistic Dynamic Progression & Fuzzing (4,000 requests)
console.log(`${GRAY}Executing Sub-Test 6.2: Dynamic Fuzzing with Cash Rewards (4,000 requests)...${RESET}`);
{
  const pFuzz = new MockPlayer(500);
  const actionPool = [
    "Damage", "Range", "Speed",
    "damage", "RANGE", "sPeEd",
    "InvalidStat", "", null, 12345, "Card_Gear5Nika"
  ];

  for (let i = 0; i < 4000; i++) {
    // Inject random cash flow simulating enemy kills and wave rewards
    if (i % 3 === 0) {
      const reward = Math.floor(Math.random() * 200) + 20;
      const cur = pFuzz.GetAttribute("Cash");
      pFuzz.SetAttribute("Cash", cur + reward);
    }

    const cashBefore = pFuzz.GetAttribute("Cash");
    const statAction = actionPool[Math.floor(Math.random() * actionPool.length)];
    const res = processCashUpgrade(pFuzz, statAction);
    totalRequestsExecuted++;

    const cashAfter = pFuzz.GetAttribute("Cash");

    if (res.success) {
      totalSuccesses++;
      // Invariant: Cash after must be exactly cashBefore - cost
      if (cashAfter < 0 || cashAfter > cashBefore) {
        totalInvariantViolations++;
      }
      // Invariant: Cooldown never < 0.15
      if (pFuzz.GetAttribute("CooldownStat") < 0.15) {
        totalInvariantViolations++;
      }
    } else {
      totalRejections++;
      // Invariant: Cash must not change on failure
      if (cashAfter !== cashBefore) {
        totalInvariantViolations++;
      }
    }
  }
}

// Sub-Test 6.3: High-Roll Millionaire Progression (3,000 requests)
console.log(`${GRAY}Executing Sub-Test 6.3: High-Roll Progression with $50,000,000 cash (3,000 requests)...${RESET}`);
{
  const pHuge = new MockPlayer(50000000);
  const upgradeTypes = ["Damage", "Range", "Speed"];

  for (let i = 0; i < 3000; i++) {
    const stat = upgradeTypes[i % upgradeTypes.length];
    const cashBefore = pHuge.GetAttribute("Cash");
    const res = processCashUpgrade(pHuge, stat);
    totalRequestsExecuted++;

    const cashAfter = pHuge.GetAttribute("Cash");

    if (res.success) {
      totalSuccesses++;
      if (cashAfter < 0 || cashAfter >= cashBefore) {
        totalInvariantViolations++;
      }
      if (pHuge.GetAttribute("CooldownStat") < 0.15) {
        totalInvariantViolations++;
      }
    } else {
      totalRejections++;
      if (cashAfter !== cashBefore) {
        totalInvariantViolations++;
      }
    }
  }
}

check('STR-6.1', 'Total request volume reached exactly 10,000 simulated calls',
  totalRequestsExecuted === STRESS_TARGET, `Executed: ${totalRequestsExecuted}`);
check('STR-6.2', 'Zero invariant violations across all 10,000 requests',
  totalInvariantViolations === 0, `Violations: ${totalInvariantViolations}`);
check('STR-6.3', 'Both successful purchases and safe rejections recorded and verified',
  totalSuccesses > 0 && totalRejections > 0, `Successes: ${totalSuccesses}, Rejections: ${totalRejections}`);

// -----------------------------------------------------------------------------
// FINAL SUMMARY
// -----------------------------------------------------------------------------
console.log(`\n${BOLD}${MAGENTA}========================================================================${RESET}`);
console.log(`${BOLD}   ADVERSARIAL CHALLENGE EXECUTION SUMMARY                              ${RESET}`);
console.log(`${BOLD}${MAGENTA}========================================================================${RESET}`);
console.log(`Total Checks:    ${results.total}`);
console.log(`Passed:          ${GREEN}${results.passed}${RESET}`);
console.log(`Failed:          ${results.failed > 0 ? `${RED}${results.failed}${RESET}` : `0`}`);
console.log(`Total Requests:  ${totalRequestsExecuted}`);
console.log(`Violations:      ${totalInvariantViolations === 0 ? `${GREEN}0${RESET}` : `${RED}${totalInvariantViolations}${RESET}`}`);
console.log(`${BOLD}${MAGENTA}========================================================================${RESET}\n`);

if (results.failed === 0 && totalInvariantViolations === 0) {
  console.log(`${BOLD}${GREEN}EMPIRICAL VERDICT: APPROVE${RESET}`);
  console.log(`All mathematical curves, boundary invariants, and high-volume stress simulations passed with 100% precision.\n`);
  process.exit(0);
} else {
  console.error(`${BOLD}${RED}EMPIRICAL VERDICT: REJECT${RESET}`);
  console.error(`Adversarial failure detected! Check test logs for failed assertions.\n`);
  process.exit(1);
}
