# P07 — Studio Runtime Verification และ Gameplay Regression Harness

สถานะ: DRAFT / REVIEW ONLY / IMPLEMENTATION NOT AUTHORIZED  
Baseline: main @ 5d0caed21aa61021790a3456cda322d16445edea | วันที่: 17 ตุลาคม 2026 (Asia/Bangkok)  
Requirements: R-01..R-07; Phase เสริมเสนอใหม่ตามคำขอผู้ใช้  
Plan Owner: Stang | Controller/Reviewer: Codex | Proposed implementer: AGY Teamwork-preview (ยังไม่มอบหมาย)  
ไม่มี application tests หรือ Studio/manual verification ในรอบนี้; ผล runtime ทั้งหมด NOT VERIFIED  
อ่าน [Integration & Contract Review](00-integration-contract-review.md) และ [HANDOFF กลาง](assets/HANDOFF.md) ก่อนเสมอ

## 1. เหตุผลที่เสนอ

ปิดช่องว่างระหว่าง “มีโค้ด/มี tests ผ่าน” กับ “เปิดในเกมแล้วทำงานจริง” โดยเตรียมวิธีทดสอบที่ใช้ runtime instances และเส้นทาง production จริง รวมทั้ง baseline oracle ที่จับการเปลี่ยน gameplay ตอนย้าย animation/VFX

Phase นี้เป็นงานของ AGY หลังอนุมัติ Codex ไม่รัน application tests ในรอบวางแผนนี้

## 2. หลักฐานจาก main

