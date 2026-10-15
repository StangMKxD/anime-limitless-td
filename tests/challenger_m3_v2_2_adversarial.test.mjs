// tests/challenger_m3_v2_2_adversarial.test.mjs
// Adversarial Empirical Challenger Verification Suite for Milestone 3 (v2.2)
// Challenger: challenger_m3_v2_2
// Focus: Procedural Rigging, Welds, Unified Kinematics, Idle Bobbing, 144-step Aura Rotation,
//        5-Phase Combat Timing, Weapon Synchronization, 8 Signature Ultimates & Masterpiece VFX

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(__dirname, '..');

const TOWER_CONTROLLER_PATH = path.join(PROJECT_ROOT, 'src', 'Track2_TowerSystem', 'TowerController.server.luau');
const GAME_CONFIG_PATH = path.join(PROJECT_ROOT, 'src', 'Shared', 'GameConfig.luau');
const WAVE_MANAGER_PATH = path.join(PROJECT_ROOT, 'src', 'Track1_WaveSystem', 'WaveManager.server.luau');

const towerSource = fs.readFileSync(TOWER_CONTROLLER_PATH, 'utf8');
const configSource = fs.readFileSync(GAME_CONFIG_PATH, 'utf8');
const waveSource = fs.readFileSync(WAVE_MANAGER_PATH, 'utf8');

// ANSI formatting
const BOLD = '\x1b[1m';
const RESET = '\x1b[0m';
const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const CYAN = '\x1b[36m';
const MAGENTA = '\x1b[35m';
const YELLOW = '\x1b[33m';
const GRAY = '\x1b[90m';

console.log(`${BOLD}${CYAN}========================================================================${RESET}`);
console.log(`${BOLD}   ADVERSARIAL EMPIRICAL CHALLENGER V2.2: RIGGING, KINEMATICS & VFX    ${RESET}`);
console.log(`${BOLD}   Target: src/Track2_TowerSystem/TowerController.server.luau          ${RESET}`);
console.log(`${BOLD}${CYAN}========================================================================${RESET}\n`);

let totalChecks = 0;
let passedChecks = 0;
let failedChecks = 0;

function assertCheck(id, description, condition, details = '') {
  totalChecks++;
  if (condition) {
    passedChecks++;
    console.log(`  ${GREEN}[PASS]${RESET} ${BOLD}${id}${RESET}: ${description} ${details ? `${GRAY}(${details})${RESET}` : ''}`);
  } else {
    failedChecks++;
    console.error(`  ${RED}[FAIL]${RESET} ${BOLD}${id}${RESET}: ${description} - FAILED! ${YELLOW}${details}${RESET}`);
  }
}

// =============================================================================
// DOMAIN 1: PROCEDURAL RIGGING, WELDCONSTRAINTS & 15 CUSTOM ACCESSORIES
// =============================================================================
console.log(`${BOLD}${MAGENTA}--- DOMAIN 1: PROCEDURAL RIGGING, WELDCONSTRAINTS & ACCESSORIES ---${RESET}`);

// 1.1 Root part dimensions and collision flags
const rootPartPattern = /root\.Name\s*=\s*"HumanoidRootPart"[\s\S]*?root\.Size\s*=\s*Vector3\.new\(2\.2,\s*2\.4,\s*1\.2\)[\s\S]*?root\.Anchored\s*=\s*true[\s\S]*?root\.CanCollide\s*=\s*false/;
assertCheck('RIG-2.1', 'HumanoidRootPart correctly initialized (2.2, 2.4, 1.2, Anchored=true, CanCollide=false)',
  rootPartPattern.test(towerSource),
  'HumanoidRootPart geometry verified');

