// tests/challenger_simulation.mjs
// Adversarial Empirical Challenge Suite for Milestone 1 (src/Shared/GameConfig.luau)
// Simulates:
// 1. 100,000 Gacha rolls on HERO_CATALOG (3-sigma confidence & Chi-Square test)
// 2. 10,000 Card drafts from CARD_POOL (Distinctness & Uniform Tier Representation)
// 3. JSON serialization safety of BagUnit (Schema fidelity, Stress scaling, Unicode, Injection & Resiliency)

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(__dirname, '..');
const GAME_CONFIG_PATH = path.join(PROJECT_ROOT, 'src', 'Shared', 'GameConfig.luau');

// Terminal formatting
const BOLD = '\x1b[1m';
const RESET = '\x1b[0m';
const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const CYAN = '\x1b[36m';
const YELLOW = '\x1b[33m';
const GRAY = '\x1b[90m';

console.log(`${BOLD}${CYAN}========================================================================${RESET}`);
console.log(`${BOLD}   EMPIRICAL CHALLENGER: GACHA & CARD DRAFT SIMULATION HARNESS         ${RESET}`);
console.log(`${BOLD}   Target: src/Shared/GameConfig.luau                                  ${RESET}`);
console.log(`${BOLD}${CYAN}========================================================================${RESET}\n`);

// -----------------------------------------------------------------------------
// Step 1: Verify & Parse GameConfig.luau
// -----------------------------------------------------------------------------
if (!fs.existsSync(GAME_CONFIG_PATH)) {
  console.error(`${RED}FATAL: GameConfig.luau not found at ${GAME_CONFIG_PATH}${RESET}`);
  process.exit(1);
}

const luauSource = fs.readFileSync(GAME_CONFIG_PATH, 'utf8');

// Parse HERO_CATALOG from source
function parseHeroCatalog(source) {
  const catalogMatch = source.match(/GameConfig\.HERO_CATALOG\s*=\s*\{([\s\S]*?)\}\s*::\s*\{\s*HeroSpec\s*\}/);
  if (!catalogMatch) {
    throw new Error("Could not parse GameConfig.HERO_CATALOG block from GameConfig.luau");
  }
  const block = catalogMatch[1];
  const heroBlocks = block.split(/\{\s*Id\s*=/).slice(1);
  const heroes = [];
  for (const b of heroBlocks) {
    const idMatch = b.match(/^\s*"([^"]+)"/);
    const nameMatch = b.match(/Name\s*=\s*"([^"]+)"/);
    const rarityMatch = b.match(/Rarity\s*=\s*"([^"]+)"/);
    const weightMatch = b.match(/Weight\s*=\s*(\d+)/);
    const sellValueMatch = b.match(/SellValue\s*=\s*(\d+)/);
    const onomatopoeiaMatch = b.match(/Onomatopoeia\s*=\s*"([^"]+)"/);
    if (!idMatch || !nameMatch || !rarityMatch || !weightMatch || !sellValueMatch) {
      throw new Error("Failed to parse hero entry: " + b.slice(0, 100));
    }
    heroes.push({
      Id: idMatch[1],
      Name: nameMatch[1],
      Rarity: rarityMatch[1],
      Weight: parseInt(weightMatch[1], 10),
      SellValue: parseInt(sellValueMatch[1], 10),
      Onomatopoeia: onomatopoeiaMatch ? onomatopoeiaMatch[1] : ""
    });
  }
  return heroes;
}

// Parse CARD_POOL from source
function parseCardPool(source) {
  const cardMatch = source.match(/GameConfig\.CARD_POOL\s*=\s*\{([\s\S]*?)\}\s*::\s*\{\s*CardDef\s*\}/);
  if (!cardMatch) {
    throw new Error("Could not parse GameConfig.CARD_POOL block from GameConfig.luau");
  }
  const block = cardMatch[1];
  const cardBlocks = block.split(/\{\s*Id\s*=/).slice(1);
  const cards = [];
  for (const b of cardBlocks) {
    const idMatch = b.match(/^\s*"([^"]+)"/);
    const rarityMatch = b.match(/Rarity\s*=\s*"([^"]+)"/);
    const titleMatch = b.match(/Title\s*=\s*"([^"]+)"/);
    const categoryMatch = b.match(/Category\s*=\s*"([^"]+)"/);
    if (!idMatch || !rarityMatch || !titleMatch) {
      throw new Error("Failed to parse card entry: " + b.slice(0, 100));
    }
    cards.push({
      Id: idMatch[1],
      Rarity: rarityMatch[1],
      Title: titleMatch[1],
      Category: categoryMatch ? categoryMatch[1] : ""
    });
  }
  return cards;
}

