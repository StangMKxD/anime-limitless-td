# P03 — Character-specific Melee Dash / Strikes และ Animation Playback

สถานะ: DRAFT / REVIEW ONLY / IMPLEMENTATION NOT AUTHORIZED  
Baseline: main @ 5d0caed21aa61021790a3456cda322d16445edea | วันที่: 17 ตุลาคม 2026 (Asia/Bangkok)  
Requirements: R-02, R-03, R-07  
Plan Owner: Stang | Controller/Reviewer: Codex | Proposed implementer: AGY Teamwork-preview (ยังไม่มอบหมาย)  
ไม่มี application tests หรือ Studio/manual verification ในรอบนี้; ผล runtime ทั้งหมด NOT VERIFIED  
อ่าน [Integration & Contract Review](00-integration-contract-review.md) และ [HANDOFF กลาง](assets/HANDOFF.md) ก่อนเสมอ

## 1. ภาพที่ต้องการ

ผู้เล่นเห็นตัวละครออกท่าจริง: Luffy ยืดหมัด, Zoro พุ่งฟันสามดาบ, Sanji บิดสะโพกเตะ และแต่ละตัวมี stance/recovery ของตนเอง เมื่อปิด VFX ยังอ่านทิศทาง น้ำหนัก และช่วงสัมผัสเป้าหมายจากร่างกายได้ ไม่ใช้การยิงลูกพลังหรือ beam สีต่างกันเป็นตัวแทนท่าประชิดทั้งหมด

ตัวที่มีอาวุธ/พลังระยะไกลตามเอกลักษณ์ยังใช้ slash wave, light หรือไฟได้ แต่ต้องเห็นท่าร่างกายเป็นต้นกำเนิด และไม่เพิ่ม damage event ให้จำนวนหมัด/ฟันที่มองเห็น

## 2. สิ่งที่ต้องแก้จาก baseline

