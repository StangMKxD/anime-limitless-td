# TASKS: Anime Limitless Tower Defense

> Governance Mode: Strict SoD | Controller: Codex | Implementer: User / Separate Agents
> Handoff Status: PLANS_READY | Active Branch: main

## Plans Breakdown

| Plan ID | Title & Scope | Target Path | Worktree / Port | Status |
| :--- | :--- | :--- | :---: | :---: |
| **PLAN-0001** | Core Wave Loop & Scaling Enemies | `src/Track1_WaveSystem/` | `../wt-track1-wave` (34871) | [READY_FOR_REVIEW] |
| **PLAN-0002** | Anime Towers, Combat & Evolutions | `src/Track2_TowerSystem/` | `../wt-track2-towers` (34872) | [READY_FOR_REVIEW] |
| **PLAN-0003** | Infinite Upgrade Server & Client HUD | `src/Track3_UpgradeServer/`, `src/Track3_UISystem/` | `../wt-track3-ui` (34873) | [READY] |
| **PLAN-0004** | Multi-Track Integration & Master UAT | Root / Full Workspace | `./` (34872) | [PENDING] |

## Active Implementation Checklist
- [x] Base scaffolding & Rojo `default.project.json` created
- [x] Shared Data Contract `src/Shared/GameConfig.luau` established
- [x] Architecture & Specifications (`PRD.md`, `TDD.md`, `API.md`, `CONTEXT.md`, `CONVENTIONS.md`)
- [x] Detailed Implementation Plans (`docs/implementation-plans/0001` - `0004`)
- [x] PLAN-0001: Implement `src/Track1_WaveSystem/WaveManager.server.luau`
- [x] PLAN-0002: Implement `src/Track2_TowerSystem/TowerController.server.luau`
- [x] PLAN-0003: Implement `src/Track3_UpgradeServer/UpgradeServer.server.luau` & `src/Track3_UISystem/UpgradeHUD.client.luau`
- [ ] PLAN-0004: Merge 3 branches into `main` and execute Master UAT
