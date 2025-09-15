# 🤖 AI Content Generation Workflow Setup Guide

## ภาพรวม
Workflow นี้ใช้สำหรับสร้างเนื้อหาอัตโนมัติด้วย AI โดยมีขั้นตอนดังนี้:
1. รับคำขอผ่าน Webhook
2. ดึงข้อมูลจาก API ภายนอก
3. สร้างเนื้อหาด้วย OpenAI
4. บันทึกลงฐานข้อมูล MySQL
5. ส่งอีเมลแจ้งเตือน

## ข้อกำหนดเบื้องต้น

### 1. OpenAI API Key
- สมัครบัญชี OpenAI ที่ https://platform.openai.com/
- สร้าง API Key ใหม่
- เติมเครดิตในบัญชี (ขั้นต่ำ $5)

### 2. MySQL Database
```sql
-- สร้างฐานข้อมูลและตาราง
CREATE DATABASE ai_content_db;
USE ai_content_db;

CREATE TABLE ai_generated_content (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    content_type VARCHAR(50),
    target_audience VARCHAR(100),
    word_count INT,
    tokens_used INT,
    created_at DATETIME,
    INDEX idx_created_at (created_at),
    INDEX idx_content_type (content_type)
);
```

### 3. Email SMTP Settings
- Gmail, Outlook หรือ SMTP Server อื่นๆ
- App Password (สำหรับ Gmail)

## การตั้งค่าใน n8n

