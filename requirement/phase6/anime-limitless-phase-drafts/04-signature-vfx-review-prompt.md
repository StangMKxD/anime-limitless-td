# P04 — Signature VFX, Impact Readability และ Resource Lifecycle

สถานะ: DRAFT / REVIEW ONLY / IMPLEMENTATION NOT AUTHORIZED  
Baseline: main @ 5d0caed21aa61021790a3456cda322d16445edea | วันที่: 17 ตุลาคม 2026 (Asia/Bangkok)  
Requirements: R-03, R-04, R-07  
Plan Owner: Stang | Controller/Reviewer: Codex | Proposed implementer: AGY Teamwork-preview (ยังไม่มอบหมาย)  
ไม่มี application tests หรือ Studio/manual verification ในรอบนี้; ผล runtime ทั้งหมด NOT VERIFIED  
อ่าน [Integration & Contract Review](00-integration-contract-review.md) และ [HANDOFF กลาง](assets/HANDOFF.md) ก่อนเสมอ

## 1. เป้าหมายที่ตรวจได้

เอฟเฟกต์ช่วยเสริมความแรงและเอกลักษณ์ของการโจมตี: หมัดมี compression/impact, ดาบมี trails ตามปลายใบดาบ, เปลวไฟมีการชาร์จและแตกตัว แต่ยังมองเห็นศัตรู เส้นทาง จุดวาง HP และ UI และไม่กินทรัพยากรสะสมหลังขายยูนิตหรือปิด Lab

ไม่ใช้การเพิ่ม particle จำนวนมากหรือ screen flash ทุกจังหวะเป็นเกณฑ์ความสวย ต้องตรวจเป็น shot ที่มี anticipation→release→contact→dissipation ชัดเจน

## 2. Baseline / จุดที่ต้องอ่าน

