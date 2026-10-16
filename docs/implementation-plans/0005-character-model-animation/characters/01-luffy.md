# Character Implementation Plan 01 — Luffy Gear 5 (`Luffy.rbxmx`)

> **IMPLEMENTATION AUTHORIZED / NOT STARTED:** ผู้ใช้ให้ AGY ทำ Phase5 ทั้งหมดแล้วส่ง Codex รีวิวรวมตอนท้าย อ่าน [HANDOFF ล่าสุด](../assets/HANDOFF.md), [PLAN](../PLAN.md), [tasks](../tasks.md) และ [contracts](../assets/contracts-and-integration.md) ก่อน; ไม่มีผล spec/Studio หรือการรับรอง visual แล้ว


- **Document ID:** `0005-character-model-animation/characters/01-luffy.md`
- **Implementer ที่เสนอ:** AGY-Char-Luffy — ยังไม่มอบหมาย session
- **Branch:** ยังไม่สร้าง; ชื่อตาม Master Pack เป็นข้อเสนออนาคตเท่านั้น
- **Worktree:** ยังไม่สร้างและยังไม่อนุมัติในรอบนี้
- **Target Model:** assets/rojo/HeroModels/Luffy.rbxmx
- **Verification Status:** `NOT VERIFIED` (Planning Stage Only)

---

## 1. Existing Model Analysis — ตรวจจาก baseline จริง

- [CONFIRMED] assets/rojo/HeroModels/Luffy.rbxmx มี 122 BaseParts, 122 Anchored parts, 0 serialized Motor6D และ 0 Weld/WeldConstraint; เป็นผลอ่าน XML ไม่ใช่ผลเล่น Studio
- ชื่อ Part ที่พบจริง: `HumanoidRootPart`, `Torso`, `Head`, `HeadTopBevel`, `UpperArm`, `Forearm`, `Fist`, `UpperArm_2`, `Forearm_2`, `Fist_2`, `Thigh`, `Shin`, `Boot`, `BootToe`, `Thigh_2`, `Shin_2`, `Boot_2`, `BootToe_2`, `StrawHatBrim`, `StrawHatDome`, `StrawHatRedBand`, `HakiBusoFist`
- geometry ใช้กลุ่ม UpperArm/Forearm/Fist และชื่อ _2 หลายชิ้น ไม่ได้มี LeftArm/RightArm/LeftLeg/RightLeg เป็น rig ครบตามตารางปลายทาง การจับซ้าย/ขวาต้องดู local coordinates/geometry ไม่เดาจาก _2 อย่างเดียว
- ประเด็น VisualBridge clone skin ซ้อน / hideLegacyParts และ runtime joints ดู [notes](../notes.md); อาการที่เห็นในเกมและ actual mobility ยัง NOT VERIFIED
- ส่วน 2–7 ต่อไปเป็น TARGET DESIGN จาก Master Pack ไม่ใช่คำบรรยายสิ่งที่มีแล้ว; Part cap 22 เป็นข้อเสนอที่ขัด baseline และถูกกั้นด้วย D-04 ห้ามลบรายละเอียดเพื่อให้ผ่านตัวเลขโดยไม่มีอนุมัติ

---

## 2. Model Improvement Requirements (ปรับปรุงจากโมเดลเดิม ไม่สร้างใหม่ทั้งหมดโดยไม่จำเป็น)

