# Animation Lab / Model Inspector UI Specification (`04-animation-lab-ui.md`)

> **IMPLEMENTATION AUTHORIZED / NOT STARTED:** AGY ทำ Lab รวมกับ Phase5 ทุก stream ตาม [HANDOFF ล่าสุด](HANDOFF.md); Codex รีวิวรวมตอนท้าย อ่าน [PLAN](../PLAN.md) และ [contracts](contracts-and-integration.md) ก่อน ตาราง budget §5 ยังเป็นตัวเลขต้นทางที่ไม่อนุมัติและขัด part count จริง


- **Document ID:** `0005-character-model-animation/assets/04-animation-lab-ui.md`
- **Implementer ที่เสนอ:** AGY-Core — ยังไม่มอบหมาย session
- **Branch/worktree:** ยังไม่สร้างและยังไม่อนุมัติรอบนี้
- **Target Module Path:** `src/DevTools/AnimationLab/`
- **Verification Status:** `NOT VERIFIED` (Planning Stage Only)

---

## 1. UI Architecture Comparison & Recommended Approach

### 1.1 ตารางเปรียบเทียบ 3 สถาปัตยกรรม
| มิติการเปรียบเทียบ | 1. Roblox Studio Plugin (`DockWidgetPluginGui`) | 2. In-Game Studio-Only Developer UI (`ScreenGui` + `Workspace` Stage) | 3. Hybrid Architecture |
| :--- | :--- | :--- | :--- |
| **การซิงค์โค้ดผ่าน Rojo (`default.project.json`)** | ต้องแยก Build `.rbxm` ไปวางในโฟลเดอร์ `LocalPlugins` ของแต่ละเครื่อง | ซิงค์ผ่าน `default.project.json` ได้ทันที นักพัฒนาทั้ง 3 คนเปิดใช้งานได้เหมือนกัน 100% | ใช้ In-Game Studio UI เป็นหลัก และแยก `ModelValidator` ให้รันจาก Command Bar ใน Edit Mode ได้ด้วย |
| **ความถูกต้องของ VFX (`Particles`, `Beam`, `Trail`, `Lighting`)** | หากรันใน Edit Mode โดยไม่กด Play ระบบ `Heartbeat` และ Particle/Trail บางส่วนไม่ทำงานตามจังหวะจริง | **เป้าหมายคือตรวจใน Studio Play; ยัง NOT VERIFIED** เพราะรันใน Studio Play Session (`RunService:IsStudio()`) | **เป้าหมายคือตรวจใน Studio Play; ยัง NOT VERIFIED** |
| **การทดสอบร่วมกับ `TowerController` (Integration Mode)** | แยก Security Context ออกจากสคริปต์ในเกม | เรียกใช้ `AnimationController`, `VFXDispatcher`, และโหมดจำลองการโจมตีได้โดยตรง | เรียกใช้ได้โดยตรง |
| **ความปลอดภัยบน Production Server** | ไม่ติดไปกับเกม | บล็อกและทำลายตัวเองทันทีด้วย `if not RunService:IsStudio() then script.Parent:Destroy() return end` | บล็อกด้วย `RunService:IsStudio()` เช่นเดียวกัน |

### 1.2 แนวทางที่เลือก (Selected Architecture)
เลือก **In-Game Studio-Only Developer Dashboard (พร้อม Headless Validator Modules)** ภายใต้ `src/DevTools/AnimationLab/` เพราะสอดคล้องกับเวิร์กโฟลว์ Rojo + Git Worktree ของทีมมากที่สุด ไม่ต้องตั้งค่า Plugin แยกเครื่อง และสามารถพรีวิว `ParticleEmitter`, `Trail`, `Beam`, `Highlight`, และ `Camera Shake` บน **Isolated Workspace Sandbox Stage** เป็น renderer หลักที่ต้องตรวจใน Studio จริง

---

## 2. ViewportFrame vs Workspace Sandbox Stage (Critical Technical Resolution)