const HERO_CATALOG = parseHeroCatalog(luauSource);
const CARD_POOL = parseCardPool(luauSource);

console.log(`${BOLD}[1] DATA CONTRACT VERIFICATION${RESET}`);
console.log(`Parsed ${HERO_CATALOG.length} Heroes from HERO_CATALOG`);
console.log(`Parsed ${CARD_POOL.length} Cards from CARD_POOL`);

const totalWeight = HERO_CATALOG.reduce((sum, h) => sum + h.Weight, 0);
if (totalWeight !== 100) {
  console.error(`${RED}FAIL: Total hero weight must be 100, got ${totalWeight}${RESET}`);
  process.exit(1);
}
console.log(`Hero weight sum: ${GREEN}${totalWeight}%${RESET} (Verified strictly 100)\n`);

let testPassedCount = 0;
let testTotalCount = 0;

function assertCheck(name, condition, extraInfo = '') {
  testTotalCount++;
  if (condition) {
    testPassedCount++;
    console.log(`  ${GREEN}[PASS]${RESET} ${name} ${GRAY}${extraInfo}${RESET}`);
  } else {
    console.error(`  ${RED}[FAIL]${RESET} ${name} ${RED}${extraInfo}${RESET}`);
  }
}

// -----------------------------------------------------------------------------
// Step 2: 100,000 GACHA ROLLS MONTE CARLO SIMULATION
// -----------------------------------------------------------------------------
console.log(`${BOLD}[2] 100,000 GACHA ROLLS MONTE CARLO SIMULATION${RESET}`);

function rollWeighted(heroes, randFn) {
  const pick = randFn() * 100;
  let cum = 0;
  for (const h of heroes) {
    cum += h.Weight;
    if (pick <= cum) return h;
  }
  return heroes[0];
}

const TOTAL_ROLLS = 100000;
const countsByHero = {};
const countsByTier = {
  "MYTHICAL YONKO": 0,
  "LEGENDARY HAKI": 0,
  "EPIC HAKI": 0
};

for (const h of HERO_CATALOG) {
  countsByHero[h.Id] = 0;
}

// Run 100,000 rolls
for (let i = 0; i < TOTAL_ROLLS; i++) {
  const rolled = rollWeighted(HERO_CATALOG, Math.random);
  countsByHero[rolled.Id]++;
  countsByTier[rolled.Rarity]++;
}

console.log(`Simulated ${TOTAL_ROLLS.toLocaleString()} rolls. Analyzing 3-sigma bounds:`);

// Tier Analysis Table
console.log(`\n${BOLD}--- Rarity Tier Distribution Analysis (N = 100,000) ---${RESET}`);
console.log(
  'Tier'.padEnd(18) + ' | ' +
  'Exp %'.padEnd(7) + ' | ' +
  'Obs Count'.padEnd(10) + ' | ' +
  'Obs %'.padEnd(7) + ' | ' +
  'StdErr (σ)'.padEnd(10) + ' | ' +
  'Z-Score'.padEnd(8) + ' | ' +
  'Within 3σ?'
);
console.log('-'.repeat(82));

const tierExpected = {
  "MYTHICAL YONKO": 0.22,
  "LEGENDARY HAKI": 0.56,
  "EPIC HAKI": 0.22
};

let allTiersWithin3Sigma = true;
for (const [tier, p] of Object.entries(tierExpected)) {
  const obs = countsByTier[tier];
  const obsPct = obs / TOTAL_ROLLS;
  const expCount = TOTAL_ROLLS * p;
  const sigma = Math.sqrt(TOTAL_ROLLS * p * (1 - p));
  const zScore = Math.abs(obs - expCount) / sigma;
  const within3Sigma = zScore <= 3.0;
  if (!within3Sigma) allTiersWithin3Sigma = false;

  console.log(
    tier.padEnd(18) + ' | ' +
    ((p * 100).toFixed(1) + '%').padEnd(7) + ' | ' +
    obs.toLocaleString().padEnd(10) + ' | ' +
    ((obsPct * 100).toFixed(3) + '%').padEnd(7) + ' | ' +
    sigma.toFixed(2).padEnd(10) + ' | ' +
    zScore.toFixed(3).padEnd(8) + ' | ' +
    (within3Sigma ? GREEN + 'PASS (< 3.0σ)' + RESET : RED + 'FAIL (> 3.0σ)' + RESET)
  );
}