1. **เอกลักษณ์และสีสันของ Luffy Gear 5:**
   - **ทรงผมและคิ้ว (`HairMesh` / `HairParts`):** ปรับสีเป็นสีขาวบริสุทธิ์ (`Color3.fromRGB(248, 248, 255)`) Material = `Neon` (หรือ `SmoothPlastic` ผสาน `Highlight` ขอบขาวนวล) รูปทรงพริ้วเหมือนเปลวเมฆ
   - **ดวงตาและรอยยิ้ม (`FaceDecal` / `EyeParts`):** ดวงตาสีแดงทับทิมวงแหวน (`Color3.fromRGB(220, 40, 60)`) พร้อมรอยยิ้มกว้างแบบ Nika
   - **เสื้อกั๊กและกางเกงขาสั้น (`Torso`, `LeftLeg`, `RightLeg`):** เสื้อและกางเกงสีขาว (`Color3.fromRGB(240, 240, 245)`) คาดด้วยผ้าคาดเอวสีม่วงเข้ม (`Sash`, `Color3.fromRGB(115, 60, 165)`)
   - **หมวกฟางสะพายหลัง (`StrawHat`):** หมวกฟางสีเหลืองทองคาดแถบแดง คล้องเชือกสะพายไว้ด้านหลังคอ (ยึดติดกับ `Torso` ด้วยมุมเอียง `CFrame.Angles(math.rad(-55), 0, 0)` เพื่อให้กระเด้งตามจังหวะลำตัว)
   - **ผ้าคลุมเมฆตื่นรู้ (`CloudScarf`):** สร้างจาก `Part` ทรง `Ball` / `Cylinder` สีขาวนวล (`Material = SmoothPlastic`, `Transparency = 0.08`) เรียงโค้งเป็นวงรอบไหล่และด้านหลังคอ จำนวนไม่เกิน 5 ชิ้นย่อย (เพื่อคุม Draw Calls)
2. **งบประมาณจำนวนชิ้นส่วน (Part & Draw Call Budget):**
   - จำนวน `BasePart` ทั้งหมดของ `Luffy.rbxmx` มี **เป้าหมายเดิมไม่เกิน 22 Parts — PENDING D-04; ยังไม่ใช่ cap ที่อนุมัติ** (Core Limbs 7 + StrawHat 2 + Sash 1 + Hair/Scarf 8–12)
   - ทุก Part ยกเว้น `HumanoidRootPart` ต้องตั้งค่า:
     - `Anchored = false`
     - `CanCollide = false`
     - `CanTouch = false`
     - `CanQuery = false`
     - `Massless = true`

---

## 3. Rig Mapping & Joint Specification

### 3.1 ตาราง `Motor6D` ทั้ง 6 ข้อต่อหลัก
| Joint Name (`AnimationContract`) | `Part0` (Parent) | `Part1` (Child) | `BaseC0` (Rest Pose Offset บน `Part0`) | `BaseC1` (Pivot Offset บน `Part1`) | หน้าที่ในการเคลื่อนไหว |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`RootJoint`** | `HumanoidRootPart` | `Torso` | `CFrame.new(0, 0, 0)` | `CFrame.new(0, 0, 0)` | ควบคุมการเด้งขึ้น-ลง (Joyboy Bounce), การเอนตัวไปด้านหลังตอนง้างหมัด และการพุ่งตัว |
| **`Neck`** | `Torso` | `Head` | `CFrame.new(0, 1.5, 0)` | `CFrame.new(0, -0.5, 0)` | ควบคุมการแหงนหัวหัวเราะและการหันมองเป้าหมาย |
| **`RightShoulder`** | `Torso` | `RightArm` | `CFrame.new(1.5, 0.5, 0)` | `CFrame.new(0, 0.5, 0)` | **ข้อต่อหลักสำหรับ `Stretch Punch` และ `Bajrang Fist`** (หมุนหัวไหล่ + เลื่อนตำแหน่งยืดแขน) |
| **`LeftShoulder`** | `Torso` | `LeftArm` | `CFrame.new(-1.5, 0.5, 0)` | `CFrame.new(0, 0.5, 0)` | ยกมือป้องหน้า/เท้าเอว หรือยกมือประคองตอนปล่อยพลัง |
| **`RightHip`** | `Torso` | `RightLeg` | `CFrame.new(0.5, -1.0, 0)` | `CFrame.new(0, 1.0, 0)` | ย่อเข่าและกระโดดลอยตัวในท่า Gear 5 |
| **`LeftHip`** | `Torso` | `LeftLeg` | `CFrame.new(-0.5, -1.0, 0)` | `CFrame.new(0, 1.0, 0)` | ย่อเข่าสลับจังหวะเด้งตัวในท่า Idle |

