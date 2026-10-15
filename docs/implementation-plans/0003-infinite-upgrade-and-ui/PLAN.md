# PLAN-0003: ระบบการ์ดสุ่มอัปเกรดเด้งทุกเวฟ และ UI HUD วันพีซ (One Piece Wave Card Draft UI & Server)

- **สถานะ**: Ready for Implementation (Phase 2)
- **ขอบเขตงาน (Ownership)**: 
  1. `src/Track3_UpgradeServer/UpgradeServer.server.luau`
  2. `src/Track3_UISystem/UpgradeHUD.client.luau`
- **Git Branch / Worktree**: `feat/track3-ui` (`../wt-track3-ui` หรือ `../altd-wt3-ui`)
- **พอร์ต Rojo สำหรับทดสอบ**: `34873`
- **เอกสารอ้างอิง**: [`requirement/phase2/03_track3_infinite_upgrade_ui_and_integration_spec.md`](../../../requirement/phase2/03_track3_infinite_upgrade_ui_and_integration_spec.md)

## 1. วัตถุประสงค์และฟีเจอร์ (Phase 2: One Piece Roguelike Wave Card Draft)
1. **Server Authority Wave Card & Upgrade Handler (`UpgradeServer.server.luau`)**:
   - จัดการ RemoteEvent `UpgradeStatRequest` ใน `ReplicatedStorage`
   - ระบบ Fallback ตั้งค่าเริ่มต้นให้ผู้เล่น (`Cash = 300`, `Damage = 45`, `Range = 36`, `Cooldown = 0.95`, `Splash = 6`, `Crit = 15%`, `PendingCardDraws = 1`)
   - รองรับคำสั่งเลือกการ์ดพลัง One Piece:
     - `Card_ConquerorHaki`: Damage +45% (+25 Flat), Crit +8%
     - `Card_Gear5Nika`: Damage +85% (+50 Flat), Cooldown -15%
     - `Card_ObservationHaki`: Range +8 Studs, Crit +10%
     - `Card_GuraQuake`: Splash +5 Studs, Damage +30% (+15 Flat)
     - `Card_IfritOverdrive`: Cooldown -18%, Damage +20% (+10 Flat)
     - `Card_BountyJackpot`: Cash +(250 * Wave), Base HP +400
   - รองรับคำสั่ง `BuyExtraCardDraw`: ใช้ Bounty Cash ซื้อสิทธิ์สุ่มการ์ดเพิ่ม (ราคาเพิ่มขึ้น $150 * 1.25^totalPicked)
   - รองรับคำสั่ง `RerollCards`: หักเงิน $50 เพื่อสุ่มหน้าไพ่ 3 ใบใหม่
   - ตรวจสอบ `PendingCardDraws > 0` ก่อนประมวลผลการ์ด และหักสิทธิ์ -1 พร้อมบันทึก `CardsPickedTotal`

2. **Client ScreenGui (One Piece Wave Card HUD & Modal - `UpgradeHUD.client.luau`)**:
   - แถบด้านบน (`TopWaveBar`): แสดง `GRAND LINE WAVE X`, `ENEMIES: Y`, และหลอดเลือด `THOUSAND SUNNY BASE HP`
   - แผงด้านซ้าย (`CrewStatsPanel`): แสดงสเตตัสกลุ่มหมวกฟาง (`BOUNTY`, `CREW DPS`, `HAKI DMG`, `CRIT`, `RANGE`, `AoE`, `SPEED`, `CARDS`) พร้อมปุ่มกดซื้อสิทธิ์เปิดการ์ดเพิ่มพิเศษ
   - หน้าต่างโมดอลการ์ดสุ่ม 3 ใบ (`WaveCardDraftModal`):
     - เด้งขึ้นมากลางจออัตโนมัติเมื่อ `PendingCardDraws > 0`
     - สุ่มการ์ด 3 ใบไม่ซ้ำกันจากคลังการ์ด 6 แบบ พร้อมกรอบสีตามระดับความหายาก (LEGENDARY, MYTHICAL, EPIC, COMMON)
     - ปุ่ม `REROLL CARDS ($50 BOUNTY)` สำหรับสุ่มการ์ดใหม่

## 2. ขอบเขตที่ห้ามทำ (Out-of-Scope)
- ห้ามแก้ไขไฟล์ในโฟลเดอร์ของ Track 1 (`src/Track1_WaveSystem/`) และ Track 2 (`src/Track2_TowerSystem/`)
- สื่อสารข้าม Track ผ่าน Data Contract กลาง (`src/Shared/GameConfig.luau`), Player Attributes และ Workspace Attributes เท่านั้น

## 3. เกณฑ์การตรวจรับ (Acceptance Criteria)
- [ ] เมื่อเริ่มเกม เวฟ 1 หน้าต่างการ์ดสุ่ม 3 ใบเด้งขึ้นมาตรงกลางจอทันที (`PendingCardDraws = 1`)
- [ ] เมื่อกดเลือกการ์ด หน้าต่างปิดลง และสเตตัสในแผงด้านซ้ายเพิ่มขึ้นตรงตามเอฟเฟกต์ของการ์ด
- [ ] ปุ่ม Reroll หักเงิน $50 และเปลี่ยนหน้าไพ่ทั้ง 3 ใบใหม่
- [ ] ปุ่ม Buy Extra Card หักเงินตามสูตรและเพิ่ม `PendingCardDraws` ให้เปิดการ์ดเพิ่มได้
- [ ] ตรวจสอบ Code Isolation: มีการแก้ไขเฉพาะ Track 3 เท่านั้น ไม่กระทบส่วนอื่น
