# Character Implementation Plan 03 — Ace Flame Emperor (`Ace.rbxmx`)

> **IMPLEMENTATION AUTHORIZED / NOT STARTED:** ผู้ใช้ให้ AGY ทำ Phase5 ทั้งหมดแล้วส่ง Codex รีวิวรวมตอนท้าย อ่าน [HANDOFF ล่าสุด](../assets/HANDOFF.md), [PLAN](../PLAN.md), [tasks](../tasks.md) และ [contracts](../assets/contracts-and-integration.md) ก่อน; ไม่มีผล spec/Studio หรือการรับรอง visual แล้ว


- **Document ID:** `0005-character-model-animation/characters/03-ace.md`
- **Implementer ที่เสนอ:** AGY-Char-Ace — ยังไม่มอบหมาย session
- **Branch:** ยังไม่สร้าง; ชื่อตาม Master Pack เป็นข้อเสนออนาคตเท่านั้น
- **Worktree:** ยังไม่สร้างและยังไม่อนุมัติในรอบนี้
- **Target Model:** assets/rojo/HeroModels/Ace.rbxmx
- **Verification Status:** `NOT VERIFIED` (Planning Stage Only)

---

## 1. Existing Model Analysis — ตรวจจาก baseline จริง

- [CONFIRMED] assets/rojo/HeroModels/Ace.rbxmx มี 128 BaseParts, 128 Anchored parts, 0 serialized Motor6D และ 0 Weld/WeldConstraint; เป็นผลอ่าน XML ไม่ใช่ผลเล่น Studio
- ชื่อ Part ที่พบจริง: `HumanoidRootPart`, `Torso`, `Head`, `HeadTopBevel`, `UpperArm`, `Forearm`, `Fist`, `UpperArm_2`, `Forearm_2`, `Fist_2`, `Thigh`, `Shin`, `Boot`, `BootToe`, `Thigh_2`, `Shin_2`, `Boot_2`, `BootToe_2`, `RedNeckBead_1`, `RedNeckBead_2`, `RedNeckBead_3`, `RedNeckBead_4`, `RedNeckBead_5`, `RedNeckBead_6`, `RedNeckBead_7`, `RedNeckBead_8`, `RedNeckBead_9`, `RedNeckBead_10`, `RedNeckBead_11`, `RedNeckBead_12`, `RedNeckBead_13`, `RedNeckBead_14`, `AceHatBrim`, `AceHatCrown`, `AceHatBeadString`, `HatSmileyBadge`, `HatSmileyBadge_2`, `HipDagger`
- geometry ใช้กลุ่ม UpperArm/Forearm/Fist และชื่อ _2 หลายชิ้น ไม่ได้มี LeftArm/RightArm/LeftLeg/RightLeg เป็น rig ครบตามตารางปลายทาง การจับซ้าย/ขวาต้องดู local coordinates/geometry ไม่เดาจาก _2 อย่างเดียว
- ประเด็น VisualBridge clone skin ซ้อน / hideLegacyParts และ runtime joints ดู [notes](../notes.md); อาการที่เห็นในเกมและ actual mobility ยัง NOT VERIFIED
- ส่วน 2–7 ต่อไปเป็น TARGET DESIGN จาก Master Pack ไม่ใช่คำบรรยายสิ่งที่มีแล้ว; Part cap 21 เป็นข้อเสนอที่ขัด baseline และถูกกั้นด้วย D-04 ห้ามลบรายละเอียดเพื่อให้ผ่านตัวเลขโดยไม่มีอนุมัติ

---

## 2. Model Improvement Requirements

