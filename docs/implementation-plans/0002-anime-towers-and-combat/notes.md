# บันทึกความคืบหน้า PLAN-0002

## สถานะปัจจุบัน
- [x] โครงสร้างโฟลเดอร์ `src/Track2_TowerSystem/` พร้อมใช้งาน
- [x] Data Contract `GameConfig.luau` อ้างอิงได้
- [x] Implement `TowerController.server.luau` สมบูรณ์ตามสเปก PLAN-0002
  - Auto-Spawn ยูนิตอนิเมะ 6 จุด พร้อมแท่น Pedestal, Torso, Head, SpiritOrb, AnimeAura, RangeIndicator และ TowerStatGui
  - Real-Time Combat Stats Synchronization จาก Attributes ของ Player (`DamageStat`, `RangeStat`, `CooldownStat`)
  - Anime Evolution 4 ขั้น (Tier 1 Cyan, Tier 2 Purple, Tier 3 Golden AoE 10 studs, Tier 4 Crimson AoE 16 studs)
  - Standalone Fallback Dummy Mode (`StandaloneTrainingDummy`) สำหรับรันเทสเดี่ยวบนพอร์ต `34872` โดยไม่ต้องพึ่งพา Track 1
  - Procedural Anime VFX (`playAnimeBlastVFX`) พร้อม TweenService fade/scale
- [x] อัปเกรด Phase 2: โมเดล R6 ปั้นสด 6 ตัวละครระดับตำนาน One Piece
  - Procedural R6 Rigs พร้อมเครื่องแต่งกาย/อาวุธเอกลักษณ์:
    - Luffy (หมวกฟางคาดแถบแดง + วงแหวนเมฆขาว Gear 5 + ท่า Bajrang Gun)
    - Zoro (ดาบ Wado คาบปาก + ดาบ Enma ม่วง + ดาบ Sandai เขียว + ท่า Enma Slash)
    - Sanji (เนคไททอง + ขาขวาไฟฟ้า Ifrit Jambe + ท่า Ifrit Kick)
    - Ace (หมวกคาวบอยส้ม + สร้อยลูกปัดแดง + ท่า Dai Enkai: Entei)
    - Law (หมวกขนสัตว์ขาว + ดาบ Kikoku + ท่าโดม Ope Ope Room)
    - Shanks (ผ้าคลุมไหล่จักรพรรดิดำ + ดาบ Gryphon + ท่า Kamusari สายฟ้าฮาคิแดง-ดำ)
  - สายฟ้าฮาคิราชันย์ซิกแซก (`spawnHakiLightning`) เมื่อติดคริติคอล หรือใช้ท่าของลูฟี่/แชงคูส
  - รองรับ Stat Sync ค่าใหม่จากการ์ดบัฟทุกเวฟ (`SPLASH_STAT`, `CRIT_CHANCE`)
  - Standalone Test Dummy: `PacifistaTrainingDummy` (เลือด 999,999 Auto-Heal) สำหรับรันเทสเดี่ยวบนพอร์ต `34872`
- [x] Zero-Conflict Isolation ตรวจสอบแล้ว: ทำงานบน Worktree `../wt-track2-towers` โฟลเดอร์ `src/Track2_TowerSystem/` ไม่แตะต้อง Track อื่น
- [ ] รอ Codex CLI / Reviewer ตรวจรับงาน Phase 2 ตามกระบวนการ SoD