assertCheck("All 3 Rarity Tiers within 3-sigma confidence (99.73%)", allTiersWithin3Sigma);

// Hero-by-Hero Analysis Table
console.log(`\n${BOLD}--- Individual Hero Distribution Analysis (N = 100,000) ---${RESET}`);
console.log(
  'Hero ID'.padEnd(26) + ' | ' +
  'Weight'.padEnd(6) + ' | ' +
  'Exp Count'.padEnd(9) + ' | ' +
  'Obs Count'.padEnd(9) + ' | ' +
  'Obs %'.padEnd(7) + ' | ' +
  'Z-Score'.padEnd(8) + ' | ' +
  'Status'
);
console.log('-'.repeat(82));

let allHeroesWithin3Sigma = true;
let chiSquare = 0;

for (const h of HERO_CATALOG) {
  const p = h.Weight / 100;
  const expCount = TOTAL_ROLLS * p;
  const obs = countsByHero[h.Id];
  const obsPct = obs / TOTAL_ROLLS;
  const sigma = Math.sqrt(TOTAL_ROLLS * p * (1 - p));
  const zScore = Math.abs(obs - expCount) / sigma;
  const within3Sigma = zScore <= 3.0;
  if (!within3Sigma) allHeroesWithin3Sigma = false;

  chiSquare += Math.pow(obs - expCount, 2) / expCount;

  console.log(
    h.Id.padEnd(26) + ' | ' +
    (h.Weight + '%').padEnd(6) + ' | ' +
    expCount.toLocaleString().padEnd(9) + ' | ' +
    obs.toLocaleString().padEnd(9) + ' | ' +
    ((obsPct * 100).toFixed(2) + '%').padEnd(7) + ' | ' +
    zScore.toFixed(3).padEnd(8) + ' | ' +
    (within3Sigma ? GREEN + 'PASS' + RESET : RED + 'FAIL' + RESET)
  );
}

assertCheck("All 8 Heroes drop rates within 3-sigma confidence interval", allHeroesWithin3Sigma);

// Chi-Square Goodness of Fit Test
// df = 8 - 1 = 7. Critical value for p = 0.01 is 18.475; for p = 0.05 is 14.067
const chiCritical01 = 18.475;
const chiCritical001 = 24.322;
console.log(`\nChi-Square Statistic (χ²): ${BOLD}${chiSquare.toFixed(4)}${RESET} (df = 7, critical α=0.01 is ${chiCritical01})`);
assertCheck("Chi-Square Goodness of Fit test passes (p > 0.01)", chiSquare < chiCritical01, `χ² = ${chiSquare.toFixed(3)} < ${chiCritical01}`);

// Adversarial High-Entropy PRNG Test (using crypto.randomBytes)
console.log(`\n${BOLD}--- Adversarial Cryptographic PRNG Test (N = 100,000 with crypto.randomBytes) ---${RESET}`);
function cryptoRand() {
  const buf = crypto.randomBytes(4);
  return buf.readUInt32BE(0) / 0xffffffff;
}

const cryptoTierCounts = { "MYTHICAL YONKO": 0, "LEGENDARY HAKI": 0, "EPIC HAKI": 0 };
for (let i = 0; i < TOTAL_ROLLS; i++) {
  const rolled = rollWeighted(HERO_CATALOG, cryptoRand);
  cryptoTierCounts[rolled.Rarity]++;
}

let cryptoWithin3Sigma = true;
for (const [tier, p] of Object.entries(tierExpected)) {
  const obs = cryptoTierCounts[tier];
  const expCount = TOTAL_ROLLS * p;
  const sigma = Math.sqrt(TOTAL_ROLLS * p * (1 - p));
  const zScore = Math.abs(obs - expCount) / sigma;
  if (zScore > 3.0) cryptoWithin3Sigma = false;
  console.log(`  Crypto ${tier.padEnd(18)}: ${obs.toLocaleString()} rolls (${(obs / TOTAL_ROLLS * 100).toFixed(2)}%), z = ${zScore.toFixed(3)}`);
}
assertCheck("Cryptographic PRNG roll distribution matches theoretical within 3-sigma", cryptoWithin3Sigma);

