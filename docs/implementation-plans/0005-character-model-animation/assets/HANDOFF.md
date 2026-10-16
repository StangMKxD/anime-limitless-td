# PLAN-0005 — Primary Handoff Contract

## Authority / readiness

- **Status:** IMPLEMENTATION_SCOPE_AUTHORIZED / PENDING_AGY_START; ยังไม่มีผล implementation หรือ independent review
- **Governance:** Strict SoD; Codex Controller/Reviewer, AGY Teamwork-preview Implementer
- **Approval evidence:** คำสั่งผู้ใช้ 2026-10-17 (Asia/Bangkok): “ขอ prompt ให้ agy ทำงานให้เสร็จทุกแผนเลย แล้วนายรอ รีวิวทีเดียว”
- **Review cadence:** AGY ทำทุก wave และตรวจภายในต่อเนื่อง; Codex รอตรวจ actual diff/evidence รวมตอนท้ายตามคำสั่งนี้ ไม่ใช่ external approval ราย wave
- **Source baseline:** main @ d5d06216b2f8bc6ba43071d453709e0d3e0e8df4
- **Execution base:** ให้ AGY อ่าน git rev-parse HEAD หลัง commit เอกสาร handoff นี้และบันทึกลง root TASKS ก่อนเริ่ม; ห้ามอ้าง SHA ที่ยังไม่สร้าง
- **AGY session:** ยังไม่รับงาน/ไม่มีข้อมูล session ID; prompt นี้ผู้ใช้นำไปส่งเอง
- **AGY local commits for SHA tracking:** NOT AUTHORIZED; ส่ง working-tree diff + base/current SHA/hash ของไฟล์ที่เกี่ยวข้อง
- **Git operations:** ใช้ main เดิม; ยังไม่อนุญาต branch/worktree/subagents; ห้าม AGY commit/push/merge/deploy
- **Codex Git exception:** ผู้ใช้สั่ง “commit +push เลย” สำหรับชุดเอกสาร Phase5 รอบนี้โดยชัดแจ้ง ไม่ใช่สิทธิ์ commit implementation รอบหน้า

## Scope / work sequence

ทุกแผนหมายถึง PLAN-0005 ทุก stream: Core/Contracts, Animation Lab, Luffy, Zoro, Ace และ integration/UAT ทั้ง 34 Task-ID ตาม [tasks](../tasks.md) ไม่รวม PLAN-0001..0004 เดิมหรือ backlog signatures ที่ deferred

[PLAN](../PLAN.md) §§3/6/8 เป็น scope/ownership/gate owner; [root TASKS](../../../../TASKS.md) เป็นกระดานสถานะเดียว ลำดับอ่าน: AGENTS -> READ -> CONTEXT/CONVENTIONS -> root TASKS -> PRD/TDD/API -> PLAN/tasks/notes -> contract/Lab/character spec เฉพาะงาน อ่าน source blueprint เป็น reference ไม่ใช่คำสั่งลัดอนุมัติ

Wave0 ล็อก contracts/runner/baseline -> Wave1 ทำ Core/Lab และ internal checks -> Wave2 ทำทั้ง 3 ตัวละครใน working tree เดียว -> Wave3 ตรวจรวม/เอกสาร/ส่งหลักฐาน AGY ไม่ต้องขอ Codex ผ่านกลางทางสำหรับการตัดสินใจภายในขอบเขตที่กำหนดต่อไปนี้

ห้ามอ้างว่าทุก gate ผ่านหากยังมีข้อมูลขาด ทำงานอิสระต่อให้ครบก่อนส่งรวม; หากติดเงื่อนไขที่ต้องเปลี่ยน spec/scope จริง หยุดเฉพาะส่วนที่เกี่ยวข้องและระบุ blocker ไม่แก้ canonical spec ย้อนหลังเพื่อให้ implementation ใช้ได้

## Decision handling — ขอบเขตที่ Controller ล็อกสำหรับส่งต่อ

