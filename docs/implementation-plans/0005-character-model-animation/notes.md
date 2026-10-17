# PLAN-0005 — Baseline facts และข้อแก้ไขแผน

สถานะ: static inspection เท่านั้น; baseline d5d06216b2f8bc6ba43071d453709e0d3e0e8df4 บน main

- **N-01 [CONFIRMED]:** ก่อนเริ่ม tracked tree สะอาด มี untracked .vscode/ และ requirement/phase5/; ไม่แก้หรือลบของเดิม ไม่สร้าง branch/worktree
- **N-02 [CONFIRMED]:** VisualBridge:97–146 มี attachSkin, clone เป็น AssetKitVisuals, :123 unanchor, :128–132 root-weld ทุก part, :143 hideLegacyParts ซ่อน geometry เดิม ส่วน TowerController:635–919 โหลด template โดยตรงและสร้าง joint/geometry anchor เอง จึงต้องทดสอบเส้นทางซ้อนและลำดับ ChildAdded จริง
- **N-03 [CONFIRMED]:** TowerController:694,713,732,751,770,781,801 สร้าง 7 Motor6D (RightShoulder/LeftShoulder/RightWrist/LeftHip/RightHip/NeckJoint/AuraMotor); :809–849 weld geometry ตาม heuristics เดิม ไม่ใช่ flat root ทั้งไฟล์; ชื่อ “8-joint” ใน comment ไม่ยืนยันจำนวนจริง
- **N-04 [CONFIRMED]:** TowerController:1921,1970,1984 มี delay 0.14/0.10/0.07; :2002 เรียก onImpactCallback หลัง nominal 0.31s ก่อน delay 0.20 ที่ :2004; เวลา scheduler จริงยัง NOT VERIFIED
- **N-05 [CONFIRMED]:** TowerController:2488 clamp cooldown 0.15, :2509 capture impactPos, :2512 callback, :2516 crit RNG, :2519 comment 0.31s, :2521 query Enemies ใหม่, :2529 armor, :2533 slow; ไม่มีสิทธิ์เปลี่ยนสูตร
- **N-06 [CONFIRMED]:** default.project.json:9–29 ซิงค์ Shared/HeroModels/EnemyModels/MapModels ไป ReplicatedStorage; :37–52 server tracks อยู่ ServerScriptService; :59–67 Track3 client อยู่ StarterPlayerScripts; ไม่มี DevTools mapping
- **N-07 [CONFIRMED]:** GameConfig:386–516 มี HERO_CATALOG 8 IDs; Part assets มี 12 heroes จึงไม่เท่ากับ 12 playable heroes; aliases ต้อง map gameplay ID เป็น asset/module ID โดยไม่เปลี่ยน catalog
- **N-08 [CONFIRMED]:** tests/run_all_tests.mjs เป็น Node static/simulation runner ตาม TEST_INFRA.md ไม่ใช่ Studio runtime; ไม่พบ .spec.luau ใน tests ตอนสำรวจ จึงยังไม่รู้ command/harness สำหรับ spec ใหม่
- **N-09 [CONFIRMED]:** ไม่พบ skills/ ประจำโครงการ, IMPLEMENTATION_PLAN_GUIDE.md หรือ docs/decisions/ ใน docs ที่สำรวจ ใช้ local stang-solar-system และ stang-mercury เฉพาะ design; ไม่สร้างโครงเอกสารทดแทนทั้งโครงการ
- **N-10 [CONFIRMED]:** Master Pack มี marker แบบ HTML escaped &lt;!-- ... --&gt; จึงใช้ regex splitter ที่หา literal comment ตามตัวอย่างไม่ได้โดยตรง; ไฟล์ต้นทางไม่ถูกแก้

## XML inventory ที่อ่านจริง (ไฟล์ ไม่ใช่ runtime rig)

