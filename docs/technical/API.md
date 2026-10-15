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
