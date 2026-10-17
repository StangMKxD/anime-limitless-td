# P06 — Multiple Maps, Map Selection และ Server Map Lifecycle

สถานะ: DRAFT / REVIEW ONLY / IMPLEMENTATION NOT AUTHORIZED  
Baseline: main @ 5d0caed21aa61021790a3456cda322d16445edea | วันที่: 17 ตุลาคม 2026 (Asia/Bangkok)  
Requirements: R-05, R-06, R-07  
Plan Owner: Stang | Controller/Reviewer: Codex | Proposed implementer: AGY Teamwork-preview (ยังไม่มอบหมาย)  
ไม่มี application tests หรือ Studio/manual verification ในรอบนี้; ผล runtime ทั้งหมด NOT VERIFIED  
อ่าน [Integration & Contract Review](00-integration-contract-review.md) และ [HANDOFF กลาง](assets/HANDOFF.md) ก่อนเสมอ

## 1. เป้าหมาย

มีแผนที่ที่เลือกได้หลายธีม ดูต่างกันชัดทั้งพื้น ฉากหลัง landmark และ lighting palette พร้อม UI เลือกที่สะท้อนผล server จริง หลังโหลดมี route, 8 pads, spawn และ base ตรงกัน ไม่มีศัตรูเดินบนทางเก่าหรือฮีโร่ถูกวางผิดตำแหน่ง

ข้อเสนอเริ่มต้นคือ 4 maps รวม default เดิม; จำนวน/ชื่อ/ธีมเป็น PROPOSED รอผู้ใช้รีวิว ไม่อ้างว่ามี map system สมบูรณ์แล้ว

## 2. Baseline ที่ทำให้ต้องมี integration hooks

