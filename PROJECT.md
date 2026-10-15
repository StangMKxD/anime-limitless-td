# Project: Anime Limitless Tower Defense — Phase 3 (Grand Line Wanted Gacha, Tactical Pads, R6 VFX & Roguelike Cards)

## Architecture
Anime Limitless Tower Defense operates on a strict Modular Zero-Conflict architecture across three decoupled tracks and a shared data contract:
```
                                 [ Shared / GameConfig ]
                           (Constants, Catalog, Remotes, Slots)
                                    /       |        \
                                   /        |         \
                                  v         v          v
   [ Track 1: WaveSystem ]     [ Track 2: TowerSystem ]     [ Track 3: Upgrade & UI ]
   - 15s Prep Countdown       - 8 Tactical Placement Pads   - Player Stats Bootstrap
   - Workspace.Enemies Spawner - Gacha Summon & Reroll       - Cash Stat Upgrades
   - Attribute "HP" & Waypoints- Bag & Atomic Swap Logic     - 12-Card Wave Draft Server
   - Bounty Multiplier Scaling - Procedural R6 Hero Models   - Top Banner HUD
   - Base HP & Game Over       - 8 One Piece Ultimates & VFX - Wanted Poster Gacha Modal
                               - Billboard Manga SFX & Shake - Bottom Bag & Slot Manager
                                                             - 3-Card Selection Modal
```
Shared state is mediated exclusively through:
1. `ReplicatedStorage.Shared.GameConfig`
2. Workspace Attributes (`WaveStatus`, `CurrentWave`, `BaseHP`, `MaxBaseHP`, `GameOver`, `PrepCountdown`)
3. Player Attributes (`Cash`, `DamageStat`, `RangeStat`, `CooldownStat`, `CritChanceStat`, `CritDamageStat`, `SplashRadiusStat`, `BountyMultiplierStat`, `HeroInventoryJson`, `FreeSummonTickets`, `RerollTokens`, `MaxPlacedTowersStat`, etc.)
4. ReplicatedStorage RemoteEvents:
   - `UpgradeStatRequest` (RemoteFunction)
   - `TowerSummonRerollRequest` (RemoteEvent)
   - `TowerPlacementActionRequest` (RemoteEvent)
   - `CardDraftSelectRequest` (RemoteEvent)
   - `VFXCameraShakeEvent` (RemoteEvent)

## Feature Inventory
| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Zero Initial Tower State | Map starts with 0 towers in Workspace.AnimeTowers | M1, M3 | Spec §1, §3.1 |
| 2 | Starter Resources & Attributes | 1 Free Ticket, 3 Rerolls, $500 Cash, 4 Max Towers, empty bag | M1, M4 | GameConfig / UpgradeServer |
| 3 | Wave 1 Preparation Window | 15s countdown before Wave 1; auto-starts early if tower deployed | M2 | WaveManager |
| 4 | Wave Zombie Scaling & Spawning | Scaling count, 1.18^(w-1) HP scaling, Kaido boss every 5 waves | M2 | WaveManager |
| 5 | Bounty Multiplier Scaling | Kill & wave cash multiplied by BountyMultiplierStat | M2 | WaveManager |
| 6 | Hero Summoning Engine | 8 heroes weighted gacha; uses Free Ticket then $100 Cash | M1, M3, M5 | TowerController / UpgradeHUD |
| 7 | Hero Reroll Engine | Rerolls latest unit in bag; uses 1 Token then $80 Cash | M1, M3, M5 | TowerController / UpgradeHUD |
| 8 | 8 Tactical Placement Pads | Physical neon pads with ClickDetector & BillboardGui | M1, M3 | TowerController |
| 9 | Deploy Tower on Empty Pad | Deploys unit from bag onto empty pad; spawns R6 model | M3, M5 | TowerController / UpgradeHUD |
| 10 | Tower Swap on Occupied Pad | Placing on occupied pad swaps units; existing unit returns to bag | M3, M5 | TowerController / UpgradeHUD |
| 11 | Recall Tower to Bag | Recalls tower from pad back to player bag; vacates pad | M3, M5 | TowerController / UpgradeHUD |
| 12 | Sell Tower from Map Slot | Sells placed tower for cash; +1 RerollToken bonus if Mythical | M3, M5 | TowerController / UpgradeHUD |
| 13 | Sell Tower from Bag | Sells unplaced unit from bag; +1 RerollToken bonus if Mythical | M3, M5 | TowerController / UpgradeHUD |
| 14 | Procedural R6 One Piece Models | R6 rig with custom head, neon arm, aura ring, signature weapon | M3 | TowerController |
| 15 | Continuous Idle Bobbing & Aura Spin | Sine wave bobbing (3.2 freq, 0.35 amp) and 2.5 deg aura ring spin | M3 | TowerController |
| 16 | Nearest Enemy Auto-Targeting | Scans Workspace.Enemies within range, targets closest enemy | M3 | TowerController |
| 17 | 3D Manga Onomatopoeia Billboard | Upward floating 3D text billboards (DOOM!!, KAMUSARI!!, etc.) | M3 | TowerController |
| 18 | Conqueror's Haki Lightning Bolts | Radial expanding jagged neon lightning parts | M3 | TowerController |
| 19 | 8 Hero Signature Ultimates | BajrangFist, Kamusari, GuraQuake, KingOfHell360, Entei, etc. | M3 | TowerController |
| 20 | Client Camera Shake & Impact Flash | Remote broadcast causing camera CFrame jitter and screen flash | M3, M5 | TowerController / UpgradeHUD |
| 21 | Whitebeard Gura Quake Slow | 2.5s slow debuff multiplying enemy move speed by 0.45x | M2, M3 | TowerController / WaveManager |
| 22 | Combat Scaling: AoE Splash & Crits | Deals damage in splash radius; crit roll multiplies damage | M3 | TowerController |
| 23 | Infinite Cash Stat Upgrades | Exponential cost upgrades for Damage, Range, Speed (min 0.15s) | M4, M5 | UpgradeServer / UpgradeHUD |
| 24 | 12 Roguelike Wave Cards Pool | 12 distinct cards modifying team stats, slots, cash, heal | M1, M4, M5 | GameConfig / UpgradeServer |
| 25 | Top Banner Status & Stats HUD | Wave status, Base HP bar, crew stat counters | M5 | UpgradeHUD |
| 26 | Central Summon & Reroll Modal | Wanted poster style central modal with rolled hero display | M5 | UpgradeHUD |
| 27 | Bottom Bag & 8-Slot Manager | Interactive inventory tray and 8 slot buttons (Place/Swap/Store/Sell)| M5 | UpgradeHUD |
| 28 | 3-Card Wave Draft Modal | Modal offering 3 random distinct cards when PendingCardDraws > 0 | M5 | UpgradeHUD |

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Shared Data Contract & Configuration | `src/Shared/GameConfig.luau` (Constants, Remotes, Attributes, Slots, 8 Heroes, 12 Cards) | none | DONE |
| M2 | Track 1 Wave System & Health Contract | `src/Track1_WaveSystem/WaveManager.server.luau` (15s Prep, Workspace.Enemies, "HP" attribute, BountyMult, Waypoint Slow) | M1 | DONE |
| M3 | Track 2 Tower System & Anime VFX | `src/Track2_TowerSystem/TowerController.server.luau` (8 Pads, Gacha, Bag/Swap/Sell, R6 Models, 8 Ultimates, Manga SFX, Shake) | M1 | DONE |
| M4 | Track 3 Upgrade Server & Card Draft | `src/Track3_UpgradeServer/UpgradeServer.server.luau` (Bootstrap Stats, Cash Upgrades, 12 Cards Draft Resolver) | M1 | DONE |
| M5 | Track 3 Client UI System & Camera Shake | `src/Track3_UISystem/UpgradeHUD.client.luau` (Top Banner, Gacha Modal, Bag/Slot HUD, 3-Card Modal, Shake Listener) | M1, M2, M3, M4 | DONE |
| M6 | Final E2E Integration & Coverage Hardening | Run 100% E2E test suite (Tiers 1-4) + Phase 2 Adversarial Coverage Hardening (Tier 5) | M1, M2, M3, M4, M5 | DONE |

