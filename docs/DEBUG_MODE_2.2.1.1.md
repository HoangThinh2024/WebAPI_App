# 🔍 Debug Mode - v2.2.1.1

## ⚠️ Issues Reported

1. **"Không có dữ liệu ứng viên"** - CandidateDetail component shows empty state
2. **"Lịch sử trao đổi đưa ra số tin nhắn hiện có chứ không có nội dung tin nhắn"** - MessagesList shows count but no content

---

## 🔧 Debug Features Added

### 1. Console Logging in App.vue

Added comprehensive logging to trace data flow:

```javascript
// In openCandidate() function
console.log('🔍 Detail Response:', detailResp.data)
console.log('🔍 Messages Response:', messagesResp.data)
console.log('✅ Parsed Candidate Data:', candidateData)
console.log('✅ Parsed Messages List:', messagesList)
```

**Purpose:** See exact API response structure and parsed data

---

### 2. Debug Panels in Components

#### CandidateDetail.vue

Added expandable debug panel in empty state:

```vue
<details style="margin-top: 1rem;">
  <summary>🔍 Debug: Click để xem data</summary>
  <pre>{{ JSON.stringify(candidate, null, 2) }}</pre>
</details>
```

**Shows:** Complete candidate object with all properties

#### MessagesList.vue

Added expandable debug panel in empty state:

```vue
<details style="margin-top: 1rem;">
  <summary>🔍 Debug: Click để xem messages data</summary>
  <pre>{{ JSON.stringify(messages, null, 2) }}</pre>
</details>
```

**Shows:** Complete messages array with all items

---

### 3. Improved Data Parsing

#### Enhanced Candidate Data Extraction

```javascript
// Old (simple)
const candidateData = detailResp.data?.data || detailResp.data || {}

// New (multiple fallback paths)
let candidateData = detailResp.data
if (candidateData?.data) {
  candidateData = candidateData.data
}
if (candidateData?.candidate) {
  candidateData = candidateData.candidate
}
```

**Handles:**
- `{ data: {...} }`
- `{ data: { candidate: {...} } }`
- `{ candidate: {...} }`
- `{...}` (direct object)

#### Enhanced Messages Data Extraction

```javascript
// Old (limited formats)
if (Array.isArray(messagesData)) {...}
else if (messagesData.messages) {...}

// New (multiple formats)
let messagesData = messagesResp.data
if (messagesData?.data) {
  messagesData = messagesData.data
}

let messagesList = []
if (Array.isArray(messagesData)) {
  messagesList = messagesData
} else if (messagesData?.messages) {
  messagesList = messagesData.messages
} else if (messagesData?.data) {
  messagesList = messagesData.data
} else if (messagesData?.list) {
  messagesList = messagesData.list
}
```

**Handles:**
- `[...]` (direct array)
- `{ data: [...] }`
- `{ messages: [...] }`
- `{ data: { messages: [...] } }`
- `{ list: [...] }`

---

### 4. Fixed Display Condition

#### CandidateDetail.vue

**Before:**
```vue
<div v-else-if="candidate.id" class="detail-content">
```

**Issue:** If API doesn't return `id` field, component shows empty state

**After:**
```vue
<div v-else-if="candidate && Object.keys(candidate).length > 0 && !candidate.error" class="detail-content">
```

**Benefits:**
- Checks if candidate object exists
- Checks if candidate has any properties
- Checks if candidate is not an error object

---

## 📋 Testing Guide

### Step 1: Open Browser Console

1. Navigate to http://localhost:5173
2. Press **F12** to open DevTools
3. Click **Console** tab
4. Keep console visible

### Step 2: Test Candidate Detail

1. Load openings and candidates
2. Click **"Xem chi tiết"** on any candidate
3. Modal opens

**Check Console Output:**
```
🔍 Detail Response: {...}
🔍 Messages Response: {...}
✅ Parsed Candidate Data: {...}
✅ Parsed Messages List: [...]
```

### Step 3: Analyze Results

#### Scenario A: Data Shows Correctly ✅

**Console:**
```javascript
✅ Parsed Candidate Data: {
  id: 12345,
  full_name: "John Doe",
  email: "john@example.com",
  // ... more fields
}
```

**Modal:**
- Shows candidate avatar, name, email, phone
- Info sections populated with data
- Skills tags visible
- Social links working

**Result:** Everything works! 🎉

---

#### Scenario B: Empty Candidate Data ❌

**Console:**
```javascript
✅ Parsed Candidate Data: {}
// OR
✅ Parsed Candidate Data: null
```

**Modal:**
- Shows "⚠️ Không có dữ liệu ứng viên"
- Debug panel available

**Action:**
1. Click **"🔍 Debug: Click để xem data"**
2. See raw candidate object
3. Screenshot console + debug panel
4. Send to developer

**Possible Causes:**
- API endpoint not returning data
- Unexpected response structure
- Authentication issue
- Candidate ID not found

---

#### Scenario C: Empty Messages ❌

**Console:**
```javascript
✅ Parsed Messages List: []
```

**Modal (Messages Tab):**
- Shows "💬 Chưa có tin nhắn nào"
- Shows "Received: 0 messages"
- Debug panel available

**Action:**
1. Switch to **"💬 Tin nhắn"** tab
2. Click **"🔍 Debug: Click để xem messages data"**
3. Screenshot debug panel
4. Check console for `🔍 Messages Response`

