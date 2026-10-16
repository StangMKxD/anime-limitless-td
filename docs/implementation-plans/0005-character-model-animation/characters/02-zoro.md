# Character Implementation Plan 02 — Zoro King of Hell (`Zoro.rbxmx`)

> **IMPLEMENTATION AUTHORIZED / NOT STARTED:** ผู้ใช้ให้ AGY ทำ Phase5 ทั้งหมดแล้วส่ง Codex รีวิวรวมตอนท้าย อ่าน [HANDOFF ล่าสุด](../assets/HANDOFF.md), [PLAN](../PLAN.md), [tasks](../tasks.md) และ [contracts](../assets/contracts-and-integration.md) ก่อน; ไม่มีผล spec/Studio หรือการรับรอง visual แล้ว


- **Document ID:** `0005-character-model-animation/characters/02-zoro.md`
- **Implementer ที่เสนอ:** AGY-Char-Zoro — ยังไม่มอบหมาย session
- **Branch:** ยังไม่สร้าง; ชื่อตาม Master Pack เป็นข้อเสนออนาคตเท่านั้น
- **Worktree:** ยังไม่สร้างและยังไม่อนุมัติในรอบนี้
- **Target Model:** assets/rojo/HeroModels/Zoro.rbxmx
- **Verification Status:** `NOT VERIFIED` (Planning Stage Only)

---

## 1. Existing Model Analysis — ตรวจจาก baseline จริง

- [CONFIRMED] assets/rojo/HeroModels/Zoro.rbxmx มี 139 BaseParts, 139 Anchored parts, 0 serialized Motor6D และ 0 Weld/WeldConstraint; เป็นผลอ่าน XML ไม่ใช่ผลเล่น Studio
- ชื่อ Part ที่พบจริง: `HumanoidRootPart`, `Torso`, `Head`, `HeadTopBevel`, `UpperArm`, `Forearm`, `Fist`, `UpperArm_2`, `Forearm_2`, `Fist_2`, `Thigh`, `Shin`, `Boot`, `BootToe`, `Thigh_2`, `Shin_2`, `Boot_2`, `BootToe_2`, `WadoIchimonji_Hilt`, `WadoIchimonji_HiltWrap_1`, `WadoIchimonji_HiltWrap_2`, `WadoIchimonji_HiltWrap_3`, `WadoIchimonji_HiltWrap_4`, `WadoIchimonji_Pommel`, `WadoIchimonji_TsubaGuard`, `WadoIchimonji_Blade_Seg1`, `WadoIchimonji_Blade_Seg2`, `WadoIchimonji_Blade_Seg3`, `WadoIchimonji_Blade_Seg4`, `Enma_Hilt`, `Enma_HiltWrap_1`, `Enma_HiltWrap_2`, `Enma_HiltWrap_3`, `Enma_HiltWrap_4`, `Enma_Pommel`, `Enma_TsubaGuard`, `Enma_Blade_Seg1`, `Enma_Blade_Seg2`, `Enma_Blade_Seg3`, `Enma_Blade_Seg4`, `Enma_HakiFlame_1`, `Enma_HakiFlame_2`, `Enma_HakiFlame_3`, `Enma_HakiFlame_4`, `Enma_HakiFlame_5`, `SandaiKitetsu_Hilt`, `SandaiKitetsu_HiltWrap_1`, `SandaiKitetsu_HiltWrap_2`, `SandaiKitetsu_HiltWrap_3`, `SandaiKitetsu_HiltWrap_4`, `SandaiKitetsu_Pommel`, `SandaiKitetsu_TsubaGuard`, `SandaiKitetsu_Blade_Seg1`, `SandaiKitetsu_Blade_Seg2`, `SandaiKitetsu_Blade_Seg3`, `SandaiKitetsu_Blade_Seg4`, `SandaiKitetsu_HakiFlame_1`, `SandaiKitetsu_HakiFlame_2`, `SandaiKitetsu_HakiFlame_3`, `SandaiKitetsu_HakiFlame_4`, `SandaiKitetsu_HakiFlame_5`
- geometry ใช้กลุ่ม UpperArm/Forearm/Fist และชื่อ _2 หลายชิ้น ไม่ได้มี LeftArm/RightArm/LeftLeg/RightLeg เป็น rig ครบตามตารางปลายทาง การจับซ้าย/ขวาต้องดู local coordinates/geometry ไม่เดาจาก _2 อย่างเดียว
- ประเด็น VisualBridge clone skin ซ้อน / hideLegacyParts และ runtime joints ดู [notes](../notes.md); อาการที่เห็นในเกมและ actual mobility ยัง NOT VERIFIED
- ส่วน 2–7 ต่อไปเป็น TARGET DESIGN จาก Master Pack ไม่ใช่คำบรรยายสิ่งที่มีแล้ว; Part cap 24 เป็นข้อเสนอที่ขัด baseline และถูกกั้นด้วย D-04 ห้ามลบรายละเอียดเพื่อให้ผ่านตัวเลขโดยไม่มีอนุมัติ

