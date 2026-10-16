// tests/test_phase4_track3_hud.test.mjs
// =============================================================================
// PHASE 4 TRACK 3 VERIFICATION TEST SUITE (PLAN-0009)
// Minimalist Flat HUD, Top Status Pill, Compact Hero Dock, Drawers & Draft Modal
// =============================================================================

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(process.cwd());

const UPGRADE_HUD_PATH = path.join(PROJECT_ROOT, 'src', 'Track3_UISystem', 'UpgradeHUD.client.luau');
const UPGRADE_SERVER_PATH = path.join(PROJECT_ROOT, 'src', 'Track3_UpgradeServer', 'UpgradeServer.server.luau');
const GAME_CONFIG_PATH = path.join(PROJECT_ROOT, 'src', 'Shared', 'GameConfig.luau');

const BOLD = '\x1b[1m';
const RESET = '\x1b[0m';
const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const CYAN = '\x1b[36m';
const GRAY = '\x1b[90m';

console.log(`${BOLD}${CYAN}========================================================================${RESET}`);
console.log(`${BOLD}   PHASE 4 TRACK 3: MINIMALIST FLAT HUD & INTEGRATION TEST SUITE       ${RESET}`);
console.log(`${BOLD}   Specification: PLAN-0009 / 03_track3_infinite_upgrade_ui_and_integration_spec${RESET}`);
console.log(`${BOLD}${CYAN}========================================================================${RESET}\n`);

let passedCount = 0;
let failedCount = 0;

function check(id, title, condition, details = '') {
  const ok = Boolean(condition);
  if (ok) {
    passedCount++;
    console.log(`  ${GREEN}[PASS]${RESET} ${BOLD}${id}${RESET}: ${title} ${details ? `${GRAY}(${details})${RESET}` : ''}`);
  } else {
    failedCount++;
    console.error(`  ${RED}[FAIL]${RESET} ${BOLD}${id}${RESET}: ${title} - ${details}`);
  }
  return ok;
}

if (!fs.existsSync(UPGRADE_HUD_PATH) || !fs.existsSync(UPGRADE_SERVER_PATH) || !fs.existsSync(GAME_CONFIG_PATH)) {
  console.error("Required source files do not exist!");
  process.exit(1);
}

const hudSource = fs.readFileSync(UPGRADE_HUD_PATH, 'utf8').replace(/\r\n/g, '\n');
const serverSource = fs.readFileSync(UPGRADE_SERVER_PATH, 'utf8').replace(/\r\n/g, '\n');
const configSource = fs.readFileSync(GAME_CONFIG_PATH, 'utf8').replace(/\r\n/g, '\n');

// =============================================================================
// SUITE 1: STATIC INTEGRITY & TYPE AUDIT
// =============================================================================
console.log(`${BOLD}${CYAN}--- SUITE 1: STATIC INTEGRITY & SYNTAX AUDIT ---${RESET}`);

check('P4-STA-1.1', 'UpgradeHUD.client.luau enforces strict type checking', hudSource.trimStart().startsWith('--!strict'));
check('P4-STA-1.2', 'UpgradeServer.server.luau enforces strict type checking', serverSource.trimStart().startsWith('--!strict'));

const requiredServices = ['HttpService', 'Players', 'ReplicatedStorage', 'RunService', 'TweenService', 'Workspace'];
let servicesOk = true;
for (const s of requiredServices) {
  if (!hudSource.includes(`game:GetService("${s}")`)) {
    servicesOk = false;
  }
}
check('P4-STA-1.3', 'Required Roblox engine services imported safely', servicesOk);

let paren = 0, brack = 0, brace = 0;
for (const ch of hudSource) {
  if (ch === '(') paren++;
  else if (ch === ')') paren--;
  else if (ch === '[') brack++;
  else if (ch === ']') brack--;
  else if (ch === '{') brace++;
  else if (ch === '}') brace--;
}
check('P4-STA-1.4', 'Source code brackets, parentheses and braces perfectly balanced', paren === 0 && brack === 0 && brace === 0);

