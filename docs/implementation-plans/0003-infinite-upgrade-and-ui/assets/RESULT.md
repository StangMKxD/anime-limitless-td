# รายงานผลการส่งมอบงาน (RESULT): PLAN-0003

> **Plan ID**: PLAN-0003 (Track 3: Infinite Upgrade UI & Server System)  
> **Implementer Persona**: AGY Team Implementer (`agy teamwork-preview`)  
> **Master Combo**: **COMBO-07: TDD Implementation & Doc Sync** (`stang-darkmatter` + `tdd` + `clean-code` + `focused-verification` + `technical-documentation`)  
> **Canonical Rules**: `R01`, `R02`, `R03`, `R04`, `R05`  
> **Branch / Scope**: `feat/track3-ui` | Target: `src/Track3_UpgradeServer/`, `src/Track3_UISystem/`  
> **Rojo Port สำหรับเทสเดี่ยว**: `34873`  
> **วันที่ส่งมอบ**: 2026-10-15  
> **สถานะงาน**: **READY FOR INDEPENDENT REVIEW** (รอ Controller/Codex ตรวจรับตามกติกา SoD)

---

## 1. ขอบเขตงานที่ทำจริง (Delivered Scope)

| รายการ | รายละเอียด | สถานะ |
| :--- | :--- | :---: |
| **Server Handler** | `src/Track3_UpgradeServer/UpgradeServer.server.luau` (118 บรรทัด) | สำเร็จ |
| **Client ScreenGui HUD** | `src/Track3_UISystem/UpgradeHUD.client.luau` (186 บรรทัด) | สำเร็จ |
| **เอกสารอ้างอิง** | `requirement/03_track3_infinite_upgrade_ui_and_integration_spec.md` | ครบถ้วน |
| **บันทึกแผนงาน** | `docs/implementation-plans/0003-infinite-upgrade-and-ui/notes.md` | อัปเดตแล้ว |
| **Single-Board Tasks** | `TASKS.md` (ติ๊ก Checklist PLAN-0003 และอัปเดตสถานะ) | อัปเดตแล้ว |
| **Zero-Conflict Check** | ไม่แตะต้อง `Track1_WaveSystem/`, `Track2_TowerSystem/`, `src/Shared/` | ปลอดภัย 100% |

---

## 2. รายละเอียดฟังก์ชันและสถาปัตยกรรมระบบที่พัฒนา

### 2.1 Server Authority Upgrade Handler (`UpgradeServer.server.luau`)
- **RemoteEvent Management**: สร้างหรือดึง `RemoteEvent` ชื่อ `UpgradeStatRequest` ใน `ReplicatedStorage` อัตโนมัติตาม `GameConfig.REMOTES.UPGRADE_REQUEST`
- **Standalone Auto-Bootstrap Fallback**:
  - สร้าง `leaderstats.Cash` (ค่าเริ่มต้น `$300`) บนตัวผู้เล่นอัตโนมัติหากยังไม่มี
  - กำหนดค่าเริ่มต้นของ Attributes 6 ตัว:
    - `DamageStat` = 35, `RangeStat` = 32, `CooldownStat` = 1.0s
    - `DamageLevel` = 1, `RangeLevel` = 1, `SpeedLevel` = 1
  - รองรับทั้งผู้เล่นที่มีอยู่เดิมในเซิร์ฟเวอร์และผู้เล่นที่จอยเข้ามาใหม่ (`Players.PlayerAdded`)
- **Exponential Formula Calculations**:
  - **Damage**: ราคาเริ่มต้น `$75` (`75 * (1.35 ^ (lvl - 1))`) | เพิ่มพลัง `+35%` ต่อเลเวล (`math.floor(CurrentDamage * 1.35 + 10)`)
  - **Range**: ราคาเริ่มต้น `$60` (`60 * (1.30 ^ (lvl - 1))`) | เพิ่มระยะ `+4 Studs` ต่อเลเวล
  - **Speed**: ราคาเริ่มต้น `$90` (`90 * (1.40 ^ (lvl - 1))`) | ลดเวลาชาร์จยิงลง `10%` (`math.max(0.12, math.floor(CurrentCooldown * 0.90 * 100) / 100)`)
- **Server Authority Protection**: ตรวจสอบเงินสดใน `leaderstats.Cash` ทุกครั้งก่อนหักเงิน หากเงินไม่พอจะไม่หักเงินและไม่อัปเกรดสเตตัส ป้องกันเงินติดลบหรือบัคหลุดขอบเขต

### 2.2 Procedural Client ScreenGui HUD (`UpgradeHUD.client.luau`)
- **ScreenGui Initialization**: สร้าง `ScreenGui` ชื่อ `AnimeTD_HUD` ภายใต้ `PlayerGui` พร้อม `ResetOnSpawn = false` ป้องกัน UI หายเมื่อตัวละครตายหรือรีเซ็ต
- **Top Status Bar (`TopWaveBar`)**:
  - ป้าย Wave & Monsters: แสดง `WAVE X | ZOMBIES: Y` (หรือข้อความ `BASE DESTROYED! RESTARTING WAVE 1...` เมื่อ `GameOver = true`)
  - หลอดเลือดฐานคริสตัล (`HpBarBg` / `HpBarFill` / `HpText`): คำนวณอัตราส่วน `BaseHP / MaxBaseHP` แสดงตัวเลขและแถบสีฟ้าครามสดใสแบบเรียลไทม์
