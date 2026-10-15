# โครงการ Anime Limitless Tower Defense — บริบทและคำศัพท์ระบบ (CONTEXT)

## 1. วิสัยทัศน์ของโครงการ (Project Vision)
Anime Limitless Tower Defense คือเกมแนว Tower Defense บนแพลตฟอร์ม Roblox ที่มุ่งเน้นระบบ **Infinite Progression (ความก้าวหน้าไร้ขีดจำกัด)** ทั้งการสเกลความยากของมอนสเตอร์ (Zombie HP & Speed Scaling) และการอัปเกรดพลังยูนิตของผู้เล่น (Damage, Range, Cooldown) พร้อมด้วยเอฟเฟกต์การเปลี่ยนร่างอนิเมะ (Anime Evolution Tiers) 4 ระดับ

## 2. หลักการออกแบบสถาปัตยกรรม (Architectural Invariants)
1. **Modular Zero-Conflict Architecture**: แยกโค้ดแต่ละ Track ออกจากกัน 100% โดยแต่ละ Track ทำงานในโฟลเดอร์ของตนเอง (`Track1_WaveSystem`, `Track2_TowerSystem`, `Track3_UISystem`, `Track3_UpgradeServer`)
2. **Decoupled Data Contracts**: ไม่มีการ `require` ข้าม Track โดยตรง ทุกการสื่อสารทำผ่าน `ReplicatedStorage.Shared.GameConfig`, `Workspace Attributes`, `Player Attributes` และ `RemoteEvent`
3. **Auto-Bootstrap & Standalone Testability**: ทุกระบบสามารถเสกสิ่งจำเป็นใน Workspace ขึ้นมาเองได้หากยังไม่มี (เช่น ทางเดิน จุดเกิดมอนสเตอร์ แท่นยูนิต) และมี Mock/Fallback เช่น `TrainingDummy` เพื่อให้ทดสอบเดี่ยวได้ทันที

## 3. นิยามศัพท์สำคัญ (Domain Glossary)
- **Waypoints**: จุดพิกัด 1 ถึง 6 บน Workspace ที่กำหนดเส้นทางเดินของซอมบี้จากจุดเกิดสู่ฐาน
- **AnimeBase / AnimeBaseCrystal**: ฐานทัพคริสตัลปลายทาง มีเลือดเริ่มต้น 1,000 HP หากซอมบี้เดินถึงจะหักเลือดฐาน
- **Anime Towers**: ยูนิตผู้พิทักษ์อนิเมะ 6 จุดข้างทางเดิน ค้นหาศัตรูและปล่อยพลังโจมตี
- **Evolution Tiers**: ระดับร่างวิวัฒนาการของยูนิตตามค่า DamageStat (Tier 1: Cyan, Tier 2: Void Purple, Tier 3: Super Golden AoE, Tier 4: God of Destruction AoE)
- **Stat Progression**: การอัปเกรดสเตตัสแบบทวีคูณ (Exponential) ด้วย Cash ที่ได้จากการปราศัตรู
