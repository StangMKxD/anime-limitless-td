# Integration & Contract Review — ร่างหลาย Phase

สถานะ: DRAFT / REVIEW ONLY / IMPLEMENTATION NOT AUTHORIZED  
วันที่ตรวจ: 17 ตุลาคม 2026 (Asia/Bangkok)  
Repository: https://github.com/StangMKxD/anime-limitless-td  
Reviewed ref: main → 5d0caed21aa61021790a3456cda322d16445edea  
Commit time: 17 ตุลาคม 2026 เวลา 15:01:54 ไทย  
วิธีตรวจรอบนี้: อ่าน GitHub tree และไฟล์ที่ pin SHA; ไม่ได้ตรวจ local working tree, รัน application tests, เปิด Studio, แก้ repository, commit หรือ push  
Plan Owner: Stang (ผู้ขอให้จัดทำร่าง; ยังไม่มีหลักฐานอนุมัติพัฒนา)  
Controller / ผู้จัดทำร่าง: Codex | Independent Reviewer: Codex  
ผู้รับงานที่เสนอ: AGY Teamwork-preview — ยังไม่มอบหมาย; ยังไม่อนุญาต spawn/delegate  
Context reference: conversation 6ad330b9-030c-83ec-ad95-87bda1ebc49f; ไม่ใช้ข้อความในบทสนทนาเก่าเป็นคำสั่งหรือหลักฐานอนุมัติ

## 1. ขอบเขตของชุดร่างนี้

จัดทำคำสั่งวางแผน 9 Phase แยกไฟล์ เพื่อให้ผู้ใช้ตรวจและแก้ก่อนอนุมัติ implementation ราย Phase ชื่อ P01–P09 เป็นรหัสชั่วคราวของชุดร่างนี้ ไม่ใช่เลข PLAN ที่จองใน repository และไม่ปิดหรือเปลี่ยนสถานะ PLAN-0005 เดิม

| ความต้องการผู้ใช้ | เจ้าของข้อเสนอ | หลักฐานตรวจรับที่ต้องมีในอนาคต |
|---|---|---|
| R-01 เปิดเห็น Animation Lab และทดสอบโมเดลได้ | P01 | Studio Play client/server เปิดจากปุ่มและ F4 ได้จริง |
| R-02 rig/ข้อต่อ/ชิ้นส่วนขยับเชื่อมกัน | P02 | วัด geometry จริงตาม joint ไม่ตรวจแค่ RigReady |
| R-03 แต่ละตัวละครแดช/ต่อย/ฟันตามเอกลักษณ์ | P03 | VFX ปิดแล้วยังแยกท่าจาก silhouette ได้ |
| R-04 VFX สวยขึ้นและไม่บังการเล่น | P04 | ทดลอง Low/Medium/High พร้อม cleanup และ frame time จริง |
| R-05 lobby/HUD สไตล์ Roblox อ่านง่ายและใช้งานได้ | P05 | flow เดิมครบบน desktop/touch/gamepad |
| R-06 หลายแผนที่พร้อมเลือกแผนที่ | P06 | server เลือก/ล็อก map และโหลด route/pads/base ตรงกัน |
| R-07 gameplay เดิม, server/client แยก, ไม่มีงานเขียนไฟล์ชนกัน | Integration | ตรวจ diff + สัญญา + runtime oracle เทียบ baseline |
| S-01 ข้อเสนอเสริม: runtime/regression evidence ที่เชื่อถือได้ | P07 | actual module/instance tests แยกจาก simulation |
| S-02 ข้อเสนอเสริม: ศัตรูเดิน/บอสมี presentation ชัด | P08 | visual root ตาม authoritative root โดยไม่เปลี่ยน logic |
| S-03 ข้อเสนอเสริม: settings/accessibility/device quality | P09 | per-player local preferences ไม่แตะ gameplay |

S-01..S-03 เป็นข้อเสนอที่เพิ่มตามคำขอให้เสนอ Phase เพิ่มเติม ยังไม่ใช่ approved scope.

การตรวจนี้เป็น focused baseline inspection เพื่อออกแบบ ไม่ใช่การรับรองทั้ง main หรือ sign-off ของงาน Phase 5 เดิม

## 2. กติกาที่ตรวจพบ

[CONFIRMED] AGENTS.md กำหนด Codex เป็น Controller/Reviewer, AGY เป็น Implementer; การแก้ PRD/TDD/CONTEXT ต้องให้ Codex ตรวจอนุมัติก่อน และห้าม require ข้าม Track โดยตรง การเชื่อมผ่าน Shared contracts/Attributes เป็นหลัก  
[CONFIRMED] tree ที่ตรวจไม่มี skills/, docs/decisions/ หรือ IMPLEMENTATION_PLAN_GUIDE.md จึงใช้ local stang-solar-system และ stang-mercury ในช่วงออกแบบ; ไม่สร้างโครงสร้าง governance ใหม่ลง repo  
[CONFIRMED] มี root TASKS.md และ Phase5/tasks.md อยู่แล้ว ห้ามสร้างกระดานคู่ขนานใหม่โดยไม่ได้ตกลง ผู้ควบคุมต้องเลือกแหล่งสถานะเดียวหลังอนุมัติ  
[CONFIRMED] docs/READ.md และ HANDOFF เก่าระบุสิทธิ์ commit/push ของ Phase 5; สิทธิ์นั้นไม่ขยายมาถึงร่างใหม่นี้ คำขอล่าสุดกำหนด no code / no commit / no push  
[UNKNOWN] local dirty state, Studio place ที่ผู้ใช้เปิด, Rojo sync รุ่นที่ใช้อยู่, Studio Output และภาพแนบเก่าไม่ได้ถูกตรวจในรอบนี้

