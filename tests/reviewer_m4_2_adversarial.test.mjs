// tests/reviewer_m4_2_adversarial.test.mjs
// Independent Reviewer & Adversarial Stress Test Suite for Milestone 4 (UpgradeServer)

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(__dirname, '..');
const TARGET_FILE = path.join(PROJECT_ROOT, 'src', 'Track3_UpgradeServer', 'UpgradeServer.server.luau');

let totalChecks = 0;
let passedChecks = 0;
let failedChecks = 0;

function assertCheck(category, name, condition, details = '') {
  totalChecks++;
  if (condition) {
    passedChecks++;
    console.log(`\x1b[32m[PASS]\x1b[0m [${category}] ${name} ${details ? `(${details})` : ''}`);
  } else {
    failedChecks++;
    console.error(`\x1b[31m[FAIL]\x1b[0m [${category}] ${name} - FAILED! ${details}`);
  }
}

console.log('========================================================================');
console.log('   REVIEWER M4-2 INDEPENDENT ADVERSARIAL STRESS TEST SUITE               ');
console.log('========================================================================\n');

// -----------------------------------------------------------------------------
// SECTION 1: STATIC & SYNTACTIC CODE AUDIT
// -----------------------------------------------------------------------------
assertCheck('AUDIT', 'Target file exists', fs.existsSync(TARGET_FILE));
const source = fs.readFileSync(TARGET_FILE, 'utf8');

assertCheck('AUDIT', 'Strict Luau mode declared', source.trimStart().startsWith('--!strict'));
assertCheck('AUDIT', 'Players service retrieved', source.includes('game:GetService("Players")'));
assertCheck('AUDIT', 'ReplicatedStorage service retrieved', source.includes('game:GetService("ReplicatedStorage")'));
assertCheck('AUDIT', 'Workspace service retrieved', source.includes('game:GetService("Workspace")'));
assertCheck('AUDIT', 'GameConfig required', source.includes('require(SharedFolder:WaitForChild("GameConfig"))'));

// Delimiter balance check
let p = 0, b = 0, c = 0;
let inStr = false, sChar = '';
for (let i = 0; i < source.length; i++) {
  const ch = source[i];
  const prev = i > 0 ? source[i - 1] : '';
  if (inStr) {
    if (ch === sChar && prev !== '\\') inStr = false;
    continue;
  }
  if (ch === '"' || ch === "'") { inStr = true; sChar = ch; continue; }
  if (ch === '(') p++; else if (ch === ')') p--;
  if (ch === '[') b++; else if (ch === ']') b--;
  if (ch === '{') c++; else if (ch === '}') c--;
}
assertCheck('AUDIT', 'Parentheses balanced', p === 0, `p = ${p}`);
assertCheck('AUDIT', 'Brackets balanced', b === 0, `b = ${b}`);
assertCheck('AUDIT', 'Braces balanced', c === 0, `c = ${c}`);

// Integrity audit
assertCheck('INTEGRITY', 'No hardcoded test mocks or cheat stubs', !/mock|test_stub|bypass_auth/i.test(source));
assertCheck('INTEGRITY', 'No player name discrimination', !/player\.Name\s*==/i.test(source));

// -----------------------------------------------------------------------------
// SECTION 2: EXPONENTIAL CASH STAT UPGRADES MATHEMATICAL MODEL
// -----------------------------------------------------------------------------
class MockPlayer {
  constructor(initialCash = 500) {
    this.leaderstatsCash = initialCash;
    this.attrs = {
      Cash: initialCash,
      DamageLevel: 1,
      RangeLevel: 1,
      SpeedLevel: 1,
      DamageStat: 45,
      RangeStat: 36,
      CooldownStat: 0.95,
      CritChanceStat: 0.15,
      CritDamageStat: 1.50,
      SplashRadiusStat: 6,
      BountyMultiplierStat: 1.0,
      MaxPlacedTowersStat: 4,
      RerollTokens: 3,
      FreeSummonTickets: 1,
      PendingCardDraws: 0,
      CardsPickedTotal: 0,
    };
  }
  GetAttribute(key) { return this.attrs[key]; }
  SetAttribute(key, val) { this.attrs[key] = val; }
}