- [Live choreography](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track2_TowerSystem/TowerController.server.luau#L1868) ใช้รูปแบบกลางและ dash 3.2 studs; ไม่เรียก profile runtime ตาม F-03
- [Profiles ที่มีแล้ว](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track2_TowerSystem/Animations/Luffy.luau#L821) ต้องตรวจว่าจะใช้ใน live/Lab ผ่าน seam ใด ไม่เขียน profile ซ้ำเป็นชุดที่สาม
- [Damage path](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track2_TowerSystem/TowerController.server.luau#L2524) ผูก callback กับ legacy choreography; Integration ต้องแยกก่อนใช้ client playback
- [Animation contract](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Shared/AnimationContract.luau#L245) มี duration/keyframes/canonical states อยู่แล้ว ให้คงชนิดข้อมูลและ EvaluatePoseAtTime signature

## 3. Scope / ownership

P03 เป็นผู้เขียนเพียงรายเดียวของ:
- src/Track2_TowerSystem/Animations/Luffy.luau, Zoro.luau, Ace.luau, _FallbackProfile.luau
- ไฟล์ใหม่ที่เสนอ src/Presentation/AnimationPlayback.luau และ src/Presentation/AttackMotionProfiles.luau
- tests/planning-followup/motion/ เฉพาะของ Phase นี้

AnimationRegistry, AnimationController, TowerController และ Shared/PresentationContract เป็น Integration owner  
ไม่แก้ P02 RigBinder, P04 VFX, P05 HUD, P06 Maps หรือ raw assets  
8 playable IDs คงเดิม ไม่เพิ่ม Nami/Usopp/Chopper/Robin เข้า catalog เพียงเพราะมี model files

## 4. Character matrix ที่เสนอให้ผู้ใช้รีวิว

| Playable ID | Stance / windup | Attack ที่เห็นจาก geometry | Recovery / ความต่าง |
|---|---|---|---|
| Tower_Luffy_G5 | เด้งตัว/ไหล่คลายแล้วดึงแขนชาร์จ | หมัดยืดจาก fist จริง สะโพกหมุนและลงน้ำหนัก; ยักษ์เฉพาะ visual cue ที่อนุมัติ | แขนคืนขนาด/rest, ท่าเด้ง Gear5 |
| Tower_Zoro_KingOfHell | ลดศูนย์ถ่วง มือสองข้างและดาบปากอยู่ท่าเตรียม | dash ตัดผ่านจุด snapshot และฟัน 3 วิถีจากใบดาบจริง | หยุดหลังฟัน บิดกลับ stance ไม่ลอยค้าง |
| Tower_Ace_Entei | เปิดไหล่/กำหมัดติดไฟ | Hiken แบบ thrust ชัดจากแขน; Entei เป็น visual variant ตามเงื่อนไขเดิมเท่านั้น | แขนและดวงไฟยุบคืน, เสื้อ/ลูกปัดตาม torso |
| Tower_Shanks_Kamusari | มือจับดาบเตรียม Iaido | ก้าว/พุ่งประชิดแล้วฟันคมเดียว; haki wave เป็นส่วนเสริม | เบรกและเก็บ stance หนักแน่น |
| Tower_Whitebeard_Gura | ตั้ง naginata/ลงน้ำหนักเท้า | ฟันง้าวหรือหมัด quake พร้อม torso follow-through | recoil ช้าและหนักทางภาพ แต่ไม่เพิ่ม cooldown |
| Tower_Law_KRoom | หมุนข้อมือ/ยก Kikoku เตรียม | thrust/draw-cut ตามอาวุธ, room distortion เป็น overlay | pose ที่นิ่งแม่นและการดึงอาวุธคืน |
| Tower_Kizaru_Pika | stance ผ่อนคลายแล้วจัดแนวขา/แขน | light-step kick หรือ light-sword strike; แสงไม่แทนการขยับ limb | หยุดที่ปลาย strike แล้วคืน stance |
| Tower_Sanji_Ifrit | ยกเข่า หมุนสะโพก ย้ายจุดถ่วง | leap/dash kick จากเท้าจริง, supporting leg และ torso counter-rotate | ลงเท้าและคืนเท้าครบ ไม่ลงเป็น generic punch |

นี่คือ art-direction proposal ไม่ใช่การเพิ่ม skill/combo/cooldown/ultimate meter ใหม่  
ข้อเสนอ batch: Luffy/Zoro/Ace ทำลึกก่อน แล้วเติมอีก 5 ตัวผ่าน motion profiles เฉพาะ ID ให้ครบ ภาพทั้ง 8 ไม่จำเป็นต้องมีระบบ rig ใหม่ 8 แบบ  
raw hero assets อีก 4 ตัวคง fallback preview เท่านั้น

## 5. Attack timeline / authority

| เวลาจาก server attack start | คงไว้ทาง gameplay | ภาพที่เสนอ |
|---|---|---|
| 0.00 | รับ target snapshot, จับลำดับ attack/cooldown เดิม | รับ attackId และเริ่ม windup |
| ~0.14 | ห้ามแก้ cadence | dash/extend/rotate ไปตาม visual trajectory |
| ~0.24 | ยังไม่ทำ damage จาก client | anticipation/hitstop ภาพสั้น ไม่หยุด server |
| ~0.31 | server จัดการ damage ตาม snapshot/fresh AoE query และ guards เดิม | contact/impact cue ตรง clock นี้ภายใต้ tolerance ที่อนุมัติ |
| หลัง hit | ไม่รอ animation จบเพื่อให้โจมตีรอบใหม่ | follow-through/recovery กลับ visual origin |

ตัวเลขเป็น nominal baseline ไม่อ้าง scheduler แม่นตรงทุก frame  
ห้ามใช้ AnimationController.PlayAttack callback เป็น damage trigger; client pause/seek/hidden/deleted visual ไม่ยกเลิก server pending hit  
damage หลาย hit, juggle, knockback, i-frame, target chase และ range ใหม่อยู่นอก scope

## 6. งานย่อยที่เสนอหลังอนุมัติ

| Task | งาน | Dependency / ตรวจรับ |
|---|---|---|
| P03-01 | pose/trajectory storyboard ทั้ง 8 IDs พร้อมชิ้นส่วนที่ใช้และ cue markers | P02 binding matrix, C-02/C-03 |
| P03-02 | AnimationPlayback transport และ deterministic EvaluateAtTime จาก rest | Stop/Seek/Replay/Scale ไม่มี drift; ปิด cues ตอน scrub |
| P03-03 | attack instance lifecycle, latency catch-up, revision/attackId dedup | drop visual เก่าไม่ cancel gameplay; late packet ไม่เล่นย้อนหลังเต็มท่า |
| P03-04 | Luffy/Zoro/Ace first-quality slice | วัดการเคลื่อน geometry จริง + VFX off comparison |
| P03-05 | อีก 5 playable profiles ผ่าน AttackMotionProfiles และ fallback ที่คง compatibility | ท่าไม่เหมือนกันทั้งแปด; ไม่มี hero ใหม่ |
| P03-06 | cue output ไป P04 และ Lab parity | live กับ Lab ใช้ evaluator/profile เดียว ไม่เขียนสูตรแยก |
| P03-07 | evidence + เสนอ docs sync แบบมี scope delta | no stale ref, no unapproved spec changes |

## 7. โครงสร้าง renderer และ concurrency ที่ต้องตกลงก่อนลงมือ

- logical tower ยังเป็น server-owned object; client แสดง cosmetic visualRoot/clone แยกจาก HP/targeting root
- local visual container ต้องอยู่นอก Enemies/AnimeTowers ที่ server combat scan และไม่เพิ่ม ClickDetector/placement handler ซ้ำ
- การซ่อน server visual ใช้ client-local visibility หลัง clone/binding พร้อม ถ้าโหลดล้มเหลวคืน baseline visual; ห้ามทำให้ผู้เล่นคนอื่นมองไม่เห็น tower
- client ห้ามส่งตำแหน่งปลายหมัด/ดาบกลับไปใช้ทำ damage
- ถ้า target เคลื่อน/ตาย ท่าจบที่ targetPositionSnapshot เดิม ไม่ retarget gameplay; effect ที่ไม่จำเป็น drop ได้
- cooldown floor 0.15s สั้นกว่าท่าเต็ม: ใช้ generation/token คุม pose writer รายตัว ให้ attack ใหม่แย่ง pose ได้โดยไม่ทำ pending damage ของเก่าหาย
- late impact cues อาจเกิดหลาย attackIds ขณะ pose เป็นของรอบใหม่; ต้องแยก pose cancellation กับ VFX TTL/impact cue lifecycle
- dash ระยะไกลไม่เปลี่ยน range และไม่ย้าย authoritative tower เพื่อเอื้อมเป้า; หากความยาวการแสดงเกิน art budget ต้องเสนอ bounded motion ที่ยังอ่านได้ ไม่ทำ beam กลับมาแทนทุกตัว

## 8. Acceptance scenarios

1. VFX Off: ผู้ตรวจแยก Luffy punch / Zoro cut / Sanji kick จาก silhouette และ contact pose ได้
2. Frame-step ใน Lab: ช่วง windup→dash→contact→recovery สัมพันธ์กับ dummy snapshot และ joints จริง
3. Luffy arm stretch คืน forearm/fist/attachment sizes; Zoro trails มี anchor ครบทั้งสามดาบ; Sanji เตะด้วยขาที่ตั้งใจ
4. enemy เคลื่อนออกหลัง target snapshot → ไม่ทำ visual retarget แล้วเปลี่ยน damage location
5. spam attacks ที่ cooldown ต่ำสุดและจำลอง latency → ไม่มี per-frame writers หลายชุดสะสม, ไม่มี arm/weapon drift
6. ขาย/เก็บ/สลับ tower ระหว่างท่า → ไม่มี clone ค้าง และ cancellation ฝั่ง server เทียบเดิม
7. client ปิด rendering/throw ใน playback/ปรับ speed → server hit count/timing/HP/RNG/reward traces คงเดิม
8. 8 heroes อยู่พร้อมกันโดย state ไม่ปน; อีก 4 asset-only heroes preview fallback ตามสถานะจริง
9. หากไม่มี Studio/manual observation ให้ระบุ Signature Visual = NOT VERIFIED แม้ deterministic tests ผ่าน

## 9. ความเสี่ยงและ rollback

เสี่ยงสำคัญ: ท่าสวยแต่ไม่สัมผัสจริง, ขยับ root แล้ว target math เปลี่ยน, animation queue ทำ DPS ลด, มีทั้ง legacy animator กับใหม่ทำงานบน joint เดียว และ raw template ไม่พร้อมแต่มาร์ก ready  
D-05 root/RNG parity ต้องคลี่คลายก่อน Integration เปิด live renderer  
rollback ปิด renderer hook คืน baseline visual route ผ่าน Integration; ไม่ revert inventory/stats และไม่สร้าง autonomous commit

## 10. Copy-ready prompt สำหรับ AGY — review only

~~~text
รีวิวและขยายร่าง P03 โดยยังไม่ลงมือพัฒนา
ตรวจ live attack loop, profiles ปัจจุบัน, canonical joints และ contracts ร่วมที่ pin SHA ไว้
ส่ง storyboard/timeline ของ 8 playable heroes, exact ownership, client renderer lifecycle,
attack concurrency/cancellation design และการเชื่อม cue กับ P04 โดยไม่แก้ damage logic
ชี้ข้อขัดแย้ง root motion/RNG/timing จากโค้ดจริงและผลต่อ behavior-preservation
เสนอ acceptance ที่พิสูจน์ body motion ขณะปิด VFX และ live/Lab parity
ห้ามแก้ code/config/assets/canonical docs, รัน application tests, spawn agents, commit หรือ push
ส่งกลับเฉพาะข้อเสนอ/ประเด็นให้ผู้ใช้ตัดสินใจ; implementation ต้องมีคำสั่งอนุมัติใหม่
~~~