## 3. ข้อค้นพบจาก main ที่ต้องจัดการก่อนเพิ่มภาพสวย

Finding IDs ต่อไปนี้คงเดิมในการรีวิวชุดนี้ ไม่ใช้แทนหมายเลข finding เก่าของโครงการที่ยังไม่ได้ตรวจครบ

### F-01 — จุดเริ่ม Lab อยู่ใน container ที่ไม่ทำให้สคริปต์เริ่มตาม mapping ปัจจุบัน
ระดับ: Blocking ต่อ R-01 | สถานะ: CONFIRMED mapping; INFERRED ผลเมื่อใช้ Rojo mapping นี้; StudioRuntime NOT VERIFIED

- default.project.json:19–21 map src/DevTools ทั้งชุดเข้า ReplicatedStorage.DevTools
- AnimationLabBootstrap.client.luau:1–16 เป็น LocalScript; server counterpart:1–23 เป็น server Script และไม่พบ RunContext override หรือ launcher ย้าย/clone scripts ใน src ที่ตรวจ
- LocalScript ใน ReplicatedStorage ไม่เริ่มทำงาน; server Script แบบ Legacy ต้องอยู่ในตำแหน่งที่รันได้ ดู [Roblox ReplicatedStorage](https://create.roblox.com/docs/reference/engine/classes/ReplicatedStorage) และ [Script locations](https://create.roblox.com/docs/scripting/locations)
- ผลที่คาดจาก mapping นี้: client ไม่ติดตั้ง F4 และ server ไม่สร้าง AnimationLabCommand จึงไม่ใช่เพียงปุ่มถูกซ่อนไว้
- ให้ P01 ออกแบบ launcher และ Integration เป็นผู้แก้ mapping หลังอนุมัติ ห้ามแก้ด้วยการเปิด Lab ใน production

### F-02 — หน้า Lab เป็นโครง GUI ยังไม่ต่อ user flow
ระดับ: Blocking ต่อ R-01 | สถานะ: CONFIRMED จากซอร์ส

- AnimationLabGui.luau:9–169 สร้าง sidebar, ช่องค้นหา, ModelList, camera buttons และ panel เปล่าแล้ว return
- ไม่พบการเติมรายการ assets, event handlers ของปุ่ม, หรือการเชื่อม TimelineController ใน GUI/bootstrap ที่ตรวจ
- SandboxStageManager.luau:160–191 clone โมเดลและย้ายตำแหน่ง แต่ไม่เรียก rig binder/profile playback
- แม้แก้ mapping แล้ว ก็ยังไม่ใช่ model-testing tool ที่เล่นท่าครบได้

### F-03 — runtime ต่อสู้ไม่ได้เรียกตัวเล่น Phase5
ระดับ: Blocking ต่อ R-02/R-03 | สถานะ: CONFIRMED จากซอร์ส

- TowerController.server.luau require เพียง GameConfig ที่ :15; ใช้ tryLoadFromHeroModels :639 และระบบ legacy towerRigs
- rig เดิมใช้ NeckJoint ที่ :786 ต่างจาก Neck ตาม AnimationContract
- attack loop :2524 เรียก execute5PhaseAttack ที่ :1868; ไม่พบการเรียก AnimationController / AnimationRegistry / VFXDispatcher จากไฟล์นี้
- ดังนั้นการมี Luffy/Zoro/Ace profile files ไม่ได้พิสูจน์ว่าท่าถูกใช้ในเกมจริง

### F-04 — โค้ดกับ TDD เรื่อง combat isolation ยังไม่ตรงกัน
ระดับ: High; ห้ามใช้เอกสารอ้างว่าแยกเสร็จแล้ว | สถานะ: CONFIRMED

- TDD.md:139–159 ระบุ task.delay(0.31) อิสระและภาพไม่ควบคุม damage
- โค้ดจริง execute5PhaseAttack :1933,1982,1996 ใช้ delay ต่อกัน 0.14 + 0.10 + 0.07 แล้วเรียก onImpactCallback ที่ :2014
- callback ที่ :2524–2554 ทำ VFX ใน pcall ก่อน crit/damage; guards ของ tower/root อยู่ในสาย choreography
- ต้องออกแบบแยก scheduler โดยรักษา nominal impact 0.31 วินาทีและเงื่อนไขเดิม ไม่เปลี่ยน cadence/overlap/cancellation เพื่อทำภาพง่ายขึ้น
- ห้ามย้าย callback ไปจังหวะ Attack หรือ Impact ของ profile ซึ่งไม่ใช่ gameplay clock

### F-05 — assets ที่ตรวจเป็น multipart Part models ไม่ใช่ bone/skinned rigs สำเร็จ
ระดับ: High ต่อ R-02 | สถานะ: CONFIRMED เฉพาะ 3 ไฟล์

ตรวจ XML ตรงที่ SHA นี้: Luffy = 122 Parts, Zoro = 139 Parts, Ace = 128 Parts; แต่ละไฟล์มี Model 1 ตัว และไม่พบ Motor6D, Bone, Humanoid, AnimationController หรือ Animator ใน XML เหล่านี้ Runtime rig injection ยังทำได้ แต่ต้องพิสูจน์ว่าเข้าถึงเส้นทาง live จริง ห้ามสรุปว่า runtime ไม่มี joints เพียงเพราะ XML ไม่มี

ไม่จำเป็นต้องแปลงเป็น skinned mesh เพื่อให้ขยับได้ ใช้ semantic Motor6D rig สำหรับ assets นี้ก่อน หากต้องการ skeleton/bone authoring จริงให้เป็น CR ต่างหาก

### F-06 — Lab command contract ใน API ไม่ตรงกับ handler จริง
ระดับ: High ต่อการเชื่อม UI | สถานะ: CONFIRMED

- API.md:165–176 ระบุ ReplicatedStorage.DevTools.AnimationLab.Remotes และ SelectModel / PlayAnimation / PauseAnimation / SeekAnimation / TriggerVFX ฯลฯ
- server bootstrap :18–84 สร้าง ReplicatedStorage.AnimationLabCommand และรองรับ OpenSession / CloseSession / LoadModel / RunStressTest
- client bootstrap ใช้ remote ที่ root เช่นกัน ห้ามเลือกสัญญาฉบับใดฉบับหนึ่งแล้วประกาศว่าอีกฉบับตรงโดยอัตโนมัติ
- P01 เสนอ adapter/command matrix; Integration ล็อกชื่อ, path, enum, schema และ compatibility ก่อนเริ่มงาน consumer

### F-07 — ผลทดสอบ headless ไม่ครอบคลุมภาพและการเริ่มสคริปต์จริง
ระดับ: Evidence gap | สถานะ: CONFIRMED runner; ผลรันปัจจุบัน NOT RUN

- run_all_tests.mjs:987–1015 เลือก Node fallback สอง suites หากไม่มี Lune
- phase5_core_and_lab.test.mjs:1–5,56–65 ระบุ static audits/Node simulations
- ผลที่ repo รายงานไว้ไม่ใช่ผลรันใหม่ของ Codex และไม่พิสูจน์ว่าปุ่มกดได้, model ขยับ, stage stream ถึง client หรือ VFX สวยจริง
- แยก StaticInspection / AutomatedTests / StudioRuntime / ManualVisual ทุก gate; missing runner ต้องเป็น unavailable/skipped ตามจริง

### F-08 — route/pad consumers ยัง hardcode และไม่เปลี่ยนตาม scene โดยอัตโนมัติ
ระดับ: Integration blocker ต่อ map selection | สถานะ: CONFIRMED

- WaveManager:14–21,241,269,535–536 ใช้ WAYPOINT_COORDS โดยตรงทั้ง spawn และเดิน ไม่อ่านแค่ Workspace waypoint Parts
- TowerController:2143–2156,2236–2241 และ HUD:926 อ่าน GameConfig.PLACEMENT_SLOTS เดิม
- P06 ต้องเสนอข้อมูล map ที่เข้ากันได้ และ Integration อัปเดต consumer seams พร้อมกัน; เปลี่ยนเฉพาะฉากไม่ครบ end-to-end

## 4. Gameplay baseline ที่ห้ามเปลี่ยนเงียบ ๆ

อ้างโค้ดที่ SHA นี้ร่วมกับ docs/CONTEXT.md และ GameConfig; เมื่อขัดกันต้องรายงาน ไม่เลือกค่าจาก PRD รุ่นต้นแทนโค้ดปัจจุบันโดยปริยาย

- Hero catalog ยังคง 8 IDs ที่ GameConfig:387–516; assets 12 heroes ไม่ได้อนุญาตเพิ่ม playable catalog
- 8 placement slots :372–380; zero initial towers; summon/reroll/bag/store/swap/sell และ ownership เดิม
- ไม่เปลี่ยน upgrade formula, reward, card draft, crit clamp, armor, Whitebeard slow, wave/boss scaling หรือ save/persistence
- Target snapshot อยู่ที่ TowerController:2521; ณ hit query enemies ใหม่รอบ impactPos :2534–2542; ห้ามเปลี่ยนเป็นติดตามเป้าตัวเดิมตลอดท่า
- Nominal hit = 0.31s, loop wait 0.08s และ finalCooldown floor 0.15s ตาม :2500,:2560; PRD รุ่นแรกอาจมีค่าคูลดาวน์อื่น
- cadence ต่ำสุดเปิดโอกาสท่าซ้อนกัน ห้ามเพิ่ม IsAttacking gate เพื่อกันภาพซ้อนแล้วทำ DPS ลด
- sell/destroy/root invalid ก่อน hit ต้องรักษาการยกเลิกเดิม ห้ามยกเลิก pending damage เพียงเพราะ client visual ถูกซ่อน/คัดออก
- root เดิมถูก tween 3.2 studs ที่ :1939 และ targeting อ่าน tower.PrimaryPart.Position :2511 การตรึง root ใหม่อาจเปลี่ยนการเลือกเป้าหมาย ต้องบันทึก traces และพิสูจน์เทียบเดิม หรือขอ CR แยกก่อนเปลี่ยน
- VFX เดิมอาจใช้ global math.random ก่อน crit draw :2531 การย้าย VFX ไป client/ปิด VFX อาจเปลี่ยนลำดับ RNG ต้อง audit RNG consumption และคงผลเกมเพลย์หรือขออนุมัตินโยบายใหม่ ห้ามอ้างว่า seed เดียวทำให้เหมือนเดิมโดยไม่ตรวจ
- Maps ใหม่ที่เปลี่ยนความยาวเส้นทาง/ตำแหน่ง pads ย่อมมีผลต่อความยาก แม้สูตรเดิม คำแนะนำชุดแรกใช้ layout เชิงการเล่นเทียบเท่าเดิมและเปลี่ยน art theme; layout ใหม่เป็น scope decision เพิ่ม

## 5. สถาปัตยกรรมเป้าหมายที่เสนอ — ยังไม่ freeze

Server เป็นผู้ตัดสิน target, attack clock, RNG, HP, rewards, inventory และ map lifecycle  
Client แสดง cosmetic dash/pose/VFX/camera/UI; ไม่มี endpoint ขอทำ damage  
Shared เก็บ contracts/ข้อมูล immutable; neutral Presentation package เก็บ visual runtime ที่ใช้ร่วมกับ Lab โดยไม่ require ข้าม Track

ข้อเสนอ D-01: เพิ่ม src/Presentation เป็น package กลางใต้ ReplicatedStorage.Presentation และ src/ClientPresentation เป็น client launcher ใต้ StarterPlayerScripts แยกจาก Track3 HUD แพ็กเกจนี้เป็นข้อเสนอขยาย architecture ต้องให้ผู้ใช้และ Codex รับทราบยอมรับก่อน ไม่ถือว่ากติกาเดิมอนุญาตโดยอัตโนมัติ

เสนอ project mapping สำหรับ Presentation ประกอบด้วย:
- RigBinder → src/Presentation/RigBinder.luau
- AnimationPlayback → src/Presentation/AnimationPlayback.luau
- AnimationRegistry → source เดิม src/Track2_TowerSystem/AnimationRegistry.luau
- Animations → source เดิม src/Track2_TowerSystem/Animations/
- VFXDispatcher → source เดิม src/Track2_TowerSystem/VFXDispatcher.luau
- VFX → source เดิม src/Track2_TowerSystem/VFX/

เป็นการ project source เดียวเข้า runtime ที่ client เข้าถึงได้ ไม่ fork สำเนาให้ workers แก้สองชุด การมี ModuleScript definition ฝั่ง server เดิมไม่อนุญาตให้รัน visual writers ซ้ำ ต้องตรวจว่า registry/modules ไม่มี require side effects และไม่พ่วง ServerScriptService ก่อนล็อก mapping หากใช้ไม่ได้ ให้แก้ D-01 แล้วรีวิวใหม่ ไม่ออกแบบ client ให้ require server container

Lab มี thin client launcher ใน StarterPlayerScripts และ thin server launcher ใน ServerScriptService; helper modules อยู่ DevTools เดิม ต้องแก้ script.Parent assumptions เป็น explicit dependencies ภายใต้ integration patch เดียว

## 6. Strict file ownership ที่เสนอ

ตารางนี้คือ allowlist สำหรับอนาคตเท่านั้น ไฟล์ใหม่เป็น PROPOSED ยังไม่ได้สร้าง ไม่มีสิทธิ์เขียนนอกแถวตน และไม่มี wildcard ที่ครอบข้าม worker

| Owner | Existing files ที่เสนอให้แก้ | New files/prefix ที่เสนอ (ขอบเขตจำกัด) |
|---|---|---|
| P01 Lab | 12 files ตามรายชื่อด้านล่างใต้ src/DevTools/AnimationLab/ | tests/planning-followup/lab/ เฉพาะ tests ของ P01 |
| P02 Rig | ไม่มี; ใช้ assets และ AnimationController เดิมเป็น reference | src/Presentation/RigBinder.luau, RigDiagnostics.luau; tests/planning-followup/rig/ |
| P03 Animation | Animations/Luffy.luau, Zoro.luau, Ace.luau, _FallbackProfile.luau | src/Presentation/AnimationPlayback.luau, AttackMotionProfiles.luau; tests/planning-followup/motion/ |
| P04 VFX | VFXDispatcher.luau, VFX/LuffyVFX.luau, ZoroVFX.luau, AceVFX.luau, _FallbackVFX.luau | tests/planning-followup/vfx/ |
| P05 UI | src/Track3_UISystem/UpgradeHUD.client.luau | src/Track3_UISystem/Views/ และ UIComponents/ เฉพาะ UI; tests/planning-followup/ui/ |
| P06 Maps | ไม่มี existing file | src/Track1_WaveSystem/Maps/ (MapService, MapSelectionService, 4 builders); tests/planning-followup/maps/ |
| P07 Runtime QA | tests/run_all_tests.mjs | tests/studio-reality/ และ tests/planning-followup/oracle/; ไม่แก้ tests ของ worker อื่น |
| P08 Enemies | ไม่มี existing file | src/Presentation/EnemyPresentation.luau, EnemyMotionProfiles.luau, BossPresentation.luau; tests/planning-followup/enemy-presentation/ |
| P09 Preferences | ไม่มี existing file | src/Presentation/PresentationPreferences.luau, QualityPolicy.luau; src/ClientSettings/SettingsPanel.luau, SettingsBootstrap.client.luau; tests/planning-followup/preferences/ |
| Integration lead (AGY หลังอนุมัติ) | default.project.json; src/Shared/GameConfig.luau, src/Shared/AnimationContract.luau, src/Shared/VFXContract.luau; src/Track2_TowerSystem/AnimationController.luau, src/Track2_TowerSystem/AnimationRegistry.luau, src/Track2_TowerSystem/TowerController.server.luau; src/Track1_WaveSystem/WaveManager.server.luau; src/AssetKit/VisualBridge.server.luau; src/DevTools/init.luau | src/Shared/PresentationContract.luau, src/Shared/MapContract.luau, src/Shared/MapCatalog.luau; src/ClientPresentation/Bootstrap.client.luau, src/ClientPresentation/LabClient.client.luau; src/DevToolsServer/LabServer.server.luau; tests/planning-followup/integration/ |
| Controller / documentation owner | AGENTS, PRD, TDD, API, CONTEXT, CONVENTIONS, PROJECT, READ, plan index, TASKS และ existing plans | เฉพาะเอกสารที่มีงานและอนุมัติก่อนเขียน |

รายชื่อ P01: AnimationLabBootstrap.client.luau, AnimationLabBootstrap.server.luau, AnimationLabGui.luau, LabConfig.luau, ModelValidator.luau, OrbitCameraController.luau, SandboxStageManager.luau, StressTestRunner.luau, TelemetryCollector.luau, TimelineController.luau, VFXInspector.luau, init.luau ทั้งหมดใต้ src/DevTools/AnimationLab/ ไม่รวม DevTools/init.luau ซึ่งเป็น Integration owner

prefix ของไฟล์ใหม่ในตารางเป็น namespace ที่สงวนให้ owner รายเดียว ก่อน freeze ต้อง enumerate exact files ในแต่ละ Phase โดยเฉพาะ Views/UIComponents/tests; ห้ามใช้ prefix นี้ขยายไป file งานอื่นเอง หาก launcher wrapper เปลี่ยน parent lookup ให้ P01 เสนอ initialization API และ Integration แก้เฉพาะ wiring ไม่แก้ไฟล์ P01 พร้อมกัน

assets/rojo/** ทั้งหมด read-only สำหรับทุก worker ในร่างนี้; runtime binder แก้ clone ไม่แก้ template; หากจำเป็นต้องแก้ XML/generator ให้ขอ CR ระบุไฟล์ทีละไฟล์ก่อน ไม่ให้ P02 กับ P06 ใช้ broad assets ownership

## 7. สัญญาที่ต้อง freeze ก่อน workers ลงมือ

ค่าต่อไปนี้เป็น draft v0; freeze เกิดเมื่อได้รับอนุมัติ, มี actual contract diff/ref และ owner matrix ระบุชื่อจริงแล้วเท่านั้น

### C-00 Existing gameplay
GameConfig attrs/remotes/8 Hero IDs/8 Slot IDs, upgrade and placement payloads เดิมคงเดิม เพิ่มแบบ additive เท่านั้น ห้ามเปลี่ยน class RemoteEvent เป็น RemoteFunction โดยไม่ตรวจ callsites ทุกฝั่ง

### C-01 Rig binding
Bind(clone, heroId) → context + report; Bind ซ้ำไม่สร้าง joints ซ้ำ; Reset(context); Destroy(context) เรียกซ้ำได้  
context มี model, logicalRoot reference (อ่านอย่างเดียว), visualRoot, motors by canonical JointName, semantic parts, attachments, rest snapshot  
6 joints ปกติ; Zoro 9 joints; map assets เป็น STATIC/N/A  
rest snapshot ครอบคลุม C0/C1/Size/attachment transforms ตาม contract เดิม; ห้ามคืนแค่ motor แล้วปล่อย rubber stretch ค้าง

### C-02 Animation playback และ visual attack message
AnimationState enum 8 ตัวตาม AnimationContract เดิม; EvaluatePoseAtTime(track, seconds) คง signature เดิม  
เสนอ remote ใหม่ชื่อ TowerPresentationEvent (Server→Client เท่านั้น), version=1, attackId, unitUid, heroId, startedAtServerTime, impactAtServerTime, logicalOriginCFrame, targetPositionSnapshot, visualSeed, presentationRevision  
required/optional/ranges/clock source/TTL/max pending ต้องกำหนดใน S0; ปฏิเสธ NaN/Infinity; stale unit/revision → drop visual; duplicate attackId → ไม่เล่นซ้ำ; client ที่ไม่มีโมเดลให้ bounded retry หรือ fallback ไม่รอไม่จำกัด  
message ไม่มี damage, money, crit result ที่ client มีสิทธิ์เปลี่ยน; ตัด visual แล้ว combat ยังดำเนินต่อ  
visual seed ใช้ RNG เฉพาะภาพ; audit global server RNG ก่อนย้าย legacy effects ตาม §4

### C-03 VFX
ใช้ cues และ VFXExecutionContext ใน VFXContract เดิม; targetPosition = server snapshot สำหรับ live และ dummy snapshot สำหรับ Lab  
ledger เป็นเจ้าของ Instance/Tween/Task/Connection ทุกชนิด; quality เป็น client preference ไม่เขียน server stats  
P03 emit cue ผ่าน interface; P04 consume โดยไม่แก้ท่าหรือ clock; dedup key=(attackId,cue,ordinal)  
camera shake/screen flash มีผู้เขียนหนึ่งราย เสนอให้บริการเดิมใน HUD เป็น sink ผ่าน client-local BindableEvent ที่ PlayerGui.PresentationFeedback (PROPOSED): Shake / Flash / AcquireCamera / ReleaseCamera พร้อม owner token, intensity/duration/color ที่จำกัดช่วง; P05 สร้าง port/handler, P01/P03/P04/P08 เรียกผ่าน interface; Integration ต่อ route โดยไม่แก้ HUD file พร้อม P05
priority Lab > lobby preview > gameplay; release ต้องตรง owner token ไม่ปลดกล้องของ session ใหม่; ไม่มี Remote client→server สำหรับการเขียน camera; P04/P08 ห้ามเขียน CurrentCamera เอง

### C-04 Lab
transport ใช้ AnimationLabCommand RemoteFunction ที่ root ต่อเพื่อ compatibility หรือเปลี่ยนพร้อม adapter; ข้อเสนอแนะนำคง root แล้วให้ API amendment ระบุตามจริงหลังอนุมัติ  
server-side actions: OpenSession, CloseSession, LoadModel, RunStressTest; เพิ่มเฉพาะ command ที่จำเป็นและตกลงก่อน  
play/pause/seek/scale/cues ของ preview clone ให้ client-local ผ่าน neutral Presentation; ถ้าต้องเพิ่ม remote action ให้แจง schema/authority ไม่ส่ง arbitrary Instance/path จาก client  
response: {success=true, data=...} หรือ {success=false, error={code,message}} เป็นร่างใหม่ ต้อง adapter ฟิลด์เดิมก่อนใช้  
session key สร้างจาก caller UserId, จำกัด assets enum, scale 0.5–2.5, stress counts 1/10/25/50, finite inputs, bounded work/rate limit  
error codes ที่เสนอ: NOT_STUDIO, INVALID_ACTION, INVALID_PAYLOAD, SESSION_NOT_FOUND, ASSET_NOT_FOUND, RIG_UNSUPPORTED, BUSY, STALE_REQUEST  
Open/Close idempotent, LoadModel revision ป้องกัน response เก่าทับ model ใหม่, production ไม่มี active Lab endpoint/listeners  
client-local preview หรือการจัด streaming ของ stage Y=5000 ต้องเลือกให้ชัดใน P01; ห้ามอ้างว่าระยะห่างอย่างเดียวรับประกัน replication/streaming

### C-05 MapDefinition และ lifecycle
เสนอ Shared.MapCatalog เป็น metadata immutable และ server builders ใน Track1 เท่านั้น  
MapDefinition: schemaVersion=1, id, displayName, theme, orderedWaypoints[6], placementSlots[8], baseCFrame, spawnCFrame, bounds, cameraFocus, compatibilityLayoutId, builderKey  
ใช้ Slot_1..Slot_8 เดิมและ metadata public อย่างเดียว ไม่ส่ง builder function ผ่าน remote  
runtime state ที่เสนอ: mapRevision, selectionState, selectedMapId, lockedMapId, allowedMapIds, votes, deadlineServerTime  
server owns transitions PreparationSelection → Locked → Loading → Ready → Playing → Results; mapping ไป prep เดิมต้องอนุมัติก่อนเพิ่มช่วงรอใหม่  
เลือกแผนที่ทำได้เฉพาะก่อน Wave1 ที่ไม่มี tower/enemy; หลัง lock reject; default Marineford เมื่อไม่เลือก; ไม่ reset cash/bag/stats/cards เพื่อเปลี่ยนฉาก  
invalid map/build failure → คืน default แบบ atomic ก่อน Ready; ห้าม partial world หรือ wave เริ่มบน map ไม่ครบ

### C-06 Map selection commands และ UI
เสนอ MapVoteRequest client→server กับ MapSelectionState server→client; authenticated player จาก OnServerEvent เท่านั้น  
request {version=1,mapId,selectionRevision,requestId}; enum whitelist, revision ถูก, phase ถูก, rate limited  
หนึ่ง player หนึ่ง vote เปลี่ยนได้ก่อน lock; requestId ซ้ำผลไม่ซ้ำ; invalid/stale/late reject พร้อม code  
tie/no-vote → default Marineford ที่คงที่; disconnect เอา vote ออกก่อน lock; late join ได้ snapshot ปัจจุบัน; client ห้ามโหลด map เอง  
deadline/time budget และการเข้าช่วงเลือก map เทียบ prep 15s/early start เดิมยังเป็น decision D-03 ห้ามเพิ่มเวลาโดยปริยาย

### C-07 Per-player visual settings (ข้อเสนอเสริม)
schemaVersion=1; quality, cameraShakeMode, flashMode, decorativeAura, reducedMotion, uiScale; client-local GetSnapshot/Subscribe/SetLocal/ResetLocal; module อยู่ ReplicatedStorage.Presentation.PresentationPreferences ตาม mapping ที่ Integration อนุมัติ
P09 owns module/SettingsPanel; P05 owns ปุ่มเปิดและ focus handoff; P04 consumes ใน dispatcher; P01 ใช้ override เฉพาะ session; ไม่มี DataStore หรือ server gameplay setter
default/enums/UI-scale bounds/Auto thresholds ต้อง freeze ก่อนใช้; error INVALID_PREFERENCE/INVALID_VALUE; Subscribe คืน disconnect function; state แยกแต่ละ client

### C-08 Enemy presentation (ข้อเสนอเสริม)
P08 อ่าน replicated Enemies และ metadata classId/assetId/generation ที่ Integration validate; ข้อมูลที่ยังไม่มีให้เสนอ additive metadata ไม่เดาชื่อ Attribute เป็นของเดิม
logical root transform/HP/dead state เป็น read-only; cosmetic clone/locomotion phase อยู่ client-local; ไม่เปลี่ยน speed/path/arrival/reward
life token ป้องกัน clone เก่ากลับมาหลัง death/reset; boss UI notification ไป P05 local presentation port ตาม schema ที่ freeze ไม่ใช้ HUD writer ใหม่

## 8. ลำดับขนานที่ทำได้จริง

S0 = ขั้นล็อกสัญญา/allowlist/mapping/compatibility โดย Integration lead หลังผู้ใช้อนุมัติ; ไม่ใช่ Phase ที่แอบอนุญาตให้ทำตอนนี้

| ช่วง | ทำขนานได้หลังอนุมัติ | ข้อจำกัด |
|---|---|---|
| Review ตอนนี้ | P01–P09 และ integration draft | อ่าน/เสนอแก้เอกสารเท่านั้น ไม่ spawn โดยปริยาย |
| S0 | ไม่มี worker แก้ shared ระหว่างล็อก | ตัดสิน D-01..D-06 และเตรียม seams/fixtures ที่ใช้งานจริง |
| Wave A | P01 Lab + P02 Rig + P05 UI + P06 Maps + P07 harness design + P09 preferences | ใช้ frozen interfaces; Lab ยังตรวจครบไม่ได้จน P02 มี rig |
| Wave B | P03 Animation + P04 VFX + P08 Enemies | ต้องผ่าน rig interface จาก P02; แยก animation vs VFX files; P01/P05/P06/P07/P09 ทำงานต่อได้ใน allowlist |
| Wave C | Integration sequential | wiring server hit timer, presentation remote, map hooks, launcher, HUD camera sink |
| Wave D | AGY/P07 รวม runtime evidence → Codex รีวิว | current SHA/working tree diff + no stale evidence; visual ขาดให้ NOT VERIFIED |

คู่สำหรับเปิดงานสองสายที่ชนกันน้อยสุด: P01 + P06 (หลัง S0; Lab uses neutral contracts, Maps stays Track1) หรือ P02 + P05  
P03 + P04 ทำขนานได้เมื่อ joint/attachment/cue contract frozen เท่านั้น  
P05 กับ P06 ไม่แย่ง map selector: P05 owns UI view, P06 owns server votes/catalog proposal, Integration owns Shared catalog  
ไม่มี Phase ใดถูกอ้างว่า end-to-end independently complete ก่อน integration gate

## 9. Acceptance และหลักฐานร่วม

| Gate | สิ่งที่ต้องพิสูจน์ภายหลัง | ผู้เก็บหลักฐาน |
|---|---|---|
| G-01 Reachability | Rojo runtime placement ถูก, Lab ปุ่ม/F4 เปิดได้, production lockout | AGY / P01 + Integration |
| G-02 Mobility | mesh/parts จริงตาม motors; accessories/swords ถูก parent; raw template ไม่ถูกแก้ | AGY / P02 |
| G-03 Signature | 8 playable heroes coverage ตาม P03; first 3 quality deep pass; VFX off ยังคงเห็น melee contact | AGY / P03 |
| G-04 Combat oracle | schedule/HP/crit/armor/slow/target snapshot/rewards เหมือน baseline; visual throw/disable ไม่เปลี่ยน damage | AGY / Integration |
| G-05 UI parity | summon/reroll/bag/place/swap/store/sell/upgrade/cards/early start ครบ; focus/modal/touch/gamepad | AGY / P05 |
| G-06 Maps | 4 maps layout-equivalent default ชุดเสนอ; route/pads/base พร้อมก่อน wave; vote rejects midmatch | AGY / P06 |
| G-07 Lifecycle | destroy/sell/close/reset/respawn/cancel/later attack ไม่เหลือ stale resources | AGY / ทุก phase |
| G-08 Performance | device/quality/concurrency/window ระบุ; avg/p95/peak frame ms และ ledger delta จริง | AGY / P04 + Integration |
| G-10 Enemy parity (เสริม) | movement/speed/path/base/reward เหมือน baseline; locomotion/boss visuals มี observer | AGY / P08 + P07 |
| G-11 Preferences (เสริม) | two clients settings ต่างกันโดย server result เดิม; Lab override คืนค่า | AGY / P09 + P07 |
| G-09 Governance | diff ไม่ออก scope; protected-doc amendment ตรวจทีละบรรทัด; actual reviewed ref ตรง evidence | Codex |

ไม่มีการรัน gates เหล่านี้ในรอบนี้ ทุก runtime/manual gate = NOT VERIFIED  
ค่าประสิทธิภาพ PRD P5-R09 ที่มีอยู่ยังต้องรักษาเป็นข้อกำหนดที่ต้องตรวจ ไม่ลดค่าเพื่อให้ผ่าน; budget เพิ่มใหม่ใช้ Proposed จนอนุมัติ  
คำสั่งที่ repo มีเป็นตัวเลือกให้ AGY preflight ในอนาคต: node tests/run_all_tests.mjs, node tests/combat_oracle_verification.test.mjs, node tests/phase5_core_and_lab.test.mjs, rojo sourcemap default.project.json ต้องตรวจ runner, side effects และไฟล์ prerequisite ก่อนรัน ไม่อ้างว่าการมี .spec.luau ทำให้ execute ใน Studio สำเร็จ  
Evidence แต่ละรายการระบุ ref/working tree diff, command หรือ Studio action, environment/device, result/category และข้อจำกัด ไม่บังคับ screenshot/video

## 10. จุดตัดสินใจสำหรับผู้ใช้ตรวจร่าง

| ID | ข้อเสนอแนะนำ | ผลกระทบหากเลือกอย่างอื่น | สถานะ |
|---|---|---|---|
| D-01 | neutral Presentation package + separate client/server launchers | หากคง server-only ต้องเลือก Lab seam และ replication strategy ใหม่ | PROPOSED |
| D-02 | 3 signature heroes ลึกก่อน + อีก 5 playable heroes มีท่าเฉพาะครบใน P03 | ถ้าต้องการ 12 playable ถือเพิ่ม catalog ต้อง CR | PROPOSED |
| D-03 | 4 theme maps layout เดิม; เลือกภายใน prep เดิม ไม่เพิ่ม matchmaking/teleport | layout ต่าง/เวลาล็อบบี้ใหม่เปลี่ยนความยากหรือ flow ต้องอนุมัติแยก | PROPOSED |
| D-04 | lobby เป็น client hub overlay บน session เดิม ไม่มี wave pause | lobby 3D แยก place/server คือขยาย scope | PROPOSED |
| D-05 | audit root motion + RNG traces ก่อนเปลี่ยน pipeline | ถ้ารักษา behavior ไม่ได้ให้แยก migration CR ห้ามแอบแก้ balance | PROPOSED |
| D-06 | รับ P07/P08/P09 เป็น proposed additions; settings session-only | persistence/Auto/device thresholds/new boss logic ต้อง review เพิ่ม | PROPOSED |

สิ่งที่เลื่อนออกจากชุดนี้: persistent unlocks, daily quests, trading, monetization, new playable heroes, pathfinding/multiple lanes, new combat skills/hit counts, ranked/matchmaking, separate places/teleport และการแปลง asset ทั้งหมดเป็น skinned mesh ยังไม่มีการอนุมัติหรือสร้าง ADR แทนผู้ใช้

## 11. การรวมงานและย้อนกลับในอนาคต

Integration lead รับ outputs เป็น working tree เฉพาะไฟล์เจ้าของ ไม่ cherry-pick/commit/push/merge โดยไม่มีคำสั่งใหม่  
ก่อนรวม: ตรวจ baseline ล่าสุด/dirty state; ห้าม reset งานคนอื่น; freeze shared consumers หยุดตอนเปลี่ยน contract  
รวมตามลำดับ contract → rig → playback/VFX → Lab/UI/maps → server wiring → outer verification; ตรวจไม่มีสอง writers ต่อ joints/camera/HP  
ย้อนกลับเป็นชุดตาม owner ปิดเฉพาะ presentation/map-selection hooks และคืน baseline mapping/default map; ไม่รีเซ็ตข้อมูลผู้เล่น ไม่ใช้ destructive reset  
หาก main เปลี่ยนจาก SHA ที่ตรวจ ให้ rebase analysis และแก้ citations/ownership ก่อนอนุมัติ ห้ามใช้เอกสารนี้เป็นการรีวิว SHA ใหม่โดยอัตโนมัติ

## 12. Protected-document review และ handoff

ทุกการแก้ PRD/TDD/API/CONTEXT/PLAN/CONVENTIONS ต้องส่ง proposed amendment ก่อนเขียน ระบุเดิม→ใหม่, เหตุผล, requirement/task, scope/spec/acceptance delta, ผู้มีอำนาจ และหลักฐานอนุมัติ  
ห้ามล้างข้อความเดิมแล้วอ้างว่า sync; ห้ามเขียนว่า Implemented/Verified/Approved จากการมีไฟล์หรือ tests แบบ simulation  
F-04/F-06 ต้องรายงานเป็นเอกสารกับโค้ดไม่ตรง ไม่แก้เอกสารลด requirement ให้พอดีกับ implementation  
งาน docs sync เป็นท้ายแต่ละ phase; การเปลี่ยน spec ต้องอนุมัติก่อนลงมือ ไม่รอท้ายงานแล้วรับรองย้อนหลัง  
ห้ามเปลี่ยนสถานะงานเดิมเป็น approved/closed/pass ในรอบนี้

อ่าน prompt กลางที่ [assets/HANDOFF.md](assets/HANDOFF.md) แล้วเลือกไฟล์ Phase P01–P09 ที่ต้องการรีวิว ไม่มี prompt ใดในชุดนี้มอบอำนาจ implementation

## แหล่งหลักฐานแบบ pin SHA

- [AGENTS.md](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/AGENTS.md), [READ.md](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/docs/READ.md), [CONVENTIONS](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/docs/CONVENTIONS.md)
- [Rojo mapping](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/default.project.json#L19), [Lab client](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/DevTools/AnimationLab/AnimationLabBootstrap.client.luau#L14), [Lab server](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/DevTools/AnimationLab/AnimationLabBootstrap.server.luau#L18)
- [Lab GUI](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/DevTools/AnimationLab/AnimationLabGui.luau#L9), [Stage spawning](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/DevTools/AnimationLab/SandboxStageManager.luau#L160)
- [Live rig loader](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track2_TowerSystem/TowerController.server.luau#L639), [attack timing](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track2_TowerSystem/TowerController.server.luau#L1868), [damage path](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track2_TowerSystem/TowerController.server.luau#L2480)
- [Animation contract](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Shared/AnimationContract.luau#L245), [VFX context](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Shared/VFXContract.luau#L166)
- [Wave map/prep](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track1_WaveSystem/WaveManager.server.luau#L14), [GameConfig](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Shared/GameConfig.luau#L344)
- [TDD combat claim](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/docs/technical/TDD.md#L139), [Lab API claim](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/docs/technical/API.md#L162)
- [Node fallback](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/tests/run_all_tests.mjs#L987), [Node simulation](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/tests/phase5_core_and_lab.test.mjs#L1)
- [Luffy XML](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/assets/rojo/HeroModels/Luffy.rbxmx), [Zoro XML](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/assets/rojo/HeroModels/Zoro.rbxmx), [Ace XML](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/assets/rojo/HeroModels/Ace.rbxmx)
- [Motor6D replication limitation](https://create.roblox.com/docs/reference/engine/classes/Motor6D): Transform เป็น Not Replicated; ห้ามอ้างว่า server pose เห็นบน client โดยไม่ทดสอบ