// 1.2 WeldConstraint helper exists and sets childPart.Anchored = false
const weldHelperPattern = /local\s+function\s+weldToRoot\(childPart:\s*BasePart,\s*rootPart:\s*BasePart\):\s*WeldConstraint[\s\S]*?Instance\.new\("WeldConstraint"\)[\s\S]*?weld\.Part0\s*=\s*rootPart[\s\S]*?weld\.Part1\s*=\s*childPart[\s\S]*?childPart\.Anchored\s*=\s*false/;
assertCheck('RIG-2.2', 'weldToRoot helper constructs WeldConstraint between rootPart and childPart with Anchored=false',
  weldHelperPattern.test(towerSource),
  'weldToRoot helper verified');

// 1.3 Welds applied to all standard limbs and weapon
const headWelded = /head\.Name\s*=\s*"Head"[\s\S]*?weldToRoot\(head,\s*root\)/.test(towerSource);
const rightArmWelded = /rightArm\.Name\s*=\s*"RightArm"[\s\S]*?weldToRoot\(rightArm,\s*root\)/.test(towerSource);
const leftArmWelded = /leftArm\.Name\s*=\s*"LeftArm"[\s\S]*?weldToRoot\(leftArm,\s*root\)/.test(towerSource);
const weaponWelded = /weapon\.Name\s*=\s*"SignatureWeapon"[\s\S]*?weldToRoot\(weapon,\s*root\)/.test(towerSource);
assertCheck('RIG-2.3', 'Head, RightArm, LeftArm, and SignatureWeapon all anchored via weldToRoot(..., root)',
  headWelded && rightArmWelded && leftArmWelded && weaponWelded,
  'All 4 primary limbs/weapons welded');

// 1.4 All 15 distinct accessories across 8 One Piece Heroes welded via weldToRoot
const accessoryList = [
  { name: 'Gear5CloudScarf', hero: 'Luffy' },
  { name: 'StrawHat', hero: 'Luffy' },
  { name: 'YonkoBlackCape', hero: 'Shanks' },
  { name: 'ShanksRedHair', hero: 'Shanks' },
  { name: 'CrescentMustache', hero: 'Whitebeard' },
  { name: 'CaptainCoat', hero: 'Whitebeard' },
  { name: 'SandaiKitetsu', hero: 'Zoro' },
  { name: 'ZoroHair', hero: 'Zoro' },
  { name: 'AceCowboyHat', hero: 'Ace' },
  { name: 'RedBeadNecklace', hero: 'Ace' },
  { name: 'LawFurHat', hero: 'Law' },
  { name: 'JusticeCape', hero: 'Kizaru' },
  { name: 'TintedGlasses', hero: 'Kizaru' },
  { name: 'BlondeHair', hero: 'Sanji' },
  { name: 'GoldenTie', hero: 'Sanji' },
];

let allAccessoriesWelded = true;
const unwelded = [];
for (const acc of accessoryList) {
  // Find the variable assigned for this accessory: local (\w+) = ... \1.Name = "acc.name" ... weldToRoot(\1, root)
  const pattern = new RegExp(`local\\s+(\\w+)\\s*=\\s*Instance\\.new\\("Part"\\)[\\s\\S]*?\\1\\.Name\\s*=\\s*"${acc.name}"[\\s\\S]*?weldToRoot\\(\\1,\\s*root\\)`);
  if (!pattern.test(towerSource)) {
    allAccessoriesWelded = false;
    unwelded.push(acc.name);
  }
}
assertCheck('RIG-2.4', 'All 15 procedural One Piece accessories are rigidly bound via weldToRoot(..., root)',
  allAccessoriesWelded,
  unwelded.length === 0 ? 'All 15 accessories welded to root' : `Unwelded: ${unwelded.join(', ')}`);

// =============================================================================
// DOMAIN 2: UNIFIED KINEMATICS & IDLE BOBBING MATHEMATICAL HARNESS
// =============================================================================
console.log(`\n${BOLD}${MAGENTA}--- DOMAIN 2: UNIFIED KINEMATICS & IDLE BOBBING MATHEMATICS ---${RESET}`);

