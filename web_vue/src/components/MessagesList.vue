<script setup>
import { computed } from 'vue'
import { sanitizeHTML } from '../utils/sanitizer'

const props = defineProps({
  messages: {
    type: Array,
    default: () => []
  },
  loading: {
    type: Boolean,
    default: false
  }
})

const messagesList = computed(() => {
  if (!Array.isArray(props.messages)) return []
  // Sort by 'since' (Base.vn) or 'created_at'
  return props.messages.sort((a, b) => {
    const timeA = a.since || a.created_at || 0
    const timeB = b.since || b.created_at || 0
    return timeB - timeA
  })
})

const formatDate = (timestamp) => {
  if (!timestamp) return 'N/A'
  const date = new Date(timestamp * 1000)
  const now = new Date()
  const diff = now - date
  
  // Less than 1 minute
  if (diff < 60000) {
    return 'Vừa xong'
  }
  
  // Less than 1 hour
  if (diff < 3600000) {
    const minutes = Math.floor(diff / 60000)
    return `${minutes} phút trước`
  }
  
  // Less than 24 hours
  if (diff < 86400000) {
    const hours = Math.floor(diff / 3600000)
    return `${hours} giờ trước`
  }
  
  // Less than 7 days
  if (diff < 604800000) {
    const days = Math.floor(diff / 86400000)
    return `${days} ngày trước`
  }
  
  // Full date
  return date.toLocaleString('vi-VN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getMessageTypeIcon = (type) => {
  const iconMap = {
    'email': '📧',
    'sms': '💬',
    'call': '📞',
    'note': '📝',
    'comment': '💭',
    'internal': '🔒',
    'system': '⚙️'
  }
  return iconMap[type?.toLowerCase()] || '📨'
}

const getMessageTypeColor = (type) => {
  const colorMap = {
    'email': '#3498db',
    'sms': '#9b59b6',
    'call': '#27ae60',
    'note': '#f39c12',
    'comment': '#e74c3c',
    'internal': '#95a5a6',
    'system': '#34495e'
  }
  return colorMap[type?.toLowerCase()] || '#3498db'
}

const getSenderInitials = (name) => {
  if (!name) return '?'
  const parts = name.trim().split(' ')
  if (parts.length === 1) return parts[0].charAt(0).toUpperCase()
  return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase()
}

const messageGroups = computed(() => {
  const groups = {}
  messagesList.value.forEach(msg => {
    const timestamp = msg.since || msg.created_at
    if (!timestamp) return
    
    const date = new Date(timestamp * 1000)
    const dateKey = date.toLocaleDateString('vi-VN', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
    
    if (!groups[dateKey]) {
      groups[dateKey] = []
    }
    groups[dateKey].push(msg)
  })
  return groups
})
</script>

<template>
  <div class="messages-list">
    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Đang tải tin nhắn...</p>
    </div>

    <!-- Messages Content -->
    <div v-else-if="messagesList.length" class="messages-content">
      <div class="messages-header">
        <h3>💬 Lịch sử trao đổi</h3>
        <span class="message-count">{{ messagesList.length }} tin nhắn</span>
      </div>

      <!-- Group by date -->
      <div v-for="(msgs, date) in messageGroups" :key="date" class="message-group">
        <div class="date-divider">
          <span>{{ date }}</span>
        </div>

        <div class="message-item" v-for="message in msgs" :key="message.id">
          <!-- Message Header -->
          <div class="message-header">
            <div class="sender-info">
              <div class="sender-avatar">
                <img 
                  v-if="message.sender_avatar" 
                  :src="message.sender_avatar" 
                  :alt="message.sender_name"
                  @error="(e) => e.target.style.display = 'none'"
                />
                <div v-else class="avatar-placeholder">
                  {{ getSenderInitials(message.user?.name || message.sender_name || message.from_name || message.user_name) }}
                </div>
              </div>
              <div class="sender-details">
                <div class="sender-name">
                  {{ message.user?.name || message.sender_name || message.from_name || message.user_name || 'Hệ thống' }}
                </div>
                <div class="message-meta">
                  <span class="message-type" :style="{ color: getMessageTypeColor(message.type || message.metatype) }">
                    {{ getMessageTypeIcon(message.type || message.metatype) }}
                    {{ message.type || message.metatype || 'Email' }}
                  </span>
                  <span class="message-time">{{ formatDate(message.since || message.created_at) }}</span>
                </div>
              </div>
            </div>
            <div class="message-actions" v-if="message.is_read !== undefined">
              <span v-if="message.is_read" class="read-status read">✓✓ Đã đọc</span>
              <span v-else class="read-status unread">✓ Đã gửi</span>
            </div>
          </div>

          <!-- Message Subject -->
          <div v-if="message.subject" class="message-subject">
            <strong>{{ message.subject }}</strong>
          </div>

          <!-- Message Body -->
          <div class="message-body">
            <!-- Base.vn uses 'body' and 'content' fields with HTML - Sanitized for XSS protection -->
            <div v-if="message.body" v-html="sanitizeHTML(message.body)" class="html-content"></div>
            <div v-else-if="message.content" v-html="sanitizeHTML(message.content)" class="html-content"></div>
            <div v-else-if="message.body_html" v-html="sanitizeHTML(message.body_html)" class="html-content"></div>
            <div v-else-if="message.message" class="text-content">{{ message.message }}</div>
            <div v-else class="text-content empty">Không có nội dung</div>
          </div>

          <!-- Message Attachments -->
          <div v-if="message.attachments && message.attachments.length" class="message-attachments">
            <div class="attachments-header">📎 Tệp đính kèm ({{ message.attachments.length }})</div>
            <div class="attachments-list">
              <a 
                v-for="(attachment, index) in message.attachments" 
                :key="index"
                :href="attachment.url || attachment.file_url"
                target="_blank"
                rel="noopener noreferrer"
                class="attachment-link"
              >
                <span class="attachment-icon">📄</span>
                <span class="attachment-name">{{ attachment.name || attachment.filename || `File ${index + 1}` }}</span>
                <span class="attachment-size" v-if="attachment.size">
                  {{ (attachment.size / 1024).toFixed(1) }} KB
                </span>
              </a>
            </div>
          </div>

          <!-- Message Footer (optional info) -->
          <div v-if="message.to_email || message.to_phone" class="message-footer">
            <span v-if="message.to_email" class="recipient">
              Đến: {{ message.to_email }}
            </span>
            <span v-if="message.to_phone" class="recipient">
              SĐT: {{ message.to_phone }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="empty-state">
      <div class="empty-icon">💬</div>
      <p>Chưa có tin nhắn nào</p>
      <p style="font-size: 0.9rem; color: #666; margin-top: 0.5rem;">
        Received: {{ Array.isArray(messages) ? messages.length : 0 }} messages
      </p>
      
      <!-- Debug Info (remove in production) -->
      <details style="margin-top: 1rem; text-align: left; font-size: 0.85rem;">
        <summary style="cursor: pointer; color: #666;">🔍 Debug: Click để xem messages data</summary>
        <pre style="background: #f5f5f5; padding: 1rem; border-radius: 4px; overflow: auto; max-height: 200px;">{{ JSON.stringify(messages, null, 2) }}</pre>
      </details>
    </div>
  </div>
</template>

<style scoped>
.messages-list {
  width: 100%;
  min-height: 300px;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  color: #666;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #9b59b6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.messages-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.messages-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-bottom: 1rem;
  border-bottom: 2px solid #e0e0e0;
}

.messages-header h3 {
  margin: 0;
  color: #2c3e50;
  font-size: 1.25rem;
}

.message-count {
  background: #9b59b6;
  color: white;
  padding: 0.35rem 0.85rem;
  border-radius: 16px;
  font-size: 0.85rem;
  font-weight: 600;
}

.message-group {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.date-divider {
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 1rem 0 0.5rem 0;
}

.date-divider span {
  background: #f8f9fa;
  padding: 0.5rem 1.5rem;
  border-radius: 20px;
  font-size: 0.85rem;
  color: #666;
  font-weight: 600;
  border: 1px solid #e0e0e0;
}

.message-item {
  background: white;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  padding: 1.25rem;
  transition: all 0.2s ease;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.message-item:hover {
  border-color: #9b59b6;
  box-shadow: 0 4px 12px rgba(155, 89, 182, 0.1);
  transform: translateY(-1px);
}

.message-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 0.75rem;
  gap: 1rem;
}

.sender-info {
  display: flex;
  gap: 0.75rem;
  align-items: flex-start;
  flex: 1;
}

.sender-avatar {
  flex-shrink: 0;
}

.sender-avatar img {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid #9b59b6;
}

.avatar-placeholder {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1rem;
  font-weight: bold;
  border: 2px solid #9b59b6;
}

.sender-details {
  flex: 1;
}

.sender-name {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.25rem;
}

.message-meta {
  display: flex;
  gap: 0.75rem;
  align-items: center;
  font-size: 0.85rem;
}

.message-type {
  font-weight: 500;
}

.message-time {
  color: #999;
}

.message-actions {
  flex-shrink: 0;
}

.read-status {
  font-size: 0.8rem;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-weight: 500;
}

.read-status.read {
  background: #d4edda;
  color: #155724;
}

.read-status.unread {
  background: #fff3cd;
  color: #856404;
}

.message-subject {
  padding: 0.75rem;
  background: #f8f9fa;
  border-left: 3px solid #9b59b6;
  margin-bottom: 0.75rem;
  border-radius: 4px;
}

.message-body {
  padding: 0.75rem 0;
  line-height: 1.6;
  color: #333;
}

.html-content {
  word-wrap: break-word;
}

.html-content :deep(a) {
  color: #007bff;
  text-decoration: underline;
}

.text-content {
  white-space: pre-wrap;
  word-wrap: break-word;
}

.text-content.empty {
  color: #999;
  font-style: italic;
}

.message-attachments {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #e0e0e0;
}

.attachments-header {
  font-size: 0.9rem;
  font-weight: 600;
  color: #666;
  margin-bottom: 0.75rem;
}

.attachments-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.attachment-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem;
  background: #f8f9fa;
  border: 1px solid #ddd;
  border-radius: 6px;
  text-decoration: none;
  color: #333;
  transition: all 0.2s ease;
}

.attachment-link:hover {
  border-color: #9b59b6;
  background: #f3e5f5;
}

.attachment-icon {
  font-size: 1.25rem;
}

.attachment-name {
  flex: 1;
  font-size: 0.9rem;
}

.attachment-size {
  font-size: 0.8rem;
  color: #666;
}

.message-footer {
  margin-top: 0.75rem;
  padding-top: 0.75rem;
  border-top: 1px solid #f0f0f0;
  font-size: 0.85rem;
  color: #666;
  display: flex;
  gap: 1rem;
}

.recipient {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  color: #999;
}

.empty-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
  opacity: 0.5;
}

/* Responsive */
@media (max-width: 768px) {
  .message-header {
    flex-direction: column;
    gap: 0.75rem;
  }

  .message-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.25rem;
  }

  .message-footer {
    flex-direction: column;
    gap: 0.5rem;
  }
}
</style>
