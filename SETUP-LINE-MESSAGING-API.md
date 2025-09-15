# 📱 Line Messaging API Workflow Setup Guide

## ภาพรวม
Workflow นี้เป็นการอัปเกรดจาก Line Notify เป็น Line Messaging API ซึ่งมีความสามารถที่มากกว่า:
- ส่งข้อความแบบ Flex Message (Rich Content)
- มี Quick Reply Actions
- ส่งไปยัง User หรือ Group เฉพาะ
- รองรับการโต้ตอบแบบ Interactive

## ความแตกต่างระหว่าง Line Notify และ Line Messaging API

| ฟีเจอร์ | Line Notify | Line Messaging API |
|---------|-------------|--------------------|
| การตั้งค่า | ง่าย (Access Token) | ซับซ้อนกว่า (Channel Setup) |
| รูปแบบข้อความ | Text + Image | Text, Flex, Template, Rich Content |
| การโต้ตอบ | ไม่ได้ | รองรับ Quick Reply, Postback |
| การส่งข้อความ | ส่งไปยัง Chat ที่ Authorize | ส่งไปยัง User/Group เฉพาะ |
| ข้อจำกัด | 1,000 ข้อความ/เดือน | ตาม Plan ที่เลือก |
| การปรับแต่ง | จำกัด | ปรับแต่งได้มาก |

## ข้อกำหนดเบื้องต้น

### 1. Line Developer Account
- สมัครบัญชี Line Developer ที่ https://developers.line.biz/
- ยืนยันตัวตนด้วยเบอร์โทรศัพท์

### 2. สร้าง Line Bot Channel
1. เข้าสู่ Line Developer Console
2. สร้าง Provider ใหม่ (หรือใช้ที่มีอยู่)
3. สร้าง Channel ประเภท "Messaging API"
4. กรอกข้อมูล Channel:
   - Channel name: ชื่อ Bot
   - Channel description: คำอธิบาย
   - Category: เลือกหมวดหมู่ที่เหมาะสม
   - Subcategory: เลือกหมวดหมู่ย่อย

### 3. ตั้งค่า Channel
1. ไปที่แท็บ "Messaging API"
2. สร้าง Channel Access Token
3. เปิดใช้งาน "Use webhooks"
4. ปิด "Auto-reply messages" (ถ้าไม่ต้องการ)
5. ปิด "Greeting messages" (ถ้าไม่ต้องการ)

## การหา User ID และ Group ID

### วิธีหา User ID
1. เพิ่มเพื่อน Bot ที่สร้าง (ใช้ QR Code หรือ Bot ID)
2. ส่งข้อความใดๆ ไปยัง Bot
3. ใช้ Webhook URL เพื่อรับ User ID จาก Event

### วิธีหา Group ID
1. เชิญ Bot เข้า Line Group
2. ส่งข้อความใน Group
3. ใช้ Webhook URL เพื่อรับ Group ID จาก Event

### ตัวอย่าง Webhook สำหรับหา ID
```javascript
// ใน n8n Webhook Node
const events = $json.events;
if (events && events.length > 0) {
  const event = events[0];
  return {
    userId: event.source.userId,
    groupId: event.source.groupId,
    type: event.source.type,
    message: event.message?.text
  };
}
```

## การตั้งค่าใน n8n

