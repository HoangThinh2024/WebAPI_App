# UI Update - Candidate Detail & Messages

## 📋 Thay đổi

### ❌ Đã xóa
- ~~JSON thô trong modal~~ → Thay bằng UI component
- ~~2 cột JSON side-by-side~~ → Tabs Detail/Messages
- ~~Raw text display~~ → Structured beautiful UI

### ✅ Đã thêm

#### 1. **CandidateDetail.vue Component**

**Features:**
- 👤 **Avatar Section**
  - Hiển thị ảnh ứng viên
  - Placeholder với initial nếu không có ảnh
  - Border gradient
  
- 📋 **Thông tin cơ bản**
  - ID, ngày sinh, giới tính
  - Địa chỉ, thành phố, quốc gia
  - Grid layout responsive

- 💼 **Thông tin nghề nghiệp**
  - Công ty hiện tại
  - Vị trí hiện tại
  - Kinh nghiệm (năm)
  - Mức lương mong muốn (VND format)
  - Học vấn

- ⚡ **Kỹ năng**
  - Tags với gradient background
  - Hover effect
  - Responsive wrap

- 🌍 **Ngôn ngữ**
  - Language tags
  - Different gradient color

- 🔗 **Social Links**
  - Facebook, LinkedIn, GitHub, Website
  - Icons với emoji
  - Hover effect với transform
  - Opens in new tab

- 📝 **Cover Letter/Note**
  - Pre-formatted text
  - White background box
  - Border style

- 📎 **Attachments**
  - File list với icons
  - File name và size
  - Download links
  - Hover effect

- 🔧 **Custom Fields**
  - Dynamic fields từ API
  - Label/value pairs
  - Grid layout

- ⏰ **Timestamps**
  - Created at
  - Updated at
  - Applied at
  - Vietnamese format

**Styling:**
- Modern card layout
- Section-based organization
- Icons for each section
- Gradient backgrounds
- Smooth animations
- Mobile responsive

---

#### 2. **MessagesList.vue Component**

**Features:**
- 💬 **Timeline View**
  - Messages grouped by date
  - Date dividers
  - Newest first

- 👤 **Sender Info**
  - Avatar or initials
  - Sender name
  - Message type (email, SMS, call, note)
  - Timestamp (relative: "5 phút trước", "2 giờ trước")

- 📧 **Message Types**
  - Email: 📧
  - SMS: 💬
  - Call: 📞
  - Note: 📝
  - Comment: 💭
  - Internal: 🔒
  - System: ⚙️
  - Color-coded by type

- 📝 **Message Content**
  - Subject line (if email)
  - HTML content support
  - Plain text fallback
  - Pre-formatted display

- 📎 **Attachments**
  - List in message
  - File icons
  - Download links
  - File size display

- ✓ **Read Status**
  - ✓✓ Đã đọc (green badge)
  - ✓ Đã gửi (yellow badge)

- 📊 **Metadata**
  - Recipient email
  - Recipient phone
  - Message footer

**Styling:**
- Card-based messages
- Hover effects
- Avatar circles
- Date dividers
- Smooth animations
- Mobile responsive
- Timeline flow

---

#### 3. **Modal Updates**

**New Structure:**
```
Modal
├── Header Bar (sticky)
│   ├── Title with icon
│   └── Close button (X)
├── Body (scrollable)
│   ├── Tabs
│   │   ├── 📋 Chi tiết
│   │   └── 💬 Tin nhắn
│   └── Tab Content
│       ├── CandidateDetail component
│       └── MessagesList component
```

**Features:**
- Tabs for switching views
- Sticky header
- Scrollable body
- Close button with rotate effect
- Larger width (1200px max)
- Better backdrop blur

---

#### 4. **App.vue Changes**

**Data Structure:**
```javascript
modal.value = {
  open: false,
  loading: false,
  candidateId: null,
  candidateData: null,    // Object
  messagesData: []        // Array
}
```

**API Response Handling:**
- Parse candidate detail object
- Parse messages array
- Handle different response formats:
  - `data.messages[]`
  - `data.data[]`
  - `data[]`

**JSON Raw Display:**
- Moved to collapsible `<details>`
- Hidden by default
- "Click để xem JSON (chỉ dành cho debug)"
- Only for debugging

---

## 🎨 Visual Improvements

### Before (v2.1.0)
```
┌─────────────────────────────────┐
│ Modal Header                    │
├────────────┬────────────────────┤
│ JSON       │ JSON               │
│ {          │ {                  │
│   "id":... │   "messages":[...] │
│   ...      │   ...              │
│ }          │ }                  │
└────────────┴────────────────────┘
```

### After (v2.2.0)
```
┌──────────────────────────────────┐
│ 👤 Thông tin ứng viên    [X]     │
├──────────────────────────────────┤
│ [📋 Chi tiết] [💬 Tin nhắn]      │
├──────────────────────────────────┤
│ ┌────────────────────────────┐   │
│ │ 👤 Avatar   John Doe       │   │
│ │    📧 john@example.com     │   │
│ ├────────────────────────────┤   │
│ │ 📋 Thông tin cơ bản        │   │
│ │ • ID: 12345                │   │
│ │ • Ngày sinh: 01/01/1990    │   │
│ ├────────────────────────────┤   │
│ │ ⚡ Kỹ năng                 │   │
│ │ [Vue] [React] [Node.js]    │   │
│ └────────────────────────────┘   │
└──────────────────────────────────┘
```

---

## 📊 Features Comparison

