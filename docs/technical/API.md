# สัญญาข้อมูลและอินเทอร์เฟซระบบ (API & Data Contracts)

## 1. ข้อมูลกลาง (Shared Configuration)
อ้างอิงจาก [`src/Shared/GameConfig.luau`](../../src/Shared/GameConfig.luau)

### Workspace Attributes
| Attribute Name | Type | Description | Owner | Listeners |
| :--- | :--- | :--- | :--- | :--- |
| `CurrentWave` | number | หมายเลขเวฟปัจจุบัน (เริ่มที่ 1) | Track 1 | Track 3 HUD |
| `BaseHP` | number | เลือดคงเหลือของฐานทัพ | Track 1 | Track 3 HUD |
| `MaxBaseHP` | number | เลือดสูงสุดของฐานทัพ (1,000) | Track 1 | Track 3 HUD |
| `ZombiesRemaining` | number | จำนวนซอมบี้ที่ยังคงมีชีวิตอยู่ในเวฟ | Track 1 | Track 3 HUD |
| `GameOver` | boolean | สถานะจบเกมเมื่อเลือดฐาน <= 0 | Track 1 | All tracks |

### Player Attributes
| Attribute Name | Type | Default Value | Description | Modifier | Listeners |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `DamageStat` | number | 35 | พลังโจมตีรวมของผู้เล่น | Track 3 Server | Track 2 Towers, Track 3 UI |
| `RangeStat` | number | 32 | ระยะยิงรวมของผู้เล่น (Studs) | Track 3 Server | Track 2 Towers, Track 3 UI |
| `CooldownStat` | number | 1.0 | คูลดาวน์เวลาโจมตี (วินาที) | Track 3 Server | Track 2 Towers, Track 3 UI |
| `DamageLevel` | number | 1 | เลเวลอัปเกรดดาเมจ | Track 3 Server | Track 3 UI |
| `RangeLevel` | number | 1 | เลเวลอัปเกรดระยะยิง | Track 3 Server | Track 3 UI |
| `SpeedLevel` | number | 1 | เลเวลอัปเกรดความเร็ว | Track 3 Server | Track 3 UI |

### Player leaderstats
| Stat Name | Type | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `Cash` | IntValue | 300 | เงินสดสำหรับใช้อัปเกรดในเกม |

## 2. เครือข่ายการสื่อสาร (Network Remotes)

### RemoteEvent: `UpgradeStatRequest`
- **Location**: `ReplicatedStorage.UpgradeStatRequest`
- **Direction**: Client $\rightarrow$ Server
- **Payload**:
  ```luau
  statType: string -- "Damage" | "Range" | "Speed"
  ```
- **Response**: Server อัปเดต Player Attributes และหัก `leaderstats.Cash` โดยตรง (Client ดักฟังผ่าน `AttributeChanged` event)

## 3. สัญญาแอนิเมชันส่วนกลาง (Shared Animation Contract)
อ้างอิงจาก [`src/Shared/AnimationContract.luau`](../../src/Shared/AnimationContract.luau)

### ชนิดข้อมูลหลัก (Strict Luau Types)
```luau
export type AnimationState = 
    | "Idle"
    | "SpecialIdle"
    | "Spawn"
    | "Windup"
    | "Attack"
    | "Impact"
    | "Recovery"
    | "Ultimate"

export type SemanticJoint =
    | "RootJoint"
    | "Neck"
    | "RightShoulder"
    | "LeftShoulder"
    | "RightHip"
    | "LeftHip"
    | "WeaponRight"
    | "WeaponLeft"
    | "WeaponMouth"

export type RestPoseSnapshot = {
    BaseC0: { [string]: CFrame },
    BaseC1: { [string]: CFrame },
    BaseSize: { [string]: Vector3 },
    BaseAttachmentCFrames: { [string]: CFrame },
}

export type KeyframeTrack = {
    Alpha: number, -- Finite [0.0 .. 1.0]
    EasingStyle: Enum.EasingStyle,
    EasingDirection: Enum.EasingDirection,
    Poses: { [SemanticJoint]: CFrame },
    ScaleTargets: { [string]: Vector3 }?,
    Cue: string?,
}

export type AnimationProfile = {
    ContractVersion: string, -- e.g. "5.0.0"
    HeroId: string,
    AssetAlias: string,
    States: { [AnimationState]: { Keyframes: { KeyframeTrack }, TotalDuration: number, Loop: boolean } },
}
```

