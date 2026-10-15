# บันทึกความคืบหน้า PLAN-0001: Grand Line Wave & R6 Enemy System (Phase 2)

## ข้อมูลการรับงานและส่งมอบ (Task Status)
- **วันที่รับงาน**: 2026-10-15 21:50 (UTC+7)
- **วันที่พัฒนาเสร็จสิ้น**: 2026-10-15 21:54 (UTC+7)
- **ผู้รับผิดชอบ (Implementer)**: Google Antigravity (`agy teamwork-preview` / `stang-darkmatter`)
- **ชุดคอมโบ**: COMBO-07 (`stang-darkmatter` + `clean-code` + `focused-verification` + `technical-documentation`)
- **ขอบเขตที่ได้รับอนุมัติ**: `src/Track1_WaveSystem/WaveManager.server.luau` (Phase 2 One Piece Edition)
- **สถานะ**: READY_FOR_REVIEW (พัฒนา Phase 2 เสร็จสมบูรณ์)

---

## สรุปฟีเจอร์ Phase 2 ที่พัฒนา (Implementation Summary)

### 1. Grand Line / Marineford Map Bootstrap
- อัปเกรดทางเดินหิน Cobblestone สไตล์สมรภูมิมารีนฟอร์ด (`GrandLineRoad_1` ถึง `5`) ขนาดกว้าง 10 Studs
- เพิ่มเส้นขอบทองคำเรืองแสงฮาคิ (`RoadGoldTrim_1` ถึง `5`)
- เสกซุ้มประตูมิติทมิฬ **Thriller Bark Dark Gate** ที่จุดเกิด (`Waypoint 1`) พร้อมเสาหิน Basalt และประตูวงกลม `DarkPortalVortex` สี Neon Purple
- เสกฐานทัพหลัก **Road Poneglyph** ศิลาสีแดงทมิฬ (`AnimeBaseCrystal` เลือด 1,500 HP) และ **Thousand Sunny Core** (`SunnyGoldenCore` บอลสีทองเรืองแสงด้านบน) ที่จุดที่ 6

### 2. Player Setup & Wave Card Trigger
- กำหนดค่าเริ่มต้นผู้เล่นตามสัญญา `GameConfig.luau`:
  - `Cash` = 300 (Bounty Belly)
  - `DamageStat` = 45, `RangeStat` = 36, `CooldownStat` = 0.95s
  - `SplashRadiusStat` = 6, `CritChanceStat` = 15% (ฮาคิราชันย์)
  - `PendingCardDraws` = 1 (รับสิทธิ์เปิดการ์ดฟรีทันทีเมื่อเข้าเกม)
  - `CardsPickedTotal` = 0
- **แจกการ์ดอัปเกรดทุกเวฟ**:
  - ทุกครั้งที่ขึ้นเวฟใหม่ (Wave 2, 3, 4...) จะแจกสิทธิ์เปิดการ์ด `PendingCardDraws += 1` ให้ผู้เล่นทุกคน
  - เวฟบอส (หารด้วย 5 ลงตัว) แจกการ์ดพิเศษเพิ่มเป็น `+2` ใบ!

### 3. Procedural R6 Thriller Bark Zombies & Yonko Kaido Boss
- ปั้นโครงร่างมอนสเตอร์ **R6 ครบ 6 ชิ้น** (`HumanoidRootPart`, `Torso`, `Head`, `LeftArm`, `RightArm`, `LeftLeg`, `RightLeg`)
- มอนสเตอร์ปกติ: ถือดาบโจรสลัด `CutlassBlade` (Neon Cyan)
- บอสจักรพรรดิ **Yonko Kaido Boss** (ทุกๆ 5 เวฟ):
  - ขยายขนาด 2.1 เท่า
  - เพิ่มเขามังกรคู่ `DragonHornL`, `DragonHornR` (Neon Gold)
  - ถือกระบองยักษ์ `HakiKanabo` (Neon Red อาบฮาคิราชันย์)
  - เลือดมอนสเตอร์คูณ 5 เท่าของเวฟนั้น
- แอนิเมชันเดินแกว่งแขนขาแบบสมจริง (`updateR6Pose`) อิงตาม sin function และความเร็วเดินจริง
- เมื่อมอนสเตอร์ตาย: แจกเงิน Bounty Belly `35 * CurrentWave * (isBoss and 4 or 1)` มี Flag ป้องกันการจ่ายซ้ำ
- เมื่อมอนสเตอร์ถึงฐาน: หักเลือดฐาน (ปกติ 60, บอส 250) หากเลือดหมดเข้าสู่ลูป Game Over รีเซ็ตเริ่มเวฟ 1 ใหม่