1. **เอกลักษณ์ของ Ace (Flame Emperor / Mera Mera no Mi):**
   - **หมวกคาวบอยสีส้ม (`CowboyHat`):** หมวกสีส้มสด (`Color3.fromRGB(235, 110, 30)`) ประดับสัญลักษณ์หน้ายิ้ม/หน้าบึ้งสีฟ้าและสายลูกปัดสีแดงคล้องใต้คาง ยึดติดกับ `Head`
   - **สร้อยลูกปัดสีแดง (`RedBeadNecklace`) และรอยสักแผ่นหลัง/แขนซ้าย (`TattooDecals`):** สร้อยลูกปัดทรงกลมสีแดงสดรอบคอ (`Part0 = Torso`)
   - **กางเกงขาสั้นสีดำ เข็มขัดหัวอักษร A และมีดสั้นสีเขียว (`BeltAndDagger`):** ยึดติดกับ `Torso` ช่วงเอว
   - **จุดปล่อยไฟประจำอวัยวะ (`FlameAttachments`):** เพิ่ม `Attachment` ชื่อ `RightHandFlameAtt`, `LeftHandFlameAtt`, และ `OverheadEnteiAtt` เพื่อใช้เป็นจุดกำเนิดของ `ParticleEmitter` และ `Beam` โดยไม่ต้องสร้าง Part เปล่าซ้ำๆ ตอน Runtime
2. **งบประมาณจำนวนชิ้นส่วน (Part & Draw Call Budget):**
   - จำนวน `BasePart` ทั้งหมดของ `Ace.rbxmx` มี **เป้าหมายเดิมไม่เกิน 21 Parts — PENDING D-04; ยังไม่ใช่ cap ที่อนุมัติ**
   - ทุก Part ยกเว้น `HumanoidRootPart` ต้องมี `Anchored = false`, `CanCollide = false`, `CanTouch = false`, `CanQuery = false`, `Massless = true`

---

## 3. Rig Mapping & Accessory Specification

### 3.1 ตาราง `Motor6D` ทั้ง 6 ข้อต่อหลัก
| Joint Name (`AnimationContract`) | `Part0` (Parent) | `Part1` (Child) | `BaseC0` (Rest Pose Offset) | `BaseC1` (Pivot Offset) | หน้าที่ในการเคลื่อนไหว |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`RootJoint`** | `HumanoidRootPart` | `Torso` | `CFrame.new(0, 0, 0)` | `CFrame.new(0, 0, 0)` | บิดสะโพกและไหล่ตามท่าชกมวยเพลิง และการลอยตัวเล็กน้อยตอนใช้พลังโรเกีย |
| **`Neck`** | `Torso` | `Head` | `CFrame.new(0, 1.5, 0)` | `CFrame.new(0, -0.5, 0)` | ก้มหน้ากดปีกหมวกเล็กน้อยตอนตั้งท่า และเงยหน้ามองลูกไฟ `Entei` ตอนใช้ท่าไม้ตาย |
| **`RightShoulder`** | `Torso` | `RightArm` | `CFrame.new(1.5, 0.5, 0)` | `CFrame.new(0, 0.5, 0)` | **ข้อต่อหลักสำหรับจุดไฟปลายนิ้ว (`Idle`), ชาร์จไฟ (`Windup`), ชก `Hiken` (`Attack`), และชูมือสร้าง `Entei` (`Ultimate`)** |
| **`LeftShoulder`** | `Torso` | `LeftArm` | `CFrame.new(-1.5, 0.5, 0)` | `CFrame.new(0, 0.5, 0)` | ยกมือซ้ายขึ้นเล็งเป้าหมาย (`Targeting Sight` หรือทำนิ้วปืนไฟ `Higan`) และดึงประคองสมดุลตอนชกขวา |
| **`RightHip`** | `Torso` | `RightLeg` | `CFrame.new(0.5, -1.0, 0)` | `CFrame.new(0, 1.0, 0)` | ยันขาหลังส่งแรงบิดเอวตอนปล่อยหมัดอัคคี |
| **`LeftHip`** | `Torso` | `LeftLeg` | `CFrame.new(-0.5, -1.0, 0)` | `CFrame.new(0, 1.0, 0)` | ก้าวเท้าซ้ายนำหน้าในท่ายืน Martial Boxer Stance |