---

## 2. Model Improvement Requirements

1. **เอกลักษณ์ของ Zoro (King of Hell / Onigashima Coat Style):**
   - **ทรงผมและผ้าโพกหัว (`HairParts` / `Bandana`):** ผมสีเขียวสด (`Color3.fromRGB(60, 185, 95)`) หรือโหมดสวมผ้าโพกหัวสีดำเข้มพร้อมแผลเป็นที่ตาซ้าย
   - **ชุดคลุมสีดำคาดแดง (`Torso`, `Legs`):** เสื้อคลุมยาวสีดำเข้ม เปิดอกเห็นรอยแผลเป็นพาดขวาง คาดด้วยผ้าคาดเอวสีแดงเข้ม (`Color3.fromRGB(180, 30, 35)`)
   - **ดาบทั้ง 3 เล่ม (Three-Sword Precision Modeling):**
     - `WadoIchimonji` (ดาบปลอก/ด้ามสีขาว): คาบไว้ที่ปากในแนวนอน (`Part0 = Head`)
     - `Enma` (ดาบด้ามสีม่วงเข้มประดับทอง): ถือในมือขวา (`Part0 = RightArm`) พร้อมจุด Attachment `BladeTip` และ `BladeBase` สำหรับผูก `Trail` และไฟฮาคิสีเขียว-ม่วง
     - `SandaiKitetsu` (ดาบด้ามสีแดงเข้ม): ถือในมือซ้าย (`Part0 = LeftArm`) พร้อมจุด Attachment `BladeTip` และ `BladeBase` สำหรับผูก `Trail`
     - `SwordScabbards` (ฝักดาบ 3 เล่มมัดรวมกัน): ยึดติดข้างเอวขวา (`Part0 = Torso`)
2. **งบประมาณจำนวนชิ้นส่วน (Part & Draw Call Budget):**
   - จำนวน `BasePart` ทั้งหมดของ `Zoro.rbxmx` มี **เป้าหมายเดิมไม่เกิน 24 Parts — PENDING D-04; ยังไม่ใช่ cap ที่อนุมัติ** (Core Limbs 7 + ดาบ 3 เล่มๆ ละ 3 Parts = 9 + ฝักดาบ 3 + ผม/ผ้าคาดเอว 5)
   - ทุก Part ยกเว้น `HumanoidRootPart` ต้องมี `Anchored = false`, `CanCollide = false`, `CanTouch = false`, `CanQuery = false`, `Massless = true`

---

## 3. Rig Mapping & 3-Sword Joint Specification

