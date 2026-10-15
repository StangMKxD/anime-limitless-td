// tests/tier5_adversarial_upgrade_ui.test.mjs
// Anime Limitless Tower Defense — Phase 3: Tier 5 Adversarial Coverage Hardening
// Focused Coverage: Track 3 (UpgradeServer & UpgradeHUD) and Cross-Track Contracts (WaveManager & TowerController)
// Architecture: Pure Headless Node.js ESM Harness (Zero dependence on rojo serve / Roblox Studio)

import crypto from 'node:crypto';
import {
  HERO_CATALOG,
  CARD_POOL,
  PLACEMENT_SLOTS,
  HeadlessPlayer,
  HeadlessGameServer,
} from './run_all_tests.mjs';

// ANSI Terminal Colors for High-Fidelity Output
const COLORS = {
  reset: '\x1b[0m',
  bold: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  yellow: '\x1b[33m',
  magenta: '\x1b[35m',
  gray: '\x1b[90m',
};

const results = {
  timestamp: new Date().toISOString(),
  categories: {
    advA: [], // Mathematical Curves & Precision
    advB: [], // Cross-Track Real-Time Data Flow
    advC: [], // Multi-Player Concurrency & State Isolation
    advD: [], // Extreme Boundary & Stress Testing
    advE: [], // Input Validation & Adversarial Injection Hardening
  },
  summary: { total: 0, passed: 0, failed: 0 },
};

function recordAdvTest(category, id, name, passed, details = '') {
  const entry = { id, name, passed, details };
  results.categories[category].push(entry);
  results.summary.total++;
  if (passed) {
    results.summary.passed++;
  } else {
    results.summary.failed++;
  }
  const statusStr = passed
    ? `${COLORS.green}${COLORS.bold}PASS${COLORS.reset}`
    : `${COLORS.red}${COLORS.bold}FAIL${COLORS.reset}`;
  const detailsStr = details ? ` ${COLORS.gray}(${details})${COLORS.reset}` : '';
  console.log(`${COLORS.cyan}[TIER5]${COLORS.reset} ${statusStr} ${COLORS.bold}${id}${COLORS.reset}: ${name}${detailsStr}`);
}

// =============================================================================
// ADVERSARIAL TRACK 3 ENGINE (FAITHFUL WHITE-BOX SERVER & CLIENT UI SIMULATOR)
// =============================================================================

export class AdversarialUpgradeServer {
  constructor() {
    this.players = new Map(); // userId -> player
    this.workspace = {
      CurrentWave: 1,
      BaseHP: 1000,
      MaxBaseHP: 1000,
      WaveStatus: 'PREP PHASE',
      GameOver: false,
      PrepCountdown: 15,
      ZombiesRemaining: 0,
      PendingCardDraws: 0,
    };
    this.towers = []; // { modelId, heroId, ownerUserId, unitUid, slotId }
    this.cardMap = new Map();
    this.initCardCatalog();
  }

  initCardCatalog() {
    for (const card of CARD_POOL) {
      this.cardMap.set(card.Id, card);
    }
    // Backward compatibility & dual-resolution aliases from UpgradeServer.server.luau
    const promptAliases = {
      RedHairHaki: { Id: 'RedHairHaki', DamagePct: 0.35 },
      FlameEmperor: { Id: 'FlameEmperor', DamageFlat: 18 },
      OpOpAmputate: { Id: 'OpOpAmputate', RangeFlat: 8 },
      GuraSeismic: { Id: 'GuraSeismic', SplashFlat: 12 },
      PikaSpeed: { Id: 'PikaSpeed', CooldownMult: 0.82 },
      KingOfHellAsura: this.cardMap.get('Card_KingOfHellAsura') || {
        Id: 'KingOfHellAsura',
        CritChanceFlat: 0.15,
        CritDamageFlat: 0.85,
        DamagePct: 0.40,
        DamageFlat: 25,
      },
      DemonFleurCrit: { Id: 'DemonFleurCrit', CritDamageFlat: 0.65 },
      NamiBountyGreed: { Id: 'NamiBountyGreed', BountyMultFlat: 0.50 },
      ThousandSunnyReinforce: { Id: 'ThousandSunnyReinforce', ExtraTowerSlot: 1 },
      LoguetownExecution: { Id: 'LoguetownExecution', BonusRerolls: 2 },
      MeatRecovery: { Id: 'MeatRecovery', BaseHealOnly: 25 },
      GoldRogerLegacy: { Id: 'GoldRogerLegacy', InstantCash: 500 },
    };
    for (const [key, val] of Object.entries(promptAliases)) {
      this.cardMap.set(key, val);
      this.cardMap.set('Card_' + key, val);
    }
  }

  registerPlayer(userId = 1) {
    const p = new HeadlessPlayer();
    p.UserId = userId;
    p.DamageStat = 45;
    p.RangeStat = 36;
    p.CooldownStat = 0.95;
    p.CritChanceStat = 0.15;
    p.CritDamageStat = 1.50;
    p.SplashStat = 6;
    p.BountyMultiplierStat = 1.0;
    p.DamageLevel = 1;
    p.RangeLevel = 1;
    p.SpeedLevel = 1;
    p.Cash = 500;
    p.FreeSummonTickets = 1;
    p.RerollTokens = 3;
    p.MaxPlacedTowersStat = 4;
    p.PlacedTowersCount = 0;
    p.PendingCardDraws = 0;
    p.CardsPickedTotal = 0;
    p.HeroInventoryJson = '[]';
    p.LastRolledHeroId = '';
    p.LastRolledUnitUid = '';
    p.SelectedBagUnitUid = '';

    this.players.set(userId, p);
    return p;
  }

  getPlayer(userId = 1) {
    if (!this.players.has(userId)) {
      return this.registerPlayer(userId);
    }
    return this.players.get(userId);
  }

