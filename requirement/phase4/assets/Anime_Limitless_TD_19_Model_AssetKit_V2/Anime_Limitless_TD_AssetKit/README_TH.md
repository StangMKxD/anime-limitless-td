# Anime Limitless TD — 3D Asset Kit (19 Models)

**ชนิดไฟล์:** `.rbxmx` (Roblox XML Model จริง) + `VisualBridge.server.luau` + Python installer  
**อ้างอิง:** `StangMKxD/anime-limitless-td` สาขา `main` ที่อ่านวันที่ 16 ต.ค. 2026  
**ขอบเขต:** 12 Hero, 4 Enemy, 3 Map = **19 Model**, รวม **1,676 Sculpted BaseParts (V2 High-Detail One Piece Masterpiece Edition)** โดยประมาณ  
**สถานะทดสอบ:** ผ่าน static XML validation และ mapping validation; **ยังไม่ได้ import/playtest ใน Roblox Studio**  
**หมายเหตุ:** โมเดลเป็น **stylized blocky cosmetic** ไม่ใช่ MeshPart high-poly, ไม่ใช่ R6 animation rig ที่มี Motor6D/Animator

## ทำไมโมเดลอย่างเดียวไม่ขึ้นในเกม?

โค้ดปัจจุบันของ Repo `TowerController.server.luau` ใช้ฟังก์ชัน `buildDetailedOnePieceModel()` สร้าง Part ด้วยตัวเอง และ `WaveManager.server.luau` สร้างศัตรู Part ด้วย `spawnEnemy()` ไม่ได้ `Clone` จาก ReplicatedStorage ดังนั้นเพียงวางไฟล์ใน HeroModels/EnemyModels **ไม่เพียงพอ**

ชุดนี้เพิ่ม `VisualBridge.server.luau` ติดตาม `Workspace.AnimeTowers` และ `Workspace.Enemies` แล้วสวมชุดโมเดล 3D เป็น Visual Layer ของ Model เดิมโดยใช้ `WeldConstraint` ยึดกับ `HumanoidRootPart` เดิม **ไม่แก้ HP/Speed/Damage, ไม่ลบระบบ Attack VFX, ไม่แก้โมดูลเดิม**

**ข้อจำกัด:** แขน/อาวุธของ cosmetic model ไม่ทำ animation ตามแขน Legacy แบบแยกชิ้น แต่ตัวละครเคลื่อนไหวตาม Root เดิมระหว่างโจมตีและศัตรูเดินตาม waypoint ตามโค้ดเดิม

## โมเดลที่มี

| Folder | รายการ |
|---|---|
| `ReplicatedStorage/HeroModels` | `Luffy`, `Zoro`, `Nami`, `Usopp`, `Sanji`, `Chopper`, `Robin`, `Shanks`, **`Whitebeard`, `Ace`, `Law`, `Kizaru`** |
| `ReplicatedStorage/EnemyModels` | `PirateGrunt`, `SoruAssassin`, `HakiBrute`, `YonkoBoss` |
| `ReplicatedStorage/MapModels` | `AnimeBaseCrystal`, `EnemySpawnGate`, `PlacementPadTemplate` |

`Nami`, `Usopp`, `Chopper`, `Robin` เป็น Asset ที่เตรียมไว้ **ยังไม่สามารถสุ่มได้จาก GameConfig ปัจจุบัน** เพราะ Hero Catalog ใน Repo มี 8 ตัวแตกต่างกัน หากต้องการใช้ครบ 12 Hero ต้องเพิ่ม HeroSpecs, กำหนด Weight รวมให้เหมาะสม, เพิ่ม AttackStyle/VFX และตรวจ UI กาชาแยกต่างหาก

### ตาราง ID ที่เชื่อมกับเกมปัจจุบัน

| Hero ID ที่ TowerController ใช้ | โมเดลที่โหลด |
|---|---|
| `Tower_Luffy_G5` | `Luffy` |
| `Tower_Zoro_KingOfHell` | `Zoro` |
| `Tower_Sanji_Ifrit` | `Sanji` |
| `Tower_Shanks_Kamusari` | `Shanks` |
| `Tower_Whitebeard_Gura` | `Whitebeard` |
| `Tower_Ace_Entei` | `Ace` |
| `Tower_Law_KRoom` | `Law` |
| `Tower_Kizaru_Pika` | `Kizaru` |

| Name ของ Enemy ที่ WaveManager สร้าง | โมเดลที่โหลด |
|---|---|
| `Thriller Bark Zombie` | `PirateGrunt` |
| `General Zombie` | `HakiBrute` |
| `Command General` | `SoruAssassin` |
| `YONKO KAIDO [DRAGON EMPEROR]` | `YonkoBoss` |