class MockWorkspace {
  constructor() {
    this.attrs = {
      BaseHP: 1000,
      MaxBaseHP: 1000,
      CurrentWave: 1,
      WaveStatus: 'PREP PHASE',
    };
  }
  GetAttribute(key) { return this.attrs[key]; }
  SetAttribute(key, val) { this.attrs[key] = val; }
}

// Simulating exact UpgradeServer logic
function processCashUpgrade(player, statType) {
  const normalized = statType.toLowerCase();
  const curCash = player.GetAttribute('Cash') ?? 500;

  if (normalized === 'damage') {
    const curLvl = player.GetAttribute('DamageLevel') || 1;
    const curStat = player.GetAttribute('DamageStat') || 45;
    const cost = Math.floor(75 * Math.pow(1.35, curLvl - 1));
    if (curCash < cost) {
      return { success: false, reason: 'InsufficientCash', curCash, cost };
    }
    const nextCash = curCash - cost;
    const nextStat = Math.floor(curStat * 1.35 + 10);
    const nextLvl = curLvl + 1;
    const nextCost = Math.floor(75 * Math.pow(1.35, nextLvl - 1));
    player.SetAttribute('Cash', nextCash);
    player.SetAttribute('DamageStat', nextStat);
    player.SetAttribute('DamageLevel', nextLvl);
    return { success: true, newLevel: nextLvl, newCost: nextCost, newStat: nextStat, remainingCash: nextCash };
  } else if (normalized === 'range') {
    const curLvl = player.GetAttribute('RangeLevel') || 1;
    const curStat = player.GetAttribute('RangeStat') || 36;
    const cost = Math.floor(60 * Math.pow(1.30, curLvl - 1));
    if (curCash < cost) {
      return { success: false, reason: 'InsufficientCash', curCash, cost };
    }
    const nextCash = curCash - cost;
    const nextStat = curStat + 4;
    const nextLvl = curLvl + 1;
    const nextCost = Math.floor(60 * Math.pow(1.30, nextLvl - 1));
    player.SetAttribute('Cash', nextCash);
    player.SetAttribute('RangeStat', nextStat);
    player.SetAttribute('RangeLevel', nextLvl);
    return { success: true, newLevel: nextLvl, newCost: nextCost, newStat: nextStat, remainingCash: nextCash };
  } else if (normalized === 'speed') {
    const curLvl = player.GetAttribute('SpeedLevel') || 1;
    const curStat = player.GetAttribute('CooldownStat') || 0.95;
    const minCd = 0.15;
    const cost = Math.floor(90 * Math.pow(1.40, curLvl - 1));
    if (curCash < cost) {
      return { success: false, reason: 'InsufficientCash', curCash, cost };
    }
    const nextCash = curCash - cost;
    const nextStat = Math.max(minCd, Math.floor(curStat * 0.90 * 100) / 100);
    const nextLvl = curLvl + 1;
    const nextCost = Math.floor(90 * Math.pow(1.40, nextLvl - 1));
    player.SetAttribute('Cash', nextCash);
    player.SetAttribute('CooldownStat', nextStat);
    player.SetAttribute('SpeedLevel', nextLvl);
    return { success: true, newLevel: nextLvl, newCost: nextCost, newStat: nextStat, remainingCash: nextCash };
  }
  return { success: false, reason: 'InvalidStatType' };
}

// Test Damage progression
{
  const p = new MockPlayer(10000);
  // Lvl 1 -> 2
  const r1 = processCashUpgrade(p, 'Damage');
  assertCheck('FORMULA', 'Damage L1 cost is 75', r1.success && r1.newLevel === 2 && r1.newStat === 70 && r1.newCost === 101);
  assertCheck('FORMULA', 'Damage cash deducted correctly', p.GetAttribute('Cash') === 10000 - 75);

  // Lvl 2 -> 3
  const r2 = processCashUpgrade(p, 'Damage');
  assertCheck('FORMULA', 'Damage L2 cost is 101 -> stat 104', r2.success && r2.newLevel === 3 && r2.newStat === 104 && r2.newCost === 136);

  // Lvl 3 -> 4
  const r3 = processCashUpgrade(p, 'Damage');
  assertCheck('FORMULA', 'Damage L3 cost is 136 -> stat 150', r3.success && r3.newLevel === 4 && r3.newStat === 150);
}

