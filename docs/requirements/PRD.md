# เอกสารข้อกำหนดผลิตภัณฑ์ (Product Requirements Document - PRD)

## 1. วัตถุประสงค์ (Objectives)
สร้างเกม Anime Limitless Tower Defense บน Roblox ที่มีระบบการเล่นหลัก 3 ส่วนทำงานเชื่อมโยงกันอย่างสมบูรณ์แบบ:
1. ระบบเวฟมอนสเตอร์ไม่จำกัด และสเกลความยากทวีคูณ
2. ระบบป้อมฮีโร่อนิเมะ โจมตีอัตโนมัติ และเปลี่ยนร่างเอฟเฟกต์ตามพลัง
3. ระบบร้านค้าอัปเกรดแบบเรียลไทม์ และหน้าจอ HUD สไตล์อนิเมะ

## 2. ขอบเขตฟังก์ชัน (Functional Requirements)

### FR-01: ระบบเวฟและการเกิดซอมบี้ (Core Wave System)
- สร้างทางเดิน Waypoints 1 ถึง 6 และฐานคริสตัลอัตโนมัติหากยังไม่มีใน Workspace
- รันเวฟเริ่มต้นตั้งแต่ Wave 1 ไปเรื่อยๆ ไม่มีที่สิ้นสุด
- จำนวนซอมบี้ต่อเวฟ = `5 + (CurrentWave * 2)`
- เลือดซอมบี้ (`MaxHealth`) = `math.floor(100 * (1.28 ^ (CurrentWave - 1)))`
- ความเร็วซอมบี้ (`WalkSpeed`) = เพิ่มขึ้นเวฟละ `0.25` (สูงสุด `26`)
- ทุกๆ 5 เวฟ (Wave 5, 10, 15...) เกิด **Anime Boss Zombie** (ขนาด 2.5 เท่า เลือดคูณ 4 เท่า)
- มีป้าย BillboardGui แสดงหลอดเลือดและชื่อมอนสเตอร์บนหัว
- ซอมบี้เดินตาม Waypoints เมื่อถูกปราบ ผู้เล่นทุกคนในเซิร์ฟเวอร์จะได้รับ `Cash = 25 * CurrentWave`
- เมื่อซอมบี้เดินถึงฐาน หักเลือดฐานตามจำนวนที่กำหนด หากเลือดฐาน `<= 0` ให้ขึ้นสถานะ Game Over

### FR-02: ระบบป้อมอนิเมะและการต่อสู้ (Anime Towers & Combat)
- สร้างแท่นอัญเชิญพร้อมฮีโร่อนิเมะ 6 จุดข้างทางเดินอัตโนมัติ พร้อมวงแหวนแสดงระยะยิง (Range Ring)
- ยูนิตอ่านค่าพลังของผู้เล่น (`DamageStat`, `RangeStat`, `CooldownStat`) แบบเรียลไทม์
- ค้นหาศัตรูที่ใกล้ที่สุดในโฟลเดอร์ `ActiveEnemies` และยิงลำแสง Tweened Beam
- ระดับวิวัฒนาการ 4 ร่าง (Evolution Tiers):
  - **Tier 1 (Spirit Novice)**: Damage < 100 | ลำแสงสีฟ้าคราม ยิงเป้าเดี่ยว
  - **Tier 2 (Awakened Sorcerer)**: Damage 100–399 | ลำแสงสีม่วงอัสนี พร้อมคลื่นระเบิด
  - **Tier 3 (Super Golden Form)**: Damage 400–1499 | ออร่าทอง โจมตี AoE รัศมี 10 Studs
  - **Tier 4 (God of Destruction)**: Damage >= 1500 | ออร่าแดงเพลิง โจมตี AoE รัศมี 16 Studs
- Standalone Dummy Mode: หากรันเดี่ยวๆ โดยไม่มี WaveManager ให้เสก `TrainingDummy` ออกมาให้ป้อมยิงได้