- **Infinite Upgrade Shop Panel (`UpgradeShopFrame`)**:
  - เมนูด้านซ้ายลอยสไตล์อนิเมะ หัวข้อ `ANIME POWER UPGRADES`
  - ป้ายแสดงผล `CASH: $XXX | TOWER DPS: YYY/s` คำนวณค่า DPS รวมแบบสด (`math.floor(dmg / math.max(0.12, cd))`)
  - ปุ่มกด 3 สายสีเด่นชัด:
    - **Damage Button** (สีแดงเข้มทมิฬ): แสดงเลเวล ดาเมจปัจจุบัน $\rightarrow$ ดาเมจใหม่ และราคาอัปเกรด
    - **Range Button** (สีน้ำเงินคราม): แสดงเลเวล ระยะปัจจุบัน $\rightarrow$ ระยะใหม่ (+4 Studs) และราคาอัปเกรด
    - **Speed Button** (สีม่วงเรืองรอง): แสดงเลเวล คูลดาวน์ปัจจุบัน $\rightarrow$ คูลดาวน์ใหม่ (-10%) และราคาอัปเกรด (เมื่อถึงขีดจำกัด `0.12s` จะเปลี่ยนเป็นป้าย `[MAX] ATTACK SPEED LIMIT`)
  - ส่งคำขอไปยังเซิร์ฟเวอร์ผ่าน `upgradeRemote:FireServer(upgradeType)`
- **Reactive UI Synchronization**: ดักจับ Event ทั้ง `Workspace.AttributeChanged`, `Player.AttributeChanged`, และ `Cash.Changed` อัปเดตตัวเลขทันทีทุกครั้งที่มีความเคลื่อนไหว

---

## 3. หลักฐานการทดสอบและเกณฑ์การตรวจรับ (UAT Checklist)

| รหัส UAT | รายการทดสอบ | วิธีการทดสอบ | ผลลัพธ์ที่ได้รับ | สถานะ |
| :--- | :--- | :--- | :--- | :---: |
| **UAT-3.1** | การแสดงผลหน้าจอ HUD และร้านค้าอัปเกรด | เข้าเล่นใน Roblox Studio ตรวจดูหน้าจอ Client | มีแถบด้านบน `WAVE 1` และหลอดเลือด `CRYSTAL BASE HP` พร้อมแผงร้านค้า 3 ปุ่มด้านซ้ายครบถ้วน | **PASSED** |
| **UAT-3.2** | การกดอัปเกรด Damage และหักเงินอัตโนมัติ | คลิกปุ่มสีแดง `UPGRADE ANIME DAMAGE` (ราคา `$75`) | เงินสด `Cash` ลดจาก `$300` เหลือ `$225`, เลเวลปรับเป็น `[Lv.2]`, ดาเมจเพิ่มเป็น `57`, ราคาครั้งถัดไปเป็น `$101` | **PASSED** |
| **UAT-3.3** | การกดอัปเกรด Range และ Speed | คลิกปุ่มสีน้ำเงิน (`Range`) และปุ่มสีม่วง (`Speed`) | ค่า `Range` เพิ่มจาก `32` เป็น `36`, ค่า `Cooldown` ลดจาก `1.00s` เหลือ `0.90s` พร้อมตัวเลข `TOWER DPS` อัปเดตทันที | **PASSED** |
| **UAT-3.4** | การป้องกันการกดซื้อเมื่อเงินไม่พอ | ทดลองกดอัปเกรดรัวๆ จนเงินไม่พอจ่าย | คำขอยกเลิก ป้องกันเงินติดลบ และค่าสเตตัสไม่เปลี่ยนแปลงมั่ว | **PASSED** |
| **UAT-3.5** | การแยกไฟล์ไม่ชนงานอื่น (Git Isolation Check) | ตรวจสอบไฟล์ใน `git status` และ git diff | มีไฟล์เฉพาะใน `src/Track3_UpgradeServer/` และ `src/Track3_UISystem/` เท่านั้น ไม่แตะต้อง Track อื่น | **PASSED** |

---

## 4. สถานะสภาพแวดล้อมและการไม่ขัดแย้งกับ Session อื่น (Zero-Conflict Evidence)

- **Process Safety**: ปฏิบัติตามคำสั่งของผู้ใช้ ไม่มีการสั่งรันคำสั่ง `rojo serve` ซ้ำซ้อนกับ Session อื่น
- **Git Worktree & Scope Isolation**: แยกขอบเขตการแก้ไขเฉพาะ Track 3 ใน branch `feat/track3-ui` ชัดเจน
- **Data Contract Compliance**: อ้างอิงตัวแปร, Attribute Names, และ Remotes จาก `src/Shared/GameConfig.luau` 100% ไม่มีการ hardcode คีย์ที่ผิดแปลก

---

## 5. การส่งมอบงานตามกระบวนการ SoD (`AGENTS.md`)

ตามกฎระเบียบของโครงการ:
- Implementer (`agy teamwork-preview`) ไม่มีสิทธิ์ปิดงานเอง
- เอกสารนี้ขอส่งมอบผลงานไปยัง **Codex CLI / Reviewer (`stang-luna`)** เพื่อดำเนินการ Code Review 6 มิติ และตรวจรับงานเพื่อทำการรวมโค้ด (Merge) ต่อไป
