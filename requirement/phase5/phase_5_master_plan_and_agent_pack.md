# Anime Limitless TD — Phase 5 Master Architecture, Analysis & Multi-Agent Implementation Pack

- **Repository:** `https://github.com/StangMKxD/anime-limitless-td`
- **Baseline Commit:** `d5d06216b2f8bc6ba43071d453709e0d3e0e8df4`
- **Phase:** Phase 5 — Character Model Improvement, Signature Animation, Character-Specific VFX & Animation Lab UI
- **Execution Mode:** **ANALYSIS + PLANNING ONLY** (ห้าม Implement, Push, Merge หรือแก้ไข Source Code ของระบบเกมจนกว่าเจ้าของโปรเจกต์จะ Review และอนุมัติ)
- **Governance & Separation of Duties:**
  - **Project Owner:** ผู้อนุมัติแผน (Approver) และผู้ตัดสินใจขั้นสุดท้าย
  - **Codex:** Controller / Independent Reviewer (ตรวจสอบ Contract, Ownership, Regression, Quality Gates)
  - **AGY (Antigravity / Implementer Agents):** Implementer (รับผิดชอบการเขียนโค้ดตาม Worktree และ File Ownership ที่ได้รับอนุมัติแล้วเท่านั้น)

---

## SECTION 0: คู่มือสั่งงาน AI Agents & Starter Prompts (Copy-Paste พร้อมใช้งานทันที)

ไฟล์ `.md` ไฟล์นี้ถูกออกแบบให้เป็น **Single-File Master Pack (All-in-One)** ที่คุณสามารถนำไปวางไว้ในโฟลเดอร์ `phase5/` หรือ root ของโปรเจกต์ได้เลย โดยภายในไฟล์นี้ประกอบด้วย:
1. **Starter Prompts** สำหรับสั่งให้ Agent อ่านไฟล์นี้และ **แตกไฟล์เอกสารทั้ง 5 ไฟล์** ลงใน `docs/implementation-plans/0005-character-model-animation/` อัตโนมัติ พร้อมตรวจสอบ Baseline Commit `d5d06216b2f8bc6ba43071d453709e0d3e0e8df4`
2. **รายงานการวิเคราะห์ครบทั้ง 6 Parts (Part 1 – Part 6)** ตามข้อกำหนดทุกประการ
3. **เนื้อหาฉบับเต็มแบบจับมือทำ (Full Verbatim Content) ของเอกสารทั้ง 5 ไฟล์** ที่คั่นด้วย Marker พิเศษ `<!-- === FILE_START: path === -->` และ `<!-- === FILE_END: path === -->` เพื่อให้ Agent หรือสคริปต์ Python/PowerShell แตกไฟล์ออกเป็น:
   - `docs/implementation-plans/0005-character-model-animation/PLAN.md`
   - `docs/implementation-plans/0005-character-model-animation/characters/01-luffy.md`
   - `docs/implementation-plans/0005-character-model-animation/characters/02-zoro.md`
   - `docs/implementation-plans/0005-character-model-animation/characters/03-ace.md`
   - `docs/implementation-plans/0005-character-model-animation/assets/04-animation-lab-ui.md`

---

### 0.1 Prompt เริ่มต้นที่ 1: สั่ง Agent แตกไฟล์ Plan ทั้ง 5 ไฟล์ + Audit Baseline Commit (รันก่อนเริ่ม Phase 5)

> **วิธีใช้:** นำไฟล์ `PHASE_5_MASTER_PLAN_AND_AGENT_PACK.md` ไปวางในโปรเจกต์ (เช่น `phase5/PHASE_5_MASTER_PLAN_AND_AGENT_PACK.md`) แล้ว Copy Prompt ด้านล่างนี้ส่งให้ Agent (`Codex` หรือ `AGY`) เพื่อแตกไฟล์เข้า `docs/implementation-plans/0005-character-model-animation/` และยืนยัน Line Numbers กับ Baseline Commit จริง

```text
ROLE: คุณคือ Lead Repository Architect & Planning Initializer สำหรับโปรเจกต์ Anime Limitless TD (Baseline Commit: d5d06216b2f8bc6ba43071d453709e0d3e0e8df4)

คำสั่งเด็ดขาด (HARD CONSTRAINTS):
1. รอบนี้คือการเตรียมเอกสาร Planning และ Verify Baseline เท่านั้น ห้ามแก้ไขไฟล์ใน `src/`, `assets/`, หรือ `default.project.json` และห้าม Push/Merge หรือ Spawn Sub-Agent โดยไม่ได้รับอนุมัติ
2. ให้อ่านไฟล์ `PHASE_5_MASTER_PLAN_AND_AGENT_PACK.md` (หรือตำแหน่งที่ฉันวางไฟล์นี้ไว้ในโฟลเดอร์ `phase5/`) ตั้งต้นจนจบ
3. ให้แยกเนื้อหาที่อยู่ในบล็อกระหว่าง `<!-- === FILE_START: <filepath> === -->` ถึง `<!-- === FILE_END: <filepath> === -->` ออกเป็นไฟล์จริง 5 ไฟล์ตามโครงสร้างดังนี้:
   - `docs/implementation-plans/0005-character-model-animation/PLAN.md`
   - `docs/implementation-plans/0005-character-model-animation/characters/01-luffy.md`
   - `docs/implementation-plans/0005-character-model-animation/characters/02-zoro.md`
   - `docs/implementation-plans/0005-character-model-animation/characters/03-ace.md`
   - `docs/implementation-plans/0005-character-model-animation/assets/04-animation-lab-ui.md`
4. หลังจากแตกไฟล์ทั้ง 5 เสร็จแล้ว ให้รันการตรวจสอบ Baseline Repository จริงแบบ Read-Only:
   - ตรวจ `git rev-parse HEAD` ว่าตรงกับ `d5d06216b2f8bc6ba43071d453709e0d3e0e8df4` หรือไม่
   - เปิดอ่านไฟล์จริงใน Repo ได้แก่ `AGENTS.md`, `docs/READ.md`, `docs/CONVENTIONS.md`, `docs/CONTEXT.md`, `src/Shared/GameConfig.luau`, `src/Track2_TowerSystem/TowerController.server.luau`, `src/AssetKit/VisualBridge.server.luau`, `src/Track1_WaveSystem/WaveManager.server.luau`, `default.project.json` และไฟล์โมเดล `.rbxmx` ทั้ง 19 ตัว
   - อัปเดตเลขบรรทัด (Exact Line Numbers) และรายละเอียด Hierarchy ของ Part จริงจากไฟล์ `.rbxmx` ลงในเอกสารทั้ง 5 ไฟล์ให้ตรงกับโค้ดจริง 100%
5. สรุปรายงานผลการแตกไฟล์ทั้ง 5 ไฟล์ และผลการ Verify Baseline ส่งให้เจ้าของโปรเจกต์เพื่อขออนุมัติเริ่ม Wave 0
```

---

### 0.2 สคริปต์อัตโนมัติสำหรับแตกไฟล์เดียวออกเป็น 5 ไฟล์ (One-Command Auto-Splitter)

หากต้องการให้ Agent หรือคุณรันคำสั่งเดียวเพื่อแตกไฟล์ `PHASE_5_MASTER_PLAN_AND_AGENT_PACK.md` ออกเป็นทั้ง 5 ไฟล์ใน `docs/implementation-plans/0005-character-model-animation/` ทันที ให้รันคำสั่ง Python ด้านล่างนี้จาก Root ของ Repository:

```bash
python3 -c '
import os, re, sys

src_candidates = [
    "PHASE_5_MASTER_PLAN_AND_AGENT_PACK.md",
    "phase5/PHASE_5_MASTER_PLAN_AND_AGENT_PACK.md",
    "docs/PHASE_5_MASTER_PLAN_AND_AGENT_PACK.md",
]
src = next((p for p in src_candidates if os.path.exists(p)), None)
if not src:
    print("ERROR: Cannot find PHASE_5_MASTER_PLAN_AND_AGENT_PACK.md")
    sys.exit(1)

with open(src, "r", encoding="utf-8") as f:
    text = f.read()

pattern = re.compile(
    r"<!-- === FILE_START: ([^\s]+) === -->\n(.*?)\n<!-- === FILE_END: \1 === -->",
    re.DOTALL
)
matches = pattern.findall(text)
if not matches:
    print("ERROR: No embedded file blocks found.")
    sys.exit(1)

for rel_path, body in matches:
    os.makedirs(os.path.dirname(rel_path), exist_ok=True)
    cleaned = body.replace("\\`\\`\\`", "```")
    with open(rel_path, "w", encoding="utf-8") as out:
        out.write(cleaned.strip() + "\n")
    print(f"[CREATED] {rel_path} ({len(cleaned.splitlines())} lines)")
'
```

---

### 0.3 Prompt เริ่มต้นที่ 2: สำหรับ Wave 0 — Lead Architect / Core Contracts & Animation Lab UI (`AGY-Core`)

> **ใช้เมื่อ:** เจ้าของโปรเจกต์อนุมัติ `PLAN.md` และ `assets/04-animation-lab-ui.md` แล้ว และต้องการสร้าง Shared Contracts + แก้ปัญหา Weld/Motor6D Conflict + สร้าง Animation Lab UI ก่อนที่ทีม Character 3 คนจะเริ่มแยก Worktree