## Interface Contracts
### GameConfig ↔ Track 1 (WaveManager)
- Folder: `GameConfig.FOLDERS.ENEMIES = "Enemies"`
- Attribute: `enemy:SetAttribute("HP", maxHP)`
- Attribute: `enemy:SetAttribute("SlowUntil", 0)`
- Bounty: `cashEarned = math.floor(baseCash * player:GetAttribute("BountyMultiplierStat"))`
- Prep: `workspace:SetAttribute("PrepCountdown", seconds)`
- Base HP: `workspace:SetAttribute("BaseHP", hp)`, `workspace:SetAttribute("MaxBaseHP", maxHp)`

### GameConfig ↔ Track 2 (TowerController)
- Slots: `GameConfig.PLACEMENT_SLOTS` (8 entries: Vector3 coords, SlotId)
- Heroes: `GameConfig.HERO_CATALOG` (8 heroes: Id, Name, Rarity, Weight, Multipliers, Colors, AttackStyle, SellValue)
- Remotes: `TowerSummonRerollRequest`, `TowerPlacementActionRequest`, `VFXCameraShakeEvent`
- Attributes: `HeroInventoryJson`, `FreeSummonTickets`, `RerollTokens`, `MaxPlacedTowersStat`, `LastRolledHeroId`, `LastRolledUnitUid`
- Targeting: Reads `Workspace.Enemies`, damages `enemy:SetAttribute("HP", math.max(0, curHP - finalDmg))`

### GameConfig ↔ Track 3 (UpgradeServer & UpgradeHUD)
- Cards: `GameConfig.CARD_POOL` (12 distinct cards with exact modifier keys)
- Remotes: `UpgradeStatRequest`, `CardDraftSelectRequest`
- Stats: `DamageStat`, `RangeStat`, `CooldownStat` (min 0.15s), `CritChanceStat` (max 0.95), `CritDamageStat`, `SplashRadiusStat`, `BountyMultiplierStat`

## Code Layout
```
src/
├── Shared/
│   └── GameConfig.luau                       [M1: Shared Data Contract — DONE]
├── Track1_WaveSystem/
│   └── WaveManager.server.luau               [M2: Wave Engine & Enemy Health — DONE]
├── Track2_TowerSystem/
│   └── TowerController.server.luau           [M3: Towers, Gacha, Pads, VFX — DONE (MASTERPIECE)]
├── Track3_UpgradeServer/
│   └── UpgradeServer.server.luau             [M4: Stat Upgrades & 12 Cards Server — DONE]
└── Track3_UISystem/
    └── UpgradeHUD.client.luau                [M5: Full Client HUD, Modals, Camera Shake — DONE]
```
All files strictly isolated with single-module ownership. No track modifies another track's files.
