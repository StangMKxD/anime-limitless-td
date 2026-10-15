# PLAN-0003: ระบบ UI HUD และเซิร์ฟเวอร์อัปเกรดไร้ขีดจำกัด (Infinite Upgrade UI & Server)

- **สถานะ**: Ready for Implementation
- **ขอบเขตงาน (Ownership)**: 
  1. `src/Track3_UpgradeServer/UpgradeServer.server.luau`
  2. `src/Track3_UISystem/UpgradeHUD.client.luau`
- **Git Branch / Worktree**: `feat/track3-ui` (`../wt-track3-ui`)
- **พอร์ต Rojo สำหรับทดสอบ**: `34873`
- **เอกสารอ้างอิง**: [`requirement/03_track3_infinite_upgrade_ui_and_integration_spec.md`](../../../requirement/03_track3_infinite_upgrade_ui_and_integration_spec.md)

## 1. วัตถุประสงค์และฟีเจอร์
1. **Server Authority Upgrade Handler**:
   - สร้าง RemoteEvent `UpgradeStatRequest` ใน `ReplicatedStorage`
   - ตรวจสอบ Fallback `leaderstats.Cash` และ Player Attributes กรณีรันเทสเดี่ยวๆ
   - เมื่อผู้เล่นขอยกเกรด (`Damage`, `Range`, `Speed`) ให้ตรวจเงิน หักเงิน และปรับค่าสเตตัสตามสูตรทวีคูณ
2. **Formula Specifications**:
   - Damage: เริ่ม `75 Cash` | ถัดไป `math.floor(75 * (1.35 ^ (L-1)))` | พลังใหม่ `+35%` (`math.floor(CurrentDamage * 1.35 + 10)`)
   - Range: เริ่ม `60 Cash` | ถัดไป `math.floor(60 * (1.30 ^ (L-1)))` | ระยะใหม่ `+4 Studs`
   - Speed: เริ่ม `90 Cash` | ถัดไป `math.floor(90 * (1.40 ^ (L-1)))` | คูลดาวน์ใหม่ ลดลง `10%` (`math.max(0.12, CurrentCooldown * 0.90)`)
3. **Client ScreenGui (UpgradeHUD)**:
   - แถบด้านบน: แสดง `WAVE`, `ZOMBIES LEFT`, `BASE HP` (พร้อมแถบหลอดเลือด) แบบเรียลไทม์
   - แผงร้านค้าด้านซ้าย: แสดงสเตตัสทั้ง 3 สาย, เลเวลปัจจุบัน, ราคาอัปเกรด, ปุ่มกด และค่า DPS รวมสดๆ
   - อนิเมชันปุ่มและเอฟเฟกต์ปฏิเสธเมื่อเงินไม่พอ (กระพริบแดง)

## 2. ขอบเขตที่ห้ามทำ (Out-of-Scope)
- ห้ามแก้ไขไฟล์ในโฟลเดอร์ของ Track 1 และ Track 2
- ห้ามดึงค่าผ่านโค้ดภายในของ Track อื่น ให้คุยผ่าน Attributes และ RemoteEvent เท่านั้น

## 3. เกณฑ์การตรวจรับ (Acceptance Criteria)
- [ ] เมื่อรันในพอร์ต `34873` หน้าจอ HUD ด้านบนและเมนูร้านค้าด้านซ้ายแสดงผลขึ้นมา
- [ ] สามารถกดปุ่มซื้ออัปเกรดได้ เงินลดลง และราคาครั้งถัดไปเพิ่มขึ้นตามสูตร
- [ ] สเตตัสและค่า DPS เปลี่ยนแปลงทันที
- [ ] มี Fallback ตั้งค่าเงินเริ่มต้นให้ทดสอบได้แม้ยังไม่มี Track 1