**Possible Causes:**
- No messages for this candidate (legitimate empty state)
- API endpoint returning wrong structure
- Messages nested deeper than expected

---

#### Scenario D: Messages Data Exists But Not Displaying ❌

**Console:**
```javascript
🔍 Messages Response: {
  data: {
    items: [
      { id: 1, content: "Hello" },
      { id: 2, content: "Hi" }
    ]
  }
}
✅ Parsed Messages List: []  // <-- Empty!
```

**Issue:** Data exists but parsing failed

**Action:**
1. Note the exact structure in console
2. Developer will add support for this structure

---

## 🔍 Console Output Analysis

### Example 1: Nested Candidate Data

**Raw Response:**
```json
{
  "status": "success",
  "data": {
    "candidate": {
      "id": 12345,
      "full_name": "Nguyễn Văn A",
      "email": "nguyenvana@example.com"
    }
  }
}
```

**Current Parsing:**
```javascript
// Step 1: detailResp.data
candidateData = { status: "success", data: {...} }

// Step 2: candidateData?.data
candidateData = { candidate: {...} }

// Step 3: candidateData?.candidate
candidateData = { id: 12345, full_name: "...", ... }
```

**Result:** ✅ Parsed correctly!

---

### Example 2: Direct Messages Array

**Raw Response:**
```json
{
  "messages": [
    {
      "id": 1,
      "sender_name": "Admin",
      "content": "Welcome",
      "created_at": 1697500000
    }
  ]
}
```

**Current Parsing:**
```javascript
// Step 1: messagesResp.data
messagesData = { messages: [...] }

// Step 2: messagesData?.data (null, skip)

// Step 3: Check formats
if (messagesData?.messages) {
  messagesList = messagesData.messages  // ✅ Found!
}
```

**Result:** ✅ Parsed correctly!

---

### Example 3: Unknown Structure (Needs Fix)

**Raw Response:**
```json
{
  "success": true,
  "result": {
    "items": [
      { "id": 1, "text": "Hello" }
    ]
  }
}
```

**Current Parsing:**
```javascript
// Step 1: messagesResp.data
messagesData = { success: true, result: {...} }

// Step 2: messagesData?.data (null)

// Step 3: Check formats
// ❌ None match! messagesList = []
```

**Fix Needed:** Add support for `result.items` structure

---

## 🛠️ Troubleshooting

### Issue: Console shows "undefined"

**Problem:** API call failed

**Check:**
1. Backend server running? (http://localhost:3000)
2. Access token valid?
3. Network tab in DevTools - see error?

---

### Issue: Console shows error message

**Example:**
```
🔍 Detail Response: { error: "Unauthorized" }
```

**Solution:**
- Token expired → Re-save token
- Wrong token → Check token value
- Backend error → Check backend logs

---

### Issue: Debug panel shows `null` or `{}`

**Causes:**
1. API returned empty data
2. Candidate doesn't exist
3. Permission denied

**Verify:**
- Can you see this candidate in the table?
- Does clicking other candidates work?
- Check backend API directly with curl/Postman

---

## 📊 Common Response Structures

Based on typical Base.vn API patterns:

### Candidate Detail

**Option 1: Direct**
```json
{
  "id": 123,
  "full_name": "Name",
  ...
}
```

**Option 2: Wrapped in data**
```json
{
  "data": {
    "id": 123,
    "full_name": "Name",
    ...
  }
}
```

**Option 3: Nested**
```json
{
  "data": {
    "candidate": {
      "id": 123,
      "full_name": "Name",
      ...
    }
  }
}
```

---

### Messages

**Option 1: Direct array**
```json
[
  { "id": 1, "content": "..." },
  { "id": 2, "content": "..." }
]
```

**Option 2: Wrapped**
```json
{
  "messages": [...]
}
```

**Option 3: Nested**
```json
{
  "data": {
    "messages": [...]
  }
}
```

---

## 📝 Next Steps

### After Testing

1. **Copy console output** (all 4 log lines)
2. **Screenshot debug panels** (if empty state)
3. **Note which scenario** (A, B, C, or D from above)
4. **Share with developer**

### Developer Will

1. Analyze exact response structure
2. Update parsing logic if needed
3. Add support for new formats
4. Re-test and confirm fix

---

## 🎯 Success Criteria

✅ **Console shows:**
- Valid data in `🔍 Detail Response`
- Valid data in `🔍 Messages Response`
- Parsed objects with properties
- No error messages

✅ **Modal shows:**
- Candidate name, email, phone
- Info sections with real data
- Messages with content (not just count)
- No empty states

✅ **Debug panels:**
- Not needed (data displays correctly)
- Or shows valid JSON structure

---

## 📞 Support

If issues persist:

1. **Collect logs:**
   - Console output (all 4 lines)
   - Debug panel content
   - Network tab (XHR requests)

2. **Describe behavior:**
   - What you see vs what you expect
   - Which candidate ID tested
   - Any error messages

3. **Share details:**
   - Backend API version
   - Sample API response (anonymized)
   - Screenshots

---

**Version:** 2.2.1.1 (Debug)  
**Date:** October 17, 2025  
**Purpose:** Diagnose data parsing issues  
**Status:** 🔍 Testing Required
