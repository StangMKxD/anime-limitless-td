# บันทึกความคืบหน้า PLAN-0003

## สถานะปัจจุบัน
- [x] โครงสร้างโฟลเดอร์ `src/Track3_UpgradeServer/` และ `src/Track3_UISystem/` พร้อมใช้งาน
- [x] Data Contract `GameConfig.luau` อ้างอิงได้
- [x] Implement `src/Track3_UpgradeServer/UpgradeServer.server.luau` สมบูรณ์ (Server Authority, Auto-Bootstrap Fallback, Exponential Upgrade Formulas)
- [x] Implement `src/Track3_UISystem/UpgradeHUD.client.luau` สมบูรณ์ (ScreenGui HUD: Top Wave/HP Bar, 3-Stat Upgrade Panel, Realtime DPS)
- [x] ตรวจสอบ Code Isolation: ไม่มีไฟล์นอกขอบเขต Track 3 ถูกแตะต้อง (R02, R03)
- [x] ไม่มีการรัน `rojo serve` ชนกับ session อื่นตามคำสั่งผู้ใช้
- [ ] รอ Codex (Controller & Reviewer) ตรวจสอบและตรวจรับงานตามกติกา SoD
