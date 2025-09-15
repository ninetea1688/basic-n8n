# 🤖 Telegram Bot Workflow Setup Guide

## ภาพรวม
Workflow นี้ใช้สำหรับส่งการแจ้งเตือนจาก Google Sheets ผ่าน Telegram Bot โดยมีคุณสมบัติ:
- ส่งข้อความแบบ Markdown (Bold, Italic)
- Inline Keyboard สำหรับการโต้ตอบ
- ส่งไปยัง Chat หรือ Channel เฉพาะ
- รองรับ Callback Actions

## เปรียบเทียบ Platforms

| ฟีเจอร์ | Line Notify | Line Messaging API | Telegram Bot |
|---------|-------------|--------------------|--------------|
| การตั้งค่า | ง่าย | ซับซ้อน | ปานกลาง |
| รูปแบบข้อความ | Text + Image | Flex Message | Markdown + HTML |
| การโต้ตอบ | ไม่ได้ | Quick Reply | Inline Keyboard |
| ข้อจำกัด | 1,000/เดือน | ตาม Plan | ไม่จำกัด (มี Rate Limit) |
| การส่งไฟล์ | รูปภาพ | หลากหลาย | ทุกประเภท |
| ความปลอดภัย | พื้นฐาน | สูง | สูงมาก |

## ข้อกำหนดเบื้องต้น

### 1. สร้าง Telegram Bot
1. เปิด Telegram และค้นหา `@BotFather`
2. ส่งคำสั่ง `/newbot`
3. ตั้งชื่อ Bot (เช่น "My Data Bot")
4. ตั้ง Username ของ Bot (ต้องลงท้ายด้วย "bot")
5. รับ Bot Token จาก BotFather

### 2. หา Chat ID

#### สำหรับ Private Chat:
1. ส่งข้อความใดๆ ไปยัง Bot
2. เปิด URL: `https://api.telegram.org/bot<BOT_TOKEN>/getUpdates`
3. หา `chat.id` ในผลลัพธ์

#### สำหรับ Group Chat:
1. เพิ่ม Bot เข้า Group
2. ส่งข้อความใน Group
3. เปิด URL: `https://api.telegram.org/bot<BOT_TOKEN>/getUpdates`
4. หา `chat.id` (จะเป็นเลขติดลบ)

#### สำหรับ Channel:
1. เพิ่ม Bot เป็น Admin ใน Channel
2. ส่งข้อความใน Channel
3. Chat ID จะเป็น `@channel_username` หรือ ID ตัวเลข

### 3. ตัวอย่างการหา Chat ID ด้วย n8n
```javascript
// Webhook Node สำหรับรับ Updates
const updates = $json.result || [];
const chatIds = updates.map(update => {
  const message = update.message || update.channel_post;
  return {
    chatId: message.chat.id,
    chatType: message.chat.type,
    chatTitle: message.chat.title || message.chat.first_name,
    username: message.chat.username
  };
});

return chatIds;
```

## การตั้งค่าใน n8n

