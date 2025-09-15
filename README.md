# n8n Basic Setup with Docker

โปรเจคนี้เป็นการตั้งค่า n8n (workflow automation platform) ด้วย Docker สำหรับการเริ่มต้นใช้งาน

## 📋 สิ่งที่ต้องมี

- Docker และ Docker Compose
- Port 5678 ว่าง (สำหรับ n8n web interface)
- Port 11434 ว่าง (สำหรับ Ollama API)
- RAM อย่างน้อย 8GB (สำหรับ Ollama AI models)

## 🚀 การติดตั้งและเริ่มใช้งาน

### 1. Clone หรือ Download โปรเจค

```bash
git clone https://github.com/ninetea1688/basic-n8n.git
cd n8n-basic
```

### 2. ตั้งค่า Environment Variables

แก้ไขไฟล์ `.env` และเปลี่ยนรหัสผ่านเริ่มต้น:

```bash
cp .env .env.local
# แก้ไข N8N_BASIC_AUTH_PASSWORD ในไฟล์ .env.local
```

### 3. เริ่มต้น n8n

```bash
# เริ่มต้น n8n
docker-compose up -d

# ดู logs
docker-compose logs -f n8n

# หยุดการทำงาน
docker-compose down
```

### 4. เข้าใช้งาน n8n

เปิดเบราว์เซอร์และไปที่: http://localhost:5678

- **Username**: admin (หรือตามที่ตั้งค่าใน .env)
- **Password**: your_secure_password_here (หรือตามที่ตั้งค่าใน .env)

## 📁 โครงสร้างโปรเจค

```
n8n-basic/
├── docker-compose.yml      # Docker Compose configuration (รวม Ollama)
├── .env                     # Environment variables template
├── workflows/              # ตัวอย่าง workflow files
│   ├── hello-world-workflow.json
│   ├── webhook-example-workflow.json
│   ├── google-sheets-line-notification.json
│   ├── google-sheets-line-messaging-api.json
│   ├── google-sheets-telegram-bot.json
│   ├── ai-content-generation-workflow.json
│   ├── ollama-ai-workflow.json
│   └── Rag_Gemini_Ollama_Supabase_Vector.json
├── credentials/            # Credentials storage (auto-created)
├── SETUP-GOOGLE-SHEETS-LINE.md
├── SETUP-LINE-MESSAGING-API.md
├── SETUP-TELEGRAM-BOT.md
├── SETUP-AI-CONTENT-GENERATION.md
├── SETUP-OLLAMA.md
└── README.md              # คู่มือนี้
```

## 🔧 การใช้งานเบื้องต้น

### Import Workflow ตัวอย่าง

1. เข้าไปที่ n8n web interface
2. คลิก "Import from file" หรือ "Import from URL"
3. เลือกไฟล์ workflow จากโฟลเดอร์ `workflows/`

### Workflow ตัวอย่างที่มีให้

#### 1. Hello World Workflow
- **ไฟล์**: `workflows/hello-world-workflow.json`
- **คำอธิบาย**: Workflow พื้นฐานสำหรับทดสอบการทำงาน
- **การใช้งาน**: กด "Test workflow" เพื่อดูผลลัพธ์

#### 2. Webhook Example Workflow
- **ไฟล์**: `workflows/webhook-example-workflow.json`
- **คำอธิบาย**: ตัวอย่างการรับ webhook และตอบกลับ
- **การทดสอบ**:
  ```bash
  # ทดสอบ webhook (เมื่อ workflow active แล้ว)
  curl -X POST http://localhost:5678/webhook/webhook-test \
    -H "Content-Type: application/json" \
    -d '{"action": "test", "message": "Hello from webhook!"}'
  ```

#### 3. 🤖 Ollama AI Workflow
- **ไฟล์**: `workflows/ollama-ai-workflow.json`
- **คำอธิบาย**: Chat กับ AI models ในเครื่อง (Llama 3.2)
- **คู่มือ**: `SETUP-OLLAMA.md`
- **การทดสอบ**:
  ```bash
  curl -X POST http://localhost:5678/webhook/ollama-chat \
    -H "Content-Type: application/json" \
    -d '{"message": "สวัสดี คุณเป็นอย่างไรบ้าง?"}'
  ```

#### 4. 📊 Google Sheets + Line Notification
- **ไฟล์**: `workflows/google-sheets-line-notification.json`
- **คำอธิบาย**: ส่งการแจ้งเตือนจาก Google Sheets ผ่าน Line Notify
- **คู่มือ**: `SETUP-GOOGLE-SHEETS-LINE.md`

#### 5. 💬 Google Sheets + Line Messaging API
- **ไฟล์**: `workflows/google-sheets-line-messaging-api.json`
- **คำอธิบาย**: ส่งข้อความแบบ Interactive ผ่าน Line Bot
- **คู่มือ**: `SETUP-LINE-MESSAGING-API.md`

