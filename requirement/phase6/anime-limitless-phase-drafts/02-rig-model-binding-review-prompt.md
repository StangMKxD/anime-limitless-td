# P02 — Semantic Rig และ Model Binding ที่ขยับ geometry จริง

สถานะ: DRAFT / REVIEW ONLY / IMPLEMENTATION NOT AUTHORIZED  
Baseline: main @ 5d0caed21aa61021790a3456cda322d16445edea | วันที่: 17 ตุลาคม 2026 (Asia/Bangkok)  
Requirements: R-02, R-07  
Plan Owner: Stang | Controller/Reviewer: Codex | Proposed implementer: AGY Teamwork-preview (ยังไม่มอบหมาย)  
ไม่มี application tests หรือ Studio/manual verification ในรอบนี้; ผล runtime ทั้งหมด NOT VERIFIED  
อ่าน [Integration & Contract Review](00-integration-contract-review.md) และ [HANDOFF กลาง](assets/HANDOFF.md) ก่อนเสมอ

## 1. เป้าหมาย

ทำให้โมเดลที่เห็นในเกมและ Lab ใช้ข้อต่อที่ตรงกับ profile และขยับชิ้นส่วนจริงอย่างถูกต้อง หมวก/เมฆ/ลูกปัดติดส่วนร่างกายที่ถูก ดาบ Zoro ทั้งสามเล่มตามมือ/ปาก และ reset แล้วไม่มี drift โดยคงรายละเอียด assets เดิม

การมี Motor6D หรือ RigReady=true ยังไม่ใช่หลักฐานว่า rig ใช้ได้ ต้องตรวจปลายทาง Part0/Part1, rigid graph และ geometry movement

## 2. Baseline ที่ต้องเคารพ

