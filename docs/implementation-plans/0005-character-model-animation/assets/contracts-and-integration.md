# Phase 5 — Contract และ integration proposals

สถานะ: ENGINEERING DESIGN TO LOCK BY AGY ภายใต้ implementation scope ที่ผู้ใช้อนุญาตแล้ว; อ่าน HANDOFF ล่าสุดสำหรับ D-01..D-07 และการ sync canonical API ตามขอบเขต Codex อนุญาต ห้ามเพิ่ม spec หรือรายงาน technical decision ทุกข้อว่า Owner อนุมัติแล้วโดยปริยาย

## 1. หลักการและขอบเขตความเชื่อถือ

- Gameplay IDs ยังคง Tower_Luffy_G5 / Tower_Zoro_KingOfHell / Tower_Ace_Entei; asset/module IDs คือ Luffy/Zoro/Ace และ <Id>VFX; alias table เป็น config ของ Registry ไม่ใช่เปลี่ยน GameConfig
- profile และ cue เป็นข้อมูล visual ไม่มี damage callback หรือสิทธิ์แก้ Workspace.Enemies.HP; model context ไม่เก็บ owner/player balance ให้ character module ใช้
- require เฉพาะ Shared contract กับโมดูลใน Track2 เดียวกัน; VisualBridge ไม่ require Track2; โหมด Lab ต้องผ่าน seam ที่อนุมัติและไม่มี client เข้าถึง ServerScriptService
- runtime API ด้านล่างใช้ชื่ออ้างอิง Master Pack เป็นชื่อเสนอ หากต้องเปลี่ยนชื่อ/ชนิดให้ Core ปรับ draft และให้ Codex ตรวจ ก่อน character streams อิง version เดียวกัน

## 2. AnimationContract ที่ต้องล็อก

| ส่วน | ฟิลด์/ความหมายที่เสนอ | validation / compatibility |
|---|---|---|
| Identity | contractVersion, gameplayHeroId, assetId, profileId | gameplay ID -> asset alias แบบ explicit; unknown ID ได้ fallback + reason ไม่เปลี่ยน catalog |
| State | Idle, SpecialIdle, Spawn, Windup, Attack, Impact, Recovery, Ultimate | require Idle/Windup/Attack/Impact/Recovery; optional state ที่ไม่มีให้ UI disable พร้อม reason |
| Joints | RootJoint, Neck, RightShoulder, LeftShoulder, RightHip, LeftHip; Zoro เพิ่ม WeaponRight/WeaponLeft/WeaponMouth | validate Part0/Part1, distinct parts, hierarchy, missing/duplicate mapping; ไม่ใช้ชื่อ NeckJoint/RightWrist legacy สลับเอง |
| Rig mapping | semantic limb -> explicit group/pivot/geometry descendants + accessory parent | actual asset ใช้ UpperArm/Forearm/Fist และ _2; ต้องระบุซ้าย/ขวาจาก geometry; ห้าม joint หนึ่งตัวชี้ last matching weapon segment |
| Rest data | per-model original C0/C1, part Size/สี/scale-related offsets และ attachments ที่แก้ | snapshot ก่อน animation/sanitize ที่เปลี่ยน pose; rebuild ต้องไม่จับ pose กลางท่าเป็น rest ใหม่ |
| Keyframe | alpha, easingStyle, easingDirection, poses, optional cue, optional scale target | alpha finite 0..1 เรียงและมีกฎ duplicate timestamp; duration >0; enum จริง Exponential; ไม่ใช้ export typeAttackCycleTimings typo |
| Pose map | jointName -> local rest offset | ละ joint หมายถึง rest หรือ hold ต้องเลือกหนึ่งให้ชัด; ข้อเสนอ rest เพื่อ seek deterministic |
| Scale target | limb/group identifier + relative scale และ origin/pivot policy | scaleMultiplier เฉยๆ ในต้นทางไม่บอก scale ที่ส่วนใด; ต้องล็อก Luffy arm axis/หลาย subparts/attachment correction/reset |
| Timing | visual state durations/attackCycleTimings | ratios รวม 1 หากใช้; ไม่ใช้ visual ratios เปลี่ยนเวลา damage 0.31s; แยก visual timeline กับ gameplay clock |
| Cancellation | canCancel สำหรับ transition ปกติ + hard cleanup token | Destroy/sell/Stop/Reset ชนะ canCancel=false เสมอ; pending visual stale token ห้ามแก้ rig ใหม่ |
| Capability | fallback/signature availability + validation report | module require สำเร็จอย่างเดียวไม่ใช่ runtime/visual verified |

