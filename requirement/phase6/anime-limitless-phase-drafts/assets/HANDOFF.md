# HANDOFF — ชุดร่างสำหรับรีวิวเท่านั้น

สถานะ: REVIEW ONLY / NOT AN IMPLEMENTATION CONTRACT  
Repository: https://github.com/StangMKxD/anime-limitless-td  
Reviewed baseline: main @ 5d0caed21aa61021790a3456cda322d16445edea  
วันที่: 17 ตุลาคม 2026 (Asia/Bangkok)  
ผู้ขอ: Stang | Controller/Independent Reviewer: Codex  
ผู้รับที่เสนอ: AGY Teamwork-preview — ยังไม่ dispatch/มอบหมาย  
อนุญาต local Git commits เพื่อ SHA tracking: **ไม่อนุญาต**  
Code/config/assets/canonical-doc writes: **ไม่อนุญาต**  
Application tests / spawn agents / push / merge / deploy: **ไม่อนุญาตในรอบนี้**

## Scope และสิ่งส่งกลับ

รีวิวชุดร่าง 9 Phase และเสนอแก้ scope, dependencies, exact ownership, contracts และ acceptance ให้ผู้ใช้กับ Codex ตรวจ ก่อนขอ implementation approval  
ข้อกำหนดและ findings หลักอยู่ [00-integration-contract-review.md](../00-integration-contract-review.md) ใช้เป็นแหล่งเดียว ไม่สร้าง integration summary ซ้ำ  
แต่ละ Phase มี task breakdown และ copy-ready prompt ที่ยังเป็น review-only:

1. [P01 Animation Lab](../01-animation-lab-review-prompt.md)
2. [P02 Rig / model binding](../02-rig-model-binding-review-prompt.md)
3. [P03 Melee / animation](../03-character-melee-animation-review-prompt.md)
4. [P04 VFX](../04-signature-vfx-review-prompt.md)
5. [P05 Lobby / gameplay UI](../05-lobby-gameplay-ui-review-prompt.md)
6. [P06 Multiple maps / selection](../06-multiple-maps-selection-review-prompt.md)
7. [P07 Runtime / regression verification](../07-runtime-regression-verification-review-prompt.md)
8. [P08 Enemy / boss presentation](../08-enemy-boss-presentation-review-prompt.md)
9. [P09 Settings / accessibility / device quality](../09-settings-accessibility-quality-review-prompt.md)

## Acceptance ของงานรีวิวแผน

- ตรวจว่า current main ยังตรง baseline หรือรายงาน drift พร้อม actual SHA
- ตรวจ F-01..F-08 และแยก confirmed/inferred/unknown; ไม่อ้าง runtime/manual pass จาก source
- ทุก Phase มี single-writer file set, dependencies และสิ่งที่ไม่ทำ; ไม่ใช้คำว่า parallel ซ่อนงานที่ต้องรอกัน
- frozen shared contracts มี schema/authority/errors/lifecycle ที่ตรวจได้ และมีสถานะ PROPOSED จนอนุมัติ
- gameplay baseline/RNG/root-motion/0.31s/cadence/target snapshot/เศรษฐกิจไม่ถูกเปลี่ยนเงียบ ๆ
- canonical docs amendment ระบุ scope/spec/acceptance delta และรอ Codex/ผู้มีอำนาจก่อนเขียน
- ส่งรายการแก้แผนและ decision requests โดยยังไม่เปลี่ยนสถานะงานเดิมหรือรับรอง implementation

## Copy-ready prompt กลาง

~~~text
AGY Teamwork-preview: รอบนี้ให้ตรวจแผนเท่านั้น ยังไม่อนุมัติ implementation
อ่าน AGENTS.md และ docs/READ.md ของ anime-limitless-td รวมเอกสารที่เกี่ยวข้องตาม project-first
ใช้ main SHA ใน HANDOFF เป็น reviewed baseline; ตรวจ current main ถ้าต่างให้แจง drift ก่อน
อ่าน 00-integration-contract-review.md แล้วเลือก Phase P01–P09 ที่ผู้ใช้ต้องการตรวจ
ทวนข้อค้นพบด้วยโค้ดจริงและเสนอแก้แผน: exact file ownership, server/client/services boundary,
shared contracts, authority/validation/errors, dependencies, acceptance, risk และ rollback
รักษา gameplay เดิมทั้งหมด; map layout หรือ lifecycle ใหม่/RNG policy/root targeting changes ต้อง CR
ตรวจเหตุ Animation Lab เข้าไม่ถึงตั้งแต่ mapping/launchers ถึง GUI/model/playback ไม่หยุดที่ F4
ส่งผลเป็น Markdown ข้อเสนอให้ผู้ใช้และ Codex รีวิว ไม่เขียน code/config/assets/canonical docs
ห้ามรัน application tests, spawn/delegate agents, commit, push, merge, deploy หรือปิด/approve งาน
สิทธิ์ commit/push ที่อยู่ใน Phase5 HANDOFF เก่าไม่ครอบคลุมงานนี้
ไม่มี runtime/manual evidence ให้ระบุ NOT VERIFIED; ห้ามผลิตหลักฐานหรือ approval สมมติ
เมื่อผู้ใช้ให้แก้ร่าง ให้แก้เฉพาะเอกสารร่างที่ระบุ ไม่ถือเป็นสิทธิ์เริ่มพัฒนา
~~~

เมื่อผู้ใช้อนุมัติ implementation จริงแล้ว Controller จึงจัดทำ/ปรับ primary assignment contract นี้ตาม scope ที่อนุมัติ ระบุตัวผู้รับ, current baseline/dirty state, contract revision, exact ownership, gates และสิทธิ์ Git ใหม่ก่อนส่งมอบ ไม่มีการอนุมัติหรือ dispatch เกิดขึ้นจากการสร้างไฟล์นี้

