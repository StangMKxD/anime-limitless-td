# P05 — Roblox-style Lobby, Gameplay HUD และ Map Selection View

สถานะ: DRAFT / REVIEW ONLY / IMPLEMENTATION NOT AUTHORIZED  
Baseline: main @ 5d0caed21aa61021790a3456cda322d16445edea | วันที่: 17 ตุลาคม 2026 (Asia/Bangkok)  
Requirements: R-01, R-05, R-06, R-07  
Plan Owner: Stang | Controller/Reviewer: Codex | Proposed implementer: AGY Teamwork-preview (ยังไม่มอบหมาย)  
ไม่มี application tests หรือ Studio/manual verification ในรอบนี้; ผล runtime ทั้งหมด NOT VERIFIED  
อ่าน [Integration & Contract Review](00-integration-contract-review.md) และ [HANDOFF กลาง](assets/HANDOFF.md) ก่อนเสมอ

## 1. เป้าหมาย

หน้าเกมดูเป็นผลิตภัณฑ์เดียวกัน: lobby hub ที่มี CTA ชัด, HUD อ่าน wave/base/cash ได้ทันที, ปุ่ม summon/upgrade/inventory วางเป็นระบบ, map selector แสดงชื่อ/ธีม/สถานะที่ server ตัดสินจริง และทุกคำสั่งเดิมยังเข้าถึงได้บน mouse/touch/gamepad

งานนี้เปลี่ยน presentation และ interaction layout ไม่เพิ่ม matchmaking, teleport, monetization, daily rewards หรือระบบ inventory ใหม่

## 2. Baseline

