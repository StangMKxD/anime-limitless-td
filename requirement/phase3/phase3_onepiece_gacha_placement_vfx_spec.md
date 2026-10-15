# Anime Limitless Tower Defense — Phase 3 Specification & คู่มือจับมือทำฉบับสมบูรณ์ (Gacha Summon, Tactical Slot Placement, Bag/Sell System, Over-the-Top One Piece VFX & 12 Roguelike Cards)

เอกสารฉบับนี้ออกแบบมาเพื่อต่อยอดโปรเจกต์ [StangMKxD/anime-limitless-td](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td) เข้าสู่ **Phase 3** โดยรักษาสถาปัตยกรรม **Modular Zero-Conflict Architecture (3 Tracks + Shared Data Contract)** ตามมาตรฐานใน [AGENTS.md](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2FAGENTS.md) และ [docs/CONVENTIONS.md](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fdocs%2FCONVENTIONS.md) คุณสามารถนำเนื้อหาในส่วนที่ 1–4 ไปบันทึกไว้ในโฟลเดอร์ [requirement/phase3/](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Ftree%2Fmain%2Frequirement) และทำตามขั้นตอนแบบจับมือทำในส่วนที่ 5 พร้อมคัดลอกโค้ด Luau (`--!strict`) ทั้ง 5 ไฟล์ไปใช้งานกับ Rojo ได้ทันที

## 1. ภาพรวมการอัปเกรดระบบใน Phase 3 (What's New in Phase 3)

ตารางเปรียบเทียบการเปลี่ยนแปลงจากระบบเดิมใน [requirement/phase2/](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Ftree%2Fmain%2Frequirement%2Fphase2) สู่ระบบใหม่ใน **Phase 3**:

| หมวดหมู่ระบบ | ระบบเดิมใน Phase 2 | ระบบใหม่ใน Phase 3 (อัปเกรดจัดเต็ม) |
| :--- | :--- | :--- |
| **การเริ่มเกม (Initial State)** | เสกตัวละครวันพีซ 6 ตัววางประจำจุดอัตโนมัติตั้งแต่เริ่มเกม | **เริ่มเกมมาไม่มี Tower บนสนาม (0 ตัว)** มีเวลาเตรียมตัว 15 วินาที พร้อมตั๋วสุ่มฟรี 1 ใบ (`FreeSummonTickets = 1`) และปุ่มสุ่มตัวละครขนาดใหญ่กลางหน้าจอ |
| **ระบบสุ่มตัวละคร (Summon & Reroll)** | ไม่มีระบบสุ่มตัวละคร | **Grand Line Wanted Poster Gacha & Reroll**: กดปุ่มสุ่มกลางจอเพื่อสุ่มฮีโร่ 8 ตัวละคร (ระดับ Epic, Legendary, Mythical Yonko) สามารถกด **Reroll (สุ่มใหม่)** ด้วย Reroll Token หรือ Cash ได้ทันที |
| **ระบบเลือกจุดวาง, วางทับ, กระเป๋า & ขาย** | ตัวละครยืนตายตัว ขยับหรือขายไม่ได้ | **Tactical Placement Pads (8 จุดวาง)**: เลือกวางตามแท่นได้อิสระ, **เลือกวางทับตัวเดิมได้** (ตัวเดิมเด้งกลับเข้ากระเป๋าอัตโนมัติ), **เก็บเข้ากระเป๋า (Recall to Bag)** และ **ขายตัวละคร (Sell Tower)** เพื่อรับเงินคืนและแต้ม Reroll |
| **โมเดล & อนิเมชั่นวันพีซ (Models & VFX)** | โมเดล R6 พื้นฐานและเอฟเฟกต์พาร์ตทรงเรขาคณิต | **Full Procedural R6 + Motor6D Animation & Anime VFX**: มีอนิเมชั่นหายใจ/ลอยตัว (Idle Loop), ท่ากระโดดง้างหมัด/พุ่งฟัน, อาวุธและผ้าคลุมครบเซ็ต, เอฟเฟกต์ฮาคิราชันย์สายฟ้าดำ-แดง, บอลดวงอาทิตย์, รอยร้าวอากาศหนวดขาว, เลเซอร์คิซารุ, ตัวอักษรการ์ตูน 3D (`DOOM!!`, `KAMUSARI!!`) และ **กล้องสั่น (Camera Shake)** |
| **ระบบการ์ดหลังจบเวฟ (Wave Card Draft)** | มีการ์ดให้เลือกเพียง 3 ใบ | **ขยายเป็น 12 การ์ดหลากหลายสาย (Global Stats & Synergies)**: สุ่ม 3 ใบไม่ซ้ำต่อเวฟ ครอบคลุมสายเพิ่มค่าสถานะรวม (All-Stats), สายคริติคอลฮาคิ, สายระเบิดวงกว้าง, สายเศรษฐกิจเพิ่มเงิน/แต้ม Reroll และสายเพิ่มจำนวนช่องวาง Tower สูงสุด |

## 2. ข้อกำหนดระบบ Track 1 — `requirement/phase3/01_track1_core_wave_and_enemy_spec.md`

ข้อมูลอ้างอิงสำหรับการทำงานร่วมกับ [src/Track1\_WaveSystem/WaveManager.server.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack1_WaveSystem%2FWaveManager.server.luau):

1. **Preparation Phase สำหรับการสุ่มตัวละครแรก (`PREP_COUNTDOWN`)**:
   - เนื่องจากเริ่มเกมมาผู้เล่นยังไม่มี Tower บนสนาม ระบบ Wave 1 จะเข้าสู่สถานะ `PREP: SUMMON & PLACE YOUR HERO!` เป็นเวลา `15` วินาที (หรือเริ่มทันทีที่ตรวจพบ Tower ตัวแรกใน `Workspace.AnimeTowers`) เพื่อให้ผู้เล่นกดสุ่มและเลือกจุดวางตัวละครตัวแรกได้ทัน
2. **ระบบคูณเงินรางวัลค่าหัวโจรสลัด (`BountyMultiplierStat`)**:
   - เมื่อศัตรูถูกกำจัดหรือจบเวฟ ระบบจะคำนวณเงินรางวัลคูณด้วย `Player:GetAttribute("BountyMultiplierStat")` เพื่อให้สอดคล้องกับการ์ดสายเศรษฐกิจใน Phase 3
3. **อนิเมชั่นการเดินของศัตรู R6 และออร่าบอสไคโด**:
   - ศัตรู Thriller Bark Zombie, General Zombie, Command General และบอส **Yonko Kaido** (ออกทุกๆ 5 เวฟ) มีการขยับแขนขาขณะเดินตาม Waypoints และมีออร่าสายฟ้าฮาคิรอบตัวบอส

## 3. ข้อกำหนดระบบ Track 2 — `requirement/phase3/02_track2_anime_towers_and_combat_spec.md`

ข้อมูลอ้างอิงสำหรับการทำงานร่วมกับ [src/Track2\_TowerSystem/TowerController.server.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack2_TowerSystem%2FTowerController.server.luau):

### 3.1 ระบบแท่นวาง 8 จุด (Tactical Placement Slots) & การจัดการกระเป๋า/ขาย

| แอ็กชัน (`ActionType`) | เงื่อนไขการทำงาน | ผลลัพธ์ในเกม |
| :--- | :--- | :--- |
| **`Summon`** | ใช้ `FreeSummonTickets >= 1` (ฟรีตอนเริ่มเกม) หรือจ่าย `$100 Cash` | สุ่มตัวละครวันพีซตามน้ำหนัก Rarity เก็บเข้า `HeroInventoryJson` และแสดงผลบนหน้าจอกลาง |
| **`Reroll`** | ใช้ `RerollTokens >= 1` หรือจ่าย `$80 Cash` | สุ่มเปลี่ยนตัวละครตัวล่าสุดในหน้าต่างสุ่มกลางจอ (มีโอกาสออกระดับ `MYTHICAL YONKO` สูงขึ้น) |
| **`PlaceOrSwap`** | เลือกตัวละครจากหน้าสุ่มหรือกระเป๋า แล้วคลิกที่แท่นวาง `Slot_1` ถึง `Slot_8` | หากแท่นว่างจะวางตัวละครลงจุดนั้นพร้อมเอฟเฟกต์ฮาคิกระแทกพื้น **หากแท่นมีตัวละครอยู่แล้ว จะสลับเอาตัวเดิมเก็บเข้ากระเป๋าอัตโนมัติแล้ววางตัวใหม่แทนทันที** |
| **`StoreToBag`** | คลิกเลือก Tower บนสนามแล้วกดปุ่ม **เก็บเข้ากระเป๋า (Recall to Bag)** | ถอน Tower ออกจากแท่นวางบนแผนที่ (คืนสถานะแท่นว่าง) และย้ายข้อมูลตัวละครกลับเข้ากระเป๋า `HeroInventoryJson` |
| **`SellFromSlot` / `SellFromBag`** | กดปุ่ม **ขายตัวละคร (Sell)** จากแท่นวางบนสนามหรือจากในกระเป๋า | ลบตัวละครออก ได้รับเงิน Cash ตามระดับความหายาก (`$120` ถึง `$500`) และหากขายตัวระดับ `MYTHICAL YONKO` จะได้รับโบนัส `+1 RerollToken` |

### 3.2 รายชื่อ 8 ตัวละครวันพีซ โมเดลจัดเต็ม และท่าไม้ตาย (Over-the-Top One Piece VFX)