#### 6. 🤖 Google Sheets + Telegram Bot
- **ไฟล์**: `workflows/google-sheets-telegram-bot.json`
- **คำอธิบาย**: ส่งการแจ้งเตือนผ่าน Telegram Bot พร้อม Inline Keyboard
- **คู่มือ**: `SETUP-TELEGRAM-BOT.md`

#### 7. ✨ AI Content Generation
- **ไฟล์**: `workflows/ai-content-generation-workflow.json`
- **คำอธิบาย**: สร้างเนื้อหาด้วย AI และบันทึกลง MySQL
- **คู่มือ**: `SETUP-AI-CONTENT-GENERATION.md`

## 🤖 Ollama AI Integration

โปรเจคนี้รวม Ollama (Local AI) ไว้ด้วยแล้ว สามารถใช้งาน AI models ในเครื่องได้โดยไม่ต้องพึ่งพา External APIs

### เริ่มต้นใช้งาน Ollama

```bash
# เริ่มต้น n8n + Ollama
docker-compose up -d

# ตรวจสอบว่า Ollama ทำงานปกติ
curl http://localhost:11434/api/tags

# ดาวน์โหลด models เพิ่มเติม
docker exec n8n-ollama ollama pull llama3.1:8b
docker exec n8n-ollama ollama pull codellama:7b
```

### Models ที่แนะนำ

- **llama3.2** (3B) - เร็ว, เหมาะสำหรับงานทั่วไป
- **llama3.1:8b** - คุณภาพสูง, ใช้ RAM มากกว่า
- **codellama:7b** - เขียนโค้ด
- **phi3:3.8b** - เล็กแต่มีประสิทธิภาพ

### การใช้งานใน n8n

1. Import `ollama-ai-workflow.json`
2. เปิดใช้งาน workflow
3. ทดสอบผ่าน webhook หรือใช้ใน workflows อื่น

**ดูรายละเอียดเพิ่มเติมใน `SETUP-OLLAMA.md`**

## ⚙️ การตั้งค่าเพิ่มเติม

### ใช้ PostgreSQL แทน SQLite

1. แก้ไข `docker-compose.yml` โดย uncomment ส่วน PostgreSQL
2. แก้ไข environment variables ใน n8n service:
   ```yaml
   - DB_TYPE=postgresdb
   - DB_POSTGRESDB_HOST=postgres
   - DB_POSTGRESDB_DATABASE=${POSTGRES_DB:-n8n}
   - DB_POSTGRESDB_USER=${POSTGRES_USER:-n8n}
   - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD:-n8n}
   ```
3. ตั้งค่า PostgreSQL credentials ใน `.env`

### การตั้งค่า Email (SMTP)

แก้ไข `.env` และ uncomment ส่วน email configuration:

```env
N8N_EMAIL_MODE=smtp
N8N_SMTP_HOST=smtp.gmail.com
N8N_SMTP_PORT=587
N8N_SMTP_USER=your_email@gmail.com
N8N_SMTP_PASS=your_app_password
N8N_SMTP_SENDER=your_email@gmail.com
```

## 🔒 ความปลอดภัย

- เปลี่ยนรหัสผ่านเริ่มต้นใน `.env`
- ใช้ HTTPS ในการ production
- ตั้งค่า `N8N_ENCRYPTION_KEY` สำหรับการเข้ารหัส credentials
- จำกัดการเข้าถึง port 5678 ด้วย firewall

## 📚 คำสั่งที่มีประโยชน์

```bash
# ดู logs แบบ real-time
docker-compose logs -f n8n

# เข้าไปใน container
docker-compose exec n8n sh

# Backup workflows และ credentials
docker-compose exec n8n tar -czf /tmp/n8n-backup.tar.gz /home/node/.n8n
docker cp $(docker-compose ps -q n8n):/tmp/n8n-backup.tar.gz ./n8n-backup.tar.gz

# Restart n8n
docker-compose restart n8n

# Update n8n to latest version
docker-compose pull n8n
docker-compose up -d n8n
```

## 🐛 การแก้ไขปัญหา

### n8n ไม่สามารถเริ่มต้นได้

1. ตรวจสอบว่า port 5678 ไม่ถูกใช้งานโดยโปรแกรมอื่น
2. ตรวจสอบ Docker logs: `docker-compose logs n8n`
3. ตรวจสอบการตั้งค่าใน `.env`

### Webhook ไม่ทำงาน

1. ตรวจสอบว่า workflow เป็น "Active"
2. ตรวจสอบ URL ของ webhook ใน workflow
3. ตรวจสอบ firewall settings

### Performance ช้า

1. เพิ่ม memory limit ใน docker-compose.yml
2. ใช้ PostgreSQL แทน SQLite
3. ตั้งค่า `N8N_PAYLOAD_SIZE_MAX` และ `EXECUTIONS_TIMEOUT`

## 📖 เอกสารเพิ่มเติม

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [n8n Workflows Library](https://n8n.io/workflows/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🤝 การสนับสนุน

หากมีปัญหาหรือข้อสงสัย สามารถ:
- เปิด Issue ใน repository นี้
- ถามใน n8n Community
- ดู n8n Documentation

---

**Happy Automating! 🚀**