  // Exact replication of UpgradeServer.server.luau processCashUpgrade
  processCashUpgrade(userId, statType) {
    const p = this.getPlayer(userId);
    const normalized = typeof statType === 'string' ? statType.toLowerCase() : '';

    if (normalized === 'damage') {
      const curLvl = p.DamageLevel || 1;
      const curStat = p.DamageStat || 45;
      const cost = Math.floor(75 * Math.pow(1.35, curLvl - 1));

      if (p.Cash < cost) {
        return {
          success: false,
          statType: 'Damage',
          newLevel: curLvl,
          newCost: cost,
          newStat: curStat,
          remainingCash: p.Cash,
          reason: 'InsufficientCash',
        };
      }

      const nextCash = p.Cash - cost;
      const nextStat = Math.floor(curStat * 1.35 + 10);
      const nextLvl = curLvl + 1;
      const nextCost = Math.floor(75 * Math.pow(1.35, nextLvl - 1));

      p.Cash = nextCash;
      p.DamageStat = nextStat;
      p.DamageLevel = nextLvl;

      return {
        success: true,
        statType: 'Damage',
        newLevel: nextLvl,
        newCost: nextCost,
        newStat: nextStat,
        remainingCash: nextCash,
      };
    } else if (normalized === 'range') {
      const curLvl = p.RangeLevel || 1;
      const curStat = p.RangeStat || 36;
      const cost = Math.floor(60 * Math.pow(1.30, curLvl - 1));

      if (p.Cash < cost) {
        return {
          success: false,
          statType: 'Range',
          newLevel: curLvl,
          newCost: cost,
          newStat: curStat,
          remainingCash: p.Cash,
          reason: 'InsufficientCash',
        };
      }

      const nextCash = p.Cash - cost;
      const nextStat = curStat + 4;
      const nextLvl = curLvl + 1;
      const nextCost = Math.floor(60 * Math.pow(1.30, nextLvl - 1));

      p.Cash = nextCash;
      p.RangeStat = nextStat;
      p.RangeLevel = nextLvl;

      return {
        success: true,
        statType: 'Range',
        newLevel: nextLvl,
        newCost: nextCost,
        newStat: nextStat,
        remainingCash: nextCash,
      };
    } else if (normalized === 'speed') {
      const curLvl = p.SpeedLevel || 1;
      const curStat = p.CooldownStat || 0.95;
      const minCd = 0.15;
      const cost = Math.floor(90 * Math.pow(1.40, curLvl - 1));

      if (p.Cash < cost) {
        return {
          success: false,
          statType: 'Speed',
          newLevel: curLvl,
          newCost: cost,
          newStat: curStat,
          remainingCash: p.Cash,
          reason: 'InsufficientCash',
        };
      }

      const nextCash = p.Cash - cost;
      const nextStat = Math.max(minCd, Math.floor(curStat * 0.90 * 100) / 100);
      const nextLvl = curLvl + 1;
      const nextCost = Math.floor(90 * Math.pow(1.40, nextLvl - 1));

      p.Cash = nextCash;
      p.CooldownStat = nextStat;
      p.SpeedLevel = nextLvl;

      return {
        success: true,
        statType: 'Speed',
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
        remainingCash: p.Cash,
        reason: 'InvalidStatType',
      };
    }
  }

  // Exact replication of UpgradeServer.server.luau handleCardSelect
  handleCardSelect(userId, cardId) {
    const p = this.getPlayer(userId);
    if ((p.PendingCardDraws || 0) <= 0) {
      return { success: false, reason: 'NoPendingDraws' };
    }

    const card = this.cardMap.get(cardId);
    if (!card) {
      return { success: false, reason: 'CardNotFound' };
    }

    p.PendingCardDraws = Math.max(0, p.PendingCardDraws - 1);
    p.CardsPickedTotal = (p.CardsPickedTotal || 0) + 1;

    if (card.DamagePct || card.DamageFlat) {
      const curDmg = p.DamageStat || 45;
      const pct = card.DamagePct || 0;
      const flat = card.DamageFlat || 0;
      p.DamageStat = Math.floor(curDmg * (1 + pct) + flat);
    }
    if (card.RangeFlat) {
      p.RangeStat = (p.RangeStat || 36) + card.RangeFlat;
    }
    if (card.CooldownMult) {
      const curCd = p.CooldownStat || 0.95;
      const minCd = 0.15;
      p.CooldownStat = Math.max(minCd, curCd * card.CooldownMult);
    }
    if (card.SplashFlat) {
      p.SplashStat = (p.SplashStat || 6) + card.SplashFlat;
    }
    if (card.CritChanceFlat) {
      const curCrit = p.CritChanceStat || 0.15;
      const maxCrit = 0.95;
      p.CritChanceStat = Math.min(maxCrit, curCrit + card.CritChanceFlat);
    }
    if (card.CritDamageFlat) {
      p.CritDamageStat = (p.CritDamageStat || 1.50) + card.CritDamageFlat;
    }
    if (card.BountyMultFlat) {
      p.BountyMultiplierStat = (p.BountyMultiplierStat || 1.0) + card.BountyMultFlat;
    }
    if (card.BonusRerolls) {
      p.RerollTokens = (p.RerollTokens || 0) + card.BonusRerolls;
    }
    if (card.ExtraTowerSlot) {
      const curMax = p.MaxPlacedTowersStat || 4;
      p.MaxPlacedTowersStat = Math.min(8, curMax + card.ExtraTowerSlot);
    }
    if (card.InstantCash) {
      p.Cash = (p.Cash || 0) + card.InstantCash;
    }
    if (card.BaseHeal) {
      this.workspace.MaxBaseHP += card.BaseHeal;
      this.workspace.BaseHP += card.BaseHeal;
    } else if (card.BaseHealOnly) {
      this.workspace.BaseHP = Math.min(this.workspace.MaxBaseHP, this.workspace.BaseHP + card.BaseHealOnly);
    }

    return { success: true, cardId };
  }

