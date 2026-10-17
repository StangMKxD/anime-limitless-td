# P09 — Per-player Visual Settings, Accessibility และ Device Quality

สถานะ: DRAFT / REVIEW ONLY / IMPLEMENTATION NOT AUTHORIZED  
Baseline: main @ 5d0caed21aa61021790a3456cda322d16445edea | วันที่: 17 ตุลาคม 2026 (Asia/Bangkok)  
Requirements: R-04, R-05, R-07; Phase เสริมเสนอใหม่  
Plan Owner: Stang | Controller/Reviewer: Codex | Proposed implementer: AGY Teamwork-preview (ยังไม่มอบหมาย)  
ไม่มี application tests หรือ Studio/manual verification ในรอบนี้; ผล runtime ทั้งหมด NOT VERIFIED  
อ่าน [Integration & Contract Review](00-integration-contract-review.md) และ [HANDOFF กลาง](assets/HANDOFF.md) ก่อนเสมอ

## 1. เหตุผลและผลลัพธ์

ผู้เล่นเลือกความสวย/ความลื่นและลด camera shake, flash, motion ได้เอง ภาพสำคัญยังอ่านได้บนมือถือและอุปกรณ์ช้ากว่า การลดคุณภาพเปลี่ยนเฉพาะภาพ ไม่ลด tick rate, damage, attack cadence หรือจำนวนศัตรูทาง server

Phase นี้เป็นส่วนเสริมที่เสนอ ไม่มีการเปิดใช้หรือเปลี่ยน default ของผู้เล่นในรอบนี้

## 2. Baseline และขอบเขต