- [Node fallback](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/tests/run_all_tests.mjs#L987) ไม่เท่ากับ Studio runtime
- [Simulation suite](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/tests/phase5_core_and_lab.test.mjs#L1) ระบุ static audits และ Node simulation
- [F-01..F-06](00-integration-contract-review.md) แสดงว่าต้องมี tests ที่เดิน call graph จริง ไม่ assert เพียง string/attribute
- ไม่มีหลักฐานใหม่จาก Codex ว่า tests ปัจจุบัน fail/pass; ทุกการรันใน phase นี้ยังเป็น NOT RUN

## 3. Ownership

เสนอให้ P07 เป็น single writer ของ tests/run_all_tests.mjs ตาม ownership matrix กลาง; Integration lead ห้ามแก้ runner พร้อม P07  
ไฟล์ใหม่อยู่ tests/studio-reality/ เฉพาะ runtime harness, tests/planning-followup/oracle/ เฉพาะ oracle/regression tests และ assets/evidence/ ของแผนที่อนุมัติเมื่อจำเป็น  
test namespace ของ P01..P06/P08/P09 ยังเป็นของแต่ละ owner ห้าม P07 แก้ให้ผ่านเอง; ส่ง finding กลับเจ้าของ  
tests/manifest_phase5.json และ historical reports เป็น read-only ห้ามแก้ผลย้อนหลัง

ไม่แก้ production modules เพื่อใส่ debug side effects ถ้าจำเป็นต้องเพิ่ม test seam ให้เสนอ exact file/symbol และขอ Integration owner ทำหลังอนุมัติ

## 4. สิ่งส่งมอบและงานย่อย

| Task | ผลส่งมอบ | เกณฑ์ที่ต้องตรวจ |
|---|---|---|
| P07-01 | execution capability matrix Node/Lune/Studio/manual | ระบุสิ่งที่แต่ละ runner พิสูจน์ได้/ไม่ได้ และ missing prerequisites |
| P07-02 | baseline oracle trace design | target/cadence/impact/crit/HP/armor/slow/reward/cash/cards/slot state ระบุ source |
| P07-03 | Studio reachability harness | ตรวจ actual mapped client/server startup, remote, button และ session path |
| P07-04 | rig/playback/VFX end-to-end probes | step จาก UI ไป geometry จริงและ ledger lifecycle ไม่สร้าง mock runtime แทน |
| P07-05 | map/UI/multiplayer regression scenarios | no-vote/tie/late join/early start/respawn/sell/swap/destroy |
| P07-06 | runner integration แบบไม่ซ่อน skipped | console/report แยก categories; runner missing ไม่สรุป full pass |
| P07-07 | evidence handover ที่ ref ตรงกัน และ proposed docs amendment | command/action/environment/result จริง; ไม่สร้างรายงานซ้ำ |

## 5. Oracle design ที่ต้องตรวจให้ละเอียด

- จับ baseline จาก main SHA ที่ pin ก่อน migration ไม่สร้าง expected values จาก implementation ใหม่
- แยก exact assertions เช่น HP/damage/จำนวน rewards กับ scheduler timing tolerance ที่ต้องวัด/อนุมัติ
- บันทึก current RNG draw order และ visual RNG consumption; fixed seed อย่างเดียวไม่พิสูจน์ parity
- บันทึก root motion ที่ส่งผลต่อ range/nearest-target; ไม่ assert จาก pad origin แล้วลืม baseline root
- attack ต่ำสุด 0.15s ต้องครอบคลุม overlap หลาย pending hits ไม่ทดสอบเพียงหนึ่ง attack
- sell/destroy ก่อนและหลัง nominal impact 0.31s ต้องรักษา cancellation policy เดิม
- impact ใช้ตำแหน่ง snapshot แต่ query enemies ใหม่ ห้ามเขียน oracle ที่ผูกแต่ target instance เดิม
- inject visual disabled/error/late packet/replay duplicates ให้ server outcomes เทียบ baseline
- ห้ามแก้ assertions/expected values เพื่อรองรับ scope/spec ที่ไม่อนุมัติ

## 6. Evidence contract

แต่ละ gate มี actual SHA หรือ baseline+working-tree diff, environment, runner/action, command ที่ตรวจ preflight, exit/result, category และ limitation  
StaticInspection, AutomatedTests, StudioRuntime, ManualVisual รายงานคนละค่า; ไม่มี Studio ให้ unavailable/NOT VERIFIED ไม่ใช้ Node simulation แทน  
เก็บ error logs เฉพาะที่จำเป็น ไม่ dump source/diffs/logs ทุกครั้ง; review รายรอบมีรายงานเดียวและ finding IDs คงเดิม  
performance ระบุ device/resolution/quality/concurrency/warmup/window/avg/p95/peak แยก server/client  
ไม่บังคับ screenshot/video; named manual observation ที่ระบุสิ่งที่เห็น/ref ได้เพียงพอ หากไม่มี observation ให้ visual gate ค้าง

## 7. Acceptance / parallel / rollback

P07 ออกแบบ harness ขนาน Wave A ได้หลัง S0 และเพิ่ม probes เมื่อแต่ละ service พร้อม แต่ full runtime execution รอ integration build  
runtime harness ต้อง test-only mapping ใน Studio ไม่ถูกใส่ production place; Integration เป็นผู้คุม mapping  
การมี .spec.luau ไม่รับประกันว่า Lune รองรับ Roblox APIs ทั้งหมด; ห้าม auto-fallback แล้วใช้ label เดิมว่า Studio verified  
ปิดท้ายต้องแสดงรายการ executed/skipped/unavailable อย่างชัดเจน และส่ง actual current ref ให้ Codex รีวิว  
rollback จำกัด test runner/harness changes ไม่แก้ game state/production config

## 8. Copy-ready prompt สำหรับ AGY — review only

~~~text
ตรวจและขยาย P07 runtime/regression verification plan เท่านั้น
วิเคราะห์ runners/test files ปัจจุบันโดยไม่รัน application tests
ระบุช่องว่าง static/simulation/Studio/manual และออกแบบ harness ที่ทดสอบ actual modules/instances
เสนอ baseline oracle ครอบคลุม root motion, RNG order, attack overlap, impact snapshot และ cancellation
ระบุ exact test ownership, prerequisites, evidence categories และ missing-capability handling
ห้ามแก้ tests/code/config/canonical docs, spawn, commit หรือ push
ส่งแผนกลับให้ผู้ใช้และ Codex ตรวจ; ยังไม่มอบหมายให้ดำเนินการทดสอบจริง
~~~