### 3.2 ตารางการยึด Accessories (`accessoryRules`)
| ชื่อชิ้นส่วน Accessory | ยึดเข้ากับ (`attachToLimb`) | ชนิดการเชื่อมต่อ | ค่า Offset มาตรฐาน |
| :--- | :--- | :--- | :--- |
| `StrawHat` (หมวกฟางสะพายหลัง) | `Torso` | `WeldConstraint` | `CFrame.new(0, 0.85, 0.75) * CFrame.Angles(math.rad(-60), 0, 0)` |
| `CloudScarf` (วงเมฆรอบไหล่) | `Torso` | `WeldConstraint` | `CFrame.new(0, 1.15, 0.15)` |
| `WaistSash` (ผ้าคาดเอวสีม่วง) | `Torso` | `WeldConstraint` | `CFrame.new(0, -0.85, 0)` |
| `HairCloud` (ผมสีขาว Gear 5) | `Head` | `WeldConstraint` | `CFrame.new(0, 0.65, 0.05)` |

---

## 4. Signature Animations Specification (`src/Track2_TowerSystem/Animations/Luffy.luau`)

ตัวละคร Luffy Gear 5 ต้องแสดงความรู้สึก **"อิสระ ยืดหยุ่น กระเด้งเหมือนการ์ตูน (Toon Rubber Physics)"** แตกต่างจากนักดาบอย่าง Zoro หรือผู้ใช้ไฟอย่าง Ace อย่างชัดเจน:

| Animation State | Duration (Base) | Looped | Can Cancel | รายละเอียดท่าทางและคีย์เฟรม (`CFrame` & `Scale` Mechanics) | VFX Cue ที่ส่งออก |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **`Idle` (Gear 5 Joyboy Bounce)** | `1.20s` | `true` | `true` | - `alpha 0.0 -> 0.5`: `RootJoint` ลอยตัวขึ้น `+0.45 studs` พร้อมเอียงตัวเบาๆ `CFrame.Angles(math.rad(6), 0, math.rad(4))`, เข่าทั้งสองข้าง (`RightHip`, `LeftHip`) งอขึ้นแบบก้าวกระโดดในอากาศ แขนสองข้างแกว่งเป็นจังหวะกลองแห่งการปลดปล่อย<br>- `alpha 0.5 -> 1.0`: ลงสู่จังหวะย่อตัวพร้อมดีดตัวขึ้นใหม่ | `"PassiveAura"` |
| **`SpecialIdle` (Nika Belly Laugh)** | `1.80s` | `false` | `true` | - เอนตัวไปด้านหลัง `RootJoint` หมุน `math.rad(25)` มือซ้ายกุมท้อง มือขวาบังหน้าผาก ศีรษะแหงนหัวเราะสั่นขึ้นลง 3 จังหวะ | `"NikaLaughPuff"` |
| **`Spawn` (Sky Bounce Drop)** | `0.65s` | `false` | `false` | - เริ่มจาก `RootJoint` สูง `+6.0 studs` พุ่งลงมากระแทกพื้นแล้วยืดหดตัวแบบยาง (`Squash & Stretch`) ก่อนดีดกลับสู่ท่า `Idle` | `"SpawnDeploy"` |
| **`Windup` (Rubber Arm Coil Back)** | `0.25s` | `false` | `true` | - บิดลำตัว `RootJoint` ไปทางขวา `-35 deg` ดึง `RightShoulder` ถอยไปด้านหลังลำตัว `CFrame.new(0.4, 0, 1.8) * CFrame.Angles(math.rad(90), 0, math.rad(25))` พร้อมบิดเกลียวแขนและเคลือบฮาคิสีดำ-แดงที่หมัดขวา | `"AttackWindup"` |
| **`Attack` (Gomu Gomu no Stretch Punch)** | `0.20s` | `false` | `false` | - บิดลำตัวกลับด้านหน้า `+30 deg` พร้อม **ยืดความยาวของ `RightArm`** ออกไปหาเป้าหมาย (`Stretch Factor` คำนวณจากระยะห่างแต่จำกัดไม่เกิน `14 studs` ใน Visual) โดยเลื่อน `RightShoulder.C0` ไปด้านหน้า `CFrame.new(0, 0, -stretchLen * 0.5)` และขยายขนาดหมัดส่วนปลาย (`scaleMultiplier = Vector3.new(1.8, 1.8, stretchScaleZ)`) | `"AttackRelease"` |
| **`Impact` (Haki Rubber Snap)** | `0.15s` | `false` | `false` | - หมัดขวาหยุดค้างที่จุดปะทะพร้อมสั่น (`Micro-Vibration`) 2 เฟรม เพื่อเน้นแรงกระแทก (Hit-Stop Feel) ในจังหวะเดียวกับที่สายฟ้าฮาคิราชันย์ระเบิดออกที่เป้าหมาย | `"AttackImpact"` |
| **`Recovery` (Elastic Snap-Back)** | `0.40s` | `false` | `true` | - แขนขวาหดกลับด้วย `Enum.EasingStyle.Elastic` (`Out`) คืนขนาด `RightArm.Size` เดิม 100% และหมุนไหล่กลับสู่ `RestPose` | `nil` |
| **`Ultimate` (Bajrang Fist — Island-Sized God Fist)** | `2.10s` | `false` | `false` | - **Phase 1 (0.0–0.7s Ascend & Inflate):** Luffy ลอยตัวสูงขึ้น (`RootJoint +4.5 studs`) ชูแขนขวาขึ้นเหนือหัว สร้างทรงกลมหมัดยักษ์เคลือบฮาคิ (`BajrangFistConstruct`) เหนือเมฆ<br>- **Phase 2 (0.7–1.3s God Slam):** เหวี่ยงแขนขวาทุบลงมาด้านหน้าด้วยความเร็วสูง<br>- **Phase 3 (1.3–2.1s Shockwave & Rebound):** พื้นยุบเกิดคลื่นเมฆขาวและสายฟ้าดำ-แดงก่อนดีดตัวกลับลงมายืน | `"UltimateCast"` -> `"UltimateImpact"` |