- [WaveManager:14–21](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track1_WaveSystem/WaveManager.server.luau#L14) hardcode WAYPOINT_COORDS 6 จุด
- สร้างฉากใน ensureMapAndWaypoints :46; enemy spawn :241/:269 และเดิน :535–536 ใช้ array นี้ตรง ๆ ไม่ได้อ่าน Part positions ใน Workspace อย่างเดียว
- [TowerController:2236](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track2_TowerSystem/TowerController.server.luau#L2236) สร้าง pads จาก GameConfig.PLACEMENT_SLOTS; place/swap :2143–2156 อ่านพิกัดเดิมเช่นกัน
- [HUD:926](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/Track3_UISystem/UpgradeHUD.client.luau#L926) ใช้ slot list จาก GameConfig
- [VisualBridge:264](https://github.com/StangMKxD/anime-limitless-td/blob/5d0caed21aa61021790a3456cda322d16445edea/src/AssetKit/VisualBridge.server.luau#L264) ผูก decoration กับ GrandLineMap/Waypoints แบบเดิม
- เปลี่ยนฉาก/waypoint Parts เพียงอย่างเดียวจึงไม่ทำให้ gameplay ใช้ map ใหม่ ต้องให้ Integration ต่อทุก consumer
- map/prep ปัจจุบันเริ่มจาก startWaveLoop :632 และ early start; ห้ามเพิ่มรอเลือก map จน flow เปลี่ยนโดยไม่ได้อนุมัติ

## 3. Scope / ownership

P06 สร้างเฉพาะไฟล์ใหม่ใต้ src/Track1_WaveSystem/Maps/:
- MapService.luau
- MapSelectionService.luau
- Builders/Marineford.luau
- Builders/SakuraHarbor.luau
- Builders/SkySanctuary.luau
- Builders/VolcanicCitadel.luau

และ tests/planning-followup/maps/  
Shared/MapContract, MapCatalog, GameConfig, WaveManager, TowerController, VisualBridge และ default.project.json เป็น Integration owner  
P06 ส่ง proposed catalog data ให้ Integration เขียน; P05 เป็นเจ้าของ selector view เท่านั้น

ไม่แก้ assets/rojo/MapModels เดิม; builders อ้าง template 3 ตัวเดิมเป็น clone-only และสร้าง environment ภายใน namespace map ที่ตนเป็นเจ้าของ  
ห้ามเพิ่ม pathfinding, multiple lanes, hazards, reward multipliers, unlock progression หรือ terrain engine migration ใน scope ฐาน

## 4. Map art matrix ที่เสนอ

| Map ID ชั่วคราว | ธีม | Landmark / readability | Gameplay layout |
|---|---|---|---|
| Marineford | ป้อมริมทะเล / default | plaza, sea wall, gate, Poneglyph base | พิกัด baseline ทุกจุดเดิม |
| SakuraHarbor | เมืองท่าไม้/ซากุระ | สะพานฉากหลัง โคมไฟ กลีบซากุระเบา | route/pads/base เทียบเท่า baseline |
| SkySanctuary | วิหารบนเกาะเมฆ | pillars, suspended islands, cloud backdrop | เส้นทางราบเดิม; ไม่มีตกขอบที่ทำ HP เปลี่ยน |
| VolcanicCitadel | ป้อมภูเขาไฟ | basalt, lava channels นอก lane, warm lighting | ไม่มี lava damage/slow/hazard |

ชุดแรกใช้ art-biome variation ที่เดินและต่อสู้ได้เหมือนเดิม; ไม่ติด label difficulty ใหม่ที่ไม่มีข้อมูล  
หากผู้ใช้ต้องการเส้นทางคดเคี้ยว/หลายเลน/map-specific pads ให้เสนอ P06 expansion พร้อมผลต่อ travel time, range overlap, base arrival และความยากก่อน ไม่ลักลอบใส่ใน builders  
thumbnail ใช้ assets ที่มีสิทธิ์และพร้อมจริง หรือ preview ที่สร้างจาก scene; ไม่ fabricate uploaded IDs

## 5. Lifecycle / selection policy ที่เสนอให้อนุมัติ

ใช้ C-05/C-06:
1. Preload/validate catalog โดยไม่มี wave หรือ tower เพิ่ม
2. เปิดการเลือกภายใน preparation window เดิมที่ตกลงไว้ ไม่เพิ่ม lobby countdown ใหม่
3. หนึ่งผู้เล่นหนึ่ง vote; tie/no-vote ใช้ Marineford คงที่
4. เมื่อ lock ใช้ selected ID เดียวทั้ง server; no mid-wave switching
5. Build scene แบบ off-tree หรือ staging namespace ให้ validation ผ่านก่อน publish active world
6. ยืนยัน ordered 6 waypoints, Slot_1..8, spawn/base, path clearance, bounds/camera metadata
7. publish mapRevision/Ready แล้วจึงอนุญาต wave/early-start ตามเงื่อนไขเดิม
8. late join ได้ snapshot ของ active map; client ห้าม load world จาก vote ของตนเอง

ประเด็นต้องตัดสินก่อน implementation: แผนที่ build ไม่ทัน prep/early-start จะ block อย่างไรโดยไม่เปลี่ยนเวลารอบเดิม; ข้อเสนอ preload default ก่อนและเลือกเฉพาะ validated/prebuilt map ในหน้าต่างเดิม หากทำไม่ได้ให้ CR ปรับ flow แยก  
การโหวตแผนที่เป็นระบบใหม่ที่ผู้ใช้ขอให้เสนอ ไม่ได้หมายถึงมีสิทธิ์เปลี่ยน server lifecycle ทันที

## 6. งานย่อยที่เสนอหลังอนุมัติ

| Task | ผลส่งมอบ | เกณฑ์ตรวจ |
|---|---|---|
| P06-01 | consumer audit ของ route/pads/base/spawn/camera/decoration | ระบุ hardcoded paths/coords ทุกจุดส่ง Integration |
| P06-02 | MapDefinition/schema + catalog proposal 4 maps | stable IDs, baseline layout checksum/coordinates เทียบกัน |
| P06-03 | MapService build/validate/ready/cleanup/rollback | invalid scene ไม่ถูก publish; no partial world |
| P06-04 | MapSelectionService validation/vote/revision/deadline/late join | server authority, idempotency และ midmatch reject |
| P06-05 | builders 4 themes | lane/pads/readability ต่างทางภาพแต่ logic เทียบ baseline |
| P06-06 | ส่ง hooks ให้ Integration และ snapshots ให้ P05 | wave/tower/HUD ใช้ active map เดียวกัน |
| P06-07 | runtime regression และ proposed docs amendments | ไม่เปลี่ยน scope/spec เกินสิ่งที่อนุมัติ |

## 7. Failure / reset / state preservation

- unknown mapId, invalid type/NaN revision, stale request, rate spam, locked state → reject พร้อม code ไม่ crash
- duplicate requestId ไม่สร้าง vote/scene ซ้ำ; player disconnect ถอน vote เฉพาะก่อน lock
- build failure → default ที่ validated พร้อมก่อน start; ไม่เปลี่ยน map กลางเวฟเพื่อแก้ error
- preserve server cash/stats/inventory/cards และ reward path; ห้ามล้างผู้เล่นเพื่อทำ map reset ง่ายขึ้น
- map cleanup ทำเฉพาะ namespace ของ map/visuals ไม่ใช้ Workspace:ClearAllChildren()
- map/global Lighting และ Terrain ใช้ save/restore scope เดียว ไม่ทับ Lab lighting หรือ UI effects; เริ่มด้วย map-contained lights ถ้าเป็นไปได้
- destroy map ไม่ฆ่า active enemies/towers ระหว่าง Playing; phase change ต้องเป็น server decision ที่อนุมัติ
- game-over loop เดิมเริ่ม prep รอบใหม่; การเลือก map รอบถัดไปต้องใช้นโยบายเดิมที่ล็อก ไม่เพิ่ม reset behaviors เอง

## 8. Acceptance scenarios

1. default/no-vote → Marineford เริ่มด้วย route/pads/base และ resources เหมือน main baseline
2. 4 maps selectable → UI และ server lockedMapId ตรงกัน; แต่ละธีมมี identity ชัดโดยยังอ่าน lane
3. vote สอง clients/เปลี่ยน vote/tie/disconnect/late join → deterministic result ตาม C-06
4. vote หลัง lock/ระหว่าง wave หรือ malformed payload → reject ไม่มี map mutation
5. early start ระหว่าง selection/build → ไม่มีศัตรูเกิดบน map ไม่พร้อม และไม่มีเปลี่ยน prep timing เงียบ ๆ
6. เดิน enemy จาก spawn ถึง base ครบ 6 จุดทุก map; รวม travel length เทียบ baseline และ base damage เดิม
7. place/swap/store/sell บน Slot_1..8 → server ตำแหน่ง, pads, range rings, UI ตรงกัน
8. map model/asset หาย → fallback เป็น default ไม่ทำให้ผู้เล่นเสีย inventory/cash
9. game-over/รอบใหม่/cleanup ซ้ำ → ไม่มี scene, lights, connections เพิ่มสะสม
10. เปรียบเทียบ HP/rewards/wave scaling/cadence บน baseline layout; manual map visuals หากไม่ได้ดูจริงให้ NOT VERIFIED

## 9. Dependencies / parallel / rollback

P06 ทำ builders/selection service ขนาน P01/P02/P05 หลัง C-05/C-06 freeze  
P05 ใช้ snapshots/metadata ที่ตกลงเท่านั้น; ห้าม hardcode catalog อีกชุดใน UI  
Integration lead ทำ hooks ทุก consumer แบบ sequential และเป็นเจ้าของ shared file เพียงรายเดียว  
rollback คืน default Marineford route/catalog adapter และปิด selection entrypoint โดยไม่ reset player state

## 10. Copy-ready prompt สำหรับ AGY — review only

~~~text
รีวิวร่าง P06 และเสนอแผน multiple maps/map selection ที่รักษา gameplay
ตรวจ hardcoded WAYPOINT_COORDS ในการสร้างฉาก การ spawn และการเดิน รวม GameConfig slots,
TowerController placement, HUD และ VisualBridge แล้วส่ง consumer integration map
เสนอ 4 theme maps แบบ layout-equivalent, exact builders/service ownership,
vote/lock/Ready lifecycle, validation/fallback และ early-start compatibility
แยก layout/flow ใหม่ที่ต้อง CR ไม่ใช้ข้อเสนอเพิ่ม map เป็นสิทธิ์เปลี่ยน balance
ห้ามแก้ code/config/assets/canonical docs, รัน application tests, spawn, commit หรือ push
ส่งกลับเฉพาะแผนและรายการตัดสินใจให้ผู้ใช้และ Codex รีวิวก่อน implementation
~~~