[VFXContract](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Shared/VFXContract.luau#L166) มี quality/layerFlags; [VFXDispatcher](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track2_TowerSystem/VFXDispatcher.luau#L50) มี global module preference  
[HUD](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track3_UISystem/UpgradeHUD.client.luau#L237) มี camera/flash handling อยู่แล้ว ต้องเชื่อมผ่าน sink เดียว  
[UNKNOWN] device performance ปัจจุบัน/อุปกรณ์เป้าหมายและ default ที่ผู้ใช้ต้องการ จึงไม่อ้างว่า Auto mode มี threshold ที่อนุมัติแล้ว

In scope: client-session preferences, settings panel, accessibility toggles, adapter ให้ services consume, measured quality recommendation  
Out of scope: DataStore/cloud persistence, account sync, monetization, dependency upgrades, broad performance refactor และการลด geometry/assets โดยไม่อนุมัติ

## 3. Strict ownership

เสนอไฟล์ใหม่:
- src/Presentation/PresentationPreferences.luau
- src/Presentation/QualityPolicy.luau
- src/ClientSettings/SettingsPanel.luau
- src/ClientSettings/SettingsBootstrap.client.luau
- tests/planning-followup/preferences/

Integration owner เพิ่ม mapping/contract C-07 และ wiring; P09 ไม่แก้ default.project.json  
P05 มีปุ่ม Settings และ modal priority เท่านั้น ไม่ทำ panel ซ้ำ  
P04 แก้ dispatcher ให้รับ preferences จาก C-07 ในไฟล์ที่ตนเป็นเจ้าของ; P09 ไม่แก้ dispatcher  
P01 Lab override quality ใช้ session-local override ไม่เขียน global preference ของผู้เล่นเงียบ ๆ

## 4. Settings ที่เสนอให้รีวิว

| Setting | ตัวเลือก / พฤติกรรม | สิ่งที่ต้องรักษา |
|---|---|---|
| VFX Quality | Low / Medium / High; Auto เป็น optional หลังมี measurements | ไม่เปลี่ยน damage/timer |
| Camera Shake | Off / Reduced / Full | camera ownership และ zero drift |
| Screen Flash | Off / Reduced / Full | impact ยังอ่านได้จาก local geometry |
| Decorative Aura | Off / On | target outline/healthbar ไม่หายตาม |
| Reduced Motion | On/Off | ลด camera/overlay/transitions; ท่าหลักและ timing คงเดิม |
| UI Scale | ช่วงที่อนุมัติหลังตรวจ layout | ไม่ทำปุ่มหรือข้อมูลสำคัญหลุดขอบ |
| Readability | label+icon/high-contrast status options | ไม่พึ่ง rarity color เพียงอย่างเดียว |
| Reset visual settings | คืนค่าที่ประกาศชัด | ไม่ reset gameplay attributes |

ทั้งหมดเป็น session-only ใน scope ฐาน ปิดเกมแล้วอาจกลับ default ต้องสื่อสารให้ตรง ไม่อ้าง save ถาวร  
defaults, UI scale min/max และ Auto policy ยังต้อง approve; ไม่เลือกจากชื่อ path/locale หรือจากความสามารถเครื่อง Codex

## 5. C-07 ที่ต้องล็อก

Preferences schema version=1, quality, cameraShakeMode, flashMode, decorativeAura, reducedMotion, uiScale  
GetSnapshot/Subscribe/SetLocal/ResetLocal ใช้ local client state; whitelist enum และ finite numbers; listeners ต้อง unsubscribe ได้  
ไม่มี RemoteEvent ส่ง settings ไปเปลี่ยน combat server และไม่มี API รับ arbitrary module/Instance path  
priority: explicit Lab session override > per-player explicit setting > approved default; close Lab แล้วคืน preference เดิม  
settings mutation แสดงผลทันทีโดยไม่สร้าง renderer/listener ใหม่ทุกครั้ง

Auto mode หากได้รับอนุมัติ: ใช้ rolling client frame-time ที่วัดจริง, hysteresis/cooldown และไม่กระโดด tier ทุก frame; clamp ไม่ต่ำกว่าระดับ readability ที่ตกลง  
ร่างนี้ยังไม่กำหนด threshold ตัวเลขเป็นมาตรฐาน เพราะไม่มี device measurements ให้รองรับ

## 6. งานย่อยที่เสนอหลังอนุมัติ

| Task | ผลส่งมอบ | เกณฑ์ตรวจ |
|---|---|---|
| P09-01 | settings/defaults/consumer inventory และ scope decision | ไม่มี setting ที่แอบแก้ game stats |
| P09-02 | Preferences module/validation/subscription lifecycle | local per-client, Reset ไม่กระทบ cash/inventory |
| P09-03 | panel แยกจาก HUD พร้อม input/modal accessibility | touch/gamepad/keyboard ปิดเปิดและคืน focus |
| P09-04 | adapters ที่ P04/P05/P01 consume ผ่าน C-07 | ไม่มี file ownership overlap |
| P09-05 | quality measurement/recommendation หรือ optional Auto design | มีข้อมูลจริงก่อนตั้ง threshold |
| P09-06 | acceptance evidence และ proposed docs amendments | ค่า default/persistence ที่สื่อสารตรง implementation |

## 7. Acceptance scenarios

1. สอง clients เลือก quality ต่างกัน → ภาพต่างกันได้ แต่ HP/damage/reward/server state เหมือนเดิม
2. Shake Off/Flash Off → ไม่สร้าง camera/flash effects ที่ซ่อนอยู่; ไม่ทิ้ง offset ค้าง
3. เปิด Lab ใช้ override High แล้วปิด → คืน preference ก่อนเปิด ไม่ค้างทั้ง gameplay
4. สลับ quality/Reduced Motion 50 ครั้ง → listener/resource count ไม่โต
5. Settings panel ไม่แย่ง gamepad focus จาก card draft; Escape/Back คืน focus ตามลำดับ
6. UI scale ที่ boundary ทุก device target → ปุ่ม/labels ยังเข้าถึงได้
7. malformed settings input/unknown enum/NaN → reject/clamp ตาม contract ไม่ crash
8. Auto ถ้าทำ: frame-time ใกล้ threshold → ไม่มี oscillation; report actual environment และผล ไม่อ้าง improvement หากไม่มี before/after
9. ไม่มี performance/manual evidence → ระบุ NOT VERIFIED ไม่ปิดงานเพียงเพราะมี settings controls

## 8. Dependencies / rollback

P09 preferences/panel ทำขนาน P05 ได้หลัง C-07 freeze; P04 ต้อง consume settings ก่อนประกาศครบ end-to-end  
ถ้าต้องใช้ profiling พบ bottleneck ใน server/combat ให้บันทึก follow-up ไม่ refactor ข้าม scope  
rollback ถอน Settings bootstrap/prefs adapters คืน approved defaults ผ่าน owner files ไม่แตะ save data เพราะไม่ได้เพิ่ม persistence

## 9. Copy-ready prompt สำหรับ AGY — review only

~~~text
รีวิว P09 และเสนอ settings/accessibility/device-quality plan โดยยังไม่ implement
อ่าน VFX quality/layers และ HUD camera behavior จริง แล้วร่าง per-player local preferences contract
ระบุ exact files, defaults ที่ต้องให้ผู้ใช้เลือก, Lab override precedence, input/modal flow และ evidence plan
ห้ามเพิ่ม persistence/Remote gameplay authority หรือเปลี่ยน damage/tick rate เพื่อให้ FPS ดูดีขึ้น
Auto thresholds ต้องเป็นข้อเสนอรอ device evidence; ห้ามอ้างผลปรับปรุงจากการคาดเดา
ห้ามแก้ code/config/assets/canonical docs, รัน application tests, spawn, commit หรือ push
ส่งแผนกลับให้ผู้ใช้และ Codex รีวิวก่อนอนุมัติพัฒนา
~~~

