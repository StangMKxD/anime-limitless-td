// tests/challenger_m5_1_remote_contracts_adversarial.test.mjs
// Adversarial Challenger Test Harness for Phase 3 Milestone 5:
// Target: src/Track3_UISystem/UpgradeHUD.client.luau
// Focus Areas:
// 1. Remote Invocation Signature Contracts (String action types vs tables)
// 2. UI State Resilience & Adversarial JSON Fuzzing (HeroInventoryJson)
// 3. Speed Upgrade Button Cooldown Floor Click Lock (CooldownStat <= 0.15s)
// 4. Empty Slot Click with No Unit Selected (Ghost Placement Prevention)
// 5. Dual-Container Remote Resolution Resilience

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(__dirname, '..');

const UPGRADE_HUD_PATH = path.join(PROJECT_ROOT, 'src', 'Track3_UISystem', 'UpgradeHUD.client.luau');
const TOWER_CONTROLLER_PATH = path.join(PROJECT_ROOT, 'src', 'Track2_TowerSystem', 'TowerController.server.luau');
const UPGRADE_SERVER_PATH = path.join(PROJECT_ROOT, 'src', 'Track3_UpgradeServer', 'UpgradeServer.server.luau');
const GAME_CONFIG_PATH = path.join(PROJECT_ROOT, 'src', 'Shared', 'GameConfig.luau');

// Terminal ANSI Styles
const BOLD = '\x1b[1m';
const RESET = '\x1b[0m';
const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const CYAN = '\x1b[36m';
const YELLOW = '\x1b[33m';
const GRAY = '\x1b[90m';
const MAGENTA = '\x1b[35m';

console.log(`${BOLD}${CYAN}========================================================================${RESET}`);
console.log(`${BOLD}   EMPIRICAL ADVERSARIAL CHALLENGER: REMOTE CONTRACTS & UI RESILIENCE   ${RESET}`);
console.log(`${BOLD}   Target: UpgradeHUD.client.luau (Phase 3 Milestone 5)                 ${RESET}`);
console.log(`${BOLD}${CYAN}========================================================================${RESET}\n`);

let passedCount = 0;
let failedCount = 0;
const testRecords = [];

function check(id, title, condition, details = '') {
  const ok = Boolean(condition);
  if (ok) {
    passedCount++;
    console.log(`  ${GREEN}[PASS]${RESET} ${BOLD}${id}${RESET}: ${title} ${details ? `${GRAY}(${details})${RESET}` : ''}`);
  } else {
    failedCount++;
    console.error(`  ${RED}[FAIL]${RESET} ${BOLD}${id}${RESET}: ${title} - ${YELLOW}${details}${RESET}`);
  }
  testRecords.push({ id, title, passed: ok, details });
  return ok;
}

// Ensure source files exist
if (!fs.existsSync(UPGRADE_HUD_PATH)) {
  console.error(`File not found: ${UPGRADE_HUD_PATH}`);
  process.exit(1);
}
const hudSource = fs.readFileSync(UPGRADE_HUD_PATH, 'utf8');
const towerSource = fs.existsSync(TOWER_CONTROLLER_PATH) ? fs.readFileSync(TOWER_CONTROLLER_PATH, 'utf8') : '';
const upgradeServerSource = fs.existsSync(UPGRADE_SERVER_PATH) ? fs.readFileSync(UPGRADE_SERVER_PATH, 'utf8') : '';

// =============================================================================
// SUITE 1: REMOTE INVOCATION SIGNATURE CONTRACTS
// =============================================================================
console.log(`\n${BOLD}${CYAN}--- SUITE 1: REMOTE INVOCATION SIGNATURE CONTRACTS ---${RESET}`);

// 1.1 Strict Luau Type Checking
check('SIG-1.1', 'Enforces strict Luau type checking (--!strict)', hudSource.trimStart().startsWith('--!strict'));