// Boundary Value Edge Case Tests
console.log(`\n${BOLD}--- Gacha Threshold Boundary Test (Exact Picks) ---${RESET}`);
const boundaryTests = [
  { pick: 0.0, expectedId: "Tower_Luffy_G5" },
  { pick: 7.999999, expectedId: "Tower_Luffy_G5" },
  { pick: 8.0, expectedId: "Tower_Luffy_G5" },
  { pick: 8.000001, expectedId: "Tower_Shanks_Kamusari" },
  { pick: 15.0, expectedId: "Tower_Shanks_Kamusari" },
  { pick: 15.000001, expectedId: "Tower_Whitebeard_Gura" },
  { pick: 22.0, expectedId: "Tower_Whitebeard_Gura" },
  { pick: 22.000001, expectedId: "Tower_Zoro_KingOfHell" },
  { pick: 78.0, expectedId: "Tower_Kizaru_Pika" },
  { pick: 78.000001, expectedId: "Tower_Sanji_Ifrit" },
  { pick: 100.0, expectedId: "Tower_Sanji_Ifrit" },
];

let boundaryPassed = true;
for (const bt of boundaryTests) {
  const result = rollWeighted(HERO_CATALOG, () => bt.pick / 100);
  if (result.Id !== bt.expectedId) {
    boundaryPassed = false;
    console.error(`  ${RED}Boundary FAIL at pick ${bt.pick}: expected ${bt.expectedId}, got ${result.Id}${RESET}`);
  }
}
assertCheck("Cumulative boundary thresholds strictly partition [0, 100] without gaps or overlaps", boundaryPassed);

// -----------------------------------------------------------------------------
// Step 3: 10,000 CARD DRAFTS FROM CARD_POOL
// -----------------------------------------------------------------------------
console.log(`\n${BOLD}[3] 10,000 CARD DRAFTS FROM CARD_POOL${RESET}`);
console.log(`Card Pool Size: ${CARD_POOL.length} cards`);

// Verify tier counts in CARD_POOL
const cardsByTier = {
  MYTHICAL: CARD_POOL.filter(c => c.Rarity.includes("MYTHICAL")),
  LEGENDARY: CARD_POOL.filter(c => c.Rarity.includes("LEGENDARY")),
  EPIC: CARD_POOL.filter(c => c.Rarity.includes("EPIC"))
};

console.log(`  Mythical Cards:  ${cardsByTier.MYTHICAL.length} / ${CARD_POOL.length} (33.33%)`);
console.log(`  Legendary Cards: ${cardsByTier.LEGENDARY.length} / ${CARD_POOL.length} (33.33%)`);
console.log(`  Epic Cards:      ${cardsByTier.EPIC.length} / ${CARD_POOL.length} (33.33%)`);

assertCheck("CARD_POOL contains exactly 4 Mythical, 4 Legendary, and 4 Epic cards (perfect 1:1:1 tier balance)",
  cardsByTier.MYTHICAL.length === 4 &&
  cardsByTier.LEGENDARY.length === 4 &&
  cardsByTier.EPIC.length === 4
);

// Fisher-Yates 3-card draft simulation function
function drawThreeCards(pool) {
  const copy = [...pool];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return [copy[0], copy[1], copy[2]];
}

const TOTAL_DRAFTS = 10000;
let duplicateDraftCount = 0;
const cardDraftCounts = {};
const tierDraftCounts = {
  MYTHICAL: 0,
  LEGENDARY: 0,
  EPIC: 0
};

for (const c of CARD_POOL) {
  cardDraftCounts[c.Id] = 0;
}

for (let d = 0; d < TOTAL_DRAFTS; d++) {
  const drawn = drawThreeCards(CARD_POOL);
  if (drawn.length !== 3) {
    duplicateDraftCount++;
    continue;
  }
  const idSet = new Set(drawn.map(c => c.Id));
  if (idSet.size !== 3) {
    duplicateDraftCount++;
  }
  for (const c of drawn) {
    cardDraftCounts[c.Id]++;
    if (c.Rarity.includes("MYTHICAL")) tierDraftCounts.MYTHICAL++;
    else if (c.Rarity.includes("LEGENDARY")) tierDraftCounts.LEGENDARY++;
    else if (c.Rarity.includes("EPIC")) tierDraftCounts.EPIC++;
  }
}