### Lifecycle API ที่เสนอภายใน Track2

| Operation | Input -> Output | failure / idempotency |
|---|---|---|
| Registry.GetAnimationProfile | gameplay ID -> profile, isSignature, reason | unknown/missing/invalid module เป็น fallback; warn มี reason; cached data ไม่ถือ per-model state |
| Registry.GetVFXModule | gameplay ID -> VFX module, isSignature, reason | fallback โหลดได้แม้ character module ยังไม่อยู่; ห้าม WaitForChild character แบบไม่จบ |
| AnimationController.SanitizeAndRigModel | model + profile -> RigContext หรือ structured failure | เรียกซ้ำไม่เพิ่ม joint/geometry; validate existing Motor6D endpoints ก่อน reuse; staged clone ไม่แตะ template |
| EvaluatePoseAtTime | profile + state + t -> rest-relative pose/scale values | ไม่มี side effect; t clamp/loop กำหนด; negative/NaN ปฏิเสธ; reverse seek ไม่ replay cue |
| PlayAttackSequence / PlayState | context + state/target/visual duration -> visual token | ไม่มี damage callback; error ส่งกลับ/บันทึกและ combat ยังเดิน |
| Pause / Seek / Stop / ResetPose | context + command -> current visual state | Stop/Reset คืน geometry+attachments และเลิก resources; repeated cleanup เป็น no-op ที่ปลอดภัย |
| DestroyContext | model/context -> cleanup report | invalidate token/disconnect/cancel/destroy/clear cache refs; เรียกซ้ำไม่ลด counter ซ้ำ |

ค่า return/error shape ต้องล็อกก่อน implementation เช่น MISSING_ROOT, MISSING_LIMB, AMBIGUOUS_MAPPING, INVALID_PROFILE, RIG_CONFLICT, DESTROYED_CONTEXT; แยก fallback ที่ยอมรับได้จาก unsupported และ error ห้าม swallow pcall failure แล้วแสดง ready

## 3. Rig ownership / VisualBridge — D-01

คำแนะนำ: Track2 claim สิทธิ์ model ก่อน parent เข้า AnimeTowers; Core กำหนด attribute keys ใน AnimationContract ให้ bridge อ่าน เช่น owner/rigReady/visualSource/version โดยชื่อ keys ยังเป็นข้อเสนอ ไม่ hardcode ต่างไฟล์

1. Track2 clone template off-tree, strip unsafe scripts ตาม baseline policy, resolve aliases, validate rig map และจัด visual/rig รายเดียว
2. ระบุ claim ก่อน publish model; bridge เห็น claim แล้วไม่ clone AssetKitVisuals ซ้อนหรือ hide rig geometry
3. ก่อน claim สำเร็จ การเลี่ยง bridge ต้องมี fallback policy ชัดเจน; ถ้า build ล้มเหลวคืน model ที่ใช้ได้หรือใช้ legacy branch ไม่ทำ model หาย/blank
4. bridge-first / Track2-first / existing children / delayed ChildAdded / rebind model เดิม ต้อง converge เป็น visual เดียวและ joint graph เดียว ไม่เชื่อว่า execution order แน่นอน
5. Legacy heroes / enemies / map assets คง route เดิม ไม่เปลี่ยน Enemy root anchoring ที่ WaveManager ใช้อยู่
6. ลบเฉพาะ rigid edges ที่ทำให้ assembly ข้าม joint; weld ของ decorative parts ที่อยู่ limb เดียวกันยังจำเป็น ต้องตรวจ rigid-connected components ทั้ง Part0/Part1 ไม่ดูชื่อหรือ Part1 ฝั่งเดียว

ทางเลือกจากต้นทางที่ให้ VisualBridge เรียก AnimationController.SanitizeAndRigModel ตรงๆ ถูกกั้นเพราะ AGENTS R03; หาก Owner ต้องการอนุญาตต้องแก้ architecture rule โดยชัดแจ้งก่อน ไม่ตีความว่าแผนนี้ยกเว้นกฎให้แล้ว

## 4. VFXContract / resource ownership

