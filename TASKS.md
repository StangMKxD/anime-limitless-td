# TASKS: Anime Limitless Tower Defense

> Governance Mode: Strict SoD | Controller: Codex | Implementer: User / Separate Agents
> Handoff Status: IN_PROGRESS | Active Branch: phase5/implementer-took-dev
> Phase5: IN_PROGRESS (M3 Complete) | Active Branch: phase5/implementer-took-dev | Codex final review only | AGY commit+push per milestone M0..M5

## Plans Breakdown

| Plan ID | Title & Scope | Target Path | Worktree / Port | Status |
| :--- | :--- | :--- | :--- | :--- |
| **PLAN-0001** | Core Wave Loop & Scaling Enemies | `src/Track1_WaveSystem/` | `../wt-track1-wave` (34871) | [READY_FOR_REVIEW] |
| **PLAN-0002** | Anime Towers, Combat & Evolutions | `src/Track2_TowerSystem/` | `../wt-track2-towers` (34872) | [READY_FOR_REVIEW] |
| **PLAN-0003** | Infinite Upgrade Server & Client HUD | `src/Track3_UpgradeServer/`, `src/Track3_UISystem/` | `../wt-track3-ui` (34873) | [READY_FOR_REVIEW] |
| **PLAN-0004** | Multi-Track Integration & Master UAT | Root / Full Workspace | `./` (34872) | [PENDING] |
| **PLAN-0005** | Character Model, Signature Animation, VFX & Animation Lab | [PLAN + รายละเอียดงาน](docs/implementation-plans/0005-character-model-animation/PLAN.md) | `./` (Phase 5) | [IN_PROGRESS: M3 READY_FOR_REVIEW] |

## Phase 5 Milestones (PLAN-0005)

| Milestone | Scope | Description | Status |
| :--- | :--- | :--- | :---: |
| **M0** | `P5-00`..`P5-06` | Contracts, Baseline Audit & Test Runner | [READY_FOR_REVIEW] |
| **M1** | `P5-07`..`P5-17` | Core Runtime Engine & Animation Lab UI | [READY_FOR_REVIEW] |
| **M2** | `L-01`..`L-04` | Luffy Gear 5 Refinement, Anim, VFX | [READY_FOR_REVIEW] |
| **M3** | `Z-01`..`Z-04` | Zoro King of Hell Refinement, Anim, VFX | [READY_FOR_REVIEW] |
| **M4** | `A-01`..`A-04` | Ace Flame Emperor Refinement, Anim, VFX | [PLANNED] |
| **M5** | `P5-20`..`P5-23` | Integration, Stress Suite, Doc Sync | [PLANNED] |

## Active Implementation Checklist
- [x] Base scaffolding & Rojo `default.project.json` created
- [x] Shared Data Contract `src/Shared/GameConfig.luau` established
- [x] Architecture & Specifications (`PRD.md`, `TDD.md`, `API.md`, `CONTEXT.md`, `CONVENTIONS.md`)
- [x] Detailed Implementation Plans (`docs/implementation-plans/0001` - `0004`)
- [x] PLAN-0001: Implement `src/Track1_WaveSystem/WaveManager.server.luau`
- [x] PLAN-0002: Implement `src/Track2_TowerSystem/TowerController.server.luau`
- [x] PLAN-0003: Implement `src/Track3_UpgradeServer/UpgradeServer.server.luau` & `src/Track3_UISystem/UpgradeHUD.client.luau`
- [ ] PLAN-0004: Merge 3 branches into `main` and execute Master UAT
- [x] PLAN-0005 M0: Contracts, Baseline Audit & Test Runner (P5-00..P5-06) [READY_FOR_REVIEW]
- [x] PLAN-0005 M1: Core Runtime Engine & Animation Lab UI (P5-07..P5-17) [READY_FOR_REVIEW]
- [x] PLAN-0005 M2: Luffy Gear 5 Refinement, Anim, VFX (L-01..L-04) [READY_FOR_REVIEW]
- [x] PLAN-0005 M3: Zoro King of Hell Refinement, Anim, VFX (Z-01..Z-04) [READY_FOR_REVIEW]
- [ ] PLAN-0005 M4..M5: Signatures & Integration (A-01..P5-23)

## Phase5 execution handoff
- Authority: คำสั่งผู้ใช้ 2026-10-17 (Asia/Bangkok): “ขอ prompt ให้ agy ทำงานให้เสร็จทุกแผนเลย แล้วนายรอ รีวิวทีเดียว”
- Contract: [PLAN-0005 HANDOFF](docs/implementation-plans/0005-character-model-animation/assets/HANDOFF.md); source base d5d0621; AGY บันทึก execution HEAD หลัง commit เอกสารก่อนเริ่ม
- Streams: Core/Lab -> Luffy/Zoro/Ace -> Integration/UAT ตาม dependencies; 34 tasks ใน tasks.md; ยังไม่มี session รับงาน
- Verification: G-01..13 NOT VERIFIED; AGY internal gates แล้ว Codex ตรวจรวมตอนท้าย; missing evidence/budget ไม่ใช่ผ่าน
- Scope/doc sync: ตาม HANDOFF Decision handling/D-07; protected paths คงเดิม; ไม่มีสิทธิ์ปิดงานเอง
- User dirty state to protect: .vscode/; ห้าม reset unrelated work; ส่ง working-tree diff และ actual ref

- Milestone Git authorization: ผู้ใช้ 2026-10-17 อนุญาต AGY commit + push origin/main ทุก M0..M5 ตาม HANDOFF; ไม่เท่ากับ review approval; final review ที่ final SHA