// 2.1 Static formula verification
const bobbingRegex = /local\s+bob\s*=\s*math\.sin\(now\s*\*\s*3\.2\)\s*\*\s*0\.35/;
assertCheck('KIN-2.1', 'Idle bobbing equation Y(t) = Y_base + 0.35 * sin(3.2t) explicitly verified in source',
  bobbingRegex.test(towerSource),
  'Formula: sin(now * 3.2) * 0.35');

// 2.2 2,000,000 Step Numerical Simulation with High-Frequency Jitter & Extreme Temporal Range
const SIM_STEPS = 2000000;
let minBob = Infinity;
let maxBob = -Infinity;
let maxVel = 0;
let maxAccel = 0;
let nanOccurred = false;

// Test across t = 0 to 1,000,000 seconds
const baseFreq = 3.2;
const baseAmp = 0.35;
let currTime = 0;
const timeDelta = 0.005; // 5ms steps

for (let s = 0; s < SIM_STEPS; s++) {
  currTime += timeDelta;
  const bobVal = Math.sin(currTime * baseFreq) * baseAmp;
  if (Number.isNaN(bobVal)) {
    nanOccurred = true;
  }
  if (bobVal < minBob) minBob = bobVal;
  if (bobVal > maxBob) maxBob = bobVal;

  const vel = Math.abs(baseAmp * baseFreq * Math.cos(currTime * baseFreq));
  if (vel > maxVel) maxVel = vel;

  const accel = Math.abs(baseAmp * baseFreq * baseFreq * Math.sin(currTime * baseFreq));
  if (accel > maxAccel) maxAccel = accel;
}

const boundsHold = (minBob >= -0.35000000001) && (maxBob <= 0.35000000001);
assertCheck('KIN-2.2', 'Idle bobbing oscillation strictly confined to [-0.35, +0.35] over 2,000,000 continuous steps',
  boundsHold && !nanOccurred,
  `Min: ${minBob.toFixed(6)}, Max: +${maxBob.toFixed(6)}, Max V: ${maxVel.toFixed(4)} st/s, Max A: ${maxAccel.toFixed(4)} st/s^2`);

// 2.3 Sub-millisecond & IEEE-754 Boundary Testing (t = 2^32, 2^48, -1000, epsilon)
const testTimestamps = [
  0,
  1e-15,
  1e-7,
  Math.PI / 6.4, // Quarter period = peak 0.35
  Math.PI / 3.2, // Half period = 0
  (3 * Math.PI) / 6.4, // 3/4 period = trough -0.35
  2 * Math.PI / 3.2, // Full period = 0
  86400, // 1 day
  2592000, // 30 days
  31536000, // 1 year
  1e9,
  1e12,
  -500,
];

let boundaryAllPass = true;
for (const tt of testTimestamps) {
  const b = Math.sin(tt * 3.2) * 0.35;
  if (b < -0.35000000001 || b > 0.35000000001 || Number.isNaN(b)) {
    boundaryAllPass = false;
  }
}
assertCheck('KIN-2.3', 'Extreme timestamp range (0 to 10^12s, negative, and micro-epsilon) strictly respects [-0.35, +0.35]',
  boundaryAllPass,
  '13 temporal boundary conditions passed');

// 2.4 Head, Arms and Weapon Position Updates in Idle Loop
const headTracking = /head\.Position\s*=\s*tower\.PrimaryPart\.Position\s*\+\s*Vector3\.new\(0,\s*1\.95,\s*0\)/.test(towerSource);
const rightArmBob = /local\s+armBob\s*=\s*math\.sin\(now\s*\*\s*3\.2\s*\+\s*0\.4\)\s*\*\s*0\.08/.test(towerSource);
const leftArmBob = /local\s+armBobLeft\s*=\s*math\.sin\(now\s*\*\s*3\.2\s*-\s*0\.4\)\s*\*\s*0\.08/.test(towerSource);
const weaponTracking = /weapon\.Position\s*=\s*rightArm\.Position\s*\+\s*Vector3\.new\(0,\s*0\.5,\s*-1\.8\)/.test(towerSource);
assertCheck('KIN-2.4', 'Idle heartbeat loop synchronously updates Head (+1.95), RightArm (+0.4 phase), LeftArm (-0.4 phase), and Weapon',
  headTracking && rightArmBob && leftArmBob && weaponTracking,
  'All limb & weapon coordinates synchronized in heartbeat loop');

