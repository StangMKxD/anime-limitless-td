# บันทึกความคืบหน้า PLAN-0003 (Phase 2: One Piece Wave Card Draft)

## สถานะปัจจุบัน
- [x] โครงสร้างโฟลเดอร์ `src/Track3_UpgradeServer/` และ `src/Track3_UISystem/` พร้อมใช้งาน
- [x] Data Contract `GameConfig.luau` อ้างอิงสเตตัสใหม่ (`SplashRadiusStat`, `CritChanceStat`, `PendingCardDraws`, `CardsPickedTotal`)
- [x] Implement Phase 2 `src/Track3_UpgradeServer/UpgradeServer.server.luau` สมบูรณ์:
  - Server Authority ตรวจสอบการ์ด 6 แบบ, ปุ่มซื้อสิทธิ์เปิดการ์ดเพิ่ม (`BuyExtraCardDraw`), ปุ่ม Reroll (`RerollCards`)
  - Standalone Fallback รองรับผู้เล่นใหม่แจก `PendingCardDraws = 1` อัตโนมัติ
- [x] Implement Phase 2 `src/Track3_UISystem/UpgradeHUD.client.luau` สมบูรณ์:
  - Procedural ScreenGui `OnePieceTD_CardHUD`
  - แถบด้านบน: `GRAND LINE WAVE X`, `ENEMIES`, หลอดเลือด Thousand Sunny
  - แผงด้านซ้าย: สรุปสเตตัสทีมหมวกฟาง (`BOUNTY`, `CREW DPS`, `HAKI DMG`, `CRIT`, `RANGE`, `AoE`, `SPEED`, `CARDS`) พร้อมปุ่มซื้อการ์ดเพิ่ม
  - โมดอลสุ่มการ์ด 3 ใบกลางจอ (`WaveCardDraftModal`): เด้งอัตโนมัติเมื่อ `PendingCardDraws > 0` พร้อมปุ่ม Reroll ($50)
- [x] ตรวจสอบ Code Isolation: แก้ไขเฉพาะในโฟลเดอร์ Track 3 ไม่ชน Track 1 หรือ 2
- [x] ปฏิบัติตามคำสั่ง: ไม่มีการรัน `rojo serve` ซ้ำซ้อน