### ขั้นตอนที่ 1: Import Workflow
1. เข้าสู่ n8n Web Interface (http://localhost:5678)
2. คลิก "Import from file"
3. เลือกไฟล์ `google-sheets-telegram-bot.json`
4. คลิก "Import"

### ขั้นตอนที่ 2: ตั้งค่า Google Sheets
1. ตั้งค่า Google Service Account Credential
2. แก้ไข `YOUR_GOOGLE_SHEET_ID` ใน Google Sheets node
3. ระบุ Sheet name และ Range ที่ต้องการ

### ขั้นตอนที่ 3: ตั้งค่า Telegram Bot
1. แก้ไข `YOUR_TELEGRAM_BOT_TOKEN` ใน "Set Bot Token" node
2. แก้ไข `YOUR_TELEGRAM_CHAT_ID` ใน "Set Bot Token" node
3. แก้ไข `YOUR_GOOGLE_SHEET_ID` ใน Inline Keyboard URL

### ขั้นตอนที่ 4: ทดสอบ Workflow
1. เปิดใช้งาน Workflow
2. รอให้ Schedule Trigger ทำงาน
3. ตรวจสอบข้อความใน Telegram Chat

## การปรับแต่งข้อความ

### Markdown Formatting
```javascript
// Bold Text
'*ข้อความตัวหนา*'

// Italic Text
'_ข้อความตัวเอียง_'

// Code
'`โค้ด`'

// Code Block
'```\nโค้ดหลายบรรทัด\n```'

// Link
'[ข้อความ](https://example.com)'
```

### HTML Formatting (ทางเลือก)
```javascript
// เปลี่ยน parse_mode เป็น "HTML"
'<b>ข้อความตัวหนา</b>'
'<i>ข้อความตัวเอียง</i>'
'<code>โค้ด</code>'
'<pre>โค้ดหลายบรรทัด</pre>'
'<a href="https://example.com">ลิงก์</a>'
```

## การปรับแต่ง Inline Keyboard

### โครงสร้างพื้นฐาน
```json
{
  "inline_keyboard": [
    [
      {
        "text": "ปุ่มที่ 1",
        "callback_data": "button1"
      },
      {
        "text": "ปุ่มที่ 2",
        "url": "https://example.com"
      }
    ],
    [
      {
        "text": "ปุ่มแถวที่ 2",
        "callback_data": "button3"
      }
    ]
  ]
}
```

### ประเภทของปุ่ม

#### 1. Callback Button
```json
{
  "text": "📊 ดูข้อมูล",
  "callback_data": "view_data"
}
```

#### 2. URL Button
```json
{
  "text": "🌐 เปิดเว็บไซต์",
  "url": "https://example.com"
}
```

#### 3. Switch Inline Button
```json
{
  "text": "🔄 แชร์",
  "switch_inline_query": "ข้อมูลจาก Bot"
}
```

#### 4. Login Button
```json
{
  "text": "🔐 เข้าสู่ระบบ",
  "login_url": {
    "url": "https://example.com/login"
  }
}
```

## การจัดการ Callback Queries

### สร้าง Webhook สำหรับรับ Callbacks
```javascript
// Webhook Node สำหรับรับ Callback Queries
const update = $json;

if (update.callback_query) {
  const callbackData = update.callback_query.data;
  const chatId = update.callback_query.message.chat.id;
  const messageId = update.callback_query.message.message_id;
  
  // ประมวลผล callback ตาม data
  switch (callbackData) {
    case 'view_all_data':
      // ดึงข้อมูลทั้งหมดจาก Google Sheets
      break;
    case 'refresh_data':
      // รีเฟรชข้อมูล
      break;
    case 'view_chart':
      // สร้างและส่งกราฟ
      break;
    case 'export_data':
      // ส่งออกข้อมูลเป็นไฟล์
      break;
  }
  
  return {
    chatId,
    messageId,
    callbackData,
    userId: update.callback_query.from.id
  };
}
```

### ตอบกลับ Callback Query
```javascript
// HTTP Request Node สำหรับตอบกลับ Callback
{
  "url": "https://api.telegram.org/bot<BOT_TOKEN>/answerCallbackQuery",
  "method": "POST",
  "body": {
    "callback_query_id": "{{ $json.callback_query.id }}",
    "text": "กำลังประมวลผล...",
    "show_alert": false
  }
}
```

## การส่งไฟล์และรูปภาพ

### ส่งรูปภาพ
```javascript
// HTTP Request Node
{
  "url": "https://api.telegram.org/bot<BOT_TOKEN>/sendPhoto",
  "method": "POST",
  "body": {
    "chat_id": "<CHAT_ID>",
    "photo": "https://example.com/image.jpg",
    "caption": "คำอธิบายรูปภาพ",
    "parse_mode": "Markdown"
  }
}
```

### ส่งเอกสาร
```javascript
// HTTP Request Node
{
  "url": "https://api.telegram.org/bot<BOT_TOKEN>/sendDocument",
  "method": "POST",
  "body": {
    "chat_id": "<CHAT_ID>",
    "document": "https://example.com/file.pdf",
    "caption": "รายงานประจำเดือน"
  }
}
```

### สร้างกราฟจากข้อมูล Google Sheets
```javascript
// Code Node สำหรับสร้าง Chart URL
const data = $json.latestData;
const chartData = Object.values(data).join(',');
const chartLabels = Object.keys(data).join('|');

// ใช้ QuickChart.io สำหรับสร้างกราฟ
const chartUrl = `https://quickchart.io/chart?c={
  type: 'bar',
  data: {
    labels: ['${chartLabels.replace(/,/g, "','")}']
    datasets: [{
      label: 'ข้อมูล',
      data: [${chartData}]
    }]
  }
}`;

return { chartUrl };
```

## การตั้งค่าขั้นสูง

### การใช้ Bot Commands
```javascript
// ตั้งค่า Commands ผ่าน BotFather
/setcommands

// รายการ Commands
start - เริ่มต้นใช้งาน Bot
help - ดูคำแนะนำการใช้งาน
data - ดูข้อมูลล่าสุด
refresh - รีเฟรชข้อมูล
settings - ตั้งค่า Bot
```