| รหัสตัวละคร (`HeroId`) | ชื่อตัวละคร & ฉายา | ระดับความหายาก | ตัวคูณดาเมจ / ระยะ / ความเร็ว | ราคาขายคืน | โมเดล 3D & อนิเมชั่นท่าไม้ตายตามอนิเมะ (`AttackStyle`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`Tower_Luffy_G5`** | **Monkey D. Luffy** (`SUN GOD NIKA [GEAR 5]`) | `MYTHICAL YONKO` | ดาเมจ `2.3x`, ระยะ `+6`, ตีไว `0.85x` | `$480` (+1 Reroll) | ผมสีขาวเมฆลอยตัว ผ้าคลุมเมฆนิกะ ท่ากระโดดลอยตัวปล่อยหมัดยักษ์ **Bajrang Gun** ขนาดเท่าเกาะพุ่งลงมาจากฟ้า พร้อมสายฟ้าฮาคิราชันย์ดำ-แดง และป้ายเสียง `DOOM!!` |
| **`Tower_Shanks_Kamusari`** | **Red-Haired Shanks** (`EMPEROR [KAMUSARI]`) | `MYTHICAL YONKO` | ดาเมจ `2.5x`, ระยะ `+10`, ตีไว `0.90x` | `$500` (+1 Reroll) | ผ้าคลุมจักรพรรดิสีดำ ดาบกริฟฟอนอาบฮาคิ พุ่งฟันปล่อยคลื่นดาบจันทร์เสี้ยวสีแดง-ดำขนาดยักษ์ **Divine Departure (Kamusari)** ผ่าพื้นแตกเป็นทางยาว พร้อมป้าย `KAMUSARI!!` |
| **`Tower_Whitebeard_Gura`** | **Edward Newgate** (`WHITEBEARD [GURA GURA]`) | `MYTHICAL YONKO` | ดาเมจ `2.6x`, ระยะ `+8`, ตีไว `1.10x` | `$500` (+1 Reroll) | หนวดพระจันทร์เสี้ยวสีขาว ง้าวคุโมะคิริ ง้างหมัดชกอากาศจนเกิด **รอยร้าวกระจกแตกกลางอากาศ (3D Air Cracks)** และคลื่นสึนามิสั่นสะเทือนสโลว์ศัตรูทั้งวง พร้อมป้าย `CRACK!!` |
| **`Tower_Zoro_KingOfHell`** | **Roronoa Zoro** (`KING OF HELL [ENMA]`) | `LEGENDARY HAKI` | ดาเมจ `1.75x`, ระยะ `+2`, ตีไว `0.80x` | `$260` | คาบดาบวาโดอิจิมอนจิ ถือดาบเอ็นมะออร่าไฟนรกสีเขียว-ม่วง พุ่งทะลุศัตรูทิ้งเงาติดตา ปล่อยพายุหมุนฟัน 360 องศาและมังกรเขียวพุ่งขึ้นฟ้า พร้อมป้าย `ONIGIRI!!` |
| **`Tower_Ace_Entei`** | **Portgas D. Ace** (`FLAME EMPEROR [ENTEI]`) | `LEGENDARY HAKI` | ดาเมจ `1.80x`, ระยะ `+8`, ตีไว `0.95x` | `$250` | หมวกคาวบอยสีส้ม ลูกประคำแดง ชูมือสร้าง **ดวงอาทิตย์ยักษ์ (Dai Enkai: Entei)** เหนือหัวแล้วทุ่มลงกลางฝูงศัตรู ระเบิดโดมเพลิงสุริยะ 3 ชั้น พร้อมป้าย `ENTEI!!` |
| **`Tower_Law_KRoom`** | **Trafalgar Law** (`SURGEON OF DEATH [K-ROOM]`) | `LEGENDARY HAKI` | ดาเมจ `1.70x`, ระยะ `+12`, ตีไว `0.88x` | `$260` | หมวกลายจุด ดาบยาวคิโคคุ กางโดมโปร่งแสงสีฟ้า **ROOM** ขนาดใหญ่ แล้วแทงดาบพลังงานยักษ์ **Puncture Wille** ทะลุพื้นระเบิดคลื่นแกมมาสีเขียว-ม่วงจากภายใน พร้อมป้าย `K-ROOM!!` |
| **`Tower_Kizaru_Pika`** | **Admiral Kizaru** (`BORSALINO [PIKA PIKA]`) | `LEGENDARY HAKI` | ดาเมจ `1.65x`, ระยะ `+16`, ตีไว `0.72x` | `$270` | สูทลายทางสีเหลือง เสื้อคลุมพลเรือเอก วาร์ปเป็นร่างแสงสีทองลอยขึ้นฟ้า ยิงห่าฝนเลเซอร์ **Yasakani no Magatama** 14 ลำแสงถล่มพื้นที่เป้าหมายรัวๆ พร้อมป้าย `FLASH!!` |
| **`Tower_Sanji_Ifrit`** | **Vinsmoke Sanji** (`IFRIT JAMBE [BLUE FLAME]`) | `EPIC HAKI` | ดาเมจ `1.45x`, ระยะ `+0`, ตีไว `0.68x` | `$140` | สูทสีดำ ขาข้างขวาหุ้มเพลิงพลาสม่าสีฟ้าอมขาวและสายฟ้า วาร์ปเตะกลางอากาศ **Boeuf Burst** รัวคลื่นไฟสีฟ้า 10 ฮิตซ้อนและเสาเพลิงสีน้ำเงินระเบิดขึ้นฟ้า พร้อมป้าย `IFRIT!!` |

## 4. ข้อกำหนดระบบ Track 3 — `requirement/phase3/03_track3_infinite_upgrade_ui_and_integration_spec.md`

ข้อมูลอ้างอิงสำหรับการทำงานร่วมกับ [src/Track3\_UpgradeServer/UpgradeServer.server.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack3_UpgradeServer%2FUpgradeServer.server.luau) และ [src/Track3\_UISystem/UpgradeHUD.client.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack3_UISystem%2FUpgradeHUD.client.luau):

### 4.1 คลังการ์ดอัปเกรดหลังผ่านเวฟทั้ง 12 ใบ (Expanded Diverse Wave-Clear Card Pool)

ทุกครั้งที่ผ่านเวฟ (`PendingCardDraws > 0`) ระบบจะสุ่มการ์ด 3 ใบไม่ซ้ำกันจาก 12 ใบด้านล่าง เพื่อเพิ่มค่าสถานะโดยรวมของทีม (Global Team Stats) และทรัพยากรของผู้เล่น:

| รหัสการ์ด (`CardId`) | ชื่อการ์ด | ระดับ & สายการ์ด | ผลลัพธ์การเพิ่ม Stats โดยรวม (Global Modifiers) |
| :--- | :--- | :--- | :--- |
| **`Card_Gear5Nika`** | **SUN GOD NIKA: GEAR 5 AWAKENING** | `MYTHICAL YONKO` (All-Out Attack) | ดาเมจรวม `+85%` (`+50` Flat), ลดคูลดาวน์โจมตี `-15%`, รัศมีระเบิด AoE `+3 Studs` |
| **`Card_GrandFleetCommand`** | **STRAW HAT GRAND FLEET ALLIANCE** | `MYTHICAL SYNERGY` (All-Stats + Slot) | **เพิ่มจำนวนวาง Tower สูงสุด `+1 ตัว`**, ดาเมจรวม `+35%`, ระยะยิง `+6 Studs`, ลดคูลดาวน์ `-12%`, คริติคอล `+6%` |
| **`Card_DevilFruitAwakening`** | **DEVIL FRUIT AWAKENING: MASTERY** | `MYTHICAL YONKO` (Supreme AoE) | รัศมีระเบิด AoE `+6 Studs`, ดาเมจรวม `+55%` (`+35` Flat), ลดคูลดาวน์ `-10%` |
| **`Card_KingOfHellAsura`** | **NINE-SWORD STYLE: ASURA DEMON AURA** | `MYTHICAL CRIT` (Lethal Critical) | โอกาสคริติคอล `+15%`, แรงคริติคอล (`CritDamageStat`) `+0.85x`, ดาเมจรวม `+40%` |
| **`Card_ConquerorHaki`** | **CONQUEROR'S HAKI: SUPREME KING** | `LEGENDARY HAKI` (Burst Damage) | ดาเมจรวม `+45%` (`+25` Flat), โอกาสคริติคอล `+8%`, แรงคริติคอล `+0.25x` |
| **`Card_GuraQuakeResonance`** | **TREMOR-TREMOR SEA QUAKE RESONANCE** | `LEGENDARY AOE` (Splash & Power) | รัศมีระเบิด AoE `+5 Studs`, ดาเมจรวม `+35%` (`+30` Flat) |
| **`Card_PikaLightSpeed`** | **GLINT-GLINT LIGHT SPEED REFLEXES** | `LEGENDARY SPEED` (Hyper Speed) | ลดคูลดาวน์โจมตีรวม `-22%`, ระยะยิงรวม `+5 Studs` |
| **`Card_YonkoBounty`** | **CROSS GUILD & YONKO BOUNTY HUNTER** | `LEGENDARY ECONOMY` (Cash & Reroll) | ตัวคูณเงินดรอป `+40%` (`BountyMultiplierStat`), รับเงินทันที `+$350 Cash`, รับตั๋วสุ่มใหม่ `+2 Reroll Tokens` |
| **`Card_ObservationHaki`** | **OBSERVATION HAKI: FUTURE SIGHT** | `EPIC HAKI` (Sniper Range) | ระยะยิงรวม `+8 Studs`, ลดคูลดาวน์โจมตี `-10%`, โอกาสคริติคอล `+5%` |
| **`Card_ArmamentRyou`** | **ADVANCED ARMAMENT: INTERNAL RYOU** | `EPIC HAKI` (Armor Piercing) | ดาเมจรวม `+30%` (`+20` Flat), แรงคริติคอล `+0.50x`, รัศมีระเบิด AoE `+2 Studs` |
| **`Card_PoneglyphWisdom`** | **ANCIENT PONEGLYPH INSCRIPTION** | `EPIC UTILITY` (Fortress & Buff) | ฟื้นฟูเลือดฐานทัพ `+250 HP` (และเพิ่ม Max HP ฐาน `+250`), ดาเมจรวม `+20%`, ระยะยิง `+4 Studs` |
| **`Card_ShandoraGold`** | **CITY OF GOLD SHANDORA TREASURE** | `EPIC GACHA` (Gacha Roll Boost) | รับเงินทันที `+$600 Cash`, รับตั๋วสุ่มใหม่ `+4 Reroll Tokens`, ดาเมจรวม `+15%` |

## 5. คู่มือจับมือทำทีละขั้นตอน (Step-by-Step Implementation Guide)

### ขั้นตอนที่ 1: เพิ่มเอกสาร Requirement Phase 3 ลงในโปรเจกต์
1. เปิดโฟลเดอร์โปรเจกต์ `anime-limitless-td` ในเครื่องของคุณ
2. สร้างโฟลเดอร์ย่อย `requirement/phase3/` ต่อจาก `requirement/phase1/` และ `requirement/phase2/`
3. บันทึกไฟล์ `.md` ฉบับนี้ไว้ที่ `requirement/phase3/phase3_onepiece_gacha_placement_vfx_spec.md` (หรือแยกเป็น 3 ไฟล์ตามหัวข้อที่ 2, 3 และ 4)

### ขั้นตอนที่ 2: อัปเดตไฟล์ Data Contract ส่วนกลาง (`src/Shared/GameConfig.luau`)
เปิดไฟล์ [src/Shared/GameConfig.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FShared%2FGameConfig.luau) แล้วแทนที่ด้วยโค้ดด้านล่างนี้ เพื่อเพิ่มข้อมูลฮีโร่ 8 ตัวละคร, จุดวาง 8 จุด, การ์ดอัปเกรด 12 ใบ และ RemoteEvents สำหรับสุ่ม/วาง/เก็บเข้ากระเป๋า/ขาย:

```luau
--!strict
-- src/Shared/GameConfig.luau
-- Phase 3 Data Contract: Gacha Summon, Tactical Slot Placement, Bag/Sell, 8 One Piece Heroes & 12 Roguelike Cards

local GameConfig = {}

GameConfig.WORKSPACE_ATTRS = {
	CURRENT_WAVE = "CurrentWave",
	WAVE_STATUS = "WaveStatus",
	BASE_HP = "BaseHP",
	MAX_BASE_HP = "MaxBaseHP",
	ZOMBIES_REMAINING = "ZombiesRemaining",
	GAME_OVER = "GameOver",
	PENDING_CARD_DRAWS = "PendingCardDraws",
}

GameConfig.PLAYER_ATTRS = {
	DAMAGE_STAT = "DamageStat",
	RANGE_STAT = "RangeStat",
	COOLDOWN_STAT = "CooldownStat",
	SPLASH_STAT = "SplashRadiusStat",
	CRIT_CHANCE = "CritChanceStat",
	CRIT_DAMAGE = "CritDamageStat",
	BOUNTY_MULT = "BountyMultiplierStat",
	DAMAGE_LEVEL = "DamageLevel",
	RANGE_LEVEL = "RangeLevel",
	SPEED_LEVEL = "SpeedLevel",
	PENDING_CARD_DRAWS = "PendingCardDraws",
	CARDS_PICKED_TOTAL = "CardsPickedTotal",
	-- Phase 3 Gacha, Bag & Slot Attributes
	REROLL_TOKENS = "RerollTokens",
	FREE_SUMMON_TICKETS = "FreeSummonTickets",
	MAX_PLACED_TOWERS = "MaxPlacedTowersStat",
	PLACED_TOWERS_COUNT = "PlacedTowersCount",
	INVENTORY_JSON = "HeroInventoryJson",
	LAST_ROLLED_HERO_ID = "LastRolledHeroId",
	LAST_ROLLED_UNIT_UID = "LastRolledUnitUid",
	SELECTED_BAG_UID = "SelectedBagUnitUid",
}

GameConfig.INITIAL_PLAYER_STATS = {
	DAMAGE = 50,
	RANGE = 30,
	COOLDOWN = 1.15,
	SPLASH_RADIUS = 7,
	CRIT_CHANCE = 0.08,
	CRIT_DAMAGE = 2.0,
	BOUNTY_MULT = 1.0,
	CASH = 500,
	REROLL_TOKENS = 3,
	FREE_SUMMON_TICKETS = 1,
	MAX_PLACED_TOWERS = 4,
	SUMMON_COST_CASH = 100,
	REROLL_COST_CASH = 80,
}

GameConfig.REMOTES = {
	UPGRADE_REQUEST = "UpgradeStatRequest",
	CARD_DRAFT_SELECT = "CardDraftSelectRequest",
	TOWER_SUMMON_REROLL = "TowerSummonRerollRequest",
	TOWER_PLACEMENT_ACTION = "TowerPlacementActionRequest",
	VFX_CAMERA_SHAKE = "VFXCameraShakeEvent",
}

-- 8 Strategic Placement Slots along the Grand Line Marineford Path
GameConfig.PLACEMENT_SLOTS = {
	{ SlotId = "Slot_1", Label = "PAD 1 [FRONT LEFT]", Position = Vector3.new(-42, 3, -28) },
	{ SlotId = "Slot_2", Label = "PAD 2 [CENTER LEFT]", Position = Vector3.new(-10, 3, -28) },
	{ SlotId = "Slot_3", Label = "PAD 3 [INNER TURN]", Position = Vector3.new(-34, 3, 0) },
	{ SlotId = "Slot_4", Label = "PAD 4 [CENTER CORE]", Position = Vector3.new(0, 3, 6) },
	{ SlotId = "Slot_5", Label = "PAD 5 [SOUTH BEND]", Position = Vector3.new(-10, 3, 34) },
	{ SlotId = "Slot_6", Label = "PAD 6 [EAST BEND]", Position = Vector3.new(10, 3, 34) },
	{ SlotId = "Slot_7", Label = "PAD 7 [EAST GUARD]", Position = Vector3.new(34, 3, 0) },
	{ SlotId = "Slot_8", Label = "PAD 8 [BASE GUARD]", Position = Vector3.new(38, 3, -20) },
}

-- 8 Iconic One Piece Hero Towers with Over-the-Top Anime VFX Specs
GameConfig.HERO_CATALOG = {
	{
		Id = "Tower_Luffy_G5",
		Name = "MONKEY D. LUFFY",
		Subtitle = "SUN GOD NIKA [GEAR 5]",
		Rarity = "MYTHICAL YONKO",
		Weight = 8,
		DamageMult = 2.30,
		RangeBonus = 6,
		CooldownMult = 0.85,
		SplashBonus = 5,
		SellValue = 480,
		AttackStyle = "BajrangFist",
		Onomatopoeia = "DOOM!! (หมัดเทพนิกะ!!)",
		PrimaryColor = Color3.fromRGB(255, 250, 255),
		SecondaryColor = Color3.fromRGB(255, 45, 95),
	},
	{
		Id = "Tower_Shanks_Kamusari",
		Name = "RED-HAIRED SHANKS",
		Subtitle = "EMPEROR [KAMUSARI]",
		Rarity = "MYTHICAL YONKO",
		Weight = 7,
		DamageMult = 2.50,
		RangeBonus = 10,
		CooldownMult = 0.90,
		SplashBonus = 4,
		SellValue = 500,
		AttackStyle = "Kamusari",
		Onomatopoeia = "KAMUSARI!! (เทวะอาสัญ!!)",
		PrimaryColor = Color3.fromRGB(220, 25, 45),
		SecondaryColor = Color3.fromRGB(25, 10, 15),
	},
	{
		Id = "Tower_Whitebeard_Gura",
		Name = "EDWARD NEWGATE",
		Subtitle = "WHITEBEARD [GURA GURA]",
		Rarity = "MYTHICAL YONKO",
		Weight = 7,
		DamageMult = 2.60,
		RangeBonus = 8,
		CooldownMult = 1.10,
		SplashBonus = 8,
		SellValue = 500,
		AttackStyle = "GuraQuake",
		Onomatopoeia = "CRACK!! (สั่นสะเทือนโลกา!!)",
		PrimaryColor = Color3.fromRGB(240, 248, 255),
		SecondaryColor = Color3.fromRGB(110, 200, 255),
	},
	{
		Id = "Tower_Zoro_KingOfHell",
		Name = "RORONOA ZORO",
		Subtitle = "KING OF HELL [ENMA]",
		Rarity = "LEGENDARY HAKI",
		Weight = 14,
		DamageMult = 1.75,
		RangeBonus = 2,
		CooldownMult = 0.80,
		SplashBonus = 3,
		SellValue = 260,
		AttackStyle = "KingOfHell360",
		Onomatopoeia = "ONIGIRI!! (ราชานรก!!)",
		PrimaryColor = Color3.fromRGB(40, 235, 115),
		SecondaryColor = Color3.fromRGB(165, 55, 255),
	},
	{
		Id = "Tower_Ace_Entei",
		Name = "PORTGAS D. ACE",
		Subtitle = "FLAME EMPEROR [ENTEI]",
		Rarity = "LEGENDARY HAKI",
		Weight = 14,
		DamageMult = 1.80,
		RangeBonus = 8,
		CooldownMult = 0.95,
		SplashBonus = 6,
		SellValue = 250,
		AttackStyle = "Entei",
		Onomatopoeia = "ENTEI!! (มหาจักรพรรดิอัคคี!!)",
		PrimaryColor = Color3.fromRGB(255, 115, 20),
		SecondaryColor = Color3.fromRGB(255, 225, 60),
	},
	{
		Id = "Tower_Law_KRoom",
		Name = "TRAFALGAR LAW",
		Subtitle = "SURGEON OF DEATH [K-ROOM]",
		Rarity = "LEGENDARY HAKI",
		Weight = 14,
		DamageMult = 1.70,
		RangeBonus = 12,
		CooldownMult = 0.88,
		SplashBonus = 4,
		SellValue = 260,
		AttackStyle = "GammaKnife",
		Onomatopoeia = "K-ROOM!! (พังก์เจอร์ วิลเล!!)",
		PrimaryColor = Color3.fromRGB(65, 215, 255),
		SecondaryColor = Color3.fromRGB(170, 255, 120),
	},
	{
		Id = "Tower_Kizaru_Pika",
		Name = "ADMIRAL KIZARU",
		Subtitle = "BORSALINO [PIKA PIKA]",
		Rarity = "LEGENDARY HAKI",
		Weight = 14,
		DamageMult = 1.65,
		RangeBonus = 16,
		CooldownMult = 0.72,
		SplashBonus = 4,
		SellValue = 270,
		AttackStyle = "YasakaniLight",
		Onomatopoeia = "FLASH!! (ลำแสงความเร็วแสง!!)",
		PrimaryColor = Color3.fromRGB(255, 240, 75),
		SecondaryColor = Color3.fromRGB(255, 195, 25),
	},
	{
		Id = "Tower_Sanji_Ifrit",
		Name = "VINSMOKE SANJI",
		Subtitle = "IFRIT JAMBE [BLUE FLAME]",
		Rarity = "EPIC HAKI",
		Weight = 22,
		DamageMult = 1.45,
		RangeBonus = 0,
		CooldownMult = 0.68,
		SplashBonus = 2,
		SellValue = 140,
		AttackStyle = "BoeufBurst",
		Onomatopoeia = "IFRIT!! (ลูกเตะเพลิงสีคราม!!)",
		PrimaryColor = Color3.fromRGB(35, 145, 255),
		SecondaryColor = Color3.fromRGB(220, 245, 255),
	},
}

-- 12 Diverse Wave-Clear Upgrade Cards (Global Stats, Synergies, Economy & Rerolls)
GameConfig.CARD_POOL = {
	{
		Id = "Card_Gear5Nika",
		Rarity = "MYTHICAL YONKO",
		Category = "ALL-OUT OFFENSE",
		Title = "SUN GOD NIKA: GEAR 5 AWAKENING",
		Desc = "+85% GLOBAL DAMAGE (+50 Flat)\n-15% ATTACK COOLDOWN | +3 AOE RADIUS",
		BorderColor = Color3.fromRGB(255, 55, 95),
		BgColor = Color3.fromRGB(60, 16, 32),
		DamagePct = 0.85,
		DamageFlat = 50,
		CooldownMult = 0.85,
		SplashFlat = 3,
	},
	{
		Id = "Card_GrandFleetCommand",
		Rarity = "MYTHICAL SYNERGY",
		Category = "FLEET COMMAND & ALL-STATS",
		Title = "STRAW HAT GRAND FLEET ALLIANCE",
		Desc = "+1 MAX PLACED TOWER SLOT\n+35% DAMAGE | +6 RANGE | -12% COOLDOWN | +6% CRIT",
		BorderColor = Color3.fromRGB(255, 215, 65),
		BgColor = Color3.fromRGB(55, 42, 12),
		ExtraTowerSlot = 1,
		DamagePct = 0.35,
		DamageFlat = 20,
		RangeFlat = 6,
		CooldownMult = 0.88,
		CritChanceFlat = 0.06,
	},
	{
		Id = "Card_DevilFruitAwakening",
		Rarity = "MYTHICAL YONKO",
		Category = "SUPREME AOE CATACLYSM",
		Title = "DEVIL FRUIT AWAKENING: MASTERY",
		Desc = "+6 STUDS SPLASH AOE RADIUS\n+55% GLOBAL DAMAGE (+35 Flat) | -10% COOLDOWN",
		BorderColor = Color3.fromRGB(230, 65, 255),
		BgColor = Color3.fromRGB(48, 15, 60),
		SplashFlat = 6,
		DamagePct = 0.55,
		DamageFlat = 35,
		CooldownMult = 0.90,
	},
	{
		Id = "Card_KingOfHellAsura",
		Rarity = "MYTHICAL CRIT",
		Category = "LETHAL HAKI CRITICAL",
		Title = "NINE-SWORD STYLE: ASURA DEMON AURA",
		Desc = "+15% CRITICAL CHANCE | +0.85x CRIT DAMAGE\n+40% GLOBAL DAMAGE (+25 Flat)",
		BorderColor = Color3.fromRGB(50, 255, 130),
		BgColor = Color3.fromRGB(15, 50, 30),
		CritChanceFlat = 0.15,
		CritDamageFlat = 0.85,
		DamagePct = 0.40,
		DamageFlat = 25,
	},
	{
		Id = "Card_ConquerorHaki",
		Rarity = "LEGENDARY HAKI",
		Category = "SUPREME KING POWER",
		Title = "CONQUEROR'S HAKI: SUPREME KING",
		Desc = "+45% GLOBAL DAMAGE (+25 Flat)\n+8% CRITICAL CHANCE | +0.25x CRIT DAMAGE",
		BorderColor = Color3.fromRGB(255, 195, 40),
		BgColor = Color3.fromRGB(55, 35, 15),
		DamagePct = 0.45,
		DamageFlat = 25,
		CritChanceFlat = 0.08,
		CritDamageFlat = 0.25,
	},
	{
		Id = "Card_GuraQuakeResonance",
		Rarity = "LEGENDARY AOE",
		Category = "TREMOR SHOCKWAVE",
		Title = "TREMOR-TREMOR SEA QUAKE RESONANCE",
		Desc = "+5 STUDS SPLASH AOE RADIUS\n+35% GLOBAL DAMAGE (+30 Flat)",
		BorderColor = Color3.fromRGB(95, 210, 255),
		BgColor = Color3.fromRGB(18, 42, 60),
		SplashFlat = 5,
		DamagePct = 0.35,
		DamageFlat = 30,
	},
	{
		Id = "Card_PikaLightSpeed",
		Rarity = "LEGENDARY SPEED",
		Category = "HYPER ATTACK SPEED",
		Title = "GLINT-GLINT LIGHT SPEED REFLEXES",
		Desc = "-22% ATTACK COOLDOWN (HYPER SPEED)\n+5 STUDS GLOBAL RANGE",
		BorderColor = Color3.fromRGB(255, 240, 80),
		BgColor = Color3.fromRGB(55, 50, 15),
		CooldownMult = 0.78,
		RangeFlat = 5,
	},
	{
		Id = "Card_YonkoBounty",
		Rarity = "LEGENDARY ECONOMY",
		Category = "BOUNTY & REROLL ENGINE",
		Title = "CROSS GUILD & YONKO BOUNTY HUNTER",
		Desc = "+40% WAVE & KILL CASH MULTIPLIER\n+$350 INSTANT CASH | +2 REROLL TOKENS",
		BorderColor = Color3.fromRGB(255, 170, 30),
		BgColor = Color3.fromRGB(50, 32, 10),
		BountyMultFlat = 0.40,
		InstantCash = 350,
		BonusRerolls = 2,
	},
	{
		Id = "Card_ObservationHaki",
		Rarity = "EPIC HAKI",
		Category = "SNIPER PRECISION",
		Title = "OBSERVATION HAKI: FUTURE SIGHT",
		Desc = "+8 STUDS GLOBAL RANGE\n-10% ATTACK COOLDOWN | +5% CRIT CHANCE",
		BorderColor = Color3.fromRGB(175, 85, 255),
		BgColor = Color3.fromRGB(38, 20, 58),
		RangeFlat = 8,
		CooldownMult = 0.90,
		CritChanceFlat = 0.05,
	},
	{
		Id = "Card_ArmamentRyou",
		Rarity = "EPIC HAKI",
		Category = "INTERNAL DESTRUCTION",
		Title = "ADVANCED ARMAMENT: INTERNAL RYOU",
		Desc = "+30% GLOBAL DAMAGE (+20 Flat)\n+0.50x CRIT DAMAGE | +2 AOE RADIUS",
		BorderColor = Color3.fromRGB(255, 95, 60),
		BgColor = Color3.fromRGB(52, 22, 18),
		DamagePct = 0.30,
		DamageFlat = 20,
		CritDamageFlat = 0.50,
		SplashFlat = 2,
	},
	{
		Id = "Card_PoneglyphWisdom",
		Rarity = "EPIC UTILITY",
		Category = "FORTRESS & GLOBAL BUFF",
		Title = "ANCIENT PONEGLYPH INSCRIPTION",
		Desc = "HEAL +250 BASE HP (+250 MAX BASE HP)\n+20% GLOBAL DAMAGE | +4 STUDS RANGE",
		BorderColor = Color3.fromRGB(80, 235, 210),
		BgColor = Color3.fromRGB(16, 48, 46),
		BaseHeal = 250,
		DamagePct = 0.20,
		DamageFlat = 15,
		RangeFlat = 4,
	},
	{
		Id = "Card_ShandoraGold",
		Rarity = "EPIC GACHA",
		Category = "TREASURE & REROLLS",
		Title = "CITY OF GOLD SHANDORA TREASURE",
		Desc = "+$600 INSTANT CASH | +4 REROLL TOKENS\n+15% GLOBAL DAMAGE",
		BorderColor = Color3.fromRGB(255, 225, 90),
		BgColor = Color3.fromRGB(48, 42, 14),
		InstantCash = 600,
		BonusRerolls = 4,
		DamagePct = 0.15,
		DamageFlat = 10,
	},
}

return GameConfig
```

### ขั้นตอนที่ 3: อัปเดตระบบเวฟและเวลาเตรียมตัวสุ่มตัวละคร (`src/Track1_WaveSystem/WaveManager.server.luau`)
เปิดไฟล์ [src/Track1\_WaveSystem/WaveManager.server.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack1_WaveSystem%2FWaveManager.server.luau) แล้วแทนที่ด้วยโค้ดด้านล่างนี้ ระบบจะรอให้ผู้เล่นกดสุ่มตัวละครตัวแรกและวางลงสนามก่อนเริ่มเวฟที่ 1 (หรือนับถอยหลัง 15 วินาที) พร้อมคูณเงินรางวัลตาม `BountyMultiplierStat`:

```luau
--!strict
-- src/Track1_WaveSystem/WaveManager.server.luau
-- Phase 3: Grand Line Wave System with First-Summon Prep Window, R6 Walk Animation & Bounty Multiplier

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(SharedFolder:WaitForChild("GameConfig")) :: any

local WAYPOINT_COORDS = {
	Vector3.new(-65, 3, -42),
	Vector3.new(-22, 3, -42),
	Vector3.new(-22, 3, 22),
	Vector3.new(22, 3, 22),
	Vector3.new(22, 3, -32),
	Vector3.new(65, 3, -32),
}

local ENEMY_TYPES = {
	ThrillerZombie = { Name = "Thriller Bark Zombie", BaseHP = 120, Speed = 10.5, Cash = 22, Scale = 1.0, Color = Color3.fromRGB(95, 135, 105) },
	GeneralZombie = { Name = "General Zombie", BaseHP = 420, Speed = 7.2, Cash = 55, Scale = 1.25, Color = Color3.fromRGB(75, 60, 110) },
	CommandGeneral = { Name = "Command General", BaseHP = 280, Speed = 14.5, Cash = 70, Scale = 1.1, Color = Color3.fromRGB(185, 45, 55) },
	YonkoKaido = { Name = "YONKO KAIDO [DRAGON EMPEROR]", BaseHP = 2600, Speed = 6.0, Cash = 550, Scale = 1.85, Color = Color3.fromRGB(45, 125, 220) },
}

local function ensureMapAndWaypoints(): (Folder, Folder)
	local mapFolder = Workspace:FindFirstChild("GrandLineMap") :: Folder?
	if not mapFolder then
		mapFolder = Instance.new("Folder")
		mapFolder.Name = "GrandLineMap"
		mapFolder.Parent = Workspace

		local ground = Instance.new("Part")
		ground.Name = "MarinefordPlaza"
		ground.Size = Vector3.new(220, 2, 180)
		ground.Position = Vector3.new(0, 0, 0)
		ground.Anchored = true
		ground.Material = Enum.Material.Cobblestone
		ground.Color = Color3.fromRGB(48, 52, 62)
		ground.Parent = mapFolder

		local baseCore = Instance.new("Part")
		baseCore.Name = "PoneglyphBase"
		baseCore.Size = Vector3.new(14, 16, 14)
		baseCore.Position = WAYPOINT_COORDS[#WAYPOINT_COORDS] + Vector3.new(8, 6, 0)
		baseCore.Anchored = true
		baseCore.Material = Enum.Material.Neon
		baseCore.Color = Color3.fromRGB(55, 185, 255)
		baseCore.Parent = mapFolder
	end

	local wpFolder = Workspace:FindFirstChild("Waypoints") :: Folder?
	if not wpFolder then
		wpFolder = Instance.new("Folder")
		wpFolder.Name = "Waypoints"
		wpFolder.Parent = Workspace

		for idx, pos in ipairs(WAYPOINT_COORDS) do
			local wp = Instance.new("Part")
			wp.Name = "Waypoint_" .. tostring(idx)
			wp.Size = Vector3.new(4, 1, 4)
			wp.Position = pos
			wp.Anchored = true
			wp.CanCollide = false
			wp.Transparency = 0.5
			wp.Material = Enum.Material.Neon
			wp.Color = Color3.fromRGB(255, 200, 60)
			wp.Parent = wpFolder
		end
	end

	local enemiesFolder = Workspace:FindFirstChild("Enemies") :: Folder?
	if not enemiesFolder then
		enemiesFolder = Instance.new("Folder")
		enemiesFolder.Name = "Enemies"
		enemiesFolder.Parent = Workspace
	end

	local towersFolder = Workspace:FindFirstChild("AnimeTowers") :: Folder?
	if not towersFolder then
		towersFolder = Instance.new("Folder")
		towersFolder.Name = "AnimeTowers"
		towersFolder.Parent = Workspace
	end

	return mapFolder :: Folder, wpFolder :: Folder
end

local function awardCashToAllPlayers(baseAmount: number)
	for _, player in ipairs(Players:GetPlayers()) do
		local mult = (player:GetAttribute(GameConfig.PLAYER_ATTRS.BOUNTY_MULT) :: number?) or 1.0
		local finalCash = math.floor(baseAmount * mult)
		local ls = player:FindFirstChild("leaderstats")
		local cashVal = ls and ls:FindFirstChild("Cash") :: IntValue?
		if cashVal then
			cashVal.Value += finalCash
		end
	end
end

local function spawnEnemy(enemyKey: string, waveNum: number, enemiesFolder: Folder)
	local spec = ENEMY_TYPES[enemyKey] or ENEMY_TYPES.ThrillerZombie
	local hpMult = math.pow(1.18, waveNum - 1)
	local maxHp = math.floor(spec.BaseHP * hpMult)

	local model = Instance.new("Model")
	model.Name = spec.Name
	model:SetAttribute("HP", maxHp)
	model:SetAttribute("MaxHP", maxHp)
	model:SetAttribute("Speed", spec.Speed)
	model:SetAttribute("CashReward", spec.Cash)
	model:SetAttribute("SlowUntil", 0)

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2.2 * spec.Scale, 4.2 * spec.Scale, 1.4 * spec.Scale)
	root.Position = WAYPOINT_COORDS[1]
	root.Anchored = true
	root.CanCollide = false
	root.Material = Enum.Material.SmoothPlastic
	root.Color = spec.Color
	root.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.6 * spec.Scale, 1.6 * spec.Scale, 1.6 * spec.Scale)
	head.Position = root.Position + Vector3.new(0, 2.9 * spec.Scale, 0)
	head.Anchored = true
	head.CanCollide = false
	head.Color = Color3.fromRGB(215, 225, 205)
	head.Parent = model

	-- Boss Dragon Horn Aura for Kaido
	if enemyKey == "YonkoKaido" then
		local aura = Instance.new("Part")
		aura.Name = "KaidoDragonAura"
		aura.Shape = Enum.PartType.Ball
		aura.Size = Vector3.new(8, 8, 8)
		aura.Position = root.Position
		aura.Anchored = true
		aura.CanCollide = false
		aura.Material = Enum.Material.Neon
		aura.Color = Color3.fromRGB(175, 50, 255)
		aura.Transparency = 0.65
		aura.Parent = model
	end

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(140, 38)
	bb.StudsOffset = Vector3.new(0, 4.5 * spec.Scale, 0)
	bb.AlwaysOnTop = true
	bb.Parent = root

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.fromScale(1, 1)
	nameLbl.BackgroundTransparency = 0.35
	nameLbl.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
	nameLbl.TextColor3 = Color3.fromRGB(255, 235, 120)
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextScaled = true
	nameLbl.Text = string.format("%s [%d HP]", spec.Name, maxHp)
	nameLbl.Parent = bb

	model.PrimaryPart = root
	model.Parent = enemiesFolder

	model:GetAttributeChangedSignal("HP"):Connect(function()
		local currentHp = (model:GetAttribute("HP") :: number?) or 0
		nameLbl.Text = string.format("%s [%d/%d]", spec.Name, math.max(0, math.floor(currentHp)), maxHp)
		if currentHp <= 0 and model.Parent then
			awardCashToAllPlayers(spec.Cash)
			model:Destroy()
		end
	end)

	task.spawn(function()
		local stepTick = 0
		for i = 2, #WAYPOINT_COORDS do
			local targetPos = WAYPOINT_COORDS[i]
			while model.Parent and ((model:GetAttribute("HP") :: number?) or 0) > 0 do
				local curPos = root.Position
				local diff = targetPos - curPos
				local dist = diff.Magnitude
				if dist <= 1.2 then
					break
				end
				local slowUntil = (model:GetAttribute("SlowUntil") :: number?) or 0
				local speedMult = (os.clock() < slowUntil) and 0.45 or 1.0
				local stepDist = math.min(dist, spec.Speed * speedMult * 0.05)
				local nextPos = curPos + diff.Unit * stepDist
				stepTick += 1
				local bobOffset = math.sin(stepTick * 0.6) * 0.35
				root.CFrame = CFrame.lookAt(nextPos + Vector3.new(0, bobOffset, 0), targetPos)
				head.CFrame = root.CFrame * CFrame.new(0, 2.9 * spec.Scale, 0)
				local kaidoAura = model:FindFirstChild("KaidoDragonAura") :: BasePart?
				if kaidoAura then
					kaidoAura.Position = root.Position
				end
				task.wait(0.05)
			end
		end

		if model.Parent and ((model:GetAttribute("HP") :: number?) or 0) > 0 then
			local curBaseHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) :: number?) or 1000
			local dmgToBase = (enemyKey == "YonkoKaido") and 180 or 35
			local newBaseHp = math.max(0, curBaseHp - dmgToBase)
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, newBaseHp)
			if newBaseHp <= 0 then
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, true)
				Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, "MARINEFORD FALLEN - GAME OVER")
			end
			model:Destroy()
		end
	end)
end

local function startWaveLoop()
	local _, _ = ensureMapAndWaypoints()
	local enemiesFolder = Workspace:WaitForChild("Enemies") :: Folder
	local towersFolder = Workspace:WaitForChild("AnimeTowers") :: Folder

	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE, 1)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, 1000)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP, 1000)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, 0)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER, false)
	Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.PENDING_CARD_DRAWS, 0)

	-- Phase 3 Preparation Phase: Wait up to 15s or until player summons & places their first tower
	for prepSec = 15, 1, -1 do
		if #towersFolder:GetChildren() > 0 then
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, "HERO DEPLOYED! STARTING WAVE 1...")
			task.wait(1.5)
			break
		end
		Workspace:SetAttribute(
			GameConfig.WORKSPACE_ATTRS.WAVE_STATUS,
			string.format("PREP PHASE (%ds): กดปุ่ม SUMMON กลางจอเพื่อสุ่มและวางตัวละคร!", prepSec)
		)
		task.wait(1)
	end

	local wave = 1
	while not (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) :: boolean) do
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.CURRENT_WAVE, wave)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, string.format("WAVE %d IN PROGRESS", wave))

		local count = 6 + math.floor(wave * 2.5)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, count)

		for i = 1, count do
			if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) then
				break
			end
			local key = "ThrillerZombie"
			if wave % 5 == 0 and i == count then
				key = "YonkoKaido"
			elseif i % 5 == 0 then
				key = "GeneralZombie"
			elseif i % 3 == 0 then
				key = "CommandGeneral"
			end
			spawnEnemy(key, wave, enemiesFolder)
			task.wait(0.85)
		end

		while #enemiesFolder:GetChildren() > 0 and not (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) :: boolean) do
			Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, #enemiesFolder:GetChildren())
			task.wait(0.3)
		end
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.ZOMBIES_REMAINING, 0)

		if Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.GAME_OVER) then
			break
		end

		-- Wave Cleared: Grant wave clear cash + trigger Roguelike Card Draft for all players
		awardCashToAllPlayers(90 + wave * 25)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS, string.format("WAVE %d CLEARED! SELECT YOUR UPGRADE CARD!", wave))

		for _, player in ipairs(Players:GetPlayers()) do
			local pending = (player:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) :: number?) or 0
			player:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, pending + 1)
			local curTokens = (player:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
			player:SetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, curTokens + 1)
		end

		task.wait(4)
		wave += 1
	end
end

task.spawn(startWaveLoop)
```

### ขั้นตอนที่ 4: อัปเดตระบบ Tower, สุ่มตัวละคร, วางตามจุด/วางทับ, กระเป๋า, ขาย & อนิเมชั่นวันพีซจัดเต็ม (`src/Track2_TowerSystem/TowerController.server.luau`)
เปิดไฟล์ [src/Track2\_TowerSystem/TowerController.server.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack2_TowerSystem%2FTowerController.server.luau) แล้วแทนที่ด้วยโค้ดด้านล่างนี้:

```luau
--!strict
-- src/Track2_TowerSystem/TowerController.server.luau
-- Phase 3: 0 Initial Towers, Gacha Summon/Reroll, 8 Tactical Placement Pads, Swap/Bag/Sell, Full R6 Models & Over-the-Top One Piece VFX

local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(SharedFolder:WaitForChild("GameConfig")) :: any

type BagUnit = {
	Uid: string,
	HeroId: string,
	Name: string,
	Rarity: string,
	SellValue: number,
}

local function getOrCreateRemote(remoteName: string): RemoteEvent
	local existing = ReplicatedStorage:FindFirstChild(remoteName)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local rem = Instance.new("RemoteEvent")
	rem.Name = remoteName
	rem.Parent = ReplicatedStorage
	return rem
end

local SummonRerollRemote = getOrCreateRemote(GameConfig.REMOTES.TOWER_SUMMON_REROLL)
local PlacementActionRemote = getOrCreateRemote(GameConfig.REMOTES.TOWER_PLACEMENT_ACTION)
local CameraShakeRemote = getOrCreateRemote(GameConfig.REMOTES.VFX_CAMERA_SHAKE)

local towersFolder = Workspace:FindFirstChild("AnimeTowers") :: Folder?
if not towersFolder then
	towersFolder = Instance.new("Folder")
	towersFolder.Name = "AnimeTowers"
	towersFolder.Parent = Workspace
end

local padsFolder = Workspace:FindFirstChild("TowerPlacementPads") :: Folder?
if not padsFolder then
	padsFolder = Instance.new("Folder")
	padsFolder.Name = "TowerPlacementPads"
	padsFolder.Parent = Workspace
end

local slotOccupants: { [string]: Model? } = {}
local slotPadParts: { [string]: Part } = {}

local function getHeroSpec(heroId: string): any
	for _, spec in ipairs(GameConfig.HERO_CATALOG) do
		if spec.Id == heroId then
			return spec
		end
	end
	return GameConfig.HERO_CATALOG[1]
end

local function decodeBag(player: Player): { BagUnit }
	local raw = (player:GetAttribute(GameConfig.PLAYER_ATTRS.INVENTORY_JSON) :: string?) or "[]"
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(raw)
	end)
	if ok and type(decoded) == "table" then
		return decoded :: { BagUnit }
	end
	return {}
end

local function encodeBag(player: Player, bag: { BagUnit })
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(bag)
	end)
	if ok then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.INVENTORY_JSON, encoded)
	end
end

local function rollWeightedHero(): any
	local totalWeight = 0
	for _, h in ipairs(GameConfig.HERO_CATALOG) do
		totalWeight += h.Weight
	end
	local pick = math.random() * totalWeight
	local cumulative = 0
	for _, h in ipairs(GameConfig.HERO_CATALOG) do
		cumulative += h.Weight
		if pick <= cumulative then
			return h
		end
	end
	return GameConfig.HERO_CATALOG[1]
end

-- Procedurally builds an expressive R6 One Piece Hero Model with signature accessories, weapons & glowing aura
local function buildDetailedOnePieceModel(heroSpec: any, slotPos: Vector3, ownerUserId: number, unitUid: string, slotId: string): Model
	local model = Instance.new("Model")
	model.Name = heroSpec.Id .. "_" .. slotId
	model:SetAttribute("HeroId", heroSpec.Id)
	model:SetAttribute("UnitUid", unitUid)
	model:SetAttribute("OwnerUserId", ownerUserId)
	model:SetAttribute("SlotId", slotId)
	model:SetAttribute("BaseY", slotPos.Y + 2.5)

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2.2, 2.4, 1.2)
	root.Position = slotPos + Vector3.new(0, 2.5, 0)
	root.Anchored = true
	root.CanCollide = false
	root.Material = Enum.Material.SmoothPlastic
	root.Color = heroSpec.PrimaryColor
	root.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.5, 1.5, 1.5)
	head.Position = root.Position + Vector3.new(0, 1.95, 0)
	head.Anchored = true
	head.CanCollide = false
	head.Color = Color3.fromRGB(255, 222, 185)
	head.Parent = model

	local rightArm = Instance.new("Part")
	rightArm.Name = "RightArm"
	rightArm.Size = Vector3.new(0.9, 2.2, 0.9)
	rightArm.Position = root.Position + Vector3.new(1.55, 0, 0)
	rightArm.Anchored = true
	rightArm.CanCollide = false
	rightArm.Material = Enum.Material.Neon
	rightArm.Color = heroSpec.SecondaryColor
	rightArm.Parent = model

	local leftArm = Instance.new("Part")
	leftArm.Name = "LeftArm"
	leftArm.Size = Vector3.new(0.9, 2.2, 0.9)
	leftArm.Position = root.Position + Vector3.new(-1.55, 0, 0)
	leftArm.Anchored = true
	leftArm.CanCollide = false
	leftArm.Color = heroSpec.PrimaryColor
	leftArm.Parent = model

	-- Signature Weapon / Aura Ring Attachment
	local auraRing = Instance.new("Part")
	auraRing.Name = "AuraRing"
	auraRing.Shape = Enum.PartType.Cylinder
	auraRing.Size = Vector3.new(0.35, 6.5, 6.5)
	auraRing.CFrame = CFrame.new(slotPos + Vector3.new(0, 0.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
	auraRing.Anchored = true
	auraRing.CanCollide = false
	auraRing.Material = Enum.Material.Neon
	auraRing.Color = heroSpec.SecondaryColor
	auraRing.Transparency = 0.35
	auraRing.Parent = model

	local weapon = Instance.new("Part")
	weapon.Name = "SignatureWeapon"
	weapon.Size = Vector3.new(0.4, 0.4, 4.8)
	weapon.Position = rightArm.Position + Vector3.new(0, 0.5, -1.8)
	weapon.Anchored = true
	weapon.CanCollide = false
	weapon.Material = Enum.Material.Neon
	weapon.Color = heroSpec.SecondaryColor
	weapon.Parent = model

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(180, 48)
	bb.StudsOffset = Vector3.new(0, 4.2, 0)
	bb.AlwaysOnTop = true
	bb.Parent = head

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.fromScale(1, 1)
	titleLbl.BackgroundTransparency = 0.25
	titleLbl.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
	titleLbl.TextColor3 = heroSpec.PrimaryColor
	titleLbl.Font = Enum.Font.GothamBlack
	titleLbl.TextScaled = true
	titleLbl.Text = string.format("[%s]\n%s", heroSpec.Rarity, heroSpec.Name)
	titleLbl.Parent = bb

	model.PrimaryPart = root
	model.Parent = towersFolder
	return model
end

-- Spawns 3D Manga Onomatopoeia Floating Billboard ("DOOM!!", "KAMUSARI!!", etc.)
local function spawnMangaBillboard(pos: Vector3, text: string, color: Color3)
	local anchor = Instance.new("Part")
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Position = pos + Vector3.new(0, 5, 0)
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.Transparency = 1
	anchor.Parent = Workspace

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(220, 68)
	bb.AlwaysOnTop = true
	bb.Parent = anchor

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = color
	lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	lbl.TextStrokeTransparency = 0
	lbl.Font = Enum.Font.GothamBlack
	lbl.TextScaled = true
	lbl.Text = text
	lbl.Parent = bb

	TweenService:Create(anchor, TweenInfo.new(0.85, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = pos + Vector3.new(0, 11, 0),
	}):Play()
	Debris:AddItem(anchor, 0.9)
end

-- Creates jagged Conqueror's Haki Black/Red Lightning Bolts
local function spawnHakiLightningBolts(origin: Vector3, color: Color3, boltCount: number)
	for i = 1, boltCount do
		local bolt = Instance.new("Part")
		bolt.Size = Vector3.new(0.45, 0.45, math.random(7, 14))
		local angle = math.rad((360 / boltCount) * i + math.random(-15, 15))
		local offset = Vector3.new(math.cos(angle) * 4, math.random(1, 6), math.sin(angle) * 4)
		bolt.CFrame = CFrame.lookAt(origin, origin + offset) * CFrame.new(0, 0, -bolt.Size.Z * 0.5)
		bolt.Anchored = true
		bolt.CanCollide = false
		bolt.Material = Enum.Material.Neon
		bolt.Color = color
		bolt.Parent = Workspace
		TweenService:Create(bolt, TweenInfo.new(0.35), { Transparency = 1, Size = Vector3.new(0.1, 0.1, bolt.Size.Z * 1.4) }):Play()
		Debris:AddItem(bolt, 0.4)
	end
end

-- Plays full Character Pose Animation + Over-the-Top One Piece Signature Ultimate VFX
local function playOnePieceUltimateVFX(heroModel: Model, heroSpec: any, targetPos: Vector3)
	local root = heroModel.PrimaryPart
	if not root then
		return
	end
	local rightArm = heroModel:FindFirstChild("RightArm") :: BasePart?
	local weapon = heroModel:FindFirstChild("SignatureWeapon") :: BasePart?
	local style = heroSpec.AttackStyle
	local startPos = root.Position

	-- Animate Hero Wind-up & Face Target
	root.CFrame = CFrame.lookAt(startPos, Vector3.new(targetPos.X, startPos.Y, targetPos.Z))
	if rightArm then
		TweenService:Create(rightArm, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
			Position = root.Position + Vector3.new(0, 2.2, 0),
		}):Play()
	end

	spawnMangaBillboard(targetPos, heroSpec.Onomatopoeia, heroSpec.PrimaryColor)
	CameraShakeRemote:FireAllClients(0.45, heroSpec.SecondaryColor)

	if style == "BajrangFist" then
		-- LUFFY GEAR 5: Giant Island Fist descends from the sky + Conqueror's Haki Lightning
		local giantFist = Instance.new("Part")
		giantFist.Shape = Enum.PartType.Ball
		giantFist.Size = Vector3.new(13, 13, 13)
		giantFist.Position = targetPos + Vector3.new(0, 32, 0)
		giantFist.Anchored = true
		giantFist.CanCollide = false
		giantFist.Material = Enum.Material.Neon
		giantFist.Color = Color3.fromRGB(255, 245, 255)
		giantFist.Parent = Workspace

		TweenService:Create(giantFist, TweenInfo.new(0.28, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
			Position = targetPos + Vector3.new(0, 2, 0),
			Color = Color3.fromRGB(255, 35, 85),
		}):Play()
		Debris:AddItem(giantFist, 0.55)
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(255, 20, 65), 8)

	elseif style == "KingOfHell360" then
		-- ZORO: Dash slice + 360 Emerald/Purple Tornado Dragon Slash
		local tornado = Instance.new("Part")
		tornado.Shape = Enum.PartType.Cylinder
		tornado.Size = Vector3.new(18, 12, 12)
		tornado.CFrame = CFrame.new(targetPos + Vector3.new(0, 6, 0)) * CFrame.Angles(0, 0, math.rad(90))
		tornado.Anchored = true
		tornado.CanCollide = false
		tornado.Material = Enum.Material.Neon
		tornado.Color = Color3.fromRGB(40, 255, 120)
		tornado.Transparency = 0.25
		tornado.Parent = Workspace

		TweenService:Create(tornado, TweenInfo.new(0.45), {
			Size = Vector3.new(26, 20, 20),
			Transparency = 1,
		}):Play()
		Debris:AddItem(tornado, 0.5)
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(165, 55, 255), 6)

	elseif style == "BoeufBurst" then
		-- SANJI: Cobalt Blue Plasma Kick Pillar + White Lightning
		local pillar = Instance.new("Part")
		pillar.Shape = Enum.PartType.Cylinder
		pillar.Size = Vector3.new(22, 9, 9)
		pillar.CFrame = CFrame.new(targetPos + Vector3.new(0, 8, 0)) * CFrame.Angles(0, 0, math.rad(90))
		pillar.Anchored = true
		pillar.CanCollide = false
		pillar.Material = Enum.Material.Neon
		pillar.Color = Color3.fromRGB(35, 155, 255)
		pillar.Parent = Workspace

		TweenService:Create(pillar, TweenInfo.new(0.4), {
			Size = Vector3.new(28, 16, 16),
			Transparency = 1,
		}):Play()
		Debris:AddItem(pillar, 0.45)
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(220, 245, 255), 6)

	elseif style == "Entei" then
		-- ACE: Giant Miniature Sun overhead hurled into target cluster
		local sunBall = Instance.new("Part")
		sunBall.Shape = Enum.PartType.Ball
		sunBall.Size = Vector3.new(11, 11, 11)
		sunBall.Position = startPos + Vector3.new(0, 14, 0)
		sunBall.Anchored = true
		sunBall.CanCollide = false
		sunBall.Material = Enum.Material.Neon
		sunBall.Color = Color3.fromRGB(255, 130, 20)
		sunBall.Parent = Workspace

		TweenService:Create(sunBall, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = targetPos,
			Size = Vector3.new(20, 20, 20),
			Transparency = 0.85,
		}):Play()
		Debris:AddItem(sunBall, 0.45)

	elseif style == "GammaKnife" then
		-- LAW: Giant translucent Cyan K-ROOM Sphere + Piercing Puncture Blade
		local roomDome = Instance.new("Part")
		roomDome.Shape = Enum.PartType.Ball
		roomDome.Size = Vector3.new(4, 4, 4)
		roomDome.Position = targetPos
		roomDome.Anchored = true
		roomDome.CanCollide = false
		roomDome.Material = Enum.Material.ForceField
		roomDome.Color = Color3.fromRGB(60, 220, 255)
		roomDome.Transparency = 0.35
		roomDome.Parent = Workspace

		local giantSword = Instance.new("Part")
		giantSword.Size = Vector3.new(1.2, 26, 1.8)
		giantSword.Position = targetPos + Vector3.new(0, 10, 0)
		giantSword.Anchored = true
		giantSword.CanCollide = false
		giantSword.Material = Enum.Material.Neon
		giantSword.Color = Color3.fromRGB(165, 255, 115)
		giantSword.Parent = Workspace

		TweenService:Create(roomDome, TweenInfo.new(0.45), { Size = Vector3.new(26, 26, 26), Transparency = 1 }):Play()
		TweenService:Create(giantSword, TweenInfo.new(0.4), { Position = targetPos - Vector3.new(0, 4, 0), Transparency = 1 }):Play()
		Debris:AddItem(roomDome, 0.5)
		Debris:AddItem(giantSword, 0.45)

	elseif style == "Kamusari" then
		-- SHANKS: Giant Crimson-Black Crescent Slash Wave tearing across the battlefield
		local crescent = Instance.new("Part")
		crescent.Size = Vector3.new(16, 1.2, 8)
		crescent.CFrame = CFrame.lookAt(startPos, targetPos)
		crescent.Anchored = true
		crescent.CanCollide = false
		crescent.Material = Enum.Material.Neon
		crescent.Color = Color3.fromRGB(235, 20, 50)
		crescent.Parent = Workspace

		TweenService:Create(crescent, TweenInfo.new(0.32), {
			CFrame = CFrame.lookAt(targetPos, targetPos + (targetPos - startPos).Unit * 8),
			Size = Vector3.new(24, 2, 12),
			Transparency = 1,
		}):Play()
		Debris:AddItem(crescent, 0.38)
		spawnHakiLightningBolts(targetPos, Color3.fromRGB(255, 25, 55), 10)

	elseif style == "GuraQuake" then
		-- WHITEBEARD: 3D Mid-Air Glass Shatter Cracks + Sea Quake Shockwave Ring
		for c = 1, 7 do
			local crack = Instance.new("Part")
			crack.Size = Vector3.new(0.3, 0.3, math.random(9, 16))
			crack.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
				* CFrame.Angles(math.rad(math.random(-65, 65)), math.rad(c * 51), 0)
			crack.Anchored = true
			crack.CanCollide = false
			crack.Material = Enum.Material.Neon
			crack.Color = Color3.fromRGB(245, 252, 255)
			crack.Parent = Workspace
			TweenService:Create(crack, TweenInfo.new(0.5), { Transparency = 1 }):Play()
			Debris:AddItem(crack, 0.55)
		end

	elseif style == "YasakaniLight" then
		-- KIZARU: Barrage of 12 Golden Photon Laser Beams from the sky
		local skyOrigin = startPos + Vector3.new(0, 24, 0)
		for b = 1, 10 do
			local hitPos = targetPos + Vector3.new(math.random(-6, 6), 0, math.random(-6, 6))
			local dist = (hitPos - skyOrigin).Magnitude
			local beam = Instance.new("Part")
			beam.Size = Vector3.new(0.55, 0.55, dist)
			beam.CFrame = CFrame.lookAt(skyOrigin, hitPos) * CFrame.new(0, 0, -dist * 0.5)
			beam.Anchored = true
			beam.CanCollide = false
			beam.Material = Enum.Material.Neon
			beam.Color = Color3.fromRGB(255, 240, 75)
			beam.Parent = Workspace
			TweenService:Create(beam, TweenInfo.new(0.28), { Transparency = 1 }):Play()
			Debris:AddItem(beam, 0.32)
		end
	end

	if weapon and rightArm then
		task.delay(0.2, function()
			if rightArm.Parent and root.Parent then
				rightArm.Position = root.Position + Vector3.new(1.55, 0, 0)
				weapon.Position = rightArm.Position + Vector3.new(0, 0.5, -1.8)
			end
		end)
	end
end

local function updatePadVisual(slotId: string)
	local pad = slotPadParts[slotId]
	if not pad then
		return
	end
	local occupant = slotOccupants[slotId]
	local lbl = pad:FindFirstChild("PadBillboard") and pad.PadBillboard:FindFirstChild("Label") :: TextLabel?
	if occupant and occupant.Parent then
		pad.Color = Color3.fromRGB(255, 200, 50)
		if lbl then
			local heroId = (occupant:GetAttribute("HeroId") :: string?) or ""
			local spec = getHeroSpec(heroId)
			lbl.Text = string.format("%s\n[%s]\n(คลิกเพื่อสลับตัว/จัดการ)", slotId, spec.Name)
		end
	else
		pad.Color = Color3.fromRGB(45, 235, 130)
		if lbl then
			lbl.Text = string.format("%s [EMPTY]\nคลิกเพื่อวางตัวละคร", slotId)
		end
	end
end

local function recountPlayerTowers(player: Player)
	local count = 0
	for _, tower in ipairs((towersFolder :: Folder):GetChildren()) do
		if tower:GetAttribute("OwnerUserId") == player.UserId then
			count += 1
		end
	end
	player:SetAttribute(GameConfig.PLAYER_ATTRS.PLACED_TOWERS_COUNT, count)
end

-- Places a unit from the player's Bag onto a Slot. If the Slot is occupied, automatically swaps the old tower back into the Bag!
local function placeOrSwapTowerOnSlot(player: Player, slotId: string, requestedUid: string?)
	local bag = decodeBag(player)
	local targetUid = requestedUid or (player:GetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID) :: string?)
	if (not targetUid or targetUid == "") and #bag > 0 then
		targetUid = bag[1].Uid
	end

	local bagIndex: number? = nil
	local chosenUnit: BagUnit? = nil
	for idx, item in ipairs(bag) do
		if item.Uid == targetUid then
			bagIndex = idx
			chosenUnit = item
			break
		end
	end

	if not chosenUnit or not bagIndex then
		return
	end

	local existingTower = slotOccupants[slotId]
	local maxTowers = (player:GetAttribute(GameConfig.PLAYER_ATTRS.MAX_PLACED_TOWERS) :: number?) or 4
	local currentCount = (player:GetAttribute(GameConfig.PLAYER_ATTRS.PLACED_TOWERS_COUNT) :: number?) or 0

	-- If slot is empty, verify max tower cap
	if not existingTower and currentCount >= maxTowers then
		return
	end

	-- Remove chosen unit from Bag
	table.remove(bag, bagIndex)

	-- If slot already has a tower, store that previous tower back into Bag (Swap/Replace!)
	if existingTower and existingTower.Parent then
		local prevHeroId = (existingTower:GetAttribute("HeroId") :: string?) or "Tower_Luffy_G5"
		local prevUid = (existingTower:GetAttribute("UnitUid") :: string?) or HttpService:GenerateGUID(false)
		local prevSpec = getHeroSpec(prevHeroId)
		table.insert(bag, {
			Uid = prevUid,
			HeroId = prevSpec.Id,
			Name = prevSpec.Name,
			Rarity = prevSpec.Rarity,
			SellValue = prevSpec.SellValue,
		})
		existingTower:Destroy()
		slotOccupants[slotId] = nil
	end

	encodeBag(player, bag)
	if #bag > 0 then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, bag[1].Uid)
	else
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, "")
	end

	-- Spawn new tower on the slot
	local slotSpec = GameConfig.PLACEMENT_SLOTS[1]
	for _, s in ipairs(GameConfig.PLACEMENT_SLOTS) do
		if s.SlotId == slotId then
			slotSpec = s
			break
		end
	end

	local heroSpec = getHeroSpec(chosenUnit.HeroId)
	local newModel = buildDetailedOnePieceModel(heroSpec, slotSpec.Position, player.UserId, chosenUnit.Uid, slotId)
	slotOccupants[slotId] = newModel
	spawnHakiLightningBolts(slotSpec.Position, heroSpec.SecondaryColor, 6)
	spawnMangaBillboard(slotSpec.Position, "DEPLOY!! " .. heroSpec.Name, heroSpec.PrimaryColor)
	updatePadVisual(slotId)
	recountPlayerTowers(player)
end

-- Stores a deployed tower from a Map Slot back into the player's Inventory Bag
local function storeTowerToBag(player: Player, slotId: string)
	local existingTower = slotOccupants[slotId]
	if not existingTower or not existingTower.Parent then
		return
	end
	local prevHeroId = (existingTower:GetAttribute("HeroId") :: string?) or "Tower_Luffy_G5"
	local prevUid = (existingTower:GetAttribute("UnitUid") :: string?) or HttpService:GenerateGUID(false)
	local prevSpec = getHeroSpec(prevHeroId)

	local bag = decodeBag(player)
	table.insert(bag, {
		Uid = prevUid,
		HeroId = prevSpec.Id,
		Name = prevSpec.Name,
		Rarity = prevSpec.Rarity,
		SellValue = prevSpec.SellValue,
	})
	encodeBag(player, bag)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, prevUid)

	existingTower:Destroy()
	slotOccupants[slotId] = nil
	updatePadVisual(slotId)
	recountPlayerTowers(player)
end

-- Sells a tower from either a Map Slot or the Inventory Bag for Cash (+1 Reroll Token if Mythical!)
local function sellTowerUnit(player: Player, sourceType: string, targetKey: string)
	local ls = player:FindFirstChild("leaderstats")
	local cashVal = ls and ls:FindFirstChild("Cash") :: IntValue?

	if sourceType == "Slot" then
		local existingTower = slotOccupants[targetKey]
		if not existingTower or not existingTower.Parent then
			return
		end
		local heroId = (existingTower:GetAttribute("HeroId") :: string?) or "Tower_Luffy_G5"
		local spec = getHeroSpec(heroId)
		if cashVal then
			cashVal.Value += spec.SellValue
		end
		if string.find(spec.Rarity, "MYTHICAL") then
			local curTokens = (player:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
			player:SetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, curTokens + 1)
		end
		existingTower:Destroy()
		slotOccupants[targetKey] = nil
		updatePadVisual(targetKey)
		recountPlayerTowers(player)

	elseif sourceType == "Bag" then
		local bag = decodeBag(player)
		for idx, item in ipairs(bag) do
			if item.Uid == targetKey then
				local spec = getHeroSpec(item.HeroId)
				if cashVal then
					cashVal.Value += spec.SellValue
				end
				if string.find(spec.Rarity, "MYTHICAL") then
					local curTokens = (player:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
					player:SetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, curTokens + 1)
				end
				table.remove(bag, idx)
				encodeBag(player, bag)
				break
			end
		end
	end
end

-- Initialize the 8 Interactive Tactical Placement Pads (0 towers placed at start!)
for _, slotSpec in ipairs(GameConfig.PLACEMENT_SLOTS) do
	local pad = Instance.new("Part")
	pad.Name = slotSpec.SlotId
	pad.Shape = Enum.PartType.Cylinder
	pad.Size = Vector3.new(0.8, 7.5, 7.5)
	pad.CFrame = CFrame.new(slotSpec.Position) * CFrame.Angles(0, 0, math.rad(90))
	pad.Anchored = true
	pad.CanCollide = false
	pad.Material = Enum.Material.Neon
	pad.Color = Color3.fromRGB(45, 235, 130)
	pad.Transparency = 0.2
	pad.Parent = padsFolder

	local bb = Instance.new("BillboardGui")
	bb.Name = "PadBillboard"
	bb.Size = UDim2.fromOffset(150, 42)
	bb.StudsOffset = Vector3.new(0, 2.6, 0)
	bb.AlwaysOnTop = true
	bb.Parent = pad

	local lbl = Instance.new("TextLabel")
	lbl.Name = "Label"
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 0.35
	lbl.BackgroundColor3 = Color3.fromRGB(10, 16, 24)
	lbl.TextColor3 = Color3.fromRGB(220, 255, 230)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Text = string.format("%s [EMPTY]\nคลิกเพื่อวางตัวละคร", slotSpec.SlotId)
	lbl.Parent = bb

	local cd = Instance.new("ClickDetector")
	cd.MaxActivationDistance = 120
	cd.Parent = pad
	cd.MouseClick:Connect(function(player: Player)
		placeOrSwapTowerOnSlot(player, slotSpec.SlotId, nil)
	end)

	slotPadParts[slotSpec.SlotId] = pad
end

-- Remote Handler: Summon & Reroll One Piece Characters
SummonRerollRemote.OnServerEvent:Connect(function(player: Player, mode: any)
	if type(mode) ~= "string" then
		return
	end
	local ls = player:FindFirstChild("leaderstats")
	local cashVal = ls and ls:FindFirstChild("Cash") :: IntValue?
	local freeTickets = (player:GetAttribute(GameConfig.PLAYER_ATTRS.FREE_SUMMON_TICKETS) :: number?) or 0
	local rerollTokens = (player:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
	local bag = decodeBag(player)

	if mode == "Summon" then
		if freeTickets > 0 then
			player:SetAttribute(GameConfig.PLAYER_ATTRS.FREE_SUMMON_TICKETS, freeTickets - 1)
		elseif cashVal and cashVal.Value >= GameConfig.INITIAL_PLAYER_STATS.SUMMON_COST_CASH then
			cashVal.Value -= GameConfig.INITIAL_PLAYER_STATS.SUMMON_COST_CASH
		else
			return
		end

		local rolledSpec = rollWeightedHero()
		local newUid = HttpService:GenerateGUID(false)
		table.insert(bag, {
			Uid = newUid,
			HeroId = rolledSpec.Id,
			Name = rolledSpec.Name,
			Rarity = rolledSpec.Rarity,
			SellValue = rolledSpec.SellValue,
		})
		encodeBag(player, bag)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_HERO_ID, rolledSpec.Id)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_UNIT_UID, newUid)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, newUid)

	elseif mode == "Reroll" then
		if rerollTokens > 0 then
			player:SetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, rerollTokens - 1)
		elseif cashVal and cashVal.Value >= GameConfig.INITIAL_PLAYER_STATS.REROLL_COST_CASH then
			cashVal.Value -= GameConfig.INITIAL_PLAYER_STATS.REROLL_COST_CASH
		else
			return
		end

		local lastUid = (player:GetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_UNIT_UID) :: string?) or ""
		local rolledSpec = rollWeightedHero()
		local replaced = false

		for idx, item in ipairs(bag) do
			if item.Uid == lastUid then
				bag[idx] = {
					Uid = lastUid,
					HeroId = rolledSpec.Id,
					Name = rolledSpec.Name,
					Rarity = rolledSpec.Rarity,
					SellValue = rolledSpec.SellValue,
				}
				replaced = true
				break
			end
		end

		if not replaced then
			local newUid = HttpService:GenerateGUID(false)
			table.insert(bag, {
				Uid = newUid,
				HeroId = rolledSpec.Id,
				Name = rolledSpec.Name,
				Rarity = rolledSpec.Rarity,
				SellValue = rolledSpec.SellValue,
			})
			lastUid = newUid
		end

		encodeBag(player, bag)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_HERO_ID, rolledSpec.Id)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_UNIT_UID, lastUid)
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, lastUid)
	end
end)

-- Remote Handler: Select Bag Unit, Place/Swap on Slot, Store to Bag, or Sell
PlacementActionRemote.OnServerEvent:Connect(function(player: Player, actionType: any, arg1: any, arg2: any)
	if type(actionType) ~= "string" then
		return
	end
	if actionType == "SelectBagUnit" and type(arg1) == "string" then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, arg1)
	elseif actionType == "PlaceOrSwap" and type(arg1) == "string" then
		local uid = (type(arg2) == "string") and arg2 or nil
		placeOrSwapTowerOnSlot(player, arg1, uid)
	elseif actionType == "StoreToBag" and type(arg1) == "string" then
		storeTowerToBag(player, arg1)
	elseif actionType == "SellFromSlot" and type(arg1) == "string" then
		sellTowerUnit(player, "Slot", arg1)
	elseif actionType == "SellFromBag" and type(arg1) == "string" then
		sellTowerUnit(player, "Bag", arg1)
	end
end)

-- Continuous Idle Breathing/Floating Animation Loop for All Placed One Piece Towers
RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for _, tower in ipairs((towersFolder :: Folder):GetChildren()) do
		if tower:IsA("Model") and tower.PrimaryPart then
			local baseY = (tower:GetAttribute("BaseY") :: number?) or 5.5
			local bob = math.sin(now * 3.2) * 0.35
			local curPos = tower.PrimaryPart.Position
			tower.PrimaryPart.Position = Vector3.new(curPos.X, baseY + bob, curPos.Z)
			local head = tower:FindFirstChild("Head") :: BasePart?
			if head then
				head.Position = tower.PrimaryPart.Position + Vector3.new(0, 1.95, 0)
			end
			local ring = tower:FindFirstChild("AuraRing") :: BasePart?
			if ring then
				ring.CFrame = ring.CFrame * CFrame.Angles(math.rad(2.5), 0, 0)
			end
		end
	end
end)

-- Combat Targeting & Over-the-Top Ultimate Execution Loop
local lastAttackTime: { [Model]: number } = {}

task.spawn(function()
	while true do
		local now = os.clock()
		local enemiesFolder = Workspace:FindFirstChild("Enemies")
		local enemies = enemiesFolder and enemiesFolder:GetChildren() or {}

		for _, tower in ipairs((towersFolder :: Folder):GetChildren()) do
			if tower:IsA("Model") and tower.PrimaryPart then
				local heroId = (tower:GetAttribute("HeroId") :: string?) or "Tower_Luffy_G5"
				local ownerId = (tower:GetAttribute("OwnerUserId") :: number?) or 0
				local owner = Players:GetPlayerByUserId(ownerId) or Players:GetPlayers()[1]
				local spec = getHeroSpec(heroId)

				local baseDmg = owner and (owner:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) :: number?) or 50
				local baseRange = owner and (owner:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) :: number?) or 30
				local baseCd = owner and (owner:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) :: number?) or 1.15
				local baseSplash = owner and (owner:GetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT) :: number?) or 7
				local critChance = owner and (owner:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE) :: number?) or 0.08
				local critDmg = owner and (owner:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_DAMAGE) :: number?) or 2.0

				local finalCooldown = math.max(0.15, baseCd * spec.CooldownMult)
				local finalRange = baseRange + spec.RangeBonus
				local finalSplash = baseSplash + spec.SplashBonus
				local lastTime = lastAttackTime[tower] or 0

				if (now - lastTime) >= finalCooldown then
					local nearestEnemy: Model? = nil
					local minDist = finalRange
					for _, enemy in ipairs(enemies) do
						if enemy:IsA("Model") and enemy.PrimaryPart and ((enemy:GetAttribute("HP") :: number?) or 0) > 0 then
							local d = (enemy.PrimaryPart.Position - tower.PrimaryPart.Position).Magnitude
							if d <= minDist then
								minDist = d
								nearestEnemy = enemy
							end
						end
					end

					if nearestEnemy and nearestEnemy.PrimaryPart then
						lastAttackTime[tower] = now
						local impactPos = nearestEnemy.PrimaryPart.Position
						playOnePieceUltimateVFX(tower, spec, impactPos)

						local isCrit = (math.random() < critChance)
						local dmg = baseDmg * spec.DamageMult * (isCrit and critDmg or 1.0)

						for _, enemy in ipairs(enemies) do
							if enemy:IsA("Model") and enemy.PrimaryPart then
								local d = (enemy.PrimaryPart.Position - impactPos).Magnitude
								if d <= finalSplash then
									local curHp = (enemy:GetAttribute("HP") :: number?) or 0
									enemy:SetAttribute("HP", curHp - dmg)
									if spec.AttackStyle == "GuraQuake" then
										enemy:SetAttribute("SlowUntil", now + 2.5)
									end
								end
							end
						end
					end
				end
			end
		end
		task.wait(0.1)
	end
end)
```

### ขั้นตอนที่ 5: อัปเดตระบบเซิร์ฟเวอร์อัปเกรดและการ์ด 12 ใบ (`src/Track3_UpgradeServer/UpgradeServer.server.luau`)
เปิดไฟล์ [src/Track3\_UpgradeServer/UpgradeServer.server.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack3_UpgradeServer%2FUpgradeServer.server.luau) แล้วแทนที่ด้วยโค้ดด้านล่างนี้:

```luau
--!strict
-- src/Track3_UpgradeServer/UpgradeServer.server.luau
-- Phase 3: Server Authority Handler for 12 Diverse Wave-Clear Cards, Global Stats & Initial Gacha Attributes

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(SharedFolder:WaitForChild("GameConfig")) :: any

local function getOrCreateRemote(name: string): RemoteEvent
	local existing = ReplicatedStorage:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local rem = Instance.new("RemoteEvent")
	rem.Name = name
	rem.Parent = ReplicatedStorage
	return rem
end

local UpgradeRequestRemote = getOrCreateRemote(GameConfig.REMOTES.UPGRADE_REQUEST)
local CardDraftRemote = getOrCreateRemote(GameConfig.REMOTES.CARD_DRAFT_SELECT)

local function initPlayer(player: Player)
	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	ls.Parent = player

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = GameConfig.INITIAL_PLAYER_STATS.CASH
	cash.Parent = ls

	player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, GameConfig.INITIAL_PLAYER_STATS.DAMAGE)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT, GameConfig.INITIAL_PLAYER_STATS.RANGE)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, GameConfig.INITIAL_PLAYER_STATS.COOLDOWN)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT, GameConfig.INITIAL_PLAYER_STATS.SPLASH_RADIUS)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE, GameConfig.INITIAL_PLAYER_STATS.CRIT_CHANCE)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.CRIT_DAMAGE, GameConfig.INITIAL_PLAYER_STATS.CRIT_DAMAGE)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.BOUNTY_MULT, GameConfig.INITIAL_PLAYER_STATS.BOUNTY_MULT)

	player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, 1)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL, 1)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL, 1)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, 0)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL, 0)

	-- Phase 3 Starter Gacha & Inventory Attributes (Starts with 0 placed towers & 1 Free Summon Ticket!)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, GameConfig.INITIAL_PLAYER_STATS.REROLL_TOKENS)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.FREE_SUMMON_TICKETS, GameConfig.INITIAL_PLAYER_STATS.FREE_SUMMON_TICKETS)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.MAX_PLACED_TOWERS, GameConfig.INITIAL_PLAYER_STATS.MAX_PLACED_TOWERS)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.PLACED_TOWERS_COUNT, 0)
	player:SetAttribute(GameConfig.PLAYER_ATTRS.INVENTORY_JSON, "[]")
	player:SetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_HERO_ID, "")
	player:SetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_UNIT_UID, "")
	player:SetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID, "")
end

Players.PlayerAdded:Connect(initPlayer)
for _, p in ipairs(Players:GetPlayers()) do
	initPlayer(p)
end

-- Cash Stat Upgrades (Damage, Range, Speed)
UpgradeRequestRemote.OnServerEvent:Connect(function(player: Player, upgradeType: any)
	if type(upgradeType) ~= "string" then
		return
	end
	local ls = player:FindFirstChild("leaderstats")
	local cash = ls and ls:FindFirstChild("Cash") :: IntValue?
	if not cash then
		return
	end

	if upgradeType == "Damage" then
		local lvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL) :: number?) or 1
		local cost = math.floor(75 * math.pow(1.35, lvl - 1))
		if cash.Value >= cost then
			cash.Value -= cost
			local cur = (player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) :: number?) or 50
			player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, math.floor(cur * 1.32 + 12))
			player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_LEVEL, lvl + 1)
		end
	elseif upgradeType == "Range" then
		local lvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL) :: number?) or 1
		local cost = math.floor(60 * math.pow(1.30, lvl - 1))
		if cash.Value >= cost then
			cash.Value -= cost
			local cur = (player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) :: number?) or 30
			player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT, cur + 4)
			player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_LEVEL, lvl + 1)
		end
	elseif upgradeType == "Speed" then
		local lvl = (player:GetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL) :: number?) or 1
		local cost = math.floor(90 * math.pow(1.40, lvl - 1))
		if cash.Value >= cost then
			cash.Value -= cost
			local cur = (player:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) :: number?) or 1.15
			player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, math.max(0.15, cur * 0.90))
			player:SetAttribute(GameConfig.PLAYER_ATTRS.SPEED_LEVEL, lvl + 1)
		end
	end
end)

-- 12-Card Wave Draft Selection Handler (Applies Global Stats, Cash, Rerolls, Extra Tower Slots & Base Heal)
CardDraftRemote.OnServerEvent:Connect(function(player: Player, cardId: any)
	if type(cardId) ~= "string" then
		return
	end
	local pending = (player:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) :: number?) or 0
	if pending <= 0 then
		return
	end

	local chosenCard: any = nil
	for _, c in ipairs(GameConfig.CARD_POOL) do
		if c.Id == cardId then
			chosenCard = c
			break
		end
	end
	if not chosenCard then
		return
	end

	player:SetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS, pending - 1)
	local pickedTotal = (player:GetAttribute(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL) :: number?) or 0
	player:SetAttribute(GameConfig.PLAYER_ATTRS.CARDS_PICKED_TOTAL, pickedTotal + 1)

	local curDmg = (player:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) :: number?) or 50
	local curRange = (player:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) :: number?) or 30
	local curCd = (player:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) :: number?) or 1.15
	local curSplash = (player:GetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT) :: number?) or 7
	local curCrit = (player:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE) :: number?) or 0.08
	local curCritDmg = (player:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_DAMAGE) :: number?) or 2.0
	local curBounty = (player:GetAttribute(GameConfig.PLAYER_ATTRS.BOUNTY_MULT) :: number?) or 1.0
	local curRerolls = (player:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
	local curMaxTowers = (player:GetAttribute(GameConfig.PLAYER_ATTRS.MAX_PLACED_TOWERS) :: number?) or 4

	if chosenCard.DamagePct or chosenCard.DamageFlat then
		local pct = chosenCard.DamagePct or 0
		local flat = chosenCard.DamageFlat or 0
		player:SetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT, math.floor(curDmg * (1 + pct) + flat))
	end
	if chosenCard.RangeFlat then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT, curRange + chosenCard.RangeFlat)
	end
	if chosenCard.CooldownMult then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT, math.max(0.15, curCd * chosenCard.CooldownMult))
	end
	if chosenCard.SplashFlat then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.SPLASH_STAT, curSplash + chosenCard.SplashFlat)
	end
	if chosenCard.CritChanceFlat then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE, math.min(0.95, curCrit + chosenCard.CritChanceFlat))
	end
	if chosenCard.CritDamageFlat then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.CRIT_DAMAGE, curCritDmg + chosenCard.CritDamageFlat)
	end
	if chosenCard.BountyMultFlat then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.BOUNTY_MULT, curBounty + chosenCard.BountyMultFlat)
	end
	if chosenCard.BonusRerolls then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS, curRerolls + chosenCard.BonusRerolls)
	end
	if chosenCard.ExtraTowerSlot then
		player:SetAttribute(GameConfig.PLAYER_ATTRS.MAX_PLACED_TOWERS, math.min(8, curMaxTowers + chosenCard.ExtraTowerSlot))
	end
	if chosenCard.InstantCash then
		local ls = player:FindFirstChild("leaderstats")
		local cash = ls and ls:FindFirstChild("Cash") :: IntValue?
		if cash then
			cash.Value += chosenCard.InstantCash
		end
	end
	if chosenCard.BaseHeal then
		local curBase = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) :: number?) or 1000
		local maxBase = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP) :: number?) or 1000
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP, maxBase + chosenCard.BaseHeal)
		Workspace:SetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP, curBase + chosenCard.BaseHeal)
	end
end)
```

### ขั้นตอนที่ 6: อัปเดต UI ปุ่มสุ่มกลางจอ, กระเป๋าตัวละคร, จัดการจุดวาง/ขาย และการเลือกการ์ด 12 แบบ (`src/Track3_UISystem/UpgradeHUD.client.luau`)
เปิดไฟล์ [src/Track3\_UISystem/UpgradeHUD.client.luau](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fsrc%2FTrack3_UISystem%2FUpgradeHUD.client.luau) แล้วแทนที่ด้วยโค้ดด้านล่างนี้:

```luau
--!strict
-- src/Track3_UISystem/UpgradeHUD.client.luau
-- Phase 3 Client UI: Central Screen Summon & Reroll Modal, Bag/Slot Manager (Swap, Store, Sell), Camera Shake & 12-Card Draft Modal

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig")) :: any

local UpgradeRemote = ReplicatedStorage:WaitForChild(GameConfig.REMOTES.UPGRADE_REQUEST) :: RemoteEvent
local CardDraftRemote = ReplicatedStorage:WaitForChild(GameConfig.REMOTES.CARD_DRAFT_SELECT) :: RemoteEvent
local SummonRerollRemote = ReplicatedStorage:WaitForChild(GameConfig.REMOTES.TOWER_SUMMON_REROLL) :: RemoteEvent
local PlacementActionRemote = ReplicatedStorage:WaitForChild(GameConfig.REMOTES.TOWER_PLACEMENT_ACTION) :: RemoteEvent
local CameraShakeRemote = ReplicatedStorage:WaitForChild(GameConfig.REMOTES.VFX_CAMERA_SHAKE) :: RemoteEvent

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnimeLimitlessPhase3HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 1. Top Wave & Global Stats Banner
local topBanner = Instance.new("Frame")
topBanner.Size = UDim2.new(0, 680, 0, 58)
topBanner.Position = UDim2.new(0.5, -340, 0, 10)
topBanner.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
topBanner.BorderSizePixel = 0
topBanner.Parent = screenGui

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBanner

local waveStatusLbl = Instance.new("TextLabel")
waveStatusLbl.Size = UDim2.new(1, -20, 0, 26)
waveStatusLbl.Position = UDim2.fromOffset(10, 4)
waveStatusLbl.BackgroundTransparency = 1
waveStatusLbl.TextColor3 = Color3.fromRGB(255, 215, 70)
waveStatusLbl.Font = Enum.Font.GothamBlack
waveStatusLbl.TextScaled = true
waveStatusLbl.Text = "PREPARING MARINEFORD..."
waveStatusLbl.Parent = topBanner

local statsSummaryLbl = Instance.new("TextLabel")
statsSummaryLbl.Size = UDim2.new(1, -20, 0, 22)
statsSummaryLbl.Position = UDim2.fromOffset(10, 32)
statsSummaryLbl.BackgroundTransparency = 1
statsSummaryLbl.TextColor3 = Color3.fromRGB(180, 230, 255)
statsSummaryLbl.Font = Enum.Font.GothamBold
statsSummaryLbl.TextScaled = true
statsSummaryLbl.Text = "DMG: 50 | RNG: 30 | CD: 1.15s | CRIT: 8% | TOWERS: 0/4"
statsSummaryLbl.Parent = topBanner

-- 2. Central Screen Summon & Reroll Modal (Opens automatically at game start when player has 0 towers!)
local summonModal = Instance.new("Frame")
summonModal.Name = "CentralSummonModal"
summonModal.Size = UDim2.fromOffset(520, 330)
summonModal.Position = UDim2.new(0.5, -260, 0.5, -165)
summonModal.BackgroundColor3 = Color3.fromRGB(18, 16, 30)
summonModal.Visible = true
summonModal.Parent = screenGui

local modalCorner = Instance.new("UICorner")
modalCorner.CornerRadius = UDim.new(0, 14)
modalCorner.Parent = summonModal

local modalStroke = Instance.new("UIStroke")
modalStroke.Color = Color3.fromRGB(255, 200, 55)
modalStroke.Thickness = 3
modalStroke.Parent = summonModal

local modalHeader = Instance.new("TextLabel")
modalHeader.Size = UDim2.new(1, -20, 0, 38)
modalHeader.Position = UDim2.fromOffset(10, 10)
modalHeader.BackgroundTransparency = 1
modalHeader.TextColor3 = Color3.fromRGB(255, 215, 65)
modalHeader.Font = Enum.Font.GothamBlack
modalHeader.TextScaled = true
modalHeader.Text = "🏴‍☠️ GRAND LINE HERO SUMMON & REROLL 🏴‍☠️"
modalHeader.Parent = summonModal

local wantedPosterBox = Instance.new("Frame")
wantedPosterBox.Size = UDim2.new(1, -40, 0, 135)
wantedPosterBox.Position = UDim2.fromOffset(20, 55)
wantedPosterBox.BackgroundColor3 = Color3.fromRGB(32, 26, 44)
wantedPosterBox.Parent = summonModal

local posterCorner = Instance.new("UICorner")
posterCorner.CornerRadius = UDim.new(0, 10)
posterCorner.Parent = wantedPosterBox

local rolledHeroTitle = Instance.new("TextLabel")
rolledHeroTitle.Size = UDim2.new(1, -20, 0, 115)
rolledHeroTitle.Position = UDim2.fromOffset(10, 10)
rolledHeroTitle.BackgroundTransparency = 1
rolledHeroTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
rolledHeroTitle.Font = Enum.Font.GothamBlack
rolledHeroTitle.TextScaled = true
rolledHeroTitle.Text = "เริ่มเกมยังไม่มีตัวละครบนสนาม!\nกดปุ่ม [SUMMON HERO] ด้านล่างเพื่อสุ่มตัวละครวันพีซตัวแรก (ฟรี 1 ครั้ง!)"
rolledHeroTitle.Parent = wantedPosterBox

local btnSummon = Instance.new("TextButton")
btnSummon.Size = UDim2.fromOffset(230, 52)
btnSummon.Position = UDim2.fromOffset(20, 205)
btnSummon.BackgroundColor3 = Color3.fromRGB(255, 185, 30)
btnSummon.TextColor3 = Color3.fromRGB(20, 15, 10)
btnSummon.Font = Enum.Font.GothamBlack
btnSummon.TextScaled = true
btnSummon.Text = "🎲 SUMMON (FREE x1)"
btnSummon.Parent = summonModal

local btnReroll = Instance.new("TextButton")
btnReroll.Size = UDim2.fromOffset(230, 52)
btnReroll.Position = UDim2.fromOffset(270, 205)
btnReroll.BackgroundColor3 = Color3.fromRGB(185, 55, 255)
btnReroll.TextColor3 = Color3.fromRGB(255, 255, 255)
btnReroll.Font = Enum.Font.GothamBlack
btnReroll.TextScaled = true
btnReroll.Text = "🔄 REROLL (Tokens: 3)"
btnReroll.Parent = summonModal

local btnCloseSummon = Instance.new("TextButton")
btnCloseSummon.Size = UDim2.new(1, -40, 0, 44)
btnCloseSummon.Position = UDim2.fromOffset(20, 268)
btnCloseSummon.BackgroundColor3 = Color3.fromRGB(35, 195, 110)
btnCloseSummon.TextColor3 = Color3.fromRGB(255, 255, 255)
btnCloseSummon.Font = Enum.Font.GothamBlack
btnCloseSummon.TextScaled = true
btnCloseSummon.Text = "📍 เลือกจุดวางบนสนาม / เก็บเข้ากระเป๋า (ไปที่หน้าสนาม)"
btnCloseSummon.Parent = summonModal

btnSummon.MouseButton1Click:Connect(function()
	SummonRerollRemote:FireServer("Summon")
end)

btnReroll.MouseButton1Click:Connect(function()
	SummonRerollRemote:FireServer("Reroll")
end)

btnCloseSummon.MouseButton1Click:Connect(function()
	summonModal.Visible = false
end)

-- Floating Button to Re-Open Central Summon Modal Anytime
local toggleSummonBtn = Instance.new("TextButton")
toggleSummonBtn.Size = UDim2.fromOffset(210, 46)
toggleSummonBtn.Position = UDim2.new(0, 16, 0.5, -120)
toggleSummonBtn.BackgroundColor3 = Color3.fromRGB(255, 190, 40)
toggleSummonBtn.TextColor3 = Color3.fromRGB(20, 14, 10)
toggleSummonBtn.Font = Enum.Font.GothamBlack
toggleSummonBtn.TextScaled = true
toggleSummonBtn.Text = "🎲 เปิดหน้าสุ่ม / REROLL"
toggleSummonBtn.Parent = screenGui

toggleSummonBtn.MouseButton1Click:Connect(function()
	summonModal.Visible = not summonModal.Visible
end)

-- 3. Bottom Inventory Bag & Tactical Slot Manager (Place, Replace Existing, Store to Bag, Sell)
local bagPanel = Instance.new("Frame")
bagPanel.Size = UDim2.new(0, 860, 0, 155)
bagPanel.Position = UDim2.new(0.5, -430, 1, -165)
bagPanel.BackgroundColor3 = Color3.fromRGB(14, 18, 28)
bagPanel.Parent = screenGui

local bagCorner = Instance.new("UICorner")
bagCorner.CornerRadius = UDim.new(0, 10)
bagCorner.Parent = bagPanel

local bagHeader = Instance.new("TextLabel")
bagHeader.Size = UDim2.new(1, -20, 0, 24)
bagHeader.Position = UDim2.fromOffset(10, 4)
bagHeader.BackgroundTransparency = 1
bagHeader.TextColor3 = Color3.fromRGB(255, 220, 90)
bagHeader.Font = Enum.Font.GothamBold
bagHeader.TextScaled = true
bagHeader.Text = "🎒 กระเป๋าตัวละคร (คลิกเลือกตัวในกระเป๋า แล้วกดจุดวาง Slot 1-8 เพื่อวางหรือวางทับตัวเดิม | กดเก็บเข้ากระเป๋า/ขายได้ทันที)"
bagHeader.Parent = bagPanel

local bagContainer = Instance.new("Frame")
bagContainer.Size = UDim2.new(1, -20, 0, 56)
bagContainer.Position = UDim2.fromOffset(10, 32)
bagContainer.BackgroundTransparency = 1
bagContainer.Parent = bagPanel

local bagLayout = Instance.new("UIListLayout")
bagLayout.FillDirection = Enum.FillDirection.Horizontal
bagLayout.Padding = UDim.new(0, 6)
bagLayout.Parent = bagContainer

local slotsContainer = Instance.new("Frame")
slotsContainer.Size = UDim2.new(1, -20, 0, 54)
slotsContainer.Position = UDim2.fromOffset(10, 94)
slotsContainer.BackgroundTransparency = 1
slotsContainer.Parent = bagPanel

local slotsLayout = Instance.new("UIListLayout")
slotsLayout.FillDirection = Enum.FillDirection.Horizontal
slotsLayout.Padding = UDim.new(0, 6)
slotsLayout.Parent = slotsContainer

local function refreshBagAndSlotsUI()
	for _, child in ipairs(bagContainer:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	for _, child in ipairs(slotsContainer:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local rawBag = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.INVENTORY_JSON) :: string?) or "[]"
	local ok, bagList = pcall(function()
		return HttpService:JSONDecode(rawBag)
	end)
	local items = (ok and type(bagList) == "table") and bagList or {}
	local selectedUid = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.SELECTED_BAG_UID) :: string?) or ""

	for _, unit in ipairs(items) do
		local itemFrame = Instance.new("Frame")
		itemFrame.Size = UDim2.fromOffset(160, 54)
		itemFrame.BackgroundColor3 = (unit.Uid == selectedUid) and Color3.fromRGB(45, 95, 65) or Color3.fromRGB(28, 32, 48)
		itemFrame.Parent = bagContainer

		local selectBtn = Instance.new("TextButton")
		selectBtn.Size = UDim2.new(0.68, 0, 1, 0)
		selectBtn.BackgroundTransparency = 1
		selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		selectBtn.Font = Enum.Font.GothamBold
		selectBtn.TextScaled = true
		selectBtn.Text = string.format("%s\n[%s]", unit.Name, unit.Rarity)
		selectBtn.Parent = itemFrame
		selectBtn.MouseButton1Click:Connect(function()
			PlacementActionRemote:FireServer("SelectBagUnit", unit.Uid)
		end)

		local sellBagBtn = Instance.new("TextButton")
		sellBagBtn.Size = UDim2.new(0.32, 0, 1, 0)
		sellBagBtn.Position = UDim2.fromScale(0.68, 0)
		sellBagBtn.BackgroundColor3 = Color3.fromRGB(200, 45, 55)
		sellBagBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		sellBagBtn.Font = Enum.Font.GothamBlack
		sellBagBtn.TextScaled = true
		sellBagBtn.Text = string.format("ขาย\n+$%d", unit.SellValue or 150)
		sellBagBtn.Parent = itemFrame
		sellBagBtn.MouseButton1Click:Connect(function()
			PlacementActionRemote:FireServer("SellFromBag", unit.Uid)
		end)
	end

	-- Render 8 Map Placement Slot Buttons (Place / Swap / Recall to Bag / Sell)
	local towersFolder = Workspace:FindFirstChild("AnimeTowers")
	for idx, slotSpec in ipairs(GameConfig.PLACEMENT_SLOTS) do
		local occupant: Model? = nil
		if towersFolder then
			for _, t in ipairs(towersFolder:GetChildren()) do
				if t:GetAttribute("SlotId") == slotSpec.SlotId then
					occupant = t :: Model
					break
				end
			end
		end

		local slotCard = Instance.new("Frame")
		slotCard.Size = UDim2.fromOffset(100, 52)
		slotCard.BackgroundColor3 = occupant and Color3.fromRGB(50, 42, 20) or Color3.fromRGB(22, 42, 32)
		slotCard.Parent = slotsContainer

		local mainSlotBtn = Instance.new("TextButton")
		mainSlotBtn.Size = UDim2.new(1, 0, occupant and 0.55 or 1, 0)
		mainSlotBtn.BackgroundTransparency = 1
		mainSlotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		mainSlotBtn.Font = Enum.Font.GothamBold
		mainSlotBtn.TextScaled = true
		mainSlotBtn.Text = occupant and string.format("Slot %d: สลับตัว", idx) or string.format("Slot %d: วางที่นี่", idx)
		mainSlotBtn.Parent = slotCard
		mainSlotBtn.MouseButton1Click:Connect(function()
			PlacementActionRemote:FireServer("PlaceOrSwap", slotSpec.SlotId, selectedUid)
		end)

		if occupant then
			local bagBtn = Instance.new("TextButton")
			bagBtn.Size = UDim2.new(0.5, 0, 0.45, 0)
			bagBtn.Position = UDim2.fromScale(0, 0.55)
			bagBtn.BackgroundColor3 = Color3.fromRGB(45, 125, 220)
			bagBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			bagBtn.Font = Enum.Font.GothamBold
			bagBtn.TextScaled = true
			bagBtn.Text = "เก็บ"
			bagBtn.Parent = slotCard
			bagBtn.MouseButton1Click:Connect(function()
				PlacementActionRemote:FireServer("StoreToBag", slotSpec.SlotId)
			end)

			local sellBtn = Instance.new("TextButton")
			sellBtn.Size = UDim2.new(0.5, 0, 0.45, 0)
			sellBtn.Position = UDim2.fromScale(0.5, 0.55)
			sellBtn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
			sellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			sellBtn.Font = Enum.Font.GothamBold
			sellBtn.TextScaled = true
			sellBtn.Text = "ขาย"
			sellBtn.Parent = slotCard
			sellBtn.MouseButton1Click:Connect(function()
				PlacementActionRemote:FireServer("SellFromSlot", slotSpec.SlotId)
			end)
		end
	end
end

-- 4. Wave-Clear Roguelike Card Draft Modal (Draws 3 Random Distinct Cards from the 12-Card Pool)
local draftModal = Instance.new("Frame")
draftModal.Size = UDim2.fromOffset(760, 310)
draftModal.Position = UDim2.new(0.5, -380, 0.5, -155)
draftModal.BackgroundColor3 = Color3.fromRGB(12, 12, 22)
draftModal.Visible = false
draftModal.Parent = screenGui

local draftHeader = Instance.new("TextLabel")
draftHeader.Size = UDim2.new(1, -20, 0, 38)
draftHeader.Position = UDim2.fromOffset(10, 8)
draftHeader.BackgroundTransparency = 1
draftHeader.TextColor3 = Color3.fromRGB(255, 215, 65)
draftHeader.Font = Enum.Font.GothamBlack
draftHeader.TextScaled = true
draftHeader.Text = "⚡ WAVE CLEARED! เลือกการ์ดอัปเกรดพลังรวมของทีม (1 จาก 3 ใบ) ⚡"
draftHeader.Parent = draftModal

local cardsRow = Instance.new("Frame")
cardsRow.Size = UDim2.new(1, -30, 0, 245)
cardsRow.Position = UDim2.fromOffset(15, 52)
cardsRow.BackgroundTransparency = 1
cardsRow.Parent = draftModal

local cardsRowLayout = Instance.new("UIListLayout")
cardsRowLayout.FillDirection = Enum.FillDirection.Horizontal
cardsRowLayout.Padding = UDim.new(0, 14)
cardsRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
cardsRowLayout.Parent = cardsRow

local function populateThreeRandomCards()
	for _, c in ipairs(cardsRow:GetChildren()) do
		if c:IsA("GuiObject") then
			c:Destroy()
		end
	end

	-- Shuffle and pick 3 distinct cards from the 12-card pool
	local poolCopy = table.clone(GameConfig.CARD_POOL)
	for i = #poolCopy, 2, -1 do
		local j = math.random(1, i)
		poolCopy[i], poolCopy[j] = poolCopy[j], poolCopy[i]
	end

	for i = 1, math.min(3, #poolCopy) do
		local card = poolCopy[i]
		local cardBtn = Instance.new("TextButton")
		cardBtn.Size = UDim2.fromOffset(232, 238)
		cardBtn.BackgroundColor3 = card.BgColor
		cardBtn.Text = ""
		cardBtn.Parent = cardsRow

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = cardBtn

		local stroke = Instance.new("UIStroke")
		stroke.Color = card.BorderColor
		stroke.Thickness = 3
		stroke.Parent = cardBtn

		local rarityLbl = Instance.new("TextLabel")
		rarityLbl.Size = UDim2.new(1, -16, 0, 28)
		rarityLbl.Position = UDim2.fromOffset(8, 8)
		rarityLbl.BackgroundTransparency = 1
		rarityLbl.TextColor3 = card.BorderColor
		rarityLbl.Font = Enum.Font.GothamBlack
		rarityLbl.TextScaled = true
		rarityLbl.Text = string.format("[%s]\n%s", card.Rarity, card.Category)
		rarityLbl.Parent = cardBtn

		local titleLbl = Instance.new("TextLabel")
		titleLbl.Size = UDim2.new(1, -16, 0, 56)
		titleLbl.Position = UDim2.fromOffset(8, 44)
		titleLbl.BackgroundTransparency = 1
		titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		titleLbl.Font = Enum.Font.GothamBlack
		titleLbl.TextScaled = true
		titleLbl.Text = card.Title
		titleLbl.Parent = cardBtn

		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(1, -16, 0, 118)
		descLbl.Position = UDim2.fromOffset(8, 108)
		descLbl.BackgroundTransparency = 1
		descLbl.TextColor3 = Color3.fromRGB(220, 235, 255)
		descLbl.Font = Enum.Font.GothamBold
		descLbl.TextScaled = true
		descLbl.Text = card.Desc
		descLbl.Parent = cardBtn

		cardBtn.MouseButton1Click:Connect(function()
			CardDraftRemote:FireServer(card.Id)
		end)
	end
end

-- Update UI Reactively on Attribute Changes
local function updateHUDLabels()
	local status = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.WAVE_STATUS) :: string?) or "READY"
	local baseHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.BASE_HP) :: number?) or 1000
	local maxBaseHp = (Workspace:GetAttribute(GameConfig.WORKSPACE_ATTRS.MAX_BASE_HP) :: number?) or 1000
	waveStatusLbl.Text = string.format("%s | BASE HP: %d/%d", status, baseHp, maxBaseHp)

	local dmg = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.DAMAGE_STAT) :: number?) or 50
	local rng = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.RANGE_STAT) :: number?) or 30
	local cd = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.COOLDOWN_STAT) :: number?) or 1.15
	local crit = ((localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_CHANCE) :: number?) or 0.08) * 100
	local critDmg = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.CRIT_DAMAGE) :: number?) or 2.0
	local placed = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.PLACED_TOWERS_COUNT) :: number?) or 0
	local maxPlaced = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.MAX_PLACED_TOWERS) :: number?) or 4
	statsSummaryLbl.Text = string.format(
		"DMG: %d | RNG: %d | CD: %.2fs | CRIT: %.0f%% (%.2fx) | TOWERS: %d/%d",
		dmg, rng, cd, crit, critDmg, placed, maxPlaced
	)

	local freeTickets = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.FREE_SUMMON_TICKETS) :: number?) or 0
	local rerollTokens = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.REROLL_TOKENS) :: number?) or 0
	btnSummon.Text = (freeTickets > 0) and string.format("🎲 SUMMON (FREE x%d)", freeTickets) or "🎲 SUMMON ($100)"
	btnReroll.Text = (rerollTokens > 0) and string.format("🔄 REROLL (Token x%d)", rerollTokens) or "🔄 REROLL ($80)"

	local lastHeroId = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.LAST_ROLLED_HERO_ID) :: string?) or ""
	if lastHeroId ~= "" then
		for _, h in ipairs(GameConfig.HERO_CATALOG) do
			if h.Id == lastHeroId then
				rolledHeroTitle.TextColor3 = h.PrimaryColor
				rolledHeroTitle.Text = string.format(
					"✨ สุ่มได้: %s ✨\n[%s] — %s\nตัวคูณดาเมจ: %.2fx | ขายได้: $%d",
					h.Name, h.Rarity, h.Subtitle, h.DamageMult, h.SellValue
				)
				break
			end
		end
	end

	local pendingDraws = (localPlayer:GetAttribute(GameConfig.PLAYER_ATTRS.PENDING_CARD_DRAWS) :: number?) or 0
	if pendingDraws > 0 and not draftModal.Visible then
		populateThreeRandomCards()
		draftModal.Visible = true
	elseif pendingDraws <= 0 then
		draftModal.Visible = false
	end

	refreshBagAndSlotsUI()
end

Workspace.AttributeChanged:Connect(updateHUDLabels)
localPlayer.AttributeChanged:Connect(updateHUDLabels)
local towersFolder = Workspace:WaitForChild("AnimeTowers")
towersFolder.ChildAdded:Connect(updateHUDLabels)
towersFolder.ChildRemoved:Connect(updateHUDLabels)

-- 5. Client Camera Shake & Anime Impact Flash Effect Listener
CameraShakeRemote.OnClientEvent:Connect(function(intensity: number, flashColor: Color3)
	local cam = Workspace.CurrentCamera
	if not cam then
		return
	end
	local flashFrame = Instance.new("Frame")
	flashFrame.Size = UDim2.fromScale(1, 1)
	flashFrame.BackgroundColor3 = flashColor or Color3.fromRGB(255, 40, 80)
	flashFrame.BackgroundTransparency = 0.72
	flashFrame.BorderSizePixel = 0
	flashFrame.Parent = screenGui
	TweenService:Create(flashFrame, TweenInfo.new(0.22), { BackgroundTransparency = 1 }):Play()
	task.delay(0.25, function()
		flashFrame:Destroy()
	end)

	local power = intensity or 0.4
	for _ = 1, 6 do
		local offset = Vector3.new(
			(math.random() - 0.5) * power,
			(math.random() - 0.5) * power,
			0
		)
		cam.CFrame = cam.CFrame * CFrame.new(offset)
		task.wait(0.03)
	end
end)

updateHUDLabels()
```

### ขั้นตอนที่ 7: รัน Rojo Sync และทดสอบระบบ Phase 3 (Master UAT Verification)
1. เปิด Terminal ในโฟลเดอร์รากของโปรเจกต์ ([default.project.json](https://www.google.com/search?q=https%3A%2F%2Fgithub.com%2FStangMKxD%2Fanime-limitless-td%2Fblob%2Fmain%2Fdefault.project.json)) แล้วรันคำสั่ง:
   ```bash
   rojo serve default.project.json
   ```
2. เปิด **Roblox Studio** กดเชื่อมต่อปลั๊กอิน Rojo (`Connect`) แล้วกดปุ่ม **Play (`F5`)** เพื่อตรวจสอบครบทั้ง 5 รายการ:
   - **เริ่มเกม 0 Tower + ปุ่มสุ่มกลางจอ**: เข้าเกมมาจะยังไม่มี Tower บนสนาม มีหน้าต่าง `GRAND LINE HERO SUMMON & REROLL` เด้งกลางจอพร้อมตั๋วสุ่มฟรี 1 ใบ
   - **สุ่มตัวละคร + Reroll**: กดปุ่ม `SUMMON` เพื่อสุ่มฮีโร่วันพีซ และกดปุ่ม `REROLL` เพื่อสุ่มเปลี่ยนตัวละครใหม่ด้วย Reroll Token หรือเงิน Cash
   - **เลือกวางตามจุด + วางทับตัวเดิม + เก็บเข้ากระเป๋า + ขาย**: คลิกเลือกตัวละครในกระเป๋าด้านล่าง แล้วคลิกแท่นวาง `Slot 1` ถึง `Slot 8` บนสนาม (หรือปุ่ม Slot ด้านล่าง) หากวางลงช่องที่มีตัวเดิมอยู่ ตัวเดิมจะเด้งกลับเข้ากระเป๋าอัตโนมัติ และสามารถกดปุ่ม **เก็บ** (เข้ากระเป๋า) หรือปุ่ม **ขาย** ได้ตลอดเวลา
   - **อนิเมชั่นตัวละคร + เอฟเฟกต์วันพีซสุดอลังการ**: ตัวละครมีอนิเมชั่นขยับหายใจ/ลอยตัวตลอดเวลา และเมื่อโจมตีจะปล่อยท่าไม้ตายประจำตัว (หมัดยักษ์ Bajrang Gun, คลื่นดาบ Kamusari, รอยร้าวอากาศหนวดขาว, ฝนเลเซอร์คิซารุ ฯลฯ) พร้อมป้ายเสียงมังงะ 3D และกล้องสั่น
   - **การ์ดอัปเกรดหลังผ่านเวฟ 12 รูปแบบ**: เมื่อเคลียร์เวฟ หน้าต่างเลือกการ์ดจะสุ่มการ์ด 3 ใบจากคลัง 12 ใบ เพิ่มค่าสถานะโดยรวมของทีม เงินรางวัล แต้ม Reroll และจำนวนช่องวาง Tower สูงสุด