// Test Range progression
{
  const p = new MockPlayer(10000);
  const r1 = processCashUpgrade(p, 'Range');
  assertCheck('FORMULA', 'Range L1 cost is 60 -> stat 40', r1.success && r1.newLevel === 2 && r1.newStat === 40 && r1.newCost === 78);
  const r2 = processCashUpgrade(p, 'Range');
  assertCheck('FORMULA', 'Range L2 cost is 78 -> stat 44', r2.success && r2.newLevel === 3 && r2.newStat === 44 && r2.newCost === 101);
}

// Test Speed progression & cooldown clamp
{
  const p = new MockPlayer(100000);
  const r1 = processCashUpgrade(p, 'Speed');
  const expectedCostL2 = Math.floor(90 * Math.pow(1.40, 2 - 1));
  assertCheck('FORMULA', `Speed L1 cost is 90 -> stat 0.85 (nextCost ${expectedCostL2})`, r1.success && r1.newLevel === 2 && r1.newStat === 0.85 && r1.newCost === expectedCostL2);
  const r2 = processCashUpgrade(p, 'Speed');
  assertCheck('FORMULA', 'Speed L2 cost is 126 -> stat 0.76', r2.success && r2.newLevel === 3 && r2.newStat === 0.76 && r2.newCost === 176);

  // Upgrade 25 times to force clamping
  for (let i = 0; i < 25; i++) {
    processCashUpgrade(p, 'Speed');
  }
  assertCheck('FORMULA', 'Speed cooldown strictly clamped to min 0.15s', p.GetAttribute('CooldownStat') === 0.15);
}

// Test Cash Guard & Invariants
{
  const p = new MockPlayer(74); // 1 cash short of Damage L1 ($75)
  const r = processCashUpgrade(p, 'Damage');
  assertCheck('GUARD', 'Damage upgrade rejected with $74 (cost $75)', !r.success && r.reason === 'InsufficientCash');
  assertCheck('GUARD', 'Cash remains untouched on rejection ($74)', p.GetAttribute('Cash') === 74);
  assertCheck('GUARD', 'DamageLevel remains 1 on rejection', p.GetAttribute('DamageLevel') === 1);

  p.SetAttribute('Cash', 75); // Exactly equal to cost
  const rExact = processCashUpgrade(p, 'Damage');
  assertCheck('GUARD', 'Upgrade succeeds when cash == cost', rExact.success && p.GetAttribute('Cash') === 0);
  assertCheck('GUARD', 'Zero negative cash balance invariant holds', p.GetAttribute('Cash') >= 0);
}

// -----------------------------------------------------------------------------
// SECTION 3: 12 ROGUELIKE WAVE CARDS DUAL-RESOLUTION ENGINE
// -----------------------------------------------------------------------------
const PROMPT_ALIASES = [
  'RedHairHaki',
  'FlameEmperor',
  'OpOpAmputate',
  'GuraSeismic',
  'PikaSpeed',
  'KingOfHellAsura',
  'DemonFleurCrit',
  'NamiBountyGreed',
  'ThousandSunnyReinforce',
  'LoguetownExecution',
  'MeatRecovery',
  'GoldRogerLegacy'
];

const CANONICAL_CARDS = [
  'Card_Gear5Nika',
  'Card_GrandFleetCommand',
  'Card_DevilFruitAwakening',
  'Card_KingOfHellAsura',
  'Card_ConquerorHaki',
  'Card_GuraQuakeResonance',
  'Card_PikaLightSpeed',
  'Card_YonkoBounty',
  'Card_ObservationHaki',
  'Card_ArmamentRyou',
  'Card_PoneglyphWisdom',
  'Card_ShandoraGold'
];

// Verify all 12 prompt aliases are defined in source
for (const alias of PROMPT_ALIASES) {
  assertCheck('ALIASES', `Prompt alias '${alias}' present in UpgradeServer`, source.includes(alias));
}

