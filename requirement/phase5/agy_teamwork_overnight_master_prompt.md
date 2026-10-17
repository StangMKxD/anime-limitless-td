# AGY Teamwork-Preview — Overnight Unattended Master Prompt & Execution Guide (Phase 5 Complete: 34 Tasks, M0–M5)

- **Target Repository Path:** `C:\Users\Stang\anime-limitless-td`
- **Primary Handoff Document:** `docs/implementation-plans/0005-character-model-animation/assets/HANDOFF.md` (Commit `44026fa`)
- **Teamwork Workspace Directory:** `C:\Users\Stang\anime-limitless-td\.agents\teamwork` (สำหรับเก็บไฟล์ประสานงานทีม, scratch, logs, generated assets/scripts ที่ไม่เกี่ยวกับ runtime โปรเจกต์หลัก)
- **Execution Mode:** **100% UNATTENDED OVERNIGHT AUTONOMOUS EXECUTION (`teamwork-preview`)** — ลุยรวดเดียวจบครบ 34 งาน (`M0 -> M1 -> M2 -> M3 -> M4 -> M5`) พร้อม Commit & Push `origin/main` ทุกจบ Milestone โดยไม่ต้องหยุดถามผู้ใช้กลางคัน

---

## ส่วนที่ 1: วิเคราะห์ความเชื่อมโยงของ Prompt, โครงสร้าง Path จริงใน Repo และกลยุทธ์สั่ง AGY ให้รันยาวทั้งคืนโดยไม่ติด Blocker

จากการตรวจสอบ `HANDOFF.md` (ฉบับ commit `44026fa`) เทียบกับคำสั่งล่าสุดของคุณ พบประเด็นสำคัญที่ต้องฝังลงใน Prompt เพื่อให้ **AGY (`teamwork-preview`)** ทำงานอัตโนมัติทั้งคืนจนจบและผ่านด่านตรวจของ **Codex** ตอนท้ายได้โดยไม่สะดุด:

| มิติสำคัญ | ข้อเท็จจริงจาก Repo (`C:\Users\Stang\anime-limitless-td`) และ `HANDOFF.md` | การตั้งค่าใน Master Prompt เพื่อให้รันทั้งคืนได้เต็มประสิทธิภาพ |
| :--- | :--- | :--- |
| **1. โครงสร้าง Path จริงของโปรเจกต์** | - โมเดลฮีโร่อยู่ที่ `assets/rojo/HeroModels/Luffy.rbxmx` (122 BaseParts), `Zoro.rbxmx` (139 BaseParts), `Ace.rbxmx` (128 BaseParts) และอีก 9 ตัวในโฟลเดอร์เดียวกัน<br>- โมเดลศัตรูอยู่ที่ `assets/rojo/EnemyModels/**` (4 ตัว) และแมปอยู่ที่ `assets/rojo/MapModels/**` (3 ตัว)<br>- โค้ดระบบอยู่ที่ `src/Shared/`, `src/AssetKit/VisualBridge.server.luau`, `src/Track2_TowerSystem/`, `src/DevTools/AnimationLab/`<br>- ตัวรันเทสต์หลักคือ `node tests/run_all_tests.mjs` | ระบุ Path จริงทั้งหมดลงใน Prompt อย่างชัดเจน พร้อมสั่งให้รักษาความละเอียดของโมเดลเดิม (122 / 139 / 128 BaseParts) และเพิ่ม Semantic Pivot Parts, Joint Attachments, Accessories, VFX Emitters/Trails/Beams เข้าไปอย่างเต็มที่ ห้ามยุบโมเดลทิ้ง |
| **2. สิทธิ์ตัดสินใจเต็มที่ (No-Stop Autonomous Override)** | ใน `HANDOFF.md` เดิมมีจุดที่เขียนว่าให้หยุดถามหรือเสนอ diff ถ้านอกขอบเขต ซึ่งถ้าปล่อยรันตอนคุณนอน Agent อาจหยุดรอคำตอบกลางดึก | เพิ่มคำสั่ง **OWNER OVERNIGHT PRE-APPROVAL OVERRIDE** โดยผู้ใช้อนุมัติล่วงหน้า 100% ให้ AGY ตัดสินใจทางวิศวกรรม ขยายรายละเอียดสเปก ใช้เครื่องมือ/ไลบรารี/สคริปต์เสริม หรือเจนรูป/Texture/Mesh/XML Part มาประกอบ Model, Animation, VFX, UI และ Performance Test ได้เต็มที่โดย **ห้ามหยุดรอถามผู้ใช้เด็ดขาด** |
| **3. การแยกไฟล์ทีมไว้ใน `.agents\teamwork`** | คุณต้องการให้ไฟล์ที่ไม่เกี่ยวกับโปรเจกต์หรือไฟล์ประสานงานของทีม `teamwork-preview` อยู่ใน `.agents\teamwork` ที่ Root ของโปรเจกต์ | สั่งให้สร้างโฟลเดอร์ `C:\Users\Stang\anime-limitless-td\.agents\teamwork` ทันทีตั้งแต่เริ่ม `M0` เพื่อเก็บไฟล์แผนย่อยของทีม, state, logs, สคริปต์ช่วยเจน XML/rbxmx, รูปที่เจนมา และผลวัดค่าต่างๆ พร้อมสั่ง **ห้าม `git add` โฟลเดอร์ `.agents/` และ `.vscode/` เข้า Git Commit** เพื่อไม่ให้ผิดกฎ Protected Scope ตอนส่ง Codex รีวิว |
| **4. การรักษาความเข้ากันได้กับเกณฑ์ตรวจของ Codex** | ตอนจบ `M5` ต้องส่งให้ Codex รีวิวรวมครั้งเดียว หาก AGY เผลอไปแก้ค่าดาเมจใน `GameConfig.luau` หรือเปลี่ยนจังหวะ Impact มาตรฐาน (`0.31s` = `0.14 + 0.10 + 0.07`) Codex จะตีตกที่ Gate `G-06` และ `G-13` | กำชับให้ AGY จัดเต็มด้าน **Visuals, 3D Model Rigging, 8-State Procedural Animation, Multi-Layer VFX, Animation Lab UI Dashboard, และ Stress/Performance Test Suite** ได้ไร้ขีดจำกัด แต่ต้องคงจังหวะ Server Damage Oracle (`0.31s`) และแยก Visual ออกจาก Combat 100% เพื่อให้ผ่านทั้งความอลังการและผ่านเกณฑ์ Codex พร้อมกัน |