[UpgradeHUD.client.luau](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track3_UISystem/UpgradeHUD.client.luau#L222) สร้าง AnimeLimitlessPhase3HUD และรวม camera shake, upgrades, gacha, bag/slots, draft cards และ refresh หลายส่วนในไฟล์เดียว  
[camera ownership](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track3_UISystem/UpgradeHUD.client.luau#L237) อยู่ที่ HUD เดิม; [bag/slot flow](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track3_UISystem/UpgradeHUD.client.luau#L850) อ่าน GameConfig.PLACEMENT_SLOTS โดยตรง  
[early start](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track3_UISystem/UpgradeHUD.client.luau#L442) มีคำสั่งเดิมที่ต้องรักษา

[UNKNOWN] visual quality ของ current Studio build และภาพแนบเดิมยังไม่ได้ตรวจ จึงใช้ข้อเสนอ layout ใหม่เป็นร่าง ไม่อ้างว่าตรงภาพ reference ที่มองไม่เห็น

## 3. Scope / ownership

P05 แก้เฉพาะ UpgradeHUD.client.luau; เพิ่ม Views/ และ UIComponents/ ใต้ src/Track3_UISystem/; tests ของตนที่ tests/planning-followup/ui/  
ห้ามแก้ UpgradeServer/TowerController/WaveManager, GameConfig, MapCatalog, map services หรือ DevTools  
P06 เป็นเจ้าของ map selection state/policy ฝั่ง server; P05 เป็นเจ้าของหน้าต่างเลือก map  
P09 เป็นเจ้าของ settings panel/service แยก namespace; P05 ทำเพียงปุ่มเปิดตาม C-07 ที่เสนอ ไม่ทำ settings panel ซ้ำ

camera/flash feedback sink ที่ HUD เป็นเจ้าของต้อง expose local port ตาม C-03; Integration เรียก port จาก client bootstrap ไม่เข้ามาแก้ HUD file พร้อม P05

## 4. Art direction และ layout ที่เสนอ

- ใช้ panel มุมโค้ง ขอบ/เงาสม่ำเสมอ สีหลักเข้มสะอาดและ accent anime ที่จำกัดจำนวน
- สี hero rarity ต้องมี label/icon รองรับ ไม่ใช้สีเพียงอย่างเดียว
- เลขเงิน/wave/base HP เป็นลำดับความสำคัญแรก; ลด glow ที่ขอบตัวอักษรจนอ่านยาก
- ใช้ typography hierarchy เดียวกัน ปุ่ม primary/secondary/destructive แยกชัดพร้อม pending/disabled/failure state
- transition สั้นและ cancel ได้; keyboard/gamepad focus เห็นชัด; reduced motion ใช้ preference ของ P09
- ไม่เพิ่ม theme/icon/font dependency หรือ asset IDs โดยไม่ได้อนุมัติ

| Surface | เนื้อหาและจุดใช้งาน |
|---|---|
| Lobby hub | title/hero backdrop แบบเบา, เล่นต่อ/เข้าดูสมรภูมิ, เลือก map, inventory, settings; Studio Lab launcher เฉพาะ Studio |
| Top HUD | wave/status/countdown, enemies remaining, base HP bar, cash/tokens/tickets ตามค่าจริง |
| Bottom action dock | summon, bag/slots, upgrades, cards; action สำคัญไม่หลบใต้ safe area |
| Tower inspect | selected unit/slot/owner/stats, place/swap/store/sell ตามระบบเดิม |
| Map selector | 4 map cards, thumbnail หรือ procedural preview, theme, vote count, locked/current map, deadline |
| Card draft | 3 cards, reroll/pending draws ตาม server state, modal focus ไม่ทะลุไปคลิก pad |
| Error feedback | remote unavailable, insufficient cash, invalid slot, stale map vote; retry ที่ไม่ซื้อ/สุ่มซ้ำโดยไม่ตั้งใจ |

Lobby ที่แนะนำเป็น client hub overlay ของ session เดิม ไม่มี private lobby place หรือ server pause  
หากเข้ามาขณะ wave กำลังเดิน UI ต้องแสดงว่า match กำลังเล่น ปุ่มดูสนามไม่หลอกว่าเริ่มเกมใหม่; เปิด lobby ไม่หยุดเวลาของผู้อื่น  
ปุ่ม map selection ใช้ได้เฉพาะ selection state ที่ server เปิด ถ้าล็อกแล้วแสดง read-only/รอบหน้า ไม่สร้าง reset flow เอง

## 5. Behavioral parity matrix

| Flow เดิม | ต้องคง | ตรวจกรณีผิดพลาด |
|---|---|---|
| Upgrade Damage/Range/Speed | payload, server formula, affordability, pending feedback | คลิกซ้ำ/latency/เงินไม่พอ |
| Summon/Reroll | ticket/cash/token ใช้กฎเดิม, hero weights เดิม | pending ห้ามสั่งซ้ำจาก double input |
| Bag select/sell | Uid/HeroId, selected state, ราคาเดิม | unit ถูกใช้/response เก่า/ownership ไม่ตรง |
| Place/swap/store/sell | Slot_1..Slot_8, tower cap/ownership และ costs เดิม | pad occupied/unknown/stale slot |
| Card draft | choices/draw count/reroll และ apply effects ฝั่ง server | modal ซ้ำ/selection race |
| EarlyStart | command เดิม, condition เดิม | map not Ready ต้องให้ server policy จัดการ |
| GameOver/reset | อ่านสถานะที่ server ส่ง | client ห้าม reset เงิน/เวฟ/HP เอง |

UI disable/debounce เป็น UX ไม่แทน server validation; ห้ามย้าย logic คำนวณซื้อ/ขาย/สุ่มมาเป็น authority ฝั่ง client

## 6. งานย่อยที่เสนอหลังอนุมัติ

| Task | งาน | Dependency / ตรวจรับ |
|---|---|---|
| P05-01 | inventory widgets/actions/remotes และ behavioral parity matrix | baseline HUD/server source ตรงกันก่อนจัด layout |
| P05-02 | wireframe ของ lobby/HUD/tower inspect/map selector และ design tokens | ผู้ใช้ตรวจทิศทางภาพก่อน implementation |
| P05-03 | แยก view/components แบบคง remote behavior | ไม่มี duplicate GUI/connection เมื่อ respawn |
| P05-04 | ต่อ summon/upgrade/bag/slots/cards ตามเดิม | mouse/touch/gamepad ใช้ทุก action ได้ |
| P05-05 | map selection view รับ server snapshots และ handle rejects | C-05/C-06, P06; UI ไม่เปลี่ยน map เอง |
| P05-06 | camera feedback/local modal focus port + เปิด Settings/Lab | C-03/C-07/C-04; ไม่เขียนกล้องพร้อม Lab |
| P05-07 | visual/input/runtime evidence และเสนอ docs sync | แยก manual NOT VERIFIED เมื่อไม่มีหลักฐาน |

## 7. Acceptance scenarios

1. Desktop 1280×720 และขนาดใหญ่: ข้อมูลหลักไม่ถูก modal/action dock บัง
2. Touch portrait/landscape: ปุ่มหลักกดได้ ไม่ใช้ hover/right-click เป็นวิธีเดียว; safe area ไม่ทับปุ่มระบบ
3. Gamepad: เปิด/ปิด modal และเลือก cards/maps/units ด้วย focus navigation ได้
4. กดเปิดหลาย panel → modal priority/focus ชัด; ปิดแล้วคืน focus/การเลือก slot เดิม
5. remote ช้าหรือ unavailable → แสดง pending/error ไม่ค้าง infinite wait และไม่สูญเงินจาก UI retry อัตโนมัติ
6. จำนวน GUI/listeners คงที่หลัง respawn/open-close 10 รอบ
7. map vote เปลี่ยน/ล็อก/หมดเวลา/late join → UI ตรง server; selected ไม่เท่ากับ active จน Ready
8. Lab เปิด → gameplay camera shake ถูกพัก; close แล้วคืนภาพ/input ตามเดิม
9. ทุก flow ใน parity matrix เทียบ baseline ไม่ตกหล่น; ไม่ยกเลิก Feature เดิมเพียงเพราะไม่มีพื้นที่หน้าจอ
10. มี named manual observation พร้อม device/ref หรือระบุ ManualVisual NOT VERIFIED; ไม่บังคับภาพ/วิดีโอ

## 8. ความเสี่ยง / ขนาน / rollback

P05 ทำ view กับ frozen map/settings fixtures ขนาน P01/P02/P06/P09 ได้; fixture เป็น test-only มีสถานะจำลองชัด ไม่แสดง fake success ใน production  
หากต้องแก้ same HUD file ให้หลายคนทำ ให้หยุดและรวมเป็น writer เดียว ไม่แบ่งตามบรรทัด  
rollback คืน HUD entrypoint/view เดิมแบบเฉพาะไฟล์เจ้าของผ่าน Integration process; ไม่ reset attributes หรือแก้ upgrade server

## 9. Copy-ready prompt สำหรับ AGY — review only

~~~text
รีวิวร่าง P05 เป็นงานออกแบบเท่านั้น
อ่าน HUD เดิม, server callsites ที่รองรับ actions, AGENTS/READ และ contracts กลาง
ส่ง lobby/HUD/map selector wireframes, design tokens, parity matrix และ input/modal/camera plan
ยืนยันว่าทุก flow เดิมยังอยู่ และระบุ UI states สำหรับ pending/error/stale response
แยกเจ้าของ P05 UI, P06 map server, P09 settings และ P01 Lab ให้ชัด
ห้ามเปลี่ยน game rules, code/config/assets/canonical docs, รัน application tests, spawn, commit หรือ push
ส่งเฉพาะแผนละเอียดและ decision requests ให้ผู้ใช้และ Codex ตรวจ ก่อนอนุมัติพัฒนา
~~~