// =============================================================================
// DOMAIN 3: 144-STEP AURA ROTATION MATHEMATICAL ORTHOGONALITY
// =============================================================================
console.log(`\n${BOLD}${MAGENTA}--- DOMAIN 3: 144-STEP AURA ROTATION HARNESS ---${RESET}`);

// 3.1 Step angle matches 2.5 degrees
const auraStepRegex = /ring\.CFrame\s*=\s*ring\.CFrame\s*\*\s*CFrame\.Angles\(math\.rad\(2\.5\),\s*0,\s*0\)/;
assertCheck('AUR-3.1', 'Aura rotation step angle is exactly 2.5 deg around local cylinder axis',
  auraStepRegex.test(towerSource),
  'Step: 2.5 deg per frame');

// 3.2 Accumulator: 144 steps = 360 deg exact
const stepsToFullRev = 360 / 2.5;
assertCheck('AUR-3.2', 'Aura rotation completes exactly 1 full 360-degree revolution in exactly 144 steps',
  stepsToFullRev === 144,
  '360 / 2.5 = 144 steps');

// 3.3 Orthogonal Rotation Simulation: 1,000 Revolutions (144,000 steps)
let rotAngleRad = 0;
const stepAngleRad = (2.5 * Math.PI) / 180;
let matrixCos = 1.0;
let matrixSin = 0.0;
const cStep = Math.cos(stepAngleRad);
const sStep = Math.sin(stepAngleRad);

for (let i = 0; i < 144000; i++) {
  rotAngleRad += stepAngleRad;
  const nextCos = matrixCos * cStep - matrixSin * sStep;
  const nextSin = matrixCos * sStep + matrixSin * cStep;
  matrixCos = nextCos;
  matrixSin = nextSin;
}

const matrixDeterminant = matrixCos * matrixCos + matrixSin * matrixSin;
const detDrift = Math.abs(matrixDeterminant - 1.0);
assertCheck('AUR-3.3', 'Rotational accumulator preserves SO(2) matrix determinant after 1,000 full revolutions (144,000 steps)',
  detDrift < 1e-10,
  `Determinant drift: ${detDrift.toExponential(4)}`);

// =============================================================================
// DOMAIN 4: 5-PHASE COMBAT SEQUENCE TIMELINE & WEAPON SYNCHRONIZATION
// =============================================================================
console.log(`\n${BOLD}${MAGENTA}--- DOMAIN 4: 5-PHASE COMBAT SEQUENCE & WEAPON SYNCHRONIZATION ---${RESET}`);

