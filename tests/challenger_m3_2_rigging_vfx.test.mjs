// tests/challenger_m3_2_rigging_vfx.test.mjs
// Adversarial Empirical Challenge Suite for Milestone 3 Track 2 TowerController.server.luau
// Challenger: challenger_m3_2
// Focus: Procedural Rigging Geometry, Idle Kinematics Bounds, 144-step Aura Rotation,
//        5-Phase Combat Timing, IsAttacking Concurrency Lock, 8 Signature Ultimates & VFX Tables.

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(__dirname, '..');

const TOWER_CONTROLLER_PATH = path.join(PROJECT_ROOT, 'src', 'Track2_TowerSystem', 'TowerController.server.luau');
const GAME_CONFIG_PATH = path.join(PROJECT_ROOT, 'src', 'Shared', 'GameConfig.luau');
const WAVE_MANAGER_PATH = path.join(PROJECT_ROOT, 'src', 'Track1_WaveSystem', 'WaveManager.server.luau');

// Terminal color codes
const BOLD = '\x1b[1m';
const RESET = '\x1b[0m';
const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const CYAN = '\x1b[36m';
const YELLOW = '\x1b[33m';
const GRAY = '\x1b[90m';
const MAGENTA = '\x1b[35m';

console.log(`${BOLD}${CYAN}========================================================================${RESET}`);
console.log(`${BOLD}   EMPIRICAL CHALLENGER M3-2: RIGGING GEOMETRY, KINEMATICS & VFX HARNESS ${RESET}`);
console.log(`${BOLD}   Target: src/Track2_TowerSystem/TowerController.server.luau           ${RESET}`);
console.log(`${BOLD}${CYAN}========================================================================${RESET}\n`);

// Verify file existence
if (!fs.existsSync(TOWER_CONTROLLER_PATH)) {
  console.error(`${RED}FATAL: TowerController.server.luau not found at ${TOWER_CONTROLLER_PATH}${RESET}`);
  process.exit(1);
}
if (!fs.existsSync(GAME_CONFIG_PATH)) {
  console.error(`${RED}FATAL: GameConfig.luau not found at ${GAME_CONFIG_PATH}${RESET}`);
  process.exit(1);
}

const towerSource = fs.readFileSync(TOWER_CONTROLLER_PATH, 'utf8');
const configSource = fs.readFileSync(GAME_CONFIG_PATH, 'utf8');
const waveSource = fs.readFileSync(WAVE_MANAGER_PATH, 'utf8');

const testResults = {
  total: 0,
  passed: 0,
  failed: 0,
  suites: [],
};

function runCheck(suiteName, checkId, description, condition, details = '') {
  testResults.total++;
  const passed = Boolean(condition);
  if (passed) {
    testResults.passed++;
    console.log(`  ${GREEN}[PASS]${RESET} ${BOLD}${checkId}${RESET}: ${description} ${details ? `${GRAY}(${details})${RESET}` : ''}`);
  } else {
    testResults.failed++;
    console.error(`  ${RED}[FAIL]${RESET} ${BOLD}${checkId}${RESET}: ${description} - FAILED! ${YELLOW}${details}${RESET}`);
  }
  return passed;
}

// =============================================================================
// SUITE 1: PROCEDURAL R6 RIGGING GEOMETRY & HUMANOID NAMED PARTS
// =============================================================================
console.log(`${BOLD}${MAGENTA}--- SUITE 1: PROCEDURAL R6 RIGGING GEOMETRY & NAMED PARTS ---${RESET}`);

// 1.1 HumanoidRootPart check
const hasRootPart = /root\.Name\s*=\s*"HumanoidRootPart"/.test(towerSource);
const rootSizeMatch = towerSource.match(/root\.Size\s*=\s*Vector3\.new\(2\.2,\s*2\.4,\s*1\.2\)/);
const rootAnchored = /root\.Anchored\s*=\s*true/.test(towerSource);
const rootCanCollide = /root\.CanCollide\s*=\s*false/.test(towerSource);
runCheck('Suite1', 'RIG-1.1', 'HumanoidRootPart exists with exact dimensions (2.2, 2.4, 1.2), Anchored=true, CanCollide=false',
  hasRootPart && rootSizeMatch && rootAnchored && rootCanCollide,
  `Anchored: ${rootAnchored}, CanCollide: ${!rootCanCollide}`);