- **ขอบเขตที่ตรวจได้:** ViewportFrame มีแสงผ่าน Ambient/LightColor/LightDirection และไม่ให้สมมุติว่า preview เท่ากับ Workspace; วาง VFX ตรวจหลักบน Workspace ส่วน Particle/Beam/Trail/Highlight/PostFX ต้องมี Studio capability check ไม่รับคำอ้างเหมารวมทุกชนิดจากต้นทางเป็นผลที่พิสูจน์แล้ว
- **สถาปัตยกรรมที่เราใช้ใน Animation Lab:**
  1. **Primary Preview — `Workspace.__AnimationLabSandbox` (Isolated 3D Studio Stage):**
     - สร้างแท่นทดสอบแยกไว้ที่พิกัด `Vector3.new(0, 5000, 0)` ห่างจากแผนที่หลัก 5,000 Studs
     - เมื่อเปิด Animation Lab กล้อง `Workspace.CurrentCamera` จะเปลี่ยนเป็น `Scriptable` และจับภาพที่แท่น `SandboxStage` โดยตรงผ่านช่องว่างตรงกลางของหน้าจอ Dashboard (`Central Viewport Window`)
     - รองรับการแสดงผล `ParticleEmitter`, `Beam`, `Trail`, `PointLight`, `Highlight`, และ `Camera Shake` โดยต้องตรวจใน Studio จริง
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

## 5. Performance Testing Design — ตัวเลขต้นทางที่ถูกกั้นด้วย D-04

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

## 6. Sandbox Isolation & Security Restrictions (target design; อ่านข้อแก้ไข §8 ก่อนลงมือ)

1. **Zero Gameplay Mutation — acceptance target:**
   - ในโหมด **Visual Sandbox** โมเดลทั้งหมดถูกสร้างใน `Workspace.__AnimationLabSandbox` เท่านั้น ไม่มีการเรียกใช้ฟังก์ชันหักเงิน, สุ่ม Gacha, เพิ่ม/ลด Tower ใน Inventory, หรือเปลี่ยน Wave ปัจจุบัน
   - ในโหมด **Controlled Integration Test** ศัตรูจำลองที่สร้างขึ้นจะมี Attribute `IsAnimationLabDummy = true` และอยู่ในลูปการทดสอบเฉพาะกิจ เมื่อปิดหน้าต่าง Animation Lab โมดูล `SandboxStageManager:CleanupAll()` จะลบทุก Instance ใน `Workspace.__AnimationLabSandbox` ทิ้งทันที 100%
2. **Production Lockout (`RunService:IsStudio()`):**
   - ห้ามเปิดใช้งาน Animation Lab ในเกมที่ Publish จริงเด็ดขาด
   - ทั้งฝั่ง Server (`AnimationLabBootstrap.server.luau`) และฝั่ง UI ตรวจสอบ `RunService:IsStudio()` ก่อนทำงาน หากเป็น Production Server ต้อง return ก่อนสร้าง UI/remotes/listeners; ไม่อ้างว่า server Destroy ย้อนลบ bytes ที่ replicate ไปแล้วได้

---

## 7. Acceptance Criteria for Animation Lab UI

1. แสดงรายชื่อครบทั้ง 19 โมเดล (12 Heroes, 4 Enemies, 3 Map Assets) พร้อมแสดงสถานะจริงจากการตรวจสอบของ `ModelValidator` (ไม่แสดง `Complete` หากโมเดลยังไม่ได้ทำหรือมีข้อผิดพลาด)
2. สามารถหมุนกล้อง ซูม เปลี่ยนมุมมอง (`Front`/`Side`/`Back`/`Reset`/`Focus`) เปิด/ปิด Grid, Joint Markers, Bounding Box, Accessories และปรับ Scale โมเดลได้จริง
3. สามารถสั่งเล่น หยุด พัก เล่นซ้ำ ปรับความเร็ว เลือก State และเลื่อนดูจังหวะ `Idle -> Wind-up -> Attack -> Impact -> Recovery` บน Timeline ได้โดยไม่เกิด Error
4. สามารถสั่งยิง VFX เดี่ยวๆ หรือเล่นคู่กับ Animation พร้อมเปิด/ปิดแยกเลเยอร์และปรับ Quality Preset (`Low`/`Medium`/`High`) ได้จริง และเห็น `ParticleEmitter`, `Trail`, `Beam` ครบถ้วนบน Sandbox Stage
5. สามารถรัน Stress Test 1 / 10 / 25 / 50 ตัวละคร และรัน Cleanup/Leak Test เพื่อยืนยันว่าไม่มี Instance ค้างหลังล้างฉาก


---

## 8. รายละเอียดเพิ่มเติมที่จำเป็นก่อนลงมือ