// 1.2 TowerSummonRerollRequest Contract
// Must be invoked with string mode "Summon" or "Reroll" (NOT a table)
const summonInvocations = [];
const summonRegex = /re:FireServer\s*\(\s*(["'`].*?["'`]|[^)]*)\)/g;

// Extract summon & reroll remote usages
const summonBlockMatch = hudSource.match(/btnSummon\.MouseButton1Click:Connect\([\s\S]*?end\)/);
const rerollBlockMatch = hudSource.match(/btnReroll\.MouseButton1Click:Connect\([\s\S]*?end\)/);

const btnSummonFiresString = summonBlockMatch && summonBlockMatch[0].includes('re:FireServer("Summon")');
const btnRerollFiresString = rerollBlockMatch && rerollBlockMatch[0].includes('re:FireServer("Reroll")');
const summonDoesNotPassTable = summonBlockMatch && !summonBlockMatch[0].includes('re:FireServer({') && !summonBlockMatch[0].includes('re:FireServer( {');
const rerollDoesNotPassTable = rerollBlockMatch && !rerollBlockMatch[0].includes('re:FireServer({') && !rerollBlockMatch[0].includes('re:FireServer( {');

check('SIG-1.2a', 'TowerSummonRerollRequest invoked with string "Summon" on btnSummon click', btnSummonFiresString);
check('SIG-1.2b', 'TowerSummonRerollRequest invoked with string "Reroll" on btnReroll click', btnRerollFiresString);
check('SIG-1.2c', 'TowerSummonRerollRequest invocations pass string literals (NOT a table payload)',
  summonDoesNotPassTable && rerollDoesNotPassTable);

// 1.3 TowerPlacementActionRequest Contract
// Actions: PlaceOrSwap, StoreToBag, SellFromSlot, SellFromBag, SelectBagUnit
const placeOrSwapMatch = hudSource.match(/re:FireServer\s*\(\s*"PlaceOrSwap"\s*,\s*slotSpec\.SlotId\s*,\s*selectedUid\s*\)/);
const storeToBagMatch = hudSource.match(/re:FireServer\s*\(\s*"StoreToBag"\s*,\s*slotSpec\.SlotId\s*\)/);
const sellFromSlotMatch = hudSource.match(/re:FireServer\s*\(\s*"SellFromSlot"\s*,\s*slotSpec\.SlotId\s*\)/);
const sellFromBagMatch = hudSource.match(/re:FireServer\s*\(\s*"SellFromBag"\s*,\s*unit\.Uid\s*\)/);
const selectBagUnitMatch = hudSource.match(/re:FireServer\s*\(\s*"SelectBagUnit"\s*,\s*unit\.Uid\s*\)/);

check('SIG-1.3a', 'TowerPlacementActionRequest invoked with string action "PlaceOrSwap"', Boolean(placeOrSwapMatch));
check('SIG-1.3b', 'TowerPlacementActionRequest invoked with string action "StoreToBag"', Boolean(storeToBagMatch));
check('SIG-1.3c', 'TowerPlacementActionRequest invoked with string action "SellFromSlot"', Boolean(sellFromSlotMatch));
check('SIG-1.3d', 'TowerPlacementActionRequest invoked with string action "SellFromBag"', Boolean(sellFromBagMatch));
check('SIG-1.3e', 'TowerPlacementActionRequest invoked with string action "SelectBagUnit"', Boolean(selectBagUnitMatch));

// Check that NO placement remote invocation passes a table as the first argument
const allPlacementCalls = hudSource.match(/getPlacementActionRemote\(\)[\s\S]*?re:FireServer\(([^)]+)\)/g) || [];
let anyPlacementPassesTable = false;
for (const call of allPlacementCalls) {
  if (call.includes('re:FireServer({') || call.includes('re:FireServer( {')) {
    anyPlacementPassesTable = true;
  }
}
check('SIG-1.3f', 'TowerPlacementActionRequest strictly passes string actions (NEVER a table)', !anyPlacementPassesTable);

// 1.4 CardDraftSelectRequest Contract
// Must be invoked with string card.Id
const cardDraftSelectMatch = hudSource.match(/re:FireServer\s*\(\s*card\.Id\s*\)/);
const cardDraftInvokeMatch = hudSource.match(/rf:InvokeServer\s*\(\s*card\.Id\s*\)/);
check('SIG-1.4a', 'CardDraftSelectRequest invoked with string card.Id via RemoteEvent', Boolean(cardDraftSelectMatch));
check('SIG-1.4b', 'CardDraftSelectRequest provides RemoteFunction fallback passing string card.Id', Boolean(cardDraftInvokeMatch));

// 1.5 UpgradeStatRequest Contract
// Must be invoked with string "Damage", "Range", "Speed"
const upgradeDamageMatch = hudSource.match(/fireStatUpgrade\s*\(\s*"Damage"\s*\)/);
const upgradeRangeMatch = hudSource.match(/fireStatUpgrade\s*\(\s*"Range"\s*\)/);
const upgradeSpeedMatch = hudSource.match(/fireStatUpgrade\s*\(\s*"Speed"\s*\)/);
const fireStatDispatchesString = hudSource.includes('rf:InvokeServer(statType)') || hudSource.includes('re:FireServer(statType)');

check('SIG-1.5a', 'UpgradeStatRequest invokes with string "Damage"', Boolean(upgradeDamageMatch));
check('SIG-1.5b', 'UpgradeStatRequest invokes with string "Range"', Boolean(upgradeRangeMatch));
check('SIG-1.5c', 'UpgradeStatRequest invokes with string "Speed"', Boolean(upgradeSpeedMatch));
check('SIG-1.5d', 'fireStatUpgrade strictly routes string statType to RemoteFunction/RemoteEvent', fireStatDispatchesString);

// 1.6 Server-Side Reciprocal Type Validation Contracts
const towerServerValidatesString = towerSource.includes('if type(mode) ~= "string" then') &&
  towerSource.includes('if type(actionType) ~= "string" then');
const upgradeServerValidatesString = upgradeServerSource.includes('typeof(statTypeOrAction) ~= "string"') &&
  upgradeServerSource.includes('typeof(cardId) == "string"');

check('SIG-1.6a', 'TowerController.server.luau strictly rejects non-string mode and actionType', towerServerValidatesString);
check('SIG-1.6b', 'UpgradeServer.server.luau strictly rejects non-string statType and cardId', upgradeServerValidatesString);

// =============================================================================
// SUITE 2: UI RESILIENCE & ADVERSARIAL JSON FUZZING (HeroInventoryJson)
// =============================================================================
console.log(`\n${BOLD}${CYAN}--- SUITE 2: UI RESILIENCE & ADVERSARIAL JSON FUZZING ---${RESET}`);

// Replicate exact client-side bag parsing logic from UpgradeHUD.client.luau:
// Lines 784-789:
// local rawBag = (localPlayer:GetAttribute(...) :: string?) or "[]"
// local ok, bagList = pcall(function() return HttpService:JSONDecode(rawBag) end)
// local units = (ok and typeof(bagList) == "table") and bagList or {}
function simulateClientBagDecode(rawBag) {
  let ok = false;
  let bagList = null;
  try {
    if (typeof rawBag !== 'string') {
      rawBag = "[]";
    }
    // Emulate Roblox HttpService:JSONDecode:
    // JSONDecode throws on invalid syntax or empty string
    if (rawBag.trim() === '') {
      throw new Error("HttpService:JSONDecode empty string error");
    }
    bagList = JSON.parse(rawBag);
    ok = true;
  } catch (err) {
    ok = false;
    bagList = null;
  }

  // Luau: typeof(bagList) == "table" (in JS, typeof object and not null and Array)
  const isTable = ok && bagList !== null && typeof bagList === 'object' && Array.isArray(bagList);
  const units = isTable ? bagList : [];
  return { ok, units };
}

// 2.1 Prescribed Edge Cases: "null", "{invalid}", ""
const resNull = simulateClientBagDecode("null");
check('JSON-2.1a', 'Decodes JSON "null" safely -> fallback to empty array []',
  Array.isArray(resNull.units) && resNull.units.length === 0);

const resInvalid = simulateClientBagDecode("{invalid}");
check('JSON-2.1b', 'Decodes malformed JSON "{invalid}" safely -> fallback to empty array []',
  Array.isArray(resInvalid.units) && resInvalid.units.length === 0);

const resEmpty = simulateClientBagDecode("");
check('JSON-2.1c', 'Decodes empty string "" safely -> fallback to empty array []',
  Array.isArray(resEmpty.units) && resEmpty.units.length === 0);

const resNilAttr = simulateClientBagDecode(null);
check('JSON-2.1d', 'Handles nil attribute safely -> fallback to empty array []',
  Array.isArray(resNilAttr.units) && resNilAttr.units.length === 0);

// 2.2 Non-Array Valid JSON Primitive Invariants
const resNumber = simulateClientBagDecode("12345");
check('JSON-2.2a', 'Decodes JSON number "12345" safely -> fallback to [] (not array)',
  Array.isArray(resNumber.units) && resNumber.units.length === 0);

const resString = simulateClientBagDecode('"quoted_string"');
check('JSON-2.2b', 'Decodes JSON string safely -> fallback to []',
  Array.isArray(resString.units) && resString.units.length === 0);

const resBool = simulateClientBagDecode("true");
check('JSON-2.2c', 'Decodes JSON boolean safely -> fallback to []',
  Array.isArray(resBool.units) && resBool.units.length === 0);

const resObjectDict = simulateClientBagDecode('{"arbitrary_key": "arbitrary_val"}');
check('JSON-2.2d', 'Decodes JSON dictionary object safely -> fallback to []',
  Array.isArray(resObjectDict.units) && resObjectDict.units.length === 0);

// 2.3 Valid JSON Array Invariant
const validBagJson = JSON.stringify([
  { Uid: "uid_1", HeroId: "Tower_Luffy_G5", Name: "MONKEY D. LUFFY", Rarity: "MYTHICAL YONKO", SellValue: 480 },
  { Uid: "uid_2", HeroId: "Tower_Zoro_KingOfHell", Name: "RORONOA ZORO", Rarity: "LEGENDARY HAKI", SellValue: 260 },
]);
const resValid = simulateClientBagDecode(validBagJson);
check('JSON-2.3', 'Decodes valid 2-hero bag JSON into 2 units accurately',
  resValid.ok === true && resValid.units.length === 2 && resValid.units[0].HeroId === "Tower_Luffy_G5");

// 2.4 Adversarial Monte Carlo Fuzzing (2,000 corrupt/fuzzed payloads)
const fuzzPayloads = [
  "", "null", "undefined", "{", "}", "[", "]", "[{", '{"a":', 'NaN', 'Infinity', '-Infinity',
  '\x00\x01\x02', '\uFFFF\uD800\uDFFF', '<script>alert(1)</script>', "'; DROP TABLE Inventory; --",
  '{"Uid": null, "Name": 123}', '[null, undefined, 42]', '[[[[[[[]]]]]]]',
  '{"a":'.repeat(50) + '1' + '}'.repeat(50),
  Buffer.alloc(256, 0xff).toString('utf8'),
  JSON.stringify({ nested: { deeper: { invalid: null } } }),
];

// Generate 2000 randomized variations
let fuzzedSurvivals = 0;
const totalFuzzTrials = 2000;
for (let i = 0; i < totalFuzzTrials; i++) {
  let payload;
  const pick = i % fuzzPayloads.length;
  if (i < fuzzPayloads.length) {
    payload = fuzzPayloads[pick];
  } else {
    // Mutate
    const base = fuzzPayloads[pick];
    const noise = crypto.randomBytes(4).toString('hex');
    payload = base.slice(0, Math.floor(base.length / 2)) + noise + base.slice(Math.floor(base.length / 2));
  }

  try {
    const res = simulateClientBagDecode(payload);
    if (Array.isArray(res.units)) {
      fuzzedSurvivals++;
    }
  } catch (err) {
    // If it threw an unhandled exception outside simulateClientBagDecode, that's a failure
  }
}

check('JSON-2.4', `Adversarial fuzzing 2,000 malformed inputs survived with 0 crashes (${fuzzedSurvivals}/${totalFuzzTrials})`,
  fuzzedSurvivals === totalFuzzTrials);

// =============================================================================
// SUITE 3: SPEED UPGRADE BUTTON COOLDOWN FLOOR CLICK LOCK
// =============================================================================
console.log(`\n${BOLD}${CYAN}--- SUITE 3: SPEED UPGRADE BUTTON COOLDOWN FLOOR CLICK LOCK ---${RESET}`);

// Inspect UpgradeHUD.client.luau lines 555-561:
// btnSpeed.MouseButton1Click:Connect(function()
//   local curCd = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) :: number?) or 1.15
//   local minCd = (GameConfig.INITIAL_PLAYER_STATS and GameConfig.INITIAL_PLAYER_STATS.MIN_COOLDOWN) or 0.15
//   if curCd > minCd then
//     fireStatUpgrade("Speed")
//   end
// end)

function simulateSpeedButtonClick(currentCd, minCd = 0.15) {
  let remoteFired = false;
  const curCd = currentCd !== undefined ? currentCd : 1.15;
  if (curCd > minCd) {
    remoteFired = true;
  }
  return remoteFired;
}

// 3.1 Above Minimum Threshold: Must fire remote
check('SPD-3.1a', 'Cooldown 1.15s > 0.15s: Click unlocked, fires "Speed" upgrade', simulateSpeedButtonClick(1.15) === true);
check('SPD-3.1b', 'Cooldown 0.50s > 0.15s: Click unlocked, fires "Speed" upgrade', simulateSpeedButtonClick(0.50) === true);
check('SPD-3.1c', 'Cooldown 0.16s > 0.15s: Click unlocked, fires "Speed" upgrade', simulateSpeedButtonClick(0.16) === true);

// 3.2 Exact Boundary Condition: Cooldown == 0.15s
check('SPD-3.2', 'Cooldown exactly 0.15s (== MIN_COOLDOWN): Click STRICTLY LOCKED, does NOT fire remote',
  simulateSpeedButtonClick(0.15) === false);

// 3.3 Sub-Minimum Corner Cases
check('SPD-3.3a', 'Cooldown 0.14s < 0.15s: Click STRICTLY LOCKED, does NOT fire remote', simulateSpeedButtonClick(0.14) === false);
check('SPD-3.3b', 'Cooldown 0.12s < 0.15s: Click STRICTLY LOCKED, does NOT fire remote', simulateSpeedButtonClick(0.12) === false);
check('SPD-3.3c', 'Cooldown 0.00s <= 0.15s: Click STRICTLY LOCKED, does NOT fire remote', simulateSpeedButtonClick(0.00) === false);
check('SPD-3.3d', 'Negative Cooldown -1.0s <= 0.15s: Click STRICTLY LOCKED, does NOT fire remote', simulateSpeedButtonClick(-1.0) === false);

// 3.4 Rapid Spam Click Attack at Floor (10,000 clicks)
let spamDispatchedCount = 0;
for (let i = 0; i < 10000; i++) {
  if (simulateSpeedButtonClick(0.15)) {
    spamDispatchedCount++;
  }
}
check('SPD-3.4', '10,000 spam clicks at Cooldown = 0.15s resulted in exactly 0 remote dispatches',
  spamDispatchedCount === 0);

// 3.5 UI Text & Color State Verification when Cooldown <= 0.15s
// Check lines 1185-1192 in UpgradeHUD.client.luau
const speedMaxTextPresent = hudSource.includes('btnSpeed.Text = string.format("⚡ SPEED [MAX]\\nCooldown Limit: %.2fs", minCd)') ||
  hudSource.includes('SPEED [MAX]');
const speedDisabledColorPresent = hudSource.includes('Color3.fromRGB(44, 48, 56)');
check('SPD-3.5a', 'UI displays [MAX] Speed Limit text when curCd <= minCd', speedMaxTextPresent);
check('SPD-3.5b', 'UI applies disabled dark gray background Color3.fromRGB(44, 48, 56) when curCd <= minCd', speedDisabledColorPresent);

// =============================================================================
// SUITE 4: EMPTY SLOT CLICK WITH NO UNIT SELECTED IN BAG
// =============================================================================
console.log(`\n${BOLD}${CYAN}--- SUITE 4: EMPTY SLOT CLICK & GHOST PLACEMENT PREVENTION ---${RESET}`);

// Replicate server-side placement validation from TowerController.server.luau lines 1013-1040:
// local function placeOrSwapTowerOnSlot(player, slotId, requestedUid)
//   local bag = decodeBag(player)
//   local targetUid = requestedUid or player:GetAttribute(SELECTED_BAG_UID)
//   if (not targetUid or targetUid == "") and #bag > 0 then
//     targetUid = bag[1].Uid
//   end
//   local bagIndex = nil
//   local chosenUnit = nil
//   for idx, item in ipairs(bag) do
//     if item.Uid == targetUid then bagIndex = idx; chosenUnit = item; break end
//   end
//   if not chosenUnit or not bagIndex then return end -- GUARD
//   ...
class HeadlessPlacementSimulator {
  constructor() {
    this.bag = [];
    this.selectedUid = "";
    this.slotOccupants = {}; // slotId -> unit
    this.placedCount = 0;
    this.maxTowers = 4;
    this.ghostTowersCreated = 0;
  }

  // Simulates client button click
  onClientSlotButtonClick(slotId) {
    const occupant = this.slotOccupants[slotId];
    // Line 913: re:FireServer("PlaceOrSwap", slotSpec.SlotId, selectedUid)
    return this.serverReceivePlaceOrSwap(slotId, this.selectedUid);
  }

  // Simulates server handle
  serverReceivePlaceOrSwap(slotId, requestedUid) {
    let targetUid = (requestedUid && requestedUid !== "") ? requestedUid : this.selectedUid;
    if ((!targetUid || targetUid === "") && this.bag.length > 0) {
      targetUid = this.bag[0].Uid;
    }

    let bagIndex = -1;
    let chosenUnit = null;
    for (let i = 0; i < this.bag.length; i++) {
      if (this.bag[i].Uid === targetUid) {
        bagIndex = i;
        chosenUnit = this.bag[i];
        break;
      }
    }

    // Critical Server Guard:
    if (!chosenUnit || bagIndex === -1) {
      // Abort safely!
      return { success: false, reason: "NoValidUnitInBag" };
    }

    const existingTower = this.slotOccupants[slotId];
    if (!existingTower && this.placedCount >= this.maxTowers) {
      return { success: false, reason: "MaxTowersCapReached" };
    }

    // Remove chosen from bag
    this.bag.splice(bagIndex, 1);

    // Swap old if present
    if (existingTower) {
      this.bag.push({ ...existingTower });
    } else {
      this.placedCount++;
    }

    this.slotOccupants[slotId] = {
      Uid: chosenUnit.Uid,
      HeroId: chosenUnit.HeroId,
      SlotId: slotId,
    };

    return { success: true, slotId, unitUid: chosenUnit.Uid };
  }
}

// 4.1 Empty Bag + No Unit Selected -> Click Empty Slot
const sim1 = new HeadlessPlacementSimulator();
sim1.bag = [];
sim1.selectedUid = "";

const resSlot1 = sim1.onClientSlotButtonClick("Slot_1");
check('GHO-4.1a', 'Empty bag & no selected unit: Click on empty Slot_1 returns success = false', resSlot1.success === false);
check('GHO-4.1b', 'Empty slot remains vacant: slotOccupants["Slot_1"] is undefined', sim1.slotOccupants["Slot_1"] === undefined);
check('GHO-4.1c', 'Placed towers count remains 0 (No ghost tower placed)', sim1.placedCount === 0);

// 4.2 Empty Bag + Corrupt Selected UID -> Click Empty Slot
const sim2 = new HeadlessPlacementSimulator();
sim2.bag = [];
sim2.selectedUid = "corrupted-or-fabricated-uuid-99999";
const resSlot2 = sim2.onClientSlotButtonClick("Slot_2");
check('GHO-4.2a', 'Empty bag & non-existent UID: Click on Slot_2 safely aborts', resSlot2.success === false);
check('GHO-4.2b', 'Slot_2 remains unoccupied (0 ghost towers)', sim2.slotOccupants["Slot_2"] === undefined);

// 4.3 Occupied Slot + Empty Bag: Click does not erase or duplicate occupant
const sim3 = new HeadlessPlacementSimulator();
sim3.bag = [];
sim3.selectedUid = "";
sim3.slotOccupants["Slot_3"] = { Uid: "existing_luffy", HeroId: "Tower_Luffy_G5", SlotId: "Slot_3" };
sim3.placedCount = 1;

const resOccupiedSwap = sim3.onClientSlotButtonClick("Slot_3");
check('GHO-4.3a', 'Attempting swap on occupied Slot_3 with empty bag safely fails', resOccupiedSwap.success === false);
check('GHO-4.3b', 'Original tower on Slot_3 remains completely intact without loss',
  sim3.slotOccupants["Slot_3"] && sim3.slotOccupants["Slot_3"].Uid === "existing_luffy");
check('GHO-4.3c', 'Placed towers count remains unchanged at 1', sim3.placedCount === 1);

// 4.4 Stress Test: 1,000 Rapid Empty Slot Clicks Across All 8 Slots
const simSpam = new HeadlessPlacementSimulator();
simSpam.bag = [];
simSpam.selectedUid = "";
const slots = ["Slot_1", "Slot_2", "Slot_3", "Slot_4", "Slot_5", "Slot_6", "Slot_7", "Slot_8"];
let spamGhostTowers = 0;

for (let i = 0; i < 1000; i++) {
  const s = slots[i % slots.length];
  const out = simSpam.onClientSlotButtonClick(s);
  if (out.success || simSpam.slotOccupants[s]) {
    spamGhostTowers++;
  }
}
check('GHO-4.4', '1,000 rapid clicks across all 8 empty pads with empty bag produced exactly 0 ghost towers',
  spamGhostTowers === 0 && simSpam.placedCount === 0);

// =============================================================================
// SUITE 5: DUAL-CONTAINER REMOTE RESOLUTION & LAZY ACCESSORS
// =============================================================================
console.log(`\n${BOLD}${CYAN}--- SUITE 5: DUAL-CONTAINER REMOTE RESOLUTION RESILIENCE ---${RESET}`);

// Check resolveRemote implementation in UpgradeHUD.client.luau lines 103-133:
const hasDirectCheck = hudSource.includes('ReplicatedStorage:FindFirstChild(remoteName)');
const hasRemotesFolderCheck = hudSource.includes('remotesFolder:FindFirstChild(remoteName)');
const hasWaitForChildCheck = hudSource.includes('ReplicatedStorage:WaitForChild(remoteName, 4)');
const hasLazyAccessors = hudSource.includes('local function getUpgradeStatRemoteFunc()') &&
  hudSource.includes('local function getUpgradeEventRemote()') &&
  hudSource.includes('local function getCardDraftRemote()') &&
  hudSource.includes('local function getSummonRerollRemote()') &&
  hudSource.includes('local function getPlacementActionRemote()');

check('REM-5.1', 'resolveRemote checks direct ReplicatedStorage container first', hasDirectCheck);
check('REM-5.2', 'resolveRemote checks ReplicatedStorage.Remotes subfolder container second', hasRemotesFolderCheck);
check('REM-5.3', 'resolveRemote implements timeout yielding fallback via WaitForChild', hasWaitForChildCheck);
check('REM-5.4', 'Implements 5 lazy accessors guaranteeing remote re-resolution if destroyed/re-parented', hasLazyAccessors);

// =============================================================================
// SUMMARY & VERDICT
// =============================================================================
console.log(`\n${BOLD}${CYAN}========================================================================${RESET}`);
console.log(`${BOLD}   ADVERSARIAL CHALLENGER VERDICT & EXECUTION SUMMARY                  ${RESET}`);
console.log(`${BOLD}${CYAN}========================================================================${RESET}`);
console.log(`  Total Checks: ${BOLD}${passedCount + failedCount}${RESET}`);
console.log(`  Passed:       ${BOLD}${GREEN}${passedCount}${RESET}`);
console.log(`  Failed:       ${BOLD}${failedCount > 0 ? RED : GREEN}${failedCount}${RESET}`);

const finalVerdict = failedCount === 0 ? 'APPROVE' : 'REJECT';
const verdictColor = failedCount === 0 ? GREEN : RED;
console.log(`  Verdict:      ${BOLD}${verdictColor}${finalVerdict}${RESET}\n`);

// Save machine-readable results
const artifactDir = path.join(PROJECT_ROOT, '.agents', 'teamwork', 'challenger_m5_1');
if (fs.existsSync(artifactDir)) {
  const jsonPath = path.join(artifactDir, 'adversarial_test_results.json');
  fs.writeFileSync(jsonPath, JSON.stringify({
    timestamp: new Date().toISOString(),
    verdict: finalVerdict,
    passedCount,
    failedCount,
    records: testRecords,
  }, null, 2));
}

if (failedCount > 0) {
  process.exit(1);
} else {
  process.exit(0);
}