---

## ส่วนที่ 2: MASTER PROMPT ฉบับเต็ม (Copy กล่องนี้ไปวางสั่ง AGY ได้เลย)

```text
ทำ Phase5 ใน C:\Users\Stang\anime-limitless-td ให้ครบทั้ง 34 งาน (M0 -> M1 -> M2 -> M3 -> M4 -> M5) แบบรวดเดียวจบ (Unattended Overnight Execution) โดยใช้ทักษะ `teamwork-preview` (และเครื่องมือ/ความสามารถทั้งหมดที่มีในระบบอย่างเต็มประสิทธิภาพสูงสุด)

====================================================================
1. เอกสารตั้งต้น & สิทธิ์อนุมัติพิเศษจากเจ้าของโปรเจกต์ (OWNER OVERNIGHT AUTHORIZATION)
====================================================================
1.1 อ่าน `AGENTS.md` และ `docs/READ.md` ก่อนเสมอ จากนั้นใช้เอกสารสั่งงานหลักใบเดียวคือ:
    `docs/implementation-plans/0005-character-model-animation/assets/HANDOFF.md` (ฉบับที่ commit `44026fa`)
    และใช้เอกสารอ้างอิงการออกแบบประกอบ ได้แก่:
    - `docs/implementation-plans/0005-character-model-animation/PLAN.md`
    - `docs/implementation-plans/0005-character-model-animation/characters/01-luffy.md`
    - `docs/implementation-plans/0005-character-model-animation/characters/02-zoro.md`
    - `docs/implementation-plans/0005-character-model-animation/characters/03-ace.md`
    - `docs/implementation-plans/0005-character-model-animation/assets/04-animation-lab-ui.md`
    - `docs/implementation-plans/0005-character-model-animation/assets/contracts-and-integration.md`
    - `requirement/phase5/phase_5_master_plan_and_agent_pack.md` (ถ้ามีใน repo)

1.2 สิทธิ์ตัดสินใจเต็มที่สำหรับรันข้ามคืน (UNATTENDED FULL-POWER OVERRIDE):
    - เจ้าของโปรเจกต์ (Stang) จะปล่อยให้ระบบรันยาวทั้งคืนโดยไม่ได้เฝ้าหน้าจอ ดังนั้น **ห้ามหยุดถามหรือรอการอนุมัติซ้ำระหว่างทางเด็ดขาด**
    - อนุญาตให้เปลี่ยน/ปรับปรุงรายละเอียดสเปกทางเทคนิค ขยายขอบเขตความละเอียดของงานด้าน Visual/Model/Animation/VFX/Lab UI/Test Harness และตัดสินใจแก้ปัญหาเฉพาะหน้า (Delegated Engineering Decisions D-01 ถึง D-08) ได้เองทันทีเพื่อให้งานออกมาสมบูรณ์และมีประสิทธิภาพสูงสุด
    - อนุญาตให้ใช้เครื่องมือทุกชนิดที่มีอย่างเต็มที่: ไม่ว่าจะเป็น `teamwork-preview`, Python/Node.js scripts สำหรับวิเคราะห์และปรับแต่งโครงสร้าง XML ของ `.rbxmx`, การเจนรูปภาพ/Texture/Decal/Sprite มาประกอบ Model หรือ VFX, หรือการสร้าง UI Component Framework / Math & Easing Libraries / Telemetry & Profiling Utilities ภายในขอบเขตโมดูลที่รับผิดชอบ
    - อนุญาตให้ AGY ทำการ `git commit` และ `git push origin main` เมื่อจบแต่ละ Milestone (`M0`, `M1`, `M2`, `M3`, `M4`, `M5`) ได้ทันทีโดยไม่ต้องขออนุมัติซ้ำ

1.3 กฎจัดการไฟล์ทีมและไฟล์นอกโปรเจกต์ (`.agents\teamwork` ISOLATION RULE):
    - ให้ตรวจสอบและสร้างโฟลเดอร์ `C:\Users\Stang\anime-limitless-td\.agents\teamwork` ทันทีตั้งแต่เริ่มงาน (หากยังไม่มีให้ `mkdir -p .agents/teamwork`)
    - ไฟล์ใดๆ ที่เป็นไฟล์ประสานงานของทีม (`teamwork-preview` state, Sub-task boards, Agent notes, Scratchpad, สคริปต์ Python/Node ชั่วคราวสำหรับแปลง `.rbxmx`, รูปภาพต้นฉบับที่เจนมา, หรือไฟล์ Log การทดลองที่ไม่ใช่ไฟล์ Runtime/Deliverable ของโปรเจกต์หลัก) **ให้สร้างและเก็บไว้ใน `.agents\teamwork\` ทั้งหมด**
    - **ห้าม** `git add` หรือ commit โฟลเดอร์ `.agents/` และ `.vscode/` ลงใน Git Repository เด็ดขาด เพื่อให้ Git Working Tree และ Commit History ของโปรเจกต์สะอาด 100%

====================================================================
2. กฎการทำงานกับ GIT & การป้องกันไฟล์กระทบ (GIT & WORKTREE DISCIPLINE)
====================================================================
2.1 ทำงานบนกิ่ง `main` เดิมใน `C:\Users\Stang\anime-limitless-td` (ไม่ต้องสร้าง Git branch ใหม่ หรือ Git worktree แยกออกไปข้างนอก เพื่อให้รันต่อเนื่องใน working tree เดียวตาม `HANDOFF.md`)
2.2 ก่อนเริ่ม `M0` ให้รัน `git status`, `git rev-parse HEAD`, และ `git remote -v` เพื่อบันทึกค่า Execution Base SHA จริงลงใน `TASKS.md` และ `.agents/teamwork/execution_ledger.md`
2.3 ปกป้องสถานะค้างของผู้ใช้ (เช่น `.vscode/` และไฟล์ untracked ที่ไม่เกี่ยว):
    - เวลา Stage ไฟล์เข้า Commit ในแต่ละ Milestone **ต้องระบุ Path ของไฟล์แบบเจาะจงเท่านั้น (`git add <explicit-file-paths>`)**
    - **ห้ามใช้** `git add .`, `git add -A`, `git commit -a`, `git push --force`, `git reset --hard`, หรือ `git clean` ทับไฟล์ของผู้ใช้เด็ดขาด
2.4 เมื่อจบแต่ละ Milestone (`M0` ถึง `M5`):
    - รันชุดทดสอบ (`node tests/run_all_tests.mjs` และเทสต์ใหม่ที่สร้างใน Milestone นั้น)
    - แก้ไขข้อผิดพลาดภายในให้ผ่านทั้งหมดก่อน Commit
    - สร้าง Commit ด้วยข้อความภาษาไทยตามรูปแบบ:
      - `M0`: `docs(PLAN-0005/M0/P5-00..06): ล็อกสัญญา Animation/VFX และตรวจสอบฐานข้อมูลเริ่มต้น` (หรือ `feat(...)` ตามเนื้อหาจริง)
      - `M1`: `feat(PLAN-0005/M1/P5-07..17): แยกระบบ Rig/Animation/VFX จาก Combat และสร้าง Animation Lab UI`
      - `M2`: `feat(PLAN-0005/M2/L-01..04): ปรับปรุงโมเดล ท่าอนิเมชัน 8 สถานะ และเอฟเฟกต์ Luffy Gear 5`
      - `M3`: `feat(PLAN-0005/M3/Z-01..04): ปรับปรุงโมเดล ริกดาบ 3 เล่ม ท่าอนิเมชัน และเอฟเฟกต์ Zoro King of Hell`
      - `M4`: `feat(PLAN-0005/M4/A-01..04): ปรับปรุงโมเดล ท่าอนิเมชัน และเอฟเฟกต์ไฟ Ace Flame Emperor`
      - `M5`: `feat(PLAN-0005/M5/P5-20..23): ทดสอบการผสานระบบ ประสิทธิภาพ และซิงค์เอกสาร Phase 5`
    - สั่ง `git push origin main` ทันทีหลังจบแต่ละ Milestone แล้วบันทึก Commit SHA จริงและสถานะการ Push ลงใน `TASKS.md` และ `docs/implementation-plans/0005-character-model-animation/notes.md`

====================================================================
3. รายละเอียดเชิงวิศวกรรมแบบเจาะจงทั้ง 6 MILESTONES (ครบ 34 TASK-IDs)
====================================================================

--------------------------------------------------------------------
MILESTONE M0 — Contracts, Baseline Audit & Test Runner (`P5-00` .. `P5-06`)
--------------------------------------------------------------------
- `P5-00`: ตรวจสอบ HEAD SHA, `git status`, และสแกนไฟล์โมเดล `.rbxmx` ทั้ง 19 รายการใน:
  - `assets/rojo/HeroModels/` (12 ตัว: `Luffy`, `Zoro`, `Nami`, `Usopp`, `Sanji`, `Chopper`, `Robin`, `Shanks`, `Whitebeard`, `Ace`, `Law`, `Kizaru`)
  - `assets/rojo/EnemyModels/` (4 ตัว: `PirateGrunt`, `SoruAssassin`, `HakiBrute`, `YonkoBoss`)
  - `assets/rojo/MapModels/` (3 ตัว: `AnimeBaseCrystal`, `EnemySpawnGate`, `PlacementPadTemplate`)
  บันทึกจำนวน `BasePart` และโครงสร้าง Hierarchy จริงของทุกตัวไว้ใน `.agents/teamwork/asset_inventory_audit.json`
- `P5-01`: ซิงค์เอกสารหลักในขอบเขต `D-07` (`docs/requirements/PRD.md`, `docs/technical/TDD.md`, `docs/technical/API.md`, `docs/CONTEXT.md`) แบบ Additive Sync โดยเพิ่มหัวข้อ Phase 5 ตามที่ `HANDOFF.md` อนุญาต
- `P5-02`: ตรวจสอบและล็อกพฤติกรรม Combat Oracle ใน `src/Track2_TowerSystem/TowerController.server.luau`:
  - รักษาสูตรคำนวณ Damage, Cooldown, Crit, Armor, Slow, Splash, Target Snapshot และระบบ Sell
  - รักษาจังหวะ Nominal Hit Impact Baseline = `0.14 + 0.10 + 0.07 = 0.31s` ก่อน Recovery Delay อย่างเคร่งครัด
- `P5-03`: สร้างและล็อก `src/Shared/AnimationContract.luau`:
  - รองรับ 8 States มาตรฐาน: `Idle`, `SpecialIdle`, `Spawn`, `Windup`, `Attack`, `Impact`, `Recovery`, `Ultimate`
  - รองรับ Semantic Joints ทั้ง 6 ข้อต่อหลัก (`RootJoint`, `Neck`, `RightShoulder`, `LeftShoulder`, `RightHip`, `LeftHip`) และข้อต่ออาวุธ (`WeaponRight`, `WeaponLeft`, `WeaponMouth`)
  - รองรับ Multi-part Limb Group Binding (สำหรับโมเดลจริงที่มี `UpperArm`, `Forearm`, `Fist`, หรือชิ้นส่วน `_2` หลายชิ้น ให้ผูกตาม Pivot ของข้อต่ออย่างถูกต้องโดยไม่ต้องยุบจำนวน Part เดิม)
  - กำหนด Schema สำหรับ Rest-pose Snapshot (`BaseC0`, `BaseC1`, `BaseSize`, `BaseAttachments`), Deterministic Seek, Playback Speed (`0.1x`–`2.0x`), Frame Step (`+/- 1/60s`), Cancellation และ Hard Reset
- `P5-04`: สร้างและล็อก `src/Shared/VFXContract.luau`:
  - รองรับ Cues: `PassiveAura`, `SpawnDeploy`, `SpecialIdleCue`, `AttackWindup`, `AttackRelease`, `AttackImpact`, `UltimateCast`, `UltimateImpact`
  - รองรับ Quality Presets (`Low`, `Medium`, `High`), Layer Toggles (`Particles`, `Aura`, `TrailOrBeam`, `ImpactEffect`, `CameraShake`, `ScreenFlash`), Intensity (`0.1`–`2.0`), Per-Model/Session Instance Caps และ Resource Ledger ที่ห้ามผูกกับ Damage Callback
- `P5-05`: ออกแบบและล็อกโครงสร้าง Server/Client Mapping ของ Animation Lab ใน `src/DevTools/AnimationLab/**` และ `default.project.json` โดยให้ Client UI ไม่ `require` โมดูลใน `ServerScriptService` ข้ามฝั่งโดยตรง และกั้นด้วย `RunService:IsStudio()` ตั้งแต่บรรทัดแรกก่อนสร้าง Instance/Remote ใดๆ
- `P5-06`: ตรวจสอบ `node tests/run_all_tests.mjs` และเตรียม Test Manifest สำหรับทดสอบทั้งใน Node Simulation Environment และ Roblox Studio Runtime
-> **จบ M0: รันเทสต์ตรวจความถูกต้อง -> Stage เฉพาะไฟล์ M0 -> Commit -> `git push origin main`**

--------------------------------------------------------------------
MILESTONE M1 — Core Runtime Engine & Animation Lab UI (`P5-07` .. `P5-17`)
--------------------------------------------------------------------
- `P5-07` (Single Visual Ownership Seam):
  - ปรับปรุง `src/AssetKit/VisualBridge.server.luau` และ `src/Track2_TowerSystem/TowerController.server.luau` ให้ `Track2` เป็นเจ้าของ Rig (Rig Owner) เพียงผู้เดียว
  - ป้องกันการ Clone Skin ซ้ำซ้อน (Idempotent Rebind) ไม่ว่า `VisualBridge` หรือ `TowerController` จะทำงานก่อนหรือหลัง และไม่สร้าง Rigid `WeldConstraint` ล็อกข้ามข้อต่อที่ต้องขับเคลื่อนด้วย `Motor6D`
- `P5-08` (Idempotent Semantic RigBuilder ใน `src/Track2_TowerSystem/AnimationController.luau`):
  - สร้างระบบสแกนและประกอบ Rig จากโครงสร้าง Part จริงของโมเดล (รองรับทั้งโมเดลที่มี 122–139 BaseParts ซึ่งประกอบด้วย `UpperArm`, `Forearm`, `Fist`, ชิ้นส่วนเสื้อผ้า และชิ้นส่วน `_2`)
  - สร้าง Semantic Pivot / Joint Hierarchy ที่ทำให้เมื่อ `Motor6D.C0` เปลี่ยนค่า ชิ้นส่วนย่อยทั้งหมดของแขน ขา หัว และอาวุธเคลื่อนที่ไปพร้อมกันใน World Space จริง (`Anchored = false`, `Massless = true`, `CanCollide = false` สำหรับทุกชิ้นส่วนลูก และ `Anchored = true` เฉพาะ RootPart)
  - ผูก Accessories เข้ากับ Parent Limb ที่ถูกต้อง (เช่น หมวกผูกกับ `Head`, ผ้าคลุม/ฝักดาบ/สร้อยผูกกับ `Torso`, ดาบผูกกับ `RightArm`/`LeftArm`/`Head`)
- `P5-09` (Deterministic Procedural Animation Player ใน `src/Track2_TowerSystem/AnimationController.luau` & `AnimationRegistry.luau` & `Animations/_FallbackProfile.luau`):
  - รองรับการเล่นท่าแบบ Real-time, Pause, Resume, Stop, Replay, Loop Toggle, Speed (`0.1x`–`2.0x`), Step Forward/Backward (`+/- 1/60s`), และการ Seek ไปยังเวลาใดๆ (`EvaluateAtTime`) แบบ Deterministic โดยไม่เกิดอาการ CFrame/Size Drift สะสม
  - สร้าง `_FallbackProfile.luau` สำหรับฮีโร่อีก 9 ตัวและศัตรู 4 ตัวให้ทำงานได้ราบรื่นไร้ Error
- `P5-10` (VFXDispatcher & Resource Ledger ใน `src/Track2_TowerSystem/VFXDispatcher.luau` & `VFX/_FallbackVFX.luau`):
  - จัดการการเสกและทำลาย VFX ทั้งหมดผ่าน Owner Ledger (`registerInstance`, `registerTween`, `registerTask`, `registerConnection`)
  - บังคับเพดานจำนวน Instance ตาม Quality Preset (`Low`, `Medium`, `High`), รองรับการเปิด/ปิดแยกเลเยอร์, ปรับความเข้มข้น (`Intensity`), และกวาดล้าง Instance ทั้งหมดได้ 100% เมื่อเรียก `cleanupAllForModel` หรือเมื่อโมเดลถูก `:Destroy()`
- `P5-11` (Server Combat & Visual Decoupling ใน `src/Track2_TowerSystem/TowerController.server.luau`):
  - แยก Server Damage Timer (`0.31s` nominal hit) ออกจาก Visual Animation และ VFX อย่างเด็ดขาด
  - พิสูจน์ด้วยเทสต์ว่าต่อให้ปิด VFX ทั้งหมด, สั่ง Seek/Cancel ท่ารัวๆ, หรือโมดูล VFX โยน Error ระบบคำนวณดาเมจ/คริติคอล/สโลว์/การขาย Tower ยังคงให้ผลลัพธ์ตรงกับ Baseline 100%
- `P5-12` ถึง `P5-16` (Animation Lab / Model Inspector UI ใน `src/DevTools/AnimationLab/**`):
  - สร้าง Developer Dashboard ระดับ Production สำหรับเปิดใช้ใน Roblox Studio (`RunService:IsStudio()`) พร้อมระบบ Production Guard ที่คืนค่าทันทีและไม่ทิ้ง UI/Remotes บนเซิร์ฟเวอร์จริง
  - **Model Explorer (19 Assets):** แสดงรายการครบทั้ง 12 Heroes, 4 Enemies, 3 Map Assets พร้อมระบบ `ModelValidator.luau` ที่ตรวจสถานะจริงแยกตามชั้น (`Template Exists`, `Cloneable`, `Rig/Joint Mobility`, `Animation Module`, `VFX Module`) โดย Map Assets แสดงสถานะ Rig เป็น `N/A (Static Map Asset)` อย่างตรงไปตรงมา
  - **Dual Preview Stage (`Workspace` Sandbox Stage + Secondary `ViewportFrame`):** สร้างเวทีทดสอบแยกอิสระพร้อมไฟสตูดิโอ, พื้นตาราง Grid, มุมกล้อง Orbit / Zoom / Front / Side / Back / Reset / Focus, ตัวเปิด/ปิด Joint Markers, Bounding Box, Accessories Toggle, Character Scale Slider (`0.5x`–`2.5x`), และหุ่น `Dummy Target` ที่เลื่อนปรับระยะได้
  - **Animation Player & 5-Phase Timeline:** ปุ่มควบคุมครบชุด (`Play`, `Pause`, `Stop`, `Replay`, `Speed`, `Loop`, `Step -1f/+1f`, `Reset Pose`) และแถบ Timeline แสดงช่วง `Idle -> Wind-up -> Attack -> Impact -> Recovery` พร้อมลาก Seek ได้โดยไม่ยิง VFX Cue ซ้ำมั่วซั่ว
  - **VFX Inspector:** ปุ่มยิง `Trigger Attack VFX`, `Trigger Ultimate VFX`, `Combo Anim + VFX`, `Reset All VFX`, เช็กบ็อกซ์เปิด/ปิดแยก 6 เลเยอร์ (`Particles`, `Aura`, `Trail/Beam`, `Impact`, `Camera Shake`, `Screen Flash`), สไลเดอร์ `Intensity`, และปุ่มสลับ `Low / Medium / High`
  - **Real-Time Debug Inspector & Stress Test Runner (`1 / 10 / 25 / 50` Active Characters):** แสดงจำนวน `BasePart`, `Active Motor6D`, `Active Welds`, `ParticleEmitters` (พร้อม Estimated Particles), `Active VFX Instances`, `Tracked Tweens/Tasks/Connections`, `Created vs Cleaned Ledger` คู่กับการสแกน Subtree จริง และปุ่มรัน Stress Test `1 / 10 / 25 / 50` ตัวละครพร้อมวัด Frame Time และตรวจ Leak หลังสั่ง Cleanup
- `P5-17`: เขียนและรันชุดทดสอบ `tests/phase5_core_and_lab.spec.luau` ครอบคลุมทุกฟังก์ชันของ Core & Lab
-> **จบ M1: รันเทสต์ทั้งหมด -> Stage เฉพาะไฟล์ M1 -> Commit -> `git push origin main`**

--------------------------------------------------------------------
MILESTONE M2 — Luffy Gear 5 (`L-01` .. `L-04`)
--------------------------------------------------------------------
- `L-01` (`assets/rojo/HeroModels/Luffy.rbxmx`):
  - รักษาความละเอียดของโมเดล Luffy เดิม (122 BaseParts) ห้ามยุบทิ้ง แต่ให้จัดระเบียบ Rig/Joint Pivots ทั้ง 6 ข้อต่อหลัก (`RootJoint`, `Neck`, `RightShoulder`, `LeftShoulder`, `RightHip`, `LeftHip`) ให้ควบคุมกลุ่มชิ้นส่วนแขน (`UpperArm`, `Forearm`, `Fist`) ขา ลำตัว และศีรษะได้อย่างสมบูรณ์
  - ปรับแต่งรายละเอียดและยึด Accessories ของ Gear 5 (ผมสีขาวเรืองแสง, วงเมฆตื่นรู้ `CloudScarf`, หมวกฟางสะพายหลัง `StrawHat`, ผ้าคาดเอวสีม่วง) ให้เกาะกับ Parent Limb ที่ถูกต้องพร้อมจุด Attachment สำหรับปล่อยสายฟ้าฮาคิราชันย์และหมัดยืด
- `L-02` (`src/Track2_TowerSystem/Animations/Luffy.luau`):
  - สร้าง Signature Animation ครบทั้ง 8 States (`Idle` Gear 5 Joyboy Bounce, `SpecialIdle` Nika Belly Laugh, `Spawn` Sky Bounce Drop, `Windup` Rubber Arm Coil Back, `Attack` Stretch Punch ยืดแขนขวาพร้อมชดเชยจุดหมุนหัวไหล่ไม่ให้แขนหลุดจากไหล่, `Impact` Hit-stop Vibration, `Recovery` Elastic Snap-back คืนขนาดแขนเดิมแม่นยำ `< 0.001`, และ `Ultimate` Bajrang Fist หมัดยักษ์เทพนิกะ)
- `L-03` (`src/Track2_TowerSystem/VFX/LuffyVFX.luau`):
  - สร้างเอฟเฟกต์ประจำตัว Luffy Gear 5: ละอองเมฆสีขาวนวลลอยรอบตัว, ประกายสายฟ้าฮาคิราชันย์สีดำ-แดง (`Black-Red Conqueror Haki Lightning`), วงแหวนโซนิค (`Rubber Sonic Rings`) ตามแนวแขนยืด, และหมัดยักษ์ `Bajrang Fist` พร้อมโดมคลื่นกระแทกเมื่อปะทะเป้าหมาย โดยลงทะเบียนทุก Instance/Tween ใน Resource Ledger พร้อม TTL
- `L-04` (`tests/characters/luffy_anim_vfx.spec.luau`):
  - เขียนชุดทดสอบตรวจสอบทั้ง 8 States, การเคลื่อนที่จริงของ World CFrame บนชิ้นส่วนแขน/ขา/หมวก/เมฆ, การยืดและหดกลับของแขนขวาสู่ค่าตั้งต้น (`< 0.001` delta), และการกวาดล้าง VFX Instance เหลือ `0` หลัง Cleanup/Destroy
-> **จบ M2: รันเทสต์ทั้งหมด -> Stage เฉพาะไฟล์ M2 -> Commit -> `git push origin main`**

--------------------------------------------------------------------
MILESTONE M3 — Zoro King of Hell (`Z-01` .. `Z-04`)
--------------------------------------------------------------------
- `Z-01` (`assets/rojo/HeroModels/Zoro.rbxmx`):
  - รักษาความละเอียดของโมเดล Zoro เดิม (139 BaseParts) พร้อมจัดระเบียบ 9-Joint Weapon Rig (`RootJoint`, `Neck`, `RightShoulder`, `LeftShoulder`, `RightHip`, `LeftHip` + `WeaponRight` สำหรับดาบ `Enma` ในมือขวา, `WeaponLeft` สำหรับดาบ `Sandai Kitetsu` ในมือซ้าย, `WeaponMouth` สำหรับดาบ `Wado Ichimonji` ที่คาบปาก และยึดฝักดาบทั้ง 3 เล่มไว้กับ `Torso`)
  - เพิ่ม `BladeBase` และ `BladeTip` Attachments บนใบดาบทั้ง 3 เล่มเพื่อรองรับ `Trail` และเปลวไฟฮาคิอย่างแม่นยำ
- `Z-02` (`src/Track2_TowerSystem/Animations/Zoro.luau`):
  - สร้าง Signature Animation ครบทั้ง 8 States (`Idle` Santoryu Guard Stance, `SpecialIdle` Enma Haki Tame, `Spawn` Three-Sword Unsheathe, `Windup` Oni Giri Cross-Arm Stance ไขว้ดาบหน้าอก, `Attack` King of Hell Dash Cross-Slash, `Impact` Triple Blade Sever Pose, `Recovery` Blade Flourish & Reset, และ `Ultimate` King of Hell: 103 Mercies Dragon Damnation) โดยดาบทั้ง 3 เล่มต้องเคลื่อนที่ตามมือและปากอย่างแม่นยำทุกเฟรม
- `Z-03` (`src/Track2_TowerSystem/VFX/ZoroVFX.luau`):
  - สร้างเอฟเฟกต์ประจำตัว Zoro: ออร่าเปลวไฟฮาคิสีเขียวมรกต-ม่วงทอง (`Enma King of Hell Flame`) บนใบดาบทั้ง 3 เล่ม, รอยลากดาบ 3 เส้น (`Three-Sword Trails` ที่บังคับปิด `Trail.Enabled = false` ทันทีเมื่อจบเฟสโจมตีหรือเมื่อถูก Cancel/Reset), คลื่นดาบพระจันทร์เสี้ยว 3 แฉก (`Crescent Slash Arcs`), และพายุคลื่นมังกรเขียวมรกตในท่า `Ultimate`
- `Z-04` (`tests/characters/zoro_anim_vfx.spec.luau`):
  - เขียนชุดทดสอบยืนยันความสัมพันธ์ของพิกัดใบดาบทั้ง 3 เล่มกับมือขวา/มือซ้าย/ศีรษะในทุก State, การปิด `Trail` เมื่อหยุดหรือ Cancel, และการล้าง VFX Instance เหลือ `0`
-> **จบ M3: รันเทสต์ทั้งหมด -> Stage เฉพาะไฟล์ M3 -> Commit -> `git push origin main`**

--------------------------------------------------------------------
MILESTONE M4 — Ace Flame Emperor (`A-01` .. `A-04`)
--------------------------------------------------------------------
- `A-01` (`assets/rojo/HeroModels/Ace.rbxmx`):
  - รักษาความละเอียดของโมเดล Ace เดิม (128 BaseParts) พร้อมจัดระเบียบ 6-Joint Semantic Rig และยึด Accessories ให้ถูกต้อง (`CowboyHat` ยึดติดกับ `Head` ขยับตามการก้ม/เงยหน้า, สร้อยลูกปัดแดง `RedBeads` และมีดสั้น `Dagger` ยึดติดกับ `Torso`) พร้อมสร้าง `RightHandFlameAtt`, `LeftHandFlameAtt`, และ `OverheadEnteiAtt`
- `A-02` (`src/Track2_TowerSystem/Animations/Ace.luau`):
  - สร้าง Signature Animation ครบทั้ง 8 States (`Idle` Logia Flame Finger Ignition ยกมือขวาเลี้ยงไฟปลายนิ้ว, `SpecialIdle` Cowboy Hat Tip & Shoulder Flame Flare, `Spawn` Fire Pillar Materialize, `Windup` Mera Mera Fire Charge มือซ้ายชี้เล็งเป้าหมายดึงหมัดขวาชาร์จไฟ, `Attack` Hiken Fire Fist Thrust ชกปล่อยหมัดเพลิง, `Impact` Detonation Recoil Hold, `Recovery` Flame Dissolve Reset, และ `Ultimate` Dai Enkai: Entei ชูมือขวาข้างเดียวเหนือหัวสร้างดวงอาทิตย์เพลิงแล้วขว้างลงใส่เป้าหมาย)
- `A-03` (`src/Track2_TowerSystem/VFX/AceVFX.luau`):
  - สร้างเอฟเฟกต์ประจำตัว Ace: เปลวไฟปลายนิ้วและสะเก็ดไฟไหล่, เกลียวไฟชาร์จที่แขนขวา, หัวหมัดเพลิงยักษ์ `Hiken` พุ่งพร้อม `Beam` เพลิงเชื่อมสู่เป้าหมาย, วงแหวนคลื่นความร้อน (`Scorch Rings`) และเสาไฟที่จุดปะทะ, รวมถึงลูกบอลดวงอาทิตย์เพลิง 2 ชั้น (`InnerCore` + `OuterCorona`) เหนือมือขวาในท่า `Entei` พร้อมควบคุม `PointLight` ตาม Quality Preset (`Low / Medium / High`)
- `A-04` (`tests/characters/ace_anim_vfx.spec.luau`):
  - เขียนชุดทดสอบยืนยันว่าหมวกคาวบอยเคลื่อนที่ตาม `Head` ทุกองศา, ตำแหน่งลูกไฟ `Entei` เกิดเหนือมือขวาที่ชูขึ้นจริง, และ VFX ทั้งหมดถูกทำลายครบ 100% หลังจบ TTL หรือเมื่อเรียก `cleanupAllForModel`
-> **จบ M4: รันเทสต์ทั้งหมด -> Stage เฉพาะไฟล์ M4 -> Commit -> `git push origin main`**

--------------------------------------------------------------------
MILESTONE M5 — Integration, Stress/Performance Suite, UAT & Canonical Doc Sync (`P5-20` .. `P5-23`)
--------------------------------------------------------------------
- `P5-20` (Mixed 3 Signatures + Legacy Fallback Integration):
  - ทดสอบการทำงานร่วมกันของ Luffy, Zoro, Ace คู่กับโมเดลที่เหลืออีก 16 รายการ (9 Legacy Heroes + 4 Enemies + 3 Map Assets) โดยยืนยันว่าทั้ง 19 Assets โหลดผ่าน `ModelValidator` และทำงานร่วมกันได้โดยไม่แย่ง `RigContext` หรือ `VFXExecutionContext`
- `P5-21` (Full Regression & Sandbox Isolation Verification):
  - รันเทสต์ทั้งหมดของโปรเจกต์ (ทั้งเทสต์เดิม Phase 1–4 และเทสต์ใหม่ทั้งหมดของ Phase 5) ด้วย `node tests/run_all_tests.mjs`
  - ยืนยันว่าทุกรายการผ่าน (`exit code 0`) โดยไม่ลดทอน Assertion เดิม และยืนยันว่าโหมด Sandbox ไม่แตะต้องค่า Economy, Wave Progress, หรือ Rewards
- `P5-22` (Performance/Stress Benchmark `1 / 10 / 25 / 50` & Gate G-01..G-13 Evidence):
  - รันการวัดผล Stress Test `1 / 10 / 25 / 50` Active Characters และ Leak Test พร้อมบันทึกตัวเลขที่ได้จริง สภาพแวดล้อมที่รัน และวิธีวัดลงใน `docs/implementation-plans/0005-character-model-animation/notes.md`
  - แยกแยะผลลัพธ์อย่างซื่อสัตย์เป็น 4 ประเภท: `StaticInspection`, `AutomatedTests (Node Simulation / Harness)`, `StudioRuntime`, และ `ManualVisual` หากการรันนี้ทำผ่าน CLI/Node Simulation โดยไม่ได้เปิดหน้าจอ GUI ของ Roblox Studio จริง ให้บันทึกส่วนที่ตรวจด้วยโค้ด/Simulation ตามจริง และระบุสถานะส่วนที่ต้องใช้ตาดูใน Roblox Studio จริงว่า `NOT VERIFIED (Awaiting Interactive Studio GUI Inspection)` ตามกฎเหล็กของ `HANDOFF.md`
- `P5-23` (Final Canonical Doc Sync & Handover Package):
  - อัปเดต `docs/requirements/PRD.md`, `docs/technical/TDD.md`, `docs/technical/API.md`, `docs/CONTEXT.md`, `docs/implementation-plans/0005-character-model-animation/notes.md` และอัปเดตสถานะทั้ง 34 Task-IDs ใน `TASKS.md` ที่ Root ให้เป็น `READY_FOR_REVIEW` (ห้ามประกาศ `APPROVED` / `PASS` / `CLOSED` เองเพื่อให้ Codex เป็นผู้ตรวจปิดงาน)
  - ตรวจสอบ `git status` และ `git diff` ครั้งสุดท้ายว่าไม่มีไฟล์นอก Scope หรือไฟล์ใน `.agents/teamwork` และ `.vscode/` หลุดเข้า Commit
-> **จบ M5: รันเทสต์ทั้งหมด -> Stage เฉพาะไฟล์ M5 -> Commit -> `git push origin main`**

====================================================================
4. รูปแบบรายงานสรุปตอนท้ายเมื่อทำครบทุก MILESTONE (สำหรับส่งต่อให้ CODEX รีวิวรวมครั้งเดียว)
====================================================================
เมื่อ Commit และ Push ครบทั้ง `M0` ถึง `M5` แล้ว ให้สรุปรายงานส่งท้ายครบทุกหัวข้อดังนี้:
1. Execution Base SHA และ Final SHA บน `origin/main`
2. ตารางสรุปทั้ง 6 Milestones (`M0`..`M5`) พร้อม Commit SHA, ข้อความ Commit, และสถานะ `git push origin main`
3. ตารางสถานะครบทั้ง 34 Task-IDs (`P5-00`..`P5-17`, `L-01`..`L-04`, `Z-01`..`Z-04`, `A-01`..`A-04`, `P5-20`..`P5-23`)
4. รายชื่อไฟล์ที่เปลี่ยนแปลงทั้งหมด (`git diff --name-status <base>..<final>`) พร้อมยืนยันว่า Protected Paths (`AGENTS.md`, `docs/CONVENTIONS.md`, `src/Shared/GameConfig.luau`, `Track1`, `Track3`, `.vscode/`, `.agents/teamwork/`) ไม่ถูกแตะต้องใน Git History
5. ผลการรัน Automated Tests ทั้งหมด (คำสั่งที่รัน, working directory, จำนวนเทสต์ที่ผ่าน, exit code) และผลตาราง Gates `G-01` ถึง `G-13` แยกตามประเภทการตรวจจริง

เริ่มดำเนินการตั้งแต่ `M0` จนจบ `M5` ได้ทันทีโดยไม่ต้องหยุดถาม!
```