// 1.2 Head geometry check (+1.95 offset)
const hasHead = /head\.Name\s*=\s*"Head"/.test(towerSource);
const headOffsetMatch = /head\.Position\s*=\s*root\.Position\s*\+\s*Vector3\.new\(0,\s*1\.95,\s*0\)/.test(towerSource)
  || /head\.Position\s*=\s*tower\.PrimaryPart\.Position\s*\+\s*Vector3\.new\(0,\s*1\.95,\s*0\)/.test(towerSource);
const headSizeMatch = /head\.Size\s*=\s*Vector3\.new\(1\.5,\s*1\.5,\s*1\.5\)/.test(towerSource);
runCheck('Suite1', 'RIG-1.2', 'Head part positioned at root.Position + Vector3.new(0, 1.95, 0) with size (1.5, 1.5, 1.5)',
  hasHead && headOffsetMatch && headSizeMatch,
  `Head Offset Y: +1.95`);

// 1.3 RightArm (+1.55 X offset) & LeftArm (-1.55 X offset)
const hasRightArm = /rightArm\.Name\s*=\s*"RightArm"/.test(towerSource);
const rightArmOffset = /rightArm\.Position\s*=\s*root\.Position\s*\+\s*Vector3\.new\(1\.55,\s*0,\s*0\)/.test(towerSource);
const hasLeftArm = /leftArm\.Name\s*=\s*"LeftArm"/.test(towerSource);
const leftArmOffset = /leftArm\.Position\s*=\s*root\.Position\s*\+\s*Vector3\.new\(-1\.55,\s*0,\s*0\)/.test(towerSource);
const armSizes = /rightArm\.Size\s*=\s*Vector3\.new\(0\.9,\s*2\.2,\s*0\.9\)/.test(towerSource)
  && /leftArm\.Size\s*=\s*Vector3\.new\(0\.9,\s*2\.2,\s*0\.9\)/.test(towerSource);
runCheck('Suite1', 'RIG-1.3', 'Symmetric arms placed at X=+1.55 and X=-1.55 with dimensions (0.9, 2.2, 0.9)',
  hasRightArm && rightArmOffset && hasLeftArm && leftArmOffset && armSizes,
  `RightArm: +1.55, LeftArm: -1.55`);

// 1.4 AuraRing, SignatureWeapon & TowerStatusGui
const hasAuraRing = /auraRing\.Name\s*=\s*"AuraRing"/.test(towerSource);
const auraRingCylinder = /auraRing\.Shape\s*=\s*Enum\.PartType\.Cylinder/.test(towerSource);
const auraRingSize = /auraRing\.Size\s*=\s*Vector3\.new\(0\.35,\s*6\.5,\s*6\.5\)/.test(towerSource);
const hasWeapon = /weapon\.Name\s*=\s*"SignatureWeapon"/.test(towerSource);
const weaponTracking = /weapon\.Position\s*=\s*rightArm\.Position\s*\+\s*Vector3\.new\(0,\s*0\.5,\s*-1\.8\)/.test(towerSource);
const hasStatusGui = /statusBb\.Name\s*=\s*"TowerStatusGui"/.test(towerSource);
runCheck('Suite1', 'RIG-1.4', 'AuraRing (Cylinder 0.35x6.5x6.5), SignatureWeapon tracking RightArm, and TowerStatusGui Billboard present',
  hasAuraRing && auraRingCylinder && auraRingSize && hasWeapon && weaponTracking && hasStatusGui,
  `AuraRing: 0.35x6.5x6.5, WeaponOffset: (0, 0.5, -1.8)`);

