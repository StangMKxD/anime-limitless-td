# P08 — Enemy Locomotion, Boss Presentation และ Combat Readability

สถานะ: DRAFT / REVIEW ONLY / IMPLEMENTATION NOT AUTHORIZED  
Baseline: main @ 5d0caed21aa61021790a3456cda322d16445edea | วันที่: 17 ตุลาคม 2026 (Asia/Bangkok)  
Requirements: R-02, R-04, R-07; Phase เสริมเสนอใหม่  
Plan Owner: Stang | Controller/Reviewer: Codex | Proposed implementer: AGY Teamwork-preview (ยังไม่มอบหมาย)  
ไม่มี application tests หรือ Studio/manual verification ในรอบนี้; ผล runtime ทั้งหมด NOT VERIFIED  
อ่าน [Integration & Contract Review](00-integration-contract-review.md) และ [HANDOFF กลาง](assets/HANDOFF.md) ก่อนเสมอ

## 1. เหตุผลและผลลัพธ์

เมื่อฮีโร่และแผนที่สวยขึ้น ศัตรูควรเดินอย่างมีน้ำหนัก แยกชนิดจาก silhouette ได้ และบอสมีการแสดงตัว/โจมตีฐานที่อ่านได้ งานนี้เพิ่มภาพเคลื่อนไหวและความชัดเจน โดยไม่แก้ความเร็ว HP เกราะ spawn schedule hitbox path reward หรือการถึงฐาน

ไม่เพิ่ม boss abilities, attack patterns, stun, knockback หรือ cutscene ที่หยุด match

## 2. สิ่งที่ตรวจพบและสิ่งที่ยังไม่ทราบ