### 3.1 ตาราง `Motor6D` ทั้ง 9 ข้อต่อ (6 Body Joints + 3 Weapon Joints)
| Joint Name (`AnimationContract`) | `Part0` (Parent) | `Part1` (Child) | `BaseC0` (Rest Pose Offset) | `BaseC1` (Pivot Offset) | หน้าที่ในการเคลื่อนไหว |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`RootJoint`** | `HumanoidRootPart` | `Torso` | `CFrame.new(0, 0, 0)` | `CFrame.new(0, 0, 0)` | ย่อตัวต่ำตั้งท่าดาบ พุ่งตัวเฉียงไปข้างหน้า และหมุนตัว 360 องศาตอนฟันพายุ |
| **`Neck`** | `Torso` | `Head` | `CFrame.new(0, 1.5, 0)` | `CFrame.new(0, -0.5, 0)` | หันศีรษะสะบัดดาบ `WadoIchimonji` ที่คาบอยู่ให้ฟันตามจังหวะไหล่ |
| **`RightShoulder`** | `Torso` | `RightArm` | `CFrame.new(1.5, 0.5, 0)` | `CFrame.new(0, 0.5, 0)` | ง้างดาบ `Enma` ไขว้หน้าอกและฟันกวาดเป็นแนวทแยง |
| **`LeftShoulder`** | `Torso` | `LeftArm` | `CFrame.new(-1.5, 0.5, 0)` | `CFrame.new(0, 0.5, 0)` | ง้างดาบ `SandaiKitetsu` ขนานกับแขนขวาและฟันประสาน |
| **`RightHip`** | `Torso` | `RightLeg` | `CFrame.new(0.5, -1.0, 0)` | `CFrame.new(0, 1.0, 0)` | ก้าวเท้าขวาไปด้านหน้าเพื่อรับน้ำหนักตัว (Forward Lunge Stance) |
| **`LeftHip`** | `Torso` | `LeftLeg` | `CFrame.new(-0.5, -1.0, 0)` | `CFrame.new(0, 1.0, 0)` | ยันเท้าซ้ายด้านหลังเป็นหลักส่งแรงพุ่ง |
| **`WeaponRight`** | `RightArm` | `EnmaHandle` | `CFrame.new(0, -1.0, -0.2) * CFrame.Angles(math.rad(-90), 0, 0)` | `CFrame.new(0, 0, 0)` | หมุนข้อมือขวาปรับมุมคมดาบ `Enma` (เช่น ควงดาบหรือตั้งดาบขนานแขนในท่า Oni Giri) |
| **`WeaponLeft`** | `LeftArm` | `SandaiHandle` | `CFrame.new(0, -1.0, -0.2) * CFrame.Angles(math.rad(-90), 0, 0)` | `CFrame.new(0, 0, 0)` | หมุนข้อมือซ้ายปรับมุมคมดาบ `SandaiKitetsu` |
| **`WeaponMouth`** | `Head` | `WadoHandle` | `CFrame.new(0, -0.25, -0.55) * CFrame.Angles(0, 0, math.rad(90))` | `CFrame.new(0, 0, 0)` | ยึดดาบ `WadoIchimonji` ขวางปากและปรับองศาเล็กน้อยตอนสะบัดคอฟัน |

---

## 4. Signature Animations Specification (`src/Track2_TowerSystem/Animations/Zoro.luau`)

สไตล์ของ Zoro ต้องเน้นความ **"คม ดุดัน รวดเร็ว และมีน้ำหนักของการไขว้ดาบ (Sharp Martial Precision & Snap)"**:

| Animation State | Duration (Base) | Looped | Can Cancel | รายละเอียดท่าทางและคีย์เฟรม (`CFrame` Mechanics) | VFX Cue ที่ส่งออก |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **`Idle` (Santoryu Combat Guard)** | `1.50s` | `true` | `true` | - ย่อตัวต่ำเล็กน้อย (`RootJoint` `Y = -0.15`) บิดลำตัวเฉียง `20 deg` แขนขวาและแขนซ้ายกางดาบออกด้านข้างลำตัวระดับเอว หายใจเข้า-ออกอย่างสุขุม คมดาบเรืองแสงฮาคิเบาๆ | `"PassiveAura"` |
| **`SpecialIdle` (Enma Haki Tame)** | `1.60s` | `false` | `true` | - ยกแขนขวา (`RightShoulder`) ขึ้นมาด้านหน้าสายตา หมุน `WeaponRight` ให้ใบดาบ `Enma` ตั้งขึ้น ดูดซับออร่าสีเขียว-ม่วงเข้าสู่ใบดาบแล้วสะบัดลง | `"EnmaChargePulse"` |
| **`Spawn` (Three-Sword Unsheathe)** | `0.60s` | `false` | `false` | - เริ่มจากท่าไขว้แขนที่เอว แล้วสะบัดแขนทั้งสองข้างชักดาบออกเป็นรูปกากบาท (`X-Cross`) พร้อมประกายแสงคมดาบ | `"SpawnDeploy"` |
| **`Windup` (Oni Giri Cross-Arm Stance)** | `0.26s` | `false` | `true` | - ย่อเข่าต่ำ (`RootJoint` `Y = -0.35`, เอนหน้า `-18 deg`) **ไขว้แขนขวาและแขนซ้ายทับกันที่หน้าอก** (`RightShoulder` หมุนเข้าใน `-55 deg`, `LeftShoulder` หมุนเข้าใน `+55 deg`) หันใบดาบทั้งสองชี้ไปด้านหลัง พร้อมคาบดาบที่สามแน่น | `"AttackWindup"` |
| **`Attack` (King of Hell Cross Slash)** | `0.18s` | `false` | `false` | - พุ่งลำตัวไปข้างหน้า (`RootJoint` เลื่อน `Z = -1.8 studs`) พร้อม **สะบัดแขนทั้งสองข้างกางออกด้านข้างด้วยความเร็วสูง** (`Enum.EasingStyle.Exponential`, `Out`) และหมุนคอ (`Neck`) ฟันดาบที่ปากตามแนวขวาง เกิดคลื่นดาบ 3 เส้นพุ่งเข้าหาเป้าหมาย | `"AttackRelease"` |
| **`Impact` (Triple Blade Sever)** | `0.16s` | `false` | `false` | - ค้างท่ากางดาบสุดแขน (`Follow-through Pose`) ขณะที่รอยฟันกากบาทสีเขียว-ทองระเบิดขึ้นที่ตัวเป้าหมาย | `"AttackImpact"` |
| **`Recovery` (Blade Flourish & Reset)** | `0.40s` | `false` | `true` | - หมุนข้อมือ (`WeaponRight`, `WeaponLeft`) ครึ่งรอบแล้วดึงลำตัวถอยกลับสู่จุดยืนพร้อมตั้งการ์ด `Idle` | `nil` |
| **`Ultimate` (King of Hell: 103 Mercies Dragon Damnation)** | `2.00s` | `false` | `false` | - **Phase 1 (0.0–0.65s King of Hell Awakening):** ตั้งดาบทั้ง 3 เล่มขนาบลำตัว เปลวไฟฮาคิสีเขียวมรกตและสายฟ้าสีม่วง-ทองลุกโชนท่วมดาบทั้ง 3 เล่ม<br>- **Phase 2 (0.65–1.25s Dragon Twister Dash):** หมุนตัวพุ่งฟันเป็นเกลียวพายุ (`RootJoint` หมุน `720 deg` อย่างรวดเร็ว) แล้วฟันผ่าลงมาจากกลางอากาศ<br>- **Phase 3 (1.25–2.00s Sheathe Pose):** ยืนหันข้างค้างท่าเท่ขณะคลื่นดาบมังกรเขียวมรกตระเบิดกลางกลุ่มศัตรู | `"UltimateCast"` -> `"UltimateImpact"` |

---

## 5. Character-Specific VFX Specification (`src/Track2_TowerSystem/VFX/ZoroVFX.luau`)

