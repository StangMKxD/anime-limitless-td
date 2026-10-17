# P01 — Animation Lab ที่เปิดเห็นและใช้งานได้จริง

สถานะ: DRAFT / REVIEW ONLY / IMPLEMENTATION NOT AUTHORIZED  
Baseline: main @ 5d0caed21aa61021790a3456cda322d16445edea | วันที่: 17 ตุลาคม 2026 (Asia/Bangkok)  
Requirements: R-01, R-02, R-07  
Plan Owner: Stang | Controller/Reviewer: Codex | Proposed implementer: AGY Teamwork-preview (ยังไม่มอบหมาย)  
ไม่มี application tests หรือ Studio/manual verification ในรอบนี้; ผล runtime ทั้งหมด NOT VERIFIED  
อ่าน [Integration & Contract Review](00-integration-contract-review.md) และ [HANDOFF กลาง](assets/HANDOFF.md) ก่อนเสมอ

## 1. ผลลัพธ์ที่ต้องการให้ผู้ใช้เห็น

ใน Roblox Studio Play ผู้ทดสอบเห็นปุ่ม Animation Lab ชัดเจน เปิดได้โดยไม่ต้องรู้ F4 ล่วงหน้า เลือก asset แล้วเห็นตัวละครในเวทีหรือ preview ที่พร้อมใช้งาน ตรวจข้อต่อ เล่น/หยุด/เลื่อนท่า และเปิดปิด VFX ได้ ปิดแล้วกลับกล้องและ HUD เดิมได้ครบ

Lab เป็น developer tool เฉพาะ Studio ไม่ปรากฏและไม่สร้าง command listeners ในเกม production ไม่อนุญาตเพิ่ม hidden admin access ในเกมจริง

## 2. สิ่งที่พบและสาเหตุที่ต้องตรวจ

