# 🔧 คู่มือการตั้งค่า Google Sheets + Line Notification Workflow

คู่มือนี้จะแนะนำการตั้งค่า workflow สำหรับเชื่อมต่อ Google Sheets กับ Line Notification

## 📋 สิ่งที่ต้องเตรียม

1. Google Account
2. Line Account
3. Google Sheets ที่ต้องการติดตาม
4. n8n instance ที่รันอยู่

## 🔑 การตั้งค่า Google Sheets API

### ขั้นตอนที่ 1: สร้าง Google Cloud Project

1. ไปที่ [Google Cloud Console](https://console.cloud.google.com/)
2. สร้าง Project ใหม่หรือเลือก Project ที่มีอยู่
3. เปิดใช้งาน Google Sheets API:
   - ไปที่ "APIs & Services" > "Library"
   - ค้นหา "Google Sheets API"
   - คลิก "Enable"

### ขั้นตอนที่ 2: สร้าง Service Account

1. ไปที่ "APIs & Services" > "Credentials"
2. คลิก "Create Credentials" > "Service Account"
3. ใส่ชื่อ Service Account (เช่น "n8n-sheets-integration")
4. คลิก "Create and Continue"
5. เลือก Role: "Editor" หรือ "Viewer" (ตามความต้องการ)
6. คลิก "Done"

### ขั้นตอนที่ 3: สร้าง JSON Key

1. คลิกที่ Service Account ที่สร้างขึ้น
2. ไปที่แท็บ "Keys"
3. คลิก "Add Key" > "Create new key"
4. เลือก "JSON" และคลิก "Create"
5. ไฟล์ JSON จะถูกดาวน์โหลด - **เก็บไฟล์นี้ไว้อย่างปลอดภัย**

### ขั้นตอนที่ 4: แชร์ Google Sheets

1. เปิด Google Sheets ที่ต้องการใช้งาน
2. คลิก "Share" (แชร์)
3. ใส่ email ของ Service Account (จาก JSON file)
4. ให้สิทธิ์ "Editor" หรือ "Viewer"
5. คลิก "Send"

## 📱 การตั้งค่า Line Notify

### ขั้นตอนที่ 1: สร้าง Line Notify Token

1. ไปที่ [Line Notify](https://notify-bot.line.me/)
2. เข้าสู่ระบบด้วย Line Account
3. คลิก "Generate token"
4. ใส่ชื่อ Service (เช่น "n8n Google Sheets Alert")
5. เลือกกลุ่มหรือแชทที่ต้องการรับการแจ้งเตือน
6. คลิก "Generate token"
7. **คัดลอกและเก็บ Token ไว้อย่างปลอดภัย**

## ⚙️ การตั้งค่าใน n8n

### ขั้นตอนที่ 1: Import Workflow

1. เข้าไปที่ n8n (http://localhost:5678)
2. คลิก "Import from file"
3. เลือกไฟล์ `google-sheets-line-notification.json`
4. คลิก "Import"

### ขั้นตอนที่ 2: ตั้งค่า Google Sheets Credentials

1. คลิกที่ "Google Sheets" node
2. ใน "Credential for Google Sheets API" คลิก "Create New"
3. เลือก "Service Account"
4. วาง JSON content จาก Service Account key file
5. คลิก "Save"

### ขั้นตอนที่ 3: ตั้งค่า Google Sheets Document

1. ใน Google Sheets node
2. แก้ไข "Document ID":
   - คัดลอก ID จาก URL ของ Google Sheets
   - URL: `https://docs.google.com/spreadsheets/d/[SHEET_ID]/edit`
   - ใส่ SHEET_ID ในช่อง "Document ID"
3. ตั้งค่า "Sheet Name" (เช่น "Sheet1")
4. ตั้งค่า "Range" (เช่น "A:Z" สำหรับทุก column)

### ขั้นตอนที่ 4: ตั้งค่า Line Notify Credentials

1. คลิกที่ "Line Notify" node
2. ใน "Credential for Line Notify API" คลิก "Create New"
3. ใส่ Access Token ที่ได้จาก Line Notify
4. คลิก "Save"

### ขั้นตอนที่ 5: ปรับแต่ง Schedule

1. คลิกที่ "Schedule Trigger" node
2. ปรับ "Interval" ตามต้องการ:
   - Minutes: ตรวจสอบทุกกี่นาที
   - Hours: ตรวจสอบทุกกี่ชั่วโมง
   - Days: ตรวจสอบทุกกี่วัน

## 🧪 การทดสอบ Workflow

### ทดสอบแต่ละ Node

1. **ทดสอบ Google Sheets**:
   - คลิกที่ Google Sheets node
   - คลิก "Test step"
   - ตรวจสอบว่าข้อมูลถูกดึงมาถูกต้อง

2. **ทดสอบ Line Notify**:
   - คลิกที่ Line Notify node
   - คลิก "Test step"
   - ตรวจสอบว่าได้รับข้อความใน Line

### ทดสอบ Workflow ทั้งหมด

1. คลิก "Test workflow"
2. ตรวจสอบผลลัพธ์ในแต่ละ node
3. ตรวจสอบว่าได้รับการแจ้งเตือนใน Line

## 🔄 การเปิดใช้งาน Workflow

1. คลิกสวิตช์ "Active" ที่มุมขวาบน
2. Workflow จะเริ่มทำงานตาม Schedule ที่ตั้งไว้
3. ตรวจสอบ Execution History เพื่อดูผลการทำงาน

## 📊 ตัวอย่างการใช้งาน

### Use Case 1: ติดตามยอดขาย
- Google Sheets: บันทึกยอดขายรายวัน
- Line Notification: แจ้งเตือนเมื่อมียอดขายใหม่

### Use Case 2: ติดตามสถานะโปรเจค
- Google Sheets: อัปเดตสถานะงาน
- Line Notification: แจ้งเตือนเมื่อมีการเปลี่ยนแปลงสถานะ

### Use Case 3: ติดตามข้อมูลลูกค้า
- Google Sheets: บันทึกข้อมูลลูกค้าใหม่
- Line Notification: แจ้งเตือนเมื่อมีลูกค้าใหม่

## 🛠️ การปรับแต่งเพิ่มเติม

### ปรับแต่งข้อความ Line Notification

แก้ไขใน "Process Sheet Data" node (Code node):

```javascript
// ปรับแต่งรูปแบบข้อความ
let message = '🔔 **แจ้งเตือนจาก Google Sheets**\n\n';

// เพิ่มเงื่อนไขการแจ้งเตือน
if (latestRow.status === 'urgent') {
  message = '🚨 **แจ้งเตือนด่วน!**\n\n';
}

// เพิ่ม emoji ตามประเภทข้อมูล
if (latestRow.type === 'sale') {
  message += '💰 ';
} else if (latestRow.type === 'task') {
  message += '📋 ';
}
```

### เพิ่มเงื่อนไขการแจ้งเตือน

แก้ไขใน "Check Data Exists" node:

```javascript
// แจ้งเตือนเฉพาะข้อมูลที่มี priority สูง
$json.priority === 'high'

// แจ้งเตือนเฉพาะในช่วงเวลาทำการ
new Date().getHours() >= 9 && new Date().getHours() <= 17
```

## ❗ การแก้ไขปัญหา

### ปัญหาที่พบบ่อย

1. **Google Sheets ไม่สามารถเข้าถึงได้**
   - ตรวจสอบว่าแชร์ Sheets ให้ Service Account แล้ว
   - ตรวจสอบ JSON credentials ถูกต้อง
   - ตรวจสอบว่าเปิดใช้งาน Google Sheets API แล้ว

2. **Line Notify ไม่ส่งข้อความ**
   - ตรวจสอบ Access Token ถูกต้อง
   - ตรวจสอบว่า Token ยังไม่หมดอายุ
   - ตรวจสอบการเชื่อมต่อ internet

3. **Workflow ไม่ทำงานตาม Schedule**
   - ตรวจสอบว่า Workflow เป็น "Active"
   - ตรวจสอบ Schedule Trigger settings
   - ดู Execution History เพื่อหาข้อผิดพลาด

### การ Debug

1. ดู Execution logs ใน n8n
2. ทดสอบแต่ละ node แยกกัน
3. ตรวจสอบ Error messages
4. ใช้ "Sticky Note" node เพื่อ debug ข้อมูล

## 🔒 ความปลอดภัย

- เก็บ Service Account JSON file อย่างปลอดภัย
- ไม่แชร์ Line Notify Token กับผู้อื่น
- ใช้สิทธิ์ขั้นต่ำที่จำเป็นสำหรับ Google Sheets
- ตรวจสอบ Execution logs เป็นประจำ

---

**🎉 ขอให้สนุกกับการ Automate!**