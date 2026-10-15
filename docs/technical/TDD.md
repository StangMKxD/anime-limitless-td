# เอกสารการออกแบบทางเทคนิค (Technical Design Document - TDD)

## 1. สถาปัตยกรรมระดับระบบ (System Architecture)

```mermaid
flowchart TD
    subgraph DataModel ["Roblox DataModel Hierarchy"]
        RS["ReplicatedStorage.Shared\n(GameConfig.luau)"]
        SSS["ServerScriptService"]
        SPS["StarterPlayer.StarterPlayerScripts"]
        WS["Workspace"]
    end

    subgraph Track1 ["Track 1: Wave System"]
        WM["WaveManager.server.luau"]
        WP["Waypoints (Folder)"]
        AE["ActiveEnemies (Folder)"]
        CRYS["AnimeBaseCrystal (Part)"]
    end

    subgraph Track2 ["Track 2: Tower System"]
        TC["TowerController.server.luau"]
        AT["AnimeTowers (Folder - 6 Units)"]
        DM["TrainingDummy (Fallback)"]
    end

    subgraph Track3 ["Track 3: Upgrade & UI System"]
        US["UpgradeServer.server.luau"]
        UH["UpgradeHUD.client.luau"]
        RE["RemoteEvent: UpgradeStatRequest"]
    end

    SSS --> WM
    SSS --> TC
    SSS --> US
    SPS --> UH

    WM -->|"Create & Manage"| WP
    WM -->|"Spawn & Track"| AE
    WM -->|"Create & Monitor"| CRYS
    WM -->|"Set Attributes"| WS

    TC -->|"Scan Enemies"| AE
    TC -->|"Spawn Units"| AT
    TC -->|"Fallback Test"| DM

    UH -->|"FireServer"| RE
    RE -->|"Process & Deduct Cash"| US
    US -->|"Update Attributes"| Players

    TC -->|"Read Player Stats"| Players
    UH -->|"Listen Attributes"| WS
```

## 2. โมเดลการแยกหน้าที่และความรับผิดชอบ (Separation of Concerns)
- **Track 1**: รับผิดชอบวงรอบชีวิตของศัตรู, การเกิดเวฟ, การนับซอมบี้ที่เหลือ, เลือดฐาน และการมอบรางวัลเงินสด
- **Track 2**: รับผิดชอบการสแกนหาเป้าหมาย, การคำนวณระยะยิง, การปล่อยกระสุน/บีม, การสร้างดาเมจ และเอฟเฟกต์วิวัฒนาการ
- **Track 3**: รับผิดชอบการแลกเปลี่ยนเงินกับสเตตัส, การคำนวณราคาแบบทวีคูณ และการแสดงผล UI/HUD

## 3. ความปลอดภัยและประสิทธิภาพ (Safety & Performance)
- **No Physics Lag**: ซอมบี้และเอฟเฟกต์ยิงบีมใช้ `TweenService` หรือ `Anchored = true` เพื่อไม่สร้างภาระการคำนวณฟิสิกส์ให้ Roblox Physics Engine
- **Server Authority**: การหักเงินและการเพิ่มสเตตัสกระทำที่ฝั่ง Server ใน `UpgradeServer` เท่านั้น Client ไม่สามารถปลอมแปลงค่าสเตตัสได้