### 3.2 ตารางการยึด Accessories (`accessoryRules`)
| ชื่อชิ้นส่วน Accessory | ยึดเข้ากับ (`attachToLimb`) | ชนิดการเชื่อมต่อ | ค่า Offset มาตรฐาน |
| :--- | :--- | :--- | :--- |
| `CowboyHat` (หมวกสีส้ม) | `Head` | `WeldConstraint` | `CFrame.new(0, 0.60, 0) * CFrame.Angles(math.rad(-6), 0, 0)` |
| `RedBeadNecklace` (สร้อยลูกปัดแดง) | `Torso` | `WeldConstraint` | `CFrame.new(0, 0.92, 0)` |
| `HipDagger` (มีดสั้นและกระเป๋าข้างเอว) | `Torso` | `WeldConstraint` | `CFrame.new(-1.05, -0.85, 0) * CFrame.Angles(0, 0, math.rad(12))` |

---

## 4. Signature Animations Specification (`src/Track2_TowerSystem/Animations/Ace.luau`)

สไตล์ของ Ace ต้องสื่อถึง **"ผู้ใช้ผลปีศาจสายโรเกียที่มั่นใจ เท่ ลื่นไหล และระเบิดพลังความร้อนสูง (Fluid Logia Pyrokinesis & Explosive Thrust)"**:

| Animation State | Duration (Base) | Looped | Can Cancel | รายละเอียดท่าทางและคีย์เฟรม (`CFrame` Mechanics) | VFX Cue ที่ส่งออก |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **`Idle` (Logia Flame Finger Stance)** | `1.40s` | `true` | `true` | - ยืนเฉียงทำมุมสบายๆ มือซ้ายเท้าเอว (`LeftShoulder` หมุน `CFrame.Angles(math.rad(20), 0, math.rad(-25))`) มือขวายกขึ้นระดับอก (`RightShoulder` หมุน `math.rad(65)`) เลี้ยงลูกไฟเล็กๆ ที่ปลายนิ้ว ลำตัวและศีรษะขยับตามจังหวะเปลวไฟ | `"PassiveAura"` |
| **`SpecialIdle` (Hat Tip & Flame Flare)** | `1.50s` | `false` | `true` | - ยกมือซ้ายแตะปีกหมวกคาวบอย (`Neck` ก้มลง `-12 deg` แล้วเงยขึ้น) พร้อมเร่งเปลวไฟที่ไหล่ทั้งสองข้างให้ลุกโชนขึ้นชั่วครู่ | `"FlameShoulderFlare"` |
| **`Spawn` (Logia Fire Pillar Materialize)** | `0.65s` | `false` | `false` | - เริ่มจากท่าย่อเข่าก้มหน้าท่ามกลางเสาไฟ แล้วสะบัดแขนทั้งสองข้างกางออกด้านข้างเพื่อสลายม่านไฟออกด้านหลัง | `"SpawnDeploy"` |
| **`Windup` (Fire Charge — Mera Mera Ignition)** | `0.28s` | `false` | `true` | - ก้าวเท้าซ้ายนำหน้า ยกแขนซ้ายชี้เล็งไปที่เป้าหมาย (`LeftShoulder` `math.rad(90)`) ขณะที่ดึงหมัดขวา (`RightShoulder`) ถอยไปด้านหลังสีข้างขวา `CFrame.Angles(math.rad(-35), math.rad(-40), math.rad(20))` เพื่ออัดมวลเปลวไฟความร้อนสูงเข้าที่หมัดขวา | `"AttackWindup"` |
| **`Attack` (Hiken — Fire Fist Thrust)** | `0.20s` | `false` | `false` | - บิดเอว (`RootJoint` หมุน `+45 deg`) ส่งหมัดขวาพุ่งตรงไปข้างหน้าสุดแขน (`RightShoulder` หมุนเป็น `math.rad(90)`) พร้อมดึงแขนซ้ายกลับข้างลำตัว ปล่อยลำแสงและหัวหมัดเพลิงขนาดใหญ่พุ่งเข้าใส่เป้าหมาย | `"AttackRelease"` |
| **`Impact` (Hiken Detonation Hold)** | `0.15s` | `false` | `false` | - ค้างหมัดขวาที่เหยียดตรงไปข้างหน้า ลำตัวเอนถอยเล็กน้อยจากแรงอัดของเสาไฟ (`Recoil Pose`) ขณะที่ระเบิดเพลิงทำงานที่จุดปะทะ | `"AttackImpact"` |
| **`Recovery` (Flame Dissolve & Boxer Reset)** | `0.37s` | `false` | `true` | - สะบัดข้อมือขวาไล่สะเก็ดไฟแล้วดึงแขนกลับสู่ท่ายืน `Idle` อย่างนุ่มนวล | `nil` |
| **`Ultimate` (Dai Enkai: Entei — Flame Emperor)** | `2.20s` | `false` | `false` | - **Phase 1 (0.0–0.85s Great Flame Command):** Ace กางแขนทั้งสองข้างออกรับวงแหวนไฟรอบตัว แล้ว **ชูแขนขวาขึ้นตั้งฉากเหนือศีรษะ (`RightShoulder` หมุน `math.rad(175)`)** ด้วยมือข้างเดียว เงยหน้ามองลูกบอลดวงอาทิตย์เพลิง (`Entei`) ที่ขยายตัวขึ้นเหนือปลายนิ้ว<br>- **Phase 2 (0.85–1.35s Emperor Hurl):** ก้าวเท้าพร้อมเหวี่ยงแขนขวาฟาดลงมาข้างหน้า (`math.rad(175) -> math.rad(75)`) ส่งดวงอาทิตย์เพลิงพุ่งลงสู่เป้าหมาย<br>- **Phase 3 (1.35–2.20s Solar Eruption):** ยืนกอดอกหรือเท้าเอวมองการระเบิดของดวงอาทิตย์เพลิงก่อนกลับสู่ท่า `Idle` | `"UltimateCast"` -> `"UltimateImpact"` |