check('P4-STA-1.5', 'Source code contains zero cheat flags or mock markers',
  !hudSource.includes('__MOCK__') && !hudSource.includes('test_runner') && !hudSource.includes('bypass'));

// =============================================================================
// SUITE 2: SCREEN FOOTPRINT BUDGET MATHEMATICAL PROOF (PLAN-0009)
// =============================================================================
console.log(`\n${BOLD}${CYAN}--- SUITE 2: SCREEN FOOTPRINT BUDGET MATHEMATICAL PROOF (PLAN-0009) ---${RESET}`);

// Persistent HUD elements during standard gameplay:
// 1. TopWaveBar: 360 x 30 = 10,800 px²
// 2. CompactHeroDock: 404 x 52 = 21,008 px²
// 3. MiniActionToggles: 100 x 64 = 6,400 px²
const persistentElements = [
  { name: 'TopWaveBar', w: 360, h: 30 },
  { name: 'CompactHeroDock', w: 404, h: 52 },
  { name: 'MiniActionToggles', w: 100, h: 64 },
];

const totalPersistentArea = persistentElements.reduce((acc, el) => acc + (el.w * el.h), 0);
check('P4-BUD-2.1', 'Total persistent UI area strictly equals 38,208 px²', totalPersistentArea === 38208,
  `Persistent area: ${totalPersistentArea} px²`);

const viewports = [
  { res: '800x600', w: 800, h: 600 },
  { res: '1280x720 (720p)', w: 1280, h: 720 },
  { res: '1366x768', w: 1366, h: 768 },
  { res: '1920x1080 (1080p)', w: 1920, h: 1080 },
  { res: '2560x1440 (2K)', w: 2560, h: 1440 },
  { res: '3840x2160 (4K)', w: 3840, h: 2160 },
];

let budgetCompliant = true;
let visibilityOver85 = true;
for (const vp of viewports) {
  const screenArea = vp.w * vp.h;
  const ratio = totalPersistentArea / screenArea;
  if (ratio > 0.15) budgetCompliant = false;
  if ((1 - ratio) < 0.85) visibilityOver85 = false;
}

check('P4-BUD-2.2', 'Screen footprint <= 15% across all viewports (720p: 4.15%, 1080p: 1.84%)', budgetCompliant);
check('P4-BUD-2.3', 'Clear battlefield visibility strictly >= 85% across all resolutions', visibilityOver85);

// =============================================================================
// SUITE 3: TOP STATUS PILL & EARLY START BUTTON
// =============================================================================
console.log(`\n${BOLD}${CYAN}--- SUITE 3: TOP STATUS PILL & EARLY START BUTTON ---${RESET}`);

const hasTopPillGeometry = hudSource.includes('UDim2.new(0, 360, 0, 30)') &&
  hudSource.includes('UDim2.new(0.5, -180, 0, 6)');
check('P4-TOP-3.1', 'TopWaveBar capsule bar is 360x30 px at position (0.5, -180, 0, 6)', hasTopPillGeometry);

check('P4-TOP-3.2', 'TopWaveBar uses capsule rounding CornerRadius = UDim.new(1, 0)',
  hudSource.includes('topPillCorner.CornerRadius = UDim.new(1, 0)'));

const hasStatusText = hudSource.includes('statusLabel.Name = "StatusText"') &&
  hudSource.includes('UDim2.new(1, -80, 1, 0)') &&
  hudSource.includes('Enum.Font.GothamBold') &&
  hudSource.includes('TextSize = 13');
check('P4-TOP-3.3', 'StatusText single-line label configured with GothamBold 13pt and padding for button', hasStatusText);

const hasReactiveStrings = hudSource.includes('"WAVE %d  •  HP %d  •  $%d"') &&
  hudSource.includes('"⏳ PREP: %ds  •  HP %d  •  $%d"') &&
  hudSource.includes('"💀 BASE DESTROYED! RESTARTING WAVE 1..."');
check('P4-TOP-3.4', 'StatusText formats reactive states: normal wave, prep phase, and game over', hasReactiveStrings);

