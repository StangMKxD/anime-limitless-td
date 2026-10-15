# E2E Test Infra: Anime Limitless Tower Defense — Phase 3

## Test Philosophy
- Opaque-box, requirement-driven headless testing without requiring `rojo serve` or Roblox Studio rendering.
- Methodology: Category-Partition + Boundary Value Analysis + Pairwise Combinatorial Testing + Full-Match Workload Simulation.
- Runner: Node.js headless assertion test suite (`.agents/teamwork/spec_miner_test_matrix/runners/run_e2e_matrix.mjs` and `tests/run_all_tests.mjs`).

## Feature Inventory & Test Coverage
| # | Feature | Source | Tier 1 | Tier 2 | Tier 3 | Tier 4 |
|---|---------|--------|:------:|:------:|:------:|:------:|
| 1 | Zero Initial Tower State | Spec §1, §3.1 | ✓ | ✓ | ✓ | ✓ |
| 2 | Starter Resources & Attributes | GameConfig / UpgradeServer | ✓ | ✓ | ✓ | ✓ |
| 3 | Wave 1 Preparation Window | WaveManager | ✓ | ✓ | ✓ | ✓ |
| 4 | Wave Zombie Scaling & Spawning | WaveManager | ✓ | ✓ | ✓ | ✓ |
| 5 | Bounty Multiplier Scaling | WaveManager | ✓ | ✓ | ✓ | ✓ |
| 6 | Hero Summoning Engine | TowerController | ✓ | ✓ | ✓ | ✓ |
| 7 | Hero Reroll Engine | TowerController | ✓ | ✓ | ✓ | ✓ |
| 8 | 8 Tactical Placement Pads | TowerController | ✓ | ✓ | ✓ | ✓ |
| 9 | Deploy Tower on Empty Pad | TowerController | ✓ | ✓ | ✓ | ✓ |
| 10 | Tower Swap on Occupied Pad | TowerController | ✓ | ✓ | ✓ | ✓ |
| 11 | Recall Tower to Bag | TowerController | ✓ | ✓ | ✓ | ✓ |
| 12 | Sell Tower from Map Slot | TowerController | ✓ | ✓ | ✓ | ✓ |
| 13 | Sell Tower from Bag | TowerController | ✓ | ✓ | ✓ | ✓ |
| 14 | Procedural R6 One Piece Models | TowerController | ✓ | ✓ | ✓ | ✓ |
| 15 | Continuous Idle Bobbing & Aura Spin | TowerController | ✓ | ✓ | ✓ | ✓ |
| 16 | Nearest Enemy Auto-Targeting | TowerController | ✓ | ✓ | ✓ | ✓ |
| 17 | 3D Manga Onomatopoeia Billboard | TowerController | ✓ | ✓ | ✓ | ✓ |
| 18 | Conqueror's Haki Lightning Bolts | TowerController | ✓ | ✓ | ✓ | ✓ |
| 19 | 8 Hero Signature Ultimates | TowerController | ✓ | ✓ | ✓ | ✓ |
| 20 | Client Camera Shake & Impact Flash | UpgradeHUD | ✓ | ✓ | ✓ | ✓ |
| 21 | Whitebeard Gura Quake Slow | WaveManager / TowerController | ✓ | ✓ | ✓ | ✓ |
| 22 | Combat Scaling: AoE Splash & Crits | TowerController | ✓ | ✓ | ✓ | ✓ |
| 23 | Infinite Cash Stat Upgrades | UpgradeServer | ✓ | ✓ | ✓ | ✓ |
| 24 | 12 Roguelike Wave Cards Pool | UpgradeServer / GameConfig | ✓ | ✓ | ✓ | ✓ |
| 25 | Top Banner Status & Stats HUD | UpgradeHUD | ✓ | ✓ | ✓ | ✓ |
| 26 | Central Summon & Reroll Modal | UpgradeHUD | ✓ | ✓ | ✓ | ✓ |
| 27 | Bottom Bag & 8-Slot Manager | UpgradeHUD | ✓ | ✓ | ✓ | ✓ |
| 28 | 3-Card Wave Draft Modal | UpgradeHUD | ✓ | ✓ | ✓ | ✓ |

## Test Architecture
- Test runner: Headless Node.js runner executing static, structural, semantic, and mathematical simulation assertions against Luau AST and simulated state.
- Test suites:
  - Tier 1: Feature Coverage (26 tests)
  - Tier 2: Boundary & Corner Cases (10 tests)
  - Tier 3: Cross-Feature Combinations (7 tests)
  - Tier 4: Real-World Workload Simulation (1 full 15-wave match)
  - Total: 44 test cases
- Pass / Fail Semantics: Process exit code 0 on all tests passing; nonzero on failure.

## Coverage Thresholds
- Tier 1: ≥5 per feature category (26 cases)
- Tier 2: Boundary conditions, pity rollover, inventory caps, cooldown clamp 0.15s, crit clamp 0.95 (10 cases)
- Tier 3: Cross-feature combinations (7 cases)
- Tier 4: Real-world match through Wave 15 with Yonko Kaido bosses (1 full match)
- Total: 44 test cases