### การจัดการ Commands ใน n8n
```javascript
// Webhook Node สำหรับรับ Commands
const message = $json.message;

if (message && message.text && message.text.startsWith('/')) {
  const command = message.text.split(' ')[0].substring(1);
  const chatId = message.chat.id;
  
  switch (command) {
    case 'start':
      return { action: 'welcome', chatId };
    case 'data':
      return { action: 'show_data', chatId };
    case 'help':
      return { action: 'show_help', chatId };
    default:
      return { action: 'unknown_command', chatId };
  }
}
```

### การตั้งค่า Webhook URL
```bash
# ตั้งค่า Webhook URL สำหรับรับ Updates
curl -X POST "https://api.telegram.org/bot<BOT_TOKEN>/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-n8n-instance.com/webhook/telegram",
    "allowed_updates": ["message", "callback_query"]
  }'
```

## การแก้ไขปัญหา

### Telegram API Error Codes
- `400`: Bad Request - ตรวจสอบ JSON format
- `401`: Unauthorized - ตรวจสอบ Bot Token
- `403`: Forbidden - Bot ถูกบล็อกหรือไม่มีสิทธิ์
- `429`: Too Many Requests - ลด Rate ของการส่งข้อความ

### ปัญหาที่พบบ่อย

#### ข้อความไม่ส่ง
1. ตรวจสอบ Bot Token
2. ตรวจสอบ Chat ID
3. ตรวจสอบว่า Bot ถูกเพิ่มใน Chat/Group
4. ตรวจสอบ JSON format

#### Inline Keyboard ไม่แสดง
1. ตรวจสอบ JSON structure ของ reply_markup
2. ตรวจสอบ callback_data ไม่เกิน 64 bytes
3. ตรวจสอบ URL ใน URL buttons

#### Callback Query ไม่ทำงาน
1. ตรวจสอบ Webhook URL
2. ตรวจสอบการตั้งค่า allowed_updates
3. ตอบกลับ answerCallbackQuery ภายใน 30 วินาที

### การ Debug
```javascript
// เพิ่ม Debug Node เพื่อดู Response
console.log('Telegram API Response:', $json);

// ตรวจสอบ Error
if ($json.ok === false) {
  console.error('Telegram Error:', $json.description);
  throw new Error($json.description);
}
```

## ความปลอดภัย

### การป้องกัน Bot Token
- เก็บ Token ใน Environment Variables
- ไม่แชร์ Token ในโค้ด
- ใช้ Webhook แทน Polling ใน Production

### การตรวจสอบผู้ใช้
```javascript
// ตรวจสอบ User ID ที่อนุญาต
const allowedUsers = ['123456789', '987654321'];
const userId = $json.message.from.id.toString();

if (!allowedUsers.includes(userId)) {
  throw new Error('Unauthorized user');
}
```

### การจำกัด Rate
```javascript
// เก็บ timestamp ของการส่งข้อความล่าสุด
const lastSent = global.get('lastTelegramSent') || 0;
const now = Date.now();

if (now - lastSent < 1000) { // จำกัด 1 ข้อความต่อวินาที
  throw new Error('Rate limit exceeded');
}

global.set('lastTelegramSent', now);
```

## การติดตามและ Analytics

### Metrics ที่ควรติดตาม
- จำนวนข้อความที่ส่งต่อวัน
- จำนวน Callback Queries
- Response Time ของ API
- Error Rate

### การใช้ Telegram Bot Analytics
```javascript
// ส่งข้อมูล Analytics
const analytics = {
  userId: $json.message.from.id,
  username: $json.message.from.username,
  chatType: $json.message.chat.type,
  messageType: $json.message.text ? 'text' : 'other',
  timestamp: new Date().toISOString()
};

// บันทึกลง Database หรือ Analytics Service
```

## การขยายระบบ

### เพิ่ม Mini Apps
- สร้าง Web App ที่ทำงานใน Telegram
- ใช้ Telegram Web Apps API
- เชื่อมต่อกับ Google Sheets โดยตรง

### การใช้ Telegram Payments
- รับชำระเงินผ่าน Telegram
- เชื่อมต่อกับ Payment Providers
- สร้างใบเสร็จอัตโนมัติ

### Bot Groups และ Channels
- สร้าง Bot สำหรับจัดการ Group
- Auto-moderation
- การส่งข้อความตามเวลา

---

**หมายเหตุ**: Telegram Bot API ไม่มีข้อจำกัดการใช้งาน แต่มี Rate Limit ที่ 30 ข้อความต่อวินาทีต่อ Chat กรุณาใช้งานอย่างเหมาะสม