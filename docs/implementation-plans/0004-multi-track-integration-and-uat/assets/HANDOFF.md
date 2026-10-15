# ใบมอบหมายงาน (HANDOFF): PLAN-0004

- **เป้าหมาย**: Merge รวม 3 Worktrees เข้าด้วยกันและรัน Master UAT Checklist 5 หมวด
- **สภาพแวดล้อมที่ทำงาน**: โฟลเดอร์หลัก root `C:\Users\Stang\anime-limitless-td` (Branch: `main`)
- **พอร์ต Rojo**: `34872`
- **คำสั่ง Merge**:
  ```bash
  git merge feat/track1-wave --no-edit
  git merge feat/track2-towers --no-edit
  git merge feat/track3-ui --no-edit
  ```
