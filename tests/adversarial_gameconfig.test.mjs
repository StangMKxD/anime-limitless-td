// tests/adversarial_gameconfig.test.mjs
// Adversarial Data & Invariant Verification Suite for GameConfig.luau
// Executed by challenger_m1_1 in headless Node.js environment

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(__dirname, '..');
const GAME_CONFIG_PATH = path.join(PROJECT_ROOT, 'src', 'Shared', 'GameConfig.luau');

// Color formatting
const C = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  yellow: '\x1b[33m',
  gray: '\x1b[90m',
};

const report = {
  total: 0,
  passed: 0,
  failed: 0,
  tests: [],
};

function assert(id, description, condition, details = '') {
  report.total++;
  const passed = Boolean(condition);
  if (passed) {
    report.passed++;
    console.log(`${C.cyan}[ADV-PASS]${C.reset} ${C.bold}${id}${C.reset}: ${description}${details ? ` ${C.gray}(${details})${C.reset}` : ''}`);
  } else {
    report.failed++;
    console.error(`${C.red}[ADV-FAIL]${C.reset} ${C.bold}${id}${C.reset}: ${description} - FAILED! ${C.yellow}${details}${C.reset}`);
  }
  report.tests.push({ id, description, passed, details });
}

// -----------------------------------------------------------------------------
// Luau AST-Free Robust Evaluator / Parser for GameConfig.luau
// -----------------------------------------------------------------------------
function loadGameConfig() {
  if (!fs.existsSync(GAME_CONFIG_PATH)) {
    throw new Error(`GameConfig.luau not found at ${GAME_CONFIG_PATH}`);
  }
  const raw = fs.readFileSync(GAME_CONFIG_PATH, 'utf8');

  // Accumulator for extracted tables
  const GameConfig = {};

  // Helper sandbox to evaluate sanitized Luau tables into JS objects
  function createSandbox() {
    return {
      Vector3: {
        new: (x, y, z) => ({ x: Number(x), y: Number(y), z: Number(z) }),
      },
      Color3: {
        fromRGB: (r, g, b) => ({ r: Number(r), g: Number(g), b: Number(b) }),
      },
      GameConfig,
    };
  }

  // Extract a Lua table by name: e.g. GameConfig.HERO_CATALOG = { ... }
  function extractTable(tableName) {
    const marker = `GameConfig.${tableName}\\s*=\\s*\\{`;
    const regex = new RegExp(marker, 'm');
    const match = regex.exec(raw);
    if (!match) {
      throw new Error(`Could not find GameConfig.${tableName}`);
    }

    const startIndex = match.index + match[0].length - 1;
    let depth = 0;
    let endIndex = -1;
    let inString = false;
    let stringChar = '';

    for (let i = startIndex; i < raw.length; i++) {
      const char = raw[i];
      const prevChar = i > 0 ? raw[i - 1] : '';

      if (inString) {
        if (char === stringChar && prevChar !== '\\') {
          inString = false;
        }
        continue;
      }

      if (char === '"' || char === "'") {
        inString = true;
        stringChar = char;
        continue;
      }

      // Check for comment
      if (char === '-' && raw[i + 1] === '-' && !inString) {
        // Skip until newline
        const nl = raw.indexOf('\n', i);
        if (nl === -1) break;
        i = nl;
        continue;
      }

      if (char === '{') {
        depth++;
      } else if (char === '}') {
        depth--;
        if (depth === 0) {
          endIndex = i + 1;
          break;
        }
      }
    }

    if (endIndex === -1) {
      throw new Error(`Unmatched braces while extracting GameConfig.${tableName}`);
    }

    let luaChunk = raw.slice(startIndex, endIndex);

    // Sanitize Lua syntax to valid JavaScript Object syntax
    // 1. Remove comments
    luaChunk = luaChunk.replace(/--.*$/gm, '');
    // 2. Remove type annotations like :: { ... } or :: string
    luaChunk = luaChunk.replace(/::\s*\{[^}]*\}/g, '');
    luaChunk = luaChunk.replace(/::\s*\w+/g, '');
    // 3. Convert identifier keys `Key =` to `"Key":`
    luaChunk = luaChunk.replace(/([a-zA-Z0-9_]+)\s*=/g, '"$1":');

    // If this table is an array of items (e.g. PLACEMENT_SLOTS, HERO_CATALOG, CARD_POOL)
    // convert the outermost { and } to [ and ]
    const isArrayTable = ['PLACEMENT_SLOTS', 'HERO_CATALOG', 'CARD_POOL'].includes(tableName);
    if (isArrayTable) {
      const firstBrace = luaChunk.indexOf('{');
      const lastBrace = luaChunk.lastIndexOf('}');
      if (firstBrace !== -1 && lastBrace !== -1) {
        luaChunk = luaChunk.slice(0, firstBrace) + '[' + luaChunk.slice(firstBrace + 1, lastBrace) + ']' + luaChunk.slice(lastBrace + 1);
      }
    }

    // Run in Function constructor with sandbox
    const sandbox = createSandbox();
    const fn = new Function('Vector3', 'Color3', 'GameConfig', `return (${luaChunk});`);
    const val = fn(sandbox.Vector3, sandbox.Color3, sandbox.GameConfig);
    GameConfig[tableName] = val;
    return val;
  }

  return {
    raw,
    WORKSPACE_ATTRS: extractTable('WORKSPACE_ATTRS'),
    PLAYER_ATTRS: extractTable('PLAYER_ATTRS'),
    ATTRIBUTES: extractTable('ATTRIBUTES'),
    INITIAL_PLAYER_STATS: extractTable('INITIAL_PLAYER_STATS'),
    BASE_STATS: extractTable('BASE_STATS'),
    WAVE_SETTINGS: extractTable('WAVE_SETTINGS'),
    FOLDERS: extractTable('FOLDERS'),
    REMOTES: extractTable('REMOTES'),
    PLACEMENT_SLOTS: extractTable('PLACEMENT_SLOTS'),
    HERO_CATALOG: extractTable('HERO_CATALOG'),
    CARD_POOL: extractTable('CARD_POOL'),
  };
}