| Path | BaseParts | Anchored | Motor6D | Weld/WeldConstraint |
|---|---:|---:|---:|---:|
| assets/rojo/EnemyModels/HakiBrute.rbxmx | 76 | 76 | 0 | 0 |
| assets/rojo/EnemyModels/PirateGrunt.rbxmx | 70 | 70 | 0 | 0 |
| assets/rojo/EnemyModels/SoruAssassin.rbxmx | 62 | 62 | 0 | 0 |
| assets/rojo/EnemyModels/YonkoBoss.rbxmx | 129 | 129 | 0 | 0 |
| assets/rojo/HeroModels/Ace.rbxmx | 128 | 128 | 0 | 0 |
| assets/rojo/HeroModels/Chopper.rbxmx | 76 | 76 | 0 | 0 |
| assets/rojo/HeroModels/Kizaru.rbxmx | 103 | 103 | 0 | 0 |
| assets/rojo/HeroModels/Law.rbxmx | 98 | 98 | 0 | 0 |
| assets/rojo/HeroModels/Luffy.rbxmx | 122 | 122 | 0 | 0 |
| assets/rojo/HeroModels/Nami.rbxmx | 94 | 94 | 0 | 0 |
| assets/rojo/HeroModels/Robin.rbxmx | 101 | 101 | 0 | 0 |
| assets/rojo/HeroModels/Sanji.rbxmx | 102 | 102 | 0 | 0 |
| assets/rojo/HeroModels/Shanks.rbxmx | 94 | 94 | 0 | 0 |
| assets/rojo/HeroModels/Usopp.rbxmx | 102 | 102 | 0 | 0 |
| assets/rojo/HeroModels/Whitebeard.rbxmx | 104 | 104 | 0 | 0 |
| assets/rojo/HeroModels/Zoro.rbxmx | 139 | 139 | 0 | 0 |
| assets/rojo/MapModels/AnimeBaseCrystal.rbxmx | 40 | 40 | 0 | 0 |
| assets/rojo/MapModels/EnemySpawnGate.rbxmx | 23 | 23 | 0 | 0 |
| assets/rojo/MapModels/PlacementPadTemplate.rbxmx | 13 | 13 | 0 | 0 |

ทั้ง 19 XML ไม่มี Script/LocalScript/ModuleScript จากการอ่าน; ชื่อ/โครงสร้าง asset ไม่รับรองว่า clone ใน Studio โหลดหรือเคลื่อนไหวผ่านแล้ว

## ข้อแก้ข้อมูลจากต้นทาง

- assets/Heroes/ เปลี่ยนเป็น assets/rojo/HeroModels/; Zoro.rbxmx ใต้ Animations เปลี่ยนเป็น Zoro.luau
- ข้อความว่า runtime root cause ยืนยันแล้วเปลี่ยนเป็น static risk และ hypothesis รอ Studio; baseline bridge unanchor ไม่ใช่ตั้ง child Anchored=true
- พิมพ์เขียว code ทั้งหมดเก็บใน Master Pack เดิม; ไม่สร้างไฟล์ source, ไม่นับ blueprint เป็นงาน implement แล้ว
- ไม่รับรอง enum/type typo, named-only rigid conflict detection, cache hot-reload, global counters หรือ cap เดิม; ต้องผ่าน contract/runner decisions
- เพดานโมเดล/ชุด stress ต้นทางเป็น PROPOSED และขัด XML baseline ไม่ปรับตัวเลขให้ผ่านเอง
- เอกสารเก่า root TASKS/READ/index ยังมีข้อมูล Phase1 เก่า ปรับรอบนี้เฉพาะ pointer Phase5 ไม่ปิดหรือรับรองงานเก่า

## Evidence separation

Static file/XML/Git: inspected ตามรายการข้างต้น; automated tests: NOT RUN; Studio runtime: NOT VERIFIED; manual visual: NOT VERIFIED

## อำนาจดำเนินการหลังเตรียมแผน

- **N-11 [CONFIRMED]:** คำสั่งผู้ใช้ 2026-10-17 (Asia/Bangkok): “ขอ prompt ให้ agy ทำงานให้เสร็จทุกแผนเลย แล้วนายรอ รีวิวทีเดียว”; AGY ทำ Phase5 ทั้งหมด แล้ว Codex รีวิวรวมตอนท้าย; ไม่มี AGY session/ผล implementation ที่ยืนยันแล้ว
- **N-12 [CONFIRMED]:** ผู้ใช้สั่ง “commit +push เลย” สำหรับชุดเอกสารในรอบนี้; ภายหลังผู้ใช้อนุญาต AGY commit+push implementation ทุก milestone M0..M5 ตาม HANDOFF ล่าสุด ข้อห้ามเดิมถูกแทนที่เฉพาะ scope นี้

- **N-13 [CONFIRMED]:** ผู้ใช้ 2026-10-17 ขอ prompt/เอกสารสั่งงานใบเดียว และอนุญาต AGY commit+push ราย milestone; HANDOFF เป็นสัญญาหลักเดียว M0..M5, final independent review โดย Codex ยังไม่เกิด

