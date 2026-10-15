# กติกาและข้อตกลงในการพัฒนา (CONVENTIONS)

## 1. การแบ่งโฟลเดอร์และการใช้ Git Worktree
โครงการนี้รองรับการพัฒนาแบบคู่ขนาน 3 Worktrees แยกโฟลเดอร์รัน 100% ป้องกัน Merge Conflict:

| Track | Git Branch | โฟลเดอร์ Worktree | โฟลเดอร์โค้ดที่รับผิดชอบ | พอร์ต Rojo |
| :--- | :--- | :--- | :--- | :---: |
| **Track 1** | `feat/track1-wave` | `../wt-track1-wave` | `src/Track1_WaveSystem/` | `34871` |
| **Track 2** | `feat/track2-towers` | `../wt-track2-towers` | `src/Track2_TowerSystem/` | `34872` |
| **Track 3** | `feat/track3-ui` | `../wt-track3-ui` | `src/Track3_UISystem/`, `src/Track3_UpgradeServer/` | `34873` |
| **Base / Integration** | `main` | `./` (repo root) | `src/Shared/`, `default.project.json` | `34872` |

## 2. กฎการเขียนโค้ด (Coding Standards)
- **Luau Type Checking**: เขียนโค้ดด้วยภาษา Luau และกำหนด Type ให้ชัดเจนเมื่อเป็นไปได้
- **Roblox Services**: เรียก Service ผ่าน `game:GetService("ServiceName")` เสมอ
- **No Direct Cross-Track Requires**: ห้ามใช้ `require` ข้าม Track เช่น ใน Track 2 ห้ามเรียกโค้ดใน Track 1 หรือ 3
- **Attribute Access**: อ่านและเขียน Attributes ผ่าน Constant Key ใน `GameConfig.WORKSPACE_ATTRS` และ `GameConfig.PLAYER_ATTRS` เสมอ เพื่อป้องกัน Typo
- **Tween & Physics Safety**: การเคลื่อนที่ของซอมบี้และกระสุนบีมให้ใช้ `TweenService` หรือ `PivotTo` แบบ Anchored เพื่อไม่ให้หลุดฟิสิกส์หล่นทะลุแมพ

## 3. เกณฑ์การรีวิวและการปิดงาน (Review & Gate Rules)
- การทดสอบแต่ละ Track ต้องผ่านเกณฑ์ Standalone Testability ในพอร์ตของตนเอง
- เมื่อรวมงานเข้าสู่ `main` ต้องผ่าน Master UAT Checklist 5 หมวด (Bootstrapping, Combat, Scaling, Upgrade UI, GameOver)