| Feature | v2.1.0 | v2.2.0 |
|---------|--------|--------|
| Display | JSON text | Structured UI |
| Layout | 2 columns | Tabs |
| Avatar | ❌ | ✅ |
| Skills tags | ❌ | ✅ Gradient |
| Social links | ❌ | ✅ Icons |
| Message timeline | ❌ | ✅ Grouped |
| Read status | ❌ | ✅ Badges |
| Attachments UI | ❌ | ✅ List |
| HTML content | ❌ | ✅ Rendered |
| Mobile friendly | ⚠️ Basic | ✅ Full |

---

## 🚀 Usage

### Xem chi tiết ứng viên

1. Click **"Xem chi tiết"** trên bất kỳ ứng viên nào
2. Modal sẽ mở với tab **📋 Chi tiết** active
3. Scroll để xem tất cả thông tin:
   - Avatar và tên
   - Email, phone, stage
   - Thông tin cơ bản (ID, ngày sinh, địa chỉ...)
   - Thông tin nghề nghiệp (công ty, vị trí, lương...)
   - Kỹ năng (tags)
   - Ngôn ngữ (tags)
   - Social links (Facebook, LinkedIn...)
   - Cover letter/Note
   - Attachments (download)
   - Custom fields
   - Timestamps

### Xem tin nhắn

1. Click tab **💬 Tin nhắn**
2. Xem timeline với:
   - Date dividers
   - Sender avatar/initials
   - Message type icon
   - Relative time ("5 phút trước")
   - Subject (nếu có)
   - Message content (HTML hoặc text)
   - Attachments (nếu có)
   - Read status

### Debug mode

1. Scroll xuống cuối trang
2. Tìm section **"🧾 JSON phản hồi thô"**
3. Click **"Click để xem JSON (chỉ dành cho debug)"**
4. Xem raw JSON response

---

## 📱 Responsive Design

### Desktop (> 768px)
- Modal: 1200px width
- 2-column info grid
- Full social links
- Large avatars

### Tablet (480px - 768px)
- Modal: 90% width
- 1-column info grid
- Stacked tabs
- Medium avatars

### Mobile (< 480px)
- Modal: 95% width
- Full-width tabs
- Single column layout
- Small avatars (60px)
- Condensed message cards

---

## 🎨 Styling Details

### Colors

**Candidate Detail:**
- Avatar border: `#007bff`
- Placeholder: Gradient `#667eea → #764ba2`
- Skills: Gradient `#667eea → #764ba2`
- Languages: Gradient `#f093fb → #f5576c`
- Sections: Left border `#007bff`

**Messages:**
- Email: `#3498db`
- SMS: `#9b59b6`
- Call: `#27ae60`
- Note: `#f39c12`
- Read status: `#2ecc71`
- Unread: `#ffa502`

### Animations

- **Modal:** slideUp (0.3s)
- **Tabs:** fadeIn (0.3s)
- **Cards:** Hover transform translateY(-2px)
- **Tags:** Hover transform translateY(-2px)
- **Links:** Hover transform translateY(-2px)
- **Spinner:** Rotate (1s infinite)

---

## 🔧 Technical Details

### Components

**CandidateDetail.vue:**
- Props: `data` (Object), `loading` (Boolean)
- Computed: `candidate`, `socialLinks`, `attachments`, `customFields`
- Methods: `formatDate()`, `formatSalary()`, `getStatusColor()`

**MessagesList.vue:**
- Props: `messages` (Array), `loading` (Boolean)
- Computed: `messagesList`, `messageGroups`
- Methods: `formatDate()`, `getMessageTypeIcon()`, `getMessageTypeColor()`, `getSenderInitials()`

**App.vue:**
- Import: CandidateDetail, MessagesList
- Modal data: `candidateData` (Object), `messagesData` (Array)
- Parse API responses with fallbacks

---

## 📝 Code Examples

### Candidate Detail Display

```vue
<CandidateDetail 
  :data="modal.candidateData" 
  :loading="modal.loading"
/>
```

### Messages Display

```vue
<MessagesList 
  :messages="modal.messagesData" 
  :loading="modal.loading"
/>
```

### Tab Switching (Vanilla JS)

```javascript
onclick="
  this.classList.add('active'); 
  this.nextElementSibling.classList.remove('active'); 
  this.parentElement.nextElementSibling.children[0].style.display='block'; 
  this.parentElement.nextElementSibling.children[1].style.display='none';
"
```

---

## ✅ Testing Checklist

- [x] Modal opens correctly
- [x] Tabs switch between Detail/Messages
- [x] Candidate avatar displays or shows placeholder
- [x] Skills render as gradient tags
- [x] Social links open in new tab
- [x] Attachments are downloadable
- [x] Messages grouped by date
- [x] Message types have correct icons
- [x] Read status badges display
- [x] HTML content renders safely
- [x] Mobile responsive layout works
- [x] Close button rotates on hover
- [x] Loading spinner shows during fetch
- [x] JSON debug view is collapsible

---

## 🚀 Next Improvements (Future)

- [ ] Add search in messages
- [ ] Filter messages by type
- [ ] Download all attachments (ZIP)
- [ ] Reply to message (if API supports)
- [ ] Mark as read/unread
- [ ] Print candidate detail
- [ ] Export to PDF
- [ ] Dark/Light mode toggle
- [ ] Custom avatar upload
- [ ] Edit candidate info inline
- [ ] Add new note/comment

---

**Version:** 2.2.0 (UI Update)  
**Date:** October 17, 2025  
**Status:** ✅ Complete  
**Components:** 2 new (CandidateDetail, MessagesList)  
**Lines:** ~800 (components) + ~150 (styles)