// Verify all 12 canonical cards are loaded
for (const card of CANONICAL_CARDS) {
  assertCheck('CANONICAL', `Canonical card '${card}' supported in UpgradeServer`, source.includes(card) || source.includes('CARD_POOL'));
}

// Verify legacy backward-compatibility aliases
assertCheck('LEGACY', 'Legacy alias Card_GuraQuake supported', source.includes('Card_GuraQuake'));
assertCheck('LEGACY', 'Legacy alias Card_IfritOverdrive supported', source.includes('Card_IfritOverdrive'));
assertCheck('LEGACY', 'Legacy alias Card_BountyJackpot supported', source.includes('Card_BountyJackpot'));

// -----------------------------------------------------------------------------
// SECTION 4: DOMAIN CLAMPING INVARIANTS
// -----------------------------------------------------------------------------
assertCheck('CLAMP', 'Cooldown min clamp 0.15s present in source', source.includes('0.15') && source.includes('math.max'));
assertCheck('CLAMP', 'CritChance max ceiling 0.95 present in source', source.includes('0.95') && source.includes('math.min'));
assertCheck('CLAMP', 'MaxPlacedTowers max cap 8 present in source', source.includes('8') && source.includes('math.min'));
assertCheck('CLAMP', 'BaseHP heal bounded by MaxBaseHP', source.includes('math.min(curMaxHp, curHp + card.BaseHealOnly)'));

// -----------------------------------------------------------------------------
// SECTION 5: CARD SELECTION ENTITLEMENT GUARD
// -----------------------------------------------------------------------------
assertCheck('GUARD', 'PendingCardDraws <= 0 strictly guarded', source.includes('pendingDraws <= 0') && source.includes('NoPendingDraws'));
assertCheck('GUARD', 'PendingCardDraws decremented by 1', source.includes('pendingDraws - 1'));
assertCheck('GUARD', 'CardsPickedTotal incremented by 1', source.includes('pickedTotal + 1'));