[CONFIRMED] มี 4 enemy model templates ใน assets/rojo/EnemyModels และ [WaveManager](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track1_WaveSystem/WaveManager.server.luau#L14) คุม authoritative movement  
[CONFIRMED] [VisualBridge](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/AssetKit/VisualBridge.server.luau#L138) สร้าง root weld ให้ cosmetic parts ใน route นี้  
[INFERRED] skin ที่ root-welded ทั้งตัวอาจไม่แสดง locomotion ของ proxy limbs แต่ยังต้องตรวจ route/instances ที่ใช้จริงใน Studio ก่อนสรุปว่าศัตรูทุกตัวแข็ง  
[UNKNOWN] current visual movement/boss readability ที่ผู้ใช้เห็นจริง; ไม่ fabricate visual defects

## 3. Ownership / interface

P08 เสนอไฟล์ใหม่เพียง:
- src/Presentation/EnemyPresentation.luau
- src/Presentation/EnemyMotionProfiles.luau
- src/Presentation/BossPresentation.luau
- tests/planning-followup/enemy-presentation/

P02 เป็นเจ้าของ RigBinder ที่ใช้ซ้ำ; P08 ห้ามแก้ binder  
WaveManager, VisualBridge, client bootstrap และ shared contract เป็น Integration owner  
P04 ไม่ต้องแก้ shared VFX dispatcher ให้ P08 ระหว่างทำงาน; P08 ใช้ cues/feedback interface ที่ freeze แล้ว; หากต้องเพิ่ม cue/module ให้ CR exact-file expansion  
raw enemy XML และ hero assets ยังคง read-only

ใช้ C-08 ที่เสนอ: immutable view ของ enemyId/model reference/generation/class/dead-state และ transform จาก replication; ไม่มี client→server combat command  
ใช้ speed/displacement ที่เห็นเพื่อแสดง gait; ห้าม animation เขียน WalkSpeed, root world CFrame, HP หรือตำแหน่ง waypoint

## 4. Visual matrix ที่เสนอ

| Enemy asset | Locomotion | Visual distinction | Death/base arrival |
|---|---|---|---|
| PirateGrunt | cadence กลาง แขนขาสลับ | silhouette เปิดอ่านง่าย | fade/pose สั้น ไม่หน่วง server cleanup |
| SoruAssassin | lean forward, stride เร็ว | speed accents แบบเบาและท่ากระชับ | dissipation ไม่สร้างการหลบ damage |
| HakiBrute | ก้าวหนัก ไหล่/ลำตัวส่งแรง | low-frequency stomp เฉพาะภาพ | armor ชัดทางภาพ ไม่เพิ่ม reduction |
| YonkoBoss | stride ใหญ่ พลัง/มวลชัด | spawn announcement และ aura ภายใต้ budget | base contact cue ตาม event จริง ไม่ delay base damage |

spawn announcement ต้องอ่านง่าย ไม่บัง HUD ไม่ lock input ไม่บังคับกล้อง pan  
ถ้าเพิ่ม reaction ต่อ hit ให้ใช้ confirmed cosmetic signal หรือ delta HP ที่สังเกตได้โดยไม่ลดความเร็ว root; ไม่มี animation-induced stun

## 5. งานย่อยที่เสนอหลังอนุมัติ

| Task | ผลส่งมอบ | เกณฑ์ตรวจ |
|---|---|---|
| P08-01 | trace spawn→VisualBridge→enemy root/limbs และ catalog alias | ชี้ active visual owner จริงก่อน replace |
| P08-02 | locomotion profiles ของ 4 classes ใช้ displacement-based phase | ไม่ขึ้นกับ server tick แบบเร่ง/ชะลอ gameplay |
| P08-03 | client cosmetic binding/fallback/revision cleanup | original visibility กลับเมื่อ clone ไม่พร้อม |
| P08-04 | boss spawn/contact/death presentation | ไม่มี input lock/extra damage/arrival delay |
| P08-05 | integrate map/VFX budget และ Lab enemy previews | ใช้ contract เดียวกับ P01/P02/P04 |
| P08-06 | runtime parity evidence และเสนอ docs sync | roots/path/arrival/reward เทียบ baseline |

## 6. Edge cases และ acceptance

1. ลองทั้ง 4 enemy classes ทุก map; locomotion อยู่กับ root จริง ไม่มีเท้าลื่นไกล/หลุดฉาก
2. root authoritative เดินเส้นทางและถึงฐานเวลาเดิม แม้ animation ปิด/throw/Low quality
3. enemy ตาย/ถูก cleanup ก่อนคลิปจบ → ไม่มี ghost clone/healthbar/tweens ค้าง
4. streaming/late join/model generation change → bind ใหม่ถูกตัว ไม่ซ่อน root ที่ไม่มี replacement
5. boss announcement ไม่บัง action dock/cards และไม่ยึด camera จาก Lab
6. enemy HP/armor/slow/speed/reward/base damage และ spawn order เทียบ baseline
7. stress หลายศัตรูใช้ visible workload ที่วัดจริง; ไม่สัญญา FPS จากจำนวนโมเดลอย่างเดียว
8. ไม่มี actual Studio movement observation ให้ locomotion/manual gate = NOT VERIFIED

## 7. ขนานและ rollback

เริ่มหลัง P02 rig interface นิ่ง; ทำขนาน P03/P04 ได้ในไฟล์ของตน แต่ Integration ต้องรับรอง single visual owner ต่อ enemy  
UI boss banner หากต้องเพิ่มใน HUD ให้ส่ง UI contract ให้ P05 ไม่แก้ HUD เอง  
rollback คืน original visibility/VisualBridge route ฝั่ง client โดยไม่ย้าย authoritative enemies หรือคืนรางวัลซ้ำ

## 8. Copy-ready prompt สำหรับ AGY — review only

~~~text
รีวิว P08 เป็นข้อเสนอเสริมเท่านั้น
ตรวจเส้นทาง enemy visuals จริงจาก WaveManager/VisualBridge และ 4 enemy templates
แยกสิ่งที่ source ยืนยันจากสิ่งที่ต้องดู Studio และร่าง locomotion/boss presentation แบบ cosmetic-only
ใช้ RigBinder/quality/camera interfaces ที่ freeze แล้ว พร้อม exact ownership และ parity scenarios
ห้ามเปลี่ยน path/speed/HP/armor/reward/base damage หรือเพิ่ม boss abilities
ห้ามแก้ code/config/assets/canonical docs, รัน application tests, spawn, commit หรือ push
ส่งแผนและ dependency กลับให้ผู้ใช้และ Codex ตรวจ ก่อนอนุมัติ implementation
~~~