- [CONFIRMED] mapping วาง DevTools ใต้ ReplicatedStorage; client/server bootstrap ไม่อยู่ตำแหน่งเริ่มรันตาม mapping นี้: [mapping](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/default.project.json#L19), [client bootstrap](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/DevTools/AnimationLab/AnimationLabBootstrap.client.luau#L1)
- [INFERRED] เมื่อใช้ mapping นี้โดยไม่มี Studio-side launcher อื่น F4 handler และ AnimationLabCommand ไม่เกิด จึงเปิดไม่ได้ ดู F-01
- [CONFIRMED] [AnimationLabGui](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/DevTools/AnimationLab/AnimationLabGui.luau#L9) สร้าง panels แต่ไม่เติม assets/ผูก event handlers ดู F-02
- [CONFIRMED] [LoadModel](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/DevTools/AnimationLab/AnimationLabBootstrap.server.luau#L40) ยังไม่ต่อ rig/profile/timeline; [SpawnModelOnStage](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/DevTools/AnimationLab/SandboxStageManager.luau#L160) clone แล้ววางโมเดล
- [CONFIRMED] [TimelineController](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/DevTools/AnimationLab/TimelineController.luau#L147) รับ scaleTarget/cue แต่ไม่ได้ใช้ใน ApplyPoseAtTime ทำให้ preview อาจไม่เทียบเท่า runtime โดยเฉพาะหมัดยืด
- [UNKNOWN] Studio place ของผู้ใช้มี script ที่วางเองนอก Rojo หรือไม่, streaming mode, Output errors, F4 ถูก Studio/OS แย่งหรือไม่ จึงห้ามเรียก F-01 ว่าเป็นสาเหตุเดียวในทุก environment

## 3. Scope / ownership

แก้ในอนาคตเฉพาะรายชื่อ P01: AnimationLabBootstrap.client.luau, AnimationLabBootstrap.server.luau, AnimationLabGui.luau, LabConfig.luau, ModelValidator.luau, OrbitCameraController.luau, SandboxStageManager.luau, StressTestRunner.luau, TelemetryCollector.luau, TimelineController.luau, VFXInspector.luau, init.luau ทั้งหมดใต้ src/DevTools/AnimationLab/; tests เฉพาะ tests/planning-followup/lab/

default.project.json, DevTools/init.luau และ thin launchers เป็นของ Integration lead; ขอ wiring ผ่าน C-04 ห้ามแก้ไฟล์เหล่านี้พร้อมกัน  
RigBinder เป็นของ P02; AnimationPlayback เป็นของ P03; VFXDispatcher เป็นของ P04 ใช้ผ่าน neutral interface ที่อนุมัติ ห้ามคัดลอก controller มาไว้ใน Lab อีกชุด

ไม่แก้ gameplay HUD, WaveManager, tower/upgrade server, raw assets, GameConfig หรือ protected docs ใน Phase นี้

## 4. แบบหน้าจอที่เสนอ

| พื้นที่ | เนื้อหา / พฤติกรรม |
|---|---|
| Launcher | ปุ่มชื่อชัดใน Studio และ tooltip F4; startup state/error มองเห็นได้ |
| ซ้าย | ค้นหา 19 assets, filter Hero/Enemy/Map, จำนวนและ validation status |
| กลาง | Workspace preview เป็นหลัก, focus model, grid, dummy, front/side/back/orbit/zoom |
| ล่าง | state 8 ตัว, Play/Pause/Stop/Replay/Loop, 0.1x–2.0x, step ±1/60s, seek timeline |
| ขวา | template/clone/rig/animation/VFX readiness แยกกัน, missing joints, attachments, counters |
| VFX | cue selector, 6 layer toggles, quality Low/Medium/High, cleanup control |
| Error/empty | asset ไม่พบ/rig ไม่พร้อม/session ล้มเหลว ต้องแสดงสาเหตุ ไม่หน้าว่างเงียบ |

โมเดล static map assets แสดง Rig/Animation = N/A ไม่ขึ้นสีแดงว่าเสีย; hero ที่มีแค่ fallback ระบุ Fallback ไม่อ้าง Signature Ready  
ไม่บังคับ mini viewport ขนาดเล็กจนบังเวที; secondary ViewportFrame เป็นส่วนตรวจโครงสร้างตาม requirement เดิมเมื่อ runtime หลักใช้งานได้แล้ว

## 5. งานย่อยที่เสนอหลังอนุมัติ

| Task | งาน / ผลส่งมอบ | Dependency | เกณฑ์ตรวจ |
|---|---|---|---|
| P01-01 | แผน trace Rojo→server boot→remote→client boot→button/F4→OpenSession→GUI | S0 | ทุกจุดมี path/run context/observable state และ failure reason |
| P01-02 | เปลี่ยน bootstrap เป็น callable initialization modules หรือ adapter API ชัดเจน ให้ Integration launcher เรียก | P01-01, C-04 | initialize ซ้ำไม่เกิด listeners/session ซ้ำ; แยก client/server dependencies |
| P01-03 | สร้างรายการ 19 assets จาก catalog จริงพร้อมค้นหาและ readiness | C-04 | เลือกตัวเดียว/สลับเร็ว/asset หายทำงานตาม revision |
| P01-04 | ต่อ LoadModel→clone→RigBinder→profile→AnimationPlayback→stage/camera | P02, P03 | ใช้ model instance เดียวที่มองเห็น และไม่อ่าน server-only modules จาก client |
| P01-05 | ต่อ playback transport, scale/attachments/rest restoration และ VFX inspector | C-01..04, P04 | paused seek ไม่ spawn cues ซ้ำ; Stop คืน size/pose |
| P01-06 | session isolation, input/camera cleanup, production lockout, telemetry/stress controls | P01-02..05 | เปิดปิด/respawn/player leave/retry ไม่ทิ้ง instance หรือกล้องค้าง |
| P01-07 | แสดงหลักฐานตามชนิด พร้อม proposed docs amendment เฉพาะ discrepancy | ทุกงาน | Codex ตรวจเอกสารก่อนเขียน; ไม่แก้ spec ให้ผ่านย้อนหลัง |

## 6. การแยก sandbox และ camera

แนะนำ client-local preview clone สำหรับภาพที่ client ควบคุมเอง โดย server session ไม่ลงทะเบียน reward/combat listeners และไม่ใส่ dummy ใน Workspace.Enemies  
หากคง server stage ที่ Y=5000 ให้เสนอวิธีให้ client เข้าถึง stage ภายใต้ streaming และตรวจสอง clients จริง ไม่ใช้ระยะสูงเป็นหลักฐาน isolation  
ModelValidator ต้องตรวจ runtime clone หลัง binding ควบคู่ raw template; สถานะพร้อมแต่ละระดับต้องแยกกัน

camera ownership แบบ Lab > lobby preview > gameplay shake เมื่อเปิด Lab ให้พัก feedback sink ผ่านสัญญา C-03; ปิดคืน CameraType/Subject/CFrame/FOV ที่บันทึกไว้ พร้อม restore HUD visibility/input focus เฉพาะที่ Lab เปลี่ยน  
ปุ่ม error/retry/close ต้องใช้ได้แม้ remote timeout หรือการโหลดโมเดลล้มเหลว; ไม่ถือ isLabOpen=true ก่อน session พร้อม

## 7. Acceptance scenarios ที่ต้องให้ AGY พิสูจน์ภายหลัง

1. Studio Play F4 และปุ่มเปิดได้ทั้งครั้งแรกและหลังปิด 10 รอบ; ไม่มี infinite WaitForChild หรือหน้าว่าง
2. Select Luffy/Zoro/Ace → เลือก state → frame step เห็นชิ้นแขน/ดาบจริงขยับ; Bone count=0 ไม่แปลว่า rig เสีย
3. Select static map asset → แสดงได้และ control ที่ไม่เกี่ยวเป็น N/A
4. สลับ assets เร็วระหว่างโหลด 20 ครั้ง → response เก่าไม่ bind ทับตัวใหม่
5. สอง Studio clients เปิดพร้อมกัน → model/camera/seek ไม่กระทบ session อีกคน
6. เปิด Lab ระหว่าง gameplay → cash/stats/inventory/enemy HP/wave/reward ไม่ถูกเขียนจาก Lab; ไม่หยุด wave ของผู้อื่น
7. เปิด scale 0.5/1/2.5 แล้ว Stop/reset → pose/size/attachments คืนตาม snapshot tolerance เดิม
8. ปิด/respawn/disconnect → cleanup idempotent, camera คืน, connections delta กลับ baseline
9. Production execution path → ไม่มี GUI/command handler/session effects; guard ต้องตรวจฝั่ง server ด้วย
10. หากไม่มี interactive Studio evidence ให้ G-01/manual UI = NOT VERIFIED ห้ามใช้ static string audit แทน

## 8. ลำดับขนาน / ความเสี่ยง / rollback

P01 ออกแบบหน้าจอ/flow คู่กับ P02/P05/P06 ได้หลัง freeze; final rig/animation parity รอ P02/P03/P04  
risk สำคัญคือแก้ launcher แล้วเหมารวมว่า Lab สมบูรณ์, แยก player สองตัวที่ไม่ตรงกัน, stage ไม่ stream, camera writers แข่ง และ preview ใช้สูตรท่าอีกชุด  
rollback ใช้ Integration ถอดเฉพาะ launcher/mapping ของ Lab และคืน DevTools package เดิม ไม่แตะ gameplay state

## 9. Copy-ready prompt สำหรับ AGY — review only

~~~text
คุณคือ AGY Teamwork-preview รอบนี้ได้รับอนุญาตให้อ่านและเสนอปรับแผน P01 เท่านั้น
อ่าน AGENTS.md, docs/READ.md, เอกสาร Phase5 Lab ที่อ้างถึง และ 00-integration-contract-review.md
ตรวจ main SHA ปัจจุบันเทียบ baseline ในไฟล์นี้ หากเปลี่ยนให้รายงาน drift ก่อน
ตรวจ F-01/F-02/F-06 ด้วย source และร่าง execution trace ของ Lab ตั้งแต่ Rojo mapping ถึง model playback
ส่งกลับแผน UI/command matrix, exact file list, initialization API, streaming/session/camera strategy,
acceptance scenarios, proposed docs amendments และรายการตัดสินใจที่ต้องให้ผู้ใช้เลือก
แยก CONFIRMED / INFERRED / UNKNOWN; runtime และ visual ที่ไม่มีหลักฐานให้ NOT VERIFIED
ห้ามแก้ code/config/assets/canonical docs, รัน application tests, spawn agents, commit, push, merge หรือเปลี่ยนสถานะงาน
ยังไม่อนุมัติ implementation; จบที่แผนเพื่อให้ผู้ใช้และ Codex รีวิว
~~~