### ขั้นตอนที่ 1: Import Workflow
1. เข้าสู่ n8n Web Interface (http://localhost:5678)
2. คลิก "Import from file"
3. เลือกไฟล์ `ai-content-generation-workflow.json`
4. คลิก "Import"

### ขั้นตอนที่ 2: ตั้งค่า Credentials

#### OpenAI Credential
1. ไปที่ Settings > Credentials
2. คลิก "Create New"
3. เลือก "OpenAI API"
4. ใส่ API Key ของคุณ
5. บันทึกเป็น "OpenAI API"

#### MySQL Credential
1. สร้าง Credential ใหม่
2. เลือก "MySQL"
3. ใส่ข้อมูล:
   ```
   Host: localhost (หรือ IP ของ MySQL Server)
   Database: ai_content_db
   User: your_mysql_user
   Password: your_mysql_password
   Port: 3306
   ```
4. บันทึกเป็น "MySQL Database"

#### Email (SMTP) Credential
1. สร้าง Credential ใหม่
2. เลือก "SMTP"
3. ตั้งค่าสำหรับ Gmail:
   ```
   Host: smtp.gmail.com
   Port: 587
   Security: STARTTLS
   User: your-email@gmail.com
   Password: your-app-password
   ```
4. บันทึกเป็น "Email SMTP"

### ขั้นตอนที่ 3: กำหนด Credentials ให้ Nodes
1. คลิกที่ "OpenAI - Generate Content" node
2. เลือก Credential "OpenAI API"
3. คลิกที่ "MySQL - Save Content" node
4. เลือก Credential "MySQL Database"
5. คลิกที่ "Email - Send Notification" node
6. เลือก Credential "Email SMTP"

### ขั้นตอนที่ 4: ปรับแต่งการตั้งค่า
1. **Webhook URL**: คัดลอก URL จาก Webhook Trigger node
2. **Email Settings**: แก้ไขอีเมลผู้ส่งใน Email node
3. **MySQL Table**: ตรวจสอบชื่อตารางใน MySQL node

## การทดสอบ

### ทดสอบด้วย curl
```bash
curl -X POST "http://localhost:5678/webhook/generate-content" \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "การใช้ AI ในธุรกิจ",
    "content_type": "article",
    "audience": "นักธุรกิจ",
    "length": "medium",
    "email": "your-email@example.com",
    "api_url": "https://jsonplaceholder.typicode.com/posts/1"
  }'
```

### ทดสอบด้วย Postman
1. สร้าง POST Request
2. URL: `http://localhost:5678/webhook/generate-content`
3. Headers: `Content-Type: application/json`
4. Body (JSON):
```json
{
  "topic": "เทคโนโลยี AI ในอนาคต",
  "content_type": "blog",
  "audience": "นักเทคโนโลยี",
  "length": "long",
  "email": "admin@yourcompany.com",
  "api_url": "https://jsonplaceholder.typicode.com/posts/2"
}
```

## การใช้งาน

### พารามิเตอร์ที่รองรับ
- `topic` (required): หัวข้อเนื้อหาที่ต้องการสร้าง
- `content_type` (optional): ประเภทเนื้อหา (article, blog, social, email)
- `audience` (optional): กลุ่มเป้าหมาย
- `length` (optional): ความยาว (short, medium, long)
- `email` (optional): อีเมลสำหรับรับการแจ้งเตือน
- `api_url` (optional): URL สำหรับดึงข้อมูลเพิ่มเติม

### ตัวอย่างการใช้งาน

#### สร้างบทความ
```json
{
  "topic": "วิธีการลงทุนในหุ้น",
  "content_type": "article",
  "audience": "นักลงทุนมือใหม่",
  "length": "long",
  "email": "investor@example.com"
}
```

#### สร้างโพสต์โซเชียล
```json
{
  "topic": "เทรนด์เทคโนโลยี 2024",
  "content_type": "social",
  "audience": "วัยรุ่น",
  "length": "short",
  "email": "social@example.com"
}
```

## การปรับแต่ง

### ปรับแต่ง AI Prompt
แก้ไขใน "OpenAI - Generate Content" node:
```
สร้างเนื้อหา{{ $json.content_type }}เกี่ยวกับหัวข้อ: {{ $json.content_topic }}

[เพิ่มคำแนะนำเฉพาะของคุณ]
```

### เพิ่มฟิลด์ในฐานข้อมูล
1. เพิ่มคอลัมน์ใน MySQL:
```sql
ALTER TABLE ai_generated_content 
ADD COLUMN author VARCHAR(100),
ADD COLUMN status ENUM('draft', 'published') DEFAULT 'draft';
```

2. อัปเดต "Format Content Data" node
3. อัปเดต "MySQL - Save Content" node

### ปรับแต่งอีเมล Template
แก้ไข HTML template ใน "Email - Send Notification" node

## การแก้ไขปัญหา

### OpenAI API Error
- ตรวจสอบ API Key
- ตรวจสอบเครดิตในบัญชี
- ลดจำนวน max_tokens หากเกินขีดจำกัด

### MySQL Connection Error
- ตรวจสอบ Host และ Port
- ตรวจสอบ Username/Password
- ตรวจสอบว่าฐานข้อมูลและตารางมีอยู่

### Email Sending Error
- ตรวจสอบ SMTP settings
- ใช้ App Password สำหรับ Gmail
- ตรวจสอบ Firewall settings

### Webhook ไม่ทำงาน
- ตรวจสอบว่า Workflow เปิดใช้งานแล้ว
- ตรวจสอบ URL ที่ถูกต้อง
- ตรวจสอบ Content-Type header

## ความปลอดภัย

### การป้องกัน API Key
- ไม่แชร์ API Key
- ใช้ Environment Variables
- ตั้งค่า Rate Limiting

### การป้องกันฐานข้อมูล
- ใช้ User ที่มีสิทธิ์จำกัด
- เปิดใช้ SSL Connection
- สำรองข้อมูลสม่ำเสมอ

### การป้องกัน Webhook
- ใช้ Authentication
- ตั้งค่า IP Whitelist
- ใช้ HTTPS ใน Production

## การติดตาม

### Logs ที่ควรติดตาม
- OpenAI API usage และ cost
- MySQL query performance
- Email delivery status
- Webhook response time

### Metrics ที่สำคัญ
- จำนวนเนื้อหาที่สร้างต่อวัน
- ค่าใช้จ่าย OpenAI tokens
- อัตราความสำเร็จของ workflow
- เวลาประมวลผลเฉลี่ย

## การขยายระบบ

### เพิ่ม AI Models อื่นๆ
- Claude (Anthropic)
- Gemini (Google)
- Local LLM models

### เพิ่มช่องทางการแจ้งเตือน
- LINE Notify
- Slack
- Discord
- Microsoft Teams

### เพิ่มฐานข้อมูลอื่นๆ
- PostgreSQL
- MongoDB
- Firebase

---

**หมายเหตุ**: Workflow นี้ใช้ OpenAI API ซึ่งมีค่าใช้จ่าย กรุณาติดตามการใช้งานและค่าใช้จ่ายอย่างสม่ำเสมอ