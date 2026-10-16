# PLAN-0005 — รายละเอียดงานย่อย (แผนร่าง ไม่ใช่กระดานสถานะอีกใบ)

สถานะปัจจุบันทุกงาน: NOT STARTED — ผู้ใช้อนุญาต AGY ทำ implementation Phase5 ครบ 34 งานแล้ว; Codex ตรวจรวมตอนท้ายตาม HANDOFF ล่าสุด

กระดานสถานะเดียวของโปรเจคคือ [root TASKS](../../../TASKS.md); [PLAN](PLAN.md) เป็น scope owner และ [HANDOFF](assets/HANDOFF.md) เป็น assignment contract ร่าง งานด้านล่างเป็นคิวแผนทั้งหมด ไม่ต้องคัดลอกเป็น checklist สถานะซ้ำในเอกสารอื่น

หาก task เดิมระบุรอ Owner/Codex อนุมัติราย wave ให้ยึด HANDOFF ล่าสุด: internal gates โดย AGY แล้วส่ง Codex รวมตอนท้าย; ข้อห้าม scope/spec drift ยังคงอยู่

ชื่อ AGY-* เป็น stream ที่เสนอ ยังไม่ใช่บุคคล/session ที่รับงานจริง; ทุกงานต้องอ่าน AGENTS/READ/CONVENTIONS/PLAN และ sub-spec ที่เกี่ยวข้องก่อนเริ่ม งานจำเป็นที่อยู่นอก ownership ต้องหยุด BLOCKED_SCOPE ไม่ขยายเอง

แต่ละ implementation task ใช้ red -> green ที่ public seam ทีละกรณี ไม่เขียนชุดทดสอบ bulk ก่อนรู้ harness และไม่เรียก static simulation ว่า Studio runtime การตรวจของ Codex คือ independent diff/evidence review; AGY เป็นผู้รันแอปและรวบรวมผล

## Wave0 — Contract lock / แก้ประเด็นค้างก่อนแตะ runtime

### P5-00 — Baseline recheck และ scope ledger

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** Owner approval ของ wave; อ่าน AGENTS/READ/PLAN/notes
- **งาน/ส่งมอบ:** อ่าน HEAD/status/diff/worktree ใหม่, ตรวจ XML inventory 19 และ source path ที่อ้าง; ระบุ tracked/untracked ของผู้ใช้และ actual ref ที่ใช้
- **เกณฑ์ตรวจรับ:** ตรง baseline หรือแจ้ง drift ให้ Codex; ไม่มีไฟล์ของผู้ใช้ถูก reset; map requirement -> ownership -> gate ครบ
- **Traceability:** P5-R01 / G-01,G-13

### P5-01 — Canonical document reconciliation proposal

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core เสนอ / Codex ตรวจ | **ก่อนเริ่ม:** P5-00; D-07
- **งาน/ส่งมอบ:** เสนอ diff เทียบ PRD/TDD/API/CONTEXT กับ code baseline และ Phase5 เฉพาะเรื่องจำเป็น; แยก facts เดิมกับ new requirement; ยังไม่แก้เอกสารหลักจน Controller อนุญาตและ Owner ตัดสิน scope
- **เกณฑ์ตรวจรับ:** มี change rationale/affected requirement/ข้อไม่ทำ; ไม่มีเพิ่ม catalog/economy/track ownership โดยเงียบ; draft ไม่ถูกใช้แทน approval
- **Traceability:** P5-R01..08 / G-13

### P5-02 — Freeze combat behavior และ timing oracle

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-00; D-03 เสนอให้อนุมัติ
- **งาน/ส่งมอบ:** วาง baseline trace ของ nominal impact 0.31s, 0.08s poll, min cooldown 0.15, overlapping attacks, capture impactPos/stats, fresh enemy query, crit/armor/slow, sell/recall cancellation; ระบุวิธี clock/seed/tolerance
- **เกณฑ์ตรวจรับ:** baseline trace จาก actual runtime ก่อนแก้หรือระบุ unavailable; tests เทียบ seam จริงได้ ไม่เปลี่ยน output ตาม implementation ใหม่
- **Traceability:** P5-R05 / G-06,G-11