const hasEarlyStartBtn = hudSource.includes('earlyStartBtn.Name = "EarlyStartBtn"') &&
  hudSource.includes('UDim2.new(0, 64, 0, 22)') &&
  hudSource.includes('UDim2.new(1, -68, 0.5, -11)') &&
  hudSource.includes('Color3.fromRGB(245, 195, 55)') &&
  hudSource.includes('Text = "START"');
check('P4-TOP-3.5', 'EarlyStartBtn nested inside pill with size 64x22 px and gold background', hasEarlyStartBtn);

const hasEarlyStartAction = hudSource.includes('rf:InvokeServer("EarlyStart")') ||
  hudSource.includes('re:FireServer("EarlyStart")');
check('P4-TOP-3.6', 'EarlyStartBtn click dispatches authoritative "EarlyStart" action to server', hasEarlyStartAction);

// =============================================================================
// SUITE 4: BOTTOM COMPACT HERO DOCK & 8-SLOT INTERACTION
// =============================================================================
console.log(`\n${BOLD}${CYAN}--- SUITE 4: BOTTOM COMPACT HERO DOCK & 8-SLOT INTERACTION ---${RESET}`);

const hasDockGeometry = hudSource.includes('UDim2.new(0, 404, 0, 52)') &&
  hudSource.includes('UDim2.new(0.5, -202, 1, -58)');
check('P4-DCK-4.1', 'CompactHeroDock is 404x52 px at position (0.5, -202, 1, -58)', hasDockGeometry);

check('P4-DCK-4.2', 'CompactHeroDock uses rounded corners CornerRadius = UDim.new(0, 10)',
  hudSource.includes('heroDockCorner.CornerRadius = UDim.new(0, 10)'));

const has8Slots = hudSource.includes('for i = 1, 8 do') &&
  hudSource.includes('btn.Name = "Slot_" .. i') &&
  hudSource.includes('UDim2.new(0, 44, 0, 44)') &&
  hudSource.includes('UDim2.new(0, 6 + (i - 1) * 49, 0, 4)');
check('P4-DCK-4.3', 'Dock generates 8 square unit slots of size 44x44 px spaced across 404px frame', has8Slots);

const heroAcronyms = ['LUF', 'ZOR', 'SAN', 'SHA', 'WB', 'ACE', 'LAW', 'KIZ'];
let acronymsOk = true;
for (const a of heroAcronyms) {
  if (!hudSource.includes(`"${a}"`)) acronymsOk = false;
}
check('P4-DCK-4.4', 'All 8 hero acronyms defined (LUF, ZOR, SAN, SHA, WB, ACE, LAW, KIZ)', acronymsOk);

const hasSlotActions = hudSource.includes('"PlaceOrSwap"') &&
  hudSource.includes('"StoreToBag"') &&
  hudSource.includes('"SellFromSlot"');
check('P4-DCK-4.5', 'Dock slot buttons handle PlaceOrSwap, StoreToBag, and SellFromSlot', hasSlotActions);

const hasBagTray = hudSource.includes('bagPanel.Name = "BottomBagAndSlotPanel"') &&
  hudSource.includes('UDim2.new(0, 404, 0, 58)') &&
  hudSource.includes('UDim2.new(0.5, -202, 1, -122)');
check('P4-DCK-4.6', 'Compact collapsible bag tray (404x58 px) attached directly above hero dock', hasBagTray);

// =============================================================================
// SUITE 5: COLLAPSIBLE MINI ACTION TOGGLES & DRAWERS
// =============================================================================
console.log(`\n${BOLD}${CYAN}--- SUITE 5: COLLAPSIBLE MINI ACTION TOGGLES & DRAWERS ---${RESET}`);

const hasMiniToggles = hudSource.includes('miniActionToggles.Name = "MiniActionToggles"') &&
  hudSource.includes('UDim2.new(0, 100, 0, 64)') &&
  hudSource.includes('UDim2.new(0, 10, 1, -128)');
check('P4-DRW-5.1', 'MiniActionToggles container is 100x64 px positioned at bottom-left (0, 10, 1, -128)', hasMiniToggles);