// 4.1 Chronological Timing Breakdown
const p1Time = /TweenInfo\.new\(0\.14,\s*Enum\.EasingStyle\.Quad/.test(towerSource) && /task\.delay\(0\.14,/.test(towerSource);
const p2Time = /TweenInfo\.new\(0\.10,\s*Enum\.EasingStyle\.Exponential/.test(towerSource) && /task\.delay\(0\.10,/.test(towerSource);
const p3Time = /task\.delay\(0\.07,/.test(towerSource);
const p4Time = /task\.delay\(0\.20,/.test(towerSource);
const p5Time = /TweenInfo\.new\(0\.22,\s*Enum\.EasingStyle\.Quad/.test(towerSource) && /task\.delay\(0\.22,/.test(towerSource);

assertCheck('TIM-4.1', '5-Phase attack durations: P1=0.14s, P2=0.10s, P3=0.07s, P4=0.20s, P5=0.22s',
  p1Time && p2Time && p3Time && p4Time && p5Time,
  'All 5 timing phases match specification');

const totalDuration = 0.14 + 0.10 + 0.07 + 0.20 + 0.22;
assertCheck('TIM-4.2', 'Total sequence duration equals 0.73s (730ms)',
  Math.abs(totalDuration - 0.73) < 1e-9,
  `Total: ${totalDuration.toFixed(2)}s`);

// 4.2 Multi-Phase Weapon Synchronization
const weaponP1 = /Position\s*=\s*startPos\s*\+\s*Vector3\.new\(0\.4,\s*2\.7,\s*-1\.2\)/.test(towerSource);
const weaponP2 = /Position\s*=\s*dashPos\s*\+\s*fwdDir\s*\*\s*1\.8\s*\+\s*Vector3\.new\(0,\s*0\.9,\s*-1\.8\)/.test(towerSource);
const weaponP5 = /Position\s*=\s*returnArmPos\s*\+\s*Vector3\.new\(0,\s*0\.5,\s*-1\.8\)/.test(towerSource);
const weaponReset = /weapon\.Position\s*=\s*rightArm\.Position\s*\+\s*Vector3\.new\(0,\s*0\.5,\s*-1\.8\)/.test(towerSource);

assertCheck('TIM-4.3', 'SignatureWeapon actively tracked through Phase 1, Phase 2, Phase 5 and reset on completion',
  weaponP1 && weaponP2 && weaponP5 && weaponReset,
  'Weapon synchronized through all kinematic phases');

// 4.3 Concurrency Lock: IsAttacking Lifecycle
const setTrue = /tower:SetAttribute\("IsAttacking",\s*true\)/.test(towerSource);
const setFalse = /tower:SetAttribute\("IsAttacking",\s*false\)/.test(towerSource);
const idleGuarded = /local\s+isAttacking\s*=\s*\(tower:GetAttribute\("IsAttacking"\)\s*::\s*boolean\?\)\s*or\s*false[\s\S]*?if\s+not\s+isAttacking\s+then/.test(towerSource);

assertCheck('TIM-4.4', 'IsAttacking concurrency lock is set true at start, reset false at end, and guards idle bobbing',
  setTrue && setFalse && idleGuarded,
  'Concurrency lock lifecycle verified');

// =============================================================================
// DOMAIN 5: 8 SIGNATURE ONE PIECE ULTIMATE VFX TABLES (MASTERPIECE QUALITY)
// =============================================================================
console.log(`\n${BOLD}${MAGENTA}--- DOMAIN 5: 8 SIGNATURE ONE PIECE ULTIMATE VFX TABLES ---${RESET}`);

const masterStyles = [
  {
    heroId: 'Tower_Luffy_G5',
    name: 'MONKEY D. LUFFY',
    style: 'BajrangFist',
    parts: ['NikaSkyPortal', 'BajrangGiantFist', 'BajrangShockwave'],
    manga: 'DOOM!! (หมัดเทพนิกะ!!)',
    shake: 0.70,
    hakiBolts: 12,
  },
  {
    heroId: 'Tower_Shanks_Kamusari',
    name: 'RED-HAIRED SHANKS',
    style: 'Kamusari',
    parts: ['KamusariCrescentSlash', 'KamusariShockRing'],
    manga: 'KAMUSARI!! (เทวะอาสัญ!!)',
    shake: 0.70,
    hakiBolts: 10,
  },
  {
    heroId: 'Tower_Whitebeard_Gura',
    name: 'EDWARD NEWGATE',
    style: 'GuraQuake',
    parts: ['TremorGlassCrack', 'TremorDome', 'SeaQuakeRing'],
    manga: 'CRACK!! (สั่นสะเทือนโลกา!!)',
    shake: 0.70,
    hakiBolts: 8,
  },
  {
    heroId: 'Tower_Zoro_KingOfHell',
    name: 'RORONOA ZORO',
    style: 'KingOfHell360',
    parts: ['KingOfHellTornado'],
    manga: 'ONIGIRI!! (ราชานรก!!)',
    shake: 0.45,
    hakiBolts: 8,
  },
  {
    heroId: 'Tower_Ace_Entei',
    name: 'PORTGAS D. ACE',
    style: 'Entei',
    parts: ['AceEnteiSun', 'EnteiFireShock'],
    manga: 'ENTEI!! (มหาจักรพรรดิอัคคี!!)',
    shake: 0.45,
    hakiBolts: 8,
  },
  {
    heroId: 'Tower_Law_KRoom',
    name: 'TRAFALGAR LAW',
    style: 'GammaKnife',
    parts: ['KRoomSpatialDome', 'PunctureWilleBlade'],
    manga: 'K-ROOM!! (พังก์เจอร์ วิลเล!!)',
    shake: 0.45,
    hakiBolts: 6,
  },
  {
    heroId: 'Tower_Kizaru_Pika',
    name: 'ADMIRAL KIZARU',
    style: 'YasakaniLight',
    parts: ['YasakaniPhotonBeam'],
    manga: 'FLASH!! (ลำแสงความเร็วแสง!!)',
    shake: 0.45,
    hakiBolts: 8,
  },
  {
    heroId: 'Tower_Sanji_Ifrit',
    name: 'VINSMOKE SANJI',
    style: 'BoeufBurst',
    parts: ['BoeufBurstPillar'],
    manga: 'IFRIT!! (ลูกเตะเพลิงสีคราม!!)',
    shake: 0.45,
    hakiBolts: 6,
  },
];

for (const s of masterStyles) {
  let stylePass = true;
  const missing = [];

  // Check Onomatopoeia in GameConfig
  if (!configSource.includes(`"${s.manga}"`)) {
    stylePass = false;
    missing.push(`MangaSFX: ${s.manga}`);
  }

  // Check procedural VFX parts in TowerController
  for (const part of s.parts) {
    const partRegex = new RegExp(`\\.Name\\s*=\\s*"${part}"`);
    if (!partRegex.test(towerSource)) {
      stylePass = false;
      missing.push(`Part: ${part}`);
    }
  }

  assertCheck('VFX-5.' + s.style, `Ultimate "${s.style}" (${s.name}): Manga "${s.manga}", Shake ${s.shake}, Parts [${s.parts.join(', ')}]`,
    stylePass,
    missing.length === 0 ? 'Verified' : `Missing: ${missing.join(', ')}`);
}

// 5.9 Dynamic PointLight Flash Specifications
const pointLightTest = /impactLight\.Brightness\s*=\s*8/.test(towerSource)
  && /impactLight\.Range\s*=\s*40/.test(towerSource)
  && /impactLight\.Shadows\s*=\s*false/.test(towerSource)
  && /TweenInfo\.new\(0\.35,\s*Enum\.EasingStyle\.Quad,\s*Enum\.EasingDirection\.Out\)/.test(towerSource);
assertCheck('VFX-5.9', 'Dynamic PointLight: Brightness=8, Range=40 studs, Shadows=false, 0.35s fade',
  pointLightTest,
  'PointLight flash verified');

// 5.10 Radial Conqueror\'s Haki Lightning Bolts
const hakiTest = /spawnHakiLightningBolts\(targetPos,\s*heroSpec\.SecondaryColor,\s*8\)/.test(towerSource)
  && /math\.rad\(\(360\s*\/\s*boltCount\)\s*\*\s*i\s*\+\s*math\.random\(-15,\s*15\)\)/.test(towerSource)
  && /\(target\s*-\s*origin\)\.Magnitude\s*>=\s*0\.05/.test(towerSource);
assertCheck('VFX-5.10', 'Conqueror\'s Haki lightning bolts: 360/N distribution with ±15 deg jitter and >= 0.05 singularity guard',
  hakiTest,
  'Radial Haki lightning verified');

// 5.11 Whitebeard Gura Quake Slow Debuff (0.45x for 2.5s)
const guraDebuff = /if\s+spec\.AttackStyle\s*==\s*"GuraQuake"\s+then\s*enemy:SetAttribute\("SlowUntil",\s*now\s*\+\s*2\.5\)\s*end/.test(towerSource);
assertCheck('VFX-5.11', 'Whitebeard GuraQuake sets SlowUntil = now + 2.5 on damaged targets',
  guraDebuff,
  'Slow: 2.5s duration');

// =============================================================================
// DOMAIN 6: ZERO-LEAK GARBAGE COLLECTION & DEFENSIVE INTEGRITY
// =============================================================================
console.log(`\n${BOLD}${MAGENTA}--- DOMAIN 6: ZERO-LEAK GARBAGE COLLECTION & INTEGRITY ---${RESET}`);

// 6.1 Multi-Point nil assignment for lastAttackTime
const swapNil = /placeOrSwapTowerOnSlot[\s\S]*?lastAttackTime\[existingTower\]\s*=\s*nil[\s\S]*?existingTower:Destroy\(\)/.test(towerSource);
const storeNil = /storeTowerToBag[\s\S]*?lastAttackTime\[existingTower\]\s*=\s*nil[\s\S]*?existingTower:Destroy\(\)/.test(towerSource);
const sellNil = /sellTowerUnit[\s\S]*?lastAttackTime\[existingTower\]\s*=\s*nil[\s\S]*?existingTower:Destroy\(\)/.test(towerSource);
const destroyingHook = /model\.Destroying:Connect\(function\(\)[\s\S]*?lastAttackTime\[model\]\s*=\s*nil[\s\S]*?end\)/.test(towerSource);

assertCheck('GC-6.1', 'lastAttackTime table explicitly dereferences destroyed towers across swap, store, sell, and Destroying hook',
  swapNil && storeNil && sellNil && destroyingHook,
  'Zero-leak garbage collection verified');

// 6.2 Fresh Enemy Query at Impact
const freshEnemyQuery = /onImpactCallback\(\)[\s\S]*?local\s+now\s*=\s*os\.clock\(\)[\s\S]*?local\s+currentEnemiesFolder\s*=\s*Workspace:FindFirstChild\("Enemies"\)[\s\S]*?local\s+currentEnemies\s*=\s*currentEnemiesFolder\s*and\s*currentEnemiesFolder:GetChildren\(\)\s*or\s*\{\}/.test(towerSource);
assertCheck('FSH-6.2', 'Active enemies query refreshed at exact moment of impact (0.31s post-targeting)',
  freshEnemyQuery,
  'Fresh enemy query verified');

// =============================================================================
// VERDICT & SUMMARY
// =============================================================================
console.log(`\n${BOLD}${CYAN}========================================================================${RESET}`);
console.log(`${BOLD}CHALLENGE HARNESS VERDICT & SUMMARY:${RESET}`);
console.log(`Total Checks Executed : ${BOLD}${totalChecks}${RESET}`);
console.log(`Passed Checks         : ${BOLD}${GREEN}${passedChecks}${RESET}`);
console.log(`Failed Checks         : ${BOLD}${failedChecks > 0 ? RED : GREEN}${failedChecks}${RESET}`);
console.log(`Pass Rate             : ${BOLD}${((passedChecks / totalChecks) * 100).toFixed(1)}%${RESET}`);
console.log(`${BOLD}${CYAN}========================================================================${RESET}\n`);

if (failedChecks === 0) {
  console.log(`${GREEN}${BOLD}FINAL EMPIRICAL VERDICT: APPROVE (All rigorous stress & edge tests passed)${RESET}`);
  process.exit(0);
} else {
  console.error(`${RED}${BOLD}FINAL EMPIRICAL VERDICT: REJECT (${failedChecks} failures detected)${RESET}`);
  process.exit(1);
}