---

## 5. Character-Specific VFX Specification (`src/Track2_TowerSystem/VFX/LuffyVFX.luau`)

| VFX Cue | รายละเอียดเอฟเฟกต์ (Visual Elements) | การใช้ Instance & อายุขัย (TTL / Cleanup) | การปรับตาม Quality Preset (`Low / Med / High`) |
| :--- | :--- | :--- | :--- |
| **`PassiveAura` (Drums of Liberation Cloud & Sparks)** | - ละอองเมฆสีขาวนวลลอยขึ้นรอบตัว (`Rate = 6` บน High)<br>- ประกายสายฟ้าสีแดง-ดำขนาดเล็กแลบเป็นระยะรอบหมัดขวา | ผูกกับ `Torso` และ `RightArm` ลบออกทันทีเมื่อ `cleanupAllForModel` ถูกเรียก | `Low`: ปิดสายฟ้ารอบหมัด เหลือเฉพาะ Highlight ขอบขาว<br>`Med`: เปิดเมฆ 50%<br>`High`: เปิดครบทุกเลเยอร์ |
| **`AttackWindup` (Armament + Conqueror Charge)** | - เปลี่ยนสีส่วนปลายหมัดขวาเป็นสีดำเงาขอบแดง (`Highlight` หรือ `MeshPart` Overlay) พร้อมวงแหวนอัดอากาศสีขาวที่ข้อศอก | TTL = `0.30s` (ผ่าน `ctx.registerInstance`) | `Low`: 1 Part<br>`Med`: 2 Parts<br>`High`: 3 Parts + Particle Burst 8 เม็ด |
| **`AttackRelease` (Rubber Sonic Rings)** | - วงแหวนอากาศสีขาว (`Cylinder/Ring Part` โปร่งแสง `Transparency 0.3 -> 1.0`) เรียงตามแนวแขนที่ยืดออกไป 2–3 วง | TTL = `0.25s` ขยายขนาดแล้วจางหายด้วย Tracked Tween | `Low`: 1 วง<br>`Med`: 2 วง<br>`High`: 3 วง + Beam เส้นแรงดึงยาง |
| **`AttackImpact` (Conqueror Haki Black-Red Lightning Burst)** | - เส้นสายฟ้าหยักสีดำแกนแดงเข้ม (`Color3.fromRGB(200, 20, 40)` + ขอบดำ) พุ่งกระจายออกจากจุด `targetPosition` 3–5 แฉก พร้อมวงกระแทกพื้นสีขาว | TTL = `0.35s`, สร้างที่พิกัด `ctx.targetPosition` | `Low`: วงกระแทก 1 ชิ้น + สายฟ้า 2 เส้น<br>`Med`: สายฟ้า 3 เส้น<br>`High`: สายฟ้า 5 เส้น + `:Emit(16)` + Subtle Camera Impulse |
| **`UltimateCast` & `UltimateImpact` (Bajrang Fist)** | - สร้างทรงกลมเมฆหมุนวนและหมัดยักษ์สีดำ-แดงเหนือศีรษะ (`Size = Vector3.new(8, 8, 8)`) พุ่งลงกระแทกจุดเป้าหมาย เกิดโดมคลื่นกระแทกสีขาวและสายฟ้าฮาคิราชันย์ขนาดใหญ่ | TTL = `1.50s` จำกัดจำนวน Part สูงสุดไม่เกิน 14 ชิ้นต่อการกด Ultimate 1 ครั้ง | `Low`: ลดจำนวนสายฟ้าเหลือ 4 เส้น ไม่ทำ Screen Flash<br>`High`: เต็มรูปแบบพร้อม Screen Flash สีขาว-แดง `0.12s` |