### P5-03 — Animation schema + semantic rig ownership lock

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-00,01; D-01,D-03
- **งาน/ส่งมอบ:** ล็อก aliases/states/joint map/rest/scale target/cancel/error/version; กำหนด claim/ready/fallback ordering ระหว่าง Track2 กับ bridge; สร้างเฉพาะ contract ที่อนุมัติหลัง Owner อนุญาต
- **เกณฑ์ตรวจรับ:** API schema ตรวจชนิด/required fields; ไม่มี direct cross-track require; semantics ของ missing limb/unknown hero/rebuild/cancel ชัด; Luffy scale เป็นหลาย subparts ได้
- **Traceability:** P5-R02,R03 / G-02,G-04,G-13

### P5-04 — VFX schema, cap และ resource ledger lock

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-03; D-04 สำหรับ budget
- **งาน/ส่งมอบ:** ล็อก cue extensions, quality/layers/intensity, passive owner, TTL, tracked instances/tweens/connections/tasks และ budget precedence; ล็อก schema ของ cleanup report
- **เกณฑ์ตรวจรับ:** ทุก resource มี owner; repeated start/cleanup ไม่เพิ่มหรือนับซ้ำ; caps ไม่ block damage; ไม่มีตัวเลขที่ขัด baseline ถูกสรุปว่า approved
- **Traceability:** P5-R04 / G-05,G-07,G-10

### P5-05 — Lab execution/client-server/isolation design lock

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-03,04; D-02,D-06
- **งาน/ส่งมอบ:** สรุป Rojo server/client entrypoints และ Studio command contract; define session scope, camera restore, dummy mode/reward exclusion; ตรวจว่าไม่ต้องแก้ protected Track1/3
- **เกณฑ์ตรวจรับ:** ไม่มี require server module จาก clientหรือข้าม Track; bootstrap มีตำแหน่งรันจริง; runtime command ไม่มี production side effect; ถ้าขยายไฟล์นอก ownership ต้อง CR ก่อน
- **Traceability:** P5-R06 / G-08,G-13

### P5-06 — Verification manifest และ runner preflight

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-02..05; D-05
- **งาน/ส่งมอบ:** ตรวจ runner จริงจาก TEST_INFRA/tests files, syntax/typecheck/build tool availability; เลือก Studio harness ให้ .spec.luau และ test-only mapping; ระบุ commands/cwd/output/exit semantics ให้ Codex ตรวจ
- **เกณฑ์ตรวจรับ:** ไม่เดาคำสั่ง lua/luau/TestEZ; ไม่มี install/dependency เพิ่มเอง; แยก static/simulation/Studio/visual; เห็นรายการ existing suite ทั้งหมดที่จะรัน
- **Traceability:** P5-R01..08 / G-11

## Wave1 — Core runtime + Lab (เริ่มเมื่อ contract/decisions ที่เกี่ยวข้องอนุมัติแล้ว)

### P5-07 — Single visual binding และ bridge compatibility

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-03,06; D-01 accepted
- **งาน/ส่งมอบ:** แก้เฉพาะ attachSkin/hero binding ownership ตาม claim protocol; ทดสอบ Track2-first/bridge-first/existing child/rebind/failure; เก็บ legacy enemy/map policy
- **เกณฑ์ตรวจรับ:** หนึ่ง tower มีหนึ่ง visible rig; geometry ไม่ถูกซ่อนผิด; no duplicate skin/weld; imported scripts ถูก strip เหมือนเดิม
- **Traceability:** P5-R02,R08 / G-01,G-02

### P5-08 — Idempotent semantic RigBuilder

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-03,07
- **งาน/ส่งมอบ:** resolve actual part groups/pivots, construct 6/9-joint target, rest transforms, selective rigid edge repair, accessory hierarchy; build ซ้ำและตรวจ duplicate/missing endpoints
- **เกณฑ์ตรวจรับ:** visible geometry ขยับเมื่อ root อยู่นิ่งหลัง engine step; accessories follow; no self joint/rigid path lock/orphan; ไม่ลบ decorative weld ที่จำเป็น
- **Traceability:** P5-R02 / G-02,G-03