| VFX Cue | รายละเอียดเอฟเฟกต์ (Visual Elements) | การใช้ Instance & อายุขัย (TTL / Cleanup) | การปรับตาม Quality Preset (`Low / Med / High`) |
| :--- | :--- | :--- | :--- |
| **`PassiveAura` (King of Hell Emerald Smoke & Haki)** | - เปลวควันไฟสีเขียวมรกต (`Color3.fromRGB(40, 235, 120)`) ลอยออกจากใบดาบทั้ง 3 เล่ม<br>- ใบดาบเคลือบสีดำมันวาว (`Armament Haki`) | ผูกกับ Attachment บนดาบทั้ง 3 เล่ม ปิดการทำงานทันทีเมื่อไม่ได้อยู่ในโหมดแสดงผล | `Low`: เปิดเฉพาะสีใบดาบฮาคิ<br>`Med`: เปิดไฟสีเขียวที่ดาบ `Enma`<br>`High`: เปิดครบทั้ง 3 เล่ม + ประกายสายฟ้าสีม่วงทอง |
| **`AttackWindup` (Triple Blade Glint)** | - แสงแฟลร์รูปดาวสี่แฉกสีเขียว-ทองสว่างวาบที่โคนดาบทั้ง 3 เล่มขณะไขว้แขนหน้าอก พร้อมเปิด `Trail` ของดาบทั้ง 3 เล่ม (`Trail.Enabled = true`) | TTL = `0.26s` | `Low`: เปิด `Trail` เฉพาะดาบขวา<br>`Med/High`: เปิด `Trail` ครบทั้ง 3 เล่ม |
| **`AttackRelease` (Santoryu Crescent Slash Arcs)** | - คลื่นดาบรูปพระจันทร์เสี้ยว 3 เส้น (สีเขียวมรกตขอบดำ-ทอง) พุ่งออกจากตัว Zoro ไปยัง `ctx.targetPosition` | TTL = `0.30s`, ปิด `Trail.Enabled = false` เมื่อจบเฟส `Attack` | `Low`: คลื่นดาบ 1 ชิ้น<br>`Med`: คลื่นดาบ 2 ชิ้น<br>`High`: คลื่นดาบ 3 ชิ้นซ้อนกันพร้อมเส้นลมเฉือน |
| **`AttackImpact` (3-Slash X-Cross Sever)** | - รอยฟันคมกริบ 3 เส้นตัดกันที่ตำแหน่ง `ctx.targetPosition` พร้อมประกายไฟฮาคิสีเขียว-ม่วงกระเด็นออก | TTL = `0.32s` | `Low`: รอยฟัน 2 ชิ้น<br>`High`: รอยฟัน 3 ชิ้น + Particle `:Emit(14)` |
| **`UltimateCast` & `UltimateImpact` (103 Mercies Dragon Slash)** | - พายุเกลียวสีเขียวมรกตหมุนรอบตัว Zoro ก่อนพุ่งเป็นคลื่นดาบยักษ์ผ่าเป้าหมาย พร้อมสายฟ้าสีเขียว-ทองและดำแดง | TTL = `1.40s`, จำกัดจำนวน Part ไม่เกิน 15 ชิ้น | `Low`: ลดจำนวนวงเกลียวพายุเหลือ 3 ชิ้น<br>`High`: เต็มรูปแบบพร้อม Camera Shake แนวเฉียง |

---

## 6. Step-by-Step Implementation Tasks (Developer 2)

1. **Task Z-1 (Model & 3-Sword Rig Preparation):**
   - ตรวจสอบ `Zoro.rbxmx` แยกชิ้นส่วนดาบทั้ง 3 เล่มให้มี Handle Part ชัดเจน (`EnmaHandle`, `SandaiHandle`, `WadoHandle`) พร้อม `Attachment0` (โคนดาบ) และ `Attachment1` (ปลายดาบ) สำหรับ `Trail`
   - ตั้งค่า `Anchored = false`, `CanCollide = false`, `Massless = true` ให้ทุกชิ้นส่วนยกเว้น `HumanoidRootPart`