| ส่วน | ข้อเสนอ |
|---|---|
| Common cues | PassiveAura, SpawnDeploy, AttackWindup, AttackRelease, AttackImpact, UltimateCast, UltimateImpact |
| Character cues | NikaLaughPuff, EnmaChargePulse, FlameShoulderFlare ต้องกำหนดเป็น extension cue + registered handler ไม่ปล่อย typo string เงียบ |
| Context | hero/asset ID, cue, source model/root, origin CFrame, targetPosition, optional targetModel, intensity, quality, layers, session/model cleanup owner |
| Quality | Low / Medium / High; rate/part/light/screen caps ตาม table ที่อนุมัติ; Low ลดภาพได้แต่ damage ไม่เปลี่ยน |
| Layers | particles, aura, trail/beam, impact, camera shake, screen flash; ทุก cue ต้องเคารพ flags รวม passive aura |
| Instance tracking | registerInstance(instance, optional TTL) มี owner/scope, register ครั้งเดียว, Destroying/cleanup ลดครั้งเดียว; Debris เป็น fallback ไม่ใช่ sole ownership |
| Tween tracking | registerTween + explicit Play/complete/cancel state; Cancel และ Completed ถูกส่งซ้ำไม่ double-decrement |
| Other resources | ต้องมี owner registration สำหรับ connections/tasks/emitters/trails/temporary materials หรือ cleanup callbacks ด้วย; contract ต้นทางมีแค่ instance/tween จึงยังไม่ครบ |
| Character API | startPassiveAura, stopPassiveAura, triggerCue, cleanupAllForModel; repeated start ไม่เพิ่ม aura ซ้ำ; cleanup idempotent |
| Caps | per-model และ per-session/global รวม passive/burst/ultimate; drop/degrade visual เมื่อเต็ม ไม่ block combat; นับ BasePart กับ Instance แยก |

ค่าเริ่มต้นต้นทาง Low/Medium/High maxParts=8/16/30 และ character maxConcurrent=25 ขัดกันบางกรณี ต้องกำหนด precedence ของ per-cue/per-model/global ใน P5-04 ก่อนตั้ง acceptance; ไม่มีค่าที่อนุมัติแล้วในร่างนี้

## 5. Combat seam ที่ต้องรักษา — D-03

Baseline source: ทุก 0.08s ตรวจ now-lastAttack >= max(0.15, baseCd*spec.CooldownMult); ณ launch capture player stats/impactPos; หลัง nominal 0.31s เรียก callback, ใช้ RNG คำนวณ crit และ query enemies ปัจจุบันรอบ impactPos เดิม; armor clamp และ Whitebeard slow คงตาม baseline

- combat timer/sequence ID อยู่ TowerController; visual เป็น fire-and-forget ไม่เรียก ApplyDamage และไม่วาง gameplay callback ไว้ใน Tween.Completed/keyframe cue
- สร้าง pending hit ไม่เกินหนึ่ง record ต่อ attack ID; การยิง VFX ซ้ำ, seek, toggle quality, visual error ไม่สร้างหรือใช้ RNG ของ combat เพิ่ม
- ไม่ serialize ทุก attack จน cadence ช้าลงเมื่อ cooldown < 0.31s; pending overlapping hits ต้องมี identity แยกตาม baseline
- Tower ถูก sell/recall/destroy ก่อน impact ต้องยกเลิกตามเงื่อนไข tower.Parent/root.Parent เดิม; visual cancel อย่างเดียวไม่ยกเลิก gameplay
- target เคลื่อน/ตายก่อน hit ให้ตรวจ semantics เดิม: impact position ถูก capture แต่รายชื่อ enemies query สด ไม่เปลี่ยนเป็น homing โดยไม่อนุมัติ
- การถอด visual root movement อาจเปลี่ยนระยะยิง/ตำแหน่งรอบถัดไป ต้องทำ trace แยก; ขยับ body ผ่าน RootJoint ขณะ root คงที่เป็นข้อเสนอ P5-R02 ไม่ให้แอบเปลี่ยน targeting origin
- actual callback source มี VFX ก่อน damage; error ใน VFX ปัจจุบันอาจขัด damage เป็น risk ที่ Phase5 ต้องแก้โดยแยก visual protection พร้อม test ไม่อ้างว่า error case baseline ใช้งานได้อยู่แล้ว

## 6. Lab boundary / Rojo / controlled integration — D-02, D-06