### P5-09 — Deterministic procedural state player

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-08
- **งาน/ส่งมอบ:** evaluate rest-relative pose ตามเวลา, easing, pause/seek/loop/speed/scale; token transition, hard cancel/reset/destroy; cue boundary policy และไม่ emit ระหว่าง seek ย้อน
- **เกณฑ์ตรวจรับ:** 8 states เมื่อ profile มี, repeated seek ได้ pose เดิม, reset C0/C1/Size/attachments/color, no drift และ no shared state ระหว่างโมเดล
- **Traceability:** P5-R03 / G-04

### P5-10 — VFXDispatcher และ lifecycle tracking

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-04,09
- **งาน/ส่งมอบ:** โหลด per-character/fallback VFX, cue/quality/layers, per-model+global caps, tracked resource wrappers/cleanup, stale token guard, errors fail visual safely
- **เกณฑ์ตรวจรับ:** passive aura ไม่ซ้ำ; cap ลดภาพเท่านั้น; Cancel/Destroy/TTL ล้าง owned resources และ counters ตรง; visual error ไม่หลุดไปบล็อก combat
- **Traceability:** P5-R04 / G-05,G-07

### P5-11 — Combat integration โดยคงพฤติกรรมเดิม

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-02,07..10
- **งาน/ส่งมอบ:** แยก server hit schedule จาก visual call; preserve pending attack identity, timing/stat snapshot/fresh enemies/crit/armor/slow; ป้องกัน duplicate callbacks และเคารพ tower destruction
- **เกณฑ์ตรวจรับ:** trace ตรง oracle ที่ล็อก; VFX off/on/error/seek spam ไม่เปลี่ยน damage/RNG; overlapping cadence เดิมยังทำงาน; ไม่แก้ Wave/GameConfig/economy
- **Traceability:** P5-R05 / G-06,G-11

### P5-12 — Studio bootstrap / Rojo / session lifecycle

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-05,11
- **งาน/ส่งมอบ:** เพิ่ม approved DevTools mapping และ client/server entrypoints; Studio guard ก่อน allocation, local UI activation/F8 ที่ไม่ชน controls, per-session containers และ close/respawn/disconnect cleanup
- **เกณฑ์ตรวจรับ:** server/client อยู่ถูก services; เข้า Studio เปิด UI ได้; non-Studio ไม่มี Lab event/UI/listener side effect; Track3 HUD ไม่ถูกแก้
- **Traceability:** P5-R06 / G-08

### P5-13 — Workspace preview และ camera controls

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-12
- **งาน/ส่งมอบ:** สร้าง isolated stage/dummy/grid, camera orbit/zoom/preset/focus, markers/BBox/accessory toggle/scale; mini ViewportFrame สำหรับ structure preview
- **เกณฑ์ตรวจรับ:** VFX ตรวจหลักใน Workspace; ทั้ง 19 ขนาด focus ได้; session restore camera/input/local effects ทุก exit path; stage ไม่รบกวนเกม
- **Traceability:** P5-R06 / G-03,G-05,G-08

### P5-14 — Animation/VFX inspection controls

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-09,10,13
- **งาน/ส่งมอบ:** UI state select/play/pause/stop/replay/loop/speed 0.1–2, step +/-1/60s, scrub; VFX-only/combo/attack/ultimate/reset, layers/intensity/quality และ optional integration mode ตาม D-06
- **เกณฑ์ตรวจรับ:** state ไม่มี disable พร้อม reason; seek ไม่ยิง VFX/ทำ damage เพิ่ม; reset คืน pose+resources; target direction/scale attachments ถูกต้อง
- **Traceability:** P5-R03,R04,R06 / G-04,G-05,G-08