### ขั้นตอนที่ 1: Import Workflow
1. เข้าสู่ n8n Web Interface (http://localhost:5678)
2. คลิก "Import from file"
3. เลือกไฟล์ `google-sheets-line-messaging-api.json`
4. คลิก "Import"

### ขั้นตอนที่ 2: ตั้งค่า Google Sheets
1. ตั้งค่า Google Service Account Credential
2. แก้ไข `YOUR_GOOGLE_SHEET_ID` ใน Google Sheets node
3. ระบุ Sheet name และ Range ที่ต้องการ

### ขั้นตอนที่ 3: ตั้งค่า Line Messaging API
1. แก้ไข `YOUR_LINE_CHANNEL_ACCESS_TOKEN` ใน HTTP Request nodes
2. แก้ไข `YOUR_LINE_USER_ID_OR_GROUP_ID` ใน JSON Body
3. แก้ไข `YOUR_GOOGLE_SHEET_ID` ใน Quick Reply URI

### ขั้นตอนที่ 4: ทดสอบ Workflow
1. เปิดใช้งาน Workflow
2. รอให้ Schedule Trigger ทำงาน
3. ตรวจสอบข้อความใน Line Chat

## การปรับแต่ง Flex Message

### โครงสร้างพื้นฐาน
```json
{
  "type": "flex",
  "altText": "ข้อความสำรอง",
  "contents": {
    "type": "bubble",
    "header": { /* ส่วนหัว */ },
    "body": { /* เนื้อหาหลัก */ },
    "footer": { /* ส่วนท้าย */ }
  }
}
```

### การเพิ่มสี Theme
```javascript
// ในส่วน header
"backgroundColor": "#06C755", // สีเขียว Line
"backgroundColor": "#FF6B6B", // สีแดง
"backgroundColor": "#4ECDC4", // สีฟ้า
"backgroundColor": "#45B7D1", // สีน้ำเงิน
```

### การเพิ่ม Actions
```javascript
// ใน footer หรือ body
"action": {
  "type": "uri",
  "uri": "https://example.com"
}
// หรือ
"action": {
  "type": "message",
  "text": "ข้อความที่จะส่งกลับ"
}
// หรือ
"action": {
  "type": "postback",
  "data": "action=view&id=123"
}
```

## การเพิ่ม Quick Reply

### ตัวอย่าง Quick Reply Actions
```json
{
  "items": [
    {
      "type": "action",
      "action": {
        "type": "message",
        "label": "📊 ดูรายงาน",
        "text": "ขอดูรายงานล่าสุด"
      }
    },
    {
      "type": "action",
      "action": {
        "type": "postback",
        "label": "⚙️ ตั้งค่า",
        "data": "action=settings",
        "displayText": "เปิดหน้าตั้งค่า"
      }
    },
    {
      "type": "action",
      "action": {
        "type": "datetimepicker",
        "label": "📅 เลือกวันที่",
        "data": "action=date",
        "mode": "date"
      }
    }
  ]
}
```

## การจัดการ Webhook Response

### สร้าง Webhook Endpoint ใน n8n
```javascript
// Webhook Node สำหรับรับ Response จาก Line
const events = $json.events || [];

for (const event of events) {
  if (event.type === 'message') {
    // จัดการข้อความที่ได้รับ
    const userMessage = event.message.text;
    const userId = event.source.userId;
    
    // ตอบกลับตามข้อความ
    if (userMessage.includes('ข้อมูลทั้งหมด')) {
      // ส่งข้อมูลทั้งหมดจาก Google Sheets
    } else if (userMessage.includes('รีเฟรช')) {
      // รีเฟรชข้อมูลใหม่
    }
  } else if (event.type === 'postback') {
    // จัดการ Postback Action
    const data = event.postback.data;
    // ประมวลผล action ตาม data
  }
}
```

## การแก้ไขปัญหา

### Line API Error Codes
- `400`: Bad Request - ตรวจสอบ JSON format
- `401`: Unauthorized - ตรวจสอบ Access Token
- `403`: Forbidden - ตรวจสอบสิทธิ์ Channel
- `429`: Too Many Requests - ลด Rate ของการส่งข้อความ

### ปัญหาที่พบบ่อย

#### ข้อความไม่ส่ง
1. ตรวจสอบ Channel Access Token
2. ตรวจสอบ User ID หรือ Group ID
3. ตรวจสอบ JSON format ของ Flex Message
4. ตรวจสอบว่า Bot ถูกเพิ่มเป็นเพื่อนแล้ว

#### Flex Message ไม่แสดงผล
1. ตรวจสอบ JSON structure
2. ใช้ Flex Message Simulator ทดสอบ
3. ตรวจสอบ altText สำหรับ fallback

#### Quick Reply ไม่ทำงาน
1. ตรวจสอบ Webhook URL
2. ตรวจสอบการตั้งค่า Channel
3. ตรวจสอบ JSON format ของ Quick Reply

## การติดตามและ Monitoring

### Metrics ที่ควรติดตาม
- จำนวนข้อความที่ส่งต่อเดือน
- Response Time ของ API
- Error Rate
- User Engagement (Click Rate)

### การใช้ Line Bot Designer
- ใช้ Flex Message Simulator: https://developers.line.biz/flex-simulator/
- ทดสอบ Rich Menu: https://developers.line.biz/console/

## การขยายระบบ

### เพิ่ม Rich Menu
```json
{
  "size": {
    "width": 2500,
    "height": 1686
  },
  "selected": false,
  "name": "Main Menu",
  "chatBarText": "เมนู",
  "areas": [
    {
      "bounds": {
        "x": 0,
        "y": 0,
        "width": 1250,
        "height": 843
      },
      "action": {
        "type": "message",
        "text": "ดูข้อมูล"
      }
    }
  ]
}
```

### เพิ่ม LIFF (Line Front-end Framework)
- สร้าง Web App ที่ทำงานใน Line
- เชื่อมต่อกับ Google Sheets โดยตรง
- แสดงข้อมูลแบบ Interactive

### การใช้ AI Chatbot
- เชื่อมต่อกับ OpenAI API
- สร้างการตอบกลับอัตโนมัติ
- วิเคราะห์ข้อความและตอบสนองตามบริบท

## ความปลอดภัย

### การป้องกัน Channel Access Token
- เก็บ Token ใน Environment Variables
- ไม่แชร์ Token ในโค้ด
- หมุนเวียน Token เป็นระยะ

### การตรวจสอบ Webhook Signature
```javascript
// ตรวจสอบ X-Line-Signature
const crypto = require('crypto');
const signature = $headers['x-line-signature'];
const body = JSON.stringify($json);
const hash = crypto.createHmac('SHA256', 'CHANNEL_SECRET').update(body).digest('base64');

if (signature !== hash) {
  throw new Error('Invalid signature');
}
```

### การจำกัดการเข้าถึง
- ใช้ IP Whitelist
- ตั้งค่า Rate Limiting
- เข้ารหัสข้อมูลสำคัญ

---

**หมายเหตุ**: Line Messaging API มีข้อจำกัดการใช้งานตาม Plan ที่เลือก กรุณาตรวจสอบ Pricing และ Quota ก่อนใช้งานจริง