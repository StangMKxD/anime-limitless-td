# PLAN-0005 — เอกสารส่งงาน AGY ใบเดียว: Phase5 + Milestone Commit/Push

## 1. อำนาจล่าสุดและสถานะ

- **Status:** IMPLEMENTATION_AUTHORIZED / PENDING_AGY_START; ยังไม่ VERIFIED/ACCEPTED/CLOSED
- **ผู้สั่ง:** Stang, 2026-10-17 Asia/Bangkok; คำสั่งก่อนหน้าให้ AGY ทำทุกแผนแล้ว Codex รีวิวรวมตอนท้าย
- **คำสั่งล่าสุด:** “ขอ prompt และเอกสาร อันเดียว พร้อม comit pushให้ agy commit ไดด้เป็นช่วงๆ ทุกๆ milestone”
- **สิทธิ์ที่ได้รับ:** AGY implement + ทดสอบ + commit และ push origin/main ราย milestone M0..M5 โดยไม่ต้องขออนุมัติซ้ำทุกครั้ง; เป็นข้อยกเว้นจากนโยบาย no-commit เดิมเฉพาะ Phase5 นี้
- **Independent reviewer:** Codex รอตรวจรวม actual final SHA และ evidence ตอนท้าย การตรวจภายใน/commit/push ไม่ใช่ independent approval หรือปิดงาน
- **เอกสารสั่งงานหลัก:** ไฟล์นี้ใบเดียว ครอบคลุม scope/tasks/milestones/Git/gates/ส่งตรวจ; PLAN/tasks/spec เดิมเป็น design reference ไม่ใช่ handoff อีกชุด
- **กระดานสถานะ:** root TASKS.md ใบเดียว; session AGY ยังไม่ระบุ/ยังไม่รับงาน
- **Branch:** main เดิม; ไม่สร้าง branch/worktree/subagents และไม่ merge/deploy/publish โดยไม่มีคำสั่งเพิ่มเติม
- **Source baseline:** d5d06216b2f8bc6ba43071d453709e0d3e0e8df4; เอกสารอนุญาตก่อนหน้า bbefbb4ecf4a5d7eb850dbb444666700a66a4226
- **Execution base:** อ่าน HEAD หลัง commit/push เอกสารใบนี้และบันทึกก่อนเริ่ม; ไม่เดา SHA ของ commit ที่ยังไม่สร้าง
- **Dirty state ที่ต้องปกป้อง:** .vscode/ เป็น untracked ที่มีอยู่ก่อน; ตรวจ status ใหม่ทุกครั้งก่อนเริ่ม/commit ไม่ stage/reset ของผู้ใช้อัตโนมัติ

อ่าน AGENTS.md และ docs/READ.md ก่อนเสมอ แล้วใช้ไฟล์นี้เป็น assignment เดียว ต้องเคารพ source invariants/กฎโปรเจค สิทธิ์ commit/push ล่าสุดนี้มีผลแทนข้อความ no-commit เก่าในเอกสารอ้างอิง ไม่ยกเลิก scope/protected paths หรือการอนุมัติ spec change

## 2. เป้าหมายและขอบเขต

ทำ Phase5 ให้ครบ Core/Shared Contracts/VisualBridge seam, Animation Lab, Luffy, Zoro, Ace และ Integration/UAT ทั้ง 34 Task-ID ใน §4 ตามลำดับ dependency ให้ AGY ตรวจและแก้ภายใน แล้วส่ง Codex รวมตอนท้าย