- [VFXContract](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Shared/VFXContract.luau#L100) มี common/character cues, layers และ execution context
- [VFXDispatcher](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track2_TowerSystem/VFXDispatcher.luau#L252) มี context/quality/ledger; ตรวจจริงว่า registration/TTL/cancellation ทำงาน ไม่เชื่อตาม comment
- origin/target fallback อยู่ที่ :293–295; live ต้องส่ง target snapshot จริง ไม่ยิงไป LookVector*15 เมื่อมีเป้า
- [Legacy attack](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track2_TowerSystem/TowerController.server.luau#L1992) ส่ง shake และ VFX อีกระบบอยู่; ต้องกำหนด cutover ป้องกัน effects ซ้ำ
- [HUD camera code](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track3_UISystem/UpgradeHUD.client.luau#L237) เป็นผู้เขียน CurrentCamera เดิม; P04 ห้ามสร้าง camera loop แย่งเอง

## 3. Ownership

แก้ในอนาคตเฉพาะ src/Track2_TowerSystem/VFXDispatcher.luau และ VFX/LuffyVFX.luau, ZoroVFX.luau, AceVFX.luau, _FallbackVFX.luau รวม tests/planning-followup/vfx/  
หากอีก 5 heroes ต้องแยก module ใหม่ ให้ขอ exact-file expansion ก่อน; ร่างฐานใช้ ID-specific branches/presets ใน fallback ที่ตนเป็นเจ้าของ  
VFXContract, AnimationRegistry, TowerController, mapping, camera feedback port เป็น Integration owner  
ไม่แก้ P03 animation profile หรือ P02 binder เพื่อทำ VFX ง่ายขึ้น; missing attachment ต้องส่ง finding ให้เจ้าของ

## 4. Art direction / shot matrix ที่เสนอ

| ตัวละคร / ชุด | Windup | Release / Contact | Dissipation / ข้อห้าม |
|---|---|---|---|
| Luffy | white cloud puff, black-red haki เกาะแขน | stretch speed accents ตามหมัดจริง, impact ring/แรงอัดแยก foreground | ฝุ่นจางเร็ว, ไม่ให้ neon sphere แทนหมัด |
| Zoro | emerald-purple Enma charge ที่อาวุธ | trails 3 เส้นตาม BladeBase/Tip, slash arcs สอดคล้องทิศดาบ | sparks ช่วง contact, ไม่ beam ยิงจาก torso |
| Ace | flame lick ที่มือ/ไหล่, heat distortion แบบพออ่าน | Hiken flame plume ตาม thrust; Entei sunball เฉพาะ cue ที่อนุมัติ | embers dissipate, ไม่มีก้อนไฟค้างนอก ledger |
| Shanks | haki gathering บน Gryphon | red-black cut path และ burst บน snapshot | จำกัด screen occupation, ไม่มี damage เพิ่ม |
| Whitebeard | air fracture ก่อน hit | quake crack/radial dust ที่ contact | cracks มี TTL และไม่เปลี่ยน map collision |
| Law | surgical ring/room contour | thin cut distortion ตรงปลายอาวุธ | ไม่ทำ full-screen filter ค้าง |
| Kizaru | compact golden streak | light trail ของ limb/weapon + localized flash | ไม่สาด beam ทั้งแผนที่ทุก hit |
| Sanji | blue-white flame รอบเท้า | curved kick arc/speed ring ที่ปลายเท้า | sparks/heat trail ไม่ติดตามตำแหน่งเก่า |

อีก 5 heroes ใช้ compact signature presets; ความละเอียด batch1 ยังคงโฟกัส Luffy/Zoro/Ace  
sound design/asset upload IDs ใหม่ไม่อยู่ใน scope ฐาน หากเสนอให้ระบุสิทธิ์/ที่มาและ CR ก่อน ไม่ fabricate asset IDs

## 5. Contract freeze ที่ต้องใช้

ใช้ C-03: cue, sourceModel, originCFrame, targetPosition, optional targetModel, intensity, quality, layerFlags และ resource registration  
P03 เป็นผู้ส่ง cue; P04 เป็นผู้ consume; duplicate key=(attackId,cue,ordinal) ต้องไม่ spawn ซ้ำ  
seek/scrub ไม่ emit gameplay impact effects; explicit manual TriggerVFX ใน Lab เป็น preview เท่านั้น  
client culling/Low quality/disabled layers ห้ามส่งผลต่อ server timer หรือการหัก HP

quality Low/Medium/High มีค่าตั้งต้นใน contract เดิม (เช่น maxParts 8/16/30) ต้องตรวจและระบุว่าตัวใดเป็น per-cue/per-model/global ห้ามอ้าง total budget ใหม่โดยไม่คลี่คลาย hierarchy  
ห้ามลด requirement P5-R09 เพื่อให้ผลผ่าน; target ใหม่/quality default/device tiers เป็นข้อเสนอรออนุมัติ

## 6. งานย่อยที่เสนอหลังอนุมัติ

| Task | งาน / ผลส่งมอบ | เกณฑ์ตรวจ |
|---|---|---|
| P04-01 | ตรวจ cue/attachment/preset/legacy effects inventory | ไม่มี missing owner; แยก client-safe กับ server-only dependency |
| P04-02 | storyboard แสง สี การบังหน้าจอ และระดับ quality ต่อ cue | ผู้ใช้เห็น art direction ก่อนเพิ่มจำนวน instances |
| P04-03 | ปรับ dispatcher lifecycle/dedup/quality ceilings | ทุก resource ลงทะเบียน, close/destroy ซ้ำไม่ error |
| P04-04 | Luffy/Zoro/Ace signature slice | cues ตาม geometry และ target snapshot จริง |
| P04-05 | compact signature presets อีก 5 playable heroes | อ่านเอกลักษณ์ได้; fallback ไม่เปลี่ยน damage |
| P04-06 | connect C-03 camera feedback และ layer preferences | HUD/Lab camera owner มีรายเดียว; reduced motion/flash ทำงาน |
| P04-07 | stress/cleanup benchmark + proposed docs amendments | actual device/ref/window/quality, ไม่มี fabricated FPS |

## 7. Resource ownership และ failure cases

- register Instance, Tween, Task, Connection และ callback ทุกชนิด; Debris เป็น fallback ไม่แทน model ownership
- close Lab/sell/recall/respawn/map teardown/model revision change → owner cleanup และ invalidate pending callbacks
- lifecycle calls idempotent; instance ที่ TTL หมดแล้วไม่ถูก decrement ซ้ำจาก Destroying
- pooled objects ถ้ามี ต้องแยก in-use กับ retained pool; ไม่เรียก retained pool ว่า zero leak โดยไม่มี bounded cap
- VFX errors ต้องถูก isolate ไม่ throw กลับจน server attack ถูกข้าม; new local visual RNG แยกจาก combat RNG
- การย้าย legacy random calls ออกจาก server ต้องผ่าน D-05 audit ก่อน ไม่อ้าง balance preserved จาก seed อย่างเดียว
- layer Off ต้องหยุด resource ที่ยังสร้างต่อเนื่องด้วย ไม่ซ่อนแค่ transparency
- distance culling และ LOD drop visual ได้; ห้าม suppress server events/damage
- placement pad/range ring/enemy healthbar อยู่เหนือ art priorities; VFX ไม่เพิ่ม collision/query/touch ที่แย่งการคลิก

## 8. Verification plan ในอนาคต

1. เล่น attack เดียวของ 3 signatures มุม front/side/back; trail อยู่กับอาวุธและจุด contact ไม่เลื่อนจาก snapshot
2. แยกเปิดแต่ละ 6 layers แล้วปิดคืน; ledger และภาพเปลี่ยนตามที่กด
3. Quality Low/Medium/High ใช้ cue เดียวกัน วัด peak parts/particles/lights/tweens จริง
4. 1/10/25/50 units ใน Lab ใช้เกณฑ์ existing PRD และระบุว่า stress แยกจาก cap gameplay 8 pads
5. เก็บ avg/p95/peak frame time, client vs server แยก, warmup/sample window/device/resolution/quality; ไม่มีเครื่องที่ตรงให้ NOT VERIFIED
6. ทำ spawn→cue spam→destroy 50 รอบ รอ TTL ที่กำหนด แล้วตรวจ instance/connection/task deltas เทียบ baseline
7. ปิด/throw VFX ทุกชนิดระหว่าง live attack → damage/crit/rewards/timing traces เดิมจาก Integration
8. เปิด Lab ระหว่าง shake แล้ว close → camera ไม่ drift และไม่มี flash ค้าง
9. ตรวจ effect footprint ในหลาย maps และ HUD mobile ไม่บังปุ่มสำคัญ
10. ผลความสวยต้องมี named manual observer/ref หรือระบุ ManualVisual NOT VERIFIED; ไม่บังคับ screenshot/video

## 9. Dependencies / rollback

ทำคู่ P03 ได้หลัง P02 joints/attachments และ C-03 freeze  
P01 ใช้ cue inspector; P05 เป็น camera/flash feedback sink ตามสัญญาที่ล็อก; P04 ไม่เขียน HUD file  
Integration ทำ cutover ระหว่าง legacy VFX กับใหม่ทีละ route ป้องกัน effect/shake ซ้ำ  
rollback ปิด new visual event consumer คืน legacy route ตาม approved baseline โดยไม่รีเซ็ต gameplay state

## 10. Copy-ready prompt สำหรับ AGY — review only

~~~text
รีวิวร่าง P04 และเสนอ VFX plan แบบตรวจผลได้ ยังไม่ implement
อ่าน VFXContract/Dispatcher/modules ปัจจุบัน, legacy VFX และ HUD camera code ตาม SHA ที่อ้าง
ส่ง shot matrix, cue/attachment dependency, quality hierarchy, resource lifecycle,
camera feedback ownership และ stress/cleanup evidence plan
ชี้จุดที่ runtime ยังไม่ได้เรียก VFX ใหม่และความเสี่ยง effect ซ้ำ/RNG consumption
คงสูตรเกม, damage timing, hero catalog และ protected files เดิม
ห้ามแก้ code/config/assets/docs หลัก, รัน application tests, spawn agents, commit หรือ push
ส่งผลเป็นข้อเสนอพร้อมประเด็นตัดสินใจให้ผู้ใช้และ Codex ตรวจ
~~~