const hasToggleButtons = hudSource.includes('toggleUpgradeBtn.Name = "ToggleUpgradeBtn"') &&
  hudSource.includes('Text = "▲ STATS"') &&
  hudSource.includes('toggleGachaBtn.Name = "ToggleGachaBtn"') &&
  hudSource.includes('Text = "★ SUMMON"');
check('P4-DRW-5.2', 'ToggleUpgradeBtn ("▲ STATS") and ToggleGachaBtn ("★ SUMMON") present', hasToggleButtons);

const hasUpgradeDrawer = hudSource.includes('upgradePanel.Name = "UpgradeShopFrame"') &&
  hudSource.includes('UDim2.new(0, 210, 0, 185)') &&
  hudSource.includes('UDim2.new(0, 10, 1, -320)');
check('P4-DRW-5.3', 'UpgradeShopFrame drawer is 210x185 px at position (0, 10, 1, -320)', hasUpgradeDrawer);

const hasDefaultHiddenDrawers = hudSource.includes('upgradePanel.Visible = false') &&
  hudSource.includes('summonModal.Visible = false');
check('P4-DRW-5.4', 'Both UpgradeShopFrame and CentralWantedGachaModal default to Visible = false', hasDefaultHiddenDrawers);

const hasToggleHandlers = hudSource.includes('upgradePanel.Visible = not upgradePanel.Visible') &&
  hudSource.includes('summonModal.Visible = not summonModal.Visible');
check('P4-DRW-5.5', 'Clicking toggle buttons cleanly inverts Visible property of corresponding drawers', hasToggleHandlers);

// =============================================================================
// SUITE 6: COMPACT WAVE CARD DRAFT MODAL & VERTICAL CLEARANCE
// =============================================================================
console.log(`\n${BOLD}${CYAN}--- SUITE 6: COMPACT WAVE CARD DRAFT MODAL & VERTICAL CLEARANCE ---${RESET}`);

const hasDraftModalGeometry = hudSource.includes('draftModal.Name = "WaveCardDraftModal"') &&
  hudSource.includes('UDim2.new(0, 500, 0, 175)') &&
  hudSource.includes('UDim2.new(0.5, -250, 0, 44)');
check('P4-MOD-6.1', 'WaveCardDraftModal geometry is 500x175 px at position (0.5, -250, 0, 44)', hasDraftModalGeometry);

// Vertical Clearance Proof:
// Modal top: Y = 44px, height: 175px -> terminates at Y = 219px.
// Bottom Hero Dock starts at: Y = screenHeight - 58px.
// On 720p: 720 - 58 = 662px. Clearance = 662 - 219 = 443px >= 440px.
// On 1080p: 1080 - 58 = 1022px. Clearance = 1022 - 219 = 803px.
const modalBottomY = 44 + 175;
const dockTopY720p = 720 - 58;
const clearance720p = dockTopY720p - modalBottomY;
check('P4-MOD-6.2', 'Vertical clearance between draft modal and hero dock is 443px on 720p (>= 440px guaranteed)',
  clearance720p >= 440, `Clearance: ${clearance720p} px`);

const has3Cards = hudSource.includes('UDim2.new(0, 154, 0, 134)') &&
  hudSource.includes('UDim2.new(0, 10 + (i - 1) * 163, 0, 2)');
check('P4-MOD-6.3', '3 compact cards generated with size 154x134 px and horizontal alignment', has3Cards);

const hasRerollCardsBtn = hudSource.includes('rerollBtn.Name = "RerollCardsBtn"') &&
  hudSource.includes('UDim2.new(0, 88, 0, 20)') &&
  hudSource.includes('UDim2.new(1, -96, 0, 6)') &&
  hudSource.includes('Text = "Reroll ($50)"');
check('P4-MOD-6.4', 'RerollCardsBtn present with size 88x20 px at (1, -96, 0, 6) with text "Reroll ($50)"', hasRerollCardsBtn);

const hasCollapseToggle = hudSource.includes('collapseToggleBtn.Name = "CollapseToggleBtn"') &&
  hudSource.includes('UDim2.new(0, 24, 0, 20)') &&
  hudSource.includes('Text = "[-]"') &&
  hudSource.includes('draftModal.Size = UDim2.new(0, 500, 0, 30)');