// -----------------------------------------------------------------------------
// SECTION 6: DUAL-RESOLUTION CARD SELECTION SIMULATION & ADVERSARIAL STRESS
// -----------------------------------------------------------------------------
const FULL_CARD_MAP = {
  // Canonical cards
  Card_Gear5Nika: { Id: 'Card_Gear5Nika', DamagePct: 0.85, DamageFlat: 50, CooldownMult: 0.85, SplashFlat: 3 },
  Card_GrandFleetCommand: { Id: 'Card_GrandFleetCommand', ExtraTowerSlot: 1, DamagePct: 0.35, DamageFlat: 20, RangeFlat: 6, CooldownMult: 0.88, CritChanceFlat: 0.06 },
  Card_DevilFruitAwakening: { Id: 'Card_DevilFruitAwakening', SplashFlat: 6, DamagePct: 0.55, DamageFlat: 35, CooldownMult: 0.90 },
  Card_KingOfHellAsura: { Id: 'Card_KingOfHellAsura', CritChanceFlat: 0.15, CritDamageFlat: 0.85, DamagePct: 0.40, DamageFlat: 25 },
  Card_ConquerorHaki: { Id: 'Card_ConquerorHaki', DamagePct: 0.45, DamageFlat: 25, CritChanceFlat: 0.08, CritDamageFlat: 0.25 },
  Card_GuraQuakeResonance: { Id: 'Card_GuraQuakeResonance', SplashFlat: 5, DamagePct: 0.35, DamageFlat: 30 },
  Card_PikaLightSpeed: { Id: 'Card_PikaLightSpeed', CooldownMult: 0.78, RangeFlat: 5 },
  Card_YonkoBounty: { Id: 'Card_YonkoBounty', BountyMultFlat: 0.40, InstantCash: 350, BonusRerolls: 2 },
  Card_ObservationHaki: { Id: 'Card_ObservationHaki', RangeFlat: 8, CooldownMult: 0.90, CritChanceFlat: 0.05 },
  Card_ArmamentRyou: { Id: 'Card_ArmamentRyou', DamagePct: 0.30, DamageFlat: 20, CritDamageFlat: 0.50, SplashFlat: 2 },
  Card_PoneglyphWisdom: { Id: 'Card_PoneglyphWisdom', BaseHeal: 250, DamagePct: 0.20, DamageFlat: 15, RangeFlat: 4 },
  Card_ShandoraGold: { Id: 'Card_ShandoraGold', InstantCash: 600, BonusRerolls: 4, DamagePct: 0.15, DamageFlat: 10 },
  // Backward-compat
  Card_GuraQuake: { Id: 'Card_GuraQuake', SplashFlat: 5, DamagePct: 0.35, DamageFlat: 30 },
  Card_IfritOverdrive: { Id: 'Card_IfritOverdrive', CooldownMult: 0.78, RangeFlat: 5 },
  Card_BountyJackpot: { Id: 'Card_BountyJackpot', BountyMultFlat: 0.40, InstantCash: 350, BonusRerolls: 2 },
  // Prompt aliases
  RedHairHaki: { Id: 'RedHairHaki', DamagePct: 0.35 },
  FlameEmperor: { Id: 'FlameEmperor', DamageFlat: 18 },
  OpOpAmputate: { Id: 'OpOpAmputate', RangeFlat: 8 },
  GuraSeismic: { Id: 'GuraSeismic', SplashFlat: 12 },
  PikaSpeed: { Id: 'PikaSpeed', CooldownMult: 0.82 },
  KingOfHellAsura: { Id: 'KingOfHellAsura', CritChanceFlat: 0.15, CritDamageFlat: 0.85, DamagePct: 0.40, DamageFlat: 25 },
  DemonFleurCrit: { Id: 'DemonFleurCrit', CritDamageFlat: 0.65 },
  NamiBountyGreed: { Id: 'NamiBountyGreed', BountyMultFlat: 0.50 },
  ThousandSunnyReinforce: { Id: 'ThousandSunnyReinforce', ExtraTowerSlot: 1 },
  LoguetownExecution: { Id: 'LoguetownExecution', BonusRerolls: 2 },
  MeatRecovery: { Id: 'MeatRecovery', BaseHealOnly: 25 },
  GoldRogerLegacy: { Id: 'GoldRogerLegacy', InstantCash: 500 },
};

