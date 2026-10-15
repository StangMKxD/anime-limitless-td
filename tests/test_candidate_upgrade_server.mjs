// tests/test_candidate_upgrade_server.mjs
// Comprehensive verification harness for candidate_UpgradeServer.server.luau
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(__dirname, '..');
const CANDIDATE_PATH = path.join(PROJECT_ROOT, '.agents', 'teamwork', 'spec_miner_m4_3', 'candidate_UpgradeServer.server.luau');

const results = { passed: 0, failed: 0, checks: [] };

function check(id, name, condition, details = '') {
  if (condition) {
    results.passed++;
    console.log(`\x1b[32m[PASS]\x1b[0m \x1b[1m${id}\x1b[0m: ${name} ${details ? `\x1b[90m(${details})\x1b[0m` : ''}`);
  } else {
    results.failed++;
    console.error(`\x1b[31m[FAIL]\x1b[0m \x1b[1m${id}\x1b[0m: ${name} - FAILED! \x1b[33m${details}\x1b[0m`);
  }
  results.checks.push({ id, name, passed: Boolean(condition), details });
}

console.log('========================================================================');
console.log('   VERIFYING CANDIDATE UPGRADESERVER.SERVER.LUAU FOR TURNKEY QUALITY    ');
console.log('========================================================================\n');

if (!fs.existsSync(CANDIDATE_PATH)) {
  console.error(`File not found: ${CANDIDATE_PATH}`);
  process.exit(1);
}

const source = fs.readFileSync(CANDIDATE_PATH, 'utf8');

// 1. Strict mode declaration
check('SYN-1.1', 'Starts with --!strict pragma', source.trimStart().startsWith('--!strict'));

// 2. Balanced syntax constructs
const openFunc = (source.match(/\bfunction\b/g) || []).length;
const openThen = (source.match(/\bthen\b/g) || []).length;
const openElseIf = (source.match(/\belseif\b/g) || []).length;
const openDo = (source.match(/\bdo\b/g) || []).length;
// In Luau, elseif ... then does not create a separate block that requires its own end
const totalBlockOpeners = openFunc + (openThen - openElseIf) + openDo;
const totalEnds = (source.match(/\bend\b/g) || []).length;
check('SYN-1.2', 'Balanced block openers and end keywords', totalBlockOpeners === totalEnds, `Openers: ${totalBlockOpeners}, Ends: ${totalEnds}`);

// 3. Parentheses, Brackets, and Braces balance
let pCount = 0, bCount = 0, cCount = 0;
let inStr = false, strChar = '';
for (let i = 0; i < source.length; i++) {
  const ch = source[i];
  const prev = i > 0 ? source[i - 1] : '';
  if (inStr) {
    if (ch === strChar && prev !== '\\') inStr = false;
    continue;
  }
  if (ch === '"' || ch === "'") { inStr = true; strChar = ch; continue; }
  if (ch === '(') pCount++;
  else if (ch === ')') pCount--;
  else if (ch === '[') bCount++;
  else if (ch === ']') bCount--;
  else if (ch === '{') cCount++;
  else if (ch === '}') cCount--;
}
check('SYN-1.3', 'Balanced parentheses ()', pCount === 0, `Delta: ${pCount}`);
check('SYN-1.4', 'Balanced square brackets []', bCount === 0, `Delta: ${bCount}`);
check('SYN-1.5', 'Balanced curly braces {}', cCount === 0, `Delta: ${cCount}`);

// 4. Required Service References
check('SRV-1.1', 'References Players service', source.includes('game:GetService("Players")'));
check('SRV-1.2', 'References ReplicatedStorage service', source.includes('game:GetService("ReplicatedStorage")'));
check('SRV-1.3', 'References Workspace service', source.includes('game:GetService("Workspace")'));
check('SRV-1.4', 'Requires Shared GameConfig', source.includes('require(SharedFolder:WaitForChild("GameConfig"))'));

// 5. Remote Definitions & Handlers
check('REM-1.1', 'Creates/retrieves RemoteFunction UpgradeStatRequest', source.includes('"UpgradeStatRequest"') && source.includes('getOrCreateRemoteFunction'));
check('REM-1.2', 'Creates/retrieves RemoteEvent UpgradeRequest', source.includes('"UpgradeRequest"') && source.includes('getOrCreateRemoteEvent'));
check('REM-1.3', 'Creates/retrieves RemoteEvent CardDraftSelectRequest', source.includes('"CardDraftSelectRequest"') && source.includes('getOrCreateRemoteEvent'));
check('REM-1.4', 'Binds OnServerInvoke for UpgradeStatRequest', source.includes('upgradeStatFunction.OnServerInvoke'));
check('REM-1.5', 'Binds OnServerEvent for UpgradeRequest', source.includes('upgradeEvent.OnServerEvent:Connect'));
check('REM-1.6', 'Binds OnServerEvent for CardDraftSelectRequest', source.includes('cardDraftEvent.OnServerEvent:Connect'));

// 6. Player Bootstrapping & Fallback Invariants
check('BST-1.1', 'Connects PlayerAdded event', source.includes('Players.PlayerAdded:Connect(ensurePlayerStats)'));
check('BST-1.2', 'Iterates existing players', source.includes('for _, plr in ipairs(Players:GetPlayers()) do'));
check('BST-1.3', 'Initializes leaderstats and Cash = 500', source.includes('newCash.Value = 500') || source.includes('cashObj.Value = 500'));
check('BST-1.4', 'Initializes FreeSummonTickets = 1', source.includes('FREE_SUMMON_TICKETS, 1'));
check('BST-1.5', 'Initializes RerollTokens = 3', source.includes('REROLL_TOKENS, 3'));
check('BST-1.6', 'Initializes MaxPlacedTowersStat = 4', source.includes('MAX_PLACED_TOWERS, 4'));
check('BST-1.7', 'Initializes DamageStat = 45, RangeStat = 36, CooldownStat = 0.95',
  source.includes('DAMAGE_STAT, 45') && source.includes('RANGE_STAT, 36') && source.includes('COOLDOWN_STAT, 0.95'));
check('BST-1.8', 'Initializes CritChanceStat = 0.15, CritDamageStat = 1.50, SplashRadiusStat = 6, BountyMultiplierStat = 1.0',
  source.includes('CRIT_CHANCE, 0.15') && source.includes('CRIT_DAMAGE, 1.50') && source.includes('SPLASH_STAT, 6') && source.includes('BOUNTY_MULT, 1.0'));
check('BST-1.9', 'Initializes HeroInventoryJson = "[]"', source.includes('INVENTORY_JSON, "[]"'));
check('BST-1.10', 'Initializes PendingCardDraws = 0, CardsPickedTotal = 0',
  source.includes('PENDING_CARD_DRAWS, 0') && source.includes('CARDS_PICKED_TOTAL, 0'));
check('BST-1.11', 'Initializes Levels = 1',
  source.includes('DAMAGE_LEVEL, 1') && source.includes('RANGE_LEVEL, 1') && source.includes('SPEED_LEVEL, 1'));

// 7. Stat Upgrade Math Formulas
check('UPG-1.1', 'Damage cost formula: floor(75 * 1.35^(lvl - 1))', source.includes('math.floor(75 * math.pow(1.35, curLvl - 1))'));
check('UPG-1.2', 'Damage stat formula: floor(curStat * 1.35 + 10)', source.includes('math.floor(curStat * 1.35 + 10)'));
check('UPG-1.3', 'Range cost formula: floor(60 * 1.30^(lvl - 1))', source.includes('math.floor(60 * math.pow(1.30, curLvl - 1))'));
check('UPG-1.4', 'Range stat formula: curStat + 4', source.includes('curStat + 4'));
check('UPG-1.5', 'Speed cost formula: floor(90 * 1.40^(lvl - 1))', source.includes('math.floor(90 * math.pow(1.40, curLvl - 1))'));
check('UPG-1.6', 'Speed stat formula with 0.15s clamp: math.max(minCd, floor(curStat * 0.90 * 100) / 100)',
  source.includes('math.max(minCd, math.floor(curStat * 0.90 * 100) / 100)'));
check('UPG-1.7', 'Cash guard: curCash < cost returns InsufficientCash', source.includes('reason = "InsufficientCash"'));

// 8. 12 Roguelike Card Selection Logic & Clamps
check('CRD-1.1', 'Guards pendingDraws <= 0', source.includes('pendingDraws <= 0'));
check('CRD-1.2', 'Decrements PendingCardDraws by 1', source.includes('math.max(0, pendingDraws - 1)'));
check('CRD-1.3', 'Increments CardsPickedTotal by 1', source.includes('pickedTotal + 1'));
check('CRD-1.4', 'Applies DamagePct & DamageFlat: math.floor(curDmg * (1 + pct) + flat)',
  source.includes('math.floor(curDmg * (1 + pct) + flat)'));
check('CRD-1.5', 'Applies RangeFlat: curRng + card.RangeFlat', source.includes('curRng + card.RangeFlat'));
check('CRD-1.6', 'Applies CooldownMult with clamp: math.max(minCd, curCd * card.CooldownMult)',
  source.includes('math.max(minCd, curCd * card.CooldownMult)'));
check('CRD-1.7', 'Applies SplashFlat: curSplash + card.SplashFlat', source.includes('curSplash + card.SplashFlat'));
check('CRD-1.8', 'Applies CritChanceFlat with clamp: math.min(maxCrit, curCrit + card.CritChanceFlat)',
  source.includes('math.min(maxCrit, curCrit + card.CritChanceFlat)'));
check('CRD-1.9', 'Applies CritDamageFlat: curCritDmg + card.CritDamageFlat', source.includes('curCritDmg + card.CritDamageFlat'));
check('CRD-1.10', 'Applies BountyMultFlat: curBounty + card.BountyMultFlat', source.includes('curBounty + card.BountyMultFlat'));
check('CRD-1.11', 'Applies BonusRerolls: curTokens + card.BonusRerolls', source.includes('curTokens + card.BonusRerolls'));
check('CRD-1.12', 'Applies ExtraTowerSlot with cap: math.min(maxCap, curMaxTowers + card.ExtraTowerSlot)',
  source.includes('math.min(maxCap, curMaxTowers + card.ExtraTowerSlot)'));
check('CRD-1.13', 'Applies InstantCash: curCash + card.InstantCash', source.includes('curCash + card.InstantCash'));
check('CRD-1.14', 'Applies BaseHeal to both MaxBaseHP and BaseHP concurrently',
  source.includes('curMaxHp + card.BaseHeal') && source.includes('curHp + card.BaseHeal'));

// 9. Legacy actions compatibility
check('LEG-1.1', 'Supports BuyExtraCardDraw', source.includes('handleBuyExtraCardDraw'));
check('LEG-1.2', 'Supports RerollCards', source.includes('handleRerollCards'));
check('LEG-1.3', 'Supports legacy card aliases (Card_GuraQuake, etc.)', source.includes('Card_GuraQuakeResonance'));

console.log('\n========================================================================');
console.log(`TOTAL CANDIDATE VERIFICATION CHECKS: ${results.passed + results.failed}`);
console.log(`PASSED: ${results.passed}`);
console.log(`FAILED: ${results.failed}`);
console.log('========================================================================\n');

if (results.failed > 0) {
  process.exit(1);
}