---

## 5. Character-Specific VFX Specification (`src/Track2_TowerSystem/VFX/AceVFX.luau`)

| VFX Cue | รายละเอียดเอฟเฟกต์ (Visual Elements) | การใช้ Instance & อายุขัย (TTL / Cleanup) | การปรับตาม Quality Preset (`Low / Med / High`) |
| :--- | :--- | :--- | :--- |
| **`PassiveAura` (Mera Mera Hand Flame & Heat Embers)** | - เปลวไฟสีส้ม-เหลืองทอง (`Colorsequence: White-Yellow -> Orange -> Crimson`) ลุกไหม้อยู่ที่ `RightHandFlameAtt` และสะเก็ดไฟลอยขึ้นจากไหล่<br>- `PointLight` สีส้มอบอุ่น (`Range = 8`, `Brightness = 1.2`) | ผูกติดกับ `RightArm` ลบหรือปิดทันทีเมื่อเรียก `stopPassiveAura` | `Low`: ปิด `PointLight` ลด `Rate` เหลือ 4<br>`Med`: `Rate = 10`<br>`High`: `Rate = 18` + สะเก็ดไฟ (`Embers`) |
| **`AttackWindup` (Swirling Fire Charge Vortex)** | - วงแหวนไฟหมุนวนรอบท่อนแขนขวา และลูกไฟสว่างจ้าขยายตัวจากขนาด `0.6` เป็น `2.2 studs` ที่หมัดขวา | TTL = `0.30s` | `Low`: ลูกไฟ 1 ชิ้น<br>`High`: ลูกไฟแกนขาว + วงแหวนเพลิงหมุนรอบแขน |
| **`AttackRelease` (Hiken Fire Fist Projectile & Flame Beam)** | - หัวหมัดเพลิงขนาดใหญ่พุ่งจากหมัดขวาของ Ace ไปยัง `ctx.targetPosition` พร้อมลำแสงเพลิง (`Beam` หรือ Tapered Cylinder) เชื่อมระหว่างหมัดกับเป้าหมาย | TTL = `0.28s` | `Low`: ลูกไฟพุ่ง 1 ชิ้น (ไม่ใช้ Beam)<br>`Med`: ลูกไฟ + Beam 1 เส้น<br>`High`: ลูกไฟ 2 ชั้น (แกนเหลือง + เปลือกส้มแดง) + Beam + Smoke Trail |
| **`AttackImpact` (Scorch Ring & Flame Pillar Burst)** | - เสาไฟพุ่งขึ้นที่จุด `ctx.targetPosition` พร้อมวงแหวนคลื่นความร้อนสีส้มแดงขยายออกแนวราบ | TTL = `0.38s` | `Low`: วงแหวนไฟ 1 ชิ้น<br>`High`: เสาไฟ + วงแหวน 2 ชั้น + Particle `:Emit(20)` |
| **`UltimateCast` & `UltimateImpact` (Dai Enkai: Entei)** | - สร้างทรงกลมดวงอาทิตย์เพลิง 2 ชั้น (`InnerCore` สีขาวเหลือง `Neon` + `OuterCorona` สีส้มแดงโปร่งแสง) ขยายขนาดขึ้นเหนือมือขวา (`Size 1.5 -> 9.0 studs`) พุ่งลงกระแทกเป้าหมายเกิดโดมระเบิดสุริยะ | TTL = `1.60s`, จำกัดจำนวน Part ไม่เกิน 14 ชิ้น | `Low`: ทรงกลมชั้นเดียว ไม่เปิด `PointLight` / Screen Flash<br>`High`: ทรงกลม 2 ชั้น + วงแหวนไฟที่พื้น (`Dai Enkai`) + Screen Flash สีส้มทอง |