- Client entrypoint ใหม่ใต้ src/DevTools/AnimationLab/ ดูแล UI/input/CurrentCamera/RenderStepped/local PostFX; server entrypoint อยู่ server-executing service ตาม Rojo mapping ที่อนุมัติ
- Local UI ไม่ require Track2 ใน ServerScriptService; ห้ามย้าย animation ทั้งเกมไป ReplicatedStorage/client เพียงเพื่อทำ Lab เพราะถูก deferred
- ข้อเสนอที่ยังไม่อนุมัติ: Studio-only shared command contract ให้ server owner ของ Track2 ประมวลผล runtime operations ภายใน Track2 โดยไม่ require DevTools ข้าม Track; Lab UI ส่งคำสั่งจำกัดและรับ snapshot/reply เท่านั้น
- ต้องกำหนดรายการ command เช่น inspect/select/play/pause/seek/reset/triggerVFX/stress/close, payload, correlation/session IDs, reply/error, schema limit และ owner ใน API ก่อนเพิ่ม remotes; ไม่เปิด arbitrary instance path/require/asset loading/code execution
- server ใช้ IsStudio, player/session checks, allowlists, numeric finite bounds และ bounded request rate; ทุก command ปฏิเสธหาก session ปิด/ไม่เป็นเจ้าของ
- default Visual Sandbox ไม่มี combat call; Controlled Integration ใช้ actual combat seam ใน Track2 กับ dummy/session แยก โดยไม่ใส่ Enemies และไม่ผูก WaveManager reward callback
- dummy attribute ต้นทางมี IsLabDummy / IsAnimationLabDummy สองชื่อ ต้องเลือกชื่อเดียวใน Shared contractก่อน; attribute อย่างเดียวไม่พอ ถ้า reward listener ถูกผูกแล้ว
- ถ้าต้องแก้ Track1 ให้หยุด BLOCKED_SCOPE; การอนุมัติแผนทั่วไปไม่เท่ากับอนุมัติแก้ Track1
- พื้นที่ Y=5000 เป็นตัวอย่าง ต้องตรวจ streaming/visibility/floating origin และไม่ใช้ distance เป็นหลักประกันแยก state; camera/Lighting ไม่กระทบคนอื่น

## 7. วิธีพิสูจน์ contract และข้อจำกัดหลักฐาน

1. Node suite ตรวจ pure logic/static contracts ที่รองรับจริง; ไม่ให้ JS จำลอง pose ใช้แทนผล Motor6D ของ engine
2. Studio runtime ตรวจ actual world CFrame ของ visible limbs/weapons/attachments หลัง engine steps + root transform, repeated build, cancel/destroy และ no orphan joints/resources
3. Character specs ใน Master Pack อ้าง TestEZ-style globals แต่ repo ยังไม่มี harness ที่ยืนยัน; D-05 ต้องเลือกวิธีรัน/require/service mapping/test isolation รวม failure exit/report ก่อนนับว่า automated
4. ModelValidator ต้องตรวจ missing joints/invalid endpoints/anchored limbs และ indirect rigid path ทั้งสองทิศ; map asset STATIC/N/A; แยก TEMPLATE_ONLY/FALLBACK/SIGNATURE_MODULE_READY/RUNTIME_VERIFIED/VISUAL_NOT_VERIFIED ตามหลักฐาน ไม่ใช้ loaded table => SIGNATURE_READY
5. G-06 เปรียบเทียบ attack IDs, nominal hit times, HP delta, seed/RNG draw count, splash/armor/slow และ cancelled pending hits ระหว่าง VFX off/on/error; ค่า tolerance ต้องระบุใน baseline trace
6. Lab telemetry เป็นข้อมูล scoped/tracked subset; resource ledger อาจไม่เห็น resource ที่ bypass wrapper ต้องคู่ subtree scan และ static ownership review

## 8. แหล่งข้อมูล

- [Master Pack](../../../../requirement/phase5/phase_5_master_plan_and_agent_pack.md) §§2.3,2.4,3.4, Part6: ที่มาสัญญาและ blueprint ที่ต้องแก้ก่อนลงมือ
- [Roblox Data model](https://create.roblox.com/docs/projects/data-model), [Script locations](https://create.roblox.com/docs/scripting/locations), [Reuse code](https://create.roblox.com/docs/scripting/module): service/client/server/module boundaries (ตรวจ 2026-10-17 ตามเวลาไทย)
- [Viewport frames](https://create.roblox.com/docs/ui/viewport-frames): properties ของแสง preview; VFX capability ยังคงต้องตรวจใน Studio