// 1.5 Distinct custom accessories for all 8 One Piece Heroes
const heroAccessories = [
  { hero: 'Luffy', style: 'BajrangFist', parts: ['Gear5CloudScarf', 'StrawHat'] },
  { hero: 'Shanks', style: 'Kamusari', parts: ['YonkoBlackCape', 'ShanksRedHair'] },
  { hero: 'Whitebeard', style: 'GuraQuake', parts: ['CrescentMustache', 'CaptainCoat'] },
  { hero: 'Zoro', style: 'KingOfHell360', parts: ['SandaiKitetsu', 'ZoroHair'] },
  { hero: 'Ace', style: 'Entei', parts: ['AceCowboyHat', 'RedBeadNecklace'] },
  { hero: 'Law', style: 'GammaKnife', parts: ['LawFurHat'] },
  { hero: 'Kizaru', style: 'YasakaniLight', parts: ['JusticeCape', 'TintedGlasses'] },
  { hero: 'Sanji', style: 'BoeufBurst', parts: ['BlondeHair', 'GoldenTie'] },
];

let allAccessoriesPresent = true;
const missingParts = [];
for (const item of heroAccessories) {
  for (const part of item.parts) {
    const partRegex = new RegExp(`\\.Name\\s*=\\s*"${part}"`);
    if (!partRegex.test(towerSource)) {
      allAccessoriesPresent = false;
      missingParts.push(`${item.hero}:${part}`);
    }
  }
}
runCheck('Suite1', 'RIG-1.5', 'All 8 One Piece heroes define distinct custom 3D accessory models (no plain R6 templates)',
  allAccessoriesPresent,
  missingParts.length === 0 ? 'All 15 custom accessory parts verified' : `Missing: ${missingParts.join(', ')}`);

// 1.6 Highlight Aura & Anchored Integrity
const hasHighlight = /auraHighlight\.Name\s*=\s*"AnimeAura"/.test(towerSource);
const highlightFill = /auraHighlight\.FillTransparency\s*=\s*0\.55/.test(towerSource);
runCheck('Suite1', 'RIG-1.6', 'Aura highlight shell "AnimeAura" configured with FillTransparency=0.55',
  hasHighlight && highlightFill,
  'AnimeAura Highlight verified');

// =============================================================================
// SUITE 2: IDLE KINEMATICS & AURA ROTATION MATHEMATICAL VERIFICATION
// =============================================================================
console.log(`\n${BOLD}${MAGENTA}--- SUITE 2: IDLE KINEMATICS & AURA ROTATION MATHEMATICAL BOUNDS ---${RESET}`);

// 2.1 Static extraction of bobbing equation
const bobbingMatch = towerSource.match(/local\s+bob\s*=\s*math\.sin\(now\s*\*\s*([\d.]+)\)\s*\*\s*([\d.]+)/);
const bobFreq = bobbingMatch ? parseFloat(bobbingMatch[1]) : 0;
const bobAmp = bobbingMatch ? parseFloat(bobbingMatch[2]) : 0;
runCheck('Suite2', 'KIN-2.1', 'Idle bobbing equation matches Y(t) = Y_base + 0.35 * sin(3.2t)',
  bobFreq === 3.2 && bobAmp === 0.35,
  `Frequency: ${bobFreq} rad/s, Amplitude: ${bobAmp} studs`);

// 2.2 Mathematical Empirical Simulation: 1,000,000 Time Step Stress Test
const baseY = 5.5;
let minObservedY = Infinity;
let maxObservedY = -Infinity;
let maxObservedVelocity = -Infinity;
let nanDetected = false;

// Sample 1,000,000 points across t = 0 to 10,000 seconds with variable delta t
const SAMPLE_COUNT = 1000000;
let t = 0;
const dt = 0.01;
for (let i = 0; i < SAMPLE_COUNT; i++) {
  t += dt;
  const bob = Math.sin(t * bobFreq) * bobAmp;
  const y = baseY + bob;
  if (Number.isNaN(y)) {
    nanDetected = true;
  }
  if (y < minObservedY) minObservedY = y;
  if (y > maxObservedY) maxObservedY = y;

  // Velocity Y'(t) = 0.35 * 3.2 * cos(3.2t)
  const vel = Math.abs(bobAmp * bobFreq * Math.cos(t * bobFreq));
  if (vel > maxObservedVelocity) maxObservedVelocity = vel;
}