2. **Task Z-2 (Implement `src/Track2_TowerSystem/Animations/Zoro.luau`):**
   - สร้าง `CharacterAnimationProfile` ที่มีครบ 9 ข้อต่อ (`RootJoint`, `Neck`, `RightShoulder`, `LeftShoulder`, `RightHip`, `LeftHip`, `WeaponRight`, `WeaponLeft`, `WeaponMouth`)
   - เขียน Keyframes ของท่าตั้งการ์ด, ท่าไขว้แขน `Oni Giri`, ท่าพุ่งฟัน และท่าไม้ตาย `King of Hell`
3. **Task Z-3 (Implement `src/Track2_TowerSystem/VFX/ZoroVFX.luau`):**
   - จัดการการเปิด/ปิด `Trail` บนดาบทั้ง 3 เล่มอย่างปลอดภัย (รับประกันว่าเมื่อถูก Cancel หรือจบเฟส `Attack` ตัว `Trail.Enabled` จะถูกตั้งเป็น `false` เสมอ ไม่ลากเส้นค้างตอนยืน Idle)
4. **Task Z-4 (Write Automated Spec `tests/characters/zoro_anim_vfx.spec.luau`):**
   - ทดสอบว่าดาบทั้ง 3 เล่มเคลื่อนที่ตาม `RightArm`, `LeftArm`, และ `Head` จริงเมื่อเปลี่ยนค่า `Motor6D.C0`
   - ทดสอบว่าหลังจบ `Attack` หรือเมื่อเรียก `cleanupAllForModel` ตัว `Trail.Enabled` ของดาบทั้ง 3 เล่มเป็น `false` เสมอ

---

## 7. File Ownership, Visual Acceptance Criteria & Risks

- **Owned Files:** `assets/rojo/HeroModels/Zoro.rbxmx`, `src/Track2_TowerSystem/Animations/Zoro.luau`, `src/Track2_TowerSystem/VFX/ZoroVFX.luau`, `tests/characters/zoro_anim_vfx.spec.luau`
- **Visual Acceptance Criteria (ต้องตรวจใน Animation Lab):**
  1. ดาบทั้ง 3 เล่มต้องติดอยู่กับมือขวา มือซ้าย และปากอย่างแม่นยำในทุกเฟรมของการขยับ ไม่ลอยแยกออกจากมือ
  2. ในจังหวะ `Windup -> Attack` ต้องเห็นการไขว้แขนหน้าอกแล้วสะบัดฟันออกพร้อมรอย `Trail` สีเขียว-ทองชัดเจน
  3. เมื่อหยุดเล่นท่า (`Stop` หรือกลับสู่ `Idle`) เส้น `Trail` ต้องหยุดลากทันที
- **Known Risks:** หาก `Attachment0` และ `Attachment1` บนใบดาบวางตำแหน่งสลับแกนกัน `Trail` จะแบนเป็นเส้นบางมองไม่เห็น **วิธีแก้:** กำหนดให้ `Attachment0` อยู่ที่ด้ามดาบ `(0, 0, -0.5)` และ `Attachment1` อยู่ที่ปลายดาบ `(0, 0, -4.0)` พร้อมตั้ง `Trail.FaceCamera = true`


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
- งานย่อยที่ใช้ส่งต่อคือ Z-01..04 ใน [tasks](../tasks.md) ซึ่งระบุ dependency/AC ชัดกว่ารายการ Task เดิมด้านบน

## 9. Code blueprint ต้นทาง

ดู [Master Pack](../../../../requirement/phase5/phase_5_master_plan_and_agent_pack.md) บรรทัด 1505–1914 สำหรับพิมพ์เขียวอ้างอิงเดิม ไม่คัดลอก implementation ยาวมาสร้างเป็น src ในรอบนี้ ตัวอย่างยังไม่ใช่ verified production code และยังขาดบาง implementation/harness; ต้องยึด contract ที่อนุมัติภายหลังเป็นหลัก
