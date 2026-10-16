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

### หลักการออกแบบสถาปัตยกรรมเพิ่มเติมสำหรับระยะที่ 5 (Phase 5 Invariants)
4. **Rig Ownership Singularity (สิทธิ์ความเป็นเจ้าของริกเดี่ยว)**: โมเดลตัวละครฮีโร่ในระบบป้อมต่อสู้ถูกสร้าง ตรวจสอบ และบริหารจัดการ Rig โดย `Track2_TowerSystem` เพียงผู้เดียว โดยติดป้ายกำกับ `Track2RigOwned = true` เพื่อป้องกันไม่ให้ระบบแปลงสกินภายนอก (`VisualBridge`) สร้างการสวมทับซ้ำซ้อนหรือสร้าง `WeldConstraint` ตรึงข้อต่อ `Motor6D`
5. **Visual-Combat Decoupling (การแยกวงจรการแสดงผลออกจากวงจรการต่อสู้)**: การคำนวณความเสียหาย คูลดาวน์ ดาเมจคริติคอล เกราะ และการเลือกเป้าหมาย ดำเนินการบนวงรอบเวลาของเซิร์ฟเวอร์อย่างเป็นเอกเทศ (Nominal Hit Time = 0.31s) โดยการเล่นแอนิเมชัน การสครับไทม์ไลน์ การปรับคุณภาพเอฟเฟกต์ หรือข้อผิดพลาดทางโค้ดในโมดูลการแสดงผล จะไม่มีผลกระทบต่อความถูกต้องของเกมเพลย์และระบบเศรษฐกิจ
6. **Studio Tooling Isolation (การกั้นแยกระบบเครื่องมือพัฒนาเฉพาะสตูดิโอ)**: เครื่องมือช่วยพัฒนาและทดสอบทั้งหมด (`DevTools / AnimationLab`) จะต้องถูกปิดกั้นการทำงานบนเซิร์ฟเวอร์จริงโดยอัตโนมัติด้วยเงื่อนไข `RunService:IsStudio()` และต้องไม่มีการปนเปื้อนข้อมูลตัวละครจำลอง (Dummy) เข้าสู่ระบบคำนวณเวฟหรือการให้รางวัลผู้เล่น

### นิยามศัพท์สำคัญเพิ่มเติมสำหรับระยะที่ 5 (Phase 5 Domain Glossary)
- **Semantic Rigging**: การจัดโครงสร้างข้อต่อ `Motor6D` เชิงความหมาย 6 จุดหลัก (`RootJoint`, `Neck`, `RightShoulder`, `LeftShoulder`, `RightHip`, `LeftHip`) และ 3 จุดอาวุธ (`WeaponRight`, `WeaponLeft`, `WeaponMouth`) ที่ควบคุมชิ้นส่วนแขนขาหลายชิ้น (`UpperArm`, `Forearm`, `Fist`) ได้อย่างสอดคล้องตามตำแหน่งจริง
- **Rest Pose Snapshot**: ข้อมูลพิกัดและขนาดตั้งต้น (`BaseC0`, `BaseC1`, `BaseSize`, `BaseAttachments`) ของโมเดลที่ถูกบันทึกไว้ก่อนเริ่มเล่นแอนิเมชัน เพื่อใช้เป็นจุดอ้างอิงในการคำนวณการเคลื่อนไหวและคืนค่าเดิมได้อย่างแม่นยำ ปราศจากค่าคลาดเคลื่อนสะสม (Zero Cumulative Drift)
- **Procedural Animation Profile**: ข้อมูลชุดคำสั่งในรูปแบบ Pure Luau Script ที่กำหนดการเปลี่ยนแปลงของ CFrame และขนาดของอวัยวะตามฟังก์ชันทางคณิตศาสตร์และการเคลื่อนที่สัมพันธ์ตามเวลา โดยไม่ใช้แอนิเมชันสำเร็จรูปที่อัปโหลดบน Roblox Asset ID
- **Visual Cue**: สัญญาณบอกตำแหน่งเวลาภายในรอบแอนิเมชัน เช่น `AttackWindup` หรือ `AttackImpact` สำหรับให้ระบบเอฟเฟกต์ภาพ (`VFXDispatcher`) ยิงเอฟเฟกต์ที่สอดคล้องกับจังหวะการโจมตี
- **VFX Resource Ledger**: ระบบบัญชีควบคุมทรัพยากรเอฟเฟกต์ที่คอยติดตามการสร้าง `Instance`, `Tween`, `Task`, และ `Connection` ทั้งหมด เพื่อบังคับใช้ขีดจำกัดจำนวนสูงสุด (Instance Caps) และรับประกันการทำลายทิ้งครบ 100% หลังจบการแสดงผล
- **Animation Lab**: ระบบแดชบอร์ดเฉพาะใน Roblox Studio ที่ช่วยให้นักพัฒนาสามารถตรวจสอบความสมบูรณ์ของโมเดล ควบคุมและทดสอบแอนิเมชัน ตรวจสอบเอฟเฟกต์ และทดสอบความเค้น (Stress Test) ได้อย่างสะดวก
- **Workspace Sandbox Stage**: พื้นที่ทดสอบโมเดลและเอฟเฟกต์ 3 มิติใน Workspace ที่แยกออกจากพื้นที่แผนที่เกมหลัก (พิกัด Y = 5000 Studs) เพื่อทดสอบการแสดงผลโดยไม่รบกวนกระบวนการทำงานของเกม
