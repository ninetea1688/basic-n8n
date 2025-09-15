# 🤖 Ollama + n8n Integration Guide

## ภาพรวม
การผสานระหว่าง Ollama และ n8n ช่วยให้คุณสามารถใช้งาน AI Models ในท้องถิ่น (Local) ได้โดยไม่ต้องพึ่งพา External APIs เช่น OpenAI

## ข้อดีของการใช้ Ollama
- **ความเป็นส่วนตัว**: ข้อมูลไม่ออกจากเครื่องของคุณ
- **ไม่มีค่าใช้จ่าย**: ไม่ต้องจ่าย API fees
- **ไม่จำกัดการใช้งาน**: ใช้ได้ไม่จำกัดตามขีดความสามารถของเครื่อง
- **รองรับหลาย Models**: Llama, Mistral, CodeLlama, และอื่นๆ
- **ความเร็ว**: Response time ขึ้นอยู่กับฮาร์ดแวร์ของคุณ

## Models ที่รองรับ

### Llama Models
- `llama3.2` (3B, 1B) - รุ่นล่าสุด, เหมาะสำหรับงานทั่วไป
- `llama3.1` (8B, 70B, 405B) - ประสิทธิภาพสูง
- `llama2` (7B, 13B, 70B) - เสถียร, ทดสอบแล้ว

### Code Models
- `codellama` (7B, 13B, 34B) - เขียนโค้ด
- `deepseek-coder` - เขียนโค้ดขั้นสูง

### Thai Language Models
- `typhoon` - รองรับภาษาไทยเป็นพิเศษ
- `seallm` - Southeast Asian Languages

### Lightweight Models
- `phi3` (3.8B) - เล็ก แต่มีประสิทธิภาพ
- `gemma` (2B, 7B) - จาก Google
- `qwen2` (0.5B, 1.5B, 7B) - จาก Alibaba

## ความต้องการระบบ

### ขั้นต่ำ
- **RAM**: 8GB (สำหรับ models 3B-7B)
- **Storage**: 10GB ว่าง
- **CPU**: x64 หรือ ARM64

### แนะนำ
- **RAM**: 16GB+ (สำหรับ models 13B+)
- **GPU**: NVIDIA GPU พร้อม CUDA (เร็วกว่า CPU 10-50 เท่า)
- **Storage**: SSD 50GB+

### สำหรับ Production
- **RAM**: 32GB+
- **GPU**: RTX 4090, A100, หรือ H100
- **Storage**: NVMe SSD 100GB+

## การติดตั้งและใช้งาน

### ขั้นตอนที่ 1: เริ่มต้น Services
```bash
# เริ่มต้น Docker Compose (รวม Ollama)
cd /Users/ninetea/Projects/nhso/n8n-basic
docker compose up -d

# ตรวจสอบสถานะ
docker compose ps
```

### ขั้นตอนที่ 2: ตรวจสอบ Ollama
```bash
# ตรวจสอบว่า Ollama ทำงานปกติ
curl http://localhost:11434/api/tags

# ดู Models ที่มี
docker exec n8n-ollama ollama list
```

### ขั้นตอนที่ 3: ดาวน์โหลด Models เพิ่มเติม
```bash
# Llama 3.2 (3B) - เร็ว, เหมาะสำหรับงานทั่วไป
docker exec n8n-ollama ollama pull llama3.2:3b

# Llama 3.1 (8B) - สมดุลระหว่างความเร็วและคุณภาพ
docker exec n8n-ollama ollama pull llama3.1:8b

# CodeLlama (7B) - เขียนโค้ด
docker exec n8n-ollama ollama pull codellama:7b

# Phi-3 (3.8B) - เล็กแต่มีประสิทธิภาพ
docker exec n8n-ollama ollama pull phi3:3.8b

# Gemma (7B) - จาก Google
docker exec n8n-ollama ollama pull gemma:7b
```