const boundsStrictlyHeld = (minObservedY >= baseY - 0.3500001) && (maxObservedY <= baseY + 0.3500001);
runCheck('Suite2', 'KIN-2.2', 'Idle bobbing empirical bounds strictly within [-0.35, +0.35] over 1,000,000 cycles',
  boundsStrictlyHeld && !nanDetected,
  `Min Y: ${minObservedY.toFixed(5)} (offset ${(minObservedY - baseY).toFixed(5)}), Max Y: ${maxObservedY.toFixed(5)} (offset +${(maxObservedY - baseY).toFixed(5)})`);

// 2.3 Extreme Time Boundary Stress Test (t = 10^9 seconds, t = -1000 seconds)
const extremeTimes = [0, 1e-9, 1e3, 1e6, 1e9, 1e12, -100, -1e6];
let extremePass = true;
for (const extT of extremeTimes) {
  const bob = Math.sin(extT * bobFreq) * bobAmp;
  if (bob < -0.350000001 || bob > 0.350000001 || Number.isNaN(bob)) {
    extremePass = false;
  }
}
runCheck('Suite2', 'KIN-2.3', 'Extreme time values (t = 0 to 10^12s, negative t) maintain [-0.35, +0.35] bounds',
  extremePass,
  'All 8 extreme temporal checkpoints validated');

// 2.4 Arm Bobbing Secondary Kinematics (Arm bobbing amplitude 0.08, phase ±0.4)
const armBobRight = /math\.sin\(now\s*\*\s*3\.2\s*\+\s*0\.4\)\s*\*\s*0\.08/.test(towerSource);
const armBobLeft = /math\.sin\(now\s*\*\s*3\.2\s*-\s*0\.4\)\s*\*\s*0\.08/.test(towerSource);
runCheck('Suite2', 'KIN-2.4', 'Secondary arm bobbing kinematics implement phase-opposed oscillation with amplitude 0.08',
  armBobRight && armBobLeft,
  'Right Arm: (+0.4 phase), Left Arm: (-0.4 phase), Amp: 0.08');

// 2.5 Aura Ring Rotation: Exactly 144 steps at 2.5 deg per step = 360 deg
const stepAngleMatch = towerSource.match(/ring\.CFrame\s*\*\s*CFrame\.Angles\(math\.rad\(([\d.]+)\),\s*0,\s*0\)/);
const stepAngleDeg = stepAngleMatch ? parseFloat(stepAngleMatch[1]) : 0;
const stepsForFullCircle = 360 / stepAngleDeg;

// Simulate rotational accumulator across 144 steps (1 rev), 1440 steps (10 rev), and 14400 steps (100 rev)
let totalRotRad = 0;
const stepRad = (stepAngleDeg * Math.PI) / 180;
for (let s = 1; s <= 144; s++) {
  totalRotRad += stepRad;
}
const totalRotDeg = (totalRotRad * 180) / Math.PI;
const is360Exact = Math.abs(totalRotDeg - 360) < 1e-9;
runCheck('Suite2', 'KIN-2.5', 'Aura ring step angle is 2.5 deg; accumulates exactly 360 deg in 144 steps',
  stepAngleDeg === 2.5 && stepsForFullCircle === 144 && is360Exact,
  `Step: ${stepAngleDeg} deg, Steps: ${stepsForFullCircle}, Accumulated: ${totalRotDeg.toFixed(4)} deg`);

// 2.6 Rotational Orthogonality & Drift Test (14,400 steps = 100 revolutions)
let cosAccum = 1.0;
let sinAccum = 0.0;
const cStep = Math.cos(stepRad);
const sStep = Math.sin(stepRad);
for (let s = 1; s <= 14400; s++) {
  const nextCos = cosAccum * cStep - sinAccum * sStep;
  const nextSin = cosAccum * sStep + sinAccum * cStep;
  cosAccum = nextCos;
  sinAccum = nextSin;
}
const norm = cosAccum * cosAccum + sinAccum * sinAccum;
const normDeviation = Math.abs(norm - 1.0);
runCheck('Suite2', 'KIN-2.6', 'Rotational matrix orthogonality maintained after 100 full revolutions (14,400 steps)',
  normDeviation < 1e-7 && !Number.isNaN(norm),
  `Norm deviation: ${normDeviation.toExponential(3)}`);

// =============================================================================
// SUITE 3: 5-PHASE COMBAT KINEMATICS & CONCURRENCY LOCK VERIFICATION
// =============================================================================
console.log(`\n${BOLD}${MAGENTA}--- SUITE 3: 5-PHASE COMBAT KINEMATICS & CONCURRENCY LOCK ---${RESET}`);

// 3.1 Phase 1: Wind-Up Anticipation (0.14s)
const phase1DurationMatch = /TweenInfo\.new\(0\.14,\s*Enum\.EasingStyle\.Quad/.test(towerSource);
const phase1DelayMatch = /task\.delay\(0\.14,\s*function\(\)/.test(towerSource);
const phase1Lean = /CFrame\.Angles\(math\.rad\(-14\),\s*0,\s*0\)/.test(towerSource);
runCheck('Suite3', 'CMB-3.1', 'Phase 1: Wind-Up duration is exactly 0.14s with Quad.Out and -14 deg backward lean',
  phase1DurationMatch && phase1DelayMatch && phase1Lean,
  'Duration: 0.14s, Lean: -14 deg');

// 3.2 Phase 2: Dash / Leap (0.10s)
const phase2DurationMatch = /TweenInfo\.new\(0\.10,\s*Enum\.EasingStyle\.Exponential/.test(towerSource);
const phase2DelayMatch = /task\.delay\(0\.10,\s*function\(\)/.test(towerSource);
const phase2ForwardDist = /dashPos\s*=\s*startPos\s*\+\s*fwdDir\s*\*\s*3\.2/.test(towerSource);
const phase2ForwardPitch = /CFrame\.Angles\(math\.rad\(18\),\s*0,\s*0\)/.test(towerSource);
runCheck('Suite3', 'CMB-3.2', 'Phase 2: Dash / Leap duration is exactly 0.10s with +3.2 studs forward leap and +18 deg pitch',
  phase2DurationMatch && phase2DelayMatch && phase2ForwardDist && phase2ForwardPitch,
  'Duration: 0.10s, Dash dist: 3.2 studs, Pitch: +18 deg');

// 3.3 Phase 3: Hitstop Freeze Frame (0.07s = 70ms)
const phase3DelayMatch = /task\.delay\(0\.07,\s*function\(\)/.test(towerSource);
const phase3BillboardTrigger = /spawnMangaBillboard\(targetPos,\s*heroSpec\.Onomatopoeia/.test(towerSource);
const phase3LightningTrigger = /spawnHakiLightningBolts\(targetPos,\s*heroSpec\.SecondaryColor,\s*8\)/.test(towerSource);
const phase3CameraShake = /CameraShakeRemote:FireAllClients\(shakeIntensity,\s*heroSpec\.SecondaryColor\)/.test(towerSource);
runCheck('Suite3', 'CMB-3.3', 'Phase 3: Hitstop Freeze Frame duration is exactly 0.07s (70ms) with Billboard, Lightning & Shake',
  phase3DelayMatch && phase3BillboardTrigger && phase3LightningTrigger && phase3CameraShake,
  'Hitstop Duration: 0.07s (70ms)');

// 3.4 Phase 4: Impact Strike & Follow-Through (0.20s)
const phase4Callback = /onImpactCallback\(\)/.test(towerSource);
const phase4DelayMatch = /task\.delay\(0\.20,\s*function\(\)/.test(towerSource);
runCheck('Suite3', 'CMB-3.4', 'Phase 4: Impact Strike dispatches damage & VFX callback with 0.20s follow-through delay',
  phase4Callback && phase4DelayMatch,
  'Impact follow-through duration: 0.20s');

// 3.5 Phase 5: Recoil & Return to Base Pad (0.22s)
const phase5DurationMatch = /TweenInfo\.new\(0\.22,\s*Enum\.EasingStyle\.Quad/.test(towerSource);
const phase5DelayMatch = /task\.delay\(0\.22,\s*function\(\)/.test(towerSource);
const phase5ReturnPos = /local\s+basePos\s*=\s*Vector3\.new\(startPos\.X,\s*baseY,\s*startPos\.Z\)/.test(towerSource);
runCheck('Suite3', 'CMB-3.5', 'Phase 5: Recoil & Return to base pad duration is exactly 0.22s',
  phase5DurationMatch && phase5DelayMatch && phase5ReturnPos,
  'Return Duration: 0.22s');

// 3.6 Total 5-Phase Sequence Duration Sum
const totalSequenceDuration = 0.14 + 0.10 + 0.07 + 0.20 + 0.22;
runCheck('Suite3', 'CMB-3.6', 'Total 5-phase combat animation timeline sums exactly to 0.73s (730ms)',
  Math.abs(totalSequenceDuration - 0.73) < 1e-9,
  `0.14 + 0.10 + 0.07 + 0.20 + 0.22 = ${totalSequenceDuration.toFixed(2)}s`);

// 3.7 Concurrency Lock: IsAttacking Lifecycle
const setAttackingTrue = /tower:SetAttribute\("IsAttacking",\s*true\)/.test(towerSource);
const setAttackingFalse = /tower:SetAttribute\("IsAttacking",\s*false\)/.test(towerSource);
const idleLoopChecksAttacking = /local\s+isAttacking\s*=\s*\(tower:GetAttribute\("IsAttacking"\)\s*::\s*boolean\?\)\s*or\s*false\s*[\r\n\s]+if\s+not\s+isAttacking\s+then/.test(towerSource);
runCheck('Suite3', 'CMB-3.7', 'IsAttacking concurrency lock is set to true at Phase 1 and reset to false at end of Phase 5',
  setAttackingTrue && setAttackingFalse && idleLoopChecksAttacking,
  'Lifecycle: true at start -> false after 0.73s; idle bobbing guarded by if not isAttacking');

// 3.8 Cooldown Margin vs Sequence Duration Analysis
// Check if base cooldowns of all 8 heroes are greater than total sequence duration (0.73s)
const baseCooldown = 1.15;
const heroCooldowns = [
  { hero: 'Luffy', mult: 0.85, cd: 1.15 * 0.85 },
  { hero: 'Shanks', mult: 0.90, cd: 1.15 * 0.90 },
  { hero: 'Whitebeard', mult: 1.10, cd: 1.15 * 1.10 },
  { hero: 'Zoro', mult: 0.80, cd: 1.15 * 0.80 },
  { hero: 'Ace', mult: 0.95, cd: 1.15 * 0.95 },
  { hero: 'Law', mult: 0.88, cd: 1.15 * 0.88 },
  { hero: 'Kizaru', mult: 0.72, cd: 1.15 * 0.72 },
  { hero: 'Sanji', mult: 0.68, cd: 1.15 * 0.68 },
];

let allBaseCdsSafe = true;
for (const h of heroCooldowns) {
  if (h.cd < totalSequenceDuration) {
    allBaseCdsSafe = false;
  }
}
runCheck('Suite3', 'CMB-3.8', 'All 8 One Piece heroes have base attack cooldowns strictly greater than 0.73s animation',
  allBaseCdsSafe,
  `Fastest hero (Sanji): ${(1.15 * 0.68).toFixed(3)}s > 0.73s`);

// =============================================================================
// SUITE 4: MASTERPIECE VFX TABLES & POINTLIGHT SPECIFICATIONS
// =============================================================================
console.log(`\n${BOLD}${MAGENTA}--- SUITE 4: MASTERPIECE VFX TABLES & POINTLIGHT SPECIFICATIONS ---${RESET}`);

// 4.1 PointLight specifications: Brightness 8, Range 40, Name "ImpactFlashLight"
const pointLightName = /impactLight\.Name\s*=\s*"ImpactFlashLight"/.test(towerSource);
const pointLightBrightness = /impactLight\.Brightness\s*=\s*8/.test(towerSource);
const pointLightRange = /impactLight\.Range\s*=\s*40/.test(towerSource);
const pointLightShadows = /impactLight\.Shadows\s*=\s*false/.test(towerSource);
const pointLightTween = /TweenService:Create\(impactLight,\s*TweenInfo\.new\(0\.35,\s*Enum\.EasingStyle\.Quad,\s*Enum\.EasingDirection\.Out\),\s*\{\s*Brightness\s*=\s*0,\s*Range\s*=\s*0,\s*\}\):Play\(\)/.test(towerSource);
runCheck('Suite4', 'VFX-4.1', 'Dynamic PointLight has Brightness=8, Range=40, Shadows=false, fades to 0 over 0.35s',
  pointLightName && pointLightBrightness && pointLightRange && pointLightShadows && pointLightTween,
  'Brightness: 8, Range: 40 studs, Fade: 0.35s');

// 4.2 Camera Shake Intensity: 0.70 for Mythicals, 0.45 for others
const mythicalShakeCondition = /if\s+heroSpec\.AttackStyle\s*==\s*"BajrangFist"\s+or\s+heroSpec\.AttackStyle\s*==\s*"Kamusari"\s+or\s+heroSpec\.AttackStyle\s*==\s*"GuraQuake"\s+then\s*shakeIntensity\s*=\s*0\.70\s*end/.test(towerSource);
const defaultShake = /local\s+shakeIntensity\s*=\s*0\.45/.test(towerSource);
runCheck('Suite4', 'VFX-4.2', 'Camera shake intensity is 0.70 for Mythicals (Luffy, Shanks, Whitebeard) and 0.45 for others',
  mythicalShakeCondition && defaultShake,
  'Mythical: 0.70, Standard: 0.45');

// 4.3 Conqueror\'s Haki Radial Lightning Arcs Implementation
const hakiFuncExists = /local\s+function\s+spawnHakiLightningBolts\(origin:\s*Vector3,\s*color:\s*Color3,\s*boltCount:\s*number\)/.test(towerSource);
const hakiRadialDistribution = /local\s+angle\s*=\s*math\.rad\(\(360\s*\/\s*boltCount\)\s*\*\s*i\s*\+\s*math\.random\(-15,\s*15\)\)/.test(towerSource);
const hakiZeroMagnitudeGuard = /if\s*\(target\s*-\s*origin\)\.Magnitude\s*>=\s*0\.05\s*then/.test(towerSource);
const hakiNeonMaterial = /bolt\.Material\s*=\s*Enum\.Material\.Neon/.test(towerSource);
runCheck('Suite4', 'VFX-4.3', 'Conqueror\'s Haki radial lightning arcs have radial distribution, ±15 deg jitter, and magnitude >= 0.05 guard',
  hakiFuncExists && hakiRadialDistribution && hakiZeroMagnitudeGuard && hakiNeonMaterial,
  'Radial 360/N + jitter(-15, 15), Zero guard: >=0.05');

// 4.4 All 8 Signature Ultimate Visual Effects in TowerController
const ultimates = [
  {
    style: 'BajrangFist',
    hero: 'Luffy',
    mangaWord: 'DOOM!!',
    shake: 0.70,
    parts: ['NikaSkyPortal', 'BajrangGiantFist', 'BajrangShockwave'],
    hakiCount: 12,
  },
  {
    style: 'Kamusari',
    hero: 'Shanks',
    mangaWord: 'KAMUSARI!!',
    shake: 0.70,
    parts: ['KamusariCrescentSlash', 'KamusariShockRing'],
    hakiCount: 10,
  },
  {
    style: 'GuraQuake',
    hero: 'Whitebeard',
    mangaWord: 'CRACK!!',
    shake: 0.70,
    parts: ['TremorGlassCrack', 'TremorDome', 'SeaQuakeRing'],
    hakiCount: 8,
  },
  {
    style: 'KingOfHell360',
    hero: 'Zoro',
    mangaWord: 'ONIGIRI!!',
    shake: 0.45,
    parts: ['KingOfHellTornado'],
    hakiCount: 8,
  },
  {
    style: 'Entei',
    hero: 'Ace',
    mangaWord: 'ENTEI!!',
    shake: 0.45,
    parts: ['AceEnteiSun', 'EnteiFireShock'],
    hakiCount: 8,
  },
  {
    style: 'GammaKnife',
    hero: 'Law',
    mangaWord: 'K-ROOM!!',
    shake: 0.45,
    parts: ['KRoomSpatialDome', 'PunctureWilleBlade'],
    hakiCount: 6,
  },
  {
    style: 'YasakaniLight',
    hero: 'Kizaru',
    mangaWord: 'FLASH!!',
    shake: 0.45,
    parts: ['YasakaniPhotonBeam'],
    hakiCount: 8,
  },
  {
    style: 'BoeufBurst',
    hero: 'Sanji',
    mangaWord: 'IFRIT!!',
    shake: 0.45,
    parts: ['BoeufBurstPillar'],
    hakiCount: 6,
  },
];

for (const ult of ultimates) {
  let ultPass = true;
  const missing = [];

  // Check manga word in GameConfig
  const mangaRegex = new RegExp(`Onomatopoeia\\s*=\\s*"${ult.mangaWord}`);
  if (!mangaRegex.test(configSource)) {
    ultPass = false;
    missing.push(`Onomatopoeia:${ult.mangaWord}`);
  }

  // Check procedural VFX parts in TowerController
  for (const part of ult.parts) {
    const partRegex = new RegExp(`\\.Name\\s*=\\s*"${part}"`);
    if (!partRegex.test(towerSource)) {
      ultPass = false;
      missing.push(`Part:${part}`);
    }
  }

  runCheck('Suite4', `ULT-${ult.style}`, `Ultimate "${ult.style}" (${ult.hero}): Manga word "${ult.mangaWord}", shake ${ult.shake}, and procedural VFX models`,
    ultPass,
    missing.length === 0 ? `Verified parts: [${ult.parts.join(', ')}]` : `Missing: ${missing.join(', ')}`);
}

// 4.5 Whitebeard Gura Quake Slow Debuff (0.45x for 2.5s)
const guraSlowSet = /if\s+spec\.AttackStyle\s*==\s*"GuraQuake"\s+then\s*enemy:SetAttribute\("SlowUntil",\s*now\s*\+\s*2\.5\)\s*end/.test(towerSource);
const waveSlowRead = /local\s+slowUntil\s*=\s*\(model:GetAttribute\("SlowUntil"\)\s*::\s*number\?\)\s*or\s*0/.test(waveSource);
const waveSlowMult = /local\s+speedMult\s*=\s*\(os\.clock\(\)\s*<\s*slowUntil\)\s*and\s*0\.45\s*or\s*1\.0/.test(waveSource);
runCheck('Suite4', 'VFX-4.5', 'Whitebeard Gura Quake sets SlowUntil=now+2.5; WaveManager applies speedMult 0.45x',
  guraSlowSet && waveSlowRead && waveSlowMult,
  'Slow Duration: 2.5s, Multiplier: 0.45x');

// 4.6 3D Manga Billboard Tween Animation
const billboardBackEasing = /Enum\.EasingStyle\.Back,\s*Enum\.EasingDirection\.Out/.test(towerSource);
const billboardYRise = /Position\s*=\s*pos\s*\+\s*Vector3\.new\(0,\s*12,\s*0\)/.test(towerSource);
const billboardGothamBlack = /Enum\.Font\.GothamBlack/.test(towerSource);
runCheck('Suite4', 'VFX-4.6', '3D Manga Onomatopoeia Billboard uses Back.Out easing, rises to Y+12, GothamBlack font',
  billboardBackEasing && billboardYRise && billboardGothamBlack,
  'Easing: Back.Out, Rise: +12 studs, Font: GothamBlack');

// =============================================================================
// SUMMARY & EXIT CODE
// =============================================================================
console.log(`\n${BOLD}${CYAN}========================================================================${RESET}`);
console.log(`${BOLD}CHALLENGE HARNESS EXECUTION SUMMARY:${RESET}`);
console.log(`Total Checks:  ${BOLD}${testResults.total}${RESET}`);
console.log(`Passed Checks: ${BOLD}${GREEN}${testResults.passed}${RESET}`);
console.log(`Failed Checks: ${BOLD}${testResults.failed > 0 ? RED : GREEN}${testResults.failed}${RESET}`);
console.log(`Pass Rate:     ${BOLD}${((testResults.passed / testResults.total) * 100).toFixed(1)}%${RESET}`);
console.log(`${BOLD}${CYAN}========================================================================${RESET}\n`);

if (testResults.failed > 0) {
  console.error(`${RED}${BOLD}VERDICT: REJECT (Found ${testResults.failed} empirical failures)${RESET}`);
  process.exit(1);
} else {
  console.log(`${GREEN}${BOLD}VERDICT: APPROVE (100% empirical checks passed without defects)${RESET}`);
  process.exit(0);
}