---

## 6. Step-by-Step Implementation Tasks (Developer 1)

1. **Task L-1 (Model & Rig Preparation):**
   - ตรวจสอบ `Luffy.rbxmx` ตั้งชื่ออวัยวะหลักให้ตรงตามมาตรฐาน (`HumanoidRootPart`, `Torso`, `Head`, `RightArm`, `LeftArm`, `RightLeg`, `LeftLeg`)
   - จัดกลุ่มชิ้นส่วน `StrawHat`, `CloudScarf`, `WaistSash`, `HairCloud` และตั้งค่า `Anchored = false`, `CanCollide = false`, `Massless = true`
2. **Task L-2 (Implement `src/Track2_TowerSystem/Animations/Luffy.luau`):**
   - สร้าง `CharacterAnimationProfile` ตาม `AnimationContract.luau`
   - เขียนตาราง Keyframes ของทั้ง 8 States (`Idle`, `SpecialIdle`, `Spawn`, `Windup`, `Attack`, `Impact`, `Recovery`, `Ultimate`) พร้อมฟังก์ชันคำนวณการยืดหดแขนขวา (`RightShoulder` + `RightArm` scale restoration)
3. **Task L-3 (Implement `src/Track2_TowerSystem/VFX/LuffyVFX.luau`):**
   - สร้างฟังก์ชัน `startPassiveAura`, `stopPassiveAura`, `triggerCue`, และ `cleanupAllForModel` ตาม `VFXContract.luau`
   - ทุก Part และ Tween ต้องลงทะเบียนผ่าน `ctx.registerInstance` และ `ctx.registerTween` เท่านั้น
4. **Task L-4 (Write Automated Spec `tests/characters/luffy_anim_vfx.spec.luau`):**
   - ทดสอบว่าเมื่อโหลด `Luffy.luau` และสร้าง Rig บนโมเดลจำลอง ข้อต่อทั้ง 6 ขยับเปลี่ยน `C0` ได้จริง
   - ทดสอบว่าหลังจบเฟส `Attack -> Recovery` ขนาดของ `RightArm.Size` และ `RightShoulder.C0` กลับคืนค่าตั้งต้น 100% (ความคลาดเคลื่อน `< 0.001`)
   - ทดสอบว่า `cleanupAllForModel` ล้าง VFX Instance เหลือ `0`

---

## 7. File Ownership, Visual Acceptance Criteria & Risks