---

## 6. Step-by-Step Implementation Tasks (Developer 3)

1. **Task A-1 (Model & Accessory Rig Preparation):**
   - ตรวจสอบ `Ace.rbxmx` แยก `CowboyHat` ให้ยึดกับ `Head` และ `RedBeadNecklace` / `HipDagger` ให้ยึดกับ `Torso`
   - เพิ่ม `RightHandFlameAtt`, `LeftHandFlameAtt`, และ `OverheadEnteiAtt`
2. **Task A-2 (Implement `src/Track2_TowerSystem/Animations/Ace.luau`):**
   - สร้าง `CharacterAnimationProfile` ของ Ace พร้อม Keyframes สำหรับ `Idle`, `SpecialIdle`, `Spawn`, `Windup` (`Fire Charge`), `Attack` (`Fire Punch / Hiken`), `Impact`, `Recovery`, และ `Ultimate` (`Entei`)
3. **Task A-3 (Implement `src/Track2_TowerSystem/VFX/AceVFX.luau`):**
   - สร้างเอฟเฟกต์ไฟทั้งหมดโดยใช้ `ctx.registerInstance` และ `ctx.registerTween`
   - ควบคุม `ParticleEmitter` ให้ใช้ `:Emit(count)` สำหรับจังหวะระเบิด (`AttackImpact`, `UltimateImpact`) แทนการเปิด `Enabled = true` ทิ้งไว้ เพื่อป้องกัน Particle ค้าง
4. **Task A-4 (Write Automated Spec `tests/characters/ace_anim_vfx.spec.luau`):**
   - ทดสอบว่า `CowboyHat` เคลื่อนที่ตาม `Head` เมื่อ `Neck.C0` เปลี่ยนค่า
   - ทดสอบว่า `Ultimate` (`Entei`) และ `Attack` (`Hiken`) เคลียร์ Instance ทั้งหมดเหลือ `0` หลังจบ TTL หรือเมื่อเรียก `cleanupAllForModel`

---

## 7. File Ownership, Visual Acceptance Criteria & Risks