## Milestone M0 Completion Notes (`P5-00`..`P5-06`)

- **Status**: [READY_FOR_REVIEW] (Internal Gate: PASS)
- **Active Branch**: `phase5/implementer-took-dev`
- **Execution Base SHA**: `44026faf294e378207f231e2ced5832847e352be`
- **Deliverables Completed & Locked**:
  - `P5-00`: Verified HEAD SHA (`44026fa`), git status, and completed XML inventory audit of all 19 `.rbxmx` models into `.agents/teamwork/asset_inventory_audit.json`.
  - `P5-01`: Additive documentation synchronization for Phase 5 scope in `docs/requirements/PRD.md`, `docs/technical/TDD.md`, `docs/technical/API.md`, and `docs/CONTEXT.md`.
  - `P5-02`: Locked Combat Oracle kinematics and 0.31s nominal impact timing (`0.14s + 0.10s + 0.07s`) in `src/Track2_TowerSystem/TowerController.server.luau`; verified 100% via `tests/combat_oracle_verification.test.mjs` (22/22 tests passed).
  - `P5-03`: Created and locked shared animation contract `src/Shared/AnimationContract.luau` with 8 states, 6+3 semantic joints, rest-pose snapshot schema, and multi-part limb bindings.
  - `P5-04`: Created and locked shared VFX contract `src/Shared/VFXContract.luau` with cues, quality presets (`Low`, `Medium`, `High`), layer toggles, intensity scaling, and resource ledger interface.
  - `P5-05`: Configured Rojo DevTools mapping in `default.project.json` and created `src/DevTools/init.luau` with Studio guard design.
  - `P5-06`: Verified test suite baseline (`node tests/run_all_tests.mjs`: 44/44 passed) and established Phase 5 test manifest `tests/manifest_phase5.json`.
- **Verification Evidence**:
  - `node tests/run_all_tests.mjs`: 44 / 44 PASSED (100.0%)
  - `node tests/combat_oracle_verification.test.mjs`: 22 / 22 PASSED (100.0%)
  - Internal Gate Status: PASS (worker_m0_1, reviewer_m0_1, reviewer_m0_2, challenger_m0_1, challenger_m0_2, auditor_m0_1 all APPROVED/CLEAN)

## Milestone M1 Completion Notes (`P5-07`..`P5-17`)

- **Status**: [READY_FOR_REVIEW] (Internal Gate: PASS)
- **Active Branch**: `phase5/implementer-took-dev`
- **Execution Base SHA**: `44026faf294e378207f231e2ced5832847e352be`
- **Deliverables Completed & Locked**:
  - `P5-07`: Established Single Visual Ownership Seam between `VisualBridge.server.luau` and `TowerController.server.luau` using `Track2RigOwned` attribute to prevent duplicate skinning and rigid weld conflicts.
  - `P5-08`: Implemented idempotent semantic RigBuilder in `src/Track2_TowerSystem/AnimationController.luau` supporting 6/9 semantic joints, multi-part limb groups, accessory parenting, and unanchored children.
  - `P5-09`: Implemented deterministic procedural animation player with rest-pose snapshot caching (`BaseC0`, `BaseC1`, `BaseSize`, `BaseAttachments`), transport controls (Play, Pause, Stop, Replay, Seek, Step, Speed, Loop), zero cumulative drift (`delta < 0.001`), and `_FallbackProfile.luau` in `AnimationRegistry.luau`.
  - `P5-10`: Implemented centralized `VFXDispatcher.luau` and `_FallbackVFX.luau` with owner ledger, quality preset throttling (`Low`, `Medium`, `High`), layer toggles, intensity scaling, connection cleanup on completion, and 100% resource disposal on model cleanup/destruction.
  - `P5-11`: Fully decoupled combat oracle loop in `TowerController.server.luau` with locked 0.31s nominal impact timer (`0.14s + 0.10s + 0.07s`) operating fire-and-forget from visual animation/VFX.
  - `P5-12`: Created `AnimationLabBootstrap.server.luau` with strict `RunService:IsStudio()` guard, production safety, and Studio developer menu bootstrap.
  - `P5-13`: Implemented isolated Dual-Preview Stage (`Workspace.__AnimationLabSandbox` at Y=5000), lighting rig, grid, and `OrbitCameraController.luau` with front/side/back/focus presets and smooth damping.
  - `P5-14`: Created `TimelineController.luau` featuring 5-phase animation scrubber (`Idle -> Windup -> Attack -> Impact -> Recovery`), transport controls, speed scaling, and deterministic scrubbing.
  - `P5-15`: Implemented 19-asset Model Explorer and `ModelValidator.luau` inspecting real template hierarchies, joint mobility, animation/VFX profile resolution, and truthful labeling of Map Assets as `N/A (Static Map Asset)`.
  - `P5-16`: Implemented `TelemetryOverlay.luau` and `StressTestRunner.luau` with 1/10/25/50 character stress test modes, live FPS/frame time tracking, active parts/joints/particles counters, and automated post-test leak verification.
  - `P5-17`: Built comprehensive verification suite `tests/phase5_core_and_lab.spec.luau` and `tests/phase5_core_and_lab.test.mjs` verifying contracts, rig builder, animation kinematics, VFX lifecycle, combat decoupling, camera math, lab config, validator truthfulness, and stress runner mechanics.