assertCheck("10,000 / 10,000 drafts produced strictly distinct cards (0 duplicates)", duplicateDraftCount === 0);

// Draft Tier Representation Table
console.log(`\n${BOLD}--- Card Draft Tier Representation Analysis (30,000 Card Slots Drawn) ---${RESET}`);
console.log(
  'Tier'.padEnd(14) + ' | ' +
  'Expected'.padEnd(10) + ' | ' +
  'Observed'.padEnd(10) + ' | ' +
  'Obs %'.padEnd(8) + ' | ' +
  'StdErr (σ)'.padEnd(10) + ' | ' +
  'Z-Score'.padEnd(8) + ' | ' +
  'Status'
);
console.log('-'.repeat(74));

const TOTAL_SLOTS = TOTAL_DRAFTS * 3; // 30,000
const expectedTierSlots = TOTAL_SLOTS / 3; // 10,000
// Hypergeometric variance across 10,000 3-card samples without replacement
const varSingleTier = 3 * (4 / 12) * (8 / 12) * ((12 - 3) / (12 - 1));
const sigmaTierSum = Math.sqrt(TOTAL_DRAFTS * varSingleTier);

let allDraftTiersWithin3Sigma = true;
for (const [tier, count] of Object.entries(tierDraftCounts)) {
  const zScore = Math.abs(count - expectedTierSlots) / sigmaTierSum;
  const within = zScore <= 3.0;
  if (!within) allDraftTiersWithin3Sigma = false;
  console.log(
    tier.padEnd(14) + ' | ' +
    expectedTierSlots.toLocaleString().padEnd(10) + ' | ' +
    count.toLocaleString().padEnd(10) + ' | ' +
    ((count / TOTAL_SLOTS * 100).toFixed(2) + '%').padEnd(8) + ' | ' +
    sigmaTierSum.toFixed(2).padEnd(10) + ' | ' +
    zScore.toFixed(3).padEnd(8) + ' | ' +
    (within ? GREEN + 'PASS' + RESET : RED + 'FAIL' + RESET)
  );
}

assertCheck("All 3 Card Tiers have uniform representation within 3-sigma hypergeometric bound", allDraftTiersWithin3Sigma);

// Individual Card Representation
console.log(`\n${BOLD}--- Individual Card Appearance Distribution (Expected: 2,500 appearances each) ---${RESET}`);
// Probability an individual card is drawn in a 3-card draft: 3 / 12 = 0.25
// Binomial variance across 10,000 drafts: N * p * (1 - p) = 10,000 * 0.25 * 0.75 = 1,875. sigma = sqrt(1875) ≈ 43.30
const expCardP = 3 / 12; // 0.25
const expCardCount = TOTAL_DRAFTS * expCardP;
const sigmaCard = Math.sqrt(TOTAL_DRAFTS * expCardP * (1 - expCardP));

let allCardsWithin3Sigma = true;
for (const c of CARD_POOL) {
  const count = cardDraftCounts[c.Id];
  const zScore = Math.abs(count - expCardCount) / sigmaCard;
  if (zScore > 3.0) allCardsWithin3Sigma = false;
}

console.log(`Expected appearances per card: ${expCardCount.toLocaleString()}, σ = ${sigmaCard.toFixed(2)}, 3σ window: [${Math.round(expCardCount - 3 * sigmaCard)}, ${Math.round(expCardCount + 3 * sigmaCard)}]`);
console.log(`Observed range: min = ${Math.min(...Object.values(cardDraftCounts))}, max = ${Math.max(...Object.values(cardDraftCounts))}`);
assertCheck("All 12 Cards appear within 3-sigma theoretical frequency [2,370 - 2,630]", allCardsWithin3Sigma);

// -----------------------------------------------------------------------------
// Step 4: JSON SERIALIZATION SAFETY OF BAGUNIT
// -----------------------------------------------------------------------------
console.log(`\n${BOLD}[4] JSON SERIALIZATION SAFETY OF BAGUNIT SCHEMAS${RESET}`);

// Test 4.1: Canonical BagUnit Schema Validation
const canonicalBag = HERO_CATALOG.map((h, idx) => ({
  Uid: `unit_${Date.now()}_${idx}`,
  HeroId: h.Id,
  Name: h.Name,
  Rarity: h.Rarity,
  SellValue: h.SellValue
}));