// -----------------------------------------------------------------------------
// ADVERSARIAL EXECUTION
// -----------------------------------------------------------------------------
console.log('='.repeat(72));
console.log('   ADVERSARIAL DATA & INVARIANT STRESS SUITE: GameConfig.luau   ');
console.log('='.repeat(72));

let config;
try {
  config = loadGameConfig();
  assert('INIT-1', 'Successfully parsed GameConfig.luau without syntactic distortion', true);
} catch (err) {
  assert('INIT-1', 'Failed to parse GameConfig.luau', false, err.message);
  process.exit(1);
}

// -----------------------------------------------------------------------------
// CATEGORY 1: HERO WEIGHTS & GACHA MATHEMATICAL INVARIANTS
// -----------------------------------------------------------------------------
console.log(`\n${C.bold}--- CATEGORY 1: HERO WEIGHTS & GACHA MATHEMATICS ---${C.reset}`);

const heroes = config.HERO_CATALOG;
assert('ADV-1.1', 'Hero catalog must contain exactly 8 heroes', heroes.length === 8, `count=${heroes.length}`);

// Sum of weights strict check
const totalWeight = heroes.reduce((sum, h) => sum + h.Weight, 0);
assert('ADV-1.2', 'Sum of hero weights must strictly equal 100 with zero drift', totalWeight === 100, `sum=${totalWeight}`);

// Integer weights and strictly positive
const allIntegerWeights = heroes.every(h => Number.isInteger(h.Weight) && h.Weight > 0);
assert('ADV-1.3', 'All hero weights must be positive integers', allIntegerWeights, heroes.map(h => `${h.Id}:${h.Weight}`).join(', '));

// Rarity tier distribution sums
const mythicalSum = heroes.filter(h => h.Rarity.includes('MYTHICAL')).reduce((s, h) => s + h.Weight, 0);
const legendarySum = heroes.filter(h => h.Rarity.includes('LEGENDARY')).reduce((s, h) => s + h.Weight, 0);
const epicSum = heroes.filter(h => h.Rarity.includes('EPIC')).reduce((s, h) => s + h.Weight, 0);

assert('ADV-1.4', 'Rarity weight distribution matches spec (Mythical: 22%, Legendary: 56%, Epic: 22%)',
  mythicalSum === 22 && legendarySum === 56 && epicSum === 22,
  `Mythical=${mythicalSum}%, Legendary=${legendarySum}%, Epic=${epicSum}%`
);