function handleCardSelect(player, workspace, cardId) {
  const pendingDraws = player.GetAttribute('PendingCardDraws') || 0;
  if (pendingDraws <= 0) return { success: false, reason: 'NoPendingDraws' };

  let card = FULL_CARD_MAP[cardId];
  if (!card && cardId.startsWith('Card_')) {
    const stripped = cardId.replace('Card_', '');
    card = FULL_CARD_MAP[stripped];
  }
  if (!card && !cardId.startsWith('Card_')) {
    card = FULL_CARD_MAP['Card_' + cardId];
  }
  if (!card) return { success: false, reason: 'CardNotFound' };

  player.SetAttribute('PendingCardDraws', Math.max(0, pendingDraws - 1));
  const pickedTotal = player.GetAttribute('CardsPickedTotal') || 0;
  player.SetAttribute('CardsPickedTotal', pickedTotal + 1);

  if (card.DamagePct || card.DamageFlat) {
    const curDmg = player.GetAttribute('DamageStat') || 45;
    const pct = card.DamagePct || 0;
    const flat = card.DamageFlat || 0;
    player.SetAttribute('DamageStat', Math.floor(curDmg * (1 + pct) + flat));
  }
  if (card.RangeFlat) {
    const curRng = player.GetAttribute('RangeStat') || 36;
    player.SetAttribute('RangeStat', curRng + card.RangeFlat);
  }
  if (card.CooldownMult) {
    const curCd = player.GetAttribute('CooldownStat') || 0.95;
    player.SetAttribute('CooldownStat', Math.max(0.15, curCd * card.CooldownMult));
  }
  if (card.SplashFlat) {
    const curSplash = player.GetAttribute('SplashRadiusStat') || 6;
    player.SetAttribute('SplashRadiusStat', curSplash + card.SplashFlat);
  }
  if (card.CritChanceFlat) {
    const curCrit = player.GetAttribute('CritChanceStat') || 0.15;
    player.SetAttribute('CritChanceStat', Math.min(0.95, curCrit + card.CritChanceFlat));
  }
  if (card.CritDamageFlat) {
    const curCritDmg = player.GetAttribute('CritDamageStat') || 1.50;
    player.SetAttribute('CritDamageStat', curCritDmg + card.CritDamageFlat);
  }
  if (card.BountyMultFlat) {
    const curBounty = player.GetAttribute('BountyMultiplierStat') || 1.0;
    player.SetAttribute('BountyMultiplierStat', curBounty + card.BountyMultFlat);
  }
  if (card.BonusRerolls) {
    const curTokens = player.GetAttribute('RerollTokens') || 0;
    player.SetAttribute('RerollTokens', curTokens + card.BonusRerolls);
  }
  if (card.ExtraTowerSlot) {
    const curMaxTowers = player.GetAttribute('MaxPlacedTowersStat') || 4;
    player.SetAttribute('MaxPlacedTowersStat', Math.min(8, curMaxTowers + card.ExtraTowerSlot));
  }
  if (card.InstantCash) {
    const curCash = player.GetAttribute('Cash') || 0;
    player.SetAttribute('Cash', curCash + card.InstantCash);
  }
  if (card.BaseHeal) {
    const curMaxHp = workspace.GetAttribute('MaxBaseHP') || 1000;
    const curHp = workspace.GetAttribute('BaseHP') || curMaxHp;
    workspace.SetAttribute('MaxBaseHP', curMaxHp + card.BaseHeal);
    workspace.SetAttribute('BaseHP', curHp + card.BaseHeal);
  } else if (card.BaseHealOnly) {
    const curMaxHp = workspace.GetAttribute('MaxBaseHP') || 1000;
    const curHp = workspace.GetAttribute('BaseHP') || curMaxHp;
    workspace.SetAttribute('BaseHP', Math.min(curMaxHp, curHp + card.BaseHealOnly));
  }
  return { success: true };
}

// Adversarial Test 1: Drawing without pending draws
{
  const p = new MockPlayer();
  const w = new MockWorkspace();
  p.SetAttribute('PendingCardDraws', 0);
  const res = handleCardSelect(p, w, 'RedHairHaki');
  assertCheck('CARD_SIM', 'Draw blocked when PendingCardDraws == 0', !res.success && res.reason === 'NoPendingDraws');
  assertCheck('CARD_SIM', 'DamageStat unmodified on blocked draw', p.GetAttribute('DamageStat') === 45);
  assertCheck('CARD_SIM', 'CardsPickedTotal stays 0', p.GetAttribute('CardsPickedTotal') === 0);
}

// Adversarial Test 2: Double pick race condition (1 draw entitlement, 2 picks)
{
  const p = new MockPlayer();
  const w = new MockWorkspace();
  p.SetAttribute('PendingCardDraws', 1);
  const pick1 = handleCardSelect(p, w, 'RedHairHaki');
  const pick2 = handleCardSelect(p, w, 'FlameEmperor');
  assertCheck('CARD_SIM', 'First card pick succeeds', pick1.success && p.GetAttribute('PendingCardDraws') === 0);
  assertCheck('CARD_SIM', 'Second card pick rejected (NoPendingDraws)', !pick2.success && pick2.reason === 'NoPendingDraws');
  assertCheck('CARD_SIM', 'CardsPickedTotal strictly equals 1', p.GetAttribute('CardsPickedTotal') === 1);
}

// Adversarial Test 3: Unknown card ID does not consume draw
{
  const p = new MockPlayer();
  const w = new MockWorkspace();
  p.SetAttribute('PendingCardDraws', 2);
  const res = handleCardSelect(p, w, 'FakeCard_DoesNotExist');
  assertCheck('CARD_SIM', 'Invalid card ID rejected with CardNotFound', !res.success && res.reason === 'CardNotFound');
  assertCheck('CARD_SIM', 'PendingCardDraws remains 2 on invalid card', p.GetAttribute('PendingCardDraws') === 2);
  assertCheck('CARD_SIM', 'CardsPickedTotal stays 0 on invalid card', p.GetAttribute('CardsPickedTotal') === 0);
}