### P5-15 — 19-asset Model Explorer และ truthful validator

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-08,12,13
- **งาน/ส่งมอบ:** search/categories/status/hierarchy; แยก file/template/clone/rig/module/runtime/visual; graph validation ทั้ง weld endpoints และ indirect connections
- **เกณฑ์ตรวจรับ:** เห็น 12/4/3 ครบ; 3 signatures รอ modules, อื่น fallback/unsupported ตรงจริง; static map N/A ไม่ถูกตีว่า broken rig; ไม่มี hardcode verified
- **Traceability:** P5-R01,R06,R08 / G-01,G-02

### P5-16 — Telemetry และ bounded stress runner

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-10,12..15; D-04 budget ที่ยืนยันได้; ตัวเลขที่ยังไม่อนุมัติต้องไม่อ้างว่าผ่าน
- **งาน/ส่งมอบ:** track part/motor/weld/emitter/tracked tween/connection/task/creation-cleanup; 1/10/25/50 mixed chars, warmup/steady/burst/cleanup; raw instance count cross-check
- **เกณฑ์ตรวจรับ:** metric มี scope/estimate label; cap/speed/intensity/quality ทำงาน; overflow ไม่ค้าง; cleanup ledger+subtree เทียบ baseline; มี measured frame data ไม่เดา FPS
- **Traceability:** P5-R07 / G-07,G-09,G-10

### P5-17 — Core/Fallback/Lab verification barrier

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core ตรวจภายในและเก็บหลักฐาน / Codex รอตรวจรวมท้าย Phase5 | **ก่อนเริ่ม:** P5-06..16
- **งาน/ส่งมอบ:** ทำ red-green ที่ public seam ตามงาน, รัน core spec และ baseline regression ที่เกี่ยวข้อง; ตรวจ module absence/failure/double rig/skin, state races, VFX off/error, sandbox snapshots และ production gate
- **เกณฑ์ตรวจรับ:** core accepted ตาม actual ref; internal failures แก้แล้ว; automated/static/Studio/manual แยกผล; gate ที่เครื่องมือยังไม่พร้อมไม่ถือผ่าน แต่ทำงานอิสระต่อได้และต้องเปิดเผยข้อจำกัดตอนส่งรวม
- **Traceability:** P5-R01..08 / G-01..08,G-11,G-13

## Wave2 — Luffy (owned files แยกรายตัว; ยังไม่อนุญาต parallel agents)

### L-01 — Luffy model refinement + explicit rig map

- **ผู้รับผิดชอบที่เสนอ:** AGY-Char-Luffy | **ก่อนเริ่ม:** P5-17; คงรายละเอียด baseline ตาม HANDOFF D-04
- **งาน/ส่งมอบ:** อ่าน characters/01-luffy.md; ปรับ assets/rojo/HeroModels/Luffy.rbxmx จากของเดิมและ map 6 joints; multi-part right-arm stretch + shoulder pivot; เก็บ approved part budget/geometry
- **เกณฑ์ตรวจรับ:** ชื่อ/mapping/attachments ถูก; expected joints ready; ไม่ลดรายละเอียดเกินสิ่งอนุมัติ; model diff ไม่แตะของตัวอื่น
- **Traceability:** P5-R02,R08 / G-02,G-03,G-13

### L-02 — Luffy signature animation

- **ผู้รับผิดชอบที่เสนอ:** AGY-Char-Luffy | **ก่อนเริ่ม:** L-01
- **งาน/ส่งมอบ:** สร้าง Animations/Luffy.luau ตาม contract version ที่ล็อก: Joyboy Bounce / Laugh / Spawn / Stretch Punch / Bajrang; ครบ idle/special/spawn/4 attack phases/ultimate ตามสเปก; cancel/reset/scale ใช้ context
- **เกณฑ์ตรวจรับ:** ดูท่าจริงทุก state/ความเร็ว; no drift/cue duplicate; arm length/Size และทุก subpart คืนค่าแม้ cancel กลาง stretch
- **Traceability:** P5-R03 / G-03,G-04

### L-03 — Luffy VFX module