- **Owned Files:** `assets/rojo/HeroModels/Luffy.rbxmx`, `src/Track2_TowerSystem/Animations/Luffy.luau`, `src/Track2_TowerSystem/VFX/LuffyVFX.luau`, `tests/characters/luffy_anim_vfx.spec.luau`
- **Visual Acceptance Criteria (ต้องตรวจใน Animation Lab):**
  1. ในท่า `Idle` ตัวของ Luffy ต้องเด้งขึ้น-ลงอย่างมีชีวิตชีวาและผ้าคลุมเมฆ + หมวกฟางต้องขยับตามลำตัวโดยไม่ลอยค้าง
  2. ในท่า `Attack` แขนขวาต้องยืดพุ่งไปข้างหน้าโดยโคนแขนยังติดอยู่กับหัวไหล่ และหดกลับมาขนาดเดิมทันทีในเฟส `Recovery` แม้จะกด Cancel หรือเปลี่ยนความเร็วเป็น `2.0x`
  3. เอฟเฟกต์สายฟ้าฮาคิราชันย์สีดำ-แดงต้องเกิดตรงตำแหน่ง `Dummy Target` พอดีในเฟส `Impact`
- **Known Risks:** หากโดน Cancel กลางจังหวะ `Attack` ที่แขนกำลังยืดอยู่ ถ้าไม่รีเซ็ต `RightArm.Size` ในฟังก์ชัน `ResetPose()` แขนจะค้างยาวผิดปกติ **วิธีแก้:** บันทึก `OriginalRightArmSize` ไว้ใน `RigContext` และคืนค่าทุกครั้งที่มีการเปลี่ยน State หรือ `ResetPose()`


---

## 8. ข้อกำหนดร่วมและจุดส่งตรวจ

- Joint C0/C1 ในตารางเป็นค่าออกแบบตั้งต้น ต้องคำนวณ pivot จาก model จริงและบันทึก rest ของทุก subpart/attachment ก่อนเปลี่ยน; ท่าเล่นด้วย rest * offset ไม่สะสมค่าจากเฟรมก่อน
- canonical limb อาจเป็น semantic pivot ที่ควบคุมหลาย geometry parts; rig builder ต้องคืนข้อมูล missing/ambiguous mapping ไม่สร้าง joint สำเร็จปลอมเมื่อไม่พบ limb
- Cancel/Destroy/Stop เป็น hard cleanup เสมอ แม้ state ระบุ canCancel=false สำหรับ normal playback; คืนสี/Size/C0/C1/transparency/attachment offset ที่ถูกเปลี่ยน
- cue ใน SpecialIdle เช่น NikaLaughPuff/EnmaChargePulse/FlameShoulderFlare ต้องกำหนด extension ใน shared contract ก่อนใช้; ไม่แก้ contract จาก character stream
- ทุก resource ต้องเข้า owner ledger; เรียก cleanup ซ้ำได้โดยไม่ double-count; passive aura ไม่ถูกสร้างซ้ำทุก frame/cue
- การตรวจ joints ต้องเทียบ CFrame ชิ้นที่เห็นจริงหลัง engine step โดย root คงที่; เปลี่ยนค่า Motor6D.C0 อย่างเดียวไม่พิสูจน์ mobility
- ตรวจครบ 8 states ตาม design, animation-only / VFX-only / combo, Low/Medium/High, 0.1x/1x/2x, seek ไปกลับ, reset ขณะกลางท่า และ destroy ระหว่าง VFX
- ผลส่งมอบรายตัว: diff ตาม owned paths, actual ref/base, test command+exit, Studio runtime observations, visual checklist และ known limitations; ไม่มีสิทธิ์ commit หรือปิดงานเอง
- งานย่อยที่ใช้ส่งต่อคือ L-01..04 ใน [tasks](../tasks.md) ซึ่งระบุ dependency/AC ชัดกว่ารายการ Task เดิมด้านบน

## 9. Code blueprint ต้นทาง

ดู [Master Pack](../../../../requirement/phase5/phase_5_master_plan_and_agent_pack.md) บรรทัด 930–1500 สำหรับพิมพ์เขียวอ้างอิงเดิม ไม่คัดลอก implementation ยาวมาสร้างเป็น src ในรอบนี้ ตัวอย่างยังไม่ใช่ verified production code และยังขาดบาง implementation/harness; ต้องยึด contract ที่อนุมัติภายหลังเป็นหลัก