## ติดตั้งลงโปรเจกต์ Rojo ที่ clone ไว้ (แนะนำ)

1. แตก ZIP ชุดนี้ออกมาในโฟลเดอร์ใดก็ได้ (แยกจาก Repo)
2. Clone หรือเปิด repo `anime-limitless-td` ในเครื่อง Windows แล้วสำรองงานที่ยังไม่ได้ Commit ก่อน
3. เปิด Terminal ในโฟลเดอร์ ZIP ที่แตกแล้ว รัน:

```powershell
python install_into_repo.py --repo "C:\Users\Stang\anime-limitless-td" --dry-run
python install_into_repo.py --repo "C:\Users\Stang\anime-limitless-td"
```

> เปลี่ยน path ให้เป็นโฟลเดอร์ที่ clone repo จริงบนเครื่องคุณ

4. Installer จะ **เพิ่มใหม่เท่านั้น**:
   - `assets/rojo/HeroModels/*.rbxmx`
   - `assets/rojo/EnemyModels/*.rbxmx`
   - `assets/rojo/MapModels/*.rbxmx`
   - `src/AssetKit/VisualBridge.server.luau`
   - เพิ่ม mapping อีก 4 entries ใน `default.project.json` พร้อมสำรองไฟล์เป็น `default.project.json.assetkit-backup`
5. ใน repo เดิม สั่ง `rojo serve` แล้ว Connect Rojo Plugin ของ Roblox Studio ให้ sync
6. ดูที่ `ReplicatedStorage` ต้องมี `HeroModels` 12, `EnemyModels` 4, `MapModels` 3
7. Play ทดสอบ Summon + วางป้อม, Enemy Spawn + เดิน, HP / Damage / Reward, ตัวบอส, รวมทั้ง Map assets

ถ้าไฟล์เดิมใน AssetKit path แตกต่างกัน Installer จะหยุดทันที (ไม่เขียนทับ) ใช้ `--force` เมื่อได้ตรวจ diff แล้วเท่านั้น

### สาธิตเห็นโมเดลครบ 19 ตัวทันที (ไม่ต้องเล่นเกม)

ใน Roblox Studio **Edit Mode** เปิด View → Command Bar แล้วคัดลอกเนื้อหาไฟล์ `PreviewAll.command.luau` ลงไปกด Execute

จะสร้างโฟลเดอร์ `Workspace/ASSET_KIT_PREVIEW` มีโมเดลทั้ง 19 ตัวเรียงเป็น Gallery สามารถลบโฟลเดอร์นี้ทิ้งก่อน Publish ได้

## วิธี Import ตรงโดยไม่ใช้ Rojo

เลือกไฟล์ `.rbxmx` ของแต่ละ Asset จาก ZIP แล้วใช้ **Import 3D / Insert From File** ตามเครื่องมือ Roblox Studio ที่รองรับโมเดล XML หรือเปิดผ่าน File → Open from File ตาม workflow เวอร์ชัน Studio ของคุณ แล้ววางให้ตรง `ReplicatedStorage` folder โดยต้องนำ `VisualBridge.server.luau` ไปไว้ใน `ServerScriptService` เป็น Server Script ด้วย จึงจะเห็นผลระหว่าง Play

**แนะนำ Rojo เป็นหลัก** เพราะสะดวกกว่าการ import ทีละโมเดล และไม่เสี่ยงโมเดลหายเมื่อ rebuild/sync โปรเจกต์

## Game Design & Production Caveats

