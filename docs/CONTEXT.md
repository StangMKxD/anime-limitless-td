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

### หลักการออกแบบสถาปัตยกรรมเพิ่มเติมสำหรับ Milestone M5 (Milestone M5 Invariants)
7. **Empirical Telemetry Over Assertion (มาตรวัดเชิงประจักษ์เหนือสมมุติฐาน)**: การทดสอบประสิทธิภาพต้องรายงานตัวเลขผลการวัดจริง (CPU time, Part counts, Active instances) ไม่ใช้ตัวเลขคาดเดาหรือลดทอนขีดจำกัดเพื่อทำให้ผลการรันผ่าน
8. **Authoritative 13 Gates Integrity (ความสมบูรณ์ของประตูด่านตรวจ 13 ข้อ)**: เกณฑ์การตรวจรับ `G-01` ถึง `G-13` ต้องแยกหลักฐานออกเป็น 4 ประเภทอย่างชัดเจน โดยรายการที่ต้องใช้สายตามนุษย์สังเกตการณ์ใน Studio GUI ต้องรายงานตามจริงว่ายังไม่ได้ตรวจรับ เพื่อส่งมอบให้ Codex และผู้ตรวจสอบอิสระเป็นผู้ตรวจปิดงาน

### นิยามศัพท์สำคัญเพิ่มเติมสำหรับ Milestone M5 (Milestone M5 Domain Glossary)
- **Multi-Character Stress Benchmark**: การทดสอบความเค้นพร้อมกันของตัวละครจำนวนมาก (1, 10, 25, 50 ตัว) บนเวที Sandbox เพื่อวัดการใช้หน่วยความจำ ความเร็วในการประมวลผลต่อเฟรม และการไม่เกิดปัญหาข้อต่อพันกัน
- **Zero-Leak Balance**: สถานะที่ตัวเลขการสร้างวัตถุ (`createdCount`) ลบด้วยตัวเลขการทำลายวัตถุ (`cleanedCount`) มีค่าเท่ากับ 0 พอดี โดยไม่หลงเหลือ Instance, Tween, หรือ Connection ใดๆ ตกค้างในหน่วยความจำ
- **13 Gates Verification Barrier**: แผงด่านตรวจสอบคุณภาพ 13 มิติ ครอบคลุมตั้งแต่การรักษาโมเดลเดิม, ความถูกต้องของริก, แอนิเมชัน, เอฟเฟกต์, การแยกระบบรบ, การป้องกันหน่วยความจำรั่วไหล, และความเข้ากันได้ย้อนหลัง

### หลักการออกแบบสถาปัตยกรรมเพิ่มเติมสำหรับระยะที่ 6 (Phase 6 Invariants)
9. **Decoupled Visual Broadcast (การแพร่ภาพแสดงผลแบบแยกส่วนเด็ดขาด)**: การปล่อยอีเวนต์การแสดงผล เช่น `TowerPresentationRemote:FireAllClients(...)` ทำงานในรูปแบบ one-way notification จากเซิร์ฟเวอร์ โดยไม่มีการรอคอย (No yield) และไม่กระทบต่อ Damage Timer (0.31s nominal hit) หรือลำดับการคำนวณ Combat State ของเซิร์ฟเวอร์
10. **Neutral Presentation Runtime (รันไทม์การแสดงผลระดับตัวกลาง)**: โมดูลใน `src/Presentation/` (`RigBinder`, `AnimationPlayback`, `VFXDispatcher`, `QualityPolicy`, `PresentationPreferences`, ฯลฯ) ทำหน้าที่เป็น Pure Procedural Engine ที่รองรับทั้งฝั่ง Client, Server และ DevTools โดยไม่มีการผูกมัดหรือครอบงำสิทธิของ `Track2` หรือทำลายความเป็นอิสระของ Tracks อื่น
11. **Themed Map Gameplay Invariance (ความเสมอภาคของกลไกการเล่นบนแผนที่ธีม)**: แผนที่ทั้ง 4 ธีม (`Marineford`, `SakuraHarbor`, `SkySanctuary`, `VolcanicCitadel`) มีการกระจายตำแหน่ง `Waypoints` (ระยะทางรวมเท่ากันที่ ~250 studs) และจำนวน/ขนาดของ `PlacementSlots` (6 สล็อตมาตรฐาน) เท่าเทียมกัน 100% ทำให้ความยากและสมดุลของเกมเพลย์คงเดิมไม่เปลี่ยนแปลงตามธีม

### นิยามศัพท์สำคัญเพิ่มเติมสำหรับระยะที่ 6 (Phase 6 Domain Glossary)
- **Presentation Preferences**: ค่ากำหนดการแสดงผลฝั่งไคลเอนต์ (Animations, VFX, Camera Shake, Quality Preset) จัดเก็บเฉพาะเครื่องผู้เล่นและมีระบบ Event Subscription (`OnChange`)
- **Quality Policy**: นโยบายจำกัดทรัพยากรการแสดงผลตามระดับ Low / Medium / High (Particle Cap, Max Lights, VFX Detail) แบบ Monotonic Guard
- **Map Lifecycle State**: วงจรชีวิตของแผนที่ (`Voting`, `Building`, `Active`, `Teardown`) บริหารจัดการโดย `MapService` และ `MapSelectionService`
- **Camera Priority Preemption**: ระบบแย่งสิทธิ์ควบคุมมุมกล้องตามระดับความสำคัญ (Gameplay = 10, AmbientCombat = 20, LobbyPreview = 50, UltimateCinematic = 80, AnimationLab = 100) ป้องกันไม่ให้แอนิเมชันมุมกล้องระดับต่ำมาแทรกแซงมุมกล้องสำคัญ

