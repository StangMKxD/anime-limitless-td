# PLAN-0004: การผสานรวม 3 Track และตรวจรับ Master UAT (Integration & UAT)

- **สถานะ**: Pending Dependencies (รอ PLAN-0001, PLAN-0002, PLAN-0003 เสร็จสมบูรณ์)
- **ขอบเขตงาน (Ownership)**: รวม Branch ทั้งหมดเข้า `main` และตรวจรับทั้งระบบ
- **Git Branch / Worktree**: `main` (`./`)
- **พอร์ต Rojo สำหรับทดสอบ**: `34872`
- **เอกสารอ้างอิง**: [`requirement/03_track3_infinite_upgrade_ui_and_integration_spec.md`](../../../requirement/03_track3_infinite_upgrade_ui_and_integration_spec.md) Section 3

## 1. ลำดับขั้นตอนการรวมงาน (Merge Sequence)
```bash
# รันที่ root โฟลเดอร์ anime-td-repo (บน branch main)
git merge feat/track1-wave --no-edit
git merge feat/track2-towers --no-edit
git merge feat/track3-ui --no-edit
```
เนื่องจากทั้ง 3 Track ถูกแบ่งโฟลเดอร์แยกขาดจากกันตั้งแต่ต้น การ merge จะเกิดแบบ **Fast-Forward / Clean Merge 100% ปราศจากความขัดแย้ง (Zero Conflict)**

## 2. ตาราง Master UAT (Acceptance Test Checklist)

| หมวดการตรวจรับ | ขั้นตอนการทดสอบ | ผลลัพธ์ที่คาดหวัง |
| :--- | :--- | :--- |
| **1. Auto-Bootstrap** | เปิด Roblox Studio กด Play | ถนน 6 จุดเลี้ยว, คริสตัลฐาน, และแท่นยูนิตอนิเมะ 6 ตัว เสกขึ้นมาใน Workspace ครบถ้วน |
| **2. Combat & Targeting** | รอซอมบี้เวฟ 1 เดินออกมา | หุ่นอนิเมะยิงลำแสงสีฟ้าใส่ซอมบี้ เลือดซอมบี้ลดและมีตัวเลขดาเมจ/หลอดเลือดลดลง |
| **3. Economy & Scaling** | รอให้ซอมบี้ตาย | ผู้เล่นได้รับ Cash เพิ่มขึ้น และเมื่อเวฟสูงขึ้น เลือดและความเร็วซอมบี้เพิ่มขึ้นตามสูตร |
| **4. Upgrade & Evolution** | กดซื้ออัปเกรดดาเมจจนเกิน 100 และ 400 | ออร่าของป้อมเปลี่ยนจากฟ้า -> ม่วง -> ทอง และเริ่มระเบิด AoE กระจายใส่ซอมบี้รอบข้าง |
| **5. Base Damage & GameOver**| ปล่อยให้ซอมบี้เดินชนคริสตัลฐาน | เลือดฐานลดลง หลอดเลือดที่ HUD ด้านบนหดสั้นลง และเมื่อเหลือ 0 แสดงข้อความ Game Over |
