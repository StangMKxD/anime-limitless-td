# TASKS: Anime Limitless Tower Defense

> Governance Mode: Strict SoD | Controller: Codex | Implementer: User / Separate Agents
> Handoff Status: READY_FOR_REVIEW | Active Branch: phase6/implementer-took-dev
> Phase6: READY_FOR_REVIEW (P01-P09 Complete) | Active Branch: phase6/implementer-took-dev | Codex single review handover

## Plans Breakdown

| Plan ID | Title & Scope | Target Path | Worktree / Port | Status |
| :--- | :--- | :--- | :--- | :--- |
| **PLAN-0001** | Core Wave Loop & Scaling Enemies | `src/Track1_WaveSystem/` | `../wt-track1-wave` (34871) | [READY_FOR_REVIEW] |
| **PLAN-0002** | Anime Towers, Combat & Evolutions | `src/Track2_TowerSystem/` | `../wt-track2-towers` (34872) | [READY_FOR_REVIEW] |
| **PLAN-0003** | Infinite Upgrade Server & Client HUD | `src/Track3_UpgradeServer/`, `src/Track3_UISystem/` | `../wt-track3-ui` (34873) | [READY_FOR_REVIEW] |
| **PLAN-0004** | Multi-Track Integration & Master UAT | Root / Full Workspace | `./` (34872) | [PENDING] |
| **PLAN-0005** | Character Model, Signature Animation, VFX & Animation Lab | [PLAN + รายละเอียดงาน](docs/implementation-plans/0005-character-model-animation/PLAN.md) | `./` (Phase 5) | [READY_FOR_REVIEW] |
| **PLAN-0006** | Neutral Presentation Runtime, Client Settings, & 4 Themed Maps | `src/Presentation/`, `src/Track1_WaveSystem/Maps/`, `src/Track3_UISystem/` | `./` (Phase 6) | [READY_FOR_REVIEW] |

## Phase 5 Milestones (PLAN-0005)

| Milestone | Scope | Description | Status |
| :--- | :--- | :--- | :---: |
| **M0** | `P5-00`..`P5-06` | Contracts, Baseline Audit & Test Runner | [READY_FOR_REVIEW] |
| **M1** | `P5-07`..`P5-17` | Core Runtime Engine & Animation Lab UI | [READY_FOR_REVIEW] |
| **M2** | `L-01`..`L-04` | Luffy Gear 5 Refinement, Anim, VFX | [READY_FOR_REVIEW] |
| **M3** | `Z-01`..`Z-04` | Zoro King of Hell Refinement, Anim, VFX | [READY_FOR_REVIEW] |
| **M4** | `A-01`..`A-04` | Ace Flame Emperor Refinement, Anim, VFX | [READY_FOR_REVIEW] |
| **M5** | `P5-20`..`P5-23` | Integration, Stress Suite, Doc Sync | [READY_FOR_REVIEW] |

## Phase 6 Sub-phases (PLAN-0006)

| Sub-phase | Scope | Description | Status |
| :--- | :--- | :--- | :---: |
| **P01-P03** | `PresentationContract`, `RigBinder`, `Playback` | Visual schemas, semantic rig binding, 5-phase motion curves | [READY_FOR_REVIEW] |
| **P04-P06** | `Preferences`, `Quality`, `VFX`, `Broadcaster` | Client prefs, quality caps, zero-leak VFX, decoupled broadcaster | [READY_FOR_REVIEW] |
| **P07-P09** | `Maps/`, `ClientSettings/`, `Phase6Spec` | 4 themed maps, vote flow, settings HUD, 52/52 tests & doc sync | [READY_FOR_REVIEW] |

## Active Implementation Checklist
- [x] Base scaffolding & Rojo `default.project.json` created
- [x] Shared Data Contract `src/Shared/GameConfig.luau` established
- [x] Architecture & Specifications (`PRD.md`, `TDD.md`, `API.md`, `CONTEXT.md`, `CONVENTIONS.md`)
- [x] Detailed Implementation Plans (`docs/implementation-plans/0001` - `0004`)
- [x] PLAN-0001: Implement `src/Track1_WaveSystem/WaveManager.server.luau`
- [x] PLAN-0002: Implement `src/Track2_TowerSystem/TowerController.server.luau`
- [x] PLAN-0003: Implement `src/Track3_UpgradeServer/UpgradeServer.server.luau` & `src/Track3_UISystem/UpgradeHUD.client.luau`
- [ ] PLAN-0004: Merge 3 branches into `main` and execute Master UAT
- [x] PLAN-0005 M0..M5: Character Model, Signature Animation, VFX & Animation Lab (34/34 Tasks) [READY_FOR_REVIEW]
- [x] PLAN-0006 P01..P03: PresentationContract, RigBinder, RigDiagnostics, MotionProfiles, Playback [READY_FOR_REVIEW]
- [x] PLAN-0006 P04..P06: PresentationPreferences, QualityPolicy, VFXDispatcher, Server Broadcaster [READY_FOR_REVIEW]
- [x] PLAN-0006 P07..P09: MapCatalog, MapBuilders, MapSelection, Client Views, 52/52 Tests & Doc Sync [READY_FOR_REVIEW]

## Phase 6 execution handoff
- Authority: คำสั่งผู้ใช้ 2026-10-17: "สร้าง branch ใหม่และทำ phase6 ให้เสร็จให้หมดและรอส่งรีวิวทีเดียว"
- Branch: `phase6/implementer-took-dev` off `main` (edc3f90)
- Scope: P01-P09 complete; 52/52 tests passed; 4 maps + neutral presentation runtime; ready for Codex review