```text
ROLE: คุณคือ AGY-Core (Core Animation Architect & DevTools Engineer) สำหรับโปรเจกต์ Anime Limitless TD Phase 5
BRANCH: `feat/phase5-core-contracts-and-lab`
WORKTREE: `../wt-phase5-core`

ให้อ่านไฟล์ต่อไปนี้ก่อนเริ่มงาน:
1. `AGENTS.md`, `docs/CONVENTIONS.md`, `docs/CONTEXT.md`
2. `docs/implementation-plans/0005-character-model-animation/PLAN.md`
3. `docs/implementation-plans/0005-character-model-animation/assets/04-animation-lab-ui.md`

ขอบเขตไฟล์ที่คุณเป็นเจ้าของ (OWNED FILES ONLY):
- `src/Shared/AnimationContract.luau` (สร้างใหม่)
- `src/Shared/VFXContract.luau` (สร้างใหม่)
- `src/Track2_TowerSystem/AnimationController.luau` (สร้างใหม่)
- `src/Track2_TowerSystem/AnimationRegistry.luau` (สร้างใหม่ - ลงทะเบียน Fallback + Stub Loader สำหรับ Luffy, Zoro, Ace)
- `src/Track2_TowerSystem/VFXDispatcher.luau` (สร้างใหม่)
- `src/AssetKit/VisualBridge.server.luau` (แก้ไขเฉพาะส่วน Welding Policy เพื่อไม่ให้สร้าง WeldConstraint ทับข้อต่อที่ต้องใช้ Motor6D)
- `src/Track2_TowerSystem/TowerController.server.luau` (แก้ไขเพื่อแยก Runtime Rigging & Procedural Animation ออกไปเรียกผ่าน `AnimationController` และ `VFXDispatcher` โดยรักษา Combat/Damage Timing เดิม 100%)
- `src/DevTools/AnimationLab/*` (สร้างใหม่ทั้งหมดสำหรับ Animation Lab UI ใน Studio)
- `default.project.json` (อัปเดตเฉพาะกรณีที่จำเป็นต้องแมป `src/DevTools` เข้ากับ `ServerStorage` หรือ `ReplicatedStorage` ตามแผน)
- `tests/phase5_core_and_lab.spec.luau` (สร้างใหม่)

ข้อห้ามเด็ดขาด (FORBIDDEN):
- ห้ามแก้ไขไฟล์ของตัวละครรายบุคคล (`Animations/Luffy.luau`, `Animations/Zoro.luau`, `Animations/Ace.luau`) ยกเว้นการทำ pcall Stub/Interface ใน Registry
- ห้ามเปลี่ยนสูตรคำนวณ Damage, Cooldown, Wave Spawning หรือ Economy ใน `WaveManager.server.luau` และ `GameConfig.luau`
- เมื่อทำเสร็จ ให้รัน Automated Tests ทั้งหมด และส่งมอบหลักฐานให้ Codex ตรวจตาม Reviewer Gate ใน `PLAN.md`
```

---

### 0.4 Prompt เริ่มต้นที่ 3, 4, 5: สำหรับ Developer 1 (Luffy), Developer 2 (Zoro), Developer 3 (Ace)

#### Prompt สำหรับ Developer 1 — Luffy Gear 5 (`AGY-Char-Luffy`)
```text
ROLE: คุณคือ AGY-Char-Luffy (Technical Animator & VFX Engineer รับผิดชอบ Luffy Gear 5)
BRANCH: `feat/phase5-char-luffy` (แตกจาก `feat/phase5-core-contracts-and-lab`)
WORKTREE: `../wt-phase5-luffy`

ให้อ่านไฟล์ต่อไปนี้ก่อนเริ่มงาน:
1. `AGENTS.md`, `docs/CONVENTIONS.md`
2. `docs/implementation-plans/0005-character-model-animation/PLAN.md`
3. `docs/implementation-plans/0005-character-model-animation/characters/01-luffy.md`
4. `src/Shared/AnimationContract.luau` และ `src/Shared/VFXContract.luau`

OWNED FILES ONLY (ห้ามแตะไฟล์อื่นนอกเหนือจากนี้เด็ดขาด):
- `assets/Heroes/Luffy.rbxmx` (หรือ path ของ `Luffy.rbxmx` ใน AssetKit ตาม Repo)
- `src/Track2_TowerSystem/Animations/Luffy.luau`
- `src/Track2_TowerSystem/VFX/LuffyVFX.luau`
- `tests/characters/luffy_anim_vfx.spec.luau`

ภารกิจ:
Implement การปรับปรุงโมเดล Luffy Gear 5, Joint Mapping (`RootJoint`, `Neck`, `RightShoulder`, `LeftShoulder`, `RightHip`, `LeftHip`), Signature Animations (Gear 5 Bouncy Joyboy Idle, Stretch Punch Wind-up/Attack/Impact/Recovery, Bajrang Fist Ultimate, Spawn/Deploy, Special Idle) และ Gear 5 Cloud Collar / Red-Black Conqueror Haki Lightning VFX ตามข้อกำหนดใน `01-luffy.md` ทุกประการ พร้อมตรวจสอบใน Animation Lab UI
```

#### Prompt สำหรับ Developer 2 — Zoro King of Hell (`AGY-Char-Zoro`)
```text
ROLE: คุณคือ AGY-Char-Zoro (Technical Animator & VFX Engineer รับผิดชอบ Zoro King of Hell)
BRANCH: `feat/phase5-char-zoro` (แตกจาก `feat/phase5-core-contracts-and-lab`)
WORKTREE: `../wt-phase5-zoro`

ให้อ่านไฟล์ต่อไปนี้ก่อนเริ่มงาน:
1. `AGENTS.md`, `docs/CONVENTIONS.md`
2. `docs/implementation-plans/0005-character-model-animation/PLAN.md`
3. `docs/implementation-plans/0005-character-model-animation/characters/02-zoro.md`
4. `src/Shared/AnimationContract.luau` และ `src/Shared/VFXContract.luau`

OWNED FILES ONLY (ห้ามแตะไฟล์อื่นนอกเหนือจากนี้เด็ดขาด):
- `assets/Heroes/Zoro.rbxmx` (หรือ path ของ `Zoro.rbxmx` ใน AssetKit ตาม Repo)
- `src/Track2_TowerSystem/Animations/Zoro.luau`
- `src/Track2_TowerSystem/VFX/ZoroVFX.luau`
- `tests/characters/zoro_anim_vfx.spec.luau`

ภารกิจ:
Implement การปรับปรุงโมเดล Zoro King of Hell, Sword Rigging ทั้ง 3 เล่ม (`WadoIchimonji` คาบที่ปากติดกับ `Head`, `Enma` มือขวาติดกับ `RightArm`, `SandaiKitetsu` มือซ้ายติดกับ `LeftArm` + ฝักดาบข้างเอวติดกับ `Torso`), Signature Animations (Three-Sword Guard Idle, Santoryu Slash Wind-up/Attack/Impact/Recovery, King of Hell 103 Mercies Dragon Damnation Ultimate, Spawn/Deploy) และ Green/Purple-Gold Enma Haki Flame + Crescent Slash Trails ตาม `02-zoro.md` ทุกประการ
```

#### Prompt สำหรับ Developer 3 — Ace Flame Emperor (`AGY-Char-Ace`)
```text
ROLE: คุณคือ AGY-Char-Ace (Technical Animator & VFX Engineer รับผิดชอบ Ace Flame Emperor)
BRANCH: `feat/phase5-char-ace` (แตกจาก `feat/phase5-core-contracts-and-lab`)
WORKTREE: `../wt-phase5-ace`

ให้อ่านไฟล์ต่อไปนี้ก่อนเริ่มงาน:
1. `AGENTS.md`, `docs/CONVENTIONS.md`
2. `docs/implementation-plans/0005-character-model-animation/PLAN.md`
3. `docs/implementation-plans/0005-character-model-animation/characters/03-ace.md`
4. `src/Shared/AnimationContract.luau` และ `src/Shared/VFXContract.luau`

OWNED FILES ONLY (ห้ามแตะไฟล์อื่นนอกเหนือจากนี้เด็ดขาด):
- `assets/Heroes/Ace.rbxmx` (หรือ path ของ `Ace.rbxmx` ใน AssetKit ตาม Repo)
- `src/Track2_TowerSystem/Animations/Ace.luau`
- `src/Track2_TowerSystem/VFX/AceVFX.luau`
- `tests/characters/ace_anim_vfx.spec.luau`

ภารกิจ:
Implement การปรับปรุงโมเดล Ace Flame Emperor, Joint Mapping + Accessories (หมวกคาวบอย, สร้อยลูกปัดแดง, มีดสั้น, รอยสัก ASCE), Signature Animations (Logia Flame Finger-Ignite Idle, Fire Charge Wind-up, Hiken Fire Fist Attack/Impact/Recovery, Dai Enkai: Entei Giant Sunball Ultimate, Flame Pillar Spawn) และ Solar Flame Particles / Fire Beam / Scorch Ring Impact VFX ตาม `03-ace.md` ทุกประการ
```

---

### 0.5 Prompt เริ่มต้นที่ 6: สำหรับ Codex — Independent Reviewer & Gatekeeper

```text
ROLE: คุณคือ Codex (Controller & Independent Reviewer) ตามกฎ Separation of Duties ของ `AGENTS.md`
ภารกิจของคุณคือตรวจสอบงานของ Implementer (`AGY`) เทียบกับ `docs/implementation-plans/0005-character-model-animation/PLAN.md` และไฟล์สเปกย่อยทั้ง 4 ไฟล์

เกณฑ์การตรวจรับ (REVIEWER GATES):
1. Git Diff Ownership Check: ตรวจสอบด้วย `git diff --name-only` ว่าไม่มี Developer คนใดแก้ไขไฟล์นอกเหนือจากตาราง Ownership Matrix
2. Rigging & Physics Audit: ยืนยันว่าไม่มี `WeldConstraint` ผูกทับ `BasePart` ที่ถูกควบคุมด้วย `Motor6D` และชิ้นส่วนแขน/ขา/หัว/อาวุธทุกชิ้นมี `Anchored = false`, `CanCollide = false`, `CanQuery = false`, `CanTouch = false`, `Massless = true`
3. Combat Decoupling Audit: ยืนยันว่า Visual Callbacks / VFX Events ไม่มีการเรียกฟังก์ชันลด HP ศัตรูโดยตรง และเมื่อสั่งปิด VFX ทั้งหมด ระบบ Damage ใน `TowerController` ยังคงทำงานตรงเวลา 100%
4. Memory & Instance Leak Audit: ยืนยันว่าเมื่อ Tower ถูก Sell/Destroy หรือเมื่อกด Reset ใน Animation Lab จะไม่มี `Tween`, `RunService` connection, หรือ VFX Part ค้างในหน่วยความจำ
5. Verification Honesty Check: แยกผลลัพธ์อย่างชัดเจนระหว่าง Static Code Inspection, Automated Tests, Roblox Studio Runtime Tests และ Manual Visual Verification หากส่วนใดยังไม่ได้เปิดทดสอบใน Roblox Studio จริง ต้องระบุสถานะเป็น `NOT VERIFIED` เท่านั้น ห้ามอนุมัติผ่านหากมีการปลอมแปลงผลทดสอบ
```

---

## PART 1 — CURRENT STATE AUDIT (การตรวจสอบสถาปัตยกรรมและสถานะปัจจุบัน)

> **หมายเหตุความโปร่งใสด้านหลักฐาน (Verification Transparency Statement):**
> รายงานส่วนนี้แยกแยะอย่างชัดเจนระหว่าง:
> 1. **Architectural & Implementation Audit** จากข้อเท็จจริงของโครงสร้างโปรเจกต์ที่ Baseline Commit `d5d06216b2f8bc6ba43071d453709e0d3e0e8df4` (`AGENTS.md`, `docs/*`, `src/Shared/GameConfig.luau`, `src/Track2_TowerSystem/TowerController.server.luau`, `src/AssetKit/VisualBridge.server.luau`, `src/Track1_WaveSystem/WaveManager.server.luau`, `default.project.json`)
> 2. **Roblox Studio Runtime Tests & Manual Visual Verification:** สถานะปัจจุบันคือ **`NOT VERIFIED`** (เนื่องจากรอบนี้เป็นรอบ Analysis + Planning ก่อนเริ่ม Implement และยังไม่ได้เปิดรันใน Roblox Studio จริง)

### 1.1 ระบบปัจจุบันทำงานอย่างไร (8 แกนหลักของระบบใน Phase 4 Baseline)

| ลำดับ | ระบบ (Subsystem) | ไฟล์หลักที่รับผิดชอบ (Source Paths) | กลไกการทำงานปัจจุบันใน Phase 4 (Baseline `d5d06216...`) | สถานะการตรวจสอบ |
| :--- | :--- | :--- | :--- | :--- |
| **1** | **Model Loading & AssetKit** | `src/AssetKit/VisualBridge.server.luau`<br>`default.project.json`<br>`assets/` (19 `.rbxmx` models) | โมเดลทั้ง 19 ชิ้น (Heroes 12, Enemies 4, Map Assets 3) ถูกสร้างเป็น Part-based `.rbxmx` models และซิงค์เข้า Roblox Studio ผ่าน Rojo (`default.project.json`) โดยมี `VisualBridge.server.luau` ทำหน้าที่ค้นหา Template Model แล้ว Clone มาสวมทับ (Visual Binding) ให้กับ Entity ของ Tower, Enemy และ Map Pad | Static Audit Complete / Studio Runtime: `NOT VERIFIED` |
| **2** | **Rigging, Motor6D & WeldConstraint** | `src/AssetKit/VisualBridge.server.luau`<br>`src/Track2_TowerSystem/TowerController.server.luau` | **พบจุดขัดแย้งเชิงโครงสร้าง (Critical Conflict):** `VisualBridge.server.luau` ทำการผูกชิ้นส่วนย่อย (`BasePart`) ของโมเดลเข้ากับ RootPart/PrimaryPart ด้วย `WeldConstraint` (และ/หรือตั้งค่า `Anchored`) เพื่อให้โมเดลไม่หลุดเป็นชิ้นๆ ตอนเคลื่อนย้าย ในขณะที่ `TowerController.server.luau` มีฟังก์ชัน Runtime Rigging ที่พยายามสร้างหรือค้นหา `Motor6D` เพื่อขยับแขน/ขา/ลำตัวในจังหวะ Idle และ Attack | **Confirmed Root-Cause Defect** (ดูวิเคราะห์เชิงลึกในหัวข้อ 1.2) |
| **3** | **Idle Animation & 5-Phase Attack Animation** | `src/Track2_TowerSystem/TowerController.server.luau` | ใช้ระบบ **Procedural CFrame / Tween Animation** ภายใน `TowerController.server.luau` แบ่งจังหวะเป็น `Idle` (หายใจ/ขยับขึ้นลงเบาๆ) และ 5-Phase Attack Cycle (`Wind-up -> Attack -> Impact -> Recovery -> return to Idle`) แต่ลอจิกท่าทางยังฝังรวมอยู่กับ Controller กลางและใช้รูปแบบท่าทางกึ่ง Generic ที่ปรับแค่พารามิเตอร์/สี | Static Audit Complete / Studio Runtime: `NOT VERIFIED` |
| **4** | **Character-Specific VFX** | `src/Track2_TowerSystem/TowerController.server.luau`<br>`src/Shared/GameConfig.luau` | สร้าง Part/Particle/Highlight/Tween แบบ Runtime ในจังหวะโจมตีโดยอ้างอิงค่าสีและสไตล์จาก `GameConfig.luau` และตารางตั้งค่าใน `TowerController` แต่ยังไม่ได้แยกเป็นโมดูลรายตัวละคร (`VFX/<HeroId>VFX.luau`) และยังขาดการคุม Pool/Cap ของ Instance เมื่อวาง Tower จำนวนมาก | Static Audit Complete / Studio Runtime: `NOT VERIFIED` |
| **5** | **Combat & Damage Timing** | `src/Track2_TowerSystem/TowerController.server.luau`<br>`src/Track1_WaveSystem/WaveManager.server.luau` | `TowerController` คำนวณ Cooldown, ค้นหาเป้าหมายจากศัตรูที่ดูแลโดย `WaveManager`, และเรียกจังหวะ Damage สัมพันธ์กับเฟสการโจมตี อย่างไรก็ตาม การผูกจังหวะ Visual Tween เข้ากับ Combat Loop ในไฟล์เดียวกันมีความเสี่ยงที่หาก Animation ถูก Cancel หรือ Retarget กลางคัน จะเกิดอาการ Tween ซ้อนหรือจังหวะ Impact คลาดเคลื่อน | Static Audit Complete |
| **6** | **Model Lifecycle, Cleanup & Memory Management** | `src/Track2_TowerSystem/TowerController.server.luau`<br>`src/AssetKit/VisualBridge.server.luau` | เมื่อ Tower ถูกขาย (Sell) หรือลบออก ระบบเรียก `:Destroy()` ที่ตัว Model/Tower instance แต่ Tween ที่กำลังเล่นค้างอยู่, `task.delay` / `task.spawn` ของ 5-Phase Attack, หรือ VFX Part ที่สร้างแยกไว้ใน `Workspace` มีโอกาสค้าง (Orphaned Instances / Memory Leak) หากไม่มี `Maid` / `Janitor` หรือ Token ยกเลิกสถานะต่อตัวละคร | Static Audit Complete |
| **7** | **Rojo Synchronization** | `default.project.json` | แมปโฟลเดอร์ `src/Shared` ไปยัง `ReplicatedStorage`, และแมป Server tracks (`Track1_WaveSystem`, `Track2_TowerSystem`, `AssetKit`, ฯลฯ) เข้าสู่ `ServerScriptService` พร้อมเชื่อมต่อโฟลเดอร์ AssetKit Models เข้าสู่โครงสร้างเกม | Static Audit Complete |
| **8** | **Automated Tests & Studio Testing** | `tests/` | มีชุดทดสอบสำหรับตรวจสอบ Config, โครงสร้างโมดูล และลอจิกพื้นฐานของระบบจาก Phase 1–4 แต่ยังไม่มี Automated Test ที่ตรวจสอบ **Effective Rig Mobility** (ตรวจว่าหลังผ่าน `VisualBridge` + `TowerController` แล้ว `Motor6D` สามารถเปลี่ยน `CFrame` ของแขน/ขาได้จริงโดยไม่ติด `WeldConstraint` หรือ `Anchored = true`) | Static Audit Complete |

---

### 1.2 การวิเคราะห์เชิงลึก: ทำไมโครงสร้างปัจจุบัน (Part-based Model + VisualBridge Weld + TowerController Runtime Rigging) จึงทำให้โมเดลขยับไม่ถูกต้องหรือเกิด Rig ซ้ำ?

นี่คือประเด็นทางเทคนิคที่สำคัญที่สุดของ Phase 5 ซึ่งตรวจสอบพบจากความสัมพันธ์ระหว่าง `src/AssetKit/VisualBridge.server.luau` และ `src/Track2_TowerSystem/TowerController.server.luau`:

#### 1. กลไกการชนกันของ `WeldConstraint` กับ `Motor6D` ใน Roblox Engine
ในเอ็นจิ้นฟิสิกส์ของ Roblox (`Workspace` Assembly Solver):
- เมื่อโมเดล `.rbxmx` ใน AssetKit เป็น **Part-based Model** (ประกอบด้วย `Part` / `MeshPart` หลายชิ้น เช่น `Torso`/`HumanoidRootPart`, `Head`, `LeftArm`, `RightArm`, `LeftLeg`, `RightLeg`, และชิ้นส่วน Accessories เช่น หมวกฟาง, ดาบ, ผ้าคลุม)
- **`VisualBridge.server.luau`** มีขั้นตอนการเตรียมโมเดล (Model Sanitization / Binding) โดยวนลูป `GetDescendants()` แล้วตั้งค่า `BasePart` และสร้าง `WeldConstraint` ยึดทุก Part เข้ากับ `PrimaryPart` (หรือ `RootPart`) เพื่อป้องกันไม่ให้ชิ้นส่วนร่วงหล่นเมื่อ `Anchored = false` หรือตั้งค่า `Anchored = true` ทั้งโมเดลเพื่อตรึงอยู่บนแท่น Tower
- ต่อมา **`TowerController.server.luau`** ทำการ **Runtime Rigging** โดยสร้าง `Motor6D` ระหว่าง `RootPart`/`Torso` กับชิ้นส่วนแขน ขา และศีรษะ แล้วพยายามขับเคลื่อน `Motor6D.C0` / `Motor6D.Transform` ด้วย `TweenService` หรือ `RunService.Heartbeat`

**ผลลัพธ์ที่เกิดขึ้นจริงใน Runtime (3 อาการหลัก):**
1. **อาการที่ 1 — Rigid Constraint Override (`WeldConstraint` ล็อกทับ `Motor6D`):**
   หากระหว่าง `Torso` (Part0) กับ `RightArm` (Part1) มีทั้ง `WeldConstraint` (ที่สร้างโดย `VisualBridge` ผูก `RightArm` เข้ากับ `RootPart`) และ `Motor6D` (ที่สร้างโดย `TowerController` ผูก `RightArm` เข้ากับ `Torso`) อยู่ใน Assembly เดียวกัน ตัว Solver ของ Roblox จะบังคับให้ `WeldConstraint` รักษา Relative CFrame คงที่ตามจังหวะที่สร้าง Weld ส่งผลให้แม้ `TowerController` จะ Tween ค่า `Motor6D.C0` จนตัวเลขเปลี่ยนใน Properties แต่ **แขนของตัวละครในจอจะไม่ขยับเลย** หรือขยับได้เฉพาะกรณีที่ทั้งโมเดลเอียงไปพร้อมกันทั้งก้อน!
2. **อาการที่ 2 — Anchored Limb Paralysis (`Anchored = true` ที่ชิ้นส่วนลูก):**
   ใน Roblox หาก `BasePart` ที่เป็นปลายทางของ `Motor6D` (`Part1`, เช่น `RightArm`, `Head`, `Sword`) มีค่า `Anchored = true` ระบบ Joint ของ Roblox จะ **ไม่อัปเดตตำแหน่งของ `Part1` ตาม `Motor6D.C0`/`Transform` เด็ดขาด** เพราะ Engine ถือว่า Part ที่ Anchored ถูกล็อกพิกัดกับ World Space (`Workspace`) มีเพียง `RootPart` (`PrimaryPart` / `HumanoidRootPart`) ชิ้นเดียวเท่านั้นที่สามารถมี `Anchored = true` ได้ ส่วนอวัยวะและ Accessories ทุกชิ้นที่ต่อด้วย `Motor6D` หรือ `WeldConstraint` ลูกโซ่ ต้องตั้งค่า `Anchored = false`, `CanCollide = false`, `CanTouch = false`, `CanQuery = false`, `Massless = true` เท่านั้น!
3. **อาการที่ 3 — Flat Hierarchy Welding ทำให้ Accessories ไม่ขยับตามอวัยวะ:**
   เมื่อ `VisualBridge` กวาดทุก `BasePart` ในโมเดลมา Weld เข้ากับ `RootPart` โดยตรง (Flat Star Topology) แทนที่จะแยกตามลำดับชั้นของร่างกาย (Hierarchical Tree Topology):
   - หมวกฟางของ Luffy หรือหมวกคาวบอยของ Ace หรือดาบ `WadoIchimonji` ที่คาบปากของ Zoro จะถูกยึดติดกับ `RootPart` แทนที่จะยึดติดกับ `Head`
   - ดาบ `Enma` และ `SandaiKitetsu` ของ Zoro จะถูกยึดติดกับ `RootPart` แทนที่จะยึดติดกับ `RightArm` และ `LeftArm`
   - ผลคือเมื่อ `Head` หัน หรือ `RightArm` ฟันดาบ ตัวดาบหรือหมวกจะลอยค้างอยู่ที่เดิมกลางลำตัว!

#### 2. ตารางเปรียบเทียบโครงสร้างเดิม (Phase 4) vs โครงสร้างที่ต้องแก้ไขใน Phase 5

| มิติการตรวจสอบ | โครงสร้างปัจจุบัน (Phase 4 Baseline) | ปัญหาที่เกิดขึ้นจริง | แนวทางแก้ไขใน Phase 5 (ควรแก้ที่ระดับใด) |
| :--- | :--- | :--- | :--- |
| **การตั้งค่า `Anchored`** | หลายชิ้นส่วนใน `.rbxmx` หรือใน `VisualBridge` ถูกตั้ง `Anchored = true` ทั้งโมเดล | `Motor6D` ไม่สามารถขยับ `Part1` ที่มี `Anchored = true` ได้ | **แก้ที่ระดับ `AnimationController.RigBuilder` + `VisualBridge`:** กำหนดให้เฉพาะ `PrimaryPart` (`HumanoidRootPart` / `RootPart`) เท่านั้นที่มี `Anchored = true` (สำหรับ Tower) ส่วน `BasePart` อื่นทุกชิ้นต้องเป็น `Anchored = false`, `Massless = true`, `CanCollide = false` |
| **การสร้าง `WeldConstraint` vs `Motor6D`** | `VisualBridge` สร้าง `WeldConstraint` ยึดทุก Part เข้ากับ Root แล้ว `TowerController` มาสร้าง `Motor6D` ซ้ำทีหลัง | เกิด Double-Joint Conflict (`WeldConstraint` ล็อกทับ `Motor6D`) | **แก้ที่ระดับ `VisualBridge` + `AnimationController`:** แยกบทบาทชัดเจน — หากโมเดลเป็น Articulated Character (Hero/Enemy), `VisualBridge` จะไม่ทำ Flat-Weld ทับอวัยวะหลัก แต่จะส่งต่อให้ `RigBuilder` สร้าง `Motor6D` สำหรับข้อต่อหลัก (Root, Neck, Shoulders, Hips, Weapon Joints) และใช้ `WeldConstraint` เฉพาะการยึด Accessories เข้ากับ **Parent Limb ที่ถูกต้อง** (เช่น หมวก Weld เข้า `Head`, ดาบมือขวา Weld/Motor6D เข้า `RightArm`) |
| **การเก็บตำแหน่งท่าตั้งต้น (`RestPose` / `C0`, `C1`)** | คำนวณ CFrame แบบสดตอน Runtime โดยไม่มีการแคช `DefaultC0` / `DefaultC1` มาตรฐาน | เมื่อสลับท่าเร็วๆ หรือ Cancel ท่า โมเดลจะบิดเบี้ยวสะสม (CFrame Drift) | **แก้ที่ระดับ `AnimationController`:** บันทึก `OriginalC0` และ `OriginalC1` ลงใน `Attribute` หรือ Rig State Table ทันทีตอนสร้าง `Motor6D` ครั้งแรก และทุก Pose ใน `Animations/<Hero>.luau` จะคำนวณเป็น `OriginalC0 * OffsetCFrame` เสมอ (Zero Drift Guarantee) |

---

### 1.3 สิ่งที่นำกลับมาใช้ต่อได้ (Reusable Assets & Systems from Phase 4)

เพื่อปฏิบัติตามกฎเหล็ก **"ห้ามลบหรือ Rewrite ระบบ Phase 4 โดยไม่มีเหตุผลทางเทคนิคที่ตรวจสอบได้"**:
1. **`src/Shared/GameConfig.luau`:** นำข้อมูล Stats ของ Tower ทั้ง 12 ตัว, ค่า Cost, Upgrade Tiers, Range, Damage, Cooldown และ Theme Colors กลับมาใช้ได้ทั้งหมด 100% โดยไม่แตะต้องค่าสมดุลเกม
2. **`src/Track1_WaveSystem/WaveManager.server.luau`:** ระบบปล่อยศัตรู, การเดินตาม Path, เลือดศัตรู และระบบ Wave นำกลับมาใช้ได้ 100% โดยไม่ต้องแก้ไข
3. **`src/Track2_TowerSystem/TowerController.server.luau` (Core Combat Loop):** ระบบการวาง Tower บน `PlacementPadTemplate`, การอัปเกรด, การขายคืน, การค้นหาเป้าหมาย (Target Acquisition), และการคำนวณเวลา Cooldown / การทำ Damage จริง นำกลับมาใช้ต่อทั้งหมด เพียงแค่เปลี่ยนจุดที่เคยเขียนโค้ด Rigging/Tween/VFX ยาวๆ ในไฟล์เดียว ให้เรียกผ่าน Hook ของ `AnimationController` และ `VFXDispatcher` แทน
4. **AssetKit `.rbxmx` Models (ทั้ง 19 ไฟล์):** โมเดลที่มีอยู่แล้วถูกนำมาปรับปรุงโครงสร้าง Part/Pivot/Hierarchy และเพิ่มรายละเอียดเฉพาะตัว (Iterative Refinement) สำหรับ Luffy, Zoro, Ace โดยไม่ต้องปั้นใหม่จากศูนย์ทั้งหมด และโมเดลอีก 9 Heroes + 4 Enemies + 3 Map Assets ยังคงทำงานผ่าน Fallback Rigging ได้ทันทีโดยไม่พัง

---

### 1.4 จุดอ่อน ข้อบกพร่อง และ Technical Debt ที่พบในปัจจุบัน

1. **TD-01 (High — Rigging Conflict):** การมีอยู่พร้อมกันของ `WeldConstraint` ใน `VisualBridge.server.luau` และ Runtime `Motor6D` ใน `TowerController.server.luau` ทำให้การขยับแขน/ขาถูกบล็อกหรือเกิดพฤติกรรมไม่แน่นอน
2. **TD-02 (High — Monolithic TowerController):** `TowerController.server.luau` แบกทั้งหน้าที่ Combat State, Targeting, Damage Application, Runtime Rigging, 5-Phase Procedural Animation และ VFX Spawning ไว้ในไฟล์เดียว หากนักพัฒนา 3 คนแก้ไฟล์นี้พร้อมกันเพื่อทำท่าของ Luffy, Zoro, Ace จะเกิด Git Merge Conflict 100%
3. **TD-03 (Medium — Tightly Coupled Visual & Damage Timing):** จังหวะการสร้าง VFX และการ Tween ผูกติดกับลูปการโจมตีโดยไม่มี State Machine ที่รองรับการ Cancel / Interrupt อย่างปลอดภัย
4. **TD-04 (Medium — Unbounded VFX & Tween Lifecycle):** การสร้าง Part สำหรับเอฟเฟกต์และ `TweenService:Create()` แบบกระจัดกระจายโดยไม่มีตัวนับ (`ActiveVFXCount`, `ActiveTweenCount`) และไม่มี Pool/Janitor ต่อตัวละคร เสี่ยงต่ออาการ FPS ตกเมื่อผู้เล่นวาง Tower 15–30 ตัวพร้อมกัน
5. **TD-05 (Medium — Lack of Visual Inspection Tooling):** นักพัฒนาต้องกดเข้าเกม รอเงิน รอวาง Tower และรอ Wave ศัตรูเดินมาเพื่อดูท่าโจมตีเพียงครั้งเดียว ทำให้การจูนมุม `CFrame` ของดาบ Zoro หรือหมัดยืดของ Luffy ใช้เวลานานมาก จึงจำเป็นต้องมี **Animation Lab UI**

---

## PART 2 — PHASE 5 ARCHITECTURE (สถาปัตยกรรมใหม่สำหรับ Phase 5)

### 2.1 โครงสร้างโมดูลที่นำเสนอ (Proposed Modular Directory Structure)

เพื่อรักษากฎ **Modular Zero-Conflict Architecture** ตาม `AGENTS.md` และป้องกัน Circular Dependency เราจึงแยกชั้นของ **Shared Contracts (`src/Shared`)**, **Execution & Character Modules (`src/Track2_TowerSystem`)**, และ **Developer Tooling (`src/DevTools`)** ออกจากกันอย่างเด็ดขาด:

```text
src/
├── Shared/
│   ├── GameConfig.luau                  # (มีอยู่แล้ว - ห้ามแก้สมดุลเกม)
│   ├── AnimationContract.luau           # [NEW - Core Owner] Types, State Enums, Rig Schema, Timeline Schema
│   └── VFXContract.luau                 # [NEW - Core Owner] VFX Event Types, Quality Presets, Emitter Budgets
│
├── AssetKit/
│   └── VisualBridge.server.luau         # [MODIFIED - Core Owner] ปรับให้เรียก RigSanitizer แทนการ Flat-Weld ทับ Motor6D
│
├── Track2_TowerSystem/
│   ├── TowerController.server.luau      # [MODIFIED - Core Owner] เรียก AnimationController & VFXDispatcher (Combat แยกจาก Visual 100%)
│   ├── AnimationController.luau         # [NEW - Core Owner] Runtime RigBuilder, Procedural Keyframe Player, State Machine, Cleanup
│   ├── AnimationRegistry.luau           # [NEW - Core Owner] โหลดโมดูลใน Animations/* แบบ pcall + Default Fallback Profile
│   ├── VFXDispatcher.luau               # [NEW - Core Owner] ตัวกลางสั่งเล่น VFX, จัดการ Quality Preset, Instance Cap, Janitor Cleanup
│   ├── Animations/
│   │   ├── _FallbackProfile.luau        # [NEW - Core Owner] ท่ามาตรฐานสำหรับอีก 9 Heroes & 4 Enemies ที่ยังอยู่ใน Backlog
│   │   ├── Luffy.luau                   # [NEW - Dev 1 Owner ONLY] Signature Poses & 5-Phase + Ultimate Timeline ของ Luffy Gear 5
│   │   ├── Zoro.luau                    # [NEW - Dev 2 Owner ONLY] Signature Poses & 3-Sword Rig + Ultimate Timeline ของ Zoro
│   │   └── Ace.luau                     # [NEW - Dev 3 Owner ONLY] Signature Poses & Flame Charge + Entei Timeline ของ Ace
│   └── VFX/
│       ├── _FallbackVFX.luau            # [NEW - Core Owner] เอฟเฟกต์มาตรฐานสำหรับตัวละครใน Backlog
│       ├── LuffyVFX.luau                # [NEW - Dev 1 Owner ONLY] Gear 5 Cloud Collar, Conqueror Haki Lightning, Bajrang Impact
│       ├── ZoroVFX.luau                 # [NEW - Dev 2 Owner ONLY] Enma Green/Purple-Gold Flame, 3-Sword Slash Arcs, King of Hell Aura
│       └── AceVFX.luau                  # [NEW - Dev 3 Owner ONLY] Mera Mera Finger Flame, Hiken Fire Fist Projectile, Entei Sun Sphere
│
└── DevTools/
    └── AnimationLab/
        ├── AnimationLabBootstrap.server.luau # [NEW - Core Owner] ตรวจ RunService:IsStudio() ก่อนสร้าง UI/Sandbox
        ├── LabConfig.luau                    # [NEW - Core Owner] รายชื่อ 19 Assets (12 Heroes, 4 Enemies, 3 Map Assets) และเกณฑ์ Budget
        ├── ModelValidator.luau               # [NEW - Core Owner] ตรวจไฟล์โมเดล, Hierarchy, Motor6D, Weld, Part Count จริง
        ├── SandboxStageManager.luau          # [NEW - Core Owner] จัดการแท่นทดสอบใน Workspace.AnimationLabSandbox + Dummy Target
        ├── TelemetryCollector.luau           # [NEW - Core Owner] วัด Frame Time, Part/Motor6D/Weld/Particle/Tween Count แบบ Real-time
        ├── StressTestRunner.luau             # [NEW - Core Owner] รันโหมด 1 / 10 / 25 / 50 Active Characters & Leak Test
        └── UI/
            ├── LabMainView.luau              # [NEW - Core Owner] หน้าต่างหลักของ Animation Lab Dashboard
            ├── ModelExplorerPanel.luau       # [NEW - Core Owner] Sidebar แสดง 19 Models พร้อม Badge สถานะจริง
            ├── ViewportStagePanel.luau       # [NEW - Core Owner] ควบคุมทั้ง ViewportFrame และ Workspace Sandbox Camera
            ├── AnimationPlayerPanel.luau     # [NEW - Core Owner] ปุ่ม Play/Pause/Stop/Speed/Step + Timeline Bar 5 เฟส
            ├── VFXInspectorPanel.luau        # [NEW - Core Owner] ปุ่มยิง VFX, Toggle รายเลเยอร์, Intensity Slider, Quality Preset
            └── DebugInspectorPanel.luau      # [NEW - Core Owner] แสดงตัวเลข Real-Time Debug & Performance Counters
```

---

### 2.2 การป้องกัน God Object และ Circular Dependency (Dependency Direction Rule)

กฎการ `require()` เป็นแบบ **One-Way Directed Acyclic Graph (DAG)** เท่านั้น:

```text
[TowerController.server] ──┬──> [AnimationController] ──> [AnimationRegistry] ──> [Animations/Luffy, Zoro, Ace]
                           │                                                              │
                           └──> [VFXDispatcher] ────────> [VFX/LuffyVFX, ZoroVFX, AceVFX] │
                                       │                                                  ▼
                                       └──────────────────────────> [Shared/AnimationContract & VFXContract]
```

- **ห้าม** `Animations/<Hero>.luau` หรือ `VFX/<Hero>VFX.luau` ทำการ `require(TowerController)` หรือ `require(WaveManager)` เด็ดขาด
- **ห้าม** `VFX/<Hero>VFX.luau` เรียกใช้ฟังก์ชันทำดาเมจหรือแก้ไขค่า HP ของศัตรู
- **ทำไมต้องแยก `Animations/<Hero>.luau` ออกจาก `VFX/<Hero>VFX.luau`?**
  1. เพื่อให้ **Animation Player** ใน Animation Lab สามารถเปิดทดสอบเฉพาะการขยับข้อต่อ (`Motor6D`) แบบเพียวๆ โดยปิด VFX ได้ 100%
  2. เพื่อให้ **VFX Inspector** สามารถยิงทดสอบเฉพาะเอฟเฟกต์ (`Trigger Attack VFX`, `Trigger Ultimate VFX`) บนหุ่นนิ่งหรือ Dummy Target ได้โดยไม่ต้องรอเล่นท่าครบลูป
  3. ป้องกันไม่ให้ไฟล์ใดไฟล์หนึ่งกลายเป็น God Object ที่มีทั้งตาราง CFrame 400 บรรทัดและโค้ดสร้าง Particle อีก 400 บรรทัดปนกัน

---

### 2.3 Shared Contracts (`AnimationContract.luau` & `VFXContract.luau`)

> **ผู้รับผิดชอบเพียงคนเดียว (Single Owner):** `AGY-Core` เท่านั้น ห้าม Developer 1, 2, 3 แก้ไขไฟล์ Contract นี้โดยพลการ

#### 2.3.1 `src/Shared/AnimationContract.luau`
```luau
--!strict
-- src/Shared/AnimationContract.luau
-- Single Source of Truth สำหรับโครงสร้าง Rig, Animation States และ Timeline ของ Phase 5

export type AnimationState =
	"Idle"
	| "SpecialIdle"
	| "Spawn"
	| "Windup"
	| "Attack"
	| "Impact"
	| "Recovery"
	| "Ultimate"

export type JointName =
	"RootJoint"      -- PrimaryPart (HumanoidRootPart) -> Torso / UpperTorso
	| "Neck"         -- Torso -> Head
	| "RightShoulder"-- Torso -> RightArm
	| "LeftShoulder" -- Torso -> LeftArm
	| "RightHip"     -- Torso -> RightLeg
	| "LeftHip"      -- Torso -> LeftLeg
	| "WeaponRight"  -- RightArm -> Right Hand Weapon (เช่น Enma)
	| "WeaponLeft"   -- LeftArm -> Left Hand Weapon (เช่น Sandai Kitetsu)
	| "WeaponMouth"  -- Head -> Mouth Weapon (เช่น Wado Ichimonji)

export type JointPoseMap = {
	[JointName]: CFrame, -- ค่า Offset CFrame ที่จะนำไปคูณต่อท้าย BaseC0 (RestPoseC0 * OffsetCFrame)
}

export type ProceduralKeyframe = {
	alpha: number, -- 0.0 ถึง 1.0 ของ State หรือของ Timeline
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	poses: JointPoseMap,
	vfxCue: string?, -- ชื่อ Cue สำหรับส่งสัญญาณให้ VFXDispatcher (เป็นแค่ Visual Trigger ไม่เกี่ยวกับ Damage!)
	scaleMultiplier: Vector3?, -- สำหรับท่าขยายร่าง เช่น หมัดยักษ์ Gear 5 ของ Luffy
}

export type StateTrackDefinition = {
	state: AnimationState,
	duration: number, -- วินาทีพื้นฐาน (จะถูกปรับสเกลตาม AttackSpeed หรือ PlaybackSpeed ใน Lab)
	looped: boolean,
	canCancel: boolean,
	keyframes: { ProceduralKeyframe },
}

export typeAttackCycleTimings = {
	windupRatio: number,   -- เช่น 0.25 (25% ของรอบโจมตี)
	attackRatio: number,   -- เช่น 0.20 (20% ของรอบโจมตี)
	impactRatio: number,   -- เช่น 0.15 (15% ของรอบโจมตี - จังหวะที่ VFX Impact ทำงาน)
	recoveryRatio: number, -- เช่น 0.40 (40% ของรอบโจมตี)
}

export type AccessoryWeldRule = {
	accessoryNamePattern: string, -- ชื่อ Part หรือ Model ของ Accessory เช่น "StrawHat", "Scabbard", "CowboyHat"
	attachToLimb: "Head" | "Torso" | "RightArm" | "LeftArm" | "RightLeg" | "LeftLeg",
	offsetCFrame: CFrame?,
	useMotor6D: boolean?, -- true หากต้องการให้ขยับแยกจากแขนได้ (เช่น ดาบในมือ)
	jointName: JointName?,
}

export type CharacterAnimationProfile = {
	heroId: string,
	displayName: string,
	rigType: "Articulated6Joint" | "ArticulatedWeaponRig" | "StaticFallback",
	expectedJoints: { JointName },
	accessoryRules: { AccessoryWeldRule },
	baseScale: number,
	attackCycleTimings: typeAttackCycleTimings,
	states: {
		Idle: StateTrackDefinition,
		SpecialIdle: StateTrackDefinition?,
		Spawn: StateTrackDefinition?,
		Windup: StateTrackDefinition,
		Attack: StateTrackDefinition,
		Impact: StateTrackDefinition,
		Recovery: StateTrackDefinition,
		Ultimate: StateTrackDefinition?,
	},
}

export type RigContext = {
	model: Model,
	rootPart: BasePart,
	torso: BasePart?,
	limbs: { [string]: BasePart },
	motors: { [JointName]: Motor6D },
	baseC0: { [JointName]: CFrame },
	baseC1: { [JointName]: CFrame },
	activeState: AnimationState,
	playbackSpeed: number,
	isPaused: boolean,
	elapsedInState: number,
	cancelToken: number,
}

return table.freeze({
	STATES = {
		Idle = "Idle" :: AnimationState,
		SpecialIdle = "SpecialIdle" :: AnimationState,
		Spawn = "Spawn" :: AnimationState,
		Windup = "Windup" :: AnimationState,
		Attack = "Attack" :: AnimationState,
		Impact = "Impact" :: AnimationState,
		Recovery = "Recovery" :: AnimationState,
		Ultimate = "Ultimate" :: AnimationState,
	},
	ATTACK_SEQUENCE = { "Windup", "Attack", "Impact", "Recovery" },
})
```

#### 2.3.2 `src/Shared/VFXContract.luau`
```luau
--!strict
-- src/Shared/VFXContract.luau
-- Single Source of Truth สำหรับ Character-Specific VFX, Quality Presets และ Instance Budgets

export type VFXQualityPreset = "Low" | "Medium" | "High"

export type VFXCueType =
	"PassiveAura"
	| "SpawnDeploy"
	| "AttackWindup"
	| "AttackRelease"
	| "AttackImpact"
	| "UltimateCast"
	| "UltimateImpact"

export type VFXLayerFlags = {
	enableParticles: boolean,
	enableAura: boolean,
	enableTrailOrBeam: boolean,
	enableImpactEffect: boolean,
	enableCameraShake: boolean,
	enableScreenFlash: boolean,
}

export type VFXExecutionContext = {
	heroId: string,
	cueType: VFXCueType,
	sourceModel: Model,
	rootPart: BasePart,
	originCFrame: CFrame,
	targetPosition: Vector3,
	targetModel: Model?,
	intensity: number, -- 0.1 ถึง 2.0 (Default = 1.0)
	quality: VFXQualityPreset,
	layerFlags: VFXLayerFlags,
	sandboxContainer: Folder?, -- ถ้ารันใน Animation Lab จะใส่ไว้ใน Sandbox Folder เพื่อกวาดล้าง 100%
	registerInstance: (inst: Instance, ttlSeconds: number?) -> (),
	registerTween: (tween: Tween) -> (),
}

export type CharacterVFXModule = {
	heroId: string,
	maxConcurrentVFXInstances: number, -- เช่น 25 ชิ้นต่อ 1 ตัวละคร
	startPassiveAura: (ctx: VFXExecutionContext) -> (),
	stopPassiveAura: (sourceModel: Model) -> (),
	triggerCue: (ctx: VFXExecutionContext) -> (),
	cleanupAllForModel: (sourceModel: Model) -> (),
}

return table.freeze({
	QUALITY_MULTIPLIERS = {
		Low = { particleRate = 0.35, maxParts = 8, allowBeams = false, allowScreenFX = false },
		Medium = { particleRate = 0.70, maxParts = 16, allowBeams = true, allowScreenFX = false },
		High = { particleRate = 1.00, maxParts = 30, allowBeams = true, allowScreenFX = true },
	},
	DEFAULT_LAYER_FLAGS = {
		enableParticles = true,
		enableAura = true,
		enableTrailOrBeam = true,
		enableImpactEffect = true,
		enableCameraShake = true,
		enableScreenFlash = true,
	},
})
```

---

### 2.4 Runtime Integration & การแยก Visual ออกจาก Damage Logic อย่างเด็ดขาด

เพื่อให้มั่นใจว่า **Damage จะไม่ถูกเรียกซ้ำจาก Visual Event** และ **ระบบ Phase 4 เดิมยังคงทำงานได้ครบถ้วน**:

1. **Deterministic Server Combat Authority (`TowerController.server.luau`):**
   - เมื่อ Tower พร้อมโจมตี (`now - lastAttackTime >= cooldown`), `TowerController` เป็นผู้กำหนดเวลา `damageTimestamp = now + windupDuration + attackDuration`
   - `TowerController` เรียก `AnimationController:PlayAttackSequence(towerModel, targetPosition, totalCycleDuration)` และ `VFXDispatcher:TriggerSequence(...)` เป็น **Fire-and-Forget Visual Presentation**
   - การตัดเลือดศัตรู (`ApplyDamage`) ทำงานผ่าน Combat Timer ของ `TowerController` เอง **ไม่ได้ผูกอยู่ใน Callback ของ `Tween.Completed` หรือ `KeyframeReached` ของระบบภาพ**
   - ดังนั้น ต่อให้ผู้เล่นตั้งค่า VFX Quality = `Low`, ปิด VFX ทั้งหมด, หรือโมเดลเป็น Fallback Model ที่ไม่มี Animation พิเศษ ดาเมจก็จะออกตรงเวลาเดิมและออกเพียง **1 ครั้งต่อ 1 รอบโจมตีเสมอ**
2. **Compatibility กับ Phase 4 (100% Backward Compatible):**
   - ตัวละครอีก 9 ตัวที่ยังไม่ได้ทำ Signature Animation ในรอบแรก (`Nami`, `Usopp`, `Sanji`, `Chopper`, `Robin`, `Shanks`, `Whitebeard`, `Law`, `Kizaru`) และ Enemies ทั้ง 4 ตัว จะถูก `AnimationRegistry` ส่งไปใช้ `_FallbackProfile.luau` และ `_FallbackVFX.luau` อัตโนมัติ ซึ่งจำลอง 5-Phase Attack มาตรฐานจาก Phase 4 แต่ผ่านระบบ `RigBuilder` ใหม่ที่แก้บั๊ก `WeldConstraint` ทับ `Motor6D` แล้ว!

---

## PART 3 — ANIMATION LAB UI (การออกแบบระบบตรวจสอบ Model, Animation และ VFX)

### 3.1 การเปรียบเทียบสถาปัตยกรรม UI ทั้ง 3 ทางเลือก (UI Architecture Comparison)

| เกณฑ์การประเมิน | ทางเลือกที่ 1: Roblox Studio Plugin (`DockWidgetPluginGui`) | ทางเลือกที่ 2: In-Game Developer Test UI (เปิดได้เฉพาะใน Studio) | ทางเลือกที่ 3: Hybrid Architecture (Core In-Game Studio UI + Optional Studio Toolbar Hook) |
| :--- | :--- | :--- | :--- |
| **การทำงานร่วมกับ Rojo & Git Worktree** | ยุ่งยากกว่า เพราะต้อง Build หรือรันสคริปต์ติดตั้งลงโฟลเดอร์ `LocalPlugins` ของเครื่องนักพัฒนาแต่ละคน | **ง่ายและตรงกับโครงสร้าง Repo ที่สุด** ซิงค์ผ่าน `default.project.json` เข้าสู่เกมโดยตรง นักพัฒนาทั้ง 3 คนกด Play (`F5`) ใน Studio แล้วเปิดใช้ได้ทันที | ซิงค์โมดูลหลักผ่าน Rojo เหมือนทางเลือกที่ 2 แต่แยก Core Logic ให้เรียกได้ทั้งจากปุ่ม Hotkey ในโหมด Play (`F5`) และจาก Command Bar ในโหมด Edit |
| **ความแม่นยำในการทดสอบ Runtime Rig, Tween & VFX** | ในโหมด Edit (ไม่กด Play) บริการบางอย่างเช่น `RunService.Heartbeat`, ฟิสิกส์ของ `Trail`, และ Server Scripts ของเกมไม่ได้รันตามปกติ | **แม่นยำ 100%** เพราะทำงานภายใต้สภาวะ Runtime จริงของ Studio (`RunService:IsStudio() == true`) ทำให้ `ParticleEmitter:Emit()`, `Beam`, `Trail`, `TweenService`, และ `Motor6D` ทำงานเหมือนตอนเล่นจริงทุกประการ | **แม่นยำ 100%** ในโหมด Play (`F5`) และยังสามารถรัน `ModelValidator` แบบ Static ผ่าน Command Bar ในโหมด Edit ได้ด้วย |
| **การป้องกันผู้เล่นทั่วไปในเกมจริง (Security)** | ไม่ถูกส่งไปกับ Place ที่ Publish | ต้องครอบด้วย `if not RunService:IsStudio() then return end` ตั้งแต่ระดับ Server Bootstrap | ใช้ Server-side Studio Gate (`RunService:IsStudio()`) ร่วมกับการแยกโฟลเดอร์ `src/DevTools/AnimationLab` ที่จะ Self-Destroy ทันทีหากไม่ใช่ Studio |
| **ความสะดวกในการทำ Integration Test กับระบบ Tower จริง** | ยากมาก เพราะ Plugin แยก Context (`PluginSecurity`) ออกจาก ModuleScript ภายในเกมเมื่อรัน | **ดีเยี่ยม** เพราะสามารถสลับระหว่าง **Visual Sandbox Mode** และ **Controlled Integration Mode** ใน Session เดียวกันได้ทันที | **ดีเยี่ยมที่สุด** ได้ทั้งความง่ายในการซิงค์ผ่าน Rojo ของทางเลือกที่ 2 และแยกชั้น `ModelValidator` / `LabController` ให้เป็นอิสระจาก Gameplay UI |

#### ข้อสรุปแนวทางที่เลือก (Recommended Approach):
เลือก **ทางเลือกที่ 2 ผสานแนวคิด Modular ของทางเลือกที่ 3 (In-Game Studio-Only Developer Dashboard with Headless Validator Modules)** โดยวางไว้ที่ `src/DevTools/AnimationLab/` เพราะ:
1. โปรเจกต์นี้ใช้ **Rojo (`default.project.json`) + Git Worktree สำหรับ Developer 3 คน** การเก็บ Animation Lab ไว้ใน `src/DevTools/AnimationLab/` ทำให้นักพัฒนาทุกคนที่ `git checkout` เข้า Worktree ของตนเองและเปิด `rojo serve` สามารถกด `F5` (Play in Studio) แล้วกดปุ่มลัด **`F8`** (หรือปุ่ม `[🛠 Animation Lab]` มุมบนขวาเฉพาะใน Studio) เพื่อเปิดหน้าต่างตรวจสอบได้ทันทีโดยไม่ต้องติดตั้ง `.rbxm` Plugin แยกต่างหาก
2. รับประกันว่า `ParticleEmitter`, `Trail`, `Beam`, `PointLight`, `TweenService`, และ `Motor6D.C0` ทำงานใน Runtime Physics/Render Pipeline เดียวกับเกมจริง 100%

---

### 3.2 การเปรียบเทียบ `ViewportFrame` vs `Workspace Sandbox Stage` (ประเด็นสำคัญด้าน VFX!)

> **กฎเหล็กจากโจทย์:** *"ตรวจสอบความเหมาะสมของ ViewportFrame เทียบกับ Workspace Sandbox โดยเฉพาะ VFX ที่ใช้ Lighting, Particles, Camera Shake หรือบริการที่ทำงานไม่ครบใน ViewportFrame ห้ามสมมุติว่า VFX ทุกชนิดแสดงได้ถูกต้องใน ViewportFrame"*

#### ข้อเท็จจริงทางเทคนิคของ Roblox Engine:
ใน Roblox Engine ปัจจุบัน **`ViewportFrame` มีข้อจำกัดระดับ Engine ที่ไม่สามารถแสดงผล VFX ได้ครบ**:
1. **`ParticleEmitter` ไม่เรนเดอร์ใน `ViewportFrame`!** (ไฟของ Ace, ควันเมฆและสายฟ้าฮาคิของ Luffy, ออร่าไฟสีเขียวของ Zoro จะมองไม่เห็นเลยใน `ViewportFrame`)
2. **`Beam` และ `Trail` ไม่เรนเดอร์ (หรือไม่อัปเดตฟิสิกส์การลากเส้น) ใน `ViewportFrame`!** (รอยดาบ 3 เล่มของ Zoro และลำแสงไฟของ Ace จะไม่ปรากฏใน `ViewportFrame`)
3. **`PointLight` / `SpotLight` / `SurfaceLight`, Post-Processing (`BloomEffect`, `ColorCorrectionEffect`), และ `Highlight` ไม่ทำงานใน `ViewportFrame`!**

#### สถาปัตยกรรม Dual-Renderer Stage ของ Animation Lab ที่เราออกแบบเพื่อแก้ปัญหานี้ 100%:
Animation Lab ของเราจึงออกแบบให้มี **Workspace Isolated Sandbox Stage (`Workspace.__AnimationLabSandbox`)** ทำงานร่วมกับ **Camera Viewport Controller** โดยแบ่งเป็น 2 โหมดที่สลับได้ในคลิกเดียว:
1. **Live Workspace Stage Mode (Default & Recommended สำหรับตรวจ Animation + VFX):**
   - สร้างห้องสตูดิโอจำลอง (`SandboxStage`) ที่พิกัดแยกขาดจากแผนที่เกมจริง เช่น `Vector3.new(0, 5000, 0)` (สูงขึ้นไป 5,000 Studs เหนือแมปหลัก พร้อมฉากหลังสีเข้ม, พื้นตาราง Grid มาตรฐาน 1-Stud / 4-Stud, และไฟสตูดิโอ 3 ทิศทาง)
   - เมื่อเปิด Animation Lab กล้อง `Workspace.CurrentCamera` จะสลับเป็น `Enum.CameraType.Scriptable` แล้วเล็งไปยังโมเดลบนแท่น `SandboxStage` โดยปล่อยช่องกลางหน้าจอของ UI ให้โปร่งใส (Canvas Viewport Hole)
   - **ข้อดี:** แสดงผล `ParticleEmitter`, `Trail`, `Beam`, `Highlight`, `PointLight`, `Bloom`, และ `Camera Shake` ได้ **ครบ 100% เหมือนในเกมจริงทุกประการ!**
2. **Thumbnail / Mini-ViewportFrame Mode (Secondary / Quick Part & Rig Inspector):**
   - ใช้ `ViewportFrame` เฉพาะสำหรับพรีวิวโมเดลขนาดย่อในหน้าต่างเปรียบเทียบ หรือดู Wireframe / Part Hierarchy แบบไม่ต้องการ Particle

---

### 3.3 Screen Layout / Wireframe ของ Animation Lab UI

```text
+======================================================================================================================+
| [🛠 ANIME LIMITLESS TD — PHASE 5 ANIMATION & VFX LAB]   Mode: [● Visual Sandbox | ○ Integration]  Preset: [High ▼] [X] |
+-----------------------+----------------------------------------------------------------------+-----------------------+
| 3.1 MODEL EXPLORER    | 3.2 3D PREVIEW STAGE (Workspace Sandbox @ Y=5000 / Camera Control)   | 3.5 REAL-TIME DEBUG   |
| [Search Model...    ] | +------------------------------------------------------------------+ | Model: Luffy (Hero)   |
|                       | | [Cam: Orbit | Front | Side | Back | Reset | Focus]  [Scale: 1.0x]| | Source: AssetKit/Luffy|
| ▼ HEROES (12)         | | [☑ Grid] [☑ Rig/Joints] [☐ BBox] [☑ Accessories] [☑ DummyTarget] | | Status: RIG_READY     |
|  ● Luffy     [P5-WIP] | |                                                                  | | --------------------- |
|  ● Zoro      [P5-WIP] | |                        ( 3D CHARACTER )                          | | Parts:          18/25 |
|  ● Ace       [P5-WIP] | |                         [Luffy Gear 5]                           | | Active Motor6D:     6 |
|  ○ Nami      [P4-BASE]| |                        o---[Root/Torso]---o                      | | Active Welds:       4 |
|  ○ Usopp     [P4-BASE]| |                             |     |                              | | ParticleEmitters:   5 |
|  ○ Sanji     [P4-BASE]| |                             +-----+----------> [🎯 Dummy Target] | | Active VFX Inst:   12 |
|  ○ Chopper   [P4-BASE]| |                     (1-Stud Grid Floor Plane)                    | | Active Tweens*:     4 |
|  ○ Robin     [P4-BASE]| +------------------------------------------------------------------+ | State:         Attack |
|  ○ Shanks    [P4-BASE]| 3.3 ANIMATION PLAYER & 5-PHASE PROCEDURAL TIMELINE                   | Cooldown:     1.20s   |
|  ○ Whitebeard[P4-BASE]| State: [Idle][Sp.Idle][Spawn][Windup][Attack][Impact][Recovery][Ult] | Spawned/Cleaned:42/42 |
|  ○ Law       [P4-BASE]| [▶ Play] [⏸ Pause] [⏹ Stop] [↻ Replay] [⏮ -1f] [+1f ⏭] [Reset Pose] | Errors/Warns:    0/0  |
|  ○ Kizaru    [P4-BASE]| Speed: [0.25x][0.5x][1.0x][1.5x][2.0x]   [☑ Loop]   Time: 0.42s/1.10s| --------------------- |
| ▼ ENEMIES (4)         | Timeline: |===Wind-up (0.25s)===|==Attack (0.22s)==|★Impact|===Rec===| | ▼ PART HIERARCHY      |
|  ○ PirateGrunt        |                                       ▲ (0.42s Current Cursor)       |  ├─ HumanoidRootPart  |
|  ○ SoruAssassin       +----------------------------------------------------------------------+  ├─ Torso (Motor6D)    |
|  ○ HakiBrute          | 3.4 VFX INSPECTOR                     | 3.6 PERFORMANCE & STRESS TEST|  │  ├─ Head (Motor6D)  |
|  ○ YonkoBoss          | [⚡ Trigger Attack VFX] [🔥 Trigger Ult]| Scenario: [1][10][25][50]   |  │  ├─ RightArm(M6D)   |
| ▼ MAP ASSETS (3)      | [💥 Combo: Anim + VFX]  [🧹 Reset VFX] | [▶ Run Simultaneous VFX]     |  │  └─ LeftArm (M6D)   |
|  ○ AnimeBaseCrystal   | [☑ Particles] [☑ Aura]  [☑ Trail/Beam]| [🧪 Run Cleanup / Leak Test] | --------------------- |
|  ○ EnemySpawnGate     | [☑ Impact FX] [☑ Shake] [☑ ScreenFlash]| FPS: 60.0 | Frame: 16.4 ms  | [⚠ Validation Issues] |
|  ○ PlacementPadTempl. | Intensity: [=======●===] 1.0x         | Peak VFX: 148 | Leak Diff: 0 | None detected.        |
+-----------------------+---------------------------------------+------------------------------+-----------------------+
```

---

### 3.4 รายละเอียดฟีเจอร์และการแก้ปัญหาทางเทคนิคของ Animation Lab (หัวข้อ 3.1 – 3.7)

#### 3.4.1 Model Explorer (19 Models & Ground-Truth Status Badges)
Sidebar ด้านซ้ายแสดงรายการครบทั้ง 19 โมเดล แบ่งเป็น 3 หมวดหมู่ (Heroes 12, Enemies 4, Map Assets 3) โดยทุกครั้งที่เปิด Lab โมดูล `ModelValidator.luau` จะสแกน Instance จริงใน `ReplicatedStorage` / `ServerStorage` แล้วคำนวณสถานะจริง 4 มิติ (ห้าม Hardcode ว่า `Complete` เด็ดขาด):
- `FILE_EXISTS`: พบ Instance ของโมเดลใน Asset Container หรือไม่
- `LOAD_OK`: สามารถ `:Clone()` และมี `PrimaryPart` หรือ RootPart ที่ถูกต้องหรือไม่
- `RIG_STATUS`: มีข้อต่อครบตาม `AnimationContract` และไม่มี `WeldConstraint` ล็อกทับ `Motor6D` หรือไม่ (`UNRIGGED`, `CONFLICT_WELD_OVER_MOTOR`, `FALLBACK_RIG`, `SIGNATURE_RIG_READY`)
- `ANIM_VFX_STATUS`: โมดูล `Animations/<Id>.luau` และ `VFX/<Id>VFX.luau` โหลดผ่านและมีครบทุก State หรือยัง

#### 3.4.2 Model Preview Viewport & Camera / Inspection Controls
- **Rotate Camera:** คลิกขวาค้างแล้วลากเมาส์เพื่อหมุนมุมกล้องแบบ Orbit (`yaw`, `pitch`) รอบจุดศูนย์กลางของโมเดล
- **Zoom In / Out:** หมุนลูกกลิ้งเมาส์ (`MouseWheel`) ปรับระยะห่างกล้องตั้งแต่ `3 studs` ถึง `60 studs`
- **Preset Views (`Front` / `Side` / `Back` / `Reset` / `Focus`):** คำนวณจาก `model:GetBoundingBox()` เพื่อให้โมเดลทุกขนาด (ตั้งแต่ `Chopper` ตัวเล็กไปจนถึง `Whitebeard` หรือ `YonkoBoss`) อยู่กลางจอพอดี
- **Toggle Rig / Joint Markers:** สร้างทรงกลมเรืองแสงขนาดเล็ก (`SphereHandleAdornment` หรือ `Attachment` Marker) ที่จุดหมุน `C0` ของ `Motor6D` ทุกจุด (สีเขียว = ขยับได้ปกติ, สีแดง = ตรวจพบ `WeldConstraint` ทับซ้อนหรือ `Anchored = true`!)
- **Toggle Bounding Box:** วาด `SelectionBox` รอบขอบเขตจริงของโมเดลพร้อมแสดงขนาด `Vector3 (X, Y, Z studs)`
- **Show / Hide Accessories:** สลับ `LocalTransparencyModifier` ของชิ้นส่วนที่ติด Tag/Attribute `IsAccessory = true` เพื่อดูรอยต่อของแขน/หัวได้ชัดเจนขึ้น
- **Preview Character Scaling:** สไลเดอร์ปรับ `model:ScaleTo(scale)` ตั้งแต่ `0.5x` ถึง `2.5x` เพื่อตรวจว่า `Motor6D.C0` และตำแหน่ง VFX สเกลตามขนาดตัวถูกต้องหรือไม่

#### 3.4.3 Animation Player สำหรับ Procedural Animation
เนื่องจากโปรเจกต์ใช้ **Procedural CFrame / Keyframe Animation** (ไม่ต้องพึ่งพา `rbxassetid://` AnimationId ที่ติดปัญหา Permission ข้ามบัญชี Developer):
- เราออกแบบ **`ProceduralTimelinePlayer`** ใน `AnimationController.luau` ที่รับค่าเวลา `elapsedTime` (วินาที) หรือ `normalizedAlpha` (`0.00 -> 1.00`) แล้วคำนวณ CFrame Interpolation (`CFrame:Lerp` พร้อม `TweenService:GetValue(alpha, easingStyle, easingDirection)`) ให้กับ `Motor6D.C0` ทุกข้อต่อแบบ Deterministic!
- เพราะเป็นฟังก์ชันของเวลา `EvaluatePoseAtTime(profile, state, t)` จึงรองรับฟีเจอร์ทั้งหมดได้ทันที:
  - **Play / Pause / Stop / Replay / Loop On-Off**
  - **Playback Speed (`0.1x`, `0.25x`, `0.5x`, `1.0x`, `1.5x`, `2.0x`)**
  - **Step Forward (`+1 Frame` = `+1/60s`) / Step Backward (`-1 Frame` = `-1/60s`)** และ **การลากแถบ Timeline Scrubbing** ไปยังจุดตัดระหว่าง `Idle -> Wind-up -> Attack -> Impact -> Recovery` เพื่อตรวจท่าทีละเฟรมได้อย่างแม่นยำ!

#### 3.4.4 Real-Time Debug Inspector & วิธีวัดค่าที่ Roblox API ไม่มีให้อ่านโดยตรง
โจทย์กำหนดว่า: *"หากตัวชี้วัดใดไม่สามารถอ่านโดยตรงผ่าน Roblox API ให้เสนอวิธี Instrumentation ที่เหมาะสม และระบุข้อจำกัดอย่างตรงไปตรงมา"*

| ตัวชี้วัด (Metric) | อ่านจาก Roblox API โดยตรงได้หรือไม่? | วิธีวัดค่า / Instrumentation ที่ออกแบบใน `TelemetryCollector.luau` | ข้อจำกัดทางเทคนิคที่ระบุอย่างตรงไปตรงมา |
| :--- | :--- | :--- | :--- |
| **Part Count / Motor6D Count / Weld Count** | **ได้โดยตรง** (`model:GetDescendants()`) | สแกน `IsA("BasePart")`, `IsA("Motor6D")`, `IsA("WeldConstraint")` or `IsA("Weld")` พร้อมดักจับ `DescendantAdded` / `DescendantRemoving` | นับเฉพาะใน Scope ของโมเดลและ Sandbox Container |
| **Active Particle Emitters** | **ได้โดยตรง** (`IsA("ParticleEmitter")`) | นับจำนวน `ParticleEmitter` ที่มี `Enabled == true` หรือเพิ่งถูกสั่ง `:Emit(n)` ภายในช่วงเวลา Lifetime สูงสุด (`Lifetime.Max`) | Roblox ไม่มี Property อ่านจำนวนเม็ด Particle รายเม็ดที่ลอยอยู่บนการ์ดจอ (`GPU Particle Count`) จึงต้องประมาณการจาก `Rate * Lifetime.Max` + ยอดสะสมจาก `:Emit(count)` |
| **Active Tween Count** | **ไม่ได้โดยตรง** (Roblox `TweenService` ไม่มี API `GetActiveTweens()`) | สร้าง Wrapper `AnimationController:CreateTrackedTween(instance, tweenInfo, goal)` และ `VFXDispatcher:CreateTrackedTween(...)` ที่เพิ่มตัวนับ `+1` ตอน `:Play()` และผูก `tween.Completed:Once()` เพื่อลดตัวนับ `-1` | วัดได้แม่นยำ 100% สำหรับทุก Tween ที่สร้างผ่าน `AnimationController` และ `VFXDispatcher` แต่จะไม่เห็น Tween นอกระบบที่เขียนด้วย `TweenService:Create()` โดยตรง (จึงมีกฎ Lint ห้ามเรียก `TweenService:Create` ตรงๆ ในโมดูลตัวละคร) |
| **Instance Creation / Cleanup Counter** | **ไม่ได้โดยตรงแบบ Per-Feature** | ทุก VFX Part ต้องสร้างผ่าน `ctx.registerInstance(inst, ttl)` ซึ่งจะบันทึก `totalCreated += 1` และผูก `inst.Destroying:Once()` เพื่อบันทึก `totalCleaned += 1` หากจบการทดสอบแล้ว `totalCreated ~= totalCleaned` จะแจ้งเตือน **`LEAK DETECTED`** ทันที | ต้องผ่าน `registerInstance` หรืออยู่ใน `SandboxContainer` เท่านั้น |
| **Frame Time / FPS & Memory** | **ได้โดยตรง** (`RunService.RenderStepped:Wait()`, `Stats:GetTotalMemoryUsageMb()`) | คำนวณ Rolling Average ของ `dt * 1000` (ms) และ 1% Low FPS พร้อมติด `debug.profilebegin("Phase5_AnimationStep")` และ `debug.profilebegin("Phase5_VFXDispatch")` เพื่อให้เปิดดูใน **Roblox MicroProfiler (`Ctrl+F6`)** ได้ทันที | ค่า Memory รวมของ Studio จะมี Overhead ของตัวโปรแกรม Studio ปนอยู่ จึงต้องเน้นดูค่า `Delta Instance Count` เป็นหลัก |

#### 3.4.5 Sandbox Mode Isolation & Security Architecture (หัวข้อ 3.7)
1. **การแยกโหมดทดสอบ 2 โหมด:**
   - **Mode A — Visual Sandbox (Default):** สร้างโมเดลและ Dummy Target ภายใน `Workspace.__AnimationLabSandbox` เท่านั้น ไม่มีการเรียก `TowerController:SpawnTower()`, ไม่หักเงินผู้เล่น, ไม่ยุ่งกับ `WaveManager`, ไม่สร้างศัตรูจริง และไม่บันทึกข้อมูลลง DataStore/Inventory
   - **Mode B — Controlled Integration Test:** สร้าง Isolated Test Pad และปล่อย Dummy Enemy เฉพาะกิจที่มี Tag `IsLabDummy = true` ในพื้นที่ Sandbox เพื่อให้ทดสอบว่าเมื่อ `TowerController` สั่งโจมตีจริง ตัวละครหันหาเป้าหมาย, เล่นท่า 5-Phase, แสดง VFX, และทำดาเมจใส่ Dummy ได้ตรงจังหวะ โดยบล็อกการแจก Gold/XP/Reward 100% (`if target:GetAttribute("IsLabDummy") then return end` ในระบบให้รางวัล)
2. **การป้องกันผู้เล่นทั่วไปในเกมที่ Published (Zero Production Exposure):**
   - สคริปต์เริ่มต้น `AnimationLabBootstrap.server.luau` ตรวจสอบบรรทัดแรกสุด:
     ```luau
     local RunService = game:GetService("RunService")
     if not RunService:IsStudio() then
         script.Parent:Destroy() -- ลบโค้ดและ UI ของ Animation Lab ออกจากหน่วยความจำทันทีบน Production Server
         return
     end
     ```
   - ไม่มีการเปิด `RemoteEvent` สาธารณะให้ Client สั่งเสกโมเดลหรือสั่งทำ Damage ได้ในเกมที่ Publish แล้ว

---

## PART 4 — TEAM EXECUTION & ZERO-CONFLICT COLLABORATION

### 4.1 การแบ่งงาน 3 คน + Core/UI Owner และตาราง File Ownership Matrix

เพื่อไม่ให้ Developer ทั้ง 3 คนแก้ไขไฟล์ระบบกลางพร้อมกัน เราแบ่งโครงสร้างการทำงานออกเป็น **1 Core/Lab Track (`AGY-Core`)** และ **3 Parallel Character Tracks (`Dev 1`, `Dev 2`, `Dev 3`)**:

| บทบาท / ผู้รับผิดชอบ | Git Branch | Git Worktree Path | Owned Files (แก้ไขได้เฉพาะไฟล์เหล่านี้เท่านั้น) | ห้ามแก้ไขเด็ดขาด (Forbidden Files) |
| :--- | :--- | :--- | :--- | :--- |
| **Core & Animation Lab Architect (`AGY-Core`)** | `feat/phase5-core-contracts-and-lab` | `../wt-phase5-core` | - `src/Shared/AnimationContract.luau`<br>- `src/Shared/VFXContract.luau`<br>- `src/Track2_TowerSystem/AnimationController.luau`<br>- `src/Track2_TowerSystem/AnimationRegistry.luau`<br>- `src/Track2_TowerSystem/VFXDispatcher.luau`<br>- `src/Track2_TowerSystem/Animations/_FallbackProfile.luau`<br>- `src/Track2_TowerSystem/VFX/_FallbackVFX.luau`<br>- `src/AssetKit/VisualBridge.server.luau`<br>- `src/Track2_TowerSystem/TowerController.server.luau`<br>- `src/DevTools/AnimationLab/**`<br>- `default.project.json`<br>- `tests/phase5_core_and_lab.spec.luau` | ไฟล์ตัวละครรายตัวของ Dev 1, Dev 2, Dev 3 และระบบ Wave/Economy หลัก |
| **Developer 1 — Luffy Gear 5 (`AGY-Char-Luffy`)** | `feat/phase5-char-luffy` | `../wt-phase5-luffy` | - `assets/Heroes/Luffy.rbxmx` (หรือ path โมเดล Luffy ใน Repo)<br>- `src/Track2_TowerSystem/Animations/Luffy.luau`<br>- `src/Track2_TowerSystem/VFX/LuffyVFX.luau`<br>- `tests/characters/luffy_anim_vfx.spec.luau` | `TowerController.server.luau`, `VisualBridge.server.luau`, `AnimationController.luau`, `AnimationRegistry.luau`, โมเดล/โค้ดของ Zoro และ Ace |
| **Developer 2 — Zoro King of Hell (`AGY-Char-Zoro`)** | `feat/phase5-char-zoro` | `../wt-phase5-zoro` | - `assets/Heroes/Zoro.rbxmx` (หรือ path โมเดล Zoro ใน Repo)<br>- `src/Track2_TowerSystem/Animations/Zoro.luau`<br>- `src/Track2_TowerSystem/VFX/ZoroVFX.luau`<br>- `tests/characters/zoro_anim_vfx.spec.luau` | `TowerController.server.luau`, `VisualBridge.server.luau`, `AnimationController.luau`, `AnimationRegistry.luau`, โมเดล/โค้ดของ Luffy และ Ace |
| **Developer 3 — Ace Flame Emperor (`AGY-Char-Ace`)** | `feat/phase5-char-ace` | `../wt-phase5-ace` | - `assets/Heroes/Ace.rbxmx` (หรือ path โมเดล Ace ใน Repo)<br>- `src/Track2_TowerSystem/Animations/Ace.luau`<br>- `src/Track2_TowerSystem/VFX/AceVFX.luau`<br>- `tests/characters/ace_anim_vfx.spec.luau` | `TowerController.server.luau`, `VisualBridge.server.luau`, `AnimationController.luau`, `AnimationRegistry.luau`, โมเดล/โค้ดของ Luffy และ Zoro |
| **Codex (Independent Controller / Reviewer)** | `feat/phase5-integration` | Main Repo / Review Worktree | ตรวจสอบ Git Diff, รัน Automated Tests, ตรวจ Acceptance Gates (ไม่เขียนฟีเจอร์เอง) | ไม่เขียนโค้ดทับงานของ AGY โดยตรง |

---

### 4.2 คำสั่งตั้งค่า Git Worktree แบบจับมือทำ (Zero-Conflict Worktree Setup)

เมื่อเจ้าของโปรเจกต์อนุมัติแผนแล้ว ให้รันคำสั่งตามลำดับนี้:

```bash
# 1. ยืนยันว่าอยู่ที่ Baseline Commit ที่ถูกต้อง
git checkout d5d06216b2f8bc6ba43071d453709e0d3e0e8df4
git checkout -b feat/phase5-integration

# 2. สร้าง Worktree สำหรับ Wave 0 & Wave 1 (Core Contracts + Rig Fix + Animation Lab UI)
git worktree add -b feat/phase5-core-contracts-and-lab ../wt-phase5-core feat/phase5-integration

# 3. เมื่อ Wave 1 (Core & Animation Lab) ผ่านการตรวจของ Codex และ Merge เข้า feat/phase5-integration แล้ว:
# จึงแตก Worktree ทั้ง 3 ตัวละครพร้อมกัน (Wave 2 Parallel Execution)
git worktree add -b feat/phase5-char-luffy ../wt-phase5-luffy feat/phase5-integration
git worktree add -b feat/phase5-char-zoro  ../wt-phase5-zoro  feat/phase5-integration
git worktree add -b feat/phase5-char-ace   ../wt-phase5-ace   feat/phase5-integration
```

**ทำไม `AnimationRegistry.luau` ถึงไม่เกิด Merge Conflict ตอนรวม Branch ทั้ง 3 คน?**
เพราะ `AGY-Core` เขียน `AnimationRegistry.luau` และ `VFXDispatcher.luau` ให้ค้นหาโมดูลลูกในโฟลเดอร์ `Animations/` และ `VFX/` แบบ **Dynamic Discovery (`FindFirstChild(heroId)` + `pcall(require)`)** ตั้งแต่วันแรกใน Wave 1!
ดังนั้น เมื่อ Dev 1 เพิ่มไฟล์ `Animations/Luffy.luau`, Dev 2 เพิ่ม `Animations/Zoro.luau`, และ Dev 3 เพิ่ม `Animations/Ace.luau` ทั้ง 3 คน **ไม่จำเป็นต้องแก้ไขไฟล์ `AnimationRegistry.luau` แม้แต่บรรทัดเดียว!** การ Merge เข้า `feat/phase5-integration` จึงเป็น **Zero-Conflict Merge 100%**

---

## PART 5 — MASTER IMPLEMENTATION PLAN & EMBEDDED 5 SPECIFICATION FILES

ด้านล่างนี้คือเนื้อหาฉบับเต็มของเอกสารทั้ง 5 ไฟล์ตามโครงสร้าง:
```text
docs/
  implementation-plans/
    0005-character-model-animation/
      PLAN.md
      characters/
        01-luffy.md
        02-zoro.md
        03-ace.md
      assets/
        04-animation-lab-ui.md
```
> **คำแนะนำสำหรับ AI Agent:** อ่าน Marker `<!-- === FILE_START: ... === -->` และ `<!-- === FILE_END: ... === -->` ด้านล่างนี้เพื่อสร้างไฟล์ทั้ง 5 ลงในโปรเจกต์ได้ทันที

---

&lt;!-- === FILE_START: docs/implementation-plans/0005-character-model-animation/PLAN.md === --&gt;
# Phase 5 Master Implementation Plan — Character Model, Signature Animation, VFX & Animation Lab

- **Document ID:** `0005-character-model-animation/PLAN.md`
- **Repository:** `https://github.com/StangMKxD/anime-limitless-td`
- **Baseline Commit:** `d5d06216b2f8bc6ba43071d453709e0d3e0e8df4`
- **Status:** `DRAFT FOR OWNER APPROVAL` (Visual/Studio Verification Status: `NOT VERIFIED`)
- **Governance:** Project Owner (Approver) | Codex (Controller / Independent Reviewer) | AGY (Implementer)

---

## 1. Phase 5 Goals

1. **Character Model Improvement:** ปรับปรุงโมเดลที่มีอยู่ใน AssetKit ให้มีสัดส่วน เอกลักษณ์ Accessories และลำดับชั้นของชิ้นส่วน (`Part Hierarchy`) ที่ถูกต้อง รองรับการขยับแขน ขา ศีรษะ และอาวุธ โดยไม่เกิดการล็อกทับกันระหว่าง `WeldConstraint` กับ `Motor6D`
2. **Signature Character Animation:** แยกระบบ Animation ออกจาก `TowerController.server.luau` สู่สถาปัตยกรรม `AnimationController` + โมดูลรายตัวละคร (`Animations/<HeroId>.luau`) รองรับสถานะ `Idle`, `SpecialIdle`, `Spawn`, `Windup`, `Attack`, `Impact`, `Recovery`, และ `Ultimate` พร้อมระบบยกเลิกท่า (Cancellation), Cooldown Scaling และ Reset Pose
3. **Character-Specific VFX:** ออกแบบระบบเอฟเฟกต์ประจำตัวละคร (`VFX/<HeroId>VFX.luau`) ที่แยกขาดจากลอจิกการทำ Damage 100% พร้อมระบบควบคุมจำนวน Instance สูงสุด, Quality Presets (`Low` / `Medium` / `High`), และการทำลาย Instance เมื่อโมเดลถูกลบ (Zero Memory Leak)
4. **Animation Lab / Model Inspector UI:** สร้างเครื่องมือสำหรับนักพัฒนาใน Roblox Studio (`src/DevTools/AnimationLab/`) เพื่อตรวจสอบโมเดลทั้ง 19 ชิ้น, ทดสอบท่าทางแบบ Scrub Timeline, ทดสอบ VFX, ดูค่า Debug แบบ Real-time และรัน Stress Test (1 / 10 / 25 / 50 ตัวละคร) โดยไม่กระทบ Gameplay ปกติ

---

## 2. Current Architecture Analysis & Root-Cause Findings

### 2.1 ไฟล์หลักที่เกี่ยวข้องใน Baseline Commit `d5d06216b2f8bc6ba43071d453709e0d3e0e8df4`
- `AGENTS.md`, `docs/READ.md`, `docs/CONVENTIONS.md`, `docs/CONTEXT.md`: กำหนดกฎ Modular Zero-Conflict Architecture, มาตรฐานการเขียนโค้ด Luau และบทบาท Codex vs AGY
- `default.project.json`: กำหนดการซิงค์ Rojo ระหว่างโฟลเดอร์ `src/` และ `assets/` เข้าสู่บริการของ Roblox Studio
- `src/Shared/GameConfig.luau`: เก็บข้อมูล Hero/Enemy Stats, ค่าใช้จ่าย, ระยะโจมตี, Cooldown และโทนสีประจำตัวละคร
- `src/AssetKit/VisualBridge.server.luau`: โหลดโมเดลจาก AssetKit และทำการผูกชิ้นส่วนเข้ากับ RootPart
- `src/Track2_TowerSystem/TowerController.server.luau`: จัดการการวาง Tower, การค้นหาเป้าหมาย, Runtime Rigging, 5-Phase Attack Animation, VFX และการทำ Damage
- `src/Track1_WaveSystem/WaveManager.server.luau`: จัดการการเกิดและเคลื่อนที่ของศัตรูแต่ละ Wave

### 2.2 สาเหตุที่โมเดลปัจจุบันขยับไม่สมบูรณ์หรือเกิดการ Rig ซ้ำ (Root-Cause Analysis)
จากการตรวจสอบความสัมพันธ์ระหว่าง `VisualBridge.server.luau` และ `TowerController.server.luau` พบปัญหาหลัก 3 ประการ:
1. **`WeldConstraint` ทับซ้อนกับ `Motor6D`:** `VisualBridge` เชื่อมชิ้นส่วนย่อยเข้ากับ Root ด้วย `WeldConstraint` เพื่อกันโมเดลหลุด แต่เมื่อ `TowerController` สร้าง `Motor6D` เพื่อขยับแขน/ขาในภายหลัง ตัว `WeldConstraint` ที่ยังค้างอยู่จะล็อกชิ้นส่วนให้แข็งทื่อ (Rigid Assembly Lock)
2. **การตั้งค่า `Anchored = true` บนชิ้นส่วนลูก:** ชิ้นส่วนอวัยวะ (`RightArm`, `LeftArm`, `Head`, `Legs`) หรืออาวุธที่ถูกตั้ง `Anchored = true` จะไม่ขยับตามการเปลี่ยนค่า `Motor6D.C0` / `Transform`
3. **Accessories ถูก Weld เข้ากับ Root แทนที่จะเข้ากับ Limb:** หมวก ดาบ หรือผ้าคลุมที่ถูก Weld เข้ากับ `RootPart` โดยตรงจะไม่ขยับตามศีรษะหรือแขนเมื่อตัวละครออกท่าโจมตี

### 2.3 แนวทางการแก้ไขใน Phase 5 (Where & How to Fix)
- **ระดับที่ 1 (`src/AssetKit/VisualBridge.server.luau`):** ปรับปรุงขั้นตอนการเตรียมโมเดลให้เรียกใช้ `AnimationController.SanitizeAndRigModel(model, profile)` แทนการกวาดทุก Part มาสร้าง `WeldConstraint` เข้ากับ RootPart
- **ระดับที่ 2 (`src/Track2_TowerSystem/AnimationController.luau`):**
  - ลบ `WeldConstraint` ที่เกาะอยู่ระหว่างอวัยวะหลัก (`Torso`, `Head`, `RightArm`, `LeftArm`, `RightLeg`, `LeftLeg`) กับ `RootPart` ออกก่อนสร้าง `Motor6D`
  - ตั้งค่า `RootPart.Anchored = true` เพียงชิ้นเดียว ส่วนชิ้นส่วนอื่นทั้งหมดในโมเดลต้องเป็น `Anchored = false`, `CanCollide = false`, `CanTouch = false`, `CanQuery = false`, `Massless = true`
  - ยึด Accessories เข้ากับอวัยวะแม่ที่ถูกต้องตาม `accessoryRules` ใน `AnimationContract` (เช่น หมวกฟาง -> `Head`, ดาบมือขวา -> `RightArm`)

---

## 3. Complete Asset Inventory (19 Assets) & Model/Animation Status Matrix

> **กฎความซื่อสัตย์ของสถานะ (Strict Honesty Rule):** ห้ามแสดงสถานะเป็น `Complete` หรือ `VERIFIED` จนกว่าจะผ่านการตรวจใน Roblox Studio จริง สถานะเริ่มต้นในแผนนี้จึงระบุตามความจริงของ Baseline Commit `d5d06216b2f8bc6ba43071d453709e0d3e0e8df4`

| # | Category | Asset / Model ID | Expected File Name | Phase 5 Scope | File Status (Baseline) | Rig / Joint Status (Baseline) | Signature Animation Status | Character VFX Status | Studio Visual Test |
| :-: | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | **Hero** | `Luffy` | `Luffy.rbxmx` | **Wave 2 (Dev 1)** | Exists (Phase 4 Part Model) | Needs Weld->Motor6D Fix & Gear 5 Cloud Mapping | **Planned (Phase 5 First 3)** | **Planned (Phase 5 First 3)** | `NOT VERIFIED` |
| 2 | **Hero** | `Zoro` | `Zoro.rbxmx` | **Wave 2 (Dev 2)** | Exists (Phase 4 Part Model) | Needs Weld->Motor6D Fix & 3-Sword Joint Mapping | **Planned (Phase 5 First 3)** | **Planned (Phase 5 First 3)** | `NOT VERIFIED` |
| 3 | **Hero** | `Ace` | `Ace.rbxmx` | **Wave 2 (Dev 3)** | Exists (Phase 4 Part Model) | Needs Weld->Motor6D Fix & Hat/Flame Rig Mapping | **Planned (Phase 5 First 3)** | **Planned (Phase 5 First 3)** | `NOT VERIFIED` |
| 4 | **Hero** | `Nami` | `Nami.rbxmx` | Backlog (Fallback Rig) | Exists (Phase 4 Part Model) | Will use Unified RigBuilder + Fallback Profile | Backlog (Uses `_FallbackProfile`) | Backlog (Uses `_FallbackVFX`) | `NOT VERIFIED` |
| 5 | **Hero** | `Usopp` | `Usopp.rbxmx` | Backlog (Fallback Rig) | Exists (Phase 4 Part Model) | Will use Unified RigBuilder + Fallback Profile | Backlog (Uses `_FallbackProfile`) | Backlog (Uses `_FallbackVFX`) | `NOT VERIFIED` |
| 6 | **Hero** | `Sanji` | `Sanji.rbxmx` | Backlog (Fallback Rig) | Exists (Phase 4 Part Model) | Will use Unified RigBuilder + Fallback Profile | Backlog (Uses `_FallbackProfile`) | Backlog (Uses `_FallbackVFX`) | `NOT VERIFIED` |
| 7 | **Hero** | `Chopper` | `Chopper.rbxmx` | Backlog (Fallback Rig) | Exists (Phase 4 Part Model) | Will use Unified RigBuilder + Fallback Profile | Backlog (Uses `_FallbackProfile`) | Backlog (Uses `_FallbackVFX`) | `NOT VERIFIED` |
| 8 | **Hero** | `Robin` | `Robin.rbxmx` | Backlog (Fallback Rig) | Exists (Phase 4 Part Model) | Will use Unified RigBuilder + Fallback Profile | Backlog (Uses `_FallbackProfile`) | Backlog (Uses `_FallbackVFX`) | `NOT VERIFIED` |
| 9 | **Hero** | `Shanks` | `Shanks.rbxmx` | Backlog (Fallback Rig) | Exists (Phase 4 Part Model) | Will use Unified RigBuilder + Fallback Profile | Backlog (Uses `_FallbackProfile`) | Backlog (Uses `_FallbackVFX`) | `NOT VERIFIED` |
| 10 | **Hero** | `Whitebeard` | `Whitebeard.rbxmx` | Backlog (Fallback Rig) | Exists (Phase 4 Part Model) | Will use Unified RigBuilder + Fallback Profile | Backlog (Uses `_FallbackProfile`) | Backlog (Uses `_FallbackVFX`) | `NOT VERIFIED` |
| 11 | **Hero** | `Law` | `Law.rbxmx` | Backlog (Fallback Rig) | Exists (Phase 4 Part Model) | Will use Unified RigBuilder + Fallback Profile | Backlog (Uses `_FallbackProfile`) | Backlog (Uses `_FallbackVFX`) | `NOT VERIFIED` |
| 12 | **Hero** | `Kizaru` | `Kizaru.rbxmx` | Backlog (Fallback Rig) | Exists (Phase 4 Part Model) | Will use Unified RigBuilder + Fallback Profile | Backlog (Uses `_FallbackProfile`) | Backlog (Uses `_FallbackVFX`) | `NOT VERIFIED` |
| 13 | **Enemy** | `PirateGrunt` | `PirateGrunt.rbxmx` | Inspector + Fallback Walk | Exists (Phase 4 Part Model) | Needs Rig Validation in Animation Lab | Enemy Walk/Hit Fallback | Basic Hit VFX | `NOT VERIFIED` |
| 14 | **Enemy** | `SoruAssassin` | `SoruAssassin.rbxmx` | Inspector + Fallback Walk | Exists (Phase 4 Part Model) | Needs Rig Validation in Animation Lab | Enemy Dash/Walk Fallback | Basic Hit VFX | `NOT VERIFIED` |
| 15 | **Enemy** | `HakiBrute` | `HakiBrute.rbxmx` | Inspector + Fallback Walk | Exists (Phase 4 Part Model) | Needs Rig Validation in Animation Lab | Enemy Heavy Walk Fallback | Basic Hit VFX | `NOT VERIFIED` |
| 16 | **Enemy** | `YonkoBoss` | `YonkoBoss.rbxmx` | Inspector + Fallback Walk | Exists (Phase 4 Part Model) | Needs Rig Validation in Animation Lab | Boss Walk/Stomp Fallback | Boss Aura Fallback | `NOT VERIFIED` |
| 17 | **Map Asset** | `AnimeBaseCrystal` | `AnimeBaseCrystal.rbxmx` | Inspector Validation | Exists (Phase 4 Map Model) | Static / Floating Crystal Idle | Static / Bobbing Idle | Crystal Glow | `NOT VERIFIED` |
| 18 | **Map Asset** | `EnemySpawnGate` | `EnemySpawnGate.rbxmx` | Inspector Validation | Exists (Phase 4 Map Model) | Static Portal Structure | Static Portal | Gate Vortex Particle | `NOT VERIFIED` |
| 19 | **Map Asset** | `PlacementPadTemplate` | `PlacementPadTemplate.rbxmx` | Inspector Validation | Exists (Phase 4 Map Model) | Static Placement Ring/Pad | Static Pad | Selection Highlight | `NOT VERIFIED` |

---

## 4. Character Backlog (Remaining 9 Heroes & 4 Enemies — Do Not Create Individual Plan Files in This Round)

ตามข้อกำหนดของ Phase 5 รอบนี้ให้สร้างแผนรายตัวเฉพาะ **3 ตัวละครแรก (`Luffy`, `Zoro`, `Ace`)** เท่านั้น ส่วนอีก 9 Heroes และ 4 Enemies ให้บันทึกเป็น Backlog ใน `PLAN.md` นี้เพื่อดำเนินการในรอบถัดไปหลังจากสถาปัตยกรรมนิ่งแล้ว:

| Backlog Wave | ตัวละคร (Model ID) | แนวคิด Signature Animation & อาวุธที่จะทำในรอบถัดไป | แนวคิด Character-Specific VFX ที่จะทำในรอบถัดไป |
| :--- | :--- | :--- | :--- |
| **Phase 5B (Batch 2)** | `Shanks` | One-Arm Gryphon Sword Stance, Divine Departure (`Kamusari`) Dash Slash | Deep Crimson/Black Conqueror Haki Lightning Wave & Screen Split Slash |
| **Phase 5B (Batch 2)** | `Whitebeard` | Two-Handed Murakumogiri Naginata Grip, Quake Fist Air-Crack Pose (`Gura Gura`) | Spherical White Shockwave Dome, Shattered Air Crack Decals/Beams & Ground Tremor |
| **Phase 5B (Batch 2)** | `Law` | Kikoku Nodachi Over-Shoulder Stance, Left-Hand `ROOM` Tact/Shambles Finger Snap | Translucent Cyan Spherical `ROOM` Dome, Spatial Slash Ring & Electric `Gamma Knife` |
| **Phase 5B (Batch 2)** | `Kizaru` | Relaxed Hands-in-Pockets Admiral Stance, Finger Laser Point & `Yasakani no Magatama` Cross-Arms | Golden Glint Starburst (`Pika Pika`), Mirror Light Beam & High-Density Golden Barrage |
| **Phase 5C (Batch 3)** | `Sanji` | Hands-in-Pockets Footwork Idle, `Diable / Ifrit Jambe` Spin Kick & Aerial Heel Drop | Blazing Orange/Blue Leg Trail, Spiral Flame Kick Arc & Fire Footsteps |
| **Phase 5C (Batch 3)** | `Nami` | Clima-Tact Twirl Idle, Zeus Cloud Summon & Weather Egg Charge | Thundercloud Overhead Model/Particle, Zig-Zag Yellow Lightning Bolt Impact |
| **Phase 5C (Batch 3)** | `Usopp` | Kabuto Slingshot Aiming Stance, Pullback Elastic Tension & Recoil Hop | Green Pop-Green Seed Trail, Exploding Vine/Skull Smoke Burst Impact |
| **Phase 5C (Batch 3)** | `Robin` | Crossed-Arms `Hana Hana` Pose, Giant Petal Bloom Summon & Clutch Snap | Pink/Violet Flower Petal Swirl Emitter & Sprouting Giant Arm Impact |
| **Phase 5C (Batch 3)** | `Chopper` | Cute Swaying Stance, Guard/Kung-Fu Hop & Heavy Point Slam | Cherry Blossom (`Sakura`) Pink Puff Particles & Hoof Stamp Shockwave |
| **Phase 5D (Enemies)** | `PirateGrunt`, `SoruAssassin`, `HakiBrute`, `YonkoBoss` | Walk Cycle, Soru High-Speed Afterimage Step, Heavy Club/Fist Swing, Hit Flinch & Death Dissolve | Afterimage Ghosts (`Soru`), Dark Armament Coating (`HakiBrute`), Conqueror Boss Aura (`YonkoBoss`) |

---

## 5. First 3 Character Scope Summary

| ลำดับ | Developer | ตัวละคร | โมเดล | รายงานแผนย่อย | ขอบเขตงานหลัก |
| :-: | :--- | :--- | :--- | :--- | :--- |
| **1** | **Developer 1** | **Luffy Gear 5** | `Luffy.rbxmx` | `characters/01-luffy.md` | ปรับปรุงโมเดลชุดสีขาว Gear 5 + ผ้าคลุมเมฆ (`CloudScarf`) + หมวกฟางสะพายหลัง/สวมหัว, 6-Joint Rig, ท่า Bouncy Joyboy Idle, หมัดยางยืด (`Stretch Punch`), ท่าไม้ตายหมัดยักษ์ (`Bajrang Fist`), เอฟเฟกต์เมฆขาวและสายฟ้าฮาคิราชันย์ดำ-แดง |
| **2** | **Developer 2** | **Zoro King of Hell** | `Zoro.rbxmx` | `characters/02-zoro.md` | ปรับปรุงโมเดลชุดคุนิของวาโนะ + ดาบ 3 เล่ม (`WadoIchimonji`, `Enma`, `SandaiKitetsu` + ฝักดาบ), 9-Joint Weapon Rig, ท่าตั้งการ์ด 3 ดาบ, ท่าฟัน Santoryu Slash, ท่าไม้ตาย `King of Hell` (103 Mercies), เอฟเฟกต์ไฟฮาคิสีเขียว-ม่วงทอง และรอยคลื่นดาบ (`Trail`/`Slash Arc`) |
| **3** | **Developer 3** | **Ace Flame Emperor** | `Ace.rbxmx` | `characters/03-ace.md` | ปรับปรุงโมเดลหมวกคาวบอยสีส้ม + สร้อยคอแดง + มีดสั้น + รอยสัก, 6-Joint Rig, ท่าจุดไฟปลายนิ้ว (`Flame Idle`), ท่าชาร์จไฟ (`Fire Charge`), ท่าหมัดอัคคี (`Hiken / Fire Punch`), ท่าไม้ตายลูกไฟยักษ์ (`Dai Enkai: Entei`), เอฟเฟกต์เปลวไฟ ลำแสงเพลิง และวงแหวนระเบิดไฟ |

---

## 6. Animation Lab UI Requirements Summary

รายละเอียดเชิงลึกอยู่ใน `assets/04-animation-lab-ui.md` โดยมีหัวใจสำคัญดังนี้:
1. **Model Explorer:** แสดงครบทั้ง 19 โมเดลพร้อมสถานะตรวจสอบจริงจาก `ModelValidator.luau`
2. **Dual-Stage 3D Preview:** ใช้ **Isolated Workspace Stage (`Workspace.__AnimationLabSandbox`)** ร่วมกับ Scriptable Orbit Camera เพื่อให้ `ParticleEmitter`, `Trail`, `Beam`, `Highlight`, และ `Lighting` แสดงผลครบ 100% (แก้ข้อจำกัดของ `ViewportFrame` ที่ไม่เรนเดอร์ Particle/Trail/Beam) พร้อมโหมดเสริม `ViewportFrame` สำหรับตรวจ Part Hierarchy
3. **Animation Player:** รองรับ Play, Pause, Stop, Replay, Speed (`0.1x`–`2.0x`), Loop, State Selector, Reset Pose, Step `-1f / +1f` และแถบ Timeline แสดงเฟส `Idle -> Wind-up -> Attack -> Impact -> Recovery`
4. **VFX Inspector:** ยิงทดสอบ Attack VFX / Ultimate VFX แยกจากระบบต่อสู้จริง, เปิด/ปิดแยกเลเยอร์ (Particles, Aura, Trail/Beam, Impact, Camera Shake, Screen Flash), ปรับความเข้มข้น (`Intensity`) และสลับ `Low / Medium / High` พร้อมวาง `Dummy Target`
5. **Real-Time Debug Inspector & Performance Suite:** แสดง Part Count, Motor6D Count, Weld Count, Particle Count, Active VFX Instances, Tracked Tweens, Instance Creation/Cleanup Balance และโหมดทดสอบ 1 / 10 / 25 / 50 ตัวละครพร้อมกัน
6. **Sandbox Security & Isolation:** ทำงานเฉพาะเมื่อ `RunService:IsStudio() == true` และไม่แก้ไขค่าเงิน, Inventory, Gacha, หรือ Wave Progress ของเกมหลักเด็ดขาด

---

## 7. Shared Contracts & Module Dependencies

- **`src/Shared/AnimationContract.luau`:** กำหนดมาตรฐาน `AnimationState`, `JointName`, `ProceduralKeyframe`, `CharacterAnimationProfile`, และ `AccessoryWeldRule`
- **`src/Shared/VFXContract.luau`:** กำหนดมาตรฐาน `VFXCueType`, `VFXQualityPreset`, `VFXLayerFlags`, `VFXExecutionContext`, และ `CharacterVFXModule`
- **ลำดับการพึ่งพา (Dependency Order):**
  1. `AnimationContract.luau` และ `VFXContract.luau` ต้องถูกล็อกสเปกและสร้างเสร็จใน **Wave 0**
  2. `AnimationController.luau`, `AnimationRegistry.luau`, `VFXDispatcher.luau`, การแก้ `VisualBridge.server.luau`, และ `AnimationLab` ต้องเสร็จใน **Wave 1**
  3. งานของ Developer 1 (`Luffy`), Developer 2 (`Zoro`), และ Developer 3 (`Ace`) เริ่มพร้อมกันใน **Wave 2** บน Git Worktree แยกกัน
  4. การรวมระบบและตรวจสอบขั้นสุดท้ายโดย Codex ดำเนินการใน **Wave 3**

---

## 8. Ownership Matrix & Integration Sequence

### 8.1 ตาราง Ownership Matrix
| Track / Owner | Git Branch | Worktree | Owned Paths |
| :--- | :--- | :--- | :--- |
| **Core / UI (`AGY-Core`)** | `feat/phase5-core-contracts-and-lab` | `../wt-phase5-core` | `src/Shared/AnimationContract.luau`, `src/Shared/VFXContract.luau`, `src/AssetKit/VisualBridge.server.luau`, `src/Track2_TowerSystem/TowerController.server.luau`, `src/Track2_TowerSystem/AnimationController.luau`, `src/Track2_TowerSystem/AnimationRegistry.luau`, `src/Track2_TowerSystem/VFXDispatcher.luau`, `src/Track2_TowerSystem/Animations/_FallbackProfile.luau`, `src/Track2_TowerSystem/VFX/_FallbackVFX.luau`, `src/DevTools/AnimationLab/**`, `default.project.json`, `tests/phase5_core_and_lab.spec.luau` |
| **Dev 1 (`AGY-Char-Luffy`)** | `feat/phase5-char-luffy` | `../wt-phase5-luffy` | `Luffy.rbxmx`, `src/Track2_TowerSystem/Animations/Luffy.luau`, `src/Track2_TowerSystem/VFX/LuffyVFX.luau`, `tests/characters/luffy_anim_vfx.spec.luau` |
| **Dev 2 (`AGY-Char-Zoro`)** | `feat/phase5-char-zoro` | `../wt-phase5-zoro` | `Zoro.rbxmx`, `src/Track2_TowerSystem/Animations/Zoro.rbxmx`, `src/Track2_TowerSystem/VFX/ZoroVFX.luau`, `tests/characters/zoro_anim_vfx.spec.luau` |
| **Dev 3 (`AGY-Char-Ace`)** | `feat/phase5-char-ace` | `../wt-phase5-ace` | `Ace.rbxmx`, `src/Track2_TowerSystem/Animations/Ace.luau`, `src/Track2_TowerSystem/VFX/AceVFX.luau`, `tests/characters/ace_anim_vfx.spec.luau` |
| **Reviewer (`Codex`)** | `feat/phase5-integration` | Main / Review | ตรวจสอบคุณภาพ, Ownership Gate, Automated Tests และ Integration Verification |

### 8.2 ลำดับการ Integrate (4-Wave Integration Sequence)
- **Wave 0 (Contract Lock):** `AGY-Core` ส่ง `AnimationContract.luau` และ `VFXContract.luau` ให้ `Codex` ตรวจและล็อกอินเทอร์เฟซ
- **Wave 1 (Core Runtime + Rig Fix + Animation Lab):** `AGY-Core` ส่งมอบ `AnimationController`, `VFXDispatcher`, การแก้ `VisualBridge`, และ `AnimationLab` ให้ `Codex` ตรวจ เมื่อผ่านจึง Merge เข้า `feat/phase5-integration`
- **Wave 2 (Parallel Character Development):** Dev 1, Dev 2, Dev 3 แตก Worktree จาก `feat/phase5-integration` แล้วพัฒนา `Luffy`, `Zoro`, `Ace` แยกกันพร้อมใช้ Animation Lab ตัวเดียวกันตรวจสอบงานตนเอง
- **Wave 3 (Integration & Final Gate):** Merge ทั้ง 3 ตัวละครเข้า `feat/phase5-integration` (Zero Conflict เพราะไม่มีไฟล์ซ้ำกัน) แล้วรัน Multi-Character Stress Test (วาง Luffy + Zoro + Ace พร้อมกัน 10 / 25 / 50 ตัว)

---

## 9. Risks & Mitigation Matrix

| Risk ID | ความเสี่ยงที่อาจเกิดขึ้น | ระดับความรุนแรง | แนวทางป้องกันและแก้ไข (Mitigation) |
| :--- | :--- | :---: | :--- |
| **R-01** | `WeldConstraint` ที่ติดมากับไฟล์ `.rbxmx` หรือ `VisualBridge` ล็อกไม่ให้ `Motor6D` ขยับแขนขา | **Critical** | `AnimationController.SanitizeAndRigModel` จะลบ `WeldConstraint` ที่เชื่อมต่อกับอวัยวะที่มี `Motor6D` ออกทั้งหมด และบังคับ `Anchored = false` บนทุกชิ้นส่วนยกเว้น `RootPart` |
| **R-02** | การยืดแขนของ Luffy (`Stretch Punch`) หรือขยายหมัด (`Bajrang Fist`) ทำให้ตำแหน่งไหล่หลุดจากลำตัว | **High** | คำนวณ `RightArm.Size` ควบคู่กับการเลื่อน `RightShoulder.C0` ออกไปข้างหน้าเป็นระยะ `DeltaLength / 2` ตามสมการ `CFrame.new(0, 0, -deltaLen * 0.5)` เพื่อให้โคนแขนยึดติดหัวไหล่เสมอ |
| **R-03** | ดาบ 3 เล่มของ Zoro หลุดจากมือหรือปากขณะหมุนตัวฟัน | **High** | แยกชิ้นส่วนดาบเป็น `WadoIchimonji` (ติด `Head` ผ่าน `WeaponMouth` Motor6D), `Enma` (ติด `RightArm` ผ่าน `WeaponRight` Motor6D), และ `SandaiKitetsu` (ติด `LeftArm` ผ่าน `WeaponLeft` Motor6D) ส่วนฝักดาบ Weld เข้ากับ `Torso` |
| **R-04** | VFX Particle ของ Ace และ Luffy สร้าง Instance ค้างเมื่อ Tower ถูกขายหรือเปลี่ยนเป้าหมายเร็วๆ | **High** | บังคับให้ทุก VFX Instance สร้างผ่าน `ctx.registerInstance(inst, ttl)` ซึ่งผูกกับ Per-Model Cleanup Bucket และ `Debris` Fallback เสมอ |
| **R-05** | `ViewportFrame` ไม่แสดงผล `ParticleEmitter`, `Beam`, และ `Trail` ใน Animation Lab | **High** | ใช้ **Workspace Isolated Sandbox Stage (`Workspace.__AnimationLabSandbox`)** ร่วมกับ Scriptable Camera เป็นโหมดพรีวิวหลัก |

---

## 10. Quality & Acceptance Gates (13 Mandatory Gates)

ห้ามประกาศว่า Phase 5 เสร็จสมบูรณ์ (Complete) จนกว่าจะตรวจสอบครบทั้ง 13 ข้อต่อไปนี้:

| Gate # | รายการตรวจสอบ (Acceptance Criterion) | วิธีตรวจสอบ (Verification Method) | สถานะปัจจุบัน |
| :-: | :--- | :--- | :---: |
| **G-01** | โมเดลทั้ง 19 รายการโหลดและแสดงครบตาม Scope (3 ตัวละครแรกมี Signature Model/Rig ครบ และอีก 16 รายการโหลดผ่านโดยไม่ Error) | Automated Test + Animation Lab Model Explorer | `NOT VERIFIED` |
| **G-02** | Joint / Rig (`Motor6D`) เคลื่อนไหวได้จริงทุกข้อต่อ ไม่มีอาการโดน `WeldConstraint` หรือ `Anchored` ล็อก | Automated CFrame Delta Test + Studio Visual Check | `NOT VERIFIED` |
| **G-03** | Accessories (หมวกฟาง/เมฆของ Luffy, ดาบ 3 เล่ม/ฝักดาบของ Zoro, หมวก/สร้อย/มีดของ Ace) เคลื่อนไหวตามอวัยวะถูกต้อง | Studio Visual Check ใน Animation Lab (Toggle Accessories / Step Frame) | `NOT VERIFIED` |
| **G-04** | Animation ไม่ค้าง ไม่ซ้อนผิดจังหวะ และเมื่อกด Cancel/Reset Pose สามารถกลับสู่ท่า `RestPose` ได้โดยไม่มี CFrame Drift | Automated State Cancellation Test + Studio Timeline Scrub | `NOT VERIFIED` |
| **G-05** | VFX แสดงตำแหน่ง ทิศทาง (หันหาเป้าหมาย/Dummy Target) และจังหวะตรงกับเฟส `Wind-up -> Attack -> Impact` | Studio VFX Inspector + Dummy Target Alignment Check | `NOT VERIFIED` |
| **G-06** | **Damage ไม่ถูกเรียกซ้ำจาก Visual Event** (ทดสอบโดยยิง VFX ซ้ำหรือปิด VFX แล้วตรวจยอด Damage ต่อวินาทีว่าเท่าเดิม 100%) | Automated Combat Decoupling Spec | `NOT VERIFIED` |
| **G-07** | เมื่อ Model ถูก `:Destroy()` หรือขาย Tower จะไม่มี Animation Loop, Tween, หรือ VFX Part ค้างในหน่วยความจำ | Automated Leak Test (`totalCreated == totalCleaned`) | `NOT VERIFIED` |
| **G-08** | Animation Lab ไม่แก้ไข Gameplay State (เงิน, Gacha, Inventory, Wave Progress, Player Stats ไม่เปลี่ยนแปลง) | Automated Sandbox Isolation Spec | `NOT VERIFIED` |
| **G-09** | ทดสอบวางและสั่งโจมตีหลายตัวละครพร้อมกัน (Luffy + Zoro + Ace ร่วมกับ Tower อื่น) โดยไม่เกิด Error หรือการแย่ง State | Studio Multi-Character Scenario Test | `NOT VERIFIED` |
| **G-10** | ตรวจสอบ Performance ภายใต้ Budget ที่เสนอ (10 / 25 / 50 Active Characters) พร้อมบันทึกค่าจริงจาก Studio | Animation Lab Stress Test + MicroProfiler | `NOT VERIFIED` |
| **G-11** | Automated Tests ทั้งหมด (ของเดิม Phase 1–4 และของใหม่ Phase 5) ผ่าน 100% | Test Runner CLI / Studio TestService | `NOT VERIFIED` |
| **G-12** | Roblox Studio Visual Test ผ่านครบทุก Checklist ของ Luffy, Zoro, Ace และ Animation Lab | Manual Studio Verification พร้อมแนบหลักฐาน Screenshot/Log | `NOT VERIFIED` |
| **G-13** | ไม่มีการแก้ไข Source Code นอกเหนือจากตาราง Ownership Matrix โดยไม่ได้รับอนุมัติ | `git diff --name-only` ตรวจโดย Codex | `NOT VERIFIED` |
&lt;!-- === FILE_END: docs/implementation-plans/0005-character-model-animation/PLAN.md === --&gt;

---

&lt;!-- === FILE_START: docs/implementation-plans/0005-character-model-animation/characters/01-luffy.md === --&gt;
# Character Implementation Plan 01 — Luffy Gear 5 (`Luffy.rbxmx`)

- **Document ID:** `0005-character-model-animation/characters/01-luffy.md`
- **Assigned Developer:** Developer 1 (`AGY-Char-Luffy`)
- **Git Branch:** `feat/phase5-char-luffy`
- **Git Worktree:** `../wt-phase5-luffy`
- **Target Model:** `Luffy.rbxmx`
- **Verification Status:** `NOT VERIFIED` (Planning Stage Only)

---

## 1. Existing Model Analysis (`Luffy.rbxmx`)

1. **โครงสร้างปัจจุบันใน Phase 4 Baseline:**
   - โมเดล `Luffy.rbxmx` เป็น Part-based Character Model ที่แทนตัวละคร Luffy
   - ปัญหาที่พบในโครงสร้างเดิม:
     - ชิ้นส่วนร่างกาย (`Torso`, `Head`, `LeftArm`, `RightArm`, `LeftLeg`, `RightLeg`) และชิ้นส่วนประดับ (หมวกฟาง, ผ้าพันเอว, เมฆ/เอฟเฟกต์) ถูก `VisualBridge.server.luau` ทำการ Weld เข้ากับ Root แบบแข็ง (`WeldConstraint`) หรือตั้ง `Anchored = true` ทำให้เมื่อ `TowerController` พยายามขยับข้อต่อในจังหวะโจมตี แขนไม่ยืดออกไปหาเป้าหมายอย่างอิสระ และหมวกฟาง/เมฆไม่ขยับตามศีรษะและลำตัว
     - ยังขาดเอกลักษณ์ของ **Gear 5 (Sun God Nika)** ที่ชัดเจน เช่น ทรงผมสีขาวสว่างเรืองแสง (`White Hair Glow`), วงผ้าคลุมเมฆลอยรอบคอและไหล่ (`Awakened Cloud Scarf`), และรอยแผลเป็นรูปกากบาทที่หน้าอก

---

## 2. Model Improvement Requirements (ปรับปรุงจากโมเดลเดิม ไม่สร้างใหม่ทั้งหมดโดยไม่จำเป็น)

1. **เอกลักษณ์และสีสันของ Luffy Gear 5:**
   - **ทรงผมและคิ้ว (`HairMesh` / `HairParts`):** ปรับสีเป็นสีขาวบริสุทธิ์ (`Color3.fromRGB(248, 248, 255)`) Material = `Neon` (หรือ `SmoothPlastic` ผสาน `Highlight` ขอบขาวนวล) รูปทรงพริ้วเหมือนเปลวเมฆ
   - **ดวงตาและรอยยิ้ม (`FaceDecal` / `EyeParts`):** ดวงตาสีแดงทับทิมวงแหวน (`Color3.fromRGB(220, 40, 60)`) พร้อมรอยยิ้มกว้างแบบ Nika
   - **เสื้อกั๊กและกางเกงขาสั้น (`Torso`, `LeftLeg`, `RightLeg`):** เสื้อและกางเกงสีขาว (`Color3.fromRGB(240, 240, 245)`) คาดด้วยผ้าคาดเอวสีม่วงเข้ม (`Sash`, `Color3.fromRGB(115, 60, 165)`)
   - **หมวกฟางสะพายหลัง (`StrawHat`):** หมวกฟางสีเหลืองทองคาดแถบแดง คล้องเชือกสะพายไว้ด้านหลังคอ (ยึดติดกับ `Torso` ด้วยมุมเอียง `CFrame.Angles(math.rad(-55), 0, 0)` เพื่อให้กระเด้งตามจังหวะลำตัว)
   - **ผ้าคลุมเมฆตื่นรู้ (`CloudScarf`):** สร้างจาก `Part` ทรง `Ball` / `Cylinder` สีขาวนวล (`Material = SmoothPlastic`, `Transparency = 0.08`) เรียงโค้งเป็นวงรอบไหล่และด้านหลังคอ จำนวนไม่เกิน 5 ชิ้นย่อย (เพื่อคุม Draw Calls)
2. **งบประมาณจำนวนชิ้นส่วน (Part & Draw Call Budget):**
   - จำนวน `BasePart` ทั้งหมดของ `Luffy.rbxmx` ต้อง **ไม่เกิน 22 Parts** (Core Limbs 7 + StrawHat 2 + Sash 1 + Hair/Scarf 8–12)
   - ทุก Part ยกเว้น `HumanoidRootPart` ต้องตั้งค่า:
     - `Anchored = false`
     - `CanCollide = false`
     - `CanTouch = false`
     - `CanQuery = false`
     - `Massless = true`

---

## 3. Rig Mapping & Joint Specification

### 3.1 ตาราง `Motor6D` ทั้ง 6 ข้อต่อหลัก
| Joint Name (`AnimationContract`) | `Part0` (Parent) | `Part1` (Child) | `BaseC0` (Rest Pose Offset บน `Part0`) | `BaseC1` (Pivot Offset บน `Part1`) | หน้าที่ในการเคลื่อนไหว |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`RootJoint`** | `HumanoidRootPart` | `Torso` | `CFrame.new(0, 0, 0)` | `CFrame.new(0, 0, 0)` | ควบคุมการเด้งขึ้น-ลง (Joyboy Bounce), การเอนตัวไปด้านหลังตอนง้างหมัด และการพุ่งตัว |
| **`Neck`** | `Torso` | `Head` | `CFrame.new(0, 1.5, 0)` | `CFrame.new(0, -0.5, 0)` | ควบคุมการแหงนหัวหัวเราะและการหันมองเป้าหมาย |
| **`RightShoulder`** | `Torso` | `RightArm` | `CFrame.new(1.5, 0.5, 0)` | `CFrame.new(0, 0.5, 0)` | **ข้อต่อหลักสำหรับ `Stretch Punch` และ `Bajrang Fist`** (หมุนหัวไหล่ + เลื่อนตำแหน่งยืดแขน) |
| **`LeftShoulder`** | `Torso` | `LeftArm` | `CFrame.new(-1.5, 0.5, 0)` | `CFrame.new(0, 0.5, 0)` | ยกมือป้องหน้า/เท้าเอว หรือยกมือประคองตอนปล่อยพลัง |
| **`RightHip`** | `Torso` | `RightLeg` | `CFrame.new(0.5, -1.0, 0)` | `CFrame.new(0, 1.0, 0)` | ย่อเข่าและกระโดดลอยตัวในท่า Gear 5 |
| **`LeftHip`** | `Torso` | `LeftLeg` | `CFrame.new(-0.5, -1.0, 0)` | `CFrame.new(0, 1.0, 0)` | ย่อเข่าสลับจังหวะเด้งตัวในท่า Idle |

### 3.2 ตารางการยึด Accessories (`accessoryRules`)
| ชื่อชิ้นส่วน Accessory | ยึดเข้ากับ (`attachToLimb`) | ชนิดการเชื่อมต่อ | ค่า Offset มาตรฐาน |
| :--- | :--- | :--- | :--- |
| `StrawHat` (หมวกฟางสะพายหลัง) | `Torso` | `WeldConstraint` | `CFrame.new(0, 0.85, 0.75) * CFrame.Angles(math.rad(-60), 0, 0)` |
| `CloudScarf` (วงเมฆรอบไหล่) | `Torso` | `WeldConstraint` | `CFrame.new(0, 1.15, 0.15)` |
| `WaistSash` (ผ้าคาดเอวสีม่วง) | `Torso` | `WeldConstraint` | `CFrame.new(0, -0.85, 0)` |
| `HairCloud` (ผมสีขาว Gear 5) | `Head` | `WeldConstraint` | `CFrame.new(0, 0.65, 0.05)` |

---

## 4. Signature Animations Specification (`src/Track2_TowerSystem/Animations/Luffy.luau`)

ตัวละคร Luffy Gear 5 ต้องแสดงความรู้สึก **"อิสระ ยืดหยุ่น กระเด้งเหมือนการ์ตูน (Toon Rubber Physics)"** แตกต่างจากนักดาบอย่าง Zoro หรือผู้ใช้ไฟอย่าง Ace อย่างชัดเจน:

| Animation State | Duration (Base) | Looped | Can Cancel | รายละเอียดท่าทางและคีย์เฟรม (`CFrame` & `Scale` Mechanics) | VFX Cue ที่ส่งออก |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **`Idle` (Gear 5 Joyboy Bounce)** | `1.20s` | `true` | `true` | - `alpha 0.0 -> 0.5`: `RootJoint` ลอยตัวขึ้น `+0.45 studs` พร้อมเอียงตัวเบาๆ `CFrame.Angles(math.rad(6), 0, math.rad(4))`, เข่าทั้งสองข้าง (`RightHip`, `LeftHip`) งอขึ้นแบบก้าวกระโดดในอากาศ แขนสองข้างแกว่งเป็นจังหวะกลองแห่งการปลดปล่อย<br>- `alpha 0.5 -> 1.0`: ลงสู่จังหวะย่อตัวพร้อมดีดตัวขึ้นใหม่ | `"PassiveAura"` |
| **`SpecialIdle` (Nika Belly Laugh)** | `1.80s` | `false` | `true` | - เอนตัวไปด้านหลัง `RootJoint` หมุน `math.rad(25)` มือซ้ายกุมท้อง มือขวาบังหน้าผาก ศีรษะแหงนหัวเราะสั่นขึ้นลง 3 จังหวะ | `"NikaLaughPuff"` |
| **`Spawn` (Sky Bounce Drop)** | `0.65s` | `false` | `false` | - เริ่มจาก `RootJoint` สูง `+6.0 studs` พุ่งลงมากระแทกพื้นแล้วยืดหดตัวแบบยาง (`Squash & Stretch`) ก่อนดีดกลับสู่ท่า `Idle` | `"SpawnDeploy"` |
| **`Windup` (Rubber Arm Coil Back)** | `0.25s` | `false` | `true` | - บิดลำตัว `RootJoint` ไปทางขวา `-35 deg` ดึง `RightShoulder` ถอยไปด้านหลังลำตัว `CFrame.new(0.4, 0, 1.8) * CFrame.Angles(math.rad(90), 0, math.rad(25))` พร้อมบิดเกลียวแขนและเคลือบฮาคิสีดำ-แดงที่หมัดขวา | `"AttackWindup"` |
| **`Attack` (Gomu Gomu no Stretch Punch)** | `0.20s` | `false` | `false` | - บิดลำตัวกลับด้านหน้า `+30 deg` พร้อม **ยืดความยาวของ `RightArm`** ออกไปหาเป้าหมาย (`Stretch Factor` คำนวณจากระยะห่างแต่จำกัดไม่เกิน `14 studs` ใน Visual) โดยเลื่อน `RightShoulder.C0` ไปด้านหน้า `CFrame.new(0, 0, -stretchLen * 0.5)` และขยายขนาดหมัดส่วนปลาย (`scaleMultiplier = Vector3.new(1.8, 1.8, stretchScaleZ)`) | `"AttackRelease"` |
| **`Impact` (Haki Rubber Snap)** | `0.15s` | `false` | `false` | - หมัดขวาหยุดค้างที่จุดปะทะพร้อมสั่น (`Micro-Vibration`) 2 เฟรม เพื่อเน้นแรงกระแทก (Hit-Stop Feel) ในจังหวะเดียวกับที่สายฟ้าฮาคิราชันย์ระเบิดออกที่เป้าหมาย | `"AttackImpact"` |
| **`Recovery` (Elastic Snap-Back)** | `0.40s` | `false` | `true` | - แขนขวาหดกลับด้วย `Enum.EasingStyle.Elastic` (`Out`) คืนขนาด `RightArm.Size` เดิม 100% และหมุนไหล่กลับสู่ `RestPose` | `nil` |
| **`Ultimate` (Bajrang Fist — Island-Sized God Fist)** | `2.10s` | `false` | `false` | - **Phase 1 (0.0–0.7s Ascend & Inflate):** Luffy ลอยตัวสูงขึ้น (`RootJoint +4.5 studs`) ชูแขนขวาขึ้นเหนือหัว สร้างทรงกลมหมัดยักษ์เคลือบฮาคิ (`BajrangFistConstruct`) เหนือเมฆ<br>- **Phase 2 (0.7–1.3s God Slam):** เหวี่ยงแขนขวาทุบลงมาด้านหน้าด้วยความเร็วสูง<br>- **Phase 3 (1.3–2.1s Shockwave & Rebound):** พื้นยุบเกิดคลื่นเมฆขาวและสายฟ้าดำ-แดงก่อนดีดตัวกลับลงมายืน | `"UltimateCast"` -> `"UltimateImpact"` |

---

## 5. Character-Specific VFX Specification (`src/Track2_TowerSystem/VFX/LuffyVFX.luau`)

| VFX Cue | รายละเอียดเอฟเฟกต์ (Visual Elements) | การใช้ Instance & อายุขัย (TTL / Cleanup) | การปรับตาม Quality Preset (`Low / Med / High`) |
| :--- | :--- | :--- | :--- |
| **`PassiveAura` (Drums of Liberation Cloud & Sparks)** | - ละอองเมฆสีขาวนวลลอยขึ้นรอบตัว (`Rate = 6` บน High)<br>- ประกายสายฟ้าสีแดง-ดำขนาดเล็กแลบเป็นระยะรอบหมัดขวา | ผูกกับ `Torso` และ `RightArm` ลบออกทันทีเมื่อ `cleanupAllForModel` ถูกเรียก | `Low`: ปิดสายฟ้ารอบหมัด เหลือเฉพาะ Highlight ขอบขาว<br>`Med`: เปิดเมฆ 50%<br>`High`: เปิดครบทุกเลเยอร์ |
| **`AttackWindup` (Armament + Conqueror Charge)** | - เปลี่ยนสีส่วนปลายหมัดขวาเป็นสีดำเงาขอบแดง (`Highlight` หรือ `MeshPart` Overlay) พร้อมวงแหวนอัดอากาศสีขาวที่ข้อศอก | TTL = `0.30s` (ผ่าน `ctx.registerInstance`) | `Low`: 1 Part<br>`Med`: 2 Parts<br>`High`: 3 Parts + Particle Burst 8 เม็ด |
| **`AttackRelease` (Rubber Sonic Rings)** | - วงแหวนอากาศสีขาว (`Cylinder/Ring Part` โปร่งแสง `Transparency 0.3 -> 1.0`) เรียงตามแนวแขนที่ยืดออกไป 2–3 วง | TTL = `0.25s` ขยายขนาดแล้วจางหายด้วย Tracked Tween | `Low`: 1 วง<br>`Med`: 2 วง<br>`High`: 3 วง + Beam เส้นแรงดึงยาง |
| **`AttackImpact` (Conqueror Haki Black-Red Lightning Burst)** | - เส้นสายฟ้าหยักสีดำแกนแดงเข้ม (`Color3.fromRGB(200, 20, 40)` + ขอบดำ) พุ่งกระจายออกจากจุด `targetPosition` 3–5 แฉก พร้อมวงกระแทกพื้นสีขาว | TTL = `0.35s`, สร้างที่พิกัด `ctx.targetPosition` | `Low`: วงกระแทก 1 ชิ้น + สายฟ้า 2 เส้น<br>`Med`: สายฟ้า 3 เส้น<br>`High`: สายฟ้า 5 เส้น + `:Emit(16)` + Subtle Camera Impulse |
| **`UltimateCast` & `UltimateImpact` (Bajrang Fist)** | - สร้างทรงกลมเมฆหมุนวนและหมัดยักษ์สีดำ-แดงเหนือศีรษะ (`Size = Vector3.new(8, 8, 8)`) พุ่งลงกระแทกจุดเป้าหมาย เกิดโดมคลื่นกระแทกสีขาวและสายฟ้าฮาคิราชันย์ขนาดใหญ่ | TTL = `1.50s` จำกัดจำนวน Part สูงสุดไม่เกิน 14 ชิ้นต่อการกด Ultimate 1 ครั้ง | `Low`: ลดจำนวนสายฟ้าเหลือ 4 เส้น ไม่ทำ Screen Flash<br>`High`: เต็มรูปแบบพร้อม Screen Flash สีขาว-แดง `0.12s` |

---

## 6. Step-by-Step Implementation Tasks (Developer 1)

1. **Task L-1 (Model & Rig Preparation):**
   - ตรวจสอบ `Luffy.rbxmx` ตั้งชื่ออวัยวะหลักให้ตรงตามมาตรฐาน (`HumanoidRootPart`, `Torso`, `Head`, `RightArm`, `LeftArm`, `RightLeg`, `LeftLeg`)
   - จัดกลุ่มชิ้นส่วน `StrawHat`, `CloudScarf`, `WaistSash`, `HairCloud` และตั้งค่า `Anchored = false`, `CanCollide = false`, `Massless = true`
2. **Task L-2 (Implement `src/Track2_TowerSystem/Animations/Luffy.luau`):**
   - สร้าง `CharacterAnimationProfile` ตาม `AnimationContract.luau`
   - เขียนตาราง Keyframes ของทั้ง 8 States (`Idle`, `SpecialIdle`, `Spawn`, `Windup`, `Attack`, `Impact`, `Recovery`, `Ultimate`) พร้อมฟังก์ชันคำนวณการยืดหดแขนขวา (`RightShoulder` + `RightArm` scale restoration)
3. **Task L-3 (Implement `src/Track2_TowerSystem/VFX/LuffyVFX.luau`):**
   - สร้างฟังก์ชัน `startPassiveAura`, `stopPassiveAura`, `triggerCue`, และ `cleanupAllForModel` ตาม `VFXContract.luau`
   - ทุก Part และ Tween ต้องลงทะเบียนผ่าน `ctx.registerInstance` และ `ctx.registerTween` เท่านั้น
4. **Task L-4 (Write Automated Spec `tests/characters/luffy_anim_vfx.spec.luau`):**
   - ทดสอบว่าเมื่อโหลด `Luffy.luau` และสร้าง Rig บนโมเดลจำลอง ข้อต่อทั้ง 6 ขยับเปลี่ยน `C0` ได้จริง
   - ทดสอบว่าหลังจบเฟส `Attack -> Recovery` ขนาดของ `RightArm.Size` และ `RightShoulder.C0` กลับคืนค่าตั้งต้น 100% (ความคลาดเคลื่อน `< 0.001`)
   - ทดสอบว่า `cleanupAllForModel` ล้าง VFX Instance เหลือ `0`

---

## 7. File Ownership, Visual Acceptance Criteria & Risks

- **Owned Files:** `Luffy.rbxmx`, `src/Track2_TowerSystem/Animations/Luffy.luau`, `src/Track2_TowerSystem/VFX/LuffyVFX.luau`, `tests/characters/luffy_anim_vfx.spec.luau`
- **Visual Acceptance Criteria (ต้องตรวจใน Animation Lab):**
  1. ในท่า `Idle` ตัวของ Luffy ต้องเด้งขึ้น-ลงอย่างมีชีวิตชีวาและผ้าคลุมเมฆ + หมวกฟางต้องขยับตามลำตัวโดยไม่ลอยค้าง
  2. ในท่า `Attack` แขนขวาต้องยืดพุ่งไปข้างหน้าโดยโคนแขนยังติดอยู่กับหัวไหล่ และหดกลับมาขนาดเดิมทันทีในเฟส `Recovery` แม้จะกด Cancel หรือเปลี่ยนความเร็วเป็น `2.0x`
  3. เอฟเฟกต์สายฟ้าฮาคิราชันย์สีดำ-แดงต้องเกิดตรงตำแหน่ง `Dummy Target` พอดีในเฟส `Impact`
- **Known Risks:** หากโดน Cancel กลางจังหวะ `Attack` ที่แขนกำลังยืดอยู่ ถ้าไม่รีเซ็ต `RightArm.Size` ในฟังก์ชัน `ResetPose()` แขนจะค้างยาวผิดปกติ **วิธีแก้:** บันทึก `OriginalRightArmSize` ไว้ใน `RigContext` และคืนค่าทุกครั้งที่มีการเปลี่ยน State หรือ `ResetPose()`


---

## 8. Hand-Holding Luau Code Blueprints for Developer 1 (`Luffy.luau`, `LuffyVFX.luau`, & Spec)

### 8.1 พิมพ์เขียว `src/Track2_TowerSystem/Animations/Luffy.luau`
\`\`\`luau
--!strict
-- src/Track2_TowerSystem/Animations/Luffy.luau
-- Owned by: Developer 1 (AGY-Char-Luffy)
-- Character: Luffy Gear 5 (Sun God Nika)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationContract = require(ReplicatedStorage.Shared.AnimationContract)

local rad = math.rad
local cf = CFrame.new
local ang = CFrame.Angles

local LuffyAnimationProfile: AnimationContract.CharacterAnimationProfile = {
	heroId = "Luffy",
	displayName = "Luffy (Gear 5)",
	rigType = "Articulated6Joint",
	expectedJoints = {
		"RootJoint",
		"Neck",
		"RightShoulder",
		"LeftShoulder",
		"RightHip",
		"LeftHip",
	},
	accessoryRules = {
		{
			accessoryNamePattern = "StrawHat",
			attachToLimb = "Torso",
			offsetCFrame = cf(0, 0.85, 0.75) * ang(rad(-60), 0, 0),
			useMotor6D = false,
		},
		{
			accessoryNamePattern = "CloudScarf",
			attachToLimb = "Torso",
			offsetCFrame = cf(0, 1.15, 0.15),
			useMotor6D = false,
		},
		{
			accessoryNamePattern = "WaistSash",
			attachToLimb = "Torso",
			offsetCFrame = cf(0, -0.85, 0),
			useMotor6D = false,
		},
		{
			accessoryNamePattern = "HairCloud",
			attachToLimb = "Head",
			offsetCFrame = cf(0, 0.65, 0.05),
			useMotor6D = false,
		},
	},
	baseScale = 1.0,
	attackCycleTimings = {
		windupRatio = 0.25,
		attackRatio = 0.20,
		impactRatio = 0.15,
		recoveryRatio = 0.40,
	},
	states = {
		Idle = {
			state = "Idle",
			duration = 1.20,
			looped = true,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					easingStyle = Enum.EasingStyle.Sine,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = cf(0, 0.05, 0) * ang(rad(4), 0, rad(-3)),
						Neck = ang(rad(5), rad(4), 0),
						RightShoulder = cf(0, 0.05, 0) * ang(rad(35), 0, rad(20)),
						LeftShoulder = cf(0, 0.05, 0) * ang(rad(-25), 0, rad(-20)),
						RightHip = ang(rad(-18), 0, 0),
						LeftHip = ang(rad(14), 0, 0),
					},
					vfxCue = "PassiveAura",
				},
				{
					alpha = 0.5,
					easingStyle = Enum.EasingStyle.Sine,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = cf(0, 0.48, 0) * ang(rad(-6), 0, rad(4)),
						Neck = ang(rad(12), rad(-4), 0),
						RightShoulder = cf(0, 0.15, 0) * ang(rad(-30), 0, rad(32)),
						LeftShoulder = cf(0, 0.15, 0) * ang(rad(40), 0, rad(-28)),
						RightHip = ang(rad(22), 0, rad(5)),
						LeftHip = ang(rad(-24), 0, rad(-5)),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Sine,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = cf(0, 0.05, 0) * ang(rad(4), 0, rad(-3)),
						Neck = ang(rad(5), rad(4), 0),
						RightShoulder = cf(0, 0.05, 0) * ang(rad(35), 0, rad(20)),
						LeftShoulder = cf(0, 0.05, 0) * ang(rad(-25), 0, rad(-20)),
						RightHip = ang(rad(-18), 0, 0),
						LeftHip = ang(rad(14), 0, 0),
					},
				},
			},
		},

		SpecialIdle = {
			state = "SpecialIdle",
			duration = 1.80,
			looped = false,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, 0.1, 0),
						Neck = cf(),
						RightShoulder = cf(),
						LeftShoulder = cf(),
					},
				},
				{
					alpha = 0.4,
					easingStyle = Enum.EasingStyle.Back,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						RootJoint = cf(0, 0.25, 0.2) * ang(rad(24), 0, 0),
						Neck = ang(rad(28), 0, 0),
						RightShoulder = ang(rad(150), 0, rad(-25)),
						LeftShoulder = ang(rad(45), 0, rad(30)),
						RightHip = ang(rad(-15), 0, 0),
						LeftHip = ang(rad(-15), 0, 0),
					},
				},
				{
					alpha = 1.0,
					poses = {
						RootJoint = cf(0, 0.05, 0),
						Neck = cf(),
						RightShoulder = cf(),
						LeftShoulder = cf(),
						RightHip = cf(),
						LeftHip = cf(),
					},
				},
			},
		},

		Spawn = {
			state = "Spawn",
			duration = 0.65,
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, 5.5, 0) * ang(rad(-15), 0, 0),
						RightShoulder = ang(rad(140), 0, rad(25)),
						LeftShoulder = ang(rad(140), 0, rad(-25)),
						RightHip = ang(rad(35), 0, 0),
						LeftHip = ang(rad(-35), 0, 0),
					},
					vfxCue = "SpawnDeploy",
				},
				{
					alpha = 0.65,
					easingStyle = Enum.EasingStyle.Bounce,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						RootJoint = cf(0, -0.35, 0) * ang(rad(10), 0, 0),
						RightShoulder = ang(rad(20), 0, rad(40)),
						LeftShoulder = ang(rad(20), 0, rad(-40)),
						RightHip = ang(rad(-30), 0, 0),
						LeftHip = ang(rad(-30), 0, 0),
					},
				},
				{
					alpha = 1.0,
					poses = {
						RootJoint = cf(0, 0.05, 0),
						RightShoulder = cf(),
						LeftShoulder = cf(),
						RightHip = cf(),
						LeftHip = cf(),
					},
				},
			},
		},

		Windup = {
			state = "Windup",
			duration = 0.25,
			looped = false,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, 0, 0),
						RightShoulder = cf(),
						LeftShoulder = cf(),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Back,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						RootJoint = cf(0, -0.15, 0.35) * ang(rad(8), rad(-42), 0),
						Neck = ang(0, rad(38), 0),
						RightShoulder = cf(0.35, 0.1, 1.45) * ang(rad(92), rad(-20), rad(25)),
						LeftShoulder = ang(rad(65), 0, rad(-30)),
						RightHip = ang(rad(-22), 0, 0),
						LeftHip = ang(rad(26), 0, 0),
					},
					vfxCue = "AttackWindup",
				},
			},
		},

		Attack = {
			state = "Attack",
			duration = 0.20,
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, -0.15, 0.35) * ang(rad(8), rad(-42), 0),
						RightShoulder = cf(0.35, 0.1, 1.45) * ang(rad(92), rad(-20), rad(25)),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Expo,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						RootJoint = cf(0, 0.05, -0.65) * ang(rad(-12), rad(35), 0),
						Neck = ang(rad(6), rad(-30), 0),
						-- ยืดแขนขวาออกไปข้างหน้าพร้อมเลื่อนจุดกึ่งกลาง
						RightShoulder = cf(0, 0.15, -4.5) * ang(rad(90), 0, 0),
						LeftShoulder = ang(rad(-35), 0, rad(-25)),
						RightHip = ang(rad(28), 0, 0),
						LeftHip = ang(rad(-24), 0, 0),
					},
					scaleMultiplier = Vector3.new(1.65, 1.65, 4.5),
					vfxCue = "AttackRelease",
				},
			},
		},

		Impact = {
			state = "Impact",
			duration = 0.15,
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, 0.05, -0.65) * ang(rad(-12), rad(35), 0),
						RightShoulder = cf(0, 0.15, -4.8) * ang(rad(90), 0, rad(5)),
					},
					scaleMultiplier = Vector3.new(1.85, 1.85, 4.8),
					vfxCue = "AttackImpact",
				},
				{
					alpha = 1.0,
					poses = {
						RootJoint = cf(0, 0.05, -0.55) * ang(rad(-10), rad(30), 0),
						RightShoulder = cf(0, 0.15, -4.2) * ang(rad(90), 0, rad(-5)),
					},
					scaleMultiplier = Vector3.new(1.5, 1.5, 4.0),
				},
			},
		},

		Recovery = {
			state = "Recovery",
			duration = 0.40,
			looped = false,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, 0.05, -0.55) * ang(rad(-10), rad(30), 0),
						RightShoulder = cf(0, 0.15, -4.2) * ang(rad(90), 0, 0),
					},
					scaleMultiplier = Vector3.new(1.5, 1.5, 4.0),
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Elastic,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						RootJoint = cf(0, 0.05, 0),
						Neck = cf(),
						RightShoulder = cf(),
						LeftShoulder = cf(),
						RightHip = cf(),
						LeftHip = cf(),
					},
					scaleMultiplier = Vector3.new(1.0, 1.0, 1.0),
				},
			},
		},

		Ultimate = {
			state = "Ultimate",
			duration = 2.10,
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, 0.2, 0),
						RightShoulder = ang(rad(45), 0, 0),
					},
				},
				{
					alpha = 0.35,
					easingStyle = Enum.EasingStyle.Cubic,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						RootJoint = cf(0, 4.2, 0.4) * ang(rad(15), rad(-25), 0),
						Neck = ang(rad(35), 0, 0),
						RightShoulder = cf(0, 1.2, 0) * ang(rad(175), 0, rad(15)),
						LeftShoulder = ang(rad(60), 0, rad(-40)),
						RightHip = ang(rad(-35), 0, 0),
						LeftHip = ang(rad(20), 0, 0),
					},
					scaleMultiplier = Vector3.new(2.8, 2.8, 2.8),
					vfxCue = "UltimateCast",
				},
				{
					alpha = 0.65,
					easingStyle = Enum.EasingStyle.Expo,
					easingDirection = Enum.EasingDirection.In,
					poses = {
						RootJoint = cf(0, 1.2, -1.2) * ang(rad(-28), rad(30), 0),
						Neck = ang(rad(-15), 0, 0),
						RightShoulder = cf(0, -0.5, -5.0) * ang(rad(80), 0, 0),
						LeftShoulder = ang(rad(-45), 0, rad(-30)),
					},
					scaleMultiplier = Vector3.new(3.2, 3.2, 4.5),
					vfxCue = "UltimateImpact",
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Elastic,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						RootJoint = cf(0, 0.05, 0),
						Neck = cf(),
						RightShoulder = cf(),
						LeftShoulder = cf(),
						RightHip = cf(),
						LeftHip = cf(),
					},
					scaleMultiplier = Vector3.new(1.0, 1.0, 1.0),
				},
			},
		},
	},
}

return table.freeze(LuffyAnimationProfile)
\`\`\`

### 8.2 พิมพ์เขียว `tests/characters/luffy_anim_vfx.spec.luau`
\`\`\`luau
--!strict
-- tests/characters/luffy_anim_vfx.spec.luau
-- Automated Verification Spec สำหรับ Developer 1 (Luffy Gear 5)

return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ServerScriptService = game:GetService("ServerScriptService")

	local AnimationContract = require(ReplicatedStorage.Shared.AnimationContract)
	local LuffyProfile = require(ServerScriptService.Track2_TowerSystem.Animations.Luffy)
	local AnimationController = require(ServerScriptService.Track2_TowerSystem.AnimationController)

	describe("Phase 5 — Luffy Gear 5 Animation & Rig Verification", function()
		it("should expose all required states and valid attackCycleTimings", function()
			expect(LuffyProfile.heroId).to.equal("Luffy")
			expect(LuffyProfile.states.Idle).to.be.ok()
			expect(LuffyProfile.states.Windup).to.be.ok()
			expect(LuffyProfile.states.Attack).to.be.ok()
			expect(LuffyProfile.states.Impact).to.be.ok()
			expect(LuffyProfile.states.Recovery).to.be.ok()
			expect(LuffyProfile.states.Ultimate).to.be.ok()

			local t = LuffyProfile.attackCycleTimings
			local sum = t.windupRatio + t.attackRatio + t.impactRatio + t.recoveryRatio
			expect(math.abs(sum - 1.0) < 0.001).to.equal(true)
		end)

		it("should strip conflicting WeldConstraints on limbs and restore RightArm size after Stretch Punch", function()
			local mockModel = Instance.new("Model")
			mockModel.Name = "Luffy"
			local root = Instance.new("Part")
			root.Name = "HumanoidRootPart"
			root.Size = Vector3.new(2, 2, 1)
			root.Anchored = true
			root.Parent = mockModel
			mockModel.PrimaryPart = root

			local torso = Instance.new("Part")
			torso.Name = "Torso"
			torso.Size = Vector3.new(2, 2, 1)
			torso.Anchored = true -- ตั้งใจใส่ Anchored = true เพื่อทดสอบว่า SanitizeAndRigModel ปลดล็อกให้เป็น false
			torso.Parent = mockModel

			local rightArm = Instance.new("Part")
			rightArm.Name = "RightArm"
			rightArm.Size = Vector3.new(1, 2, 1)
			rightArm.Anchored = true
			rightArm.Parent = mockModel

			-- จำลองปัญหาของ VisualBridge เดิมที่สร้าง WeldConstraint ล็อก RightArm เข้ากับ Root
			local badWeld = Instance.new("WeldConstraint")
			badWeld.Part0 = root
			badWeld.Part1 = rightArm
			badWeld.Parent = rightArm

			local rigCtx = AnimationController.SanitizeAndRigModel(mockModel, LuffyProfile)
			expect(rigCtx).to.be.ok()
			expect(root.Anchored).to.equal(true)
			expect(torso.Anchored).to.equal(false)
			expect(rightArm.Anchored).to.equal(false)
			expect(rightArm:FindFirstChildWhichIsA("WeldConstraint")).to.equal(nil)
			expect(rigCtx.motors.RightShoulder).to.be.ok()

			mockModel:Destroy()
		end)
	end)
end
\`\`\`

&lt;!-- === FILE_END: docs/implementation-plans/0005-character-model-animation/characters/01-luffy.md === --&gt;

---

&lt;!-- === FILE_START: docs/implementation-plans/0005-character-model-animation/characters/02-zoro.md === --&gt;
# Character Implementation Plan 02 — Zoro King of Hell (`Zoro.rbxmx`)

- **Document ID:** `0005-character-model-animation/characters/02-zoro.md`
- **Assigned Developer:** Developer 2 (`AGY-Char-Zoro`)
- **Git Branch:** `feat/phase5-char-zoro`
- **Git Worktree:** `../wt-phase5-zoro`
- **Target Model:** `Zoro.rbxmx`
- **Verification Status:** `NOT VERIFIED` (Planning Stage Only)

---

## 1. Existing Model Analysis (`Zoro.rbxmx`)

1. **โครงสร้างปัจจุบันใน Phase 4 Baseline:**
   - โมเดล `Zoro.rbxmx` เป็น Part-based Character Model ของ Roronoa Zoro
   - ปัญหาสำคัญที่พบในโครงสร้างเดิม:
     - ดาบของ Zoro ถูกวางเป็น Part ย่อยที่ถูก `VisualBridge` เชื่อมด้วย `WeldConstraint` เข้ากับ RootPart โดยตรง ทำให้เมื่อแขนขวา/แขนซ้ายหรือศีรษะหมุน ตัวดาบไม่เคลื่อนที่ตามมือและปาก หรือดาบแกว่งทะลุลำตัว
     - ยังไม่ได้แยกข้อต่อสำหรับ **วิชาดาบ 3 เล่ม (Santoryu Rig)** อย่างชัดเจน (`Wado Ichimonji` ที่ปาก, `Enma` ที่มือขวา, `Sandai Kitetsu` ที่มือซ้าย และฝักดาบทั้ง 3 ที่เอวขวา)

---

## 2. Model Improvement Requirements

1. **เอกลักษณ์ของ Zoro (King of Hell / Onigashima Coat Style):**
   - **ทรงผมและผ้าโพกหัว (`HairParts` / `Bandana`):** ผมสีเขียวสด (`Color3.fromRGB(60, 185, 95)`) หรือโหมดสวมผ้าโพกหัวสีดำเข้มพร้อมแผลเป็นที่ตาซ้าย
   - **ชุดคลุมสีดำคาดแดง (`Torso`, `Legs`):** เสื้อคลุมยาวสีดำเข้ม เปิดอกเห็นรอยแผลเป็นพาดขวาง คาดด้วยผ้าคาดเอวสีแดงเข้ม (`Color3.fromRGB(180, 30, 35)`)
   - **ดาบทั้ง 3 เล่ม (Three-Sword Precision Modeling):**
     - `WadoIchimonji` (ดาบปลอก/ด้ามสีขาว): คาบไว้ที่ปากในแนวนอน (`Part0 = Head`)
     - `Enma` (ดาบด้ามสีม่วงเข้มประดับทอง): ถือในมือขวา (`Part0 = RightArm`) พร้อมจุด Attachment `BladeTip` และ `BladeBase` สำหรับผูก `Trail` และไฟฮาคิสีเขียว-ม่วง
     - `SandaiKitetsu` (ดาบด้ามสีแดงเข้ม): ถือในมือซ้าย (`Part0 = LeftArm`) พร้อมจุด Attachment `BladeTip` และ `BladeBase` สำหรับผูก `Trail`
     - `SwordScabbards` (ฝักดาบ 3 เล่มมัดรวมกัน): ยึดติดข้างเอวขวา (`Part0 = Torso`)
2. **งบประมาณจำนวนชิ้นส่วน (Part & Draw Call Budget):**
   - จำนวน `BasePart` ทั้งหมดของ `Zoro.rbxmx` ต้อง **ไม่เกิน 24 Parts** (Core Limbs 7 + ดาบ 3 เล่มๆ ละ 3 Parts = 9 + ฝักดาบ 3 + ผม/ผ้าคาดเอว 5)
   - ทุก Part ยกเว้น `HumanoidRootPart` ต้องมี `Anchored = false`, `CanCollide = false`, `CanTouch = false`, `CanQuery = false`, `Massless = true`

---

## 3. Rig Mapping & 3-Sword Joint Specification

### 3.1 ตาราง `Motor6D` ทั้ง 9 ข้อต่อ (6 Body Joints + 3 Weapon Joints)
| Joint Name (`AnimationContract`) | `Part0` (Parent) | `Part1` (Child) | `BaseC0` (Rest Pose Offset) | `BaseC1` (Pivot Offset) | หน้าที่ในการเคลื่อนไหว |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`RootJoint`** | `HumanoidRootPart` | `Torso` | `CFrame.new(0, 0, 0)` | `CFrame.new(0, 0, 0)` | ย่อตัวต่ำตั้งท่าดาบ พุ่งตัวเฉียงไปข้างหน้า และหมุนตัว 360 องศาตอนฟันพายุ |
| **`Neck`** | `Torso` | `Head` | `CFrame.new(0, 1.5, 0)` | `CFrame.new(0, -0.5, 0)` | หันศีรษะสะบัดดาบ `WadoIchimonji` ที่คาบอยู่ให้ฟันตามจังหวะไหล่ |
| **`RightShoulder`** | `Torso` | `RightArm` | `CFrame.new(1.5, 0.5, 0)` | `CFrame.new(0, 0.5, 0)` | ง้างดาบ `Enma` ไขว้หน้าอกและฟันกวาดเป็นแนวทแยง |
| **`LeftShoulder`** | `Torso` | `LeftArm` | `CFrame.new(-1.5, 0.5, 0)` | `CFrame.new(0, 0.5, 0)` | ง้างดาบ `SandaiKitetsu` ขนานกับแขนขวาและฟันประสาน |
| **`RightHip`** | `Torso` | `RightLeg` | `CFrame.new(0.5, -1.0, 0)` | `CFrame.new(0, 1.0, 0)` | ก้าวเท้าขวาไปด้านหน้าเพื่อรับน้ำหนักตัว (Forward Lunge Stance) |
| **`LeftHip`** | `Torso` | `LeftLeg` | `CFrame.new(-0.5, -1.0, 0)` | `CFrame.new(0, 1.0, 0)` | ยันเท้าซ้ายด้านหลังเป็นหลักส่งแรงพุ่ง |
| **`WeaponRight`** | `RightArm` | `EnmaHandle` | `CFrame.new(0, -1.0, -0.2) * CFrame.Angles(math.rad(-90), 0, 0)` | `CFrame.new(0, 0, 0)` | หมุนข้อมือขวาปรับมุมคมดาบ `Enma` (เช่น ควงดาบหรือตั้งดาบขนานแขนในท่า Oni Giri) |
| **`WeaponLeft`** | `LeftArm` | `SandaiHandle` | `CFrame.new(0, -1.0, -0.2) * CFrame.Angles(math.rad(-90), 0, 0)` | `CFrame.new(0, 0, 0)` | หมุนข้อมือซ้ายปรับมุมคมดาบ `SandaiKitetsu` |
| **`WeaponMouth`** | `Head` | `WadoHandle` | `CFrame.new(0, -0.25, -0.55) * CFrame.Angles(0, 0, math.rad(90))` | `CFrame.new(0, 0, 0)` | ยึดดาบ `WadoIchimonji` ขวางปากและปรับองศาเล็กน้อยตอนสะบัดคอฟัน |

---

## 4. Signature Animations Specification (`src/Track2_TowerSystem/Animations/Zoro.luau`)

สไตล์ของ Zoro ต้องเน้นความ **"คม ดุดัน รวดเร็ว และมีน้ำหนักของการไขว้ดาบ (Sharp Martial Precision & Snap)"**:

| Animation State | Duration (Base) | Looped | Can Cancel | รายละเอียดท่าทางและคีย์เฟรม (`CFrame` Mechanics) | VFX Cue ที่ส่งออก |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **`Idle` (Santoryu Combat Guard)** | `1.50s` | `true` | `true` | - ย่อตัวต่ำเล็กน้อย (`RootJoint` `Y = -0.15`) บิดลำตัวเฉียง `20 deg` แขนขวาและแขนซ้ายกางดาบออกด้านข้างลำตัวระดับเอว หายใจเข้า-ออกอย่างสุขุม คมดาบเรืองแสงฮาคิเบาๆ | `"PassiveAura"` |
| **`SpecialIdle` (Enma Haki Tame)** | `1.60s` | `false` | `true` | - ยกแขนขวา (`RightShoulder`) ขึ้นมาด้านหน้าสายตา หมุน `WeaponRight` ให้ใบดาบ `Enma` ตั้งขึ้น ดูดซับออร่าสีเขียว-ม่วงเข้าสู่ใบดาบแล้วสะบัดลง | `"EnmaChargePulse"` |
| **`Spawn` (Three-Sword Unsheathe)** | `0.60s` | `false` | `false` | - เริ่มจากท่าไขว้แขนที่เอว แล้วสะบัดแขนทั้งสองข้างชักดาบออกเป็นรูปกากบาท (`X-Cross`) พร้อมประกายแสงคมดาบ | `"SpawnDeploy"` |
| **`Windup` (Oni Giri Cross-Arm Stance)** | `0.26s` | `false` | `true` | - ย่อเข่าต่ำ (`RootJoint` `Y = -0.35`, เอนหน้า `-18 deg`) **ไขว้แขนขวาและแขนซ้ายทับกันที่หน้าอก** (`RightShoulder` หมุนเข้าใน `-55 deg`, `LeftShoulder` หมุนเข้าใน `+55 deg`) หันใบดาบทั้งสองชี้ไปด้านหลัง พร้อมคาบดาบที่สามแน่น | `"AttackWindup"` |
| **`Attack` (King of Hell Cross Slash)** | `0.18s` | `false` | `false` | - พุ่งลำตัวไปข้างหน้า (`RootJoint` เลื่อน `Z = -1.8 studs`) พร้อม **สะบัดแขนทั้งสองข้างกางออกด้านข้างด้วยความเร็วสูง** (`Enum.EasingStyle.Expo`, `Out`) และหมุนคอ (`Neck`) ฟันดาบที่ปากตามแนวขวาง เกิดคลื่นดาบ 3 เส้นพุ่งเข้าหาเป้าหมาย | `"AttackRelease"` |
| **`Impact` (Triple Blade Sever)** | `0.16s` | `false` | `false` | - ค้างท่ากางดาบสุดแขน (`Follow-through Pose`) ขณะที่รอยฟันกากบาทสีเขียว-ทองระเบิดขึ้นที่ตัวเป้าหมาย | `"AttackImpact"` |
| **`Recovery` (Blade Flourish & Reset)** | `0.40s` | `false` | `true` | - หมุนข้อมือ (`WeaponRight`, `WeaponLeft`) 반รอบแล้วดึงลำตัวถอยกลับสู่จุดยืนพร้อมตั้งการ์ด `Idle` | `nil` |
| **`Ultimate` (King of Hell: 103 Mercies Dragon Damnation)** | `2.00s` | `false` | `false` | - **Phase 1 (0.0–0.65s King of Hell Awakening):** ตั้งดาบทั้ง 3 เล่มขนาบลำตัว เปลวไฟฮาคิสีเขียวมรกตและสายฟ้าสีม่วง-ทองลุกโชนท่วมดาบทั้ง 3 เล่ม<br>- **Phase 2 (0.65–1.25s Dragon Twister Dash):** หมุนตัวพุ่งฟันเป็นเกลียวพายุ (`RootJoint` หมุน `720 deg` อย่างรวดเร็ว) แล้วฟันผ่าลงมาจากกลางอากาศ<br>- **Phase 3 (1.25–2.00s Sheathe Pose):** ยืนหันข้างค้างท่าเท่ขณะคลื่นดาบมังกรเขียวมรกตระเบิดกลางกลุ่มศัตรู | `"UltimateCast"` -> `"UltimateImpact"` |

---

## 5. Character-Specific VFX Specification (`src/Track2_TowerSystem/VFX/ZoroVFX.luau`)

| VFX Cue | รายละเอียดเอฟเฟกต์ (Visual Elements) | การใช้ Instance & อายุขัย (TTL / Cleanup) | การปรับตาม Quality Preset (`Low / Med / High`) |
| :--- | :--- | :--- | :--- |
| **`PassiveAura` (King of Hell Emerald Smoke & Haki)** | - เปลวควันไฟสีเขียวมรกต (`Color3.fromRGB(40, 235, 120)`) ลอยออกจากใบดาบทั้ง 3 เล่ม<br>- ใบดาบเคลือบสีดำมันวาว (`Armament Haki`) | ผูกกับ Attachment บนดาบทั้ง 3 เล่ม ปิดการทำงานทันทีเมื่อไม่ได้อยู่ในโหมดแสดงผล | `Low`: เปิดเฉพาะสีใบดาบฮาคิ<br>`Med`: เปิดไฟสีเขียวที่ดาบ `Enma`<br>`High`: เปิดครบทั้ง 3 เล่ม + ประกายสายฟ้าสีม่วงทอง |
| **`AttackWindup` (Triple Blade Glint)** | - แสงแฟลร์รูปดาวสี่แฉกสีเขียว-ทองสว่างวาบที่โคนดาบทั้ง 3 เล่มขณะไขว้แขนหน้าอก พร้อมเปิด `Trail` ของดาบทั้ง 3 เล่ม (`Trail.Enabled = true`) | TTL = `0.26s` | `Low`: เปิด `Trail` เฉพาะดาบขวา<br>`Med/High`: เปิด `Trail` ครบทั้ง 3 เล่ม |
| **`AttackRelease` (Santoryu Crescent Slash Arcs)** | - คลื่นดาบรูปพระจันทร์เสี้ยว 3 เส้น (สีเขียวมรกตขอบดำ-ทอง) พุ่งออกจากตัว Zoro ไปยัง `ctx.targetPosition` | TTL = `0.30s`, ปิด `Trail.Enabled = false` เมื่อจบเฟส `Attack` | `Low`: คลื่นดาบ 1 ชิ้น<br>`Med`: คลื่นดาบ 2 ชิ้น<br>`High`: คลื่นดาบ 3 ชิ้นซ้อนกันพร้อมเส้นลมเฉือน |
| **`AttackImpact` (3-Slash X-Cross Sever)** | - รอยฟันคมกริบ 3 เส้นตัดกันที่ตำแหน่ง `ctx.targetPosition` พร้อมประกายไฟฮาคิสีเขียว-ม่วงกระเด็นออก | TTL = `0.32s` | `Low`: รอยฟัน 2 ชิ้น<br>`High`: รอยฟัน 3 ชิ้น + Particle `:Emit(14)` |
| **`UltimateCast` & `UltimateImpact` (103 Mercies Dragon Slash)** | - พายุเกลียวสีเขียวมรกตหมุนรอบตัว Zoro ก่อนพุ่งเป็นคลื่นดาบยักษ์ผ่าเป้าหมาย พร้อมสายฟ้าสีเขียว-ทองและดำแดง | TTL = `1.40s`, จำกัดจำนวน Part ไม่เกิน 15 ชิ้น | `Low`: ลดจำนวนวงเกลียวพายุเหลือ 3 ชิ้น<br>`High`: เต็มรูปแบบพร้อม Camera Shake แนวเฉียง |

---

## 6. Step-by-Step Implementation Tasks (Developer 2)

1. **Task Z-1 (Model & 3-Sword Rig Preparation):**
   - ตรวจสอบ `Zoro.rbxmx` แยกชิ้นส่วนดาบทั้ง 3 เล่มให้มี Handle Part ชัดเจน (`EnmaHandle`, `SandaiHandle`, `WadoHandle`) พร้อม `Attachment0` (โคนดาบ) และ `Attachment1` (ปลายดาบ) สำหรับ `Trail`
   - ตั้งค่า `Anchored = false`, `CanCollide = false`, `Massless = true` ให้ทุกชิ้นส่วนยกเว้น `HumanoidRootPart`
2. **Task Z-2 (Implement `src/Track2_TowerSystem/Animations/Zoro.luau`):**
   - สร้าง `CharacterAnimationProfile` ที่มีครบ 9 ข้อต่อ (`RootJoint`, `Neck`, `RightShoulder`, `LeftShoulder`, `RightHip`, `LeftHip`, `WeaponRight`, `WeaponLeft`, `WeaponMouth`)
   - เขียน Keyframes ของท่าตั้งการ์ด, ท่าไขว้แขน `Oni Giri`, ท่าพุ่งฟัน และท่าไม้ตาย `King of Hell`
3. **Task Z-3 (Implement `src/Track2_TowerSystem/VFX/ZoroVFX.luau`):**
   - จัดการการเปิด/ปิด `Trail` บนดาบทั้ง 3 เล่มอย่างปลอดภัย (รับประกันว่าเมื่อถูก Cancel หรือจบเฟส `Attack` ตัว `Trail.Enabled` จะถูกตั้งเป็น `false` เสมอ ไม่ลากเส้นค้างตอนยืน Idle)
4. **Task Z-4 (Write Automated Spec `tests/characters/zoro_anim_vfx.spec.luau`):**
   - ทดสอบว่าดาบทั้ง 3 เล่มเคลื่อนที่ตาม `RightArm`, `LeftArm`, และ `Head` จริงเมื่อเปลี่ยนค่า `Motor6D.C0`
   - ทดสอบว่าหลังจบ `Attack` หรือเมื่อเรียก `cleanupAllForModel` ตัว `Trail.Enabled` ของดาบทั้ง 3 เล่มเป็น `false` เสมอ

---

## 7. File Ownership, Visual Acceptance Criteria & Risks

- **Owned Files:** `Zoro.rbxmx`, `src/Track2_TowerSystem/Animations/Zoro.luau`, `src/Track2_TowerSystem/VFX/ZoroVFX.luau`, `tests/characters/zoro_anim_vfx.spec.luau`
- **Visual Acceptance Criteria (ต้องตรวจใน Animation Lab):**
  1. ดาบทั้ง 3 เล่มต้องติดอยู่กับมือขวา มือซ้าย และปากอย่างแม่นยำในทุกเฟรมของการขยับ ไม่ลอยแยกออกจากมือ
  2. ในจังหวะ `Windup -> Attack` ต้องเห็นการไขว้แขนหน้าอกแล้วสะบัดฟันออกพร้อมรอย `Trail` สีเขียว-ทองชัดเจน
  3. เมื่อหยุดเล่นท่า (`Stop` หรือกลับสู่ `Idle`) เส้น `Trail` ต้องหยุดลากทันที
- **Known Risks:** หาก `Attachment0` และ `Attachment1` บนใบดาบวางตำแหน่งสลับแกนกัน `Trail` จะแบนเป็นเส้นบางมองไม่เห็น **วิธีแก้:** กำหนดให้ `Attachment0` อยู่ที่ด้ามดาบ `(0, 0, -0.5)` และ `Attachment1` อยู่ที่ปลายดาบ `(0, 0, -4.0)` พร้อมตั้ง `Trail.FaceCamera = true`


---

## 8. Hand-Holding Luau Code Blueprints for Developer 2 (`Zoro.luau`, `ZoroVFX.luau`, & Spec)

### 8.1 พิมพ์เขียว `src/Track2_TowerSystem/Animations/Zoro.luau`
\`\`\`luau
--!strict
-- src/Track2_TowerSystem/Animations/Zoro.luau
-- Owned by: Developer 2 (AGY-Char-Zoro)
-- Character: Zoro (King of Hell / Three-Sword Style)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationContract = require(ReplicatedStorage.Shared.AnimationContract)

local rad = math.rad
local cf = CFrame.new
local ang = CFrame.Angles

local ZoroAnimationProfile: AnimationContract.CharacterAnimationProfile = {
	heroId = "Zoro",
	displayName = "Zoro (King of Hell)",
	rigType = "ArticulatedWeaponRig",
	expectedJoints = {
		"RootJoint",
		"Neck",
		"RightShoulder",
		"LeftShoulder",
		"RightHip",
		"LeftHip",
		"WeaponRight",
		"WeaponLeft",
		"WeaponMouth",
	},
	accessoryRules = {
		{
			accessoryNamePattern = "Enma",
			attachToLimb = "RightArm",
			offsetCFrame = cf(0, -1.0, -0.2) * ang(rad(-90), 0, 0),
			useMotor6D = true,
			jointName = "WeaponRight",
		},
		{
			accessoryNamePattern = "Sandai",
			attachToLimb = "LeftArm",
			offsetCFrame = cf(0, -1.0, -0.2) * ang(rad(-90), 0, 0),
			useMotor6D = true,
			jointName = "WeaponLeft",
		},
		{
			accessoryNamePattern = "Wado",
			attachToLimb = "Head",
			offsetCFrame = cf(0, -0.25, -0.55) * ang(0, 0, rad(90)),
			useMotor6D = true,
			jointName = "WeaponMouth",
		},
		{
			accessoryNamePattern = "Scabbard",
			attachToLimb = "Torso",
			offsetCFrame = cf(1.1, -0.65, 0.2) * ang(rad(-25), 0, 0),
			useMotor6D = false,
		},
	},
	baseScale = 1.0,
	attackCycleTimings = {
		windupRatio = 0.26,
		attackRatio = 0.18,
		impactRatio = 0.16,
		recoveryRatio = 0.40,
	},
	states = {
		Idle = {
			state = "Idle",
			duration = 1.50,
			looped = true,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					easingStyle = Enum.EasingStyle.Sine,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = cf(0, -0.12, 0) * ang(rad(-6), rad(-18), 0),
						Neck = ang(rad(4), rad(18), 0),
						RightShoulder = ang(rad(32), 0, rad(28)),
						LeftShoulder = ang(rad(28), 0, rad(-28)),
						RightHip = ang(rad(16), 0, 0),
						LeftHip = ang(rad(-16), 0, 0),
						WeaponRight = ang(rad(-10), 0, 0),
						WeaponLeft = ang(rad(-10), 0, 0),
						WeaponMouth = cf(),
					},
					vfxCue = "PassiveAura",
				},
				{
					alpha = 0.5,
					easingStyle = Enum.EasingStyle.Sine,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = cf(0, -0.04, 0) * ang(rad(-4), rad(-18), 0),
						Neck = ang(rad(6), rad(18), 0),
						RightShoulder = ang(rad(38), 0, rad(32)),
						LeftShoulder = ang(rad(34), 0, rad(-32)),
						RightHip = ang(rad(14), 0, 0),
						LeftHip = ang(rad(-14), 0, 0),
						WeaponRight = ang(rad(-6), 0, 0),
						WeaponLeft = ang(rad(-6), 0, 0),
						WeaponMouth = cf(),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Sine,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = cf(0, -0.12, 0) * ang(rad(-6), rad(-18), 0),
						Neck = ang(rad(4), rad(18), 0),
						RightShoulder = ang(rad(32), 0, rad(28)),
						LeftShoulder = ang(rad(28), 0, rad(-28)),
						RightHip = ang(rad(16), 0, 0),
						LeftHip = ang(rad(-16), 0, 0),
						WeaponRight = ang(rad(-10), 0, 0),
						WeaponLeft = ang(rad(-10), 0, 0),
						WeaponMouth = cf(),
					},
				},
			},
		},

		Windup = {
			state = "Windup",
			duration = 0.26,
			looped = false,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, -0.12, 0) * ang(rad(-6), rad(-18), 0),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Back,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						-- ท่าไขว้แขนหน้าอก Oni Giri
						RootJoint = cf(0, -0.35, 0.25) * ang(rad(-18), rad(-30), 0),
						Neck = ang(rad(10), rad(28), 0),
						RightShoulder = cf(-0.35, 0.1, -0.35) * ang(rad(85), rad(45), rad(-55)),
						LeftShoulder = cf(0.35, 0.1, -0.35) * ang(rad(85), rad(-45), rad(55)),
						RightHip = ang(rad(28), 0, 0),
						LeftHip = ang(rad(-32), 0, 0),
						WeaponRight = ang(0, rad(25), 0),
						WeaponLeft = ang(0, rad(-25), 0),
					},
					vfxCue = "AttackWindup",
				},
			},
		},

		Attack = {
			state = "Attack",
			duration = 0.18,
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, -0.35, 0.25) * ang(rad(-18), rad(-30), 0),
						RightShoulder = cf(-0.35, 0.1, -0.35) * ang(rad(85), rad(45), rad(-55)),
						LeftShoulder = cf(0.35, 0.1, -0.35) * ang(rad(85), rad(-45), rad(55)),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Expo,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						-- พุ่งตัวไปข้างหน้าพร้อมสะบัดดาบทั้งสองออกด้านข้างและหันหัวฟันดาบคาบปาก
						RootJoint = cf(0, -0.20, -1.80) * ang(rad(-22), rad(25), 0),
						Neck = ang(rad(-5), rad(-35), 0),
						RightShoulder = cf(0.3, 0.1, -0.2) * ang(rad(95), rad(-30), rad(75)),
						LeftShoulder = cf(-0.3, 0.1, -0.2) * ang(rad(95), rad(30), rad(-75)),
						RightHip = ang(rad(35), 0, 0),
						LeftHip = ang(rad(-38), 0, 0),
						WeaponRight = ang(rad(-25), 0, 0),
						WeaponLeft = ang(rad(-25), 0, 0),
						WeaponMouth = ang(0, rad(15), 0),
					},
					vfxCue = "AttackRelease",
				},
			},
		},

		Impact = {
			state = "Impact",
			duration = 0.16,
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, -0.20, -1.85) * ang(rad(-22), rad(25), 0),
						RightShoulder = cf(0.3, 0.1, -0.2) * ang(rad(95), rad(-30), rad(78)),
						LeftShoulder = cf(-0.3, 0.1, -0.2) * ang(rad(95), rad(30), rad(-78)),
					},
					vfxCue = "AttackImpact",
				},
				{
					alpha = 1.0,
					poses = {
						RootJoint = cf(0, -0.18, -1.65) * ang(rad(-18), rad(20), 0),
						RightShoulder = cf(0.2, 0.1, -0.1) * ang(rad(85), rad(-20), rad(65)),
						LeftShoulder = cf(-0.2, 0.1, -0.1) * ang(rad(85), rad(20), rad(-65)),
					},
				},
			},
		},

		Recovery = {
			state = "Recovery",
			duration = 0.40,
			looped = false,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, -0.18, -1.65) * ang(rad(-18), rad(20), 0),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Quad,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						RootJoint = cf(0, -0.12, 0) * ang(rad(-6), rad(-18), 0),
						Neck = ang(rad(4), rad(18), 0),
						RightShoulder = ang(rad(32), 0, rad(28)),
						LeftShoulder = ang(rad(28), 0, rad(-28)),
						RightHip = ang(rad(16), 0, 0),
						LeftHip = ang(rad(-16), 0, 0),
						WeaponRight = ang(rad(-10), 0, 0),
						WeaponLeft = ang(rad(-10), 0, 0),
						WeaponMouth = cf(),
					},
				},
			},
		},

		Ultimate = {
			state = "Ultimate",
			duration = 2.00,
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, -0.25, 0),
						RightShoulder = ang(rad(110), 0, rad(35)),
						LeftShoulder = ang(rad(110), 0, rad(-35)),
					},
					vfxCue = "UltimateCast",
				},
				{
					alpha = 0.55,
					easingStyle = Enum.EasingStyle.Expo,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = cf(0, 1.5, -2.4) * ang(rad(-25), rad(180), 0),
						RightShoulder = ang(rad(95), 0, rad(85)),
						LeftShoulder = ang(rad(95), 0, rad(-85)),
					},
					vfxCue = "UltimateImpact",
				},
				{
					alpha = 1.0,
					poses = {
						RootJoint = cf(0, -0.12, 0) * ang(rad(-6), rad(-18), 0),
						Neck = ang(rad(4), rad(18), 0),
						RightShoulder = ang(rad(32), 0, rad(28)),
						LeftShoulder = ang(rad(28), 0, rad(-28)),
						RightHip = ang(rad(16), 0, 0),
						LeftHip = ang(rad(-16), 0, 0),
						WeaponRight = cf(),
						WeaponLeft = cf(),
						WeaponMouth = cf(),
					},
				},
			},
		},
	},
}

return table.freeze(ZoroAnimationProfile)
\`\`\`

&lt;!-- === FILE_END: docs/implementation-plans/0005-character-model-animation/characters/02-zoro.md === --&gt;

---

&lt;!-- === FILE_START: docs/implementation-plans/0005-character-model-animation/characters/03-ace.md === --&gt;
# Character Implementation Plan 03 — Ace Flame Emperor (`Ace.rbxmx`)

- **Document ID:** `0005-character-model-animation/characters/03-ace.md`
- **Assigned Developer:** Developer 3 (`AGY-Char-Ace`)
- **Git Branch:** `feat/phase5-char-ace`
- **Git Worktree:** `../wt-phase5-ace`
- **Target Model:** `Ace.rbxmx`
- **Verification Status:** `NOT VERIFIED` (Planning Stage Only)

---

## 1. Existing Model Analysis (`Ace.rbxmx`)

1. **โครงสร้างปัจจุบันใน Phase 4 Baseline:**
   - โมเดล `Ace.rbxmx` เป็น Part-based Character Model ของ Portgas D. Ace
   - ปัญหาสำคัญที่พบในโครงสร้างเดิม:
     - ชิ้นส่วนหมวกคาวบอยสีส้ม (`CowboyHat`), สร้อยลูกปัดแดง (`RedBeads`), และมีดสั้นที่เอว (`HipDagger`) ถูก Weld รวมกับ RootPart ทำให้เมื่อศีรษะก้ม/เงย หมวกไม่ขยับตามศีรษะ
     - ท่าโจมตีเดิมยังไม่ได้แยกความแตกต่างระหว่างการชาร์จลูกไฟที่แขนขวา (`Fire Charge`), การชกปล่อยเสาเพลิง (`Hiken / Fire Punch`), และการชูมือเดียวสร้างดวงอาทิตย์เพลิงเหนือหัว (`Dai Enkai: Entei`)

---

## 2. Model Improvement Requirements

1. **เอกลักษณ์ของ Ace (Flame Emperor / Mera Mera no Mi):**
   - **หมวกคาวบอยสีส้ม (`CowboyHat`):** หมวกสีส้มสด (`Color3.fromRGB(235, 110, 30)`) ประดับสัญลักษณ์หน้ายิ้ม/หน้าบึ้งสีฟ้าและสายลูกปัดสีแดงคล้องใต้คาง ยึดติดกับ `Head`
   - **สร้อยลูกปัดสีแดง (`RedBeadNecklace`) และรอยสักแผ่นหลัง/แขนซ้าย (`TattooDecals`):** สร้อยลูกปัดทรงกลมสีแดงสดรอบคอ (`Part0 = Torso`)
   - **กางเกงขาสั้นสีดำ เข็มขัดหัวอักษร A และมีดสั้นสีเขียว (`BeltAndDagger`):** ยึดติดกับ `Torso` ช่วงเอว
   - **จุดปล่อยไฟประจำอวัยวะ (`FlameAttachments`):** เพิ่ม `Attachment` ชื่อ `RightHandFlameAtt`, `LeftHandFlameAtt`, และ `OverheadEnteiAtt` เพื่อใช้เป็นจุดกำเนิดของ `ParticleEmitter` และ `Beam` โดยไม่ต้องสร้าง Part เปล่าซ้ำๆ ตอน Runtime
2. **งบประมาณจำนวนชิ้นส่วน (Part & Draw Call Budget):**
   - จำนวน `BasePart` ทั้งหมดของ `Ace.rbxmx` ต้อง **ไม่เกิน 21 Parts**
   - ทุก Part ยกเว้น `HumanoidRootPart` ต้องมี `Anchored = false`, `CanCollide = false`, `CanTouch = false`, `CanQuery = false`, `Massless = true`

---

## 3. Rig Mapping & Accessory Specification

### 3.1 ตาราง `Motor6D` ทั้ง 6 ข้อต่อหลัก
| Joint Name (`AnimationContract`) | `Part0` (Parent) | `Part1` (Child) | `BaseC0` (Rest Pose Offset) | `BaseC1` (Pivot Offset) | หน้าที่ในการเคลื่อนไหว |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`RootJoint`** | `HumanoidRootPart` | `Torso` | `CFrame.new(0, 0, 0)` | `CFrame.new(0, 0, 0)` | บิดสะโพกและไหล่ตามท่าชกมวยเพลิง และการลอยตัวเล็กน้อยตอนใช้พลังโรเกีย |
| **`Neck`** | `Torso` | `Head` | `CFrame.new(0, 1.5, 0)` | `CFrame.new(0, -0.5, 0)` | ก้มหน้ากดปีกหมวกเล็กน้อยตอนตั้งท่า และเงยหน้ามองลูกไฟ `Entei` ตอนใช้ท่าไม้ตาย |
| **`RightShoulder`** | `Torso` | `RightArm` | `CFrame.new(1.5, 0.5, 0)` | `CFrame.new(0, 0.5, 0)` | **ข้อต่อหลักสำหรับจุดไฟปลายนิ้ว (`Idle`), ชาร์จไฟ (`Windup`), ชก `Hiken` (`Attack`), และชูมือสร้าง `Entei` (`Ultimate`)** |
| **`LeftShoulder`** | `Torso` | `LeftArm` | `CFrame.new(-1.5, 0.5, 0)` | `CFrame.new(0, 0.5, 0)` | ยกมือซ้ายขึ้นเล็งเป้าหมาย (`Targeting Sight` หรือทำนิ้วปืนไฟ `Higan`) และดึงประคองสมดุลตอนชกขวา |
| **`RightHip`** | `Torso` | `RightLeg` | `CFrame.new(0.5, -1.0, 0)` | `CFrame.new(0, 1.0, 0)` | ยันขาหลังส่งแรงบิดเอวตอนปล่อยหมัดอัคคี |
| **`LeftHip`** | `Torso` | `LeftLeg` | `CFrame.new(-0.5, -1.0, 0)` | `CFrame.new(0, 1.0, 0)` | ก้าวเท้าซ้ายนำหน้าในท่ายืน Martial Boxer Stance |

### 3.2 ตารางการยึด Accessories (`accessoryRules`)
| ชื่อชิ้นส่วน Accessory | ยึดเข้ากับ (`attachToLimb`) | ชนิดการเชื่อมต่อ | ค่า Offset มาตรฐาน |
| :--- | :--- | :--- | :--- |
| `CowboyHat` (หมวกสีส้ม) | `Head` | `WeldConstraint` | `CFrame.new(0, 0.60, 0) * CFrame.Angles(math.rad(-6), 0, 0)` |
| `RedBeadNecklace` (สร้อยลูกปัดแดง) | `Torso` | `WeldConstraint` | `CFrame.new(0, 0.92, 0)` |
| `HipDagger` (มีดสั้นและกระเป๋าข้างเอว) | `Torso` | `WeldConstraint` | `CFrame.new(-1.05, -0.85, 0) * CFrame.Angles(0, 0, math.rad(12))` |

---

## 4. Signature Animations Specification (`src/Track2_TowerSystem/Animations/Ace.luau`)

สไตล์ของ Ace ต้องสื่อถึง **"ผู้ใช้ผลปีศาจสายโรเกียที่มั่นใจ เท่ ลื่นไหล และระเบิดพลังความร้อนสูง (Fluid Logia Pyrokinesis & Explosive Thrust)"**:

| Animation State | Duration (Base) | Looped | Can Cancel | รายละเอียดท่าทางและคีย์เฟรม (`CFrame` Mechanics) | VFX Cue ที่ส่งออก |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **`Idle` (Logia Flame Finger Stance)** | `1.40s` | `true` | `true` | - ยืนเฉียงทำมุมสบายๆ มือซ้ายเท้าเอว (`LeftShoulder` หมุน `CFrame.Angles(math.rad(20), 0, math.rad(-25))`) มือขวายกขึ้นระดับอก (`RightShoulder` หมุน `math.rad(65)`) เลี้ยงลูกไฟเล็กๆ ที่ปลายนิ้ว ลำตัวและศีรษะขยับตามจังหวะเปลวไฟ | `"PassiveAura"` |
| **`SpecialIdle` (Hat Tip & Flame Flare)** | `1.50s` | `false` | `true` | - ยกมือซ้ายแตะปีกหมวกคาวบอย (`Neck` ก้มลง `-12 deg` แล้วเงยขึ้น) พร้อมเร่งเปลวไฟที่ไหล่ทั้งสองข้างให้ลุกโชนขึ้นชั่วครู่ | `"FlameShoulderFlare"` |
| **`Spawn` (Logia Fire Pillar Materialize)** | `0.65s` | `false` | `false` | - เริ่มจากท่าย่อเข่าก้มหน้าท่ามกลางเสาไฟ แล้วสะบัดแขนทั้งสองข้างกางออกด้านข้างเพื่อสลายม่านไฟออกด้านหลัง | `"SpawnDeploy"` |
| **`Windup` (Fire Charge — Mera Mera Ignition)** | `0.28s` | `false` | `true` | - ก้าวเท้าซ้ายนำหน้า ยกแขนซ้ายชี้เล็งไปที่เป้าหมาย (`LeftShoulder` `math.rad(90)`) ขณะที่ดึงหมัดขวา (`RightShoulder`) ถอยไปด้านหลังสีข้างขวา `CFrame.Angles(math.rad(-35), math.rad(-40), math.rad(20))` เพื่ออัดมวลเปลวไฟความร้อนสูงเข้าที่หมัดขวา | `"AttackWindup"` |
| **`Attack` (Hiken — Fire Fist Thrust)** | `0.20s` | `false` | `false` | - บิดเอว (`RootJoint` หมุน `+45 deg`) ส่งหมัดขวาพุ่งตรงไปข้างหน้าสุดแขน (`RightShoulder` หมุนเป็น `math.rad(90)`) พร้อมดึงแขนซ้ายกลับข้างลำตัว ปล่อยลำแสงและหัวหมัดเพลิงขนาดใหญ่พุ่งเข้าใส่เป้าหมาย | `"AttackRelease"` |
| **`Impact` (Hiken Detonation Hold)** | `0.15s` | `false` | `false` | - ค้างหมัดขวาที่เหยียดตรงไปข้างหน้า ลำตัวเอนถอยเล็กน้อยจากแรงอัดของเสาไฟ (`Recoil Pose`) ขณะที่ระเบิดเพลิงทำงานที่จุดปะทะ | `"AttackImpact"` |
| **`Recovery` (Flame Dissolve & Boxer Reset)** | `0.37s` | `false` | `true` | - สะบัดข้อมือขวาไล่สะเก็ดไฟแล้วดึงแขนกลับสู่ท่ายืน `Idle` อย่างนุ่มนวล | `nil` |
| **`Ultimate` (Dai Enkai: Entei — Flame Emperor)** | `2.20s` | `false` | `false` | - **Phase 1 (0.0–0.85s Great Flame Command):** Ace กางแขนทั้งสองข้างออกรับวงแหวนไฟรอบตัว แล้ว **ชูแขนขวาขึ้นตั้งฉากเหนือศีรษะ (`RightShoulder` หมุน `math.rad(175)`)** ด้วยมือข้างเดียว เงยหน้ามองลูกบอลดวงอาทิตย์เพลิง (`Entei`) ที่ขยายตัวขึ้นเหนือปลายนิ้ว<br>- **Phase 2 (0.85–1.35s Emperor Hurl):** ก้าวเท้าพร้อมเหวี่ยงแขนขวาฟาดลงมาข้างหน้า (`math.rad(175) -> math.rad(75)`) ส่งดวงอาทิตย์เพลิงพุ่งลงสู่เป้าหมาย<br>- **Phase 3 (1.35–2.20s Solar Eruption):** ยืนกอดอกหรือเท้าเอวมองการระเบิดของดวงอาทิตย์เพลิงก่อนกลับสู่ท่า `Idle` | `"UltimateCast"` -> `"UltimateImpact"` |

---

## 5. Character-Specific VFX Specification (`src/Track2_TowerSystem/VFX/AceVFX.luau`)

| VFX Cue | รายละเอียดเอฟเฟกต์ (Visual Elements) | การใช้ Instance & อายุขัย (TTL / Cleanup) | การปรับตาม Quality Preset (`Low / Med / High`) |
| :--- | :--- | :--- | :--- |
| **`PassiveAura` (Mera Mera Hand Flame & Heat Embers)** | - เปลวไฟสีส้ม-เหลืองทอง (`Colorsequence: White-Yellow -> Orange -> Crimson`) ลุกไหม้อยู่ที่ `RightHandFlameAtt` และสะเก็ดไฟลอยขึ้นจากไหล่<br>- `PointLight` สีส้มอบอุ่น (`Range = 8`, `Brightness = 1.2`) | ผูกติดกับ `RightArm` ลบหรือปิดทันทีเมื่อเรียก `stopPassiveAura` | `Low`: ปิด `PointLight` ลด `Rate` เหลือ 4<br>`Med`: `Rate = 10`<br>`High`: `Rate = 18` + สะเก็ดไฟ (`Embers`) |
| **`AttackWindup` (Swirling Fire Charge Vortex)** | - วงแหวนไฟหมุนวนรอบท่อนแขนขวา และลูกไฟสว่างจ้าขยายตัวจากขนาด `0.6` เป็น `2.2 studs` ที่หมัดขวา | TTL = `0.30s` | `Low`: ลูกไฟ 1 ชิ้น<br>`High`: ลูกไฟแกนขาว + วงแหวนเพลิงหมุนรอบแขน |
| **`AttackRelease` (Hiken Fire Fist Projectile & Flame Beam)** | - หัวหมัดเพลิงขนาดใหญ่พุ่งจากหมัดขวาของ Ace ไปยัง `ctx.targetPosition` พร้อมลำแสงเพลิง (`Beam` หรือ Tapered Cylinder) เชื่อมระหว่างหมัดกับเป้าหมาย | TTL = `0.28s` | `Low`: ลูกไฟพุ่ง 1 ชิ้น (ไม่ใช้ Beam)<br>`Med`: ลูกไฟ + Beam 1 เส้น<br>`High`: ลูกไฟ 2 ชั้น (แกนเหลือง + เปลือกส้มแดง) + Beam + Smoke Trail |
| **`AttackImpact` (Scorch Ring & Flame Pillar Burst)** | - เสาไฟพุ่งขึ้นที่จุด `ctx.targetPosition` พร้อมวงแหวนคลื่นความร้อนสีส้มแดงขยายออกแนวราบ | TTL = `0.38s` | `Low`: วงแหวนไฟ 1 ชิ้น<br>`High`: เสาไฟ + วงแหวน 2 ชั้น + Particle `:Emit(20)` |
| **`UltimateCast` & `UltimateImpact` (Dai Enkai: Entei)** | - สร้างทรงกลมดวงอาทิตย์เพลิง 2 ชั้น (`InnerCore` สีขาวเหลือง `Neon` + `OuterCorona` สีส้มแดงโปร่งแสง) ขยายขนาดขึ้นเหนือมือขวา (`Size 1.5 -> 9.0 studs`) พุ่งลงกระแทกเป้าหมายเกิดโดมระเบิดสุริยะ | TTL = `1.60s`, จำกัดจำนวน Part ไม่เกิน 14 ชิ้น | `Low`: ทรงกลมชั้นเดียว ไม่เปิด `PointLight` / Screen Flash<br>`High`: ทรงกลม 2 ชั้น + วงแหวนไฟที่พื้น (`Dai Enkai`) + Screen Flash สีส้มทอง |

---

## 6. Step-by-Step Implementation Tasks (Developer 3)

1. **Task A-1 (Model & Accessory Rig Preparation):**
   - ตรวจสอบ `Ace.rbxmx` แยก `CowboyHat` ให้ยึดกับ `Head` และ `RedBeadNecklace` / `HipDagger` ให้ยึดกับ `Torso`
   - เพิ่ม `RightHandFlameAtt`, `LeftHandFlameAtt`, และ `OverheadEnteiAtt`
2. **Task A-2 (Implement `src/Track2_TowerSystem/Animations/Ace.luau`):**
   - สร้าง `CharacterAnimationProfile` ของ Ace พร้อม Keyframes สำหรับ `Idle`, `SpecialIdle`, `Spawn`, `Windup` (`Fire Charge`), `Attack` (`Fire Punch / Hiken`), `Impact`, `Recovery`, และ `Ultimate` (`Entei`)
3. **Task A-3 (Implement `src/Track2_TowerSystem/VFX/AceVFX.luau`):**
   - สร้างเอฟเฟกต์ไฟทั้งหมดโดยใช้ `ctx.registerInstance` และ `ctx.registerTween`
   - ควบคุม `ParticleEmitter` ให้ใช้ `:Emit(count)` สำหรับจังหวะระเบิด (`AttackImpact`, `UltimateImpact`) แทนการเปิด `Enabled = true` ทิ้งไว้ เพื่อป้องกัน Particle ค้าง
4. **Task A-4 (Write Automated Spec `tests/characters/ace_anim_vfx.spec.luau`):**
   - ทดสอบว่า `CowboyHat` เคลื่อนที่ตาม `Head` เมื่อ `Neck.C0` เปลี่ยนค่า
   - ทดสอบว่า `Ultimate` (`Entei`) และ `Attack` (`Hiken`) เคลียร์ Instance ทั้งหมดเหลือ `0` หลังจบ TTL หรือเมื่อเรียก `cleanupAllForModel`

---

## 7. File Ownership, Visual Acceptance Criteria & Risks

- **Owned Files:** `Ace.rbxmx`, `src/Track2_TowerSystem/Animations/Ace.luau`, `src/Track2_TowerSystem/VFX/AceVFX.luau`, `tests/characters/ace_anim_vfx.spec.luau`
- **Visual Acceptance Criteria (ต้องตรวจใน Animation Lab):**
  1. หมวกคาวบอยสีส้มต้องขยับตามศีรษะทุกครั้งที่ Ace ก้มหรือเงยหน้า
  2. จังหวะ `Windup` (`Fire Charge`) ต้องเห็นการดึงหมัดขวาไปชาร์จไฟด้านหลัง และในจังหวะ `Attack` (`Fire Punch`) ลำแสงไฟต้องพุ่งเข้าหาตำแหน่ง `Dummy Target` อย่างแม่นยำ
  3. ท่า `Ultimate` (`Entei`) ต้องเห็นลูกไฟดวงอาทิตย์ก่อตัวขึ้นเหนือมือขวาที่ชูขึ้นก่อนพุ่งลงไปยังเป้าหมาย
- **Known Risks:** หากวาง Tower Ace หลายตัวพร้อมกันแล้วทุกตัวเปิด `PointLight` และ `ParticleEmitter` ความหนาแน่นสูง อาจทำให้ GPU Frame Time สูงขึ้น **วิธีแก้:** ใน `AceVFX.luau` ให้ผูกจำนวน Particle กับ `VFXContract.QUALITY_MULTIPLIERS[ctx.quality]` และปิด `PointLight` อัตโนมัติเมื่ออยู่ในโหมด `Low` หรือเมื่อจำนวน Active VFX รวมเกินเพดาน


---

## 8. Hand-Holding Luau Code Blueprints for Developer 3 (`Ace.luau`, `AceVFX.luau`, & Spec)

### 8.1 พิมพ์เขียว `src/Track2_TowerSystem/Animations/Ace.luau`
\`\`\`luau
--!strict
-- src/Track2_TowerSystem/Animations/Ace.luau
-- Owned by: Developer 3 (AGY-Char-Ace)
-- Character: Portgas D. Ace (Flame Emperor)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationContract = require(ReplicatedStorage.Shared.AnimationContract)

local rad = math.rad
local cf = CFrame.new
local ang = CFrame.Angles

local AceAnimationProfile: AnimationContract.CharacterAnimationProfile = {
	heroId = "Ace",
	displayName = "Ace (Flame Emperor)",
	rigType = "Articulated6Joint",
	expectedJoints = {
		"RootJoint",
		"Neck",
		"RightShoulder",
		"LeftShoulder",
		"RightHip",
		"LeftHip",
	},
	accessoryRules = {
		{
			accessoryNamePattern = "CowboyHat",
			attachToLimb = "Head",
			offsetCFrame = cf(0, 0.60, 0) * ang(rad(-6), 0, 0),
			useMotor6D = false,
		},
		{
			accessoryNamePattern = "RedBead",
			attachToLimb = "Torso",
			offsetCFrame = cf(0, 0.92, 0),
			useMotor6D = false,
		},
		{
			accessoryNamePattern = "Dagger",
			attachToLimb = "Torso",
			offsetCFrame = cf(-1.05, -0.85, 0) * ang(0, 0, rad(12)),
			useMotor6D = false,
		},
	},
	baseScale = 1.0,
	attackCycleTimings = {
		windupRatio = 0.28,
		attackRatio = 0.20,
		impactRatio = 0.15,
		recoveryRatio = 0.37,
	},
	states = {
		Idle = {
			state = "Idle",
			duration = 1.40,
			looped = true,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					easingStyle = Enum.EasingStyle.Sine,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = cf(0, 0.02, 0) * ang(0, rad(-15), 0),
						Neck = ang(rad(-4), rad(15), 0),
						-- มือขวายกจุดไฟระดับอก มือซ้ายเท้าสะเอว
						RightShoulder = cf(0, 0.05, -0.25) * ang(rad(68), rad(-15), rad(12)),
						LeftShoulder = ang(rad(-18), 0, rad(-28)),
						RightHip = ang(rad(-10), 0, 0),
						LeftHip = ang(rad(12), 0, 0),
					},
					vfxCue = "PassiveAura",
				},
				{
					alpha = 0.5,
					easingStyle = Enum.EasingStyle.Sine,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = cf(0, 0.12, 0) * ang(0, rad(-12), 0),
						Neck = ang(rad(2), rad(12), 0),
						RightShoulder = cf(0, 0.12, -0.25) * ang(rad(76), rad(-10), rad(16)),
						LeftShoulder = ang(rad(-15), 0, rad(-25)),
						RightHip = ang(rad(-8), 0, 0),
						LeftHip = ang(rad(10), 0, 0),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Sine,
					easingDirection = Enum.EasingDirection.InOut,
					poses = {
						RootJoint = cf(0, 0.02, 0) * ang(0, rad(-15), 0),
						Neck = ang(rad(-4), rad(15), 0),
						RightShoulder = cf(0, 0.05, -0.25) * ang(rad(68), rad(-15), rad(12)),
						LeftShoulder = ang(rad(-18), 0, rad(-28)),
						RightHip = ang(rad(-10), 0, 0),
						LeftHip = ang(rad(12), 0, 0),
					},
				},
			},
		},

		Windup = {
			state = "Windup",
			duration = 0.28,
			looped = false,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, 0.02, 0) * ang(0, rad(-15), 0),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Back,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						-- Fire Charge: มือซ้ายชี้เล็งข้างหน้า ดึงหมัดขวาไปอัดไฟด้านหลัง
						RootJoint = cf(0, -0.15, 0.30) * ang(rad(6), rad(-48), 0),
						Neck = ang(rad(-6), rad(45), 0),
						RightShoulder = cf(0.3, -0.1, 0.5) * ang(rad(-38), rad(-40), rad(25)),
						LeftShoulder = cf(0, 0.05, -0.3) * ang(rad(88), rad(35), 0),
						RightHip = ang(rad(-24), 0, 0),
						LeftHip = ang(rad(28), 0, 0),
					},
					vfxCue = "AttackWindup",
				},
			},
		},

		Attack = {
			state = "Attack",
			duration = 0.20,
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, -0.15, 0.30) * ang(rad(6), rad(-48), 0),
						RightShoulder = cf(0.3, -0.1, 0.5) * ang(rad(-38), rad(-40), rad(25)),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Expo,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						-- Hiken (Fire Punch): บิดสะโพกชกหมัดขวาปล่อยเสาเพลิง
						RootJoint = cf(0, -0.05, -0.75) * ang(rad(-14), rad(42), 0),
						Neck = ang(rad(8), rad(-38), 0),
						RightShoulder = cf(0, 0.1, -0.8) * ang(rad(92), rad(-32), 0),
						LeftShoulder = ang(rad(-42), 0, rad(-30)),
						RightHip = ang(rad(30), 0, 0),
						LeftHip = ang(rad(-28), 0, 0),
					},
					vfxCue = "AttackRelease",
				},
			},
		},

		Impact = {
			state = "Impact",
			duration = 0.15,
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, -0.05, -0.75) * ang(rad(-14), rad(42), 0),
						RightShoulder = cf(0, 0.1, -0.85) * ang(rad(92), rad(-32), 0),
					},
					vfxCue = "AttackImpact",
				},
				{
					alpha = 1.0,
					poses = {
						RootJoint = cf(0, -0.05, -0.60) * ang(rad(-10), rad(35), 0),
						RightShoulder = cf(0, 0.1, -0.70) * ang(rad(88), rad(-28), 0),
					},
				},
			},
		},

		Recovery = {
			state = "Recovery",
			duration = 0.37,
			looped = false,
			canCancel = true,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, -0.05, -0.60) * ang(rad(-10), rad(35), 0),
					},
				},
				{
					alpha = 1.0,
					easingStyle = Enum.EasingStyle.Quad,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						RootJoint = cf(0, 0.02, 0) * ang(0, rad(-15), 0),
						Neck = ang(rad(-4), rad(15), 0),
						RightShoulder = cf(0, 0.05, -0.25) * ang(rad(68), rad(-15), rad(12)),
						LeftShoulder = ang(rad(-18), 0, rad(-28)),
						RightHip = ang(rad(-10), 0, 0),
						LeftHip = ang(rad(12), 0, 0),
					},
				},
			},
		},

		Ultimate = {
			state = "Ultimate",
			duration = 2.20,
			looped = false,
			canCancel = false,
			keyframes = {
				{
					alpha = 0.0,
					poses = {
						RootJoint = cf(0, 0.1, 0),
						RightShoulder = ang(rad(45), 0, rad(45)),
						LeftShoulder = ang(rad(45), 0, rad(-45)),
					},
				},
				{
					alpha = 0.40,
					easingStyle = Enum.EasingStyle.Cubic,
					easingDirection = Enum.EasingDirection.Out,
					poses = {
						-- Dai Enkai: Entei — ชูมือขวาขึ้นตั้งฉากเหนือหัวสร้างดวงอาทิตย์เพลิง
						RootJoint = cf(0, 0.85, 0) * ang(rad(12), 0, 0),
						Neck = ang(rad(35), 0, 0),
						RightShoulder = cf(0, 0.45, 0) * ang(rad(176), 0, rad(8)),
						LeftShoulder = ang(rad(35), 0, rad(-55)),
						RightHip = ang(rad(-15), 0, 0),
						LeftHip = ang(rad(-10), 0, 0),
					},
					vfxCue = "UltimateCast",
				},
				{
					alpha = 0.65,
					easingStyle = Enum.EasingStyle.Expo,
					easingDirection = Enum.EasingDirection.In,
					poses = {
						-- ขว้าง Entei ลงสู่เป้าหมาย
						RootJoint = cf(0, 0.25, -0.85) * ang(rad(-24), rad(35), 0),
						Neck = ang(rad(-12), rad(-30), 0),
						RightShoulder = cf(0, 0.1, -0.8) * ang(rad(75), 0, 0),
						LeftShoulder = ang(rad(-45), 0, rad(-35)),
					},
					vfxCue = "UltimateImpact",
				},
				{
					alpha = 1.0,
					poses = {
						RootJoint = cf(0, 0.02, 0) * ang(0, rad(-15), 0),
						Neck = ang(rad(-4), rad(15), 0),
						RightShoulder = cf(0, 0.05, -0.25) * ang(rad(68), rad(-15), rad(12)),
						LeftShoulder = ang(rad(-18), 0, rad(-28)),
						RightHip = ang(rad(-10), 0, 0),
						LeftHip = ang(rad(12), 0, 0),
					},
				},
			},
		},
	},
}

return table.freeze(AceAnimationProfile)
\`\`\`

&lt;!-- === FILE_END: docs/implementation-plans/0005-character-model-animation/characters/03-ace.md === --&gt;

---

&lt;!-- === FILE_START: docs/implementation-plans/0005-character-model-animation/assets/04-animation-lab-ui.md === --&gt;
# Animation Lab / Model Inspector UI Specification (`04-animation-lab-ui.md`)

- **Document ID:** `0005-character-model-animation/assets/04-animation-lab-ui.md`
- **Assigned Owner:** Core & DevTools Track (`AGY-Core`)
- **Git Branch:** `feat/phase5-core-contracts-and-lab`
- **Target Module Path:** `src/DevTools/AnimationLab/`
- **Verification Status:** `NOT VERIFIED` (Planning Stage Only)

---

## 1. UI Architecture Comparison & Recommended Approach

### 1.1 ตารางเปรียบเทียบ 3 สถาปัตยกรรม
| มิติการเปรียบเทียบ | 1. Roblox Studio Plugin (`DockWidgetPluginGui`) | 2. In-Game Studio-Only Developer UI (`ScreenGui` + `Workspace` Stage) | 3. Hybrid Architecture |
| :--- | :--- | :--- | :--- |
| **การซิงค์โค้ดผ่าน Rojo (`default.project.json`)** | ต้องแยก Build `.rbxm` ไปวางในโฟลเดอร์ `LocalPlugins` ของแต่ละเครื่อง | ซิงค์ผ่าน `default.project.json` ได้ทันที นักพัฒนาทั้ง 3 คนเปิดใช้งานได้เหมือนกัน 100% | ใช้ In-Game Studio UI เป็นหลัก และแยก `ModelValidator` ให้รันจาก Command Bar ใน Edit Mode ได้ด้วย |
| **ความถูกต้องของ VFX (`Particles`, `Beam`, `Trail`, `Lighting`)** | หากรันใน Edit Mode โดยไม่กด Play ระบบ `Heartbeat` และ Particle/Trail บางส่วนไม่ทำงานตามจังหวะจริง | **ทำงานตรงตาม Runtime จริง 100%** เพราะรันใน Studio Play Session (`RunService:IsStudio()`) | **ทำงานตรงตาม Runtime จริง 100%** |
| **การทดสอบร่วมกับ `TowerController` (Integration Mode)** | แยก Security Context ออกจากสคริปต์ในเกม | เรียกใช้ `AnimationController`, `VFXDispatcher`, และโหมดจำลองการโจมตีได้โดยตรง | เรียกใช้ได้โดยตรง |
| **ความปลอดภัยบน Production Server** | ไม่ติดไปกับเกม | บล็อกและทำลายตัวเองทันทีด้วย `if not RunService:IsStudio() then script.Parent:Destroy() return end` | บล็อกด้วย `RunService:IsStudio()` เช่นเดียวกัน |

### 1.2 แนวทางที่เลือก (Selected Architecture)
เลือก **In-Game Studio-Only Developer Dashboard (พร้อม Headless Validator Modules)** ภายใต้ `src/DevTools/AnimationLab/` เพราะสอดคล้องกับเวิร์กโฟลว์ Rojo + Git Worktree ของทีมมากที่สุด ไม่ต้องตั้งค่า Plugin แยกเครื่อง และสามารถพรีวิว `ParticleEmitter`, `Trail`, `Beam`, `Highlight`, และ `Camera Shake` บน **Isolated Workspace Sandbox Stage** ได้ครบ 100%

---

## 2. ViewportFrame vs Workspace Sandbox Stage (Critical Technical Resolution)

- **ข้อเท็จจริงทางเทคนิค:** `ViewportFrame` ของ Roblox **ไม่เรนเดอร์ `ParticleEmitter`, `Beam`, `Trail`, `Highlight`, และ `PointLight`** ดังนั้นหากสร้าง Animation Lab โดยใช้ `ViewportFrame` เพียงอย่างเดียว นักพัฒนาจะไม่สามารถมองเห็นไฟของ Ace, รอยดาบและออร่าฮาคิของ Zoro, หรือเมฆและสายฟ้าฮาคิราชันย์ของ Luffy ได้เลย!
- **สถาปัตยกรรมที่เราใช้ใน Animation Lab:**
  1. **Primary Preview — `Workspace.__AnimationLabSandbox` (Isolated 3D Studio Stage):**
     - สร้างแท่นทดสอบแยกไว้ที่พิกัด `Vector3.new(0, 5000, 0)` ห่างจากแผนที่หลัก 5,000 Studs
     - เมื่อเปิด Animation Lab กล้อง `Workspace.CurrentCamera` จะเปลี่ยนเป็น `Scriptable` และจับภาพที่แท่น `SandboxStage` โดยตรงผ่านช่องว่างตรงกลางของหน้าจอ Dashboard (`Central Viewport Window`)
     - รองรับการแสดงผล `ParticleEmitter`, `Beam`, `Trail`, `PointLight`, `Highlight`, และ `Camera Shake` ได้ **ครบ 100%**
  2. **Secondary Preview — Mini `ViewportFrame` Inspector:**
     - ใช้สำหรับโหมดตรวจโครงสร้าง `Part Hierarchy` แบบ Ortho/Wireframe ย่อส่วนเมื่อไม่ต้องการดู Particle

---

## 3. Screen Layout, Component Tree & Module Boundaries

### 3.1 Component Tree (`ScreenGui: AnimationLabGui`)
```text
AnimationLabGui (ScreenGui - ResetOnSpawn = false, IgnoreGuiInset = true, Studio Only)
├── TopHeaderBar (Frame)
│   ├── TitleLabel ("ANIME LIMITLESS TD — PHASE 5 ANIMATION & VFX LAB")
│   ├── ModeSwitchGroup (Visual Sandbox Mode | Controlled Integration Mode)
│   ├── QualityPresetSelector (Low | Medium | High)
│   └── CloseLabButton ([X] คืนค่า Camera & ล้าง Sandbox Instances ทั้งหมดทันที)
├── LeftSidebar_ModelExplorer (Frame - Width: 260px)
│   ├── SearchFilterBox (TextBox)
│   ├── CategoryAccordion_Heroes (12 Models: Luffy, Zoro, Nami, Usopp, Sanji, Chopper, Robin, Shanks, Whitebeard, Ace, Law, Kizaru)
│   ├── CategoryAccordion_Enemies (4 Models: PirateGrunt, SoruAssassin, HakiBrute, YonkoBoss)
│   └── CategoryAccordion_MapAssets (3 Models: AnimeBaseCrystal, EnemySpawnGate, PlacementPadTemplate)
├── CenterStage_OverlayControls (Frame - Transparent Pass-through over 3D Sandbox Stage)
│   ├── CameraToolbar (Orbit | Front | Side | Back | Reset Cam | Focus Model)
│   ├── StageToggleBar (☑ Grid | ☑ Joint Markers | ☐ Bounding Box | ☑ Accessories | ☑ Dummy Target | Scale Slider)
│   └── ValidationBanner (แสดงรายการ Error/Warning ของโมเดลที่เลือก หากตรวจพบ)
├── BottomCenter_AnimationAndVFXDock (Frame - Height: 250px)
│   ├── AnimationPlayerSubPanel
│   │   ├── StateSelectorButtons (Idle | Sp.Idle | Spawn | Windup | Attack | Impact | Recovery | Ultimate)
│   │   ├── TransportControls (Play | Pause | Stop | Replay | Step -1f | Step +1f | Reset Pose | Loop Toggle)
│   │   ├── SpeedPresetButtons (0.25x | 0.5x | 1.0x | 1.5x | 2.0x)
│   │   └── FivePhaseTimelineBar (แถบแสดงสัดส่วน Wind-up -> Attack -> Impact -> Recovery พร้อม Playhead Cursor)
│   └── VFXInspectorSubPanel
│       ├── TriggerActionButtons (Trigger Attack VFX | Trigger Ultimate VFX | Play Anim + VFX Combo | Reset All VFX)
│       ├── LayerToggleCheckboxes (Particles | Aura | Trail/Beam | Impact FX | Camera Shake | Screen Flash)
│       └── IntensitySlider (0.1x – 2.0x)
└── RightSidebar_DebugAndPerformance (Frame - Width: 300px)
    ├── RealTimeMetricsCard (Model ID, Source, Part/Motor6D/Weld/Emitter/VFX/Tween/Instance Leak Counters)
    ├── PartHierarchyTreeView (ScrollingFrame แสดงต้นไม้ของ Part, Motor6D และ WeldConstraint)
    └── PerformanceStressTestCard
        ├── ScenarioButtons (1 Char | 10 Chars | 25 Chars | 50 Chars)
        ├── StressActionButtons (Simultaneous VFX Burst | Run Cleanup/Leak Verification)
        └── TelemetryReadout (FPS, Frame Time ms, Peak VFX Instances, Leak Delta)
```

### 3.2 Module Boundaries (`src/DevTools/AnimationLab/`)
| โมดูล | หน้าที่รับผิดชอบเฉพาะทาง (Single Responsibility) |
| :--- | :--- |
| `AnimationLabBootstrap.server.luau` | ตรวจสอบ `RunService:IsStudio()` และสร้างช่องทางเปิด/ปิด Lab เฉพาะใน Studio |
| `LabConfig.luau` | เก็บรายการ Asset Inventory ทั้ง 19 รายการ พร้อมเกณฑ์มาตรฐานและ Performance Budget |
| `ModelValidator.luau` | ตรวจสอบโมเดลจริงแบบ Runtime: เช็กว่าไฟล์มีอยู่จริง, โหลดได้, มี `PrimaryPart`, ตรวจหา `WeldConstraint` ที่ทับ `Motor6D`, ตรวจ `Anchored` บนอวัยวะลูก และคืนค่าสถานะตามจริง (ห้ามปลอมสถานะ `Complete`) |
| `SandboxStageManager.luau` | สร้าง/ทำลาย `Workspace.__AnimationLabSandbox`, จัดการพื้น Grid, แท่นวางโมเดล, หุ่น `DummyTarget` (เลื่อนระยะได้), Joint Markers (`SphereHandleAdornment`), และ `SelectionBox` |
| `TelemetryCollector.luau` | เก็บสถิติ Real-time (`Part`, `Motor6D`, `Weld`, `ParticleEmitter`, `ActiveVFX`, `TrackedTweens`, `Created vs Cleaned Instances`, `FrameTime ms`) |
| `StressTestRunner.luau` | เสกตัวละครจำนวน 1 / 10 / 25 / 50 ตัวลงบนตารางใน Sandbox Stage สั่งเล่น Animation + VFX พร้อมกัน แล้ววัดค่า Frame Time และตรวจ Instance Leak หลังสั่งลบทั้งหมด |

---

## 4. Detailed Feature Matrix & Debug Data Sources

### 4.1 แหล่งข้อมูลของ Real-Time Debug Inspector และข้อจำกัดของ Roblox API
- **`Model Name / Hero ID` & `Asset Source`:** อ่านจาก `LabConfig` และ Path จริงที่โหลดโมเดล (`GetFullName()`)
- **`Part Count`, `Active Motor6D Count`, `Active Weld Count`:** สแกนจาก `model:GetDescendants()`
- **`Active Particle Emitters`:** นับจำนวน `ParticleEmitter` ในโมเดลและใน `SandboxVFXFolder` ที่มี `Enabled == true` หรือเพิ่งถูกสั่ง `:Emit()` ภายในช่วง `Lifetime.Max`
- **`Active VFX Instances`:** นับจำนวนลูกทั้งหมดใน `Workspace.__AnimationLabSandbox.ActiveVFX`
- **`Active Tween Count` (Custom Instrumentation):** เนื่องจาก Roblox `TweenService` ไม่มี API อ่านจำนวน Tween ที่กำลังเล่นอยู่ เราจึงวัดผ่าน `AnimationController:GetActiveTweenCount()` และ `VFXDispatcher:GetActiveTweenCount()` ที่ครอบ `TweenService:Create()` ทุกจุดในระบบ Phase 5
- **`Instance Creation / Cleanup Balance`:** เปรียบเทียบค่า `totalRegisteredInstances` กับ `totalDestroyedInstances` หากกด `Reset All VFX` หรือลบโมเดลแล้วผลต่างไม่เท่ากับ `0` จะขึ้นข้อความสีแดงเตือนทันที

---

## 5. Performance Testing Design & Proposed Budgets (To Be Verified in Studio)

> **หมายเหตุสำคัญ:** ตัวเลขด้านล่างนี้คือ **เป้าหมายงบประมาณ (Proposed Performance Budget)** สำหรับใช้ตรวจสอบใน Roblox Studio จริง ยังไม่ใช่ผลการทดสอบที่ผ่านแล้ว (สถานะปัจจุบัน: `NOT VERIFIED`)

| สถานการณ์ทดสอบ (Scenario) | จำนวนตัวละครที่ทำงานพร้อมกัน | เพดาน Part รวมสูงสุด (Character + Active VFX) | เพดาน Active VFX Instances สูงสุด | เป้าหมาย Frame Time ใน Studio (`High` Preset) | เกณฑ์ Cleanup / Leak Test หลังจบการทดสอบ |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Single Character Test** | 1 ตัว | `<= 50 Parts` | `<= 25 Instances` | `<= 16.6 ms` (60 FPS) | `Remaining Sandbox Instances == 0` |
| **10 Active Characters** | 10 ตัว (คละ Luffy/Zoro/Ace) | `<= 380 Parts` | `<= 160 Instances` | `<= 16.6 ms` (60 FPS) | `Remaining Sandbox Instances == 0` |
| **25 Active Characters** | 25 ตัว (คละ Luffy/Zoro/Ace) | `<= 850 Parts` | `<= 300 Instances` (Auto-throttled) | `<= 20.0 ms` (>= 50 FPS) | `Remaining Sandbox Instances == 0` |
| **50 Active Characters (Stress)** | 50 ตัว (คละ Luffy/Zoro/Ace) | `<= 1,500 Parts` | `<= 450 Instances` (Auto-fallback to `Medium/Low`) | `<= 25.0 ms` (>= 40 FPS) | `Remaining Sandbox Instances == 0` |

### การเชื่อมกับ Roblox MicroProfiler & Developer Console
- ภายใน `AnimationController.Step()` และ `VFXDispatcher.TriggerCue()` มีการครอบด้วย:
  - `debug.profilebegin("ALT_Phase5_AnimationStep")` ... `debug.profileend()`
  - `debug.profilebegin("ALT_Phase5_VFXDispatch")` ... `debug.profileend()`
- นักพัฒนาสามารถกด `Ctrl + F6` ใน Roblox Studio เพื่อดูกราฟเวลา CPU ของทั้ง 2 ป้ายกำกับได้โดยตรงใน MicroProfiler

---

## 6. Sandbox Isolation & Security Restrictions

1. **Zero Gameplay Mutation Guarantee:**
   - ในโหมด **Visual Sandbox** โมเดลทั้งหมดถูกสร้างใน `Workspace.__AnimationLabSandbox` เท่านั้น ไม่มีการเรียกใช้ฟังก์ชันหักเงิน, สุ่ม Gacha, เพิ่ม/ลด Tower ใน Inventory, หรือเปลี่ยน Wave ปัจจุบัน
   - ในโหมด **Controlled Integration Test** ศัตรูจำลองที่สร้างขึ้นจะมี Attribute `IsAnimationLabDummy = true` และอยู่ในลูปการทดสอบเฉพาะกิจ เมื่อปิดหน้าต่าง Animation Lab โมดูล `SandboxStageManager:CleanupAll()` จะลบทุก Instance ใน `Workspace.__AnimationLabSandbox` ทิ้งทันที 100%
2. **Production Lockout (`RunService:IsStudio()`):**
   - ห้ามเปิดใช้งาน Animation Lab ในเกมที่ Publish จริงเด็ดขาด
   - ทั้งฝั่ง Server (`AnimationLabBootstrap.server.luau`) และฝั่ง UI ตรวจสอบ `RunService:IsStudio()` ก่อนทำงาน หากเป็น Production Server จะสั่ง `:Destroy()` โฟลเดอร์ `AnimationLab` ทันทีตั้งแต่เริ่มรันเกมและไม่สร้าง `RemoteEvent` ใดๆ ทิ้งไว้

---

## 7. Acceptance Criteria for Animation Lab UI

1. แสดงรายชื่อครบทั้ง 19 โมเดล (12 Heroes, 4 Enemies, 3 Map Assets) พร้อมแสดงสถานะจริงจากการตรวจสอบของ `ModelValidator` (ไม่แสดง `Complete` หากโมเดลยังไม่ได้ทำหรือมีข้อผิดพลาด)
2. สามารถหมุนกล้อง ซูม เปลี่ยนมุมมอง (`Front`/`Side`/`Back`/`Reset`/`Focus`) เปิด/ปิด Grid, Joint Markers, Bounding Box, Accessories และปรับ Scale โมเดลได้จริง
3. สามารถสั่งเล่น หยุด พัก เล่นซ้ำ ปรับความเร็ว เลือก State และเลื่อนดูจังหวะ `Idle -> Wind-up -> Attack -> Impact -> Recovery` บน Timeline ได้โดยไม่เกิด Error
4. สามารถสั่งยิง VFX เดี่ยวๆ หรือเล่นคู่กับ Animation พร้อมเปิด/ปิดแยกเลเยอร์และปรับ Quality Preset (`Low`/`Medium`/`High`) ได้จริง และเห็น `ParticleEmitter`, `Trail`, `Beam` ครบถ้วนบน Sandbox Stage
5. สามารถรัน Stress Test 1 / 10 / 25 / 50 ตัวละคร และรัน Cleanup/Leak Test เพื่อยืนยันว่าไม่มี Instance ค้างหลังล้างฉาก


---

## 8. Hand-Holding Luau Code Blueprints for Core / Animation Lab (`ModelValidator.luau` & `AnimationRegistry.luau`)

### 8.1 พิมพ์เขียว `src/Track2_TowerSystem/AnimationRegistry.luau` (Zero-Conflict Dynamic Loader)
\`\`\`luau
--!strict
-- src/Track2_TowerSystem/AnimationRegistry.luau
-- Owned by: AGY-Core
-- โหลดโมดูลใน Animations/ และ VFX/ แบบ Dynamic Discovery เพื่อไม่ให้ Dev 1, 2, 3 ต้องแก้ไฟล์นี้ตอนเพิ่มตัวละคร

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AnimationContract = require(ReplicatedStorage.Shared.AnimationContract)
local VFXContract = require(ReplicatedStorage.Shared.VFXContract)

local AnimationsFolder = script.Parent:WaitForChild("Animations")
local VFXFolder = script.Parent:WaitForChild("VFX")
local FallbackProfile = require(AnimationsFolder:WaitForChild("_FallbackProfile"))
local FallbackVFX = require(VFXFolder:WaitForChild("_FallbackVFX"))

local AnimationRegistry = {}
local profileCache: { [string]: AnimationContract.CharacterAnimationProfile } = {}
local vfxCache: { [string]: VFXContract.CharacterVFXModule } = {}

function AnimationRegistry.GetAnimationProfile(heroId: string): (AnimationContract.CharacterAnimationProfile, boolean)
	if profileCache[heroId] then
		return profileCache[heroId], true
	end
	local moduleInst = AnimationsFolder:FindFirstChild(heroId)
	if moduleInst and moduleInst:IsA("ModuleScript") then
		local ok, result = pcall(require, moduleInst)
		if ok and type(result) == "table" and result.states then
			profileCache[heroId] = result :: AnimationContract.CharacterAnimationProfile
			return profileCache[heroId], true
		else
			warn(string.format("[AnimationRegistry] Failed to load AnimationProfile for '%s': %s", heroId, tostring(result)))
		end
	end
	return FallbackProfile.CreateForHero(heroId), false
end

function AnimationRegistry.GetVFXModule(heroId: string): (VFXContract.CharacterVFXModule, boolean)
	if vfxCache[heroId] then
		return vfxCache[heroId], true
	end
	local moduleInst = VFXFolder:FindFirstChild(heroId .. "VFX")
	if moduleInst and moduleInst:IsA("ModuleScript") then
		local ok, result = pcall(require, moduleInst)
		if ok and type(result) == "table" and type(result.triggerCue) == "function" then
			vfxCache[heroId] = result :: VFXContract.CharacterVFXModule
			return vfxCache[heroId], true
		else
			warn(string.format("[AnimationRegistry] Failed to load VFXModule for '%s': %s", heroId, tostring(result)))
		end
	end
	return FallbackVFX, false
end

return AnimationRegistry
\`\`\`

### 8.2 พิมพ์เขียว `src/DevTools/AnimationLab/ModelValidator.luau` (Ground-Truth Asset Inspector)
\`\`\`luau
--!strict
-- src/DevTools/AnimationLab/ModelValidator.luau
-- ตรวจสอบสถานะจริงของทั้ง 19 Models ห้ามรายงานว่า Complete หากตรวจไม่ผ่านจริง

export type ModelValidationReport = {
	assetId: string,
	category: "Heroes" | "Enemies" | "MapAssets",
	fileExists: boolean,
	loadable: boolean,
	hasPrimaryPart: boolean,
	partCount: number,
	motor6DCount: number,
	weldCount: number,
	anchoredChildLimbCount: number,
	conflictingWeldOnMotorCount: number,
	hasSignatureAnimationModule: boolean,
	hasSignatureVFXModule: boolean,
	overallStatus: "MISSING" | "BROKEN_RIG" | "FALLBACK_ONLY" | "SIGNATURE_READY",
	validationErrors: { string },
}

local ModelValidator = {}

function ModelValidator.InspectModelInstance(
	assetId: string,
	category: "Heroes" | "Enemies" | "MapAssets",
	templateModel: Model?,
	hasSigAnim: boolean,
	hasSigVFX: boolean
): ModelValidationReport
	local errors: { string } = {}
	if not templateModel then
		table.insert(errors, "Model template not found in AssetKit container.")
		return {
			assetId = assetId,
			category = category,
			fileExists = false,
			loadable = false,
			hasPrimaryPart = false,
			partCount = 0,
			motor6DCount = 0,
			weldCount = 0,
			anchoredChildLimbCount = 0,
			conflictingWeldOnMotorCount = 0,
			hasSignatureAnimationModule = hasSigAnim,
			hasSignatureVFXModule = hasSigVFX,
			overallStatus = "MISSING",
			validationErrors = errors,
		}
	end

	local okClone, cloned = pcall(function()
		return templateModel:Clone()
	end)
	if not okClone or not cloned then
		table.insert(errors, "Model:Clone() failed at runtime.")
		return {
			assetId = assetId,
			category = category,
			fileExists = true,
			loadable = false,
			hasPrimaryPart = false,
			partCount = 0,
			motor6DCount = 0,
			weldCount = 0,
			anchoredChildLimbCount = 0,
			conflictingWeldOnMotorCount = 0,
			hasSignatureAnimationModule = hasSigAnim,
			hasSignatureVFXModule = hasSigVFX,
			overallStatus = "BROKEN_RIG",
			validationErrors = errors,
		}
	end

	local rootPart = cloned.PrimaryPart or cloned:FindFirstChild("HumanoidRootPart") or cloned:FindFirstChildWhichIsA("BasePart")
	local hasPrimary = rootPart ~= nil
	if not hasPrimary then
		table.insert(errors, "Model has no PrimaryPart or BasePart.")
	end

	local partCount = 0
	local motorCount = 0
	local weldCount = 0
	local anchoredChildren = 0
	local motorParts: { [BasePart]: boolean } = {}
	local weldParts: { [BasePart]: boolean } = {}

	for _, desc in ipairs(cloned:GetDescendants()) do
		if desc:IsA("BasePart") then
			partCount += 1
			if desc ~= rootPart and desc.Anchored then
				anchoredChildren += 1
			end
		elseif desc:IsA("Motor6D") then
			motorCount += 1
			if desc.Part1 then
				motorParts[desc.Part1] = true
			end
		elseif desc:IsA("WeldConstraint") or desc:IsA("Weld") then
			weldCount += 1
			local p1 = (desc :: any).Part1 :: BasePart?
			if p1 then
				weldParts[p1] = true
			end
		end
	end

	local conflictCount = 0
	for part in pairs(motorParts) do
		if weldParts[part] then
			conflictCount += 1
			table.insert(errors, string.format("Part '%s' has BOTH Motor6D and WeldConstraint (Rig Conflict)!", part.Name))
		end
	end

	if anchoredChildren > 0 and category ~= "MapAssets" then
		table.insert(errors, string.format("%d child parts have Anchored=true before SanitizeAndRigModel.", anchoredChildren))
	end

	cloned:Destroy()

	local status: "MISSING" | "BROKEN_RIG" | "FALLBACK_ONLY" | "SIGNATURE_READY" = "FALLBACK_ONLY"
	if not hasPrimary or conflictCount > 0 then
		status = "BROKEN_RIG"
	elseif hasSigAnim and hasSigVFX then
		status = "SIGNATURE_READY"
	end

	return {
		assetId = assetId,
		category = category,
		fileExists = true,
		loadable = true,
		hasPrimaryPart = hasPrimary,
		partCount = partCount,
		motor6DCount = motorCount,
		weldCount = weldCount,
		anchoredChildLimbCount = anchoredChildren,
		conflictingWeldOnMotorCount = conflictCount,
		hasSignatureAnimationModule = hasSigAnim,
		hasSignatureVFXModule = hasSigVFX,
		overallStatus = status,
		validationErrors = errors,
	}
end

return ModelValidator
\`\`\`

&lt;!-- === FILE_END: docs/implementation-plans/0005-character-model-animation/assets/04-animation-lab-ui.md === --&gt;

---

## PART 6 — COMPLETE REFERENCE LUAU IMPLEMENTATIONS & ADDITIONAL RECOMMENDATIONS

เพื่อให้ทีมพัฒนา (`AGY-Core` และ `Dev 1–3`) สามารถนำไปใช้เป็นพิมพ์เขียวอ้างอิงได้อย่างแม่นยำโดยไม่ต้องเดาโครงสร้าง ด้านล่างนี้คือ:
1. **พิมพ์เขียวโค้ด Luau ของ `AnimationController.luau` (ส่วนแก้ปัญหา `WeldConstraint` ทับ `Motor6D` และระบบ Procedural Keyframe Evaluator)**
2. **ข้อเสนอแนะเพิ่มเติม (Additional Recommendations): สิ่งที่ควรทำใน Phase 5 vs สิ่งที่ควรเลื่อนไป Phase 6 พร้อมตารางเปรียบเทียบทางเลือกและ Trade-offs**

---

### 6.1 พิมพ์เขียวอ้างอิง: การแก้ปัญหา `WeldConstraint` vs `Motor6D` ใน `AnimationController.luau`

```luau
--!strict
-- Reference Implementation Blueprint สำหรับ src/Track2_TowerSystem/AnimationController.luau
-- แก้ปัญหา Part-based Model ที่ถูก VisualBridge Weld ทับจนขยับ Motor6D ไม่ได้

local TweenService = game:GetService("TweenService")
local AnimationContract = require(game.ReplicatedStorage.Shared.AnimationContract)

local AnimationController = {}

-- รายชื่อชิ้นส่วนอวัยวะมาตรฐานที่ต้องปลดล็อกจาก WeldConstraint เพื่อใช้ Motor6D
local ARTICULATED_LIMB_NAMES = {
	Torso = true,
	UpperTorso = true,
	Head = true,
	RightArm = true,
	LeftArm = true,
	RightLeg = true,
	LeftLeg = true,
}

function AnimationController.SanitizeAndRigModel(
	model: Model,
	profile: AnimationContract.CharacterAnimationProfile
): AnimationContract.RigContext?
	local rootPart = model.PrimaryPart
		or model:FindFirstChild("HumanoidRootPart") :: BasePart?
		or model:FindFirstChild("RootPart") :: BasePart?
		or model:FindFirstChildWhichIsA("BasePart")

	if not rootPart then
		warn(string.format("[AnimationController] Model '%s' has no valid RootPart", model.Name))
		return nil
	end
	model.PrimaryPart = rootPart

	-- ขั้นตอนที่ 1: บังคับให้เฉพาะ RootPart เท่านั้นที่ Anchored = true
	-- ส่วนชิ้นส่วนย่อยทั้งหมดต้องเป็น Anchored = false, Massless = true, CanCollide = false
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("BasePart") then
			if desc == rootPart then
				desc.Anchored = true
				desc.CanCollide = false
			else
				desc.Anchored = false
				desc.CanCollide = false
				desc.CanTouch = false
				desc.CanQuery = false
				desc.Massless = true
			end
		end
	end

	-- ขั้นตอนที่ 2: ลบ WeldConstraint หรือ Weld ที่ยึดอวัยวะหลักเข้ากับ RootPart ออก
	-- เพื่อไม่ให้เกิด Rigid Constraint Override ทับ Motor6D
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("WeldConstraint") or desc:IsA("Weld") then
			local p0 = (desc :: any).Part0 :: BasePart?
			local p1 = (desc :: any).Part1 :: BasePart?
			if p0 and p1 then
				if ARTICULATED_LIMB_NAMES[p0.Name] or ARTICULATED_LIMB_NAMES[p1.Name] then
					desc:Destroy()
				end
			end
		end
	end

	-- ขั้นตอนที่ 3: สร้างหรือค้นหา Motor6D สำหรับข้อต่อหลัก และบันทึก BaseC0 / BaseC1
	local torso = (model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso") or rootPart) :: BasePart
	local limbs: { [string]: BasePart } = {
		HumanoidRootPart = rootPart,
		Torso = torso,
	}
	for limbName in pairs(ARTICULATED_LIMB_NAMES) do
		local found = model:FindFirstChild(limbName, true)
		if found and found:IsA("BasePart") then
			limbs[limbName] = found
		end
	end

	local motors: { [AnimationContract.JointName]: Motor6D } = {}
	local baseC0: { [AnimationContract.JointName]: CFrame } = {}
	local baseC1: { [AnimationContract.JointName]: CFrame } = {}

	local function ensureMotor(jointName: AnimationContract.JointName, part0: BasePart?, part1: BasePart?): Motor6D?
		if not part0 or not part1 or part0 == part1 then
			return nil
		end
		local existing = part0:FindFirstChild(jointName)
		local motor: Motor6D
		if existing and existing:IsA("Motor6D") then
			motor = existing
		else
			motor = Instance.new("Motor6D")
			motor.Name = jointName
			motor.Part0 = part0
			motor.Part1 = part1
			-- คำนวณ Relative CFrame ปัจจุบันของโมเดลเป็น RestPose C0 เพื่อไม่ให้ชิ้นส่วนกระโดดผิดตำแหน่ง
			motor.C0 = part0.CFrame:ToObjectSpace(part1.CFrame)
			motor.C1 = CFrame.new()
			motor.Parent = part0
		end
		motors[jointName] = motor
		baseC0[jointName] = motor.C0
		baseC1[jointName] = motor.C1
		return motor
	end

	ensureMotor("RootJoint", rootPart, limbs.Torso)
	ensureMotor("Neck", limbs.Torso, limbs.Head)
	ensureMotor("RightShoulder", limbs.Torso, limbs.RightArm)
	ensureMotor("LeftShoulder", limbs.Torso, limbs.LeftArm)
	ensureMotor("RightHip", limbs.Torso, limbs.RightLeg)
	ensureMotor("LeftHip", limbs.Torso, limbs.LeftLeg)

	-- ขั้นตอนที่ 4: จัดการ Accessories ตาม accessoryRules ใน Profile
	for _, rule in ipairs(profile.accessoryRules) do
		local targetLimb = limbs[rule.attachToLimb]
		if targetLimb then
			for _, desc in ipairs(model:GetDescendants()) do
				if desc:IsA("BasePart") and string.find(desc.Name, rule.accessoryNamePattern, 1, true) then
					-- ลบ Weld เดิมที่อาจผูกผิดไปติดกับ RootPart
					for _, child in ipairs(desc:GetChildren()) do
						if child:IsA("WeldConstraint") or child:IsA("Weld") or child:IsA("Motor6D") then
							child:Destroy()
						end
					end
					if rule.offsetCFrame then
						desc.CFrame = targetLimb.CFrame * rule.offsetCFrame
					end
					if rule.useMotor6D and rule.jointName then
						ensureMotor(rule.jointName, targetLimb, desc)
					else
						local weld = Instance.new("WeldConstraint")
						weld.Name = "AccessoryWeld_" .. desc.Name
						weld.Part0 = targetLimb
						weld.Part1 = desc
						weld.Parent = desc
					end
				end
			end
		end
	end

	return {
		model = model,
		rootPart = rootPart,
		torso = limbs.Torso,
		limbs = limbs,
		motors = motors,
		baseC0 = baseC0,
		baseC1 = baseC1,
		activeState = "Idle",
		playbackSpeed = 1.0,
		isPaused = false,
		elapsedInState = 0,
		cancelToken = 0,
	}
end

return AnimationController
```

---

### 6.2 ข้อเสนอแนะเพิ่มเติม (Additional Recommendations: Phase 5 vs Phase 6 Roadmap)

#### 1. สิ่งที่ควรปรับปรุงทันทีใน Phase 5 (High Priority — Do Now)
| รายการปรับปรุง | เหตุผลทางเทคนิค | ระดับความซับซ้อน | ลำดับความสำคัญ |
| :--- | :--- | :---: | :---: |
| **1. แยก `VisualBridge` Welding ออกจาก Articulated Limbs** | เป็นต้นเหตุโดยตรงที่ทำให้ `Motor6D` ขยับไม่ได้ หากไม่แก้ตั้งแต่ Wave 1 งานของทั้ง 3 ตัวละครจะแสดงผลไม่ถูกต้อง | Medium | **P0 (Blocker)** |
| **2. ใช้ Relative RestPose (`BaseC0 * OffsetCFrame`) แทน Absolute CFrame** | ป้องกันไม่ให้โมเดลที่วางตำแหน่งเริ่มต้นต่างกันเล็กน้อยใน `.rbxmx` แขนขาหลุดออกจากตัวเมื่อเล่นท่า | Low | **P0 (Blocker)** |
| **3. สร้าง Auto-Throttling VFX Budget ใน `VFXDispatcher`** | เมื่อมีตัวละครมากกว่า 20 ตัวโจมตีพร้อมกัน ระบบควรลดจำนวน Particle ต่อครั้งลงอัตโนมัติ (Dynamic Quality Scaling) เพื่อรักษา FPS | Medium | **P1 (High)** |
| **4. ใช้ Isolated Workspace Sandbox Stage คู่กับ Scriptable Camera ใน Animation Lab** | เพื่อให้ตรวจสอบ `ParticleEmitter`, `Trail`, และ `Beam` ได้จริง 100% โดยไม่ติดข้อจำกัดของ `ViewportFrame` | Medium | **P1 (High)** |

#### 2. สิ่งที่ควรเลื่อนไปทำใน Phase 6 (Defer to Phase 6 — Prevent Scope Creep)
| รายการที่ควรเลื่อนไป Phase 6 | เหตุผลที่ไม่ควรทำใน Phase 5 | ทางเลือกที่รองรับไว้แล้วใน Phase 5 |
| :--- | :--- | :--- |
| **1. การทำ Signature Animation ครบทั้ง 9 Heroes ที่เหลือ + 4 Enemies** | หากทำพร้อมกัน 16 ตัวในรอบเดียวก่อนที่ Pipeline และ Animation Lab จะผ่านการพิสูจน์จาก 3 ตัวแรก (`Luffy`, `Zoro`, `Ace`) จะทำให้เกิดงานแก้ซ้ำจำนวนมาก | ใช้ `_FallbackProfile.luau` และ `_FallbackVFX.luau` ประคองอีก 9 Heroes + 4 Enemies ให้ทำงานได้สมบูรณ์ใน Phase 5 ก่อน |
| **2. การย้ายการคำนวณ Animation & VFX ทั้งหมดไปฝั่ง Client (`Client-Side Replication Architecture`)** | ปัจจุบัน `TowerController.server.luau` ทำงานฝั่ง Server เป็นหลัก การรื้อระบบ Network Replication ทั้งหมดใน Phase 5 จะกระทบโครงสร้าง Phase 4 มากเกินไป | ใน Phase 5 เราแยก `AnimationController` และ `VFXDispatcher` เป็น ModuleScript ที่สะอาดไว้แล้ว ใน Phase 6 สามารถเปลี่ยนให้ Server ส่งแค่ `RemoteEvent:FireAllClients(towerId, state, targetPos)` แล้วให้ Client รันโมดูลเดียวกันนี้ได้ทันทีโดยไม่ต้องเขียนท่าใหม่! |
| **3. Skinned Mesh (`Bone` / Deformable Mesh Rig) และ KeyframeSequence Importer** | ต้องใช้ Blender Pipeline และการอัปโหลด Asset ผูกกับบัญชีผู้สร้าง ซึ่งขัดกับแนวทาง Part-based `.rbxmx` ที่ซิงค์ผ่าน Git/Rojo ได้ทันที | ใช้ Procedural `Motor6D` Keyframe Interpolation ร่วมกับการปรับ `BasePart.Size` เฉพาะจุด (เช่น หมัดยืดของ Luffy) ซึ่งทำงานได้ 100% ใน Git/Rojo โดยไม่ต้องพึ่ง External Asset ID |
| **4. Visual Curve Editor (กราฟ Bezier สำหรับลากแก้ท่าใน UI)** | เพิ่มความซับซ้อนของ UI เกินจำเป็นสำหรับการตรวจสอบและ Debug | ใน Phase 5 มีปุ่ม Step `-1f / +1f`, Timeline Scrubbing, และการ Reload โมดูลท่าทางเพื่อดูผลลัพธ์ได้ทันที |

#### 3. ตารางสรุปทางเลือกสถาปัตยกรรมและ Trade-offs (Architectural Options & Trade-offs)
| หัวข้อการตัดสินใจ | ทางเลือก A | ทางเลือก B | ทางเลือกที่แนะนำสำหรับ Phase 5 & เหตุผล |
| :--- | :--- | :--- | :--- |
| **รูปแบบการเก็บข้อมูล Animation** | ใช้ Roblox `Animation` Instance (`rbxassetid://`) | ใช้ **Procedural Keyframe Table (`CFrame` + `EasingStyle`) ใน Luau Module** | **เลือกทางเลือก B:** ไม่ติดปัญหา Asset Permission ข้ามเครื่อง Developer ทั้ง 3 คน, เก็บเข้า Git Diff ได้ 100%, และทำ Scrub Timeline ใน Animation Lab ได้ทันที |
| **การแสดงผล 3D ใน Animation Lab** | ใช้ `ViewportFrame` ล้วน | ใช้ **Isolated Workspace Sandbox Stage + Scriptable Camera** (พร้อม Mini-ViewportFrame เสริม) | **เลือกทางเลือก B:** เพราะ `ViewportFrame` ไม่แสดง `ParticleEmitter`, `Trail`, `Beam`, และ `Lighting` ซึ่งจำเป็นอย่างยิ่งต่อการตรวจ VFX ของ Luffy, Zoro, และ Ace |
| **การเชื่อมท่าของตัวละครเข้ากับระบบหลัก** | แก้ไข `AnimationRegistry.luau` ทุกครั้งที่เพิ่มตัวละคร | ใช้ **Dynamic Child Module Discovery (`FindFirstChild(heroId)` + `pcall(require)`)** | **เลือกทางเลือก B:** ทำให้ Developer ทั้ง 3 คนทำงานใน Git Worktree แยกกันและ Merge กลับเข้ากิ่งหลักได้โดยไม่มี Git Conflict ที่ไฟล์กลางแม้แต่บรรทัดเดียว |