### FR-03: ระบบอัปเกรดและหน้าจอ HUD (Infinite Upgrades & UI)
- สร้าง ScreenGui ด้านบนแสดง: WAVE, ZOMBIES LEFT, BASE HP (พร้อมหลอดเลือด)
- แผงร้านค้าด้านซ้ายมือ มีปุ่มกดอัปเกรด 3 สาย:
  - **Damage**: ราคาเริ่มต้น `75 Cash` | สูตรคูณ `math.floor(75 * (1.35 ^ (L-1)))` | ดาเมจใหม่ `+35%` ต่อเลเวล
  - **Range**: ราคาเริ่มต้น `60 Cash` | สูตรคูณ `math.floor(60 * (1.30 ^ (L-1)))` | ระยะยิงใหม่ `+4 Studs` ต่อเลเวล
  - **Speed**: ราคาเริ่มต้น `90 Cash` | สูตรคูณ `math.floor(90 * (1.40 ^ (L-1)))` | คูลดาวน์ลด `10%` ต่อเลเวล (ต่ำสุด `0.12s`)
- แสดงค่า DPS รวมแบบคำนวณสด (`Damage / Cooldown`)
- เชื่อมต่อผ่าน RemoteEvent `UpgradeStatRequest` พร้อมเซิร์ฟเวอร์ตรวจสอบเงินและหักเงินอย่างปลอดภัย

## 3. ข้อกำหนดระยะที่ 5: โมเดลตัวละคร แอนิเมชัน เอฟเฟกต์ และห้องทดลอง (Phase 5: Character Model, Signature Animation, VFX & Animation Lab)

### วัตถุประสงค์และขอบเขต (Objectives & Scope Lock)
พัฒนาและยกระดับคุณภาพการแสดงผลทางสายตาของยูนิตฮีโร่และศัตรูในเกม Anime Limitless Tower Defense โดยคงความสมบูรณ์ของระบบเกมเพลย์เดิม 100%:
- **In-Scope**:
  - รองรับการโหลดและตรวจสอบโมเดล `.rbxmx` ทั้ง 19 รายการในคลังสินทรัพย์ (12 Heroes, 4 Enemies, 3 Map Assets)
  - พัฒนาระบบแอนิเมชันและเอฟเฟกต์เฉพาะตัว (Signature Animation & VFX) สำหรับ 3 ตัวละครหลักชุดแรก: Luffy Gear 5, Zoro King of Hell, Ace Flame Emperor
  - ออกแบบระบบแอนิเมชันและเอฟเฟกต์สำรอง (_FallbackProfile & _FallbackVFX) สำหรับอีก 9 ตัวละครและศัตรู
  - สร้างห้องทดลองและตรวจสอบโมเดลในสตูดิโอ (Studio-Only Animation Lab Developer Dashboard)
- **Out-of-Scope**:
  - ไม่เพิ่มจำนวนตัวละครที่เล่นได้ในระบบสุ่ม (Playable Hero Catalog คงเดิมที่ 8 ตัวละครตาม `GameConfig.HERO_CATALOG`)
  - ไม่ปรับแก้สูตรดาเมจ คูลดาวน์ อัตราคริติคอล เกราะ สโลว์ หรือระบบเศรษฐกิจ/เงินรางวัลในเกม
  - ไม่แก้ระบบการเดินของศัตรูใน Track 1 หรือระบบ HUD ผู้เล่นใน Track 3

### รายการความต้องการทางเทคนิค (Phase 5 Requirements: P5-R01 .. P5-R08)

#### P5-R01: การตรวจสอบและจำแนกคลังสินทรัพย์โมเดล 19 รายการ (Asset Inventory & Truthful Validation)
- ตรวจสอบโครงสร้างไฟล์ `.rbxmx` ทั้ง 19 ไฟล์ใน `assets/rojo/` (Heroes 12, Enemies 4, Map Assets 3)
- รักษาจำนวนชิ้นส่วนจริงของโมเดลเดิมโดยไม่ยุบชิ้นส่วนโดยพลการ (Luffy 122, Zoro 139, Ace 128 BaseParts)
- ระบบจำแนกสถานะต้องรายงานความพร้อมตามจริง (Template Exists, Cloneable, Rig Mobility, Animation Ready, VFX Ready) โดย Map Assets แสดงสถานะริกเป็น `N/A (Static Map Asset)`

