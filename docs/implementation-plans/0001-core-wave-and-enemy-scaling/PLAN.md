# PLAN-0001: ระบบแกนหลักเวฟและซอมบี้สเกลไร้ขีดจำกัด (Core Wave & Enemy Scaling)

- **สถานะ**: Ready for Implementation
- **ขอบเขตงาน (Ownership)**: `src/Track1_WaveSystem/WaveManager.server.luau`
- **Git Branch / Worktree**: `feat/track1-wave` (`../wt-track1-wave`)
- **พอร์ต Rojo สำหรับทดสอบ**: `34871`
- **เอกสารอ้างอิง**: [`requirement/01_track1_core_wave_and_enemy_spec.md`](../../../requirement/01_track1_core_wave_and_enemy_spec.md)

## 1. วัตถุประสงค์และฟีเจอร์
1. **Auto-Map & Waypoints Bootstrap**: สร้างทางเดิน S-curve และ Waypoints 1 ถึง 6 พร้อมปราสาทคริสตัลปลายทางใน Workspace อัตโนมัติเมื่อเริ่มเกม
2. **Player Initial Setup**: สร้าง `leaderstats.Cash` (300) และเซ็ตค่า Attributes เริ่มต้นของผู้เล่น
3. **Infinite Wave Loop**: รันลูปเวฟ `1, 2, 3...` อัปเดต `CurrentWave` และ `ZombiesRemaining` บน Workspace
4. **Infinite Zombie Scaling**:
   - จำนวนซอมบี้ต่อเวฟ = `5 + (CurrentWave * 2)`
   - เลือดซอมบี้ = `math.floor(100 * (1.28 ^ (CurrentWave - 1)))`
   - ความเร็วเดิน = เพิ่มขึ้นเวฟละ `0.25` (สูงสุด `26`)
   - ทุกเวฟหารด้วย 5 ลงตัว เกิด **Anime Boss Zombie** เลือดคูณ 4 เท่า ขนาดตัว 2.5 เท่า
5. **Movement, Combat & Economy**:
   - ซอมบี้เดินเรียงตาม Waypoint 1 -> 6 ด้วย Tween/PivotTo
   - แสดง BillboardGui หลอดเลือดสดบนหัว
   - เมื่อซอมบี้ตาย แจกเงินให้ผู้เล่นทุกคน `25 * CurrentWave`
   - เมื่อถึงจุดที่ 6 หักเลือดฐาน `BaseHP`

## 2. ขอบเขตที่ห้ามทำ (Out-of-Scope)
- ห้ามแตะต้องโฟลเดอร์ของ Track 2 และ Track 3
- ห้ามสร้าง UI หน้าร้านค้า หรือป้อมปืนในสคริปต์นี้

## 3. เกณฑ์การตรวจรับ (Acceptance Criteria)
- [ ] เมื่อกด Play ในพอร์ต `34871` ทางเดินและคริสตัลฐานปรากฏขึ้นอัตโนมัติ
- [ ] ซอมบี้เกิดตามจำนวนและเลือดตรงตามสูตรคำนวณ
- [ ] ซอมบี้เดินตามเส้นทางไม่ติดขัด ไม่หลุดฟิสิกส์
- [ ] บอสเกิดในเวฟ 5 และมีหลอดเลือด/ขนาดตัวต่างจากปกติชัดเจน
- [ ] สคริปต์ทำงานจบเวฟและขึ้นเวฟถัดไปได้ต่อเนื่องไม่มีที่สิ้นสุด
