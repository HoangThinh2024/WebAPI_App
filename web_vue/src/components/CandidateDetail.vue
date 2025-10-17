<script setup>
import { computed } from 'vue'

const props = defineProps({
  data: {
    type: Object,
    default: () => ({})
  },
  loading: {
    type: Boolean,
    default: false
  }
})

const candidate = computed(() => props.data || {})

const formatDate = (timestamp) => {
  if (!timestamp) return 'N/A'
  const date = new Date(timestamp * 1000)
  return date.toLocaleString('vi-VN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatSalary = (salary) => {
  if (!salary) return 'Thỏa thuận'
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(salary)
}

const getStatusColor = (status) => {
  const statusMap = {
    'new': '#3498db',
    'screening': '#f39c12',
    'interview': '#9b59b6',
    'offer': '#27ae60',
    'hired': '#2ecc71',
    'rejected': '#e74c3c',
    'archived': '#95a5a6'
  }
  return statusMap[status?.toLowerCase()] || '#34495e'
}

const socialLinks = computed(() => {
  const links = []
  if (candidate.value.facebook) {
    links.push({ name: 'Facebook', url: candidate.value.facebook, icon: '📘' })
  }
  if (candidate.value.linkedin) {
    links.push({ name: 'LinkedIn', url: candidate.value.linkedin, icon: '💼' })
  }
  if (candidate.value.github) {
    links.push({ name: 'GitHub', url: candidate.value.github, icon: '🐙' })
  }
  if (candidate.value.website) {
    links.push({ name: 'Website', url: candidate.value.website, icon: '🌐' })
  }
  return links
})

const attachments = computed(() => {
  // Handle both 'cvs' (Base.vn format) and 'attachments' fields
  const cvs = candidate.value.cvs || candidate.value.attachments
  if (!cvs || !Array.isArray(cvs)) {
    return []
  }
  
  return cvs.map((item, index) => {
    if (typeof item === 'string') {
      // Direct URL string
      const fileName = item.split('/').pop() || `CV_${index + 1}.pdf`
      return {
        name: fileName,
        url: item,
        size: 'N/A'
      }
    }
    // Object with name, url, size
    return item
  })
})

const customFields = computed(() => {
  if (!candidate.value.custom_fields || typeof candidate.value.custom_fields !== 'object') {
    return []
  }
  return Object.entries(candidate.value.custom_fields)
    .filter(([key, value]) => value !== null && value !== undefined && value !== '')
    .map(([key, value]) => ({
      key: key.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
      value: String(value)
    }))
})
</script>

<template>
  <div class="candidate-detail">
    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Đang tải thông tin ứng viên...</p>
    </div>

    <!-- Candidate Info -->
    <div v-else-if="candidate && Object.keys(candidate).length > 0 && !candidate.error" class="detail-content">
      <!-- Header Section -->
      <div class="detail-header">
        <div class="candidate-avatar">
          <img 
            v-if="candidate.avatar || candidate.photo_url" 
            :src="candidate.avatar || candidate.photo_url" 
            :alt="candidate.name"
            @error="(e) => e.target.src = 'https://ui-avatars.com/api/?name=' + encodeURIComponent(candidate.name || 'User')"
          />
          <div v-else class="avatar-placeholder">
            {{ (candidate.name || candidate.first_name || 'U').charAt(0).toUpperCase() }}
          </div>
        </div>
        <div class="candidate-header-info">
          <h2>{{ candidate.name || (candidate.first_name + ' ' + candidate.last_name) || 'N/A' }}</h2>
          <div class="meta-info">
            <span v-if="candidate.email" class="meta-item">
              📧 {{ candidate.email }}
            </span>
            <span v-if="candidate.phone" class="meta-item">
              📱 {{ candidate.phone }}
            </span>
            <span v-if="candidate.stage_name" class="meta-item badge" :style="{ background: getStatusColor(candidate.stage_name) }">
              {{ candidate.stage_name }}
            </span>
            <span v-if="candidate.status" class="meta-item badge" :style="{ background: getStatusColor(candidate.status) }">
              {{ candidate.status }}
            </span>
          </div>
        </div>
      </div>

      <!-- Info Grid -->
      <div class="info-section">
        <h3>📋 Thông tin cơ bản</h3>
        <div class="info-grid">
          <div class="info-item" v-if="candidate.id">
            <span class="label">ID:</span>
            <span class="value">{{ candidate.id }}</span>
          </div>
          <div class="info-item" v-if="candidate.dob || candidate.birthday">
            <span class="label">Ngày sinh:</span>
            <span class="value">{{ candidate.dob || candidate.birthday }}</span>
          </div>
          <div class="info-item" v-if="candidate.gender || candidate.gender_text">
            <span class="label">Giới tính:</span>
            <span class="value">{{ candidate.gender_text || (candidate.gender === 'male' || candidate.gender === '1' ? 'Nam' : candidate.gender === 'female' || candidate.gender === '2' ? 'Nữ' : candidate.gender) }}</span>
          </div>
          <div class="info-item" v-if="candidate.address">
            <span class="label">Địa chỉ:</span>
            <span class="value">{{ candidate.address }}</span>
          </div>
          <div class="info-item" v-if="candidate.city">
            <span class="label">Thành phố:</span>
            <span class="value">{{ candidate.city }}</span>
          </div>
          <div class="info-item" v-if="candidate.country">
            <span class="label">Quốc gia:</span>
            <span class="value">{{ candidate.country }}</span>
          </div>
        </div>
      </div>

      <!-- Work Info -->
      <div class="info-section" v-if="candidate.current_company || candidate.current_position || candidate.expected_salary">
        <h3>💼 Thông tin nghề nghiệp</h3>
        <div class="info-grid">
          <div class="info-item" v-if="candidate.current_company">
            <span class="label">Công ty hiện tại:</span>
            <span class="value">{{ candidate.current_company }}</span>
          </div>
          <div class="info-item" v-if="candidate.current_position">
            <span class="label">Vị trí hiện tại:</span>
            <span class="value">{{ candidate.current_position }}</span>
          </div>
          <div class="info-item" v-if="candidate.years_of_experience">
            <span class="label">Kinh nghiệm:</span>
            <span class="value">{{ candidate.years_of_experience }} năm</span>
          </div>
          <div class="info-item" v-if="candidate.expected_salary">
            <span class="label">Mức lương mong muốn:</span>
            <span class="value">{{ formatSalary(candidate.expected_salary) }}</span>
          </div>
          <div class="info-item" v-if="candidate.education">
            <span class="label">Học vấn:</span>
            <span class="value">{{ candidate.education }}</span>
          </div>
        </div>
      </div>

      <!-- Skills -->
      <div class="info-section" v-if="candidate.skills && candidate.skills.length">
        <h3>⚡ Kỹ năng</h3>
        <div class="skills-container">
          <span v-for="skill in candidate.skills" :key="skill" class="skill-tag">
            {{ skill }}
          </span>
        </div>
      </div>

      <!-- Languages -->
      <div class="info-section" v-if="candidate.languages && candidate.languages.length">
        <h3>🌍 Ngôn ngữ</h3>
        <div class="skills-container">
          <span v-for="lang in candidate.languages" :key="lang" class="skill-tag language-tag">
            {{ lang }}
          </span>
        </div>
      </div>

      <!-- Social Links -->
      <div class="info-section" v-if="socialLinks.length">
        <h3>🔗 Liên kết</h3>
        <div class="social-links">
          <a 
            v-for="link in socialLinks" 
            :key="link.name" 
            :href="link.url" 
            target="_blank" 
            rel="noopener noreferrer"
            class="social-link"
          >
            <span class="icon">{{ link.icon }}</span>
            <span>{{ link.name }}</span>
          </a>
        </div>
      </div>

      <!-- Cover Letter / Note -->
      <div class="info-section" v-if="candidate.cover_letter || candidate.note">
        <h3>📝 Thư xin việc / Ghi chú</h3>
        <div class="text-content">
          {{ candidate.cover_letter || candidate.note }}
        </div>
      </div>

      <!-- Attachments -->
      <div class="info-section" v-if="attachments.length">
        <h3>📎 Tệp đính kèm</h3>
        <div class="attachments-list">
          <a 
            v-for="(attachment, index) in attachments" 
            :key="index"
            :href="attachment.url || attachment.file_url"
            target="_blank"
            rel="noopener noreferrer"
            class="attachment-item"
          >
            <span class="attachment-icon">📄</span>
            <span class="attachment-name">{{ attachment.name || attachment.filename || `File ${index + 1}` }}</span>
            <span class="attachment-size" v-if="attachment.size">
              {{ (attachment.size / 1024).toFixed(2) }} KB
            </span>
          </a>
        </div>
      </div>

      <!-- Custom Fields -->
      <div class="info-section" v-if="customFields.length">
        <h3>🔧 Thông tin bổ sung</h3>
        <div class="info-grid">
          <div class="info-item" v-for="field in customFields" :key="field.key">
            <span class="label">{{ field.key }}:</span>
            <span class="value">{{ field.value }}</span>
          </div>
        </div>
      </div>

      <!-- Timestamps -->
      <div class="info-section">
        <h3>⏰ Thời gian</h3>
        <div class="info-grid">
          <div class="info-item" v-if="candidate.created_at">
            <span class="label">Ngày tạo:</span>
            <span class="value">{{ formatDate(candidate.created_at) }}</span>
          </div>
          <div class="info-item" v-if="candidate.updated_at">
            <span class="label">Cập nhật lần cuối:</span>
            <span class="value">{{ formatDate(candidate.updated_at) }}</span>
          </div>
          <div class="info-item" v-if="candidate.applied_at">
            <span class="label">Ngày ứng tuyển:</span>
            <span class="value">{{ formatDate(candidate.applied_at) }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Error State -->
    <div v-else class="error-state">
      <div class="error-icon">⚠️</div>
      <p v-if="candidate?.error">{{ candidate.error }}</p>
      <p v-else>Không có dữ liệu ứng viên</p>
      
      <!-- Debug Info (remove in production) -->
      <details style="margin-top: 1rem; text-align: left; font-size: 0.85rem;">
        <summary style="cursor: pointer; color: #666;">🔍 Debug: Click để xem data</summary>
        <pre style="background: #f5f5f5; padding: 1rem; border-radius: 4px; overflow: auto; max-height: 200px;">{{ JSON.stringify(candidate, null, 2) }}</pre>
      </details>
    </div>
  </div>
</template>

<style scoped>
.candidate-detail {
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
  border-top: 4px solid #007bff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.detail-content {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.detail-header {
  display: flex;
  gap: 1.5rem;
  align-items: flex-start;
  padding-bottom: 1.5rem;
  border-bottom: 2px solid #e0e0e0;
}

.candidate-avatar {
  flex-shrink: 0;
}

.candidate-avatar img {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid #007bff;
}

.avatar-placeholder {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 2.5rem;
  font-weight: bold;
  border: 3px solid #007bff;
}

.candidate-header-info {
  flex: 1;
}

.candidate-header-info h2 {
  margin: 0 0 0.75rem 0;
  color: #2c3e50;
  font-size: 1.75rem;
}

.meta-info {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: center;
}

.meta-item {
  font-size: 0.9rem;
  color: #666;
}

.meta-item.badge {
  padding: 0.35rem 0.85rem;
  border-radius: 16px;
  color: white;
  font-weight: 600;
  font-size: 0.85rem;
}

.info-section {
  background: #f8f9fa;
  padding: 1.25rem;
  border-radius: 8px;
  border-left: 4px solid #007bff;
}

.info-section h3 {
  margin: 0 0 1rem 0;
  color: #2c3e50;
  font-size: 1.1rem;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-item .label {
  font-size: 0.85rem;
  color: #666;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.info-item .value {
  font-size: 1rem;
  color: #2c3e50;
  word-break: break-word;
}

.skills-container {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.skill-tag {
  padding: 0.5rem 1rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 500;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s ease;
}

.skill-tag:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.language-tag {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.social-links {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.social-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  background: white;
  border: 2px solid #007bff;
  border-radius: 8px;
  text-decoration: none;
  color: #007bff;
  font-weight: 500;
  transition: all 0.2s ease;
}

.social-link:hover {
  background: #007bff;
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 123, 255, 0.3);
}

.social-link .icon {
  font-size: 1.25rem;
}

.text-content {
  background: white;
  padding: 1rem;
  border-radius: 6px;
  border: 1px solid #ddd;
  white-space: pre-wrap;
  line-height: 1.6;
  color: #333;
}

.attachments-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.attachment-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem;
  background: white;
  border: 1px solid #ddd;
  border-radius: 6px;
  text-decoration: none;
  color: #333;
  transition: all 0.2s ease;
}

.attachment-item:hover {
  border-color: #007bff;
  background: #f0f8ff;
  transform: translateX(4px);
}

.attachment-icon {
  font-size: 1.5rem;
}

.attachment-name {
  flex: 1;
  font-weight: 500;
}

.attachment-size {
  font-size: 0.85rem;
  color: #666;
}

.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem;
  color: #999;
}

.error-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

/* Responsive */
@media (max-width: 768px) {
  .detail-header {
    flex-direction: column;
    text-align: center;
  }

  .candidate-avatar {
    margin: 0 auto;
  }

  .meta-info {
    justify-content: center;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }

  .candidate-header-info h2 {
    font-size: 1.5rem;
  }
}
</style>