1. **Bootstrap/Rojo:** source ยังไม่มี client entrypoint ให้ระบุ AnimationLabBootstrap.client.luau ใต้ src/DevTools/AnimationLab/ และ server entrypoint แยก; ผัง service mapping ต้องผ่าน D-02 ก่อนเพิ่ม default.project.json ห้าม LocalScript require ServerScriptService.Track2 โดยตรง
2. **Studio boundary:** ทั้ง server/UI ตรวจ IsStudio ก่อน allocate; server ตรวจซ้ำทุก command, allowlist asset/state/quality และ session ownership; bounded stress 1/10/25/50, speed 0.1–2, intensity 0.1–2, scale 0.5–2.5 ปฏิเสธ NaN/Inf/ข้อมูลนอกชุด
3. **No cross-track require:** ช่องทางเรียก actual runtime ต้องออกแบบผ่าน shared contract ตาม D-02 ไม่ได้อนุมัติให้ DevTools/VisualBridge ยกเว้นกฎเอง
4. **Sessions:** sandbox ใช้ Workspace.__AnimationLabSandbox/<session> แยกผู้ใช้; คุม destroy scope ห้ามล้างโมเดลจริงหรือ session คนอื่น; ตรวจ streaming/distance ของ stage Y=5000 ใน Studio ก่อนเลือกตำแหน่ง
5. **Camera/input:** เก็บ CameraType/CameraSubject/CFrame/FieldOfView, cursor/input และ local PostFX ก่อนเปิด; restore เมื่อ Close, Reset, respawn, error และ PlayerRemoving; ไม่ขยับ Lighting ส่วนกลางของเกม
6. **Status:** แยก template inspection, rigged clone runtime, signature module validity และ manual visual ออกจากกัน; map assets ใช้ STATIC/N/A rig ไม่ใช่ broken เพราะไม่มี Motor6D; module loaded ไม่เท่ากับ SIGNATURE_VERIFIED
7. **Timeline:** pose seek เป็น deterministic และไม่ replay cue ย้อนหลัง; Pause/seek คุม clock ของ visual เท่านั้น ไม่แก้ combat; hot reload ไม่เป็น acceptance ในรอบนี้เพราะ source ไม่กำหนด cache invalidation
8. **Integration:** dummy ใช้ชื่อ attribute เดียวตาม contract ที่ล็อก (ต้นทางใช้สองชื่อไม่ตรงกัน); ไม่ใส่ Workspace.Enemies และไม่ผูก reward listener ของ Track1; เปิดได้หลัง D-06 และต้องทดสอบ state snapshot แบบควบคุม เพราะ wave จริงยังเดินระหว่างเล่น
9. **Telemetry:** นับ BaseParts แยก total Instances; particle count เป็น estimate, active Tween/connection/task เป็น tracked subset; วัด created-cleaned เท่ากับ outstanding ไม่ใช่ proof ว่าไม่มี leak ถ้าไม่ได้ register ทั้งหมด
10. **Performance:** ชุดผสม Luffy/Zoro/Ace เท่าๆ กันเท่าที่หารได้ ทดสอบ warmup/steady/burst/cleanup โดยระบุ duration, Studio version, device/GPU, resolution, graphics/quality; เก็บ frame time percentile/peak แยก server/client ตามวิธีวัดที่ล็อก ห้ามสมมุติว่า 50 ตัวเป็นเกมปกติซึ่งมี cap 8
11. **Budget decision:** baseline แค่ 1 ตัวก็มี 122–139 parts จึงสูงกว่า total 50 ของตารางเดิมแล้ว ตัวเลขทุก scenario ต้องประเมินใหม่หลัง D-04 รวม semantic pivots และ VFX; ห้ามลด geometry หรือแก้ budget หลังทดสอบเพื่อรับรองย้อนหลัง
12. **Evidence:** แต่ละ action มีผลที่สังเกตได้จริง + limitation; visual record เป็นข้อความระบุผู้ตรวจ, build/ref, state, มุมมองและข้อสังเกตได้ ไม่บังคับ screenshot/video; ถ้าไม่มีผู้ตรวจให้ NOT VERIFIED

## 9. แหล่งยืนยันและ blueprint

- [Roblox Data model](https://create.roblox.com/docs/projects/data-model): server-only containers และ client containers
- [Script types and locations](https://create.roblox.com/docs/scripting/locations): execution context ต้องตรงตำแหน่ง script
- [Viewport frames](https://create.roblox.com/docs/ui/viewport-frames): แสงใน ViewportFrame มี property ควบคุมของตน
- [Master Pack](../../../../requirement/phase5/phase_5_master_plan_and_agent_pack.md) บรรทัด 2457–2667: Registry/Validator blueprint อ้างอิง ยังไม่ใช่ implementation ที่ผ่าน contract; ตัวอย่างตรวจ weld ด้วย Part1 เพียงด้านเดียวและ module presence ไม่เพียงพอยืนยัน rig readiness