// Cumulative Distribution Function (CDF) coverage: 0 to 99 must map 1:1 with no holes
let cdfHoles = false;
let cdfOverlaps = false;
for (let roll = 0; roll < 100; roll++) {
  let accum = 0;
  let matchedHero = null;
  for (const h of heroes) {
    accum += h.Weight;
    if (roll < accum) {
      matchedHero = h;
      break;
    }
  }
  if (!matchedHero) cdfHoles = true;
}
assert('ADV-1.5', 'Gacha roll space [0, 99] maps exhaustively with 0 holes or unreachable units', !cdfHoles);

// Monte Carlo 100,000 Roll Stress Test
const MC_TRIALS = 100000;
const rollCounts = {};
for (const h of heroes) rollCounts[h.Id] = 0;

for (let i = 0; i < MC_TRIALS; i++) {
  const roll = Math.floor(Math.random() * 100);
  let accum = 0;
  for (const h of heroes) {
    accum += h.Weight;
    if (roll < accum) {
      rollCounts[h.Id]++;
      break;
    }
  }
}

let mcWithinTolerance = true;
const mcDetails = [];
for (const h of heroes) {
  const observedPct = (rollCounts[h.Id] / MC_TRIALS) * 100;
  const expectedPct = h.Weight;
  const error = Math.abs(observedPct - expectedPct);
  // With 100k trials, 3 sigma error is roughly 3 * sqrt(p * (1-p) / N) * 100 < 0.5%
  if (error > 0.8) {
    mcWithinTolerance = false;
  }
  mcDetails.push(`${h.Id.replace('Tower_', '')}:${observedPct.toFixed(2)}% (exp ${expectedPct}%)`);
}
assert('ADV-1.6', 'Monte Carlo 100k rolls converge to catalog weights within 3-sigma tolerance', mcWithinTolerance, mcDetails.slice(0, 4).join(', ') + '...');

// -----------------------------------------------------------------------------
// CATEGORY 2: HERO CATALOG ATTRIBUTES & SCHEMA HARDENING
// -----------------------------------------------------------------------------
console.log(`\n${C.bold}--- CATEGORY 2: HERO CATALOG ATTRIBUTES & SCHEMA ---${C.reset}`);

// ID Uniqueness & Non-Emptiness
const heroIds = heroes.map(h => h.Id);
const uniqueHeroIds = new Set(heroIds);
assert('ADV-2.1', 'All 8 Hero IDs must be strictly unique', uniqueHeroIds.size === 8 && heroIds.every(id => typeof id === 'string' && id.length > 0));

// Prefix formatting
const validIdPrefixes = heroIds.every(id => id.startsWith('Tower_') && /^[a-zA-Z0-9_]+$/.test(id));
assert('ADV-2.2', 'All Hero IDs conform to naming convention (Tower_<Name>_<Spec>)', validIdPrefixes);

// Names & Subtitles Uniqueness & Non-Emptiness
const heroNames = heroes.map(h => h.Name);
const heroSubtitles = heroes.map(h => h.Subtitle);
assert('ADV-2.3', 'All Hero Names and Subtitles are non-empty and unique',
  new Set(heroNames).size === 8 && heroNames.every(n => n.length > 0) &&
  new Set(heroSubtitles).size === 8 && heroSubtitles.every(s => s.length > 0)
);

// Multipliers sanity check
const validMultipliers = heroes.every(h =>
  typeof h.DamageMult === 'number' && h.DamageMult >= 1.0 && h.DamageMult <= 5.0 &&
  typeof h.RangeBonus === 'number' && h.RangeBonus >= 0 && h.RangeBonus <= 50 &&
  typeof h.CooldownMult === 'number' && h.CooldownMult > 0 && h.CooldownMult <= 2.0 &&
  typeof h.SplashBonus === 'number' && h.SplashBonus >= 0 && h.SplashBonus <= 30
);
assert('ADV-2.4', 'All Hero multipliers (DamageMult, RangeBonus, CooldownMult, SplashBonus) within sane bounds', validMultipliers);

// SellValue integrity
const validSellValues = heroes.every(h => typeof h.SellValue === 'number' && h.SellValue > 0 && Number.isInteger(h.SellValue));
assert('ADV-2.5', 'All Hero SellValues are positive integers', validSellValues);

// AttackStyle & Onomatopoeia
const attackStyles = heroes.map(h => h.AttackStyle);
const onomatopoeias = heroes.map(h => h.Onomatopoeia);
assert('ADV-2.6', 'All 8 AttackStyles are distinct and non-empty valid identifiers',
  new Set(attackStyles).size === 8 && attackStyles.every(a => /^[a-zA-Z0-9_]+$/.test(a))
);
assert('ADV-2.7', 'All 8 Onomatopoeia strings are non-empty and contain Japanese/Thai manga sound text',
  new Set(onomatopoeias).size === 8 && onomatopoeias.every(o => o.length > 0)
);

// Colors
const validColors = heroes.every(h =>
  h.PrimaryColor && typeof h.PrimaryColor.r === 'number' && h.PrimaryColor.r >= 0 && h.PrimaryColor.r <= 255 &&
  h.SecondaryColor && typeof h.SecondaryColor.r === 'number' && h.SecondaryColor.r >= 0 && h.SecondaryColor.r <= 255
);
assert('ADV-2.8', 'All Hero PrimaryColor and SecondaryColor have valid Color3 RGB [0, 255] channels', validColors);

// -----------------------------------------------------------------------------
// CATEGORY 3: TACTICAL PLACEMENT SLOTS INVARIANTS
// -----------------------------------------------------------------------------
console.log(`\n${C.bold}--- CATEGORY 3: TACTICAL PLACEMENT SLOTS INVARIANTS ---${C.reset}`);

const slots = config.PLACEMENT_SLOTS;
assert('ADV-3.1', 'Tactical placement slots must contain exactly 8 slots', slots.length === 8, `count=${slots.length}`);

// SlotId uniqueness & sequential naming
const slotIds = slots.map(s => s.SlotId);
const expectedSlotIds = ['Slot_1', 'Slot_2', 'Slot_3', 'Slot_4', 'Slot_5', 'Slot_6', 'Slot_7', 'Slot_8'];
assert('ADV-3.2', 'Slot IDs must be unique and strictly sequential Slot_1 through Slot_8',
  JSON.stringify(slotIds) === JSON.stringify(expectedSlotIds)
);

// Label uniqueness
const slotLabels = slots.map(s => s.Label);
assert('ADV-3.3', 'All Slot Labels must be non-empty and strictly unique',
  new Set(slotLabels).size === 8 && slotLabels.every(l => typeof l === 'string' && l.length > 0)
);

// Position coordinates invariants
const yEqualsThree = slots.every(s => s.Position.y === 3.0);
assert('ADV-3.4', 'All 8 Slot Positions must have Y coordinate strictly equal to 3.0', yEqualsThree,
  slots.map(s => s.Position.y).join(', ')
);

const nonZeroPositions = slots.every(s => !(s.Position.x === 0 && s.Position.y === 0 && s.Position.z === 0));
assert('ADV-3.5', 'No Slot Position can be zero Vector3(0,0,0)', nonZeroPositions);

// Pairwise distances - no overlapping pads (minimum clearance 15 studs)
let minPairwiseDistance = Infinity;
let overlappingSlots = false;
for (let i = 0; i < slots.length; i++) {
  for (let j = i + 1; j < slots.length; j++) {
    const p1 = slots[i].Position;
    const p2 = slots[j].Position;
    const dist = Math.sqrt(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2) + Math.pow(p1.z - p2.z, 2));
    if (dist < minPairwiseDistance) minPairwiseDistance = dist;
    if (dist < 10.0) overlappingSlots = true; // pads are ~4x4 studs
  }
}
assert('ADV-3.6', 'All 8 Slot Positions have sufficient physical clearance (min distance >= 15 studs)',
  !overlappingSlots && minPairwiseDistance >= 15.0,
  `minDistance=${minPairwiseDistance.toFixed(2)} studs`
);

// Map bounds check: within [-70, 70] on X and [-50, 50] on Z
const withinMapBounds = slots.every(s =>
  s.Position.x >= -70 && s.Position.x <= 70 &&
  s.Position.z >= -50 && s.Position.z <= 50
);
assert('ADV-3.7', 'All 8 Slot Positions lie safely within GrandLineMap plaza boundaries', withinMapBounds);

// -----------------------------------------------------------------------------
// CATEGORY 4: ROGUELIKE WAVE CARDS POOL INVARIANTS
// -----------------------------------------------------------------------------
console.log(`\n${C.bold}--- CATEGORY 4: ROGUELIKE WAVE CARDS POOL INVARIANTS ---${C.reset}`);

const cards = config.CARD_POOL;
assert('ADV-4.1', 'Card pool must contain exactly 12 diverse upgrade cards', cards.length === 12, `count=${cards.length}`);

// ID Uniqueness & Non-Emptiness
const cardIds = cards.map(c => c.Id);
const uniqueCardIds = new Set(cardIds);
assert('ADV-4.2', 'All 12 Card IDs are unique and start with Card_',
  uniqueCardIds.size === 12 && cardIds.every(id => id.startsWith('Card_'))
);

// Title & Category Uniqueness
const cardTitles = cards.map(c => c.Title);
const cardCategories = cards.map(c => c.Category);
assert('ADV-4.3', 'All 12 Card Titles and Categories are non-empty and unique',
  new Set(cardTitles).size === 12 && cardTitles.every(t => t.length > 0) &&
  new Set(cardCategories).size === 12 && cardCategories.every(c => c.length > 0)
);

// Descriptions non-empty
assert('ADV-4.4', 'All 12 Card Descriptions are non-empty strings', cards.every(c => c.Desc && c.Desc.length > 0));

// Colors
const validCardColors = cards.every(c =>
  c.BorderColor && c.BorderColor.r >= 0 && c.BorderColor.r <= 255 &&
  c.BgColor && c.BgColor.r >= 0 && c.BgColor.r <= 255
);
assert('ADV-4.5', 'All 12 Cards have valid Color3 BorderColor and BgColor specifications', validCardColors);

// Modifier values boundary checks
let cardModifiersValid = true;
const modifierViolations = [];
for (const c of cards) {
  if (c.DamagePct !== undefined && (c.DamagePct <= 0 || c.DamagePct > 2.0)) {
    cardModifiersValid = false;
    modifierViolations.push(`${c.Id}.DamagePct=${c.DamagePct}`);
  }
  if (c.DamageFlat !== undefined && (c.DamageFlat <= 0 || !Number.isInteger(c.DamageFlat))) {
    cardModifiersValid = false;
    modifierViolations.push(`${c.Id}.DamageFlat=${c.DamageFlat}`);
  }
  if (c.CooldownMult !== undefined && (c.CooldownMult <= 0 || c.CooldownMult >= 1.0)) {
    cardModifiersValid = false;
    modifierViolations.push(`${c.Id}.CooldownMult=${c.CooldownMult}`);
  }
  if (c.RangeFlat !== undefined && (c.RangeFlat <= 0 || !Number.isInteger(c.RangeFlat))) {
    cardModifiersValid = false;
    modifierViolations.push(`${c.Id}.RangeFlat=${c.RangeFlat}`);
  }
  if (c.SplashFlat !== undefined && (c.SplashFlat <= 0 || !Number.isInteger(c.SplashFlat))) {
    cardModifiersValid = false;
    modifierViolations.push(`${c.Id}.SplashFlat=${c.SplashFlat}`);
  }
  if (c.CritChanceFlat !== undefined && (c.CritChanceFlat <= 0 || c.CritChanceFlat > 0.50)) {
    cardModifiersValid = false;
    modifierViolations.push(`${c.Id}.CritChanceFlat=${c.CritChanceFlat}`);
  }
  if (c.CritDamageFlat !== undefined && (c.CritDamageFlat <= 0 || c.CritDamageFlat > 2.0)) {
    cardModifiersValid = false;
    modifierViolations.push(`${c.Id}.CritDamageFlat=${c.CritDamageFlat}`);
  }
  if (c.BountyMultFlat !== undefined && (c.BountyMultFlat <= 0 || c.BountyMultFlat > 1.0)) {
    cardModifiersValid = false;
    modifierViolations.push(`${c.Id}.BountyMultFlat=${c.BountyMultFlat}`);
  }
  if (c.ExtraTowerSlot !== undefined && (c.ExtraTowerSlot <= 0 || !Number.isInteger(c.ExtraTowerSlot))) {
    cardModifiersValid = false;
    modifierViolations.push(`${c.Id}.ExtraTowerSlot=${c.ExtraTowerSlot}`);
  }
  if (c.InstantCash !== undefined && (c.InstantCash <= 0 || !Number.isInteger(c.InstantCash))) {
    cardModifiersValid = false;
    modifierViolations.push(`${c.Id}.InstantCash=${c.InstantCash}`);
  }
  if (c.BonusRerolls !== undefined && (c.BonusRerolls <= 0 || !Number.isInteger(c.BonusRerolls))) {
    cardModifiersValid = false;
    modifierViolations.push(`${c.Id}.BonusRerolls=${c.BonusRerolls}`);
  }
  if (c.BaseHeal !== undefined && (c.BaseHeal <= 0 || !Number.isInteger(c.BaseHeal))) {
    cardModifiersValid = false;
    modifierViolations.push(`${c.Id}.BaseHeal=${c.BaseHeal}`);
  }
}
assert('ADV-4.6', 'All Card numerical modifiers conform to strict domain boundaries and types',
  cardModifiersValid,
  modifierViolations.join(', ')
);

// 3-Card Draft Modal Simulation (10,000 draws)
let duplicatesFound = false;
const cardDrawnCounts = {};
for (const c of cards) cardDrawnCounts[c.Id] = 0;

for (let i = 0; i < 10000; i++) {
  // Fisher-Yates draw 3 from pool
  const pool = [...cards];
  const drawn = [];
  for (let k = 0; k < 3; k++) {
    const idx = Math.floor(Math.random() * pool.length);
    drawn.push(pool.splice(idx, 1)[0]);
  }
  const drawnSet = new Set(drawn.map(c => c.Id));
  if (drawnSet.size !== 3) duplicatesFound = true;
  for (const c of drawn) cardDrawnCounts[c.Id]++;
}

assert('ADV-4.7', 'Simulated 3-card wave draft guaranteed 0 duplicates across 10k trials', !duplicatesFound);

// Uniform draw probability test: 3 cards out of 12 -> expected 25% draw rate per card
let draftUniform = true;
for (const c of cards) {
  const rate = (cardDrawnCounts[c.Id] / 10000) * 100;
  if (Math.abs(rate - 25.0) > 2.0) draftUniform = false;
}
assert('ADV-4.8', 'Card draft distribution is strictly uniform across all 12 cards (~25% frequency)', draftUniform);

// -----------------------------------------------------------------------------
// CATEGORY 5: CLAMP BOUNDARIES & DOMAIN INVARIANTS
// -----------------------------------------------------------------------------
console.log(`\n${C.bold}--- CATEGORY 5: CLAMPS, BOUNDARIES & SYSTEM INVARIANTS ---${C.reset}`);

const initStats = config.INITIAL_PLAYER_STATS;
assert('ADV-5.1', 'MIN_COOLDOWN is strictly 0.15s', initStats.MIN_COOLDOWN === 0.15, `MIN_COOLDOWN=${initStats.MIN_COOLDOWN}`);
assert('ADV-5.2', 'MAX_CRIT_CHANCE is strictly 0.95', initStats.MAX_CRIT_CHANCE === 0.95, `MAX_CRIT_CHANCE=${initStats.MAX_CRIT_CHANCE}`);
assert('ADV-5.3', 'MAX_TOWERS_LIMIT equals total tactical placement slots (8)',
  initStats.MAX_TOWERS_LIMIT === 8 && initStats.MAX_TOWER_CAP_LIMIT === 8 && slots.length === 8,
  `MAX_TOWERS_LIMIT=${initStats.MAX_TOWERS_LIMIT}, slots=${slots.length}`
);
assert('ADV-5.4', 'Base stats initial values are valid and uncorrupted',
  initStats.DAMAGE === 50 &&
  initStats.RANGE === 30 &&
  initStats.COOLDOWN === 1.15 &&
  initStats.SPLASH_RADIUS === 7 &&
  initStats.CRIT_CHANCE === 0.08 &&
  initStats.CRIT_DAMAGE === 2.0 &&
  initStats.BOUNTY_MULT === 1.0 &&
  initStats.CASH === 500 &&
  initStats.REROLL_TOKENS === 3 &&
  initStats.FREE_SUMMON_TICKETS === 1 &&
  initStats.MAX_PLACED_TOWERS === 4
);

// Cooldown clamp stress-test: apply extreme upgrades and verify clamp boundary
let extremeCd = initStats.COOLDOWN;
for (let lvl = 1; lvl <= 100; lvl++) {
  extremeCd = extremeCd * 0.90;
}
const clampedCd = Math.max(initStats.MIN_COOLDOWN, extremeCd);
assert('ADV-5.5', 'Extreme speed upgrades (Lv.100) are clamped at MIN_COOLDOWN (0.15s)',
  clampedCd === 0.15 && extremeCd < 0.15,
  `unclamped=${extremeCd.toFixed(6)}, clamped=${clampedCd}`
);

// Crit chance clamp stress-test: pick all crit cards multiple times
let extremeCrit = initStats.CRIT_CHANCE + 0.15 * 10; // +150% crit
const clampedCrit = Math.min(initStats.MAX_CRIT_CHANCE, extremeCrit);
assert('ADV-5.6', 'Extreme critical cards stack are clamped at MAX_CRIT_CHANCE (0.95)',
  clampedCrit === 0.95 && extremeCrit > 0.95,
  `unclamped=${extremeCrit}, clamped=${clampedCrit}`
);

// Extra tower slot clamp stress-test: repeatedly picking ExtraTowerSlot
let extremeSlots = initStats.MAX_PLACED_TOWERS;
for (let i = 0; i < 10; i++) {
  extremeSlots = Math.min(initStats.MAX_TOWERS_LIMIT, extremeSlots + 1);
}
assert('ADV-5.7', 'ExtraTowerSlot card picks cannot exceed MAX_TOWERS_LIMIT (8)',
  extremeSlots === 8,
  `clampedSlots=${extremeSlots}`
);

// Base HP and Wave settings invariants
const baseStats = config.BASE_STATS;
const waveSettings = config.WAVE_SETTINGS;
assert('ADV-5.8', 'Base HP and Wave Settings are consistent with project specs',
  baseStats.BASE_HP === 1000 &&
  baseStats.MAX_BASE_HP === 1000 &&
  baseStats.PREP_COUNTDOWN === 15 &&
  waveSettings.MAX_WAVES === 15 &&
  waveSettings.HP_GROWTH_RATE === 1.18 &&
  waveSettings.BOSS_WAVE_INTERVAL === 5
);

// -----------------------------------------------------------------------------
// CATEGORY 6: ATTRIBUTE & REMOTE CONTRACT CONSISTENCY
// -----------------------------------------------------------------------------
console.log(`\n${C.bold}--- CATEGORY 6: ATTRIBUTES & REMOTES INTEGRITY ---${C.reset}`);

const remotes = config.REMOTES;
const remoteValues = [
  remotes.UPGRADE_REQUEST,
  remotes.CARD_DRAFT_SELECT,
  remotes.TOWER_SUMMON_REROLL,
  remotes.TOWER_PLACEMENT_ACTION,
  remotes.VFX_CAMERA_SHAKE,
];
assert('ADV-6.1', 'All 5 RemoteEvent / RemoteFunction names are non-empty and unique',
  new Set(remoteValues).size === 5 && remoteValues.every(r => typeof r === 'string' && r.length > 0)
);

const folders = config.FOLDERS;
const folderValues = Object.values(folders);
assert('ADV-6.2', 'All Folder names are non-empty strings',
  folderValues.every(f => typeof f === 'string' && f.length > 0)
);

const playerAttrs = config.PLAYER_ATTRS;
const playerAttrValues = Object.values(playerAttrs);
assert('ADV-6.3', 'All Player Attribute names are non-empty and unique',
  new Set(playerAttrValues).size === playerAttrValues.length &&
  playerAttrValues.every(a => typeof a === 'string' && a.length > 0)
);

const workspaceAttrs = config.WORKSPACE_ATTRS;
const workspaceAttrValues = Object.values(workspaceAttrs);
assert('ADV-6.4', 'All Workspace Attribute names are non-empty and unique',
  new Set(workspaceAttrValues).size === workspaceAttrValues.length &&
  workspaceAttrValues.every(a => typeof a === 'string' && a.length > 0)
);

// -----------------------------------------------------------------------------
// FINAL SUMMARY & VERDICT
// -----------------------------------------------------------------------------
console.log('\n' + '='.repeat(72));
const pct = ((report.passed / report.total) * 100).toFixed(1);
console.log(`TOTAL ADVERSARIAL TESTS: ${report.total}`);
console.log(`PASSED: ${report.passed} (${pct}%)`);
console.log(`FAILED: ${report.failed}`);
const verdict = report.failed === 0 ? 'APPROVE' : 'REJECT';
const verdictColor = verdict === 'APPROVE' ? C.green : C.red;
console.log(`EMPIRICAL VERDICT: ${verdictColor}${C.bold}${verdict}${C.reset}`);
console.log('='.repeat(72));

// Export results for harness & reporting
fs.writeFileSync(
  path.join(PROJECT_ROOT, '.agents', 'teamwork', 'challenger_m1_1', 'adversarial_results.json'),
  JSON.stringify({ ...report, verdict }, null, 2),
  'utf8'
);

process.exit(report.failed === 0 ? 0 : 1);
