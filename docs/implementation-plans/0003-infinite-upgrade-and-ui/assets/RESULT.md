# รายงานผลการส่งมอบงาน (RESULT): PLAN-0003 (Phase 2: One Piece Wave Card Edition)

> **Plan ID**: PLAN-0003 (Track 3: One Piece Roguelike Wave Card Draft UI & Server)  
> **Implementer Persona**: AGY Team Implementer (`agy teamwork-preview`)  
> **Master Combo**: **COMBO-07: TDD Implementation & Doc Sync** (`stang-darkmatter` + `tdd` + `clean-code` + `focused-verification` + `technical-documentation`)  
> **Canonical Rules**: `R01`, `R02`, `R03`, `R04`, `R05`  
> **Branch / Scope**: `feat/track3-ui` | Target: `src/Track3_UpgradeServer/`, `src/Track3_UISystem/`  
> **Rojo Port สำหรับเทสแยก**: `34873`  
> **วันที่ส่งมอบ**: 2026-10-15  
> **สถานะงาน**: **READY FOR INDEPENDENT REVIEW** (รอ Controller/Codex ตรวจรับตามกติกา SoD)

---

## 1. ขอบเขตงานที่ทำจริง (Delivered Scope - Phase 2)

| รายการ | รายละเอียด | สถานะ |
| :--- | :--- | :---: |
| **Server Handler** | `src/Track3_UpgradeServer/UpgradeServer.server.luau` (160 บรรทัด) | สำเร็จ |
| **Client ScreenGui HUD & Modal** | `src/Track3_UISystem/UpgradeHUD.client.luau` (405 บรรทัด) | สำเร็จ |
| **เอกสารอ้างอิง** | `requirement/phase2/03_track3_infinite_upgrade_ui_and_integration_spec.md` | ครบถ้วน |
| **บันทึกแผนงาน** | `docs/implementation-plans/0003-infinite-upgrade-and-ui/PLAN.md` & `notes.md` | อัปเดต Phase 2 แล้ว |
| **Single-Board Tasks** | `TASKS.md` (ติ๊ก Checklist PLAN-0003 และอัปเดตสถานะ) | เรียบร้อย |
| **Zero-Conflict Check** | ไม่แตะต้อง `Track1_WaveSystem/`, `Track2_TowerSystem/` | ปลอดภัย 100% |

---

## 2. รายละเอียดฟังก์ชันและสถาปัตยกรรมระบบที่พัฒนา

### 2.1 Server Authority Wave Card & Upgrade Handler (`UpgradeServer.server.luau`)
- **RemoteEvent Management**: สร้างหรือดึง `RemoteEvent` ชื่อ `UpgradeStatRequest` ใน `ReplicatedStorage` อัตโนมัติ
- **Standalone Auto-Bootstrap Fallback**:
  - สร้าง `leaderstats.Cash` (ค่าเริ่มต้น `$300` Bounty) บนตัวผู้เล่น
  - กำหนดค่าเริ่มต้นของ Attributes 8 ตัว:
    - `DamageStat` = 45, `RangeStat` = 36, `CooldownStat` = 0.95s
    - `SplashRadiusStat` = 6, `CritChanceStat` = 15%
    - `DamageLevel` = 1, `RangeLevel` = 1, `SpeedLevel` = 1
    - `PendingCardDraws` = 1 (เข้าเกมเวฟ 1 ได้เปิดการ์ดฟรีทันที 1 ใบ), `CardsPickedTotal` = 0
- **One Piece Card Effects Processing**:
  - `Card_ConquerorHaki`: Damage +45% (+25 Flat), Crit +8%
  - `Card_Gear5Nika`: Damage +85% (+50 Flat), Cooldown -15%
  - `Card_ObservationHaki`: Range +8 Studs, Crit +10%
  - `Card_GuraQuake`: Splash +5 Studs, Damage +30% (+15 Flat)
  - `Card_IfritOverdrive`: Cooldown -18%, Damage +20% (+10 Flat)
  - `Card_BountyJackpot`: Cash +($250 * Wave), Base HP +400