- **ผู้รับผิดชอบที่เสนอ:** AGY-Char-Luffy | **ก่อนเริ่ม:** L-02; P5-10
- **งาน/ส่งมอบ:** สร้าง VFX/LuffyVFX.luau สำหรับ Cloud + black-red Haki; cue/quality/layers/intensity/TTL/cap และ passive cleanup ผ่าน registry wrappers
- **เกณฑ์ตรวจรับ:** animation-only/VFX-only/combo และทุก quality ทำงาน; target aligned; repeated passive start ไม่ซ้ำ; ไม่มี HP/economy write หรือ resource bypass
- **Traceability:** P5-R04 / G-05,G-07

### L-04 — Luffy tests + Studio visual handover

- **ผู้รับผิดชอบที่เสนอ:** AGY-Char-Luffy | **ก่อนเริ่ม:** L-01..03; P5-06
- **งาน/ส่งมอบ:** เพิ่ม tests/characters/luffy_anim_vfx.spec.luau ตาม harness จริง; joint world delta, accessory relation, cancel/reset, cue/quality/layer/TTL/destroy; บันทึก visual checklist ข้อ §7 ของตัวละคร
- **เกณฑ์ตรวจรับ:** หลักฐานผูก actual ref; C0/C1/Size tolerance ตาม approved contract, no leak, manual visual ระบุคนตรวจ/มุม/state; ห้ามแทน Studio ด้วย regex/JS simulation
- **Traceability:** P5-R02..04,R08 / G-02..07,G-12,G-13

## Wave2 — Zoro (owned files แยกรายตัว; ยังไม่อนุญาต parallel agents)

### Z-01 — Zoro model refinement + explicit rig map

- **ผู้รับผิดชอบที่เสนอ:** AGY-Char-Zoro | **ก่อนเริ่ม:** P5-17; คงรายละเอียด baseline ตาม HANDOFF D-04
- **งาน/ส่งมอบ:** อ่าน characters/02-zoro.md; ปรับ assets/rojo/HeroModels/Zoro.rbxmx จากของเดิมและ map 9 joints; Wado mouth, Enma right, Sandai left, scabbards torso; เก็บ approved part budget/geometry
- **เกณฑ์ตรวจรับ:** ชื่อ/mapping/attachments ถูก; expected joints ready; ไม่ลดรายละเอียดเกินสิ่งอนุมัติ; model diff ไม่แตะของตัวอื่น
- **Traceability:** P5-R02,R08 / G-02,G-03,G-13

### Z-02 — Zoro signature animation

- **ผู้รับผิดชอบที่เสนอ:** AGY-Char-Zoro | **ก่อนเริ่ม:** Z-01
- **งาน/ส่งมอบ:** สร้าง Animations/Zoro.luau ตาม contract version ที่ล็อก: Guard / Enma special idle / Draw / Cross Slash / 103 Mercies; ครบ idle/special/spawn/4 attack phases/ultimate ตามสเปก; cancel/reset/scale ใช้ context
- **เกณฑ์ตรวจรับ:** ดูท่าจริงทุก state/ความเร็ว; no drift/cue duplicate; 3 blades ไม่หลุด/ทะลุมือและ mouth blade ตาม head
- **Traceability:** P5-R03 / G-03,G-04

### Z-03 — Zoro VFX module

- **ผู้รับผิดชอบที่เสนอ:** AGY-Char-Zoro | **ก่อนเริ่ม:** Z-02; P5-10
- **งาน/ส่งมอบ:** สร้าง VFX/ZoroVFX.luau สำหรับ green-purple-gold flames / three blade trails; cue/quality/layers/intensity/TTL/cap และ passive cleanup ผ่าน registry wrappers
- **เกณฑ์ตรวจรับ:** animation-only/VFX-only/combo และทุก quality ทำงาน; target aligned; repeated passive start ไม่ซ้ำ; ไม่มี HP/economy write หรือ resource bypass
- **Traceability:** P5-R04 / G-05,G-07

### Z-04 — Zoro tests + Studio visual handover

