# บันทึกความคืบหน้า PLAN-0001: Core Wave & Scaling Enemies System

## ข้อมูลการรับงานและส่งมอบ (Task Status)
- **วันที่รับงาน**: 2026-10-15 21:10 (UTC+7)
- **วันที่พัฒนาเสร็จสิ้น**: 2026-10-15 21:18 (UTC+7)
- **ผู้รับผิดชอบ (Implementer)**: Google Antigravity (`agy teamwork-preview` / `stang-darkmatter`)
- **ชุดคอมโบ**: COMBO-07 (`stang-darkmatter` + `clean-code` + `focused-verification` + `technical-documentation`)
- **ขอบเขตที่ได้รับอนุมัติ**: `src/Track1_WaveSystem/WaveManager.server.luau` เท่านั้น
- **สถานะ**: READY_FOR_REVIEW (พัฒนาเสร็จสมบูรณ์ รอการตรวจรับจาก Codex Controller/Reviewer)

---

## สรุปงานที่ดำเนินการ (Implementation Summary)

### 1. Auto-Map & Waypoints Bootstrap
- สร้าง `Workspace.Waypoints` (จุดที่ 1 ถึง 6) รูปตัว S แบบอัตโนมัติเมื่อเริ่มเกม
- สร้างพื้นถนนคอนกรีต (`PathSegment_1` ถึง `5`) เชื่อมต่อระหว่างแต่ละ Waypoint
- สร้างคริสตัลฐานทัพอนิเมะ `Workspace.AnimeBaseCrystal` (สี Neon Cyan) ที่จุดสุดท้าย
- สร้างโฟลเดอร์ `Workspace.ActiveEnemies` สำหรับจัดเก็บมอนสเตอร์ทั้งหมด

### 2. Player Setup & Data Contract Sync
- สร้าง `leaderstats.Cash` (เริ่มต้น 300) และ `leaderstats.Wave` (เริ่มต้น 1 หรือตามเวฟปัจจุบัน)
- ตั้งค่า Player Attributes เริ่มต้นตามสัญญา `GameConfig.luau`:
  - `DamageStat` = 35, `RangeStat` = 32, `CooldownStat` = 1.0
  - `DamageLevel` = 1, `RangeLevel` = 1, `SpeedLevel` = 1
- รองรับทั้งผู้เล่นใหม่ที่เข้ามาในเซิร์ฟเวอร์ (`PlayerAdded`) และผู้เล่นที่มีอยู่เดิม

### 3. Infinite Wave Loop & Stat Scaling
- รันลูปเวฟไม่มีที่สิ้นสุด (`1, 2, 3...`)
- อัปเดต Attributes กลางบน `Workspace`:
  - `CurrentWave`: เลขเวฟปัจจุบัน
  - `BaseHP`: เลือดฐานปัจจุบัน (เริ่มต้น 1,000)
  - `MaxBaseHP`: เลือดฐานสูงสุด (1,000)
  - `ZombiesRemaining`: จำนวนซอมบี้ที่เหลือในเวฟแบบเรียลไทม์
  - `GameOver`: สถานะจบเกม (`true`/`false`)
- **สูตรการสเกลซอมบี้ไร้ขีดจำกัด**:
  - จำนวนซอมบี้ต่อเวฟ = `5 + (CurrentWave * 2)`
  - เลือดซอมบี้ = `math.floor(100 * (1.28 ^ (CurrentWave - 1)))`
  - ความเร็วเดิน = เพิ่มเวฟละ `0.25` (สูงสุด `26`)
  - บอสเวฟ 5 (และทุกเวฟที่หารด้วย 5 ลงตัว): เกิด **Anime Boss Zombie** เลือดคูณ 4 เท่า ขนาดตัว 1.8 เท่า สีแดงทมิฬพร้อมออร่าทองแดง

### 4. Zombie Presentation, Movement & Rewards
- มี `BillboardGui` แสดงชื่อเวฟ/บอส และหลอดเลือดสด (`HP / MaxHP`) บนหัวซอมบี้
- การเดินตาม Waypoint ใช้ `CFrame.lookAt` และการขยับแบบแองเคอร์ (`Anchored`) ป้องกันการตกแมพหรือติดบั๊กฟิสิกส์
- เมื่อซอมบี้เลือด `<= 0`: แจก `Cash` ให้ผู้เล่นทุกคน `25 * CurrentWave * (isBoss and 3 or 1)` มี Flag ป้องกันการแจกซ้ำ
- เมื่อซอมบี้ถึงฐาน: หักเลือดฐาน (ปกติ 50, บอส 150) หากเลือดฐาน `<= 0` จะเซ็ต `GameOver = true`
- ระบบรีเซ็ตเมื่อแพ้: พัก 5 วินาทีแล้วเริ่มเวฟ 1 ใหม่อัตโนมัติ โดยไม่ลบสเตตัสที่ผู้เล่นอัปไว้

---

## การตรวจสอบความปลอดภัยและผลกระทบ (Zero-Conflict Audit)
- **Track 1**: สร้างเฉพาะ `src/Track1_WaveSystem/WaveManager.server.luau` เท่านั้น
- **Track 2 (`src/Track2_TowerSystem/`)**: ไม่มีการแตะต้องหรือแก้ไข
- **Track 3 (`src/Track3_UpgradeServer/`, `src/Track3_UISystem/`)**: ไม่มีการแตะต้องหรือแก้ไข (ให้ Session อื่นทำต่อได้อย่างอิสระ)
- **Data Contract (`src/Shared/GameConfig.luau`)**: ไม่มีการแก้ไข รักษาความสมบูรณ์ของโครงสร้างกลาง 100%
