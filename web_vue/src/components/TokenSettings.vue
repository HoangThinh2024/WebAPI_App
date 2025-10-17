<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useTokenManager } from '../composables/useTokenManager.js'

const props = defineProps({
  accessToken: {
    type: String,
    default: ''
  },
  apiBase: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:accessToken', 'tokenSaved', 'tokenCleared'])

const tokenManager = useTokenManager()
const showSettings = ref(false)
const tokenInfo = ref(null)
const expiryHours = ref(24)
const showTokenPreview = ref(false)

// Auto-refresh token info mỗi 10 giây
let refreshInterval = null

function refreshTokenInfo() {
  tokenInfo.value = tokenManager.getTokenInfo()
}

function handleSaveToken() {
  try {
    const result = tokenManager.saveToken(
      props.accessToken,
      props.apiBase,
      expiryHours.value
    )

    refreshTokenInfo()
    emit('tokenSaved', result)

    alert(
      `✅ Đã lưu token!\n\n` +
        `🔐 Mã hóa: ${result.encrypted ? 'Bật' : 'Tắt'}\n` +
        `⏰ Hết hạn sau: ${expiryHours.value} giờ\n` +
        `📅 Thời gian: ${new Date(result.expiryTime).toLocaleString('vi-VN')}`
    )
  } catch (error) {
    alert('❌ Lỗi: ' + error.message)
  }
}

function handleClearToken() {
  if (confirm('🗑️ Bạn có chắc muốn xóa token?')) {
    tokenManager.clearToken()
    refreshTokenInfo()
    emit('update:accessToken', '')
    emit('tokenCleared')
    alert('✅ Đã xóa token!')
  }
}

function handleClearAll() {
  if (confirm('⚠️ Xóa TẤT CẢ dữ liệu bao gồm cài đặt?\n\nHành động này không thể hoàn tác!')) {
    tokenManager.clearAll()
    refreshTokenInfo()
    emit('update:accessToken', '')
    emit('tokenCleared')
    alert('✅ Đã xóa tất cả dữ liệu!')
  }
}

function handleToggleEncryption() {
  tokenManager.toggleEncryption()
  refreshTokenInfo()
  alert(
    tokenManager.encryptionEnabled.value
      ? '🔐 Đã BẬT mã hóa token'
      : '🔓 Đã TẮT mã hóa token'
  )
}

function handleLoadToken() {
  const token = tokenManager.getToken()
  if (token) {
    emit('update:accessToken', token)
    alert('✅ Đã tải token từ localStorage!')
  } else {
    alert('❌ Không tìm thấy token hoặc token đã hết hạn!')
  }
}

const statusColor = computed(() => {
  if (!tokenInfo.value?.hasToken) return '#999'
  if (tokenInfo.value?.expired) return '#ff4757'
  if (tokenInfo.value?.timeRemaining && tokenInfo.value.timeRemaining < 3600000) {
    return '#ffa502' // < 1h
  }
  return '#2ecc71'
})

const statusText = computed(() => {
  if (!tokenInfo.value?.hasToken) return 'Chưa lưu token'
  if (tokenInfo.value?.expired) return 'Token đã hết hạn'
  return `Còn ${tokenInfo.value?.timeRemainingFormatted}`
})

onMounted(() => {
  refreshTokenInfo()
  // Refresh mỗi 10 giây
  refreshInterval = setInterval(refreshTokenInfo, 10000)
})

onUnmounted(() => {
  if (refreshInterval) {
    clearInterval(refreshInterval)
  }
})
</script>

<template>
  <div class="token-settings">
    <!-- Status Bar -->
    <div class="token-status" :style="{ borderLeftColor: statusColor }">
      <div class="status-content">
        <span class="status-icon">🔑</span>
        <div class="status-info">
          <div class="status-label">Token Status</div>
          <div class="status-text" :style="{ color: statusColor }">
            {{ statusText }}
          </div>
          <div v-if="tokenInfo?.hasToken" class="token-meta">
            <span v-if="tokenInfo.encrypted" class="badge badge-success">🔐 Đã mã hóa</span>
            <span v-else class="badge badge-warning">🔓 Không mã hóa</span>
          </div>
        </div>
      </div>
      <button
        class="toggle-btn"
        @click="showSettings = !showSettings"
        :title="showSettings ? 'Ẩn cài đặt' : 'Hiện cài đặt'"
      >
        {{ showSettings ? '▲' : '▼' }}
      </button>
    </div>

    <!-- Settings Panel -->
    <div v-if="showSettings" class="settings-panel">
      <!-- Token Preview -->
      <div v-if="tokenInfo?.hasToken" class="setting-group">
        <div class="setting-label">
          <span>Token Preview</span>
          <button
            class="link-btn"
            @click="showTokenPreview = !showTokenPreview"
          >
            {{ showTokenPreview ? '🙈 Ẩn' : '👁️ Hiện' }}
          </button>
        </div>
        <div v-if="showTokenPreview" class="token-preview">
          {{ tokenInfo.tokenPreview }}
        </div>
      </div>

      <!-- Expiry Settings -->
      <div class="setting-group">
        <label class="setting-label">⏰ Token hết hạn sau (giờ)</label>
        <input
          type="number"
          v-model.number="expiryHours"
          min="1"
          max="720"
          step="1"
          class="setting-input"
          placeholder="24"
        />
        <div class="setting-hint">
          Mặc định: 24 giờ. Tối đa: 720 giờ (30 ngày)
        </div>
      </div>

      <!-- Encryption Toggle -->
      <div class="setting-group">
        <div class="setting-checkbox">
          <label>
            <input
              type="checkbox"
              :checked="tokenManager.encryptionEnabled.value"
              @change="handleToggleEncryption"
            />
            <span>🔐 Mã hóa token bằng AES-256</span>
          </label>
        </div>
        <div class="setting-hint">
          Khuyến nghị: BẬT để tăng bảo mật trong LocalStorage
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="action-grid">
        <button
          @click="handleSaveToken"
          :disabled="!accessToken"
          class="btn btn-primary"
          title="Lưu token với cài đặt hiện tại"
        >
          💾 Lưu Token
        </button>

        <button
          @click="handleLoadToken"
          :disabled="!tokenInfo?.hasToken"
          class="btn btn-secondary"
          title="Tải token đã lưu vào form"
        >
          📥 Tải Token
        </button>

        <button
          @click="handleClearToken"
          :disabled="!tokenInfo?.hasToken"
          class="btn btn-warning"
          title="Xóa token đã lưu"
        >
          🗑️ Xóa Token
        </button>

        <button
          @click="handleClearAll"
          class="btn btn-danger"
          title="Xóa tất cả dữ liệu"
        >
          ⚠️ Xóa Tất Cả
        </button>
      </div>

      <!-- Info Box -->
      <div class="info-box">
        <div class="info-title">📌 Lưu ý bảo mật</div>
        <ul class="info-list">
          <li>Token được lưu trong <strong>LocalStorage</strong> của trình duyệt</li>
          <li>Bật mã hóa để tăng bảo mật (khuyến nghị)</li>
          <li>Token sẽ tự động hết hạn sau thời gian đã cài đặt</li>
          <li>Xóa cache trình duyệt sẽ xóa token đã lưu</li>
          <li>Không chia sẻ token với người khác</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<style scoped>
.token-settings {
  margin-bottom: 1rem;
  border-radius: 8px;
  overflow: hidden;
  background: var(--card-bg, #fff);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.token-status {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem;
  border-left: 4px solid #999;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  transition: all 0.3s ease;
}

.token-status:hover {
  background: linear-gradient(135deg, #e9ecef 0%, #dee2e6 100%);
}

.status-content {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex: 1;
}

.status-icon {
  font-size: 2rem;
  line-height: 1;
}

.status-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.status-label {
  font-size: 0.75rem;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-weight: 600;
}

.status-text {
  font-size: 1rem;
  font-weight: 600;
}

.token-meta {
  display: flex;
  gap: 0.5rem;
  margin-top: 0.25rem;
}

.badge {
  display: inline-block;
  padding: 0.15rem 0.5rem;
  font-size: 0.7rem;
  font-weight: 600;
  border-radius: 12px;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.badge-success {
  background: #d4edda;
  color: #155724;
}

.badge-warning {
  background: #fff3cd;
  color: #856404;
}

.toggle-btn {
  padding: 0.5rem 1rem;
  background: rgba(0, 0, 0, 0.05);
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: bold;
  transition: all 0.2s ease;
}

.toggle-btn:hover {
  background: rgba(0, 0, 0, 0.1);
  transform: translateY(-1px);
}

.settings-panel {
  padding: 1.5rem;
  border-top: 1px solid #e0e0e0;
  background: #fafafa;
  animation: slideDown 0.3s ease;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.setting-group {
  margin-bottom: 1.5rem;
}

.setting-group:last-child {
  margin-bottom: 0;
}

.setting-label {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: #333;
}

.setting-input {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.2s ease;
}

.setting-input:focus {
  outline: none;
  border-color: #007bff;
}

.setting-checkbox label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  padding: 0.75rem;
  background: white;
  border-radius: 6px;
  border: 2px solid #ddd;
  transition: all 0.2s ease;
}

.setting-checkbox label:hover {
  border-color: #007bff;
  background: #f0f8ff;
}

.setting-checkbox input[type="checkbox"] {
  width: 1.2rem;
  height: 1.2rem;
  cursor: pointer;
}

.setting-hint {
  font-size: 0.85rem;
  color: #666;
  margin-top: 0.5rem;
  font-style: italic;
}

.token-preview {
  padding: 0.75rem;
  background: #fff;
  border: 2px dashed #007bff;
  border-radius: 6px;
  font-family: 'Courier New', monospace;
  font-size: 0.9rem;
  color: #007bff;
  word-break: break-all;
}

.link-btn {
  background: none;
  border: none;
  color: #007bff;
  cursor: pointer;
  font-size: 0.9rem;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  transition: all 0.2s ease;
}

.link-btn:hover {
  background: rgba(0, 123, 255, 0.1);
}

.action-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.btn {
  padding: 0.75rem 1rem;
  border: none;
  border-radius: 6px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  text-align: center;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-primary {
  background: #007bff;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #0056b3;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 123, 255, 0.3);
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

.btn-secondary:hover:not(:disabled) {
  background: #545b62;
  transform: translateY(-2px);
}

.btn-warning {
  background: #ffc107;
  color: #000;
}

.btn-warning:hover:not(:disabled) {
  background: #e0a800;
  transform: translateY(-2px);
}

.btn-danger {
  background: #dc3545;
  color: white;
}

.btn-danger:hover:not(:disabled) {
  background: #c82333;
  transform: translateY(-2px);
}

.info-box {
  padding: 1rem;
  background: #e7f3ff;
  border-left: 4px solid #007bff;
  border-radius: 6px;
}

.info-title {
  font-weight: 700;
  margin-bottom: 0.75rem;
  color: #007bff;
}

.info-list {
  margin: 0;
  padding-left: 1.5rem;
  font-size: 0.9rem;
  color: #333;
}

.info-list li {
  margin-bottom: 0.5rem;
  line-height: 1.5;
}

.info-list li:last-child {
  margin-bottom: 0;
}

/* Responsive */
@media (max-width: 768px) {
  .token-status {
    padding: 0.75rem;
  }

  .status-icon {
    font-size: 1.5rem;
  }

  .settings-panel {
    padding: 1rem;
  }

  .action-grid {
    grid-template-columns: 1fr;
  }
}
</style>