- Inventory มี 19 assets (12 hero models, 4 enemies, 3 map assets); playable HeroSpec ปัจจุบันมี 8 ไม่เพิ่ม gacha/catalog ของอีก 4 ตัว
- Signature batch นี้มีเพียง Luffy/Zoro/Ace; legacy 9 hero assets + 4 enemies + 3 map assets ต้องคง load/inspect/fallback ตามจริง ไม่อ้างว่ามี signature ใหม่ครบ
- รักษาสูตร damage/cooldown/crit/armor/slow, target snapshot และ reward/economy; nominal impact baseline = 0.14+0.10+0.07 = 0.31s ก่อน recovery delay
- รักษา geometry/detail ของโมเดลเดิม Luffy122/Zoro139/Ace128 BaseParts; cap 22/24/21 ในต้นทางยังไม่อนุมัติและห้ามใช้เป็นเหตุยุบโมเดล
- ไม่ทำ enemy walk rewrite, อีก 9 signatures/4 enemies, client-side animation migration ทั้งเกม, skinned mesh/Blender/uploaded animation, curve editor หรือ featureใหม่

## 3. Ownership และพื้นที่ห้ามแตะ

| Stream | Owned paths ที่ implement ได้ |
|---|---|
| Core | src/Shared/AnimationContract.luau; src/Shared/VFXContract.luau; src/AssetKit/VisualBridge.server.luau เฉพาะ hero binding/welding seam; src/Track2_TowerSystem/TowerController.server.luau เฉพาะ visual/rig/combat decoupling ที่ preserve semantics; AnimationController.luau, AnimationRegistry.luau, VFXDispatcher.luau ภายใต้ Track2; Animations/_FallbackProfile.luau; VFX/_FallbackVFX.luau |
| Lab | src/DevTools/AnimationLab/** รวม client/server entrypoints/test-only harness; default.project.json เฉพาะ mapping ที่ต้องใช้; tests/phase5_core_and_lab.spec.luau |
| Luffy | assets/rojo/HeroModels/Luffy.rbxmx; src/Track2_TowerSystem/Animations/Luffy.luau; src/Track2_TowerSystem/VFX/LuffyVFX.luau; tests/characters/luffy_anim_vfx.spec.luau |
| Zoro | assets/rojo/HeroModels/Zoro.rbxmx; src/Track2_TowerSystem/Animations/Zoro.luau; src/Track2_TowerSystem/VFX/ZoroVFX.luau; tests/characters/zoro_anim_vfx.spec.luau |
| Ace | assets/rojo/HeroModels/Ace.rbxmx; src/Track2_TowerSystem/Animations/Ace.luau; src/Track2_TowerSystem/VFX/AceVFX.luau; tests/characters/ace_anim_vfx.spec.luau |
| Tracking/docs | root TASKS.md, plan notes.md, evidence ที่จำเป็น; canonical doc sync เฉพาะ D-07 ด้านล่าง; ไม่เขียน review-NNN แทน Codex |

**Protected:** AGENTS.md, docs/CONVENTIONS.md, src/Shared/GameConfig.luau, Track1/Track3 ทั้งหมด, assets/rojo/EnemyModels/**, MapModels/** และ hero อีก 9 ไฟล์ ไม่มีสิทธิ์เปลี่ยนกฎหรือขยาย ownership เพื่อแก้ติดขัดเอง

## 4. Milestones และรายการงานครบ 34 IDs

M0 -> M1 -> M2 -> M3 -> M4 -> M5 ใน working tree เดียว ลำดับ character แบบต่อเนื่องเพื่อไม่ต้องสร้าง agent/worktree เพิ่ม ทำ internal checks ที่เกี่ยวข้องให้ครบแต่ละ milestone แล้ว commit+push ไม่ต้องรอ Codex ตรวจกลางทาง

### M0 — Contracts / baseline / runner (P5-00..P5-06)

| Task-ID | ผลส่งมอบ | จุดตรวจภายในก่อนส่งต่อ |
|---|---|---|
| P5-00 | Recheck HEAD/status/XML inventory 19 และ dirty paths | baseline จริง + protected user changes |
| P5-01 | Reconcile canonical docs เฉพาะ Phase5 ตาม D-07 | scope/spec delta ระบุที่มา |
| P5-02 | Freeze combat oracle: timing/cadence/stat snapshot/crit/armor/slow/sell | nominal hit 0.31s; scheduler จริงต้องวัด |
| P5-03 | ล็อก AnimationContract + alias + semantic rig + ownership handshake | missing/duplicate limb, rest/reset/cancel/scale ชัด |
| P5-04 | ล็อก VFXContract/cues/quality/caps/resource ledger | lifecycle idempotent; no damage callbacks |
| P5-05 | ล็อก Lab server/client mapping + Studio command/isolation | no cross-track require/production side effects |
| P5-06 | Preflight tool/test runner และ verification manifest | ไม่เดา harness/คำสั่งและไม่ติดตั้ง dependency เอง |

### M1 — Core runtime + Animation Lab (P5-07..P5-17)

| Task-ID | ผลส่งมอบ | จุดตรวจภายในก่อนส่งต่อ |
|---|---|---|
| P5-07 | Single visual ownership ใน VisualBridge/Track2 | bridge-first/Track2-first/rebind ไม่ clone ซ้ำ |
| P5-08 | Idempotent semantic RigBuilder | joint/world motion จริง, accessory parent ถูก |
| P5-09 | Deterministic procedural player + lifecycle | play/pause/seek/cancel/scale/reset ไม่มี drift |
| P5-10 | VFXDispatcher + resource tracking/caps | quality/layers/TTL/cleanup ไม่ block combat |
| P5-11 | แยก server damage timer จาก visual | oracle เดิม; VFX off/error/spam ไม่เปลี่ยน damage |
| P5-12 | Studio bootstrap/Rojo/client-server/session lifecycle | guard ก่อน allocate และ cleanup ทุก exit |
| P5-13 | Workspace stage/camera/grid/markers/BBox/accessory/scale | restore camera/input/local effects; no game state mutation |
| P5-14 | Animation player + VFX inspector controls | seek ไม่ replay cue; state ที่ไม่มี disableพร้อมreason |
| P5-15 | 19-model explorer + truthful validator | แยก template/clone/module/runtime/visual; map rig N/A |
| P5-16 | Scoped telemetry + stress 1/10/25/50 | tracked/estimated metrics แยก, no orphan after cleanup |
| P5-17 | Core/fallback/Lab internal verification barrier | แก้ failure; missing tools เปิดเผย; Codex ตรวจตอนท้าย |

### M2 — Luffy (L-01..L-04)

| Task-ID | ผลส่งมอบ | จุดตรวจภายในก่อนส่งต่อ |
|---|---|---|
| L-01 | Refine existing Luffy model + 6-joint semantic rig | preserve detail; right-arm multiparts + shoulder pivot |
| L-02 | Luffy 8-state animation | Joyboy/Laugh/Spawn/Stretch Punch/Bajrang; stretch/reset ถูก |
| L-03 | Luffy VFX module | cloud/scarf/black-red Haki/sonic rings/giant fist; tracked TTL |
| L-04 | Luffy automated + Studio/visual checks | visible limb delta, arm/attachment rest <0.001 ตามวิธีวัด, no leak |

### M3 — Zoro (Z-01..Z-04)

| Task-ID | ผลส่งมอบ | จุดตรวจภายในก่อนส่งต่อ |
|---|---|---|
| Z-01 | Refine existing Zoro + 9-joint weapon rig | Wado mouth / Enma right / Sandai left / scabbards torso |
| Z-02 | Zoro 8-state animation | guard/Enma idle/draw/cross slash/103 Mercies; swordsไม่หลุด |
| Z-03 | Zoro VFX module | green-purple-gold flame/three trails/slash arcs; stop clears trails |
| Z-04 | Zoro automated + Studio/visual checks | actual blade/hand/head relation + reset/TTL/destroy |

### M4 — Ace (A-01..A-04)

| Task-ID | ผลส่งมอบ | จุดตรวจภายในก่อนส่งต่อ |
|---|---|---|
| A-01 | Refine existing Ace + 6-joint/accessory rig | hat->head; beads/dagger->torso; hand/overhead attachments |
| A-02 | Ace 8-state animation | flame finger/hat tip/pillar spawn/Hiken/Entei; aimถูก |
| A-03 | Ace VFX module | fire charge/projectile-beam/scorch rings/sunball; quality lights |
| A-04 | Ace automated + Studio/visual checks | hat follows head; Entei above raised hand; no leftover VFX |

### M5 — Integration / UAT / documentation (P5-20..P5-23)

| Task-ID | ผลส่งมอบ | จุดตรวจภายในก่อนส่งต่อ |
|---|---|---|
| P5-20 | Mixed 3 signatures + legacy fallback integration | 19 assetsยังโหลด; ไม่เพิ่ม catalog/แก้ registryจากcharacterโดยพลการ |
| P5-21 | Gameplay/isolation regression ตาม manifest | fresh commands/ref/exits; ไม่ลด assertions; no economy drift |
| P5-22 | Measured stress/cleanup/visual acceptance | device/build/quality/duration/frametime/peak/delta จริง; budget pendingเปิดเผย |
| P5-23 | Final doc sync + final handover | 34 tasks + 6 milestone SHAs/push + final ref + scope/doc audit |

## 5. รายละเอียดสำคัญของ character/Core/Lab

- **Rig:** Luffy/Ace เป้าหมาย 6 body joints (RootJoint/Neck/shoulders/hips), Zoroเพิ่ม WeaponRight/WeaponLeft/WeaponMouth รวม9; geometryจริงเป็น UpperArm/Forearm/Fist และ _2 หลายชิ้น ต้อง mapจากตำแหน่งจริง ไม่สมมุติว่าเป็น R6 สำเร็จรูป
- **Hierarchy:** Track2 เป็น rig owner, bridgeไม่ clone skinซ้อน/ซ่อนvisiblerig; semantic pivotsควบคุมหลายgeometryparts; weld decorationsอยู่parentlimbที่ถูก; ห้าม rigid path ล็อกข้ามmotor ต้องตรวจทั้ง Part0/Part1 และ indirect graph
- **Player:** rest-relative C0/C1/Size/attachment data ต่อ model; states Idle, SpecialIdle, Spawn, Windup, Attack, Impact, Recovery, Ultimate; deterministic seek/loop/speed0.1–2, frame step +/-1/60; hard reset/destroy ชนะ canCancel=false; seekไม่ยิงcueย้อนหลัง
- **Character feel:** Luffyเด้ง/หัวเราะ/ยืดแขนและหมัดยักษ์; ZoroคาบWado มือขวาEnma มือซ้ายSandai พร้อมSantoryuและKing of Hell; Aceชาร์จHikenและชูมือสร้างEnteiก่อนขว้าง สี/ท่า/accessoryตามสเปก batch1 เดิม ไม่สร้างfeatureเพิ่ม
- **VFX:** common cues PassiveAura/SpawnDeploy/AttackWindup/AttackRelease/AttackImpact/UltimateCast/UltimateImpact; SpecialIdle cue extensionต้องล็อกในcontract; Low/Medium/High, layer toggles, intensity0.1–2, per-model/session caps; ทุกinstance/tween/task/connectionเข้าownerledgerและcleanupซ้ำได้
- **Combat:** serverเป็นauthority, visual fire-and-forget ไม่ถือdamagecallback; duplicate/error/cancel visualไม่สร้างHP change/RNGเพิ่ม; cooldownสั้นกว่าจังหวะimpactยังรองรับoverlapเหมือนbaseline; sell/destroyยกเลิกpendingตามsemanticsเดิม
- **Lab:** Studio-only server/client entrypointsถูกservices; local UIไม่require ServerScriptService; Workspace stageหลักสำหรับVFX, ViewportFrameแค่previewรอง; model explorer19, orbit/zoom/presets/focus, grid/markers/BBox/accessorytoggle/scale0.5–2.5, timeline/player/VFXinspector/telemetry/stress1/10/25/50
- **Isolation:** persessioncontainers, กล้อง/input/localpostFXต้องคืนทุกexit; dummyไม่เข้า Enemies/rewardlistener; productionreturnก่อนallocateUI/remotes/listeners; ระยะY5000ไม่ใช่หลักประกันแยกstate
- **Telemetry:** parts/instancesแยก, particlecountเป็นestimate, tweens/tasks/connectionsนับเฉพาะtrackedsubset; ledgerต้องคู่subtree scan; ทุกตัวเลขperformanceมีdevice/build/quality/duration/methodจริง ไม่เท่ากับผลผ่านอัตโนมัติ

Design references เฉพาะเมื่อจำเป็นต้องดูค่าท่ารายละเอียด: [Luffy](../characters/01-luffy.md), [Zoro](../characters/02-zoro.md), [Ace](../characters/03-ace.md), [Lab](04-animation-lab-ui.md), [contracts](contracts-and-integration.md), [source pack](../../../../requirement/phase5/phase_5_master_plan_and_agent_pack.md) พิมพ์เขียวเป็นตัวอย่างที่ยังต้องตรวจ ไม่คัดลอกเป็นverifiedcode

## 6. Decision handling / bounded canonical doc sync

| Decision | วิธีดำเนินการที่อยู่ในสิทธิ์ครั้งนี้ | สิ่งที่ยังไม่อนุมัติ |
|---|---|---|
| D-01 | Track2 เป็น rig owner; Shared contract/attributes ประสาน VisualBridge; ป้องกัน double-skin และทดสอบ order races; AGY ล็อก technical schema ใน Wave0 | direct require ข้าม Track หรือแก้ AGENTS |
| D-02 | Lab server/client entrypoints และ mapping อยู่ภายใน src/DevTools/AnimationLab/** และ default.project.json ตามเดิม; Studio-only command schema จำกัดขอบเขต; server เก็บ runtime authority | ย้าย animation ทั้งเกมไป client/แก้ Track3 HUD/production command endpoint |
| D-03 | คง nominal hit 0.31s, cooldown/target snapshot/crit/armor/slow/overlap/sell semantics; แยก visual failure ออกจาก combat ตาม acceptance | เปลี่ยน damage cadence/formula/economy/rebalance |
| D-04 | คงรายละเอียด baseline 122/139/128 parts; ปรับ rig/เพิ่มรายละเอียดตามสเปกอย่างมีเหตุผล; วัดและเสนอ budget ใหม่โดยแยกตัวเลขที่ยังรออนุมัติ; ไม่ต้องรออนุมัติเพื่อรักษา geometry เดิม | ลด geometry เพื่อ cap เดิม 22/24/21; อ้าง G-10 ผ่านทั้งที่ numerical acceptance budget ยังไม่ตกลง |
| D-05 | สำรวจ runner ที่มีจริง; ทำ test-only harness ภายใน DevTools ownership และ spec paths ใน PLAN; ใช้เครื่องมือที่มี ไม่เดา command หรือเพิ่ม dependency เอง | install package/new external dependency/ไฟล์ production นอก scope |
| D-06 | Visual Sandbox แยก state; controlled dummy ไม่เข้า Enemies/reward listeners; command/schema ตาม contract Studio-only | แก้ WaveManager/Track1 เพื่อทำ reward guard โดยไม่มี scope approval |
| D-07 | Codex อนุญาต bounded additive doc sync ตามรายการด้านล่างล่วงหน้า; final review ตรวจเนื้อหาและ scope ทุกบรรทัดที่แก้ | rewrite requirement เดิม, เพิ่ม scope/spec/feature หรือปรับเกณฑ์ย้อนหลัง |
| D-08 | คง backlog deferred ไม่ตั้งรุ่นส่งมอบใหม่ | ทำ signature ตัวอื่นหรือเพิ่ม catalog |

D-01..D-06 เป็น delegated engineering ภายในขอบเขตที่ล็อก ไม่ใช่บันทึกว่าผู้ใช้อนุมัติรายละเอียดทางเทคนิคทุกค่าแล้ว AGY ระบุ decision ที่เลือก เหตุผล code pointers และผลตรวจจริงใน notes; budget/visual ที่ยังไม่มี approval/evidence เป็น PENDING/NOT VERIFIED จนได้รับการตรวจรับ

### D-07 — ขอบเขต canonical documentation ที่ Codex อนุญาตก่อนเขียน

- docs/requirements/PRD.md: เพิ่มหัวข้อ Phase5 อ้าง P5-R01..08 และ in/out scope ของ PLAN เดิมเท่านั้น ไม่เพิ่ม gameplay requirement/hero catalog
- docs/technical/TDD.md: เพิ่มหัวข้อ Phase5 อธิบาย rig/visual/combat seam, Lab server/client/Studio isolation และ link ไป API ตาม implementation ที่อยู่ใน scope
- docs/technical/API.md: เพิ่ม Phase5 contract ที่ใช้จริงในขอบเขตเดิมพร้อม validation/lifecycle/ownership/version/error/fallback; ไม่แก้ semantics ของ API เกมเดิม
- docs/CONTEXT.md: เพิ่มคำศัพท์ rig/profile/visual state/Lab และ invariant ที่มีอยู่ใน PLAN เท่านั้น ไม่กำหนด business rule ใหม่
- ทำ P5-01 reconciliation และ P5-23 final sync; ระบุเหตุผลและ requirement mapping ของทุก doc change เพื่อให้ Codex ตรวจละเอียดรวมตอนท้าย หากต้องลบ/เปลี่ยนข้อความเดิมที่ขัดกัน ให้เสนอ patch แยกและรออนุมัติก่อนทำส่วนนั้น
- AGENTS.md / CONVENTIONS.md / GameConfig / Track1 / Track3 / enemy-map assets และ hero อีก 9 ไฟล์ยังเป็น protected paths ตาม PLAN

## 7. นโยบาย commit + push ทุก milestone (อนุญาตแล้ว)

1. ก่อนเริ่ม M0 ตรวจ branch/HEAD/status/remotes; execution base ต้องมี HANDOFF เวอร์ชันนี้ และบันทึก actual SHA ใน root TASKS ไม่ตั้งค่า identity/remote ใหม่เอง
2. ทำงานใน milestone ตาม ownership; เขียนและรัน test ทีละ public seam ตาม red-green เมื่อเหมาะสม แก้ relevant failures ก่อนประกาศ milestoneเสร็จ ไม่ลดassertion/ข้ามfailureให้เขียว
3. ถ้าเครื่องมือ Studio/visualไม่มี ให้รายงาน IMPLEMENTED_UNVERIFIED / NOT VERIFIED พร้อมข้อจำกัดและทำงานอิสระต่อ อนุญาตcheckpoint commit/pushตามจริง แต่ห้ามกล่าวว่าgateผ่านหรือmilestoneverified
4. ก่อน commit ตรวจ unstaged/staged diff และ doc scope; stageเฉพาะรายชื่อไฟล์ที่ตรวจในmilestoneด้วย explicit paths ไม่ใช้ git add . / -A ไม่รวม .vscode, credentials, generatedbuilds หรือ unrelateduserfiles
5. Commit แบบระบุ milestone/Task-ID ด้วยข้อความไทย เช่น feat(PLAN-0005/M1/P5-07..17): แยกริกและสร้างแล็บทดสอบ; M0ใช้docs/featตามเนื้อหาจริง, M5ระบุintegration/verification/docsตามdiff
6. หลังcommitอ่าน SHAจากGit แล้ว push แบบปกติด้วย git push origin main; ไม่ force, amend/rebase/rewrite shared history, merge หรือเปลี่ยนbranch ถ้าremoteเปลี่ยนจนpushถูกปฏิเสธให้รายงานสภาพจริงและหยุดเฉพาะGitstepที่ติด ห้ามรีเซ็ตทับงานผู้ใช้
7. M0..M5 มี commitอย่างน้อยหนึ่งก้อนต่อmilestone; อาจแยกtask/fixเพิ่มเมื่อมีเหตุผล แต่ไม่จับทั้ง6milestoneรวมcommitเดียว ห้ามemptycommitเพื่อทำให้ตารางดูครบ
8. จดmilestone/Task-IDs/command-results/commitSHA/pushstatusตามจริงในnotesหรืออ้างgitlog ไม่สร้างreportsซ้ำ; SHAของcommitปัจจุบันจดหลังcommit/ในบันทึกmilestoneถัดไปได้ FinalSHAส่งในคำตอบสุดท้าย ไม่พยายามใส่hashของcommitลงตัวมันเอง
9. คำสั่งนี้ไม่อนุญาตปิดงานหรือประกาศAPPROVED/PASS/CLOSED; Codexตรวจรวมที่finalSHAหลังM5 การpushไม่ใช่reviewsignoff

## 8. Gates G-01..G-13 และรูปแบบหลักฐาน

| Gate | ต้องพิสูจน์ | สถานะตั้งต้น |
|---|---|---|
| G-01 | load/clone/inspect19 assets;3 signatures+16legacyตามจริง | NOT VERIFIED |
| G-02 | expectedjointsและvisiblelimb/weapon worldCFrameขยับจริงหลังenginestep ไม่มีrigidlock | NOT VERIFIED |
| G-03 | accessories/3swordsตามparentถูกทุกstate/มุม | NOT VERIFIED |
| G-04 | pause/seek/cancel/reset/scale/replayคืนrest ไม่มีdrift/stalecontext | NOT VERIFIED |
| G-05 | VFXcue/position/direction/layers/qualityถูกและseekไม่emitซ้ำ | NOT VERIFIED |
| G-06 | damage timing/cadence/RNG/armor/splash/slow/sellไม่เปลี่ยนจากvisual | NOT VERIFIED |
| G-07 | destroy/sell/reset/closeไม่เหลือownedresource/references; ledger+subtreeตรง | NOT VERIFIED |
| G-08 | sandbox/productionguardไม่แก้gameplay/economy/wave/rewards | NOT VERIFIED |
| G-09 | mixedcharacters+legacyไม่แย่งstate; stressแยกจากcapเกมปกติ8 | NOT VERIFIED |
| G-10 | actualstress1/10/25/50+environment+budgetที่ยืนยันได้; ตัวเลขที่ยังไม่อนุมัติคงpending | NOT VERIFIED |
| G-11 | existingPhases1–4+Phase5suite manifestรันจริงและรายงานexit/status | NOT VERIFIED |
| G-12 | actualStudio/visualครบ3characters+Lab; ไม่มีผลจริงห้ามถือผ่าน ไม่บังคับภาพวิดีโอ | NOT VERIFIED |
| G-13 | finaldiff+ทุกdocchangeอยู่approvedscope ไม่มีspec/ownershipdrift | NOT VERIFIED |

ผลแยก4ประเภท: StaticInspection, AutomatedTests (ระบุNode simulation/engine), StudioRuntime, ManualVisual พร้อมcommand/cwd/ref/exit/statusหรือเหตุunavailable Existing candidateคือ node tests/run_all_tests.mjs ส่วนsuite .test.mjs/build/typecheck/Studioharnessให้preflightจากของจริงก่อนรัน ไม่ติดตั้งdependencyหรือเดาคำสั่งเอง Normalpassingtestsไม่ต้องเก็บlogซ้ำ เก็บเฉพาะevidenceที่จำเป็นต่อperformance/failure/ข้อสรุป

## 9. ส่ง Codex รวมครั้งเดียวตอนท้าย

- ส่งexecutionbase/finalSHA, gitlogของM0..M5และpushstatus, changed-pathlist และworkingtreeที่ยังเหลือ (ถ้ามี)
- รายงานครบ34Task-IDว่าทำ/ยังขาดอะไรพร้อมgateevidence; ห้ามอ้างallcompleteหากยังมีblocker/unverifiedgate
- ส่งtestmanifest/commands/cwd/exits, Studio/visual/performanceจริง, openD-IDs/budget/limitations, docschangeและscope audit; ไม่สร้างRESULT/summary/checklistซ้ำหลายไฟล์
- rootTASKSเป็นREADY_FOR_REVIEWเมื่อpackageครบ หรือBLOCKEDพร้อมเหตุจริง งานอิสระทำต่อให้ครบก่อนถามข้อที่จำเป็น
- Codexจะอ่านactualcommitdiffตั้งแต่executionbaseถึงfinalSHA และevidenceรวม เขียนreview-NNNตามรอบ/F-IDเดิม; ถ้าต้องแก้ภายหลังใช้HANDOFFเดิมและต้องตรวจrefใหม่ ไม่อนุมัติstaleSHAหรือunresolvedblocker

## 10. Prompt เดียวสำหรับส่ง AGY

```text
ทำ Phase5 ใน C:\Users\Stang\anime-limitless-td ให้ครบทุก stream ด้วย agy teamwork-preview / stang-darkmatter
ใช้เอกสารสั่งงานหลักเพียงใบเดียว: docs/implementation-plans/0005-character-model-animation/assets/HANDOFF.md อ่านกฎ AGENTS.md และ docs/READ.md ก่อน แล้วทำตาม HANDOFF ทุกหัวข้อ เอกสารอื่นเป็น design references ตามที่ HANDOFF ชี้เท่านั้น

ผู้ใช้อนุญาตให้ implement ทั้ง 34 งาน และให้ AGY commit + push origin/main เมื่อจบแต่ละ milestone แล้ว โดย Codex จะรอรีวิวรวมตอนท้าย ไม่ต้องขออนุมัติซ้ำทุก milestone

ตรวจ HEAD/status ก่อนเริ่มและปกป้อง .vscode/ กับงานค้างผู้ใช้ ทำ M0 Contracts -> M1 Core/Lab -> M2 Luffy -> M3 Zoro -> M4 Ace -> M5 Integration/UAT/Doc sync บน main เดิม ยังไม่สร้าง branch/worktree/subagents
แต่ละ milestone ต้องตรวจและแก้ failure ภายในก่อน stage เฉพาะไฟล์ใน scope, commit ข้อความไทยระบุ PLAN-0005/Mx/Task-ID แล้ว push แบบปกติไป origin/main บันทึก commit SHA และผล push ตามจริง ห้าม git add ., force push, rewrite history, merge/deploy หรือปิดงานเอง

ยึด scope/protected paths/Decision handling ใน HANDOFF รักษารายละเอียดโมเดลและ damage timing 0.31s ห้ามเพิ่ม feature/rebalance/require ข้าม Track หรือขยายสเปกเอง การแก้ PRD/TDD/API/CONTEXT ทำได้เฉพาะ bounded additive sync ที่ Codex อนุญาตใน HANDOFF ถ้าต้องเปลี่ยนเกินนั้นให้เสนอ diff ก่อน

ตรวจ gates G-01..G-13 และแยก Static/Automated/Studio Runtime/Manual Visual จากกัน ผลที่ทำไม่ได้หรือ budget ที่ยังไม่อนุมัติให้ NOT VERIFIED/PENDING ห้ามประดิษฐ์ผลหรือถือว่า commit/push เท่ากับผ่านรีวิว ทำงานที่ไม่ติดขัดต่อจนจบ ไม่หยุดรอ Codex ราย milestone

ท้ายงานส่งครั้งเดียว: execution base/final SHA, รายการ M0..M5 พร้อม SHA/ผล push, สถานะครบ 34 Task-ID, changed-path list, คำสั่งทดสอบ/cwd/exit/status และ evidence จริง, การแก้เอกสารพร้อม scope audit, known limitations/open decisions อัปเดต root TASKS เป็น READY_FOR_REVIEW เมื่อครบ หรือ BLOCKED พร้อมเหตุจริง ห้าม APPROVED/PASS/CLOSED จากนั้นส่งให้ Codex รีวิวรวมที่ final SHA
```