- **Owned Files:** `assets/rojo/HeroModels/Ace.rbxmx`, `src/Track2_TowerSystem/Animations/Ace.luau`, `src/Track2_TowerSystem/VFX/AceVFX.luau`, `tests/characters/ace_anim_vfx.spec.luau`
- **Visual Acceptance Criteria (ต้องตรวจใน Animation Lab):**
  1. หมวกคาวบอยสีส้มต้องขยับตามศีรษะทุกครั้งที่ Ace ก้มหรือเงยหน้า
  2. จังหวะ `Windup` (`Fire Charge`) ต้องเห็นการดึงหมัดขวาไปชาร์จไฟด้านหลัง และในจังหวะ `Attack` (`Fire Punch`) ลำแสงไฟต้องพุ่งเข้าหาตำแหน่ง `Dummy Target` อย่างแม่นยำ
  3. ท่า `Ultimate` (`Entei`) ต้องเห็นลูกไฟดวงอาทิตย์ก่อตัวขึ้นเหนือมือขวาที่ชูขึ้นก่อนพุ่งลงไปยังเป้าหมาย
- **Known Risks:** หากวาง Tower Ace หลายตัวพร้อมกันแล้วทุกตัวเปิด `PointLight` และ `ParticleEmitter` ความหนาแน่นสูง อาจทำให้ GPU Frame Time สูงขึ้น **วิธีแก้:** ใน `AceVFX.luau` ให้ผูกจำนวน Particle กับ `VFXContract.QUALITY_MULTIPLIERS[ctx.quality]` และปิด `PointLight` อัตโนมัติเมื่ออยู่ในโหมด `Low` หรือเมื่อจำนวน Active VFX รวมเกินเพดาน


---

## 8. ข้อกำหนดร่วมและจุดส่งตรวจ

- Joint C0/C1 ในตารางเป็นค่าออกแบบตั้งต้น ต้องคำนวณ pivot จาก model จริงและบันทึก rest ของทุก subpart/attachment ก่อนเปลี่ยน; ท่าเล่นด้วย rest * offset ไม่สะสมค่าจากเฟรมก่อน
- canonical limb อาจเป็น semantic pivot ที่ควบคุมหลาย geometry parts; rig builder ต้องคืนข้อมูล missing/ambiguous mapping ไม่สร้าง joint สำเร็จปลอมเมื่อไม่พบ limb
- Cancel/Destroy/Stop เป็น hard cleanup เสมอ แม้ state ระบุ canCancel=false สำหรับ normal playback; คืนสี/Size/C0/C1/transparency/attachment offset ที่ถูกเปลี่ยน
- cue ใน SpecialIdle เช่น NikaLaughPuff/EnmaChargePulse/FlameShoulderFlare ต้องกำหนด extension ใน shared contract ก่อนใช้; ไม่แก้ contract จาก character stream
- ทุก resource ต้องเข้า owner ledger; เรียก cleanup ซ้ำได้โดยไม่ double-count; passive aura ไม่ถูกสร้างซ้ำทุก frame/cue
- การตรวจ joints ต้องเทียบ CFrame ชิ้นที่เห็นจริงหลัง engine step โดย root คงที่; เปลี่ยนค่า Motor6D.C0 อย่างเดียวไม่พิสูจน์ mobility
- ตรวจครบ 8 states ตาม design, animation-only / VFX-only / combo, Low/Medium/High, 0.1x/1x/2x, seek ไปกลับ, reset ขณะกลางท่า และ destroy ระหว่าง VFX
- ผลส่งมอบรายตัว: diff ตาม owned paths, actual ref/base, test command+exit, Studio runtime observations, visual checklist และ known limitations; อนุญาต commit+push เฉพาะ milestone ของตัวละครตาม HANDOFF ล่าสุด; ไม่มีสิทธิ์ปิดงานเอง
- งานย่อยที่ใช้ส่งต่อคือ A-01..04 ใน [tasks](../tasks.md) ซึ่งระบุ dependency/AC ชัดกว่ารายการ Task เดิมด้านบน

## 9. Code blueprint ต้นทาง

ดู [Master Pack](../../../../requirement/phase5/phase_5_master_plan_and_agent_pack.md) บรรทัด 1919–2311 สำหรับพิมพ์เขียวอ้างอิงเดิม ไม่คัดลอก implementation ยาวมาสร้างเป็น src ในรอบนี้ ตัวอย่างยังไม่ใช่ verified production code และยังขาดบาง implementation/harness; ต้องยึด contract ที่อนุมัติภายหลังเป็นหลัก