| Decision | วิธีดำเนินการที่อยู่ในสิทธิ์ครั้งนี้ | สิ่งที่ยังไม่อนุมัติ |
|---|---|---|
| D-01 | Track2 เป็น rig owner; Shared contract/attributes ประสาน VisualBridge; ป้องกัน double-skin และทดสอบ order races; AGY ล็อก technical schema ใน Wave0 | direct require ข้าม Track หรือแก้ AGENTS |
| D-02 | Lab server/client entrypoints และ mapping อยู่ภายใน src/DevTools/AnimationLab/** และ default.project.json ตามเดิม; Studio-only command schema จำกัดขอบเขต; server เก็บ runtime authority | ย้าย animation ทั้งเกมไป client/แก้ Track3 HUD/production command endpoint |
| D-03 | คง nominal hit 0.31s, cooldown/target snapshot/crit/armor/slow/overlap/sell semantics; แยก visual failure ออกจาก combat ตาม acceptance | เปลี่ยน damage cadence/formula/economy/rebalance |
| D-04 | คงรายละเอียด baseline 122/139/128 parts; ปรับ rig/เพิ่มรายละเอียดตามสเปกอย่างมีเหตุผล; วัดและเสนอ budget ใหม่โดยแยกตัวเลขที่ยังรออนุมัติ; ไม่ต้องรออนุมัติเพื่อรักษา geometry เดิม | ลด geometry เพื่อ cap เดิม 22/24/21; อ้าง G-10 ผ่านทั้งที่ numerical acceptance budget ยังไม่ตกลง |
| D-05 | สำรวจ runner ที่มีจริง; ทำ test-only harness ภายใน DevTools ownership และ spec paths ใน PLAN; ใช้เครื่องมือที่มี ไม่เดา command หรือเพิ่ม dependency เอง | install package/new external dependency/ไฟล์ production นอก scope |
| D-06 | Visual Sandbox แยก state; controlled dummy ไม่เข้า Enemies/reward listeners; command/schema ตาม contract Studio-only | แก้ WaveManager/Track1 เพื่อทำ reward guard โดยไม่มี scope approval |
| D-07 | Codex อนุญาต bounded additive doc sync ตามรายการด้านล่างล่วงหน้า; final review ตรวจเนื้อหาและ scope ทุกบรรทัดที่แก้ | rewrite requirement เดิม, เพิ่ม scope/spec/feature หรือปรับเกณฑ์ย้อนหลัง |
| D-08 | คง backlog deferred ไม่ตั้งรุ่นส่งมอบใหม่ | ทำ signature ตัวอื่นหรือเพิ่ม catalog |

D-01..D-06 เป็น delegated engineering ภายในขอบเขตที่ล็อก ไม่ใช่บันทึกว่าผู้ใช้อนุมัติรายละเอียดทางเทคนิคทุกค่าแล้ว AGY ระบุ decision ที่เลือก เหตุผล code pointers และผลตรวจจริงใน notes; budget/visual ที่ยังไม่มี approval/evidence เป็น PENDING/NOT VERIFIED จนได้รับการตรวจรับ

### D-07 — ขอบเขต canonical documentation ที่ Codex อนุญาตก่อนเขียน

- docs/requirements/PRD.md: เพิ่มหัวข้อ Phase5 อ้าง P5-R01..08 และ in/out scope ของ PLAN เดิมเท่านั้น ไม่เพิ่ม gameplay requirement/hero catalog
- docs/technical/TDD.md: เพิ่มหัวข้อ Phase5 อธิบาย rig/visual/combat seam, Lab server/client/Studio isolation และ link ไป API ตาม implementation ที่อยู่ใน scope
- docs/technical/API.md: เพิ่ม Phase5 contract ที่ใช้จริงในขอบเขตเดิมพร้อม validation/lifecycle/ownership/version/error/fallback; ไม่แก้ semantics ของ API เกมเดิม
- docs/CONTEXT.md: เพิ่มคำศัพท์ rig/profile/visual state/Lab และ invariant ที่มีอยู่ใน PLAN เท่านั้น ไม่กำหนด business rule ใหม่
- ทำ P5-01 reconciliation และ P5-23 final sync; ระบุเหตุผลและ requirement mapping ของทุก doc change เพื่อให้ Codex ตรวจละเอียดรวมตอนท้าย หากต้องลบ/เปลี่ยนข้อความเดิมที่ขัดกัน ให้เสนอ patch แยกและรออนุมัติก่อนทำส่วนนั้น
- AGENTS.md / CONVENTIONS.md / GameConfig / Track1 / Track3 / enemy-map assets และ hero อีก 9 ไฟล์ยังเป็น protected paths ตาม PLAN

## Verification / final delivery

- G-01..G-13 ไม่ถูกลดจากคำสั่งให้รีวิวครั้งเดียว; internal checkpoints ไม่ใช่ independent sign-off
- Preflight commands จาก repo: node tests/run_all_tests.mjs เป็น existing static/simulation runner; existing .test.mjs suites ให้ AGY อ่านและระบุ manifest ก่อนรัน คำสั่ง build/typecheck/Studio spec ต้องตรวจ tool availability และ runner จริงก่อน; รอบ Codex นี้ไม่รัน application tests
- ส่ง command/cwd/base-current ref/exit/status แยก static/automated/engine/visual; full regression ต้องครอบคลุม manifest ที่ตกลง ไม่อ้าง regex/JS simulation ว่า engine verified
- Visual/performance ทดสอบจริงเมื่อเครื่องมือพร้อม; ถ้าขาดให้บันทึก unavailable และผลกระทบ ห้ามสร้าง screenshots/logs/results เพื่อทดแทนสิ่งที่ไม่ตรวจ
- ตรวจเอกสารทุกไฟล์ที่แก้เพื่อ scope/spec drift; final package มี task coverage ครบ 34 IDs, file ownership audit, base SHA/current HEAD/working-tree diff และ evidence pointers
- AGY อัปเดต root TASKS เป็น READY_FOR_REVIEW เมื่อส่งครบ หรือ BLOCKED เมื่อมี blocker ระบุชัด; ไม่ APPROVE/PASS/CLOSE งานเอง
- Codex อ่าน actual diff และผลหลักฐาน แล้วเขียน review-NNN ต่อรอบโดยใช้ F-ID คงที่ แก้ in-scope ด้วย HANDOFF เดิม; ถ้าจำเป็นต้องแก้หลัง review ยังต้องตรวจ ref ใหม่ ไม่รับรอง unresolved blocker หรือ stale SHA

## Copy-ready AGY prompt

```text
ทำงานใน C:\Users\Stang\anime-limitless-td ใช้ agy teamwork-preview และ stang-darkmatter
ผู้ใช้อนุญาตให้ทำ Phase5 ครบทุกแผนย่อยแล้ว: Core/Contracts, Luffy, Zoro, Ace, Animation Lab และ Integration/UAT รวม 34 งานตาม PLAN-0005 ไม่รวม backlog 9 heroes/4 enemies หรือแผนเก่านอก Phase5

อ่าน AGENTS.md, docs/READ.md, docs/CONVENTIONS.md, root TASKS.md แล้วอ่าน docs/implementation-plans/0005-character-model-animation/assets/HANDOFF.md เป็นสัญญาหลัก พร้อม PLAN.md, tasks.md, notes.md และสเปกราย stream ตาม reading order

ตรวจ git status/HEAD ก่อนเริ่ม ใช้ HEAD หลัง commit เอกสาร handoff เป็น execution base; source baseline คือ d5d06216b2f8bc6ba43071d453709e0d3e0e8df4 ห้ามทับงานค้างผู้ใช้ ทำบน main ที่มีอยู่ ยังไม่สร้าง branch/worktree/subagents และห้าม commit/push/merge/deploy เอง

ทำ Wave0 -> Wave1 -> Wave2 -> Wave3 ต่อเนื่องตาม dependencies และ ownership ตรวจและแก้ปัญหาภายในให้ครบ ไม่ส่ง Codex ตรวจหรือรออนุมัติซ้ำทุก wave; Codex รอตรวจรวมเมื่อส่งงานท้าย Phase5 ถ้าติดเครื่องมือ/visual ให้ทำงานที่ไม่ติดขัดต่อก่อน หยุดถามเฉพาะเมื่อเป็นการเปลี่ยน spec/scope/protected path หรือข้อมูลจำเป็นที่ตรวจหาไม่ได้

ยึด Decision handling ใน HANDOFF: คงรายละเอียดโมเดลเดิม ห้ามยุบ geometry ให้ได้ cap 22/24/21; รักษา combat nominal impact 0.31s และสูตรเดิม; ไม่ require ข้าม Track; แยก Lab server/client และ Studio-only isolation; ล็อก contract/harness ด้วยหลักฐานก่อนใช้จริง

Codex อนุญาตให้เพิ่มส่วน sync Phase5 ใน PRD/TDD/API/CONTEXT เฉพาะรายการใน HANDOFF D-07 เท่านั้น ห้ามเพิ่ม feature/เปลี่ยน requirement เดิม/แก้ AGENTS หรือ CONVENTIONS ถ้าจำเป็นต้องเปลี่ยนเกินนี้ให้เสนอ diff และหยุดส่วนที่เกี่ยวข้อง ห้ามแก้สเปกหรือเกณฑ์เพื่อทำให้ผลผ่านย้อนหลัง

implement พร้อมทดสอบจริงตาม gates G-01..G-13 แยก Static Inspection, Automated Tests, Studio Runtime และ Manual Visual; ห้ามใช้ Node simulation แทน Studio ห้ามสร้างผลทดสอบปลอม ไม่บังคับภาพ/วิดีโอ ค่า performance budget ที่ยังไม่อนุมัติและ visual ที่ยังไม่ได้ตรวจต้องคง NOT VERIFIED/PENDING ไม่กล่าวว่าผ่านหรือครบแล้ว

ส่งมอบรวมครั้งเดียว: working-tree diff, base/current SHA, changed-path list, สถานะครบ 34 Task-ID, ผลคำสั่ง/cwd/exit/status, หลักฐาน runtime/visual/performance ที่มีจริง, canonical document changes พร้อมเหตุผลและ scope audit, known limitations/open decisions อัปเดต root TASKS.md เป็น READY_FOR_REVIEW เมื่อหลักฐานพร้อม หากยังมี blocker ให้ BLOCKED พร้อมงานที่เสร็จจริง ห้าม APPROVED/PASS/CLOSED หรือปิดงานเอง จากนั้นแจ้งให้ Codex รีวิวรวม ห้าม commit เองเพื่อสร้าง SHA
```