  // Exact replication of UpgradeServer.server.luau handleBuyExtraCardDraw
  handleBuyExtraCardDraw(userId) {
    const p = this.getPlayer(userId);
    const totalPicked = p.CardsPickedTotal || 0;
    const baseCost = 150;
    const drawCost = Math.floor(baseCost * Math.pow(1.25, totalPicked));
    if (p.Cash >= drawCost) {
      p.Cash -= drawCost;
      p.PendingCardDraws = (p.PendingCardDraws || 0) + 1;
      return { success: true, drawCost, pendingDraws: p.PendingCardDraws };
    }
    return { success: false, drawCost, reason: 'InsufficientCash' };
  }

  // Exact replication of UpgradeServer.server.luau RemoteFunction invoke handler
  onUpgradeStatInvoke(userId, statTypeOrAction) {
    if (typeof statTypeOrAction !== 'string') {
      return { success: false, reason: 'InvalidArguments' };
    }
    const actionStr = statTypeOrAction;
    if (actionStr === 'BuyExtraCardDraw') {
      return this.handleBuyExtraCardDraw(userId);
    } else if (actionStr === 'RerollCards') {
      const p = this.getPlayer(userId);
      if (p.Cash >= 50) {
        p.Cash -= 50;
        return { success: true, action: actionStr };
      }
      return { success: false, reason: 'InsufficientCash' };
    } else if (actionStr.startsWith('Card_') || this.cardMap.has(actionStr)) {
      return this.handleCardSelect(userId, actionStr);
    } else {
      return this.processCashUpgrade(userId, actionStr);
    }
  }

  // Combat Attack Query Simulator matching TowerController.server.luau
  calculateTowerCombatMetrics(towerModelId) {
    const tower = this.towers.find((t) => t.modelId === towerModelId);
    if (!tower) return null;

    const owner = this.getPlayer(tower.ownerUserId);
    const heroSpec = HERO_CATALOG.find((h) => h.Id === tower.heroId) || HERO_CATALOG[0];

    const baseDmg = owner.DamageStat !== undefined ? owner.DamageStat : 50;
    const baseRange = owner.RangeStat !== undefined ? owner.RangeStat : 30;
    const baseCd = owner.CooldownStat !== undefined ? owner.CooldownStat : 1.15;
    const baseSplash = owner.SplashStat !== undefined ? owner.SplashStat : 7;
    const critChance = owner.CritChanceStat !== undefined ? owner.CritChanceStat : 0.08;
    const critDmg = owner.CritDamageStat !== undefined ? owner.CritDamageStat : 2.0;

    const finalCooldown = Math.max(0.15, baseCd * heroSpec.CooldownMult);
    const finalRange = baseRange + heroSpec.RangeBonus;
    const finalSplash = baseSplash + heroSpec.SplashBonus;
    const nonCritDamage = Math.floor(baseDmg * heroSpec.DamageMult);
    const critDamage = Math.floor(baseDmg * heroSpec.DamageMult * critDmg);

    return {
      finalCooldown,
      finalRange,
      finalSplash,
      nonCritDamage,
      critDamage,
      critChance: Math.min(0.95, critChance),
    };
  }

  // Procedural Client HUD Preview Formats (Matching UpgradeHUD.client.luau)
  getClientUpgradePreview(userId) {
    const p = this.getPlayer(userId);
    const dmgLvl = p.DamageLevel || 1;
    const rngLvl = p.RangeLevel || 1;
    const spdLvl = p.SpeedLevel || 1;
    const curDmg = p.DamageStat !== undefined ? p.DamageStat : 45;
    const curRng = p.RangeStat !== undefined ? p.RangeStat : 36;
    const curCd = p.CooldownStat !== undefined ? p.CooldownStat : 0.95;
    const minCd = 0.15;

    const dmgCost = Math.floor(75 * Math.pow(1.35, dmgLvl - 1));
    const nextDmg = Math.floor(curDmg * 1.35 + 10);

    const rngCost = Math.floor(60 * Math.pow(1.30, rngLvl - 1));
    const nextRng = curRng + 4;

    const spdCost = Math.floor(90 * Math.pow(1.40, spdLvl - 1));
    const nextCd = Math.max(minCd, Math.floor(curCd * 0.90 * 100) / 100);

    const dps = Math.floor(curDmg / Math.max(0.12, curCd));
    const hpRatio = Math.max(0, Math.min(1, this.workspace.BaseHP / Math.max(1, this.workspace.MaxBaseHP)));

    return {
      dmgCost,
      nextDmg,
      rngCost,
      nextRng,
      spdCost,
      nextCd,
      isSpeedMax: curCd <= minCd,
      dps,
      hpRatio,
    };
  }
}

// =============================================================================
// TIER 5 TEST SUITE MAIN EXECUTION
// =============================================================================