### แอตทริบิวต์ควบคุมความเป็นเจ้าของริก (Rig Ownership Attributes)
| Attribute Name | Type | Target | Description | Set By | Read By |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Track2RigOwned` | boolean | Tower Model | บ่งชี้ว่า Track2 เป็นผู้สร้างและถือครอง Rig เพียงผู้เดียว | `TowerController` | `VisualBridge` |
| `RigReady` | boolean | Tower Model | บ่งชี้ว่ากระบวนการประกอบ Motor6D และ RestPose สำเร็จ | `AnimationController` | DevTools, TowerController |
| `VisualSource` | string | Tower Model | ระบุแหล่งที่มาของโมเดล (เช่น "Signature", "Fallback") | `AnimationController` | DevTools ModelValidator |

### รหัสข้อผิดพลาดมาตรฐาน (Standard Error Codes)
- `MISSING_ROOT`: โมเดลไม่มี `PrimaryPart` หรือ `HumanoidRootPart`
- `MISSING_LIMB`: ไม่พบชิ้นส่วนอวัยวะสำคัญที่ต้องใช้ในการต่อข้อต่อ
- `AMBIGUOUS_MAPPING`: พบชิ้นส่วนชื่อซ้ำซ้อนที่ไม่สามารถระบุความสัมพันธ์ซ้าย/ขวาได้
- `INVALID_PROFILE`: ข้อมูล AnimationProfile ไม่ผ่านการตรวจสอบ Schema (เช่น Alpha ไม่เรียงลำดับ หรือ Duration <= 0)
- `RIG_CONFLICT`: พบ `WeldConstraint` ที่ล็อกทับข้อต่อ `Motor6D`
- `DESTROYED_CONTEXT`: พยายามสั่งงานบน Context ของโมเดลที่ถูกลบออกจากเกมแล้ว

---

## 4. สัญญาเอฟเฟกต์ภาพและบัญชีทรัพยากร (Shared VFX Contract)
อ้างอิงจาก [`src/Shared/VFXContract.luau`](../../src/Shared/VFXContract.luau)

### ชนิดข้อมูลและสัญญาณภาพ (Strict Luau Types & Cues)
```luau
export type VFXCue =
    | "PassiveAura"
    | "SpawnDeploy"
    | "SpecialIdleCue"
    | "AttackWindup"
    | "AttackRelease"
    | "AttackImpact"
    | "UltimateCast"
    | "UltimateImpact"

export type QualityPreset = "Low" | "Medium" | "High"

export type LayerFlags = {
    EnableParticles: boolean,
    EnableAura: boolean,
    EnableTrailOrBeam: boolean,
    EnableImpactEffect: boolean,
    EnableCameraShake: boolean,
    EnableScreenFlash: boolean,
}

export type VFXContext = {
    Model: Model,
    RootPart: BasePart,
    OriginCFrame: CFrame,
    TargetPosition: Vector3,
    Intensity: number, -- Clamped [0.1 .. 2.0], Default 1.0
    Quality: QualityPreset,
    Layers: LayerFlags,
    OwnerLedger: any,
}
```

### เพดานงบประมาณตามระดับคุณภาพ (Quality Preset Budgets)
| Preset | Particle Rate Mult | Max Concurrent VFX Parts | PointLight Support | Screen Flash |
| :--- | :---: | :---: | :---: | :---: |
| `Low` | `0.35` | `8` | Disabled | Disabled |
| `Medium` | `0.70` | `16` | Enabled (Medium Brightness) | Enabled (Short) |
| `High` | `1.00` | `30` | Enabled (Full Brightness) | Enabled (Full) |

### อินเทอร์เฟซระบบบัญชีทรัพยากร (Resource Ledger Interface)
- `registerInstance(instance: Instance, ttl: number?): Instance` — ลงทะเบียนวัตถุพร้อมกำหนดเวลาหมดอายุ (TTL) อัตโนมัติ
- `registerTween(tween: Tween): Tween` — ลงทะเบียน Tween แอนิเมชันเพื่อสามารถหยุดหรือยกเลิกได้ทันที
- `registerTask(taskThread: thread): thread` — ลงทะเบียน Task เพื่อยกเลิกเมื่อโมเดลถูกทำลาย
- `registerConnection(conn: RBXScriptConnection): RBXScriptConnection` — ลงทะเบียน Connection เพื่อตัดการเชื่อมต่ออัตโนมัติ
- `cleanupAllForModel(model: Model): ()` — กวาดล้างทรัพยากรทั้งหมดที่ผูกกับโมเดลแบบ 100% Idempotent

---

## 5. สัญญาคำสั่งห้องทดลองในสตูดิโอ (Studio Animation Lab Command Contract)
อ้างอิงจาก [`src/DevTools/AnimationLab/`](../../src/DevTools/AnimationLab/)

### Remote Events & Functions (Studio Only)
- **Location**: `ReplicatedStorage.DevTools.AnimationLab.Remotes` (สร้างเฉพาะใน Studio)
- **Security Check**: ทุกคำสั่งตรวจสอบ `RunService:IsStudio() == true`
- **Supported Commands**:
  - `SelectModel(assetId: string)`: สลับโมเดลที่แสดงบน Sandbox Stage
  - `PlayAnimation(state: AnimationState, speed: number, loop: boolean)`: สั่งเล่นท่าแอนิเมชัน
  - `PauseAnimation()`: หยุดการเล่นชั่วคราว
  - `SeekAnimation(state: AnimationState, alpha: number)`: ข้ามไปยังตำแหน่งเวลาที่กำหนด
  - `ResetPose()`: คืนค่า Rest Pose ของโมเดลทันที
  - `TriggerVFX(cue: VFXCue, quality: QualityPreset, layers: LayerFlags)`: สั่งยิงเอฟเฟกต์ภาพ
  - `RunStressTest(characterCount: number)`: สั่งทดสอบความเค้น (1, 10, 25, 50 ตัวละคร)
  - `CleanupSandbox()`: สั่งล้างข้อมูลและวัตถุทั้งหมดบน Sandbox Stage