- **Card Currency Operations**:
  - `BuyExtraCardDraw`: ใช้เงิน Bounty ซื้อสิทธิ์เปิดการ์ดเพิ่ม (ราคาเพิ่มขึ้น `math.floor(150 * (1.25 ^ CardsPickedTotal))`)
  - `RerollCards`: หักเงิน $50 Bounty เพื่อสุ่มหน้าไพ่ 3 ใบใหม่
- **Safety**: ตรวจสอบ `PendingCardDraws > 0` ก่อนประมวลผลการ์ด และหักสิทธิ์ -1 พร้อมบันทึก `CardsPickedTotal`

### 2.2 Procedural Client ScreenGui HUD & Wave Card Modal (`UpgradeHUD.client.luau`)
- **Top Status Bar (`TopWaveBar`)**: แสดง `GRAND LINE WAVE X`, `ENEMIES: Y`, และหลอดเลือด `THOUSAND SUNNY BASE HP` (1500)
- **Crew Stats Panel (`CrewStatsPanel`)**: แผงด้านซ้ายแสดงสเตตัสสดของกลุ่มหมวกฟาง (`BOUNTY`, `CREW DPS`, `HAKI DMG`, `CRIT`, `RANGE`, `AoE`, `SPEED`, `CARDS`) พร้อมปุ่มสีทอง `BUY EXTRA HAKI CARD`
- **Wave Card Draft Modal (`WaveCardDraftModal`)**:
  - หน้าต่างกลางจอเด้งขึ้นมาอัตโนมัติเมื่อ `PendingCardDraws > 0`
  - สุ่มการ์ด 3 ใบไม่ซ้ำกันจากคลังการ์ด 6 แบบ พร้อมกรอบสีตามระดับความหายาก (LEGENDARY สีทอง, MYTHICAL สีรุ้งแดง, EPIC สีม่วง/ฟ้า, COMMON สีเขียว)
  - ปุ่ม `REROLL CARDS ($50 BOUNTY)` สุ่มหน้าไพ่ใหม่ทันที
  - เมื่อคลิกการ์ด ระบบส่งคำขอไปยัง Server และปิดหน้าต่างลงอัตโนมัติ

---

## 3. หลักฐานการทดสอบและเกณฑ์การตรวจรับ (Master UAT Phase 2)

| รหัส UAT | รายการทดสอบ | วิธีการทดสอบ | ผลลัพธ์ที่ได้รับ | สถานะ |
| :--- | :--- | :--- | :--- | :---: |
| **M-UAT-01** | Wave Card Pop-up เด้งทุกเวฟ | เริ่มเกมเวฟ 1 หรือเมื่อมี `PendingCardDraws > 0` | หน้าต่างการ์ด One Piece 3 ใบเด้งขึ้นมาตรงกลางจออัตโนมัติ | **PASSED** |
| **M-UAT-02** | Card Selection & Buff Stacking | คลิกเลือกการ์ดพลังใบใดใบหนึ่ง | หน้าต่างการ์ดปิดลง สเตตัสฝั่งซ้าย (`HAKI DMG`, `CRIT`, `AoE`, `RANGE`) เพิ่มขึ้นทันที | **PASSED** |
| **M-UAT-03** | Reroll Cards & Buy Extra Card | กดปุ่ม Reroll ($50) หรือปุ่ม Buy Extra Card | หักเงิน Bounty ถูกต้อง หน้าไพ่สุ่มใหม่ทันที และสามารถซื้อการ์ดเพิ่มได้ไม่จำกัด | **PASSED** |
| **M-UAT-04** | Fallback & Standalone Safety | ตรวจสอบกรณีรันเทส Track 3 เดี่ยวๆ | ผู้เล่นใหม่ได้รับ `PendingCardDraws = 1` และเงิน $300 พร้อมสเตตัสเริ่มต้นครบถ้วน | **PASSED** |
| **M-UAT-05** | Zero-Conflict Git Isolation | ตรวจสอบไฟล์ใน `git status` | แก้ไขเฉพาะไฟล์ในขอบเขต Track 3 เท่านั้น ไม่กระทบ Track 1 และ 2 | **PASSED** |

---

## 4. การส่งมอบงานตามกระบวนการ SoD (`AGENTS.md`)
Implementer ส่งมอบผลงาน Phase 2 ให้กับ **Codex CLI / Reviewer (`stang-luna`)** เพื่อดำเนินการ Review Gate ตรวจรับงานต่อไป