- [XML Luffy](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/assets/rojo/HeroModels/Luffy.rbxmx), [Zoro](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/assets/rojo/HeroModels/Zoro.rbxmx), [Ace](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/assets/rojo/HeroModels/Ace.rbxmx) เป็น Part models 122/139/128 Parts ไม่มี baked bones/joints
- [Live loader](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track2_TowerSystem/TowerController.server.luau#L686) สร้าง limb anchors เอง; NeckJoint ไม่ตรง Neck canonical; heuristic จัดชิ้นส่วนอยู่ :813–853
- [AnimationController](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track2_TowerSystem/AnimationController.luau#L187) มี sanitation/binding อีกเส้นทาง แต่ live loader ไม่เรียกตาม F-03
- [VisualBridge](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/AssetKit/VisualBridge.server.luau#L114) ติด skin แบบ root weld สำหรับ route ที่ไม่ได้ Track2RigOwned ต้องไม่กลายเป็นอีก writer ทับ canonical rig
- นี่เป็นข้อสังเกตจาก source ไม่ใช่การยืนยันว่าข้อต่อทุกตัวใน Studio ผิด

## 3. Ownership และขอบเขต

P02 เสนอสร้างเพียง src/Presentation/RigBinder.luau, src/Presentation/RigDiagnostics.luau และ tests/planning-followup/rig/  
existing AnimationController, TowerController, VisualBridge, Shared contracts และ mapping ให้ Integration lead แก้ wiring ตามคำขอของ P02 เมื่อรวมงาน  
raw assets/rojo/** และ generator scripts เป็น read-only; ห้ามแก้ XML เพื่อให้ test counts ผ่าน

In scope: semantic part grouping, Motor6D hierarchy, accessory/weapon attachments, rest snapshot, validation, idempotent cleanup บน clone  
Out of scope: combat AI, damage, target selection, physics ของ enemy root, geometry reduction, เพิ่ม hero catalog หรือ reauthor assets ทั้งชุดเป็น skinned mesh

## 4. Binding contract และข้อมูลที่ต้องตรวจ

ใช้ C-01 ในไฟล์ integration เป็นผู้กำหนดชื่อสัญญา; P02 ส่งข้อมูลประกอบให้ freeze ก่อนสร้าง consumer

| กลุ่ม | ความสัมพันธ์ที่ต้องพิสูจน์ |
|---|---|
| Root/Torso | logical root ไม่ถูกย้ายจาก binder; visual root/torso ขยับได้ตาม RootJoint ที่ตกลง |
| Head | Neck เชื่อม torso→head; hair/hat/face/cloud ที่เป็น head accessories ไม่หลุด |
| Arms | RightShoulder/LeftShoulder ขยับ upperarm/forearm/fist ทั้งกลุ่ม |
| Legs | RightHip/LeftHip ขยับ thigh/shin/foot และเสื้อผ้าที่ควรตามขา |
| Zoro | WeaponRight/WeaponLeft/WeaponMouth จับดาบครบทุก segment ไม่ชี้ชิ้นสุดท้ายที่ชื่อ match |
| Attachments | root/fist/head/cloud, blade base/tip, flame/Entei anchor อยู่บน part ที่ถูกและ reset ได้ |
| Static maps | ไม่สร้าง humanoid rig, report STATIC_MAP_ASSET / N/A |

ห้ามใช้ _2 แปลว่า right โดยไม่มีการตรวจ geometry และแกน local ของ template จริง  
Accessory และ sword segments ใช้ explicit map ที่ audit ได้; ambiguous/unmapped parts ต้องขึ้น report ไม่ซ่อนปัญหาด้วย weld ทุกอย่างเข้า root  
ห้าม weld ข้าม animated joint จนเกิด rigid path ล็อกแขน/หัว/ดาบ และห้ามลบ weld ทุกชนิดแบบกวาดจน asset แตก

## 5. งานย่อยที่เสนอหลังอนุมัติ

| Task | ผลส่งมอบ | เกณฑ์ตรวจ |
|---|---|---|
| P02-01 | inventory จาก 19 template IDs แยก raw parts/bones/motors/static status | อ้าง XML จริง ไม่ใช้ notes เดิมเป็นผลตรวจใหม่ |
| P02-02 | semantic binding map แรกสำหรับ Luffy/Zoro/Ace พร้อม ambiguous names/coordinates | ระบุครบ limb/accessory/weapon groups ก่อนเขียน binder |
| P02-03 | RigBinder clone-only + context/rest snapshot + Destroy | Bind สองครั้ง joint count คงที่; static map ไม่ถูกแปลง |
| P02-04 | rigid-graph diagnostics และ movement probe แบบทีละ joint | ขยับ joint แล้ว geometry กลุ่มที่ถูกเปลี่ยน CFrame; root และกลุ่มอื่นไม่ผิด |
| P02-05 | รองรับ 5 playable heroes ที่เหลือและ 4 enemy templates ด้วย fallback safe binding | ห้ามเปลี่ยน enemy movement controller; unsupported รายงานตามจริง |
| P02-06 | ส่ง integration adapter design ให้ live loader และ Lab ใช้ binder เดียว | ไม่มี double rig/skins/joint writers; readiness set หลัง validation เท่านั้น |
| P02-07 | regression/lifecycle evidence และ proposed docs amendments | Codex ตรวจ scope/spec delta ก่อน sync |

ความเข้ากันได้ 9 heroes ที่ไม่ใช่ signature รวมทั้ง 4 ตัวที่ไม่อยู่ playable catalog หมายถึงตรวจ asset preview/fallback ไม่เปิดให้สุ่มเล่นเพิ่มเอง

## 6. วิธีตรวจในอนาคตที่มีความหมาย

- วัด world CFrame ของ forearm/fist/sword tip และ accessory ก่อน/หลัง joint step; ไม่ assert เพียงว่ามี Motor6D ชื่อถูก
- แยก rigid connectivity graph ของ root→limb และตรวจไม่มี weld path ลัดผ่าน Motor6D ที่ต้องขยับ
- เปรียบเทียบ bind ก่อน/หลัง rebind และ cleanup: motors/welds/attachments ไม่เพิ่มซ้ำ
- ใช้หน้าตัด front/side/back เพื่อตรวจหมวก ดาบคาบปาก ผ้าคลุม และตำแหน่งปลายหมัด
- Stop/Replay/Seek/Scale 50 รอบตาม requirement เดิม: C0/C1/Size/attachments คืน snapshot; tolerance <0.001 ตามเกณฑ์เดิม พร้อมแยก angular tolerance ที่ต้องตกลงวิธีวัด
- missing part, duplicate name, invalid PrimaryPart, unknown hero, malformed template ต้องคืน structured report ไม่ mark ready
- ทดสอบ destroy ระหว่าง bind และ model swap/revision เดิมถูกยกเลิก โดยไม่ทำลาย template
- ตรวจ raw BasePart count ยังคง 122/139/128 สำหรับสาม signatures; runtime helper parts แยกนับ ไม่ใช้ budget เดียวปะปน

การเปลี่ยน C0 กับ Transform มี replication ต่างกัน หาก P03 เลือก Transform บน client ให้พิสูจน์หลาย clients ห้ามคาดว่า server Transform replicate เอง ดู [Motor6D](https://create.roblox.com/docs/reference/engine/classes/Motor6D)

## 7. Dependencies / rollback / gate

P02 ใช้ C-01 ที่ freeze แล้ว ทำขนาน P01/P05/P06 ได้; P03/P04 เริ่ม integration จริงหลัง joint/attachment map นี้นิ่ง  
หาก live server root motion มีผลต่อ target distance ต้องส่งประเด็น D-05 ให้ Integration ไม่แก้ root/targeting ใน binder  
rollback ให้ client renderer กลับ baseline visual route ด้วย Integration hooks โดยไม่ลบหรือคืน raw XML ที่ไม่ได้แก้

ครบ Phase เมื่อผู้ตรวจเห็น actual moving geometry และ cleanup evidence; ไม่ครบเพียงเพราะ exported API หรือ test mock ผ่าน

## 8. Copy-ready prompt สำหรับ AGY — review only

~~~text
ตรวจและปรับร่าง P02 เท่านั้น ยังไม่ implement
อ่านกติกาโปรเจกต์, AnimationContract, source ของ live loader/AnimationController/VisualBridge,
XML ของ assets ที่เกี่ยวข้อง และ 00-integration-contract-review.md
ส่ง semantic part/joint/attachment matrix โดยใช้ชื่อและ geometry จริง
อธิบายเหตุที่เส้นทาง legacy กับ Phase5 ไม่เชื่อม และเสนอ binder กลาง clone-only
ระบุ files ของ P02 แยกจาก integration files, validation error model, mobility evidence plan และ rollback
ตรวจความจำเป็นของ Bone เทียบ multipart Motor6D โดยไม่สมมติว่าต้อง reauthor assets
ห้ามเปลี่ยน code/config/assets/docs หลัก, รัน application tests, spawn, commit หรือ push
ถ้าต้องเพิ่ม scope ให้เสนอ CR พร้อมผลต่อ gameplay; ส่งแผนกลับให้ผู้ใช้และ Codex รีวิว
~~~