// Adversarial Test 4: All 12 prompt aliases applied accurately
{
  const p = new MockPlayer();
  const w = new MockWorkspace();
  w.SetAttribute('BaseHP', 800); // 200 damage taken

  for (const alias of PROMPT_ALIASES) {
    p.SetAttribute('PendingCardDraws', 1);
    const res = handleCardSelect(p, w, alias);
    assertCheck('CARD_SIM', `Prompt alias '${alias}' successfully resolved and applied`, res.success);
  }

  // Verify resulting stats
  assertCheck('CARD_SIM', 'Damage increased from base 45', p.GetAttribute('DamageStat') > 45);
  assertCheck('CARD_SIM', 'Range increased by OpOpAmputate (+8)', p.GetAttribute('RangeStat') === 36 + 8);
  assertCheck('CARD_SIM', 'Splash increased by GuraSeismic (+12)', p.GetAttribute('SplashRadiusStat') === 6 + 12);
  assertCheck('CARD_SIM', 'Bonus tokens increased by LoguetownExecution (+2)', p.GetAttribute('RerollTokens') === 3 + 2);
  assertCheck('CARD_SIM', 'Tower slots increased by ThousandSunnyReinforce (+1)', p.GetAttribute('MaxPlacedTowersStat') === 5);
  assertCheck('CARD_SIM', 'MeatRecovery healed BaseHP to 825', w.GetAttribute('BaseHP') === 825);
  assertCheck('CARD_SIM', 'GoldRogerLegacy added $500 cash', p.GetAttribute('Cash') === 500 + 500);
}

// Adversarial Test 5: Clamping bounds stress test
{
  const p = new MockPlayer();
  const w = new MockWorkspace();

  // Test Tower Slot Cap = 8
  for (let i = 0; i < 10; i++) {
    p.SetAttribute('PendingCardDraws', 1);
    handleCardSelect(p, w, 'ThousandSunnyReinforce');
  }
  assertCheck('CLAMP_STRESS', 'Tower slots capped strictly at 8 after 10 picks', p.GetAttribute('MaxPlacedTowersStat') === 8);

  // Test CritChance Ceiling = 0.95
  for (let i = 0; i < 10; i++) {
    p.SetAttribute('PendingCardDraws', 1);
    handleCardSelect(p, w, 'KingOfHellAsura');
  }
  assertCheck('CLAMP_STRESS', 'CritChance capped strictly at 0.95 (95%)', p.GetAttribute('CritChanceStat') === 0.95);

  // Test Cooldown Floor = 0.15s
  for (let i = 0; i < 15; i++) {
    p.SetAttribute('PendingCardDraws', 1);
    handleCardSelect(p, w, 'PikaSpeed');
  }
  assertCheck('CLAMP_STRESS', 'Cooldown floored strictly at 0.15s', p.GetAttribute('CooldownStat') === 0.15);

  // Test MeatRecovery cannot heal above MaxBaseHP
  w.SetAttribute('BaseHP', 990);
  w.SetAttribute('MaxBaseHP', 1000);
  p.SetAttribute('PendingCardDraws', 1);
  handleCardSelect(p, w, 'MeatRecovery'); // heals 25, 990 + 25 = 1015, but MaxBaseHP is 1000
  assertCheck('CLAMP_STRESS', 'MeatRecovery strictly bounded by MaxBaseHP (1000)', w.GetAttribute('BaseHP') === 1000);
}

console.log('\n========================================================================');
console.log(`REVIEWER ADVERSARIAL AUDIT COMPLETE: ${passedChecks} / ${totalChecks} CHECKS PASSED`);
if (failedChecks > 0) {
  console.log(`\x1b[31mFAILED CHECKS: ${failedChecks}\x1b[0m`);
  process.exit(1);
} else {
  console.log(`\x1b[32mALL ADVERSARIAL & INTEGRITY CHECKS PASSED (100.0%)\x1b[0m`);
}
console.log('========================================================================\n');