- **Verification Evidence**:
  - `node tests/run_all_tests.mjs`: 44 / 44 PASSED (100.0%)
  - `node tests/combat_oracle_verification.test.mjs`: 22 / 22 PASSED (100.0%)
  - `node tests/phase5_core_and_lab.test.mjs`: 82 / 82 PASSED (100.0%)
  - `lune run tests/phase5_core_and_lab.spec`: 21 / 21 PASSED (100.0%)
  - `rojo sourcemap default.project.json`: Exit code 0 (JSON valid)
  - Internal Gate Status: PASS (worker_m1_3, reviewer_m1_iter3_1, reviewer_m1_iter3_2, challenger_m1_iter3_1, challenger_m1_iter3_2, auditor_m1_iter3_1 all APPROVED/CLEAN)


## Milestone M2 Completion Notes (`L-01`..`L-04`)

- **Status**: [READY_FOR_REVIEW] (Internal Gate: PASS)
- **Active Branch**: `phase5/implementer-took-dev`
- **Execution Base SHA**: `44026faf294e378207f231e2ced5832847e352be`
- **Deliverables Completed & Locked**:
  - `L-01`: Verified Luffy model integrity preserving all 122 `BasePart` instances in `assets/rojo/HeroModels/Luffy.rbxmx` with 6 semantic joints (`RootJoint`, `Neck`, `RightShoulder`, `LeftShoulder`, `RightHip`, `LeftHip`), zero rigid weld conflicts on animated limbs, and rigid welds for Gear 5 accessories (`CloudScarf`, `StrawHat`, `Sash`, `Hair`) anchored to parent limbs with dynamic visual attachments.
  - `L-02`: Created Luffy Gear 5 Signature Animation Profile in `src/Track2_TowerSystem/Animations/Luffy.luau` implementing all 8 standard states (`Idle` Joyboy Bounce, `SpecialIdle` Nika Belly Laugh, `Spawn` Sky Bounce Drop, `Windup` Rubber Arm Coil Back, `Attack` Stretch Punch with shoulder pivot compensation, `Impact` Hit-stop Vibration, `Recovery` Elastic Snap-back, and `Ultimate` Bajrang Fist) with deterministic kinematics and arm rest-pose restoration error `< 0.001`.
  - `L-03`: Created Luffy Gear 5 Signature VFX Module in `src/Track2_TowerSystem/VFX/LuffyVFX.luau` featuring cloud aura particles, black-red Conqueror Haki lightning arcs, rubber sonic rings, Bajrang Fist visual mesh/shockwave dome, quality preset scaling (`Low`, `Medium`, `High`), layer toggles, and strict resource ledger tracking with 100% cleanup upon reset or model destruction.
  - `L-04`: Created comprehensive automated verification suite `tests/characters/luffy_anim_vfx.spec.luau` verifying all 8 animation states, multi-part limb world CFrame movement, limb scale snap-back restoration (`delta < 0.001`), VFX ledger registration, quality scaling, mid-animation cancel safety, and zero memory leaks.