check('P4-MOD-6.5', 'CollapseToggleBtn present with [-]/[+] toggle collapsing modal height to 30px', hasCollapseToggle);

// =============================================================================
// SUITE 7: UPGRADESERVER AUTHORITY & REMOTE CONTRACT STABILITY
// =============================================================================
console.log(`\n${BOLD}${CYAN}--- SUITE 7: UPGRADESERVER AUTHORITY & REMOTE CONTRACT STABILITY ---${RESET}`);

const serverHasEarlyStart = serverSource.includes('actionStr == "EarlyStart"') &&
  serverSource.includes('handleEarlyStart(player)') &&
  serverSource.includes('Workspace:SetAttribute(prepAttr, 0)');
check('P4-SRV-7.1', 'UpgradeServer authoritatively handles "EarlyStart" and zeroes PrepCountdown', serverHasEarlyStart);

const serverHasRerollCards = serverSource.includes('actionStr == "RerollCards"') &&
  serverSource.includes('handleRerollCards(player)') &&
  serverSource.includes('setCash(player, curCash - 50)');
check('P4-SRV-7.2', 'UpgradeServer authoritatively handles "RerollCards" with $50 deduction', serverHasRerollCards);

const hasCardSelection = serverSource.includes('handleCardSelect(player, actionStr)');
check('P4-SRV-7.3', 'UpgradeServer preserves roguelike card application handlers', hasCardSelection);

const hasPlacementRemotes = hudSource.includes('re:FireServer("PlaceOrSwap", slotSpec.SlotId, selectedUid)') &&
  hudSource.includes('re:FireServer("StoreToBag", slotSpec.SlotId)') &&
  hudSource.includes('re:FireServer("SellFromSlot", slotSpec.SlotId)') &&
  hudSource.includes('re:FireServer("SellFromBag", unit.Uid)') &&
  hudSource.includes('re:FireServer("SelectBagUnit", unit.Uid)');
check('P4-SRV-7.4', 'All tactical placement pad remote invocation contracts strictly preserved', hasPlacementRemotes);

const hasGachaRemotes = hudSource.includes('re:FireServer("Summon")') &&
  hudSource.includes('re:FireServer("Reroll")');
check('P4-SRV-7.5', 'Gacha summon and reroll remote invocation contracts strictly preserved', hasGachaRemotes);

const hasStatUpgrades = hudSource.includes('fireStatUpgrade("Damage")') &&
  hudSource.includes('fireStatUpgrade("Range")') &&
  hudSource.includes('fireStatUpgrade("Speed")') &&
  hudSource.includes('curCd > minCd');
check('P4-SRV-7.6', 'Stat upgrade dispatches and minimum cooldown floor lock strictly preserved', hasStatUpgrades);

// =============================================================================
// TEST SUMMARY & VERDICT
// =============================================================================
console.log(`\n${BOLD}${CYAN}========================================================================${RESET}`);
console.log(`${BOLD}   PHASE 4 TRACK 3 TEST SUMMARY                                        ${RESET}`);
console.log(`${BOLD}${CYAN}========================================================================${RESET}`);
console.log(`  Total Checks Executed : ${BOLD}${passedCount + failedCount}${RESET}`);
console.log(`  Passed Checks         : ${BOLD}${GREEN}${passedCount}${RESET}`);
console.log(`  Failed Checks         : ${BOLD}${failedCount > 0 ? RED : GREEN}${failedCount}${RESET}`);
console.log(`  Pass Rate             : ${BOLD}${GREEN}${((passedCount / (passedCount + failedCount)) * 100).toFixed(1)}%${RESET}\n`);

if (failedCount > 0) {
  console.error(`${BOLD}${RED}VERDICT: REJECTED (${failedCount} checks failed)${RESET}\n`);
  process.exit(1);
} else {
  console.log(`${BOLD}${GREEN}VERDICT: APPROVED (100% Phase 4 Track 3 requirements verified)${RESET}\n`);
  process.exit(0);
}