- **ผู้รับผิดชอบที่เสนอ:** AGY-Char-Zoro | **ก่อนเริ่ม:** Z-01..03; P5-06
- **งาน/ส่งมอบ:** เพิ่ม tests/characters/zoro_anim_vfx.spec.luau ตาม harness จริง; joint world delta, accessory relation, cancel/reset, cue/quality/layer/TTL/destroy; บันทึก visual checklist ข้อ §7 ของตัวละคร
- **เกณฑ์ตรวจรับ:** หลักฐานผูก actual ref; C0/C1/Size tolerance ตาม approved contract, no leak, manual visual ระบุคนตรวจ/มุม/state; ห้ามแทน Studio ด้วย regex/JS simulation
- **Traceability:** P5-R02..04,R08 / G-02..07,G-12,G-13

## Wave2 — Ace (owned files แยกรายตัว; ยังไม่อนุญาต parallel agents)

### A-01 — Ace model refinement + explicit rig map

- **ผู้รับผิดชอบที่เสนอ:** AGY-Char-Ace | **ก่อนเริ่ม:** P5-17; คงรายละเอียด baseline ตาม HANDOFF D-04
- **งาน/ส่งมอบ:** อ่าน characters/03-ace.md; ปรับ assets/rojo/HeroModels/Ace.rbxmx จากของเดิมและ map 6 joints; hat follows head, beads/dagger torso + hand/overhead attachments; เก็บ approved part budget/geometry
- **เกณฑ์ตรวจรับ:** ชื่อ/mapping/attachments ถูก; expected joints ready; ไม่ลดรายละเอียดเกินสิ่งอนุมัติ; model diff ไม่แตะของตัวอื่น
- **Traceability:** P5-R02,R08 / G-02,G-03,G-13

### A-02 — Ace signature animation

- **ผู้รับผิดชอบที่เสนอ:** AGY-Char-Ace | **ก่อนเริ่ม:** A-01
- **งาน/ส่งมอบ:** สร้าง Animations/Ace.luau ตาม contract version ที่ล็อก: Flame Finger / Hat Tip / Pillar Spawn / Hiken / Entei; ครบ idle/special/spawn/4 attack phases/ultimate ตามสเปก; cancel/reset/scale ใช้ context
- **เกณฑ์ตรวจรับ:** ดูท่าจริงทุก state/ความเร็ว; no drift/cue duplicate; flame attachments ตามมือและ Entei ก่อตัวเหนือมือก่อนขว้าง
- **Traceability:** P5-R03 / G-03,G-04

### A-03 — Ace VFX module

- **ผู้รับผิดชอบที่เสนอ:** AGY-Char-Ace | **ก่อนเริ่ม:** A-02; P5-10
- **งาน/ส่งมอบ:** สร้าง VFX/AceVFX.luau สำหรับ fire charge / projectile-beam / scorch rings / sunball; cue/quality/layers/intensity/TTL/cap และ passive cleanup ผ่าน registry wrappers
- **เกณฑ์ตรวจรับ:** animation-only/VFX-only/combo และทุก quality ทำงาน; target aligned; repeated passive start ไม่ซ้ำ; ไม่มี HP/economy write หรือ resource bypass
- **Traceability:** P5-R04 / G-05,G-07

### A-04 — Ace tests + Studio visual handover

- **ผู้รับผิดชอบที่เสนอ:** AGY-Char-Ace | **ก่อนเริ่ม:** A-01..03; P5-06
- **งาน/ส่งมอบ:** เพิ่ม tests/characters/ace_anim_vfx.spec.luau ตาม harness จริง; joint world delta, accessory relation, cancel/reset, cue/quality/layer/TTL/destroy; บันทึก visual checklist ข้อ §7 ของตัวละคร
- **เกณฑ์ตรวจรับ:** หลักฐานผูก actual ref; C0/C1/Size tolerance ตาม approved contract, no leak, manual visual ระบุคนตรวจ/มุม/state; ห้ามแทน Studio ด้วย regex/JS simulation
- **Traceability:** P5-R02..04,R08 / G-02..07,G-12,G-13

## Wave3 — Integration / verification / documentation