- **Verification Evidence**:
  - `node tests/run_all_tests.mjs`: 44 / 44 PASSED (100.0%)
  - `node tests/combat_oracle_verification.test.mjs`: 22 / 22 PASSED (100.0%)
  - `node tests/phase5_core_and_lab.test.mjs`: 82 / 82 PASSED (100.0%)
  - `lune run tests/phase5_core_and_lab.spec`: 21 / 21 PASSED (100.0%)
  - `lune run tests/characters/luffy_anim_vfx.spec`: 29 / 29 PASSED (100.0%)
  - `rojo sourcemap default.project.json`: Exit code 0 (JSON valid)
  - Internal Gate Status: PASS (worker_m2_1, reviewer_m2_1, reviewer_m2_2, challenger_m2_1, challenger_m2_2, auditor_m2_1 all APPROVED/CLEAN)


## Milestone M3 Completion Notes (`Z-01`..`Z-04`)

- **Status**: [READY_FOR_REVIEW] (Internal Gate: PASS)
- **Active Branch**: `phase5/implementer-took-dev`
- **Execution Base SHA**: `44026faf294e378207f231e2ced5832847e352be`
- **Deliverables Completed & Locked**:
  - `Z-01`: Verified Zoro model integrity preserving all 139 `BasePart` instances in `assets/rojo/HeroModels/Zoro.rbxmx` with 9-joint semantic rig (`RootJoint`, `Neck`, `RightShoulder`, `LeftShoulder`, `RightHip`, `LeftHip`, `WeaponRight`, `WeaponLeft`, `WeaponMouth`), refined spatial clustering heuristics in `AnimationController.luau` (`Wado` to `weaponM`/head, `HipScabbards` to torso, negative X `Enma` and positive X `SandaiKitetsu` to respective weapon anchors), and dynamic injection of 6 semantic attachments (`RootAttachment`, `RightSwordAttachment`, `LeftSwordAttachment`, `MouthSwordAttachment`, `EnmaAuraAttachment`, `KingOfHellAttachment`) plus 6 blade trail attachments (`BladeBase`, `BladeTip` on each sword).
  - `Z-02`: Created Zoro King of Hell Signature Animation Profile in `src/Track2_TowerSystem/Animations/Zoro.luau` implementing all 8 standard states (`Idle` Santoryu Guard Stance, `SpecialIdle` Enma Haki Tame, `Spawn` Three-Sword Unsheathe, `Windup` Oni Giri Cross-Arm Stance, `Attack` King of Hell Dash Cross-Slash, `Impact` Triple Blade Sever Pose, `Recovery` Blade Flourish & Reset, and `Ultimate` King of Hell: 103 Mercies Dragon Damnation) with 3-sword synchronized kinematics, nominal 0.31s combat hit timing (`0.14s + 0.10s + 0.07s`), and rest-pose restoration error `delta = 0.000000 < 0.001`.
  - `Z-03`: Created Zoro King of Hell Signature VFX Module in `src/Track2_TowerSystem/VFX/ZoroVFX.luau` featuring emerald flame and purple aura particles, synchronized 3-sword trails (`Three-Sword Trails`) with mandatory disabling (`Trail.Enabled = false`) upon attack end/cancel/cleanup, crescent slash arcs, dragon damnation vortex, quality preset scaling (`Low`, `Medium`, `High`), layer toggles, and strict resource ledger tracking with 100% cleanup upon reset or model destruction.
  - `Z-04`: Created comprehensive automated verification suite `tests/characters/zoro_anim_vfx.spec.luau` verifying all 8 animation states, 3-sword world CFrame kinematic tracking, rest-pose restoration (`delta < 0.001`), trail suppression on stop/reset, VFX ledger registration, quality scaling, mid-animation interrupt safety, and zero memory leaks.
- **Verification Evidence**:
  - `node tests/run_all_tests.mjs`: 44 / 44 PASSED (100.0%)
  - `node tests/combat_oracle_verification.test.mjs`: 22 / 22 PASSED (100.0%)
  - `node tests/phase5_core_and_lab.test.mjs`: 82 / 82 PASSED (100.0%)
  - `lune run tests/phase5_core_and_lab.spec`: 21 / 21 PASSED (100.0%)
  - `lune run tests/characters/luffy_anim_vfx.spec`: 29 / 29 PASSED (100.0%)
  - `lune run tests/characters/zoro_anim_vfx.spec`: 31 / 31 PASSED (100.0%)
  - `rojo sourcemap default.project.json`: Exit code 0 (JSON valid)
  - Internal Gate Status: PASS (worker_m3_1, reviewer_m3_1, reviewer_m3_2, challenger_m3_1, challenger_m3_2, auditor_m3_1 all APPROVED/CLEAN)