#### P5-R02: สถาปัตยกรรมริกความหมายเชิงโครงสร้าง (Semantic Rigging & Multi-Part Limbs)
- โมเดลตัวละครฮีโร่ทั่วไปและศัตรูรองรับ 6 ข้อต่อหลัก: `RootJoint`, `Neck`, `RightShoulder`, `LeftShoulder`, `RightHip`, `LeftHip`
- โมเดลที่ใช้อาวุธ (Zoro) รองรับข้อต่ออาวุธเพิ่ม 3 จุด: `WeaponRight` (ดาบ Enma มือขวา), `WeaponLeft` (ดาบ Sandai Kitetsu มือซ้าย), `WeaponMouth` (ดาบ Wado Ichimonji คาบปาก) รวมเป็น 9 ข้อต่อ
- รองรับการจัดกลุ่มชิ้นส่วนแขนขาหลายท่อน (Multi-part Limbs: UpperArm, Forearm, Fist) ให้เคลื่อนไหวตาม Pivot ของข้อต่อพร้อมเพรียงกัน
- ผูกชิ้นส่วนเครื่องประดับ (Accessories) เข้ากับส่วนลำตัวที่ถูกต้อง (หมวกผูกกับ Head, เสื้อคลุม/ฝักดาบ/สร้อยผูกกับ Torso)
- ขจัดปัญหาการล็อกข้อต่อแข็ง (No Rigid WeldConstraint across Motor6D joints)

#### P5-R03: ตัวเล่นแอนิเมชันเชิงกระบวนการแบบกำหนดผลลัพธ์แน่นอน (Deterministic Procedural Animation)
- รองรับ 8 สถานะมาตรฐาน: `Idle`, `SpecialIdle`, `Spawn`, `Windup`, `Attack`, `Impact`, `Recovery`, `Ultimate`
- คำนวณท่าทางการเคลื่อนไหวสัมพันธ์กับฐานข้อมูลท่าพักเริ่มต้น (Rest-pose Snapshot: `BaseC0`, `BaseC1`, `BaseSize`, `BaseAttachments`)
- ปราศจากปัญหาค่าพิกัดคลาดเคลื่อนสะสม (Zero Cumulative Drift, ค่าเบี่ยงเบนขนาดและตำแหน่งเมื่อรีเซ็ต `< 0.001`)
- รองรับคำสั่งควบคุมการเล่น: Play, Pause, Stop, Replay, Loop Toggle, ปรับความเร็ว (0.1x–2.0x), เลื่อนทีละเฟรม (+/- 1/60s) และการข้ามไปยังจุดเวลาใดๆ (Seek / Scrubbing)

#### P5-R04: ระบบควบคุมเอฟเฟกต์ภาพและบัญชีทรัพยากร (VFX Contract, Presets & Resource Ledger)
- รองรับ Visual Cues มาตรฐาน: `PassiveAura`, `SpawnDeploy`, `SpecialIdleCue`, `AttackWindup`, `AttackRelease`, `AttackImpact`, `UltimateCast`, `UltimateImpact`
- รองรับการปรับระดับคุณภาพ 3 ระดับ (Quality Presets):
  - **Low**: Particle rate 0.35, Max concurrent parts 8, ปิด PointLight
  - **Medium**: Particle rate 0.70, Max concurrent parts 16, PointLight ความสว่างปานกลาง
  - **High**: Particle rate 1.00, Max concurrent parts 30, PointLight เต็มรูปแบบ
- รองรับการเปิด/ปิดเลเยอร์เอฟเฟกต์ 6 เลเยอร์อิสระ: `Particles`, `Aura`, `Trail/Beam`, `Impact`, `Camera Shake`, `Screen Flash`
- ควบคุมวงจรชีวิตทรัพยากรเอฟเฟกต์ผ่าน Resource Ledger (`Instance`, `Tween`, `Task`, `Connection`) โดยรับประกันการล้างทรัพยากรเหลือ 0 (100% Cleanup) เมื่อยูนิตถูกทำลายหรือขาย

