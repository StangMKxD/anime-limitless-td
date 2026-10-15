# PLAN-0002: ระบบป้อมฮีโร่อนิเมะและการต่อสู้วิวัฒนาการ 4 ร่าง (Anime Towers & Combat)

- **สถานะ**: Ready for Implementation
- **ขอบเขตงาน (Ownership)**: `src/Track2_TowerSystem/TowerController.server.luau`
- **Git Branch / Worktree**: `feat/track2-towers` (`../wt-track2-towers`)
- **พอร์ต Rojo สำหรับทดสอบ**: `34872`
- **เอกสารอ้างอิง**: [`requirement/02_track2_anime_towers_and_combat_spec.md`](../../../requirement/02_track2_anime_towers_and_combat_spec.md)

## 1. วัตถุประสงค์และฟีเจอร์
1. **Auto-Spawn Anime Hero Units**: สร้างแท่นหุ่นผู้พิทักษ์อนิเมะ 6 ตัวขนาบข้างเส้นทางเดิน พร้อมวงแหวนแสดงระยะยิง (`Range Ring`)
2. **Real-Time Stat Sync**: ดึงค่าพลังรวม/สูงสุดของผู้เล่น (`DamageStat`, `RangeStat`, `CooldownStat`) มาอัปเดตให้ยูนิตทุกตัวแบบเรียลไทม์
3. **Anime Evolution Tiers (4 ร่างออร่า & การโจมตี)**:
   - **Tier 1 (Spirit Novice)**: Damage < 100 | ออร่าและลำแสงสีฟ้าคราม ยิงเป้าเดี่ยว
   - **Tier 2 (Awakened Sorcerer)**: Damage 100–399 | ออร่าและลำแสงสีม่วงอัสนี พร้อมคลื่นกระแทก
   - **Tier 3 (Super Golden Form)**: Damage 400–1499 | ออร่าสีทอง โจมตี AoE รัศมี 10 Studs
   - **Tier 4 (God of Destruction)**: Damage >= 1500 | ออร่าสีแดงเพลิง โจมตี AoE รัศมี 16 Studs
4. **Standalone Dummy Mode**: หากตรวจพบว่าไม่มี WaveManager ใน Workspace ให้เสก `TrainingDummy` มาให้ป้อมยิงทดสอบเดี่ยวๆ ได้ทันที

## 2. ขอบเขตที่ห้ามทำ (Out-of-Scope)
- ห้ามแก้ไขไฟล์นอกโฟลเดอร์ `src/Track2_TowerSystem/`
- ห้ามเขียนระบบสปอว์นเวฟ หรือสร้างหน้าจอ UI ซื้อของ

## 3. เกณฑ์การตรวจรับ (Acceptance Criteria)
- [ ] เมื่อรันในพอร์ต `34872` หุ่น 6 ตัวและวงแหวนระยะยิงปรากฏข้างทางเดิน
- [ ] ยูนิตค้นหาเป้าหมายและยิงลำแสง Tween สู่ศัตรูได้ถูกต้อง
- [ ] เมื่อสเตตัสผู้เล่นเพิ่มขึ้น วงแหวนและดาเมจของป้อมขยายขึ้นแบบสดๆ
- [ ] การเปลี่ยนร่าง 4 ขั้นแสดงชื่อ สีออร่า และผล AoE ตรงตามระดับดาเมจ
- [ ] เสกหุ่น `TrainingDummy` ได้ใน Standalone Mode