### ขั้นตอนที่ 4: Import Workflow
1. เข้าสู่ n8n (http://localhost:5678)
2. Import ไฟล์ `ollama-ai-workflow.json`
3. เปิดใช้งาน Workflow

### ขั้นตอนที่ 5: ทดสอบ
```bash
# ทดสอบ Chat API
curl -X POST http://localhost:5678/webhook/ollama-chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "สวัสดี คุณเป็นอย่างไรบ้าง?",
    "system_prompt": "คุณเป็น AI ผู้ช่วยที่เป็นมิตรและตอบเป็นภาษาไทย"
  }'
```

## การใช้งานใน n8n Workflows

### 1. HTTP Request Node
```json
{
  "url": "http://ollama:11434/api/generate",
  "method": "POST",
  "body": {
    "model": "llama3.2",
    "prompt": "สวัสดี",
    "stream": false,
    "options": {
      "temperature": 0.7,
      "top_p": 0.9,
      "max_tokens": 1000
    }
  }
}
```

### 2. Chat API (แนะนำ)
```json
{
  "url": "http://ollama:11434/api/chat",
  "method": "POST",
  "body": {
    "model": "llama3.2",
    "messages": [
      {
        "role": "system",
        "content": "คุณเป็น AI ผู้ช่วยที่เป็นมิตร"
      },
      {
        "role": "user",
        "content": "สวัสดี"
      }
    ],
    "stream": false
  }
}
```

### 3. Code Node สำหรับประมวลผล
```javascript
// เตรียมข้อมูลสำหรับ Ollama
const userMessage = $json.message || 'สวัสดี';
const systemPrompt = $json.system_prompt || 'คุณเป็น AI ผู้ช่วย';

return {
  model: 'llama3.2',
  messages: [
    { role: 'system', content: systemPrompt },
    { role: 'user', content: userMessage }
  ],
  stream: false,
  options: {
    temperature: 0.7,
    top_p: 0.9,
    max_tokens: 1000,
    stop: ['Human:', 'Assistant:']
  }
};
```

## การปรับแต่ง Parameters

### Temperature (0.0 - 2.0)
- `0.0-0.3`: คำตอบที่แน่นอน, เหมาะสำหรับข้อเท็จจริง
- `0.4-0.7`: สมดุล, เหมาะสำหรับงานทั่วไป
- `0.8-1.2`: สร้างสรรค์, เหมาะสำหรับเขียนเรื่อง
- `1.3-2.0`: สุ่มมาก, อาจได้คำตอบแปลกๆ

### Top-p (0.0 - 1.0)
- `0.1-0.3`: จำกัดคำตอบ
- `0.4-0.7`: สมดุล
- `0.8-0.95`: หลากหลาย
- `1.0`: ไม่จำกัด

### Max Tokens
- `100-300`: คำตอบสั้น
- `500-1000`: คำตอบปานกลาง
- `1500-2000`: คำตอบยาว
- `4000+`: เอกสารยาว

### Stop Sequences
```javascript
"stop": ["Human:", "Assistant:", "\n\n", "---"]
```

## Use Cases และตัวอย่าง

### 1. Customer Support Chatbot
```javascript
// System Prompt
const systemPrompt = `คุณเป็นเจ้าหน้าที่ฝ่ายบริการลูกค้า มีหน้าที่:
1. ตอบคำถามเกี่ยวกับสินค้าและบริการ
2. ช่วยแก้ไขปัญหา
3. ให้ข้อมูลที่ถูกต้องและเป็นประโยชน์
4. สุภาพและเป็นมิตรเสมอ`;
```

### 2. Content Generator
```javascript
// สร้างเนื้อหา Blog
const prompt = `เขียนบทความเกี่ยวกับ "${topic}" ความยาว 500 คำ 
รวมหัวข้อย่อย 3 หัวข้อ และสรุปท้ายบทความ`;
```

### 3. Code Assistant
```javascript
// ใช้ CodeLlama
const codePrompt = `เขียนฟังก์ชัน Python สำหรับ:
${requirement}

รวม:
- Docstring
- Type hints
- Error handling
- Unit tests`;
```

### 4. Data Analysis
```javascript
// วิเคราะห์ข้อมูลจาก Google Sheets
const analysisPrompt = `วิเคราะห์ข้อมูลต่อไปนี้:
${JSON.stringify(data)}

ให้:
1. สรุปข้อมูลสำคัญ
2. แนวโน้ม
3. ข้อเสนอแนะ`;
```

### 5. Translation Service
```javascript
// แปลภาษา
const translatePrompt = `แปลข้อความต่อไปนี้จากภาษาไทยเป็นภาษาอังกฤษ:
"${thaiText}"

ให้คำแปลที่เป็นธรรมชาติและถูกต้อง`;
```

## การจัดการ Models

### ดู Models ที่มี
```bash
docker exec n8n-ollama ollama list
```

### ลบ Models
```bash
# ลบ model ที่ไม่ใช้
docker exec n8n-ollama ollama rm llama2:7b
```

### อัปเดต Models
```bash
# ดาวน์โหลดเวอร์ชันล่าสุด
docker exec n8n-ollama ollama pull llama3.2:latest
```

### สร้าง Custom Model
```bash
# สร้าง Modelfile
echo 'FROM llama3.2
SYSTEM "คุณเป็น AI ผู้ช่วยที่เชี่ยวชาญด้านการเงิน"' > Modelfile

# สร้าง custom model
docker exec -i n8n-ollama ollama create finance-assistant < Modelfile
```

## การ Monitor และ Debug

### ดู Logs
```bash
# ดู logs ของ Ollama
docker logs n8n-ollama

# ดู logs แบบ real-time
docker logs -f n8n-ollama
```

### ตรวจสอบ Performance
```bash
# ดู resource usage
docker stats n8n-ollama

# ดูข้อมูล model
curl http://localhost:11434/api/show -d '{
  "name": "llama3.2"
}'
```

### Debug Workflow
```javascript
// เพิ่มใน Code Node เพื่อ debug
console.log('Request to Ollama:', JSON.stringify($json, null, 2));

// ตรวจสอบ response
if (!$json.response) {
  throw new Error('No response from Ollama');
}

console.log('Ollama Response:', $json.response);
```

## การแก้ไขปัญหา

### Ollama ไม่ทำงาน
```bash
# ตรวจสอบสถานะ container
docker ps | grep ollama

# รีสตาร์ท Ollama
docker restart n8n-ollama

# ตรวจสอบ logs
docker logs n8n-ollama
```

### Model ไม่โหลด
```bash
# ตรวจสอบพื้นที่ disk
df -h

# ตรวจสอบ RAM
free -h

# ลองดาวน์โหลดใหม่
docker exec n8n-ollama ollama pull llama3.2
```

### Response ช้า
1. **ลด Model Size**: ใช้ 3B แทน 7B
2. **ลด Max Tokens**: จาก 2000 เป็น 500
3. **เพิ่ม RAM**: อย่างน้อย 16GB
4. **ใช้ GPU**: เร็วกว่า CPU มาก

### Out of Memory
```bash
# ตรวจสอบ memory usage
docker stats

# ใช้ model เล็กกว่า
docker exec n8n-ollama ollama pull llama3.2:1b
```

## การปรับแต่งขั้นสูง

### GPU Support (NVIDIA)
```yaml
# เพิ่มใน docker-compose.yml
ollama:
  image: ollama/ollama:latest
  deploy:
    resources:
      reservations:
        devices:
          - driver: nvidia
            count: 1
            capabilities: [gpu]
```

### Custom Environment Variables
```yaml
# เพิ่มใน docker-compose.yml
environment:
  - OLLAMA_HOST=0.0.0.0
  - OLLAMA_ORIGINS=*
  - OLLAMA_NUM_PARALLEL=4
  - OLLAMA_MAX_LOADED_MODELS=2
  - OLLAMA_FLASH_ATTENTION=1
```

### Load Balancing
```yaml
# หลาย Ollama instances
ollama-1:
  image: ollama/ollama:latest
  ports: ["11434:11434"]
  
ollama-2:
  image: ollama/ollama:latest
  ports: ["11435:11434"]
```

### Persistent Models
```yaml
# เก็บ models ไว้ใน host
volumes:
  - ./ollama-models:/root/.ollama
```

## Security Best Practices

### Network Security
```yaml
# จำกัดการเข้าถึง
ollama:
  ports:
    - "127.0.0.1:11434:11434"  # localhost only
```

### API Authentication
```javascript
// เพิ่ม API key check ใน n8n
const apiKey = $json.headers['x-api-key'];
if (apiKey !== process.env.OLLAMA_API_KEY) {
  throw new Error('Unauthorized');
}
```

### Rate Limiting
```javascript
// จำกัดจำนวน requests
const rateLimiter = global.get('rateLimiter') || {};
const clientIP = $json.headers['x-forwarded-for'] || 'unknown';
const now = Date.now();

if (rateLimiter[clientIP] && now - rateLimiter[clientIP] < 5000) {
  throw new Error('Rate limit exceeded');
}

rateLimiter[clientIP] = now;
global.set('rateLimiter', rateLimiter);
```

## Performance Optimization

### Model Selection Strategy
```javascript
// เลือก model ตามความซับซ้อนของงาน
function selectModel(taskComplexity, responseTime) {
  if (taskComplexity === 'simple' && responseTime === 'fast') {
    return 'llama3.2:1b';
  } else if (taskComplexity === 'medium') {
    return 'llama3.2:3b';
  } else if (taskComplexity === 'complex') {
    return 'llama3.1:8b';
  }
  return 'llama3.2';
}
```

### Caching Responses
```javascript
// Cache คำตอบที่ซ้ำ
const cacheKey = require('crypto')
  .createHash('md5')
  .update(JSON.stringify($json))
  .digest('hex');

const cached = global.get(`cache_${cacheKey}`);
if (cached && Date.now() - cached.timestamp < 3600000) { // 1 hour
  return cached.response;
}
```

### Batch Processing
```javascript
// ประมวลผลหลายคำถามพร้อมกัน
const questions = $json.questions || [];
const promises = questions.map(async (question) => {
  // Call Ollama API
  return await callOllama(question);
});

const responses = await Promise.all(promises);
```

## Monitoring และ Analytics

### Usage Metrics
```javascript
// เก็บสถิติการใช้งาน
const stats = global.get('ollamaStats') || {
  totalRequests: 0,
  totalTokens: 0,
  averageResponseTime: 0,
  modelUsage: {}
};

stats.totalRequests++;
stats.modelUsage[$json.model] = (stats.modelUsage[$json.model] || 0) + 1;

global.set('ollamaStats', stats);
```

### Health Check
```javascript
// ตรวจสอบสุขภาพของ Ollama
const healthCheck = async () => {
  try {
    const response = await fetch('http://ollama:11434/api/tags');
    return response.ok;
  } catch (error) {
    return false;
  }
};
```

## การขยายระบบ

### Microservices Architecture
```yaml
# แยก services
services:
  ollama-chat:
    image: ollama/ollama:latest
    environment:
      - OLLAMA_MODELS=llama3.2,phi3
      
  ollama-code:
    image: ollama/ollama:latest
    environment:
      - OLLAMA_MODELS=codellama,deepseek-coder
      
  ollama-translate:
    image: ollama/ollama:latest
    environment:
      - OLLAMA_MODELS=llama3.1:8b
```

### Auto Scaling
```bash
# ใช้ Docker Swarm หรือ Kubernetes
docker service create \
  --name ollama-cluster \
  --replicas 3 \
  --publish 11434:11434 \
  ollama/ollama:latest
```

---

## สรุป

Ollama + n8n เป็นการผสมที่ทรงพลังสำหรับการสร้าง AI Workflows ที่:
- **ปลอดภัย**: ข้อมูลไม่ออกจากระบบ
- **ประหยัด**: ไม่มีค่า API
- **ยืดหยุ่น**: ปรับแต่งได้ตามต้องการ
- **เสถียร**: ไม่พึ่งพา External Services

เหมาะสำหรับองค์กรที่ต้องการความเป็นส่วนตัวและการควบคุมข้อมูลสูง