#### P5-R05: การรักษาสมดุลและจังหวะเวลาการต่อสู้ดั้งเดิม (Combat Oracle & Timing Preservation)
- จังหวะการโจมตีทางเซิร์ฟเวอร์ยังคงมาตรฐานเดิมอย่างเคร่งครัด: Nominal Hit Impact Baseline = `0.14s + 0.10s + 0.07s = 0.31s`
- การคำนวณดาเมจ, อัตราคริติคอล (Crit RNG), การตรวจจับพื้นที่ (AoE Splash), การหักลบเกราะ (Armor Mod), การสโลว์ (Slow Debuff) และการบันทึกตำแหน่งเป้าหมาย (Target Snapshot) ทำงานบน Server Timer แยกจากแอนิเมชันโดยเด็ดขาด
- หากแอนิเมชันถูกหยุด ข้ามเวลา ยกเลิก หรือเกิดข้อผิดพลาดในสคริปต์ ดาเมจยังคงถูกคำนวณและส่งมอบตามจังหวะเวลา 0.31s เสมอ

#### P5-R06: แดชบอร์ดห้องทดลองแอนิเมชันเฉพาะในสตูดิโอ (Studio-Only Animation Lab UI)
- เครื่องมือเปิดใช้งานได้เฉพาะในสภาพแวดล้อม Roblox Studio เท่านั้น (`RunService:IsStudio()`) โดยตัดการทำงานทันทีใน Production Server
- เวทีทดสอบอิสระ 3 มิติ (Primary Workspace Sandbox Stage) ที่ระดับความสูง Y=5000 Studs พร้อมแท่นทดสอบ Grid, ไฟสตูดิโอ, การหมุนมุมกล้องรอบวัตถุ (Orbit Camera), ตัวควบคุมสเกล (0.5x–2.5x) และหุ่นทดสอบจำลอง (Dummy Target)
- จอพรีวิวรองแบบ Mini ViewportFrame สำหรับการตรวจสอบโครงสร้าง Wireframe
- แถบไทม์ไลน์ 5 เฟส (Wind-up -> Attack -> Impact -> Recovery) พร้อมปุ่มคำสั่งควบคุมท่าทางและเอฟเฟกต์ครบวงจร

#### P5-R07: การทดสอบประสิทธิภาพและความเค้น (Stress Benchmark & Telemetry)
- รองรับการรันแบบจำลองความเค้น 1, 10, 25, 50 ตัวละครพร้อมกันบนเวที Sandbox
- แสดงผลมาตรวัดแบบเรียลไทม์: Frame Time (ms), FPS, Active Motor6D, Active Welds, Active Particles, Active Tweens และผลต่างการสร้างเทียบกับการทำลาย Instances (Created vs Cleaned Delta)
- ยืนยันการไม่เกิดหน่วยความจำรั่วไหล (Zero Leak Verification) หลังสั่งเคลียร์เวทีทดสอบ

#### P5-R08: การจำกัดขอบเขต Signature Batch 1 และระบบสำรอง (Signature Batch 1 & Fallback Integrity)
- ชุดเอกลักษณ์แอนิเมชันและเอฟเฟกต์สมบูรณ์จำกัดเฉพาะ 3 ฮีโร่หลัก:
  - **Luffy Gear 5**: ท่าเด้ง Joyboy, หัวเราะเทพนิกะ, หมัดยืด Rubber Stretch, หมัดยักษ์ Bajrang Fist พร้อมออร่าเมฆและสายฟ้าฮาคิราชันย์สีดำ-แดง
  - **Zoro King of Hell**: ท่าเตรียม 3 ดาบ Santoryu, ท่าไขว้ดาบ Oni Giri, เพลิงนรก King of Hell เปลวไฟมรกต-ม่วงทอง, รอยลากดาบ 3 เส้น (Three-Sword Trails) และคลื่นดาบ 103 Mercies
  - **Ace Flame Emperor**: ท่าจุดไฟปลายนิ้ว, ท่าชาร์จหมัดเพลิง Hiken, เสาเพลิง, และดวงอาทิตย์เพลิงยักษ์ Dai Enkai: Entei เหนือมือขวา
- โมเดลอีก 16 รายการที่เหลือ (9 Heroes, 4 Enemies, 3 Map Assets) ทำงานผ่าน `_FallbackProfile` และ `_FallbackVFX` อย่างเสถียร