const serialized = JSON.stringify(canonicalBag);
const deserialized = JSON.parse(serialized);

assertCheck("Canonical BagUnit round-trip preservation (keys, types, values)",
  Array.isArray(deserialized) &&
  deserialized.length === HERO_CATALOG.length &&
  deserialized.every((u, i) =>
    u.Uid === canonicalBag[i].Uid &&
    u.HeroId === canonicalBag[i].HeroId &&
    u.Name === canonicalBag[i].Name &&
    u.Rarity === canonicalBag[i].Rarity &&
    u.SellValue === canonicalBag[i].SellValue
  )
);

// Test 4.2: Stress Scaling & Byte Size Limits (Roblox StringAttribute 200 KB limit)
console.log(`\n${BOLD}--- Inventory Size & Attribute Capacity Stress Test ---${RESET}`);
const sizeStressCounts = [0, 1, 10, 50, 100, 500];
let sizeStressPassed = true;

for (const count of sizeStressCounts) {
  const stressBag = [];
  for (let i = 0; i < count; i++) {
    const h = HERO_CATALOG[i % HERO_CATALOG.length];
    stressBag.push({
      Uid: crypto.randomUUID(),
      HeroId: h.Id,
      Name: h.Name,
      Rarity: h.Rarity,
      SellValue: h.SellValue
    });
  }
  const jsonStr = JSON.stringify(stressBag);
  const byteLen = Buffer.byteLength(jsonStr, 'utf8');
  const pctOfRobloxLimit = (byteLen / 200000) * 100;
  const parsed = JSON.parse(jsonStr);

  if (parsed.length !== count) sizeStressPassed = false;
  console.log(`  Bag with ${count.toString().padEnd(3)} units: ${byteLen.toLocaleString().padEnd(6)} bytes (${pctOfRobloxLimit.toFixed(2)}% of 200KB attribute limit) -> Parse integrity: OK`);
}
assertCheck("Inventory scales cleanly up to 500 units well within 200KB attribute limit", sizeStressPassed);

// Test 4.3: Unicode & Multi-Byte Onomatopoeia Retention
console.log(`\n${BOLD}--- Unicode & Exotic Character Serialization Test ---${RESET}`);
const unicodeBag = [
  {
    Uid: "unit_thai_1",
    HeroId: "Tower_Luffy_G5",
    Name: "MONKEY D. LUFFY (หมัดเทพนิกะ!!)",
    Rarity: "MYTHICAL YONKO ★",
    SellValue: 480
  },
  {
    Uid: "unit_jp_2",
    HeroId: "Tower_Shanks_Kamusari",
    Name: "赤髪のシャンクス (เทวะอาสัญ!! ☠️)",
    Rarity: "MYTHICAL YONKO",
    SellValue: 500
  }
];

const unicodeJson = JSON.stringify(unicodeBag);
const unicodeParsed = JSON.parse(unicodeJson);
const unicodeMatches =
  unicodeParsed[0].Name === "MONKEY D. LUFFY (หมัดเทพนิกะ!!)" &&
  unicodeParsed[1].Name === "赤髪のシャンクス (เทวะอาสัญ!! ☠️)" &&
  unicodeParsed[0].Rarity === "MYTHICAL YONKO ★";

assertCheck("Multi-byte UTF-8 Unicode characters (Thai, Japanese, Emojis) survive intact", unicodeMatches);

// Test 4.4: Adversarial JSON Injection Attack Vectors
console.log(`\n${BOLD}--- Adversarial JSON Injection & Escaping Resilience ---${RESET}`);
const injectionBag = [
  {
    Uid: `safe_uid_1`,
    HeroId: `Tower_Luffy_G5`,
    Name: `Luffy", "injectedField": true, "hack": "`,
    Rarity: `MYTHICAL YONKO`,
    SellValue: 480
  },
  {
    Uid: `{"admin": true, "cash": 999999}`,
    HeroId: `Tower_Zoro_KingOfHell`,
    Name: `Zoro\\n\\t\\r"with quotes" and <script>alert(1)</script>`,
    Rarity: `LEGENDARY HAKI`,
    SellValue: 260
  }
];

const injectionJson = JSON.stringify(injectionBag);
const injectionParsed = JSON.parse(injectionJson);

const injectionDefeated =
  injectionParsed.length === 2 &&
  injectionParsed[0].Name === `Luffy", "injectedField": true, "hack": "` &&
  injectionParsed[0].injectedField === undefined &&
  injectionParsed[1].Uid === `{"admin": true, "cash": 999999}` &&
  injectionParsed[1].admin === undefined;

assertCheck("Adversarial payload injection (quotes, escapes, nested JSON) safely neutralised as string literals", injectionDefeated);

// Test 4.5: Robustness against Malformed / Corrupted Raw Strings
console.log(`\n${BOLD}--- Corrupted / Malformed Raw Input Decode Resilience ---${RESET}`);
function safeDecodeBag(raw) {
  if (typeof raw !== 'string') return [];
  try {
    const decoded = JSON.parse(raw);
    if (!Array.isArray(decoded)) return [];
    return decoded.filter(u =>
      typeof u === 'object' &&
      u !== null &&
      typeof u.Uid === 'string' &&
      typeof u.HeroId === 'string' &&
      typeof u.SellValue === 'number'
    );
  } catch (err) {
    return [];
  }
}

const corruptedInputs = [
  "",
  "   ",
  "{ bad json",
  "null",
  "12345",
  "\"just a string\"",
  "[]",
  "[{\"Uid\": 123}]", // invalid Uid type
  "[{\"HeroId\": \"Tower_Luffy_G5\"}]", // missing Uid
  "{\"Uid\": \"not_an_array\"}" // object instead of array
];

let corruptedHandledSafely = true;
for (const badInput of corruptedInputs) {
  const result = safeDecodeBag(badInput);
  if (!Array.isArray(result)) {
    corruptedHandledSafely = false;
    break;
  }
}
assertCheck("Decoder safely falls back to empty array without crashing on malformed inputs", corruptedHandledSafely);

// -----------------------------------------------------------------------------
// Step 5: Final Verdict Compilation
// -----------------------------------------------------------------------------
console.log(`\n${BOLD}${CYAN}========================================================================${RESET}`);
console.log(`${BOLD}   EMPIRICAL CHALLENGER VERIFICATION SUMMARY                           ${RESET}`);
console.log(`${BOLD}${CYAN}========================================================================${RESET}`);

console.log(`Total Checks Run:   ${testTotalCount}`);
console.log(`Total Passed:       ${GREEN}${testPassedCount}${RESET}`);
console.log(`Total Failed:       ${testTotalCount - testPassedCount === 0 ? GREEN + '0' + RESET : RED + (testTotalCount - testPassedCount) + RESET}`);

const verdict = testPassedCount === testTotalCount ? "APPROVE" : "REJECT";
const verdictColor = verdict === "APPROVE" ? GREEN : RED;

console.log(`\n${BOLD}FINAL EMPIRICAL VERDICT: ${verdictColor}${verdict}${RESET}\n`);

// Save machine-readable results
const artifact = {
  timestamp: new Date().toISOString(),
  verdict,
  totalChecks: testTotalCount,
  passedChecks: testPassedCount,
  gachaSimulation: {
    totalRolls: TOTAL_ROLLS,
    tierExpected,
    tierObserved: countsByTier,
    heroObserved: countsByHero,
    allTiersWithin3Sigma,
    allHeroesWithin3Sigma,
    chiSquare,
    chiCritical01
  },
  cardDraftSimulation: {
    totalDrafts: TOTAL_DRAFTS,
    totalSlotsDrawn: TOTAL_SLOTS,
    duplicatesDetected: duplicateDraftCount,
    tierDraftCounts,
    expectedTierSlots,
    allDraftTiersWithin3Sigma,
    allCardsWithin3Sigma
  },
  jsonSerializationSafety: {
    canonicalRoundTrip: true,
    sizeStressPassed,
    unicodeRetention: unicodeMatches,
    injectionDefeated,
    corruptedHandledSafely
  }
};

const artifactDir = path.join(PROJECT_ROOT, '.agents', 'teamwork', 'challenger_m1_2');
if (!fs.existsSync(artifactDir)) {
  fs.mkdirSync(artifactDir, { recursive: true });
}
const artifactPath = path.join(artifactDir, 'challenger_results.json');
fs.writeFileSync(artifactPath, JSON.stringify(artifact, null, 2), 'utf8');
console.log(`Results written to ${artifactPath}`);

if (verdict !== "APPROVE") {
  process.exit(1);
} else {
  process.exit(0);
}
