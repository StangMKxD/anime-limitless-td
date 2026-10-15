# กติกาโครงการ Anime Limitless Tower Defense (Roblox)

โปรเจกต์นี้ใช้สถาปัตยกรรม Modular Zero-Conflict Architecture (Rojo + Git Worktree + Data Contract) แบ่งการทำงานออกเป็น 3 Tracks อิสระ:
1. **Track 1**: Core Wave & Infinite Scaling Enemy System (`src/Track1_WaveSystem/`)
2. **Track 2**: Anime Hero Towers & Combat System (`src/Track2_TowerSystem/`)
3. **Track 3**: Infinite Upgrade UI & Server (`src/Track3_UpgradeServer/`, `src/Track3_UISystem/`)

## การแบ่งหน้าที่ (Separation of Duties - SoD & MEM-BP-0004)
- **Controller & Independent Reviewer**: OpenAI Codex CLI (`stang-solar-system`, `stang-comet`, `stang-luna`)
- **Implementer**: Google Antigravity (`agy teamwork-preview` / `stang-darkmatter`)
- **กติกาอนุมัติ**: การเขียน PRD, TDD, CONTEXT ต้องขออนุมัติจาก Codex (Controller) ก่อน Implementer ไม่มีสิทธิ์ปิดงานเอง ต้องรอเจ้าของงานหรือ Reviewer ตรวจรับและปิดงาน

## กฎเหล็กของโปรเจกต์ (Zero-Conflict & Canonical Rules R01–R08)
1. **R01 (Truth & Evidence)**: ไม่ประดิษฐ์ผลลัพธ์หรือสร้างผลการทดสอบเท็จ ทุกผลการทำงานต้องอ้างอิงจากหลักฐานจริง
2. **R02 (SoD & Teamwork)**: ปฏิบัติตามขอบเขตงานอย่างเคร่งครัด แต่ละ Track แก้ไขเฉพาะไฟล์ในโฟลเดอร์ของตนเอง
3. **R03 (Architecture & Deep Modules)**: การสื่อสารระหว่างระบบต้องผ่าน Data Contract กลาง (`src/Shared/GameConfig.luau`), Player Attributes และ Workspace Attributes ห้าม `require` ข้าม Track โดยตรง
4. **R04 (Clean Code & Change Safety)**: ห้ามลบ comment/docstring ที่ไม่เกี่ยวข้อง รักษาความสะอาดของโค้ด
5. **R05 (TDD & Fast Verification)**: ทุก Track ต้องมี Standalone Fallback / Auto-Bootstrap ที่สามารถรันเทสเดี่ยวได้โดยไม่ต้องพึ่งพา Track อื่น