### P5-20 — รวม 3 signatures กับ legacy asset paths

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** L-04,Z-04,A-04 ที่ตรวจแล้ว; การอนุญาต integrate แยกจากแผนนี้
- **งาน/ส่งมอบ:** รวมเฉพาะ owned diffs เมื่ออนุญาต; ตรวจ contract version/aliases, mixed characters กับ legacy heroes, enemies/maps และ missing-character-module fallback
- **เกณฑ์ตรวจรับ:** 19 assets ยังโหลดได้; ไม่เพิ่ม hero catalog หรือเขียน registry จาก character stream; ไม่มี shared mutable per-model state
- **Traceability:** P5-R01,R08 / G-01,G-09,G-13

### P5-21 — Gameplay regression / isolation barrier

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core | **ก่อนเริ่ม:** P5-20,06,11
- **งาน/ส่งมอบ:** รัน verification manifest ที่ล็อก: existing Node suites + new Studio specs; replay damage oracle, place/swap/recall/sell, wave cards/stats, enemy HP/armor/slow, Lab controlled snapshots
- **เกณฑ์ตรวจรับ:** exact commands/cwd/ref/exits พร้อม limitation; failure ไม่ถูกลด assertion; ทุก blocked/unavailable ถูกเปิดเผย; gameplay+economy invariants ไม่เปลี่ยน
- **Traceability:** P5-R05,R06,R08 / G-06,G-08,G-11

### P5-22 — Measured stress / cleanup / visual acceptance

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core เก็บหลักฐาน / ผู้ตรวจ visual ยังไม่มอบหมาย | **ก่อนเริ่ม:** P5-20,21; methodology ล็อกก่อนวัด; budget ที่ยังรออนุมัติให้รายงานตามจริง
- **งาน/ส่งมอบ:** ทดสอบ 1/10/25/50 mixed heroes quality ที่อนุมัติ; warmup/steady/burst/cleanup, repeat reset/close/destroy; ตรวจครบ 3 character visual และ Lab UI controls
- **เกณฑ์ตรวจรับ:** มี actual device/build/ref/method/duration/percentiles/peak/resource delta; ไม่อ้าง 50 เป็น cap gameplay; budget หรือ visual ที่ยังขาดเป็น NOT VERIFIED
- **Traceability:** P5-R07 / G-07,G-09,G-10,G-12

### P5-23 — Documentation sync และ independent review handover

- **ผู้รับผิดชอบที่เสนอ:** AGY-Core เสนอ / Codex review | **ก่อนเริ่ม:** P5-20..22; D-07 ขอบเขตเอกสารได้รับอนุญาต
- **งาน/ส่งมอบ:** งานท้ายสุด: sync เอกสารที่อนุมัติตามผลงานจริง, root board/index references และ contract owner docs; ส่ง working-tree/base/current SHA, changed-path list, evidence; แก้ finding ใน scope ด้วย HANDOFF เดิม
- **เกณฑ์ตรวจรับ:** Codex ตรวจ scope/spec drift ของทุก doc และ diff ณ ref ล่าสุด; stable F-ID ใน review-NNN; no unresolved blockers/stale SHA; Owner ตัดสินรับงานเอง; AGY commit/push ได้เฉพาะ milestones ที่ผู้ใช้อนุญาตตาม HANDOFF; ไม่ merge/deploy/ปิดงานเอง
- **Traceability:** P5-R01..08 / G-13 และ final gate

## การส่งตรวจ/แก้ไขในอนาคต

AGY ส่ง actual ref และ working-tree diff พร้อมผลแยก 4 ประเภท; Codex ลง verdict/findings ใน assets/review-NNN.md ต่อรอบ โดยคง F-ID เดิมสำหรับปัญหาเดิม AGY เขียน assets/fix-NNN.md เมื่อได้รับมอบหมายแก้ ใช้ HANDOFF เดิมสำหรับ in-scope correction ไม่มีการสร้างรายงานเหล่านี้ล่วงหน้า และใช้ milestone commit/push ที่ผู้ใช้อนุญาตตาม HANDOFF ล่าสุดเพื่อ SHA tracking; Codex ตรวจรวม final SHA