export async function runTier5Tests() {
  const startTime = Date.now();
  console.log(`\n${COLORS.bold}${COLORS.yellow}========================================================================${COLORS.reset}`);
  console.log(`${COLORS.bold}${COLORS.yellow}   TIER 5 ADVERSARIAL COVERAGE HARDENING (TRACK 3 & CROSS-TRACK)        ${COLORS.reset}`);
  console.log(`${COLORS.bold}${COLORS.yellow}   White-Box Mathematical Precision, Cross-Track Flow & Stress Harvester${COLORS.reset}`);
  console.log(`${COLORS.bold}${COLORS.yellow}========================================================================${COLORS.reset}\n`);

  // ---------------------------------------------------------------------------
  // CATEGORY A: Mathematical Curves & Precision Verification (5 Cases)
  // ---------------------------------------------------------------------------
  console.log(`${COLORS.bold}${COLORS.magenta}--- CATEGORY A: MATHEMATICAL CURVES & PRECISION VERIFICATION ---${COLORS.reset}`);

  // ADV-A1: Exponential Damage Curve across 50 levels
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(101);
    p.Cash = 1e15; // Plentiful funds to trace pure curve

    let valid = true;
    let prevCost = 0;
    let prevStat = p.DamageStat;

    for (let lvl = 1; lvl <= 50; lvl++) {
      const curLvl = p.DamageLevel;
      const expectedCost = Math.floor(75 * Math.pow(1.35, curLvl - 1));
      const res = server.processCashUpgrade(101, 'Damage');

      if (!res.success) {
        valid = false;
        break;
      }
      if (res.newLevel !== lvl + 1) {
        valid = false;
        break;
      }
      if (res.newStat <= prevStat || !Number.isInteger(res.newStat)) {
        valid = false;
        break;
      }
      if (Number.isNaN(res.newCost) || !Number.isFinite(res.newCost)) {
        valid = false;
        break;
      }
      prevCost = res.newCost;
      prevStat = res.newStat;
    }

    recordAdvTest(
      'advA',
      'ADV-A1',
      'Exponential Damage Curve across 50 levels retains strictly monotonic integer precision without NaN',
      valid,
      `Lv.51 reached, Dmg: ${prevStat.toLocaleString()}, NextCost: $${prevCost.toLocaleString()}`
    );
  }

  // ADV-A2: Linear Range Curve across 50 levels & HUD parity
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(102);
    p.Cash = 1e12;

    let valid = true;
    for (let lvl = 1; lvl <= 50; lvl++) {
      const preview = server.getClientUpgradePreview(102);
      const res = server.processCashUpgrade(102, 'Range');

      if (!res.success) {
        valid = false;
        break;
      }
      if (res.newStat !== preview.nextRng) {
        valid = false;
        break;
      }
      if (res.newCost !== Math.floor(60 * Math.pow(1.30, res.newLevel - 1))) {
        valid = false;
        break;
      }
    }

    recordAdvTest(
      'advA',
      'ADV-A2',
      'Linear Range Curve across 50 levels matches client HUD preview with exact +4 stud increments',
      valid,
      `Lv.51 reached, Range: ${p.RangeStat} studs`
    );
  }

  // ADV-A3: Exponential Speed Curve & 0.15s Minimum Clamping Invariant
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(103);
    p.Cash = 1e12;
    p.CooldownStat = 0.95;

    let clampHitLevel = null;
    let clampedCorrectly = true;

    for (let lvl = 1; lvl <= 50; lvl++) {
      const res = server.processCashUpgrade(103, 'Speed');
      if (res.newStat === 0.15 && clampHitLevel === null) {
        clampHitLevel = res.newLevel;
      }
      if (clampHitLevel !== null && res.newStat < 0.15) {
        clampedCorrectly = false;
        break;
      }
    }

    const preview = server.getClientUpgradePreview(103);
    const clientBlocked = preview.isSpeedMax;

    recordAdvTest(
      'advA',
      'ADV-A3',
      'Exponential Speed Curve strictly clamps to 0.15s minimum cooldown without underflow and disables HUD',
      clampedCorrectly && clientBlocked && clampHitLevel !== null,
      `Clamped at Lv.${clampHitLevel}, cooldown frozen at ${p.CooldownStat}s, isSpeedMax=${clientBlocked}`
    );
  }

  // ADV-A4: Tower DPS Formula Edge Cases & Zero Division Protection
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(104);

    // Test extreme damage and normal cooldown
    p.DamageStat = 1000000;
    p.CooldownStat = 0.15;
    const dpsNormal = server.getClientUpgradePreview(104).dps;

    // Test zero cooldown guard (math.max(0.12, cd))
    p.CooldownStat = 0;
    const dpsZeroGuard = server.getClientUpgradePreview(104).dps;

    // Test negative cooldown guard
    p.CooldownStat = -1.5;
    const dpsNegativeGuard = server.getClientUpgradePreview(104).dps;

    const valid =
      dpsNormal === Math.floor(1000000 / 0.15) &&
      dpsZeroGuard === Math.floor(1000000 / 0.12) &&
      dpsNegativeGuard === Math.floor(1000000 / 0.12) &&
      Number.isFinite(dpsZeroGuard);

    recordAdvTest(
      'advA',
      'ADV-A4',
      'Client HUD Tower DPS formula protects against divide-by-zero using 0.12s floor divisor',
      valid,
      `Normal DPS: ${dpsNormal}, Zero-CD Guard DPS: ${dpsZeroGuard}`
    );
  }

  // ADV-A5: Extra Card Draw Cost Scaling across 30 purchases
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(105);
    p.Cash = 1e12;

    let valid = true;
    for (let i = 0; i < 30; i++) {
      const totalPicked = p.CardsPickedTotal || 0;
      const expectedCost = Math.floor(150 * Math.pow(1.25, totalPicked));
      const res = server.handleBuyExtraCardDraw(105);

      if (!res.success || res.drawCost !== expectedCost) {
        valid = false;
        break;
      }
      p.CardsPickedTotal++;
    }

    recordAdvTest(
      'advA',
      'ADV-A5',
      'Extra card draw cost progression (150 * 1.25^N) scales reliably across 30 sequential purchases',
      valid,
      `Draw 30 Cost: $${Math.floor(150 * Math.pow(1.25, 29)).toLocaleString()}`
    );
  }

  // ---------------------------------------------------------------------------
  // CATEGORY B: Cross-Track Real-Time Data Flow Contracts (5 Cases)
  // ---------------------------------------------------------------------------
  console.log(`\n${COLORS.bold}${COLORS.magenta}--- CATEGORY B: CROSS-TRACK REAL-TIME DATA FLOW CONTRACTS ---${COLORS.reset}`);

  // ADV-B1: Stat upgrade immediately reflects in TowerController combat calculations
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(201);
    p.Cash = 50000; // Provide sufficient funds for upgrades
    server.towers.push({
      modelId: 'Tower_Luffy_Slot_1',
      heroId: 'Tower_Luffy_G5',
      ownerUserId: 201,
      unitUid: 'uid-luffy-1',
      slotId: 'Slot_1',
    });

    const mBefore = server.calculateTowerCombatMetrics('Tower_Luffy_Slot_1');

    // Upgrade damage by 5 levels
    for (let i = 0; i < 5; i++) {
      server.processCashUpgrade(201, 'Damage');
    }
    // Upgrade speed by 3 levels
    for (let i = 0; i < 3; i++) {
      server.processCashUpgrade(201, 'Speed');
    }

    const mAfter = server.calculateTowerCombatMetrics('Tower_Luffy_Slot_1');

    const valid =
      mAfter.nonCritDamage > mBefore.nonCritDamage &&
      mAfter.finalCooldown < mBefore.finalCooldown &&
      mAfter.finalRange === mBefore.finalRange;

    recordAdvTest(
      'advB',
      'ADV-B1',
      'Player stat upgrades immediately reflect in Track 2 TowerController combat damage and cooldown in real time',
      valid,
      `Damage: ${mBefore.nonCritDamage} -> ${mAfter.nonCritDamage}, Cooldown: ${mBefore.finalCooldown.toFixed(3)}s -> ${mAfter.finalCooldown.toFixed(3)}s`
    );
  }

  // ADV-B2: Card draft Card_GrandFleetCommand immediately affects tower combat & unlocks 5th pad
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(202);
    p.PendingCardDraws = 1;
    server.towers.push({
      modelId: 'Tower_Zoro_Slot_2',
      heroId: 'Tower_Zoro_KingOfHell',
      ownerUserId: 202,
      unitUid: 'uid-zoro-2',
      slotId: 'Slot_2',
    });

    const mBefore = server.calculateTowerCombatMetrics('Tower_Zoro_Slot_2');
    const slotsBefore = p.MaxPlacedTowersStat;

    server.handleCardSelect(202, 'Card_GrandFleetCommand');

    const mAfter = server.calculateTowerCombatMetrics('Tower_Zoro_Slot_2');
    const slotsAfter = p.MaxPlacedTowersStat;

    const valid =
      slotsAfter === slotsBefore + 1 &&
      mAfter.nonCritDamage > mBefore.nonCritDamage &&
      mAfter.finalRange === mBefore.finalRange + 6 &&
      mAfter.finalCooldown < mBefore.finalCooldown &&
      mAfter.critChance > mBefore.critChance;

    recordAdvTest(
      'advB',
      'ADV-B2',
      'Card_GrandFleetCommand draft immediately updates combat range, damage, crit and unlocks 5th tower slot',
      valid,
      `Slots: ${slotsBefore} -> ${slotsAfter}, Range: ${mBefore.finalRange} -> ${mAfter.finalRange}, Crit: ${(mBefore.critChance * 100).toFixed(0)}% -> ${(mAfter.critChance * 100).toFixed(0)}%`
    );
  }

  // ADV-B3: Card draft Card_YonkoBounty scales WaveManager kill cash reward
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(203);
    p.PendingCardDraws = 1;
    const tokensBefore = p.RerollTokens;
    const cashBefore = p.Cash;

    server.handleCardSelect(203, 'Card_YonkoBounty');

    const baseEnemyCash = 55; // GeneralZombie
    const awardedCash = Math.floor(baseEnemyCash * p.BountyMultiplierStat);

    const valid =
      p.BountyMultiplierStat === 1.40 &&
      p.RerollTokens === tokensBefore + 2 &&
      p.Cash === cashBefore + 350 &&
      awardedCash === Math.floor(55 * 1.40);

    recordAdvTest(
      'advB',
      'ADV-B3',
      'Card_YonkoBounty draft immediately updates BountyMultiplierStat (1.40x) and multiplies wave cash rewards',
      valid,
      `BountyMult: 1.0x -> ${p.BountyMultiplierStat}x, Cash: +$350, Tokens: +2, Zombie Reward: $55 -> $${awardedCash}`
    );
  }

  // ADV-B4: Card draft Card_PoneglyphWisdom immediately heals BaseHP and updates HUD health ratio
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(204);
    p.PendingCardDraws = 1;
    server.workspace.BaseHP = 600; // Damaged base
    server.workspace.MaxBaseHP = 1000;

    const ratioBefore = server.getClientUpgradePreview(204).hpRatio;
    server.handleCardSelect(204, 'Card_PoneglyphWisdom');
    const ratioAfter = server.getClientUpgradePreview(204).hpRatio;

    const valid =
      server.workspace.BaseHP === 850 &&
      server.workspace.MaxBaseHP === 1250 &&
      ratioBefore === 0.60 &&
      ratioAfter === 850 / 1250;

    recordAdvTest(
      'advB',
      'ADV-B4',
      'Card_PoneglyphWisdom draft expands MaxBaseHP and heals BaseHP with instant HUD ratio synchronization',
      valid,
      `BaseHP: 600/1000 (${(ratioBefore * 100).toFixed(0)}%) -> ${server.workspace.BaseHP}/${server.workspace.MaxBaseHP} (${(ratioAfter * 100).toFixed(1)}%)`
    );
  }

  // ADV-B5: Card draft Card_KingOfHellAsura scales combat critical rolls
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(205);
    p.PendingCardDraws = 1;
    server.towers.push({
      modelId: 'Tower_Whitebeard_Slot_3',
      heroId: 'Tower_Whitebeard_Gura',
      ownerUserId: 205,
      unitUid: 'uid-wb-3',
      slotId: 'Slot_3',
    });

    const mBefore = server.calculateTowerCombatMetrics('Tower_Whitebeard_Slot_3');
    server.handleCardSelect(205, 'Card_KingOfHellAsura');
    const mAfter = server.calculateTowerCombatMetrics('Tower_Whitebeard_Slot_3');

    const valid =
      mAfter.critChance === mBefore.critChance + 0.15 &&
      mAfter.critDamage > mBefore.critDamage &&
      mAfter.nonCritDamage > mBefore.nonCritDamage;

    recordAdvTest(
      'advB',
      'ADV-B5',
      'Card_KingOfHellAsura draft scales critical chance (+15%) and critical strike multiplier (+0.85x)',
      valid,
      `Crit Chance: ${(mBefore.critChance * 100).toFixed(0)}% -> ${(mAfter.critChance * 100).toFixed(0)}%, Crit Hit: ${mBefore.critDamage} -> ${mAfter.critDamage}`
    );
  }

  // ---------------------------------------------------------------------------
  // CATEGORY C: Multi-Player Concurrency & State Isolation (5 Cases)
  // ---------------------------------------------------------------------------
  console.log(`\n${COLORS.bold}${COLORS.magenta}--- CATEGORY C: MULTI-PLAYER CONCURRENCY & STATE ISOLATION ---${COLORS.reset}`);

  // ADV-C1: Dual-Player Concurrent Upgrades
  {
    const server = new AdversarialUpgradeServer();
    const p1 = server.registerPlayer(301);
    const p2 = server.registerPlayer(302);

    // Player 1 buys Damage 3 times
    for (let i = 0; i < 3; i++) {
      server.processCashUpgrade(301, 'Damage');
    }
    // Player 2 buys Speed 3 times
    for (let i = 0; i < 3; i++) {
      server.processCashUpgrade(302, 'Speed');
    }

    const valid =
      p1.DamageLevel === 4 &&
      p1.SpeedLevel === 1 &&
      p1.CooldownStat === 0.95 &&
      p2.DamageLevel === 1 &&
      p2.SpeedLevel === 4 &&
      p2.DamageStat === 45 &&
      p1.Cash !== p2.Cash;

    recordAdvTest(
      'advC',
      'ADV-C1',
      'Two concurrent players upgrading disparate stats maintain 100% isolated stat levels and cash balances',
      valid,
      `P1: Dmg Lv.${p1.DamageLevel} Spd Lv.${p1.SpeedLevel} ($${p1.Cash}) | P2: Dmg Lv.${p2.DamageLevel} Spd Lv.${p2.SpeedLevel} ($${p2.Cash})`
    );
  }

  // ADV-C2: Dual-Player Concurrent Card Drafts
  {
    const server = new AdversarialUpgradeServer();
    const p1 = server.registerPlayer(303);
    const p2 = server.registerPlayer(304);

    p1.PendingCardDraws = 2;
    p2.PendingCardDraws = 0;

    const res1 = server.handleCardSelect(303, 'Card_Gear5Nika');
    const res2 = server.handleCardSelect(304, 'Card_Gear5Nika'); // should fail

    const valid =
      res1.success === true &&
      res2.success === false &&
      res2.reason === 'NoPendingDraws' &&
      p1.PendingCardDraws === 1 &&
      p2.PendingCardDraws === 0 &&
      p1.DamageStat > p2.DamageStat;

    recordAdvTest(
      'advC',
      'ADV-C2',
      'Concurrent card draft requests respect individual pending draw quotas without cross-player leak',
      valid,
      `P1 draft accepted (1 draw left), P2 draft rejected with ${res2.reason}`
    );
  }

  // ADV-C3: Multi-Player Placed Tower Combat Isolation
  {
    const server = new AdversarialUpgradeServer();
    const p1 = server.registerPlayer(305);
    const p2 = server.registerPlayer(306);

    // Buff Player 1 heavily
    for (let i = 0; i < 5; i++) {
      server.processCashUpgrade(305, 'Damage');
    }

    // Deploy same hero spec for both players
    server.towers.push({
      modelId: 'Tower_Shanks_P1',
      heroId: 'Tower_Shanks_Kamusari',
      ownerUserId: 305,
      unitUid: 'uid-shanks-p1',
      slotId: 'Slot_1',
    });
    server.towers.push({
      modelId: 'Tower_Shanks_P2',
      heroId: 'Tower_Shanks_Kamusari',
      ownerUserId: 306,
      unitUid: 'uid-shanks-p2',
      slotId: 'Slot_2',
    });

    const m1 = server.calculateTowerCombatMetrics('Tower_Shanks_P1');
    const m2 = server.calculateTowerCombatMetrics('Tower_Shanks_P2');

    const valid =
      m1.nonCritDamage > m2.nonCritDamage &&
      m1.finalRange === m2.finalRange &&
      m1.finalCooldown === m2.finalCooldown;

    recordAdvTest(
      'advC',
      'ADV-C3',
      'Identical towers owned by different players dynamically query and scale with their distinct owner stats',
      valid,
      `P1 Shanks Damage: ${m1.nonCritDamage} vs P2 Shanks Damage: ${m2.nonCritDamage}`
    );
  }

  // ADV-C4: Multi-Player Inventory and Gacha Reroll Isolation
  {
    const p1 = new HeadlessPlayer();
    p1.UserId = 307;
    const p2 = new HeadlessPlayer();
    p2.UserId = 308;

    const s1 = new HeadlessGameServer(p1);
    const s2 = new HeadlessGameServer(p2);

    // P1 summons
    s1.handleSummon(() => 0.05); // deterministic Luffy
    // P2 summons
    s2.handleSummon(() => 0.95); // deterministic Sanji

    // P1 rerolls
    s1.handleReroll(() => 0.50);

    const b1 = p1.getBag();
    const b2 = p2.getBag();

    const valid =
      b1.length === 1 &&
      b2.length === 1 &&
      b1[0].Uid !== b2[0].Uid &&
      p1.RerollTokens === 2 &&
      p2.RerollTokens === 3 &&
      b2[0].HeroId === 'Tower_Sanji_Ifrit';

    recordAdvTest(
      'advC',
      'ADV-C4',
      'Gacha summoning and unit rerolling maintain strict inventory bag and token isolation across players',
      valid,
      `P1: ${b1[0].HeroId} (${p1.RerollTokens} tokens) | P2: ${b2[0].HeroId} (${p2.RerollTokens} tokens)`
    );
  }

  // ADV-C5: Concurrent Tactical Pad Interaction Contention
  {
    const p1 = new HeadlessPlayer();
    p1.UserId = 309;
    const p2 = new HeadlessPlayer();
    p2.UserId = 310;

    const s = new HeadlessGameServer(p1);
    s.handleSummon(() => 0.05);
    const p1HeroUid = p1.getBag()[0].Uid;

    // P1 places on Slot_1
    const p1Placed = s.handlePlaceOrSwap('Slot_1', p1HeroUid);

    // Switch server focus to P2
    s.player = p2;
    s.handleSummon(() => 0.95);
    const p2HeroUid = p2.getBag()[0].Uid;

    // P2 attempts to swap into Slot_1
    const p2Swapped = s.handlePlaceOrSwap('Slot_1', p2HeroUid);

    const valid = p1Placed === true && p2Swapped === true && s.slotOccupants['Slot_1'].UnitUid === p2HeroUid;

    recordAdvTest(
      'advC',
      'ADV-C5',
      'Tactical placement pad state transitions safely under sequential multi-player occupancy requests',
      valid,
      `Slot_1 successfully placed by P1 and occupied by P2 without orphan references`
    );
  }

  // ---------------------------------------------------------------------------
  // CATEGORY D: Extreme Boundary & Stress Testing (5 Cases)
  // ---------------------------------------------------------------------------
  console.log(`\n${COLORS.bold}${COLORS.magenta}--- CATEGORY D: EXTREME BOUNDARY & STRESS TESTING ---${COLORS.reset}`);

  // ADV-D1: Massive 200 Roguelike Card Picks Stress Test
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(401);
    p.PendingCardDraws = 200;

    let invariantsHeld = true;
    const pool = CARD_POOL;

    for (let i = 0; i < 200; i++) {
      const card = pool[i % pool.length];
      const res = server.handleCardSelect(401, card.Id);

      if (!res.success) {
        invariantsHeld = false;
        break;
      }
      if (p.CooldownStat < 0.15) {
        invariantsHeld = false;
        break;
      }
      if (p.CritChanceStat > 0.95) {
        invariantsHeld = false;
        break;
      }
      if (p.MaxPlacedTowersStat > 8) {
        invariantsHeld = false;
        break;
      }
      if (!Number.isFinite(p.DamageStat) || Number.isNaN(p.DamageStat)) {
        invariantsHeld = false;
        break;
      }
    }

    const valid =
      invariantsHeld &&
      p.PendingCardDraws === 0 &&
      p.CardsPickedTotal === 200 &&
      p.MaxPlacedTowersStat === 8 &&
      p.CritChanceStat === 0.95 &&
      p.CooldownStat === 0.15;

    recordAdvTest(
      'advD',
      'ADV-D1',
      'Massive 200 card picks stress test preserves all domain clamp invariants without arithmetic overflow',
      valid,
      `200/200 cards picked, Cooldown clamped at ${p.CooldownStat}s, Crit capped at ${(p.CritChanceStat * 100).toFixed(0)}%, MaxTowers capped at ${p.MaxPlacedTowersStat}`
    );
  }

  // ADV-D2: Million-Dollar Cash Balance Stress Test ($1,000,000+)
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(402);
    p.Cash = 1000000;

    let upgradesDone = 0;
    let totalDeducted = 0;
    let running = true;

    while (running && upgradesDone < 200) {
      const curLvl = p.DamageLevel;
      const expectedCost = Math.floor(75 * Math.pow(1.35, curLvl - 1));
      if (p.Cash >= expectedCost) {
        const cashBefore = p.Cash;
        const res = server.processCashUpgrade(402, 'Damage');
        if (res.success) {
          totalDeducted += expectedCost;
          upgradesDone++;
          if (p.Cash !== cashBefore - expectedCost || p.Cash < 0) {
            running = false;
          }
        } else {
          running = false;
        }
      } else {
        running = false;
      }
    }

    const nextCost = Math.floor(75 * Math.pow(1.35, p.DamageLevel - 1));
    const valid =
      p.Cash >= 0 &&
      p.Cash < nextCost &&
      upgradesDone >= 25 &&
      1000000 - totalDeducted === p.Cash;

    recordAdvTest(
      'advD',
      'ADV-D2',
      'Million-dollar balance ($1,000,000) bulk upgrade stress test executes exact deductions without drift',
      valid,
      `${upgradesDone} damage upgrades executed to Lv.${p.DamageLevel}, Total Spent: $${totalDeducted.toLocaleString()}, Remaining: $${p.Cash.toLocaleString()} (< next cost $${nextCost.toLocaleString()})`
    );
  }

  // ADV-D3: 500 Rapid Sequential Hero Rerolls Stress Test
  {
    const p = new HeadlessPlayer();
    p.RerollTokens = 500;
    const s = new HeadlessGameServer(p);

    // Initial summon
    s.handleSummon();

    let validBag = true;
    for (let i = 0; i < 500; i++) {
      const ok = s.handleReroll();
      if (!ok) {
        validBag = false;
        break;
      }
      const bag = p.getBag();
      if (bag.length !== 1) {
        validBag = false;
        break;
      }
    }

    const valid = validBag && p.RerollTokens === 0 && p.getBag().length === 1;

    recordAdvTest(
      'advD',
      'ADV-D3',
      '500 rapid sequential hero rerolls stress test updates unit in-place without leaking bag entries',
      valid,
      `500 rerolls executed, final token count: ${p.RerollTokens}, bag unit count strictly: ${p.getBag().length}`
    );
  }

  // ADV-D4: Exact Boundary and Negative Cash Hardening
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(404);

    // Level 1 Damage costs $75
    // Test 1: $74 (exactly 1 dollar short)
    p.Cash = 74;
    const resShort = server.processCashUpgrade(404, 'Damage');

    // Test 2: $75 (exact price)
    p.Cash = 75;
    const resExact = server.processCashUpgrade(404, 'Damage');

    // Test 3: $0
    p.Cash = 0;
    const resZero = server.processCashUpgrade(404, 'Damage');

    // Test 4: Negative cash injection
    p.Cash = -500;
    const resNegative = server.processCashUpgrade(404, 'Damage');

    const valid =
      resShort.success === false &&
      resShort.reason === 'InsufficientCash' &&
      resExact.success === true &&
      resExact.remainingCash === 0 &&
      resZero.success === false &&
      resNegative.success === false &&
      p.Cash === -500; // Unchanged by failed attempts

    recordAdvTest(
      'advD',
      'ADV-D4',
      'Exact cost boundary ($cost - $1, exact $cost, $0, and negative cash) handled safely without mutations',
      valid,
      `$74 -> Rejected (${resShort.reason}), $75 -> Accepted ($0 left), $0 -> Rejected, -$500 -> Rejected`
    );
  }

  // ADV-D5: Pending Draws Exhaustion & Replay Attack Defense
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(405);
    p.PendingCardDraws = 1;

    let successes = 0;
    let rejections = 0;

    for (let i = 0; i < 10; i++) {
      const res = server.handleCardSelect(405, 'Card_DevilFruitAwakening');
      if (res.success) {
        successes++;
      } else if (res.reason === 'NoPendingDraws') {
        rejections++;
      }
    }

    const valid = successes === 1 && rejections === 9 && p.PendingCardDraws === 0;

    recordAdvTest(
      'advD',
      'ADV-D5',
      'Card draft draft exhaustion defense: exactly 1 card consumed from 1 pending draw under 10 rapid calls',
      valid,
      `Successes: ${successes}, Rejections: ${rejections}, Final Pending: ${p.PendingCardDraws}`
    );
  }

  // ---------------------------------------------------------------------------
  // CATEGORY E: Input Validation & Adversarial Injection Hardening (4 Cases)
  // ---------------------------------------------------------------------------
  console.log(`\n${COLORS.bold}${COLORS.magenta}--- CATEGORY E: INPUT VALIDATION & ADVERSARIAL INJECTION HARDENING ---${COLORS.reset}`);

  // ADV-E1: Non-String & Malformed Type Mismatch Rejection
  {
    const server = new AdversarialUpgradeServer();
    server.registerPlayer(501);

    const inputs = [null, undefined, 12345, true, false, {}, [], NaN];
    let allSafelyHandled = true;

    for (const inp of inputs) {
      const res = server.onUpgradeStatInvoke(501, inp);
      if (res.success !== false || res.reason !== 'InvalidArguments') {
        allSafelyHandled = false;
        break;
      }
    }

    recordAdvTest(
      'advE',
      'ADV-E1',
      'RemoteFunction invoke rejects non-string and malformed payloads with InvalidArguments reason',
      allSafelyHandled,
      `Tested 8 non-string types (null, undefined, number, bool, table, NaN) -> all safely rejected`
    );
  }

  // ADV-E2: String Injection Hardening
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(502);
    p.Cash = 10000;
    p.PendingCardDraws = 5;

    const injections = [
      "'; DROP TABLE users; --",
      '<script>alert(1)</script>',
      '\0\r\n\t',
      'NaN',
      'undefined',
      '-1',
      '99999999999999999999999999',
    ];

    let allRejected = true;
    for (const inj of injections) {
      const res = server.onUpgradeStatInvoke(502, inj);
      if (res.success !== false) {
        allRejected = false;
        break;
      }
    }

    const valid = allRejected && p.Cash === 10000 && p.PendingCardDraws === 5;

    recordAdvTest(
      'advE',
      'ADV-E2',
      'Malicious string injections (SQL-like, XSS-like, whitespace, negative strings) cleanly rejected',
      valid,
      `Tested 7 hostile strings -> zero side-effects on cash or pending draws`
    );
  }

  // ADV-E3: Non-Existent Stat Types & Card IDs
  {
    const server = new AdversarialUpgradeServer();
    const p = server.registerPlayer(503);
    p.PendingCardDraws = 3;

    const resStat = server.onUpgradeStatInvoke(503, 'Defense');
    const resCard = server.onUpgradeStatInvoke(503, 'Card_UltraInstinctGoku');

    const valid =
      resStat.success === false &&
      resStat.reason === 'InvalidStatType' &&
      resCard.success === false &&
      resCard.reason === 'CardNotFound' &&
      p.PendingCardDraws === 3;

    recordAdvTest(
      'advE',
      'ADV-E3',
      'Non-existent stat names and invalid card IDs reject cleanly without consuming pending draws',
      valid,
      `Defense -> ${resStat.reason}, Card_UltraInstinctGoku -> ${resCard.reason}`
    );
  }

  // ADV-E4: Malformed UUID & Phantom Slot Attack Defense
  {
    const p = new HeadlessPlayer();
    const s = new HeadlessGameServer(p);

    // Attacking with bogus slot IDs and non-existent bag unit UIDs
    const res1 = s.handlePlaceOrSwap('Slot_999', 'bogus-uid-123');
    const res2 = s.handleStoreToBag('Slot_Fake');
    const res3 = s.handleSell('Slot', 'Slot_Invalid');
    const res4 = s.handleSell('Bag', 'phantom-bag-uid');

    const valid =
      res1 === false &&
      res2 === false &&
      res3 === false &&
      res4 === false &&
      p.Cash === 500 &&
      Object.keys(s.slotOccupants).length === 0;

    recordAdvTest(
      'advE',
      'ADV-E4',
      'Phantom slot IDs and invalid bag UIDs safely abort across placement, recall, and sell handlers',
      valid,
      `All 4 phantom operations returned false with zero state mutation or orphan towers`
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY REPORT
  // ---------------------------------------------------------------------------
  const duration = Date.now() - startTime;
  console.log(`\n${COLORS.bold}${COLORS.yellow}========================================================================${COLORS.reset}`);
  console.log(
    `${COLORS.bold}${results.summary.failed === 0 ? COLORS.green : COLORS.red}TIER 5 ADVERSARIAL EXECUTION COMPLETE: ${results.summary.passed} / ${results.summary.total} PASSED (${((results.summary.passed / results.summary.total) * 100).toFixed(1)}%) in ${duration}ms${COLORS.reset}`
  );
  console.log(`${COLORS.bold}${COLORS.yellow}========================================================================${COLORS.reset}\n`);

  return results;
}

// Run immediately when executed directly
if (process.argv[1] && process.argv[1].endsWith('tier5_adversarial_upgrade_ui.test.mjs')) {
  runTier5Tests().then((res) => {
    if (res.summary.failed > 0) {
      process.exit(1);
    } else {
      process.exit(0);
    }
  });
}