- **ไม่ใช่ mesh คุณภาพ Blender**: ได้โมเดลสไตล์ Roblox Blocky มีหมวก/ดาบ/สี/รูปทรงเอกลักษณ์ แต่ยังไม่เท่ารายละเอียดใน Concept Art; ไม่ควรคาดหวังเหมือนภาพร่าง 1:1
- **ไม่ใช่ R6 Rig สำหรับ Animation Editor**: ไม่มี Humanoid / Motor6D ในตัว Visual Layer ต้อง Rig ใหม่หรือปรับให้เป็น Skinned Mesh ใน Blender/Studio เพื่อทำท่าหมัด-เตะ-เดินละเอียด
- **Performance**: 1,676 ชิ้นคือจำนวนรวมของ 19 Template; เมื่อ spawn enemy หลายตัวจะ clone Part เพิ่มจริง ทดสอบจำนวน Instance, Render/Physics และมือถือใน MicroProfiler ก่อน Production; อาจต้อง Merge Mesh / Reduce Parts เป็น LOD ภายหลัง
- **No toolbox virus**: โมเดล XML สร้างจาก Part เท่านั้น ไม่มี Script, LocalScript, ModuleScript, external AssetId หรือการ execute โค้ดใด ๆ; Server Script มีเฉพาะ VisualBridge ที่รวมในชุดนี้
- **No new game balance**: ตัวใหม่ 4 ตัวที่ยังไม่อยู่ใน GameConfig ไม่ได้เพิ่มระบบ summon อัตโนมัติ เพื่อไม่แตะสูตร Weight, Rare, Cooldown เดิม
- **Scene Assets**: map bridge ติดตั้งโครงสร้างตกแต่งที่ Waypoint 1/6 และตกแต่ง Pad1-8 โดยคง ClickDetector เดิมไว้ ไม่เพิ่ม Slot และไม่เปลี่ยน Pathfinding/Waypoint
- **Copyright / publishing**: โมเดลแฟนอาร์ตได้แรงบันดาลใจจาก One Piece ควรตรวจสิทธิ IP ก่อนเผยแพร่หรือหารายได้อย่างเป็นทางการ

## Testing checklist ใน Studio

- [ ] XML Models ทั้ง 19 ปรากฏใน ReplicatedStorage ไม่มี import error
- [ ] `Luffy` Model มี PrimaryPart = HumanoidRootPart
- [ ] ทุก Template Part Anchored=true, CanCollide=false
- [ ] Play แล้ว Summon tower ได้และโมเดล Tower ปรากฏเป็นดีไซน์ใหม่
- [ ] Attack ยังลด HP และแสดง VFX เหมือนเดิม
- [ ] Enemy ยังเคลื่อนตาม Waypoint 1-6, ถูกฆ่าแล้วหาย และ Cash เพิ่ม
- [ ] บอสในเวฟ 5 แสดงเป็น YonkoBoss
- [ ] กด Pad ได้แม้ Pad มีแท่นตกแต่ง และ Swap/Store/Sell ยังถูกต้อง
- [ ] Stop/Play แล้วไม่ซ้อน asset อีกชุด
- [ ] ตรวจ CPU/Memory/Network เมื่อมีศัตรูจำนวนมาก โดยเฉพาะมือถือ

## อ้างอิง Source ที่ตรวจ

- https://github.com/StangMKxD/anime-limitless-td/blob/main/src/Shared/GameConfig.luau
- https://github.com/StangMKxD/anime-limitless-td/blob/main/src/Track2_TowerSystem/TowerController.server.luau
- https://github.com/StangMKxD/anime-limitless-td/blob/main/src/Track1_WaveSystem/WaveManager.server.luau
- https://github.com/StangMKxD/anime-limitless-td/blob/main/default.project.json
- https://rojo.space/docs/v7/sync-details/

## Rollback

1. หยุด `rojo serve`, ปิดการเชื่อม Rojo Plugin
2. กู้ `default.project.json` จาก `default.project.json.assetkit-backup`
3. ลบ `src/AssetKit`, `assets/rojo/HeroModels`, `assets/rojo/EnemyModels`, `assets/rojo/MapModels` **เฉพาะไฟล์ที่ติดตั้งจากชุดนี้เท่านั้น** และตรวจ Git diff ก่อนทำ
4. รัน Rojo ใหม่

## Import ทีเดียวทั้งเซต (.rbxmx)

มีไฟล์ `All_19_Models.rbxmx` รวมทั้งหมดเป็น `AnimeLimitlessAssetPack` และ 3 Folder ข้างใน  
ใน Studio เปิดไฟล์ `All_19_Models.rbxmx` เป็น Model / Insert from File (ตามเมนูเวอร์ชันที่ใช้) จากนั้นย้ายโฟลเดอร์ `HeroModels`, `EnemyModels`, `MapModels` ที่อยู่ข้างใน ไปยัง `ReplicatedStorage` ตามชื่อเป๊ะ ๆ หากเปิดด้วยวิธีนี้ **อย่า**นำ Folder ครอบ `AnimeLimitlessAssetPack` ไปไว้ใต้ `ReplicatedStorage` โดยตรง เพราะ VisualBridge จะมองหาโฟลเดอร์ทั้งสามที่ระดับบนสุด

เพื่อเปิดใช้ Asset อัตโนมัติระหว่าง Play ให้สร้าง Server Script `VisualBridge` ภายใต้ `ServerScriptService` แล้ววางเนื้อหา `src/AssetKit/VisualBridge.server.luau` เข้าไปด้วย (ถ้าใช้ Rojo installer ไม่ต้องทำเอง)
