<script setup>
import { ref, computed } from 'vue'
import axios from 'axios'

const apiBase = ref(localStorage.getItem('LOCAL_PROXY_URL') || 'http://127.0.0.1:8000')
const accessToken = ref(localStorage.getItem('BASE_TOKEN') || '')
const openings = ref({})
const selectedOpeningKey = ref('')
const filters = ref({
  opening_id: '',
  stage: '',
  page: 1,
  num_per_page: 50
})
const candidates = ref([])
const metrics = ref(null)
const rawJson = ref('')
const loading = ref({
  openings: false,
  candidates: false
})
const modal = ref({
  open: false,
  candidateId: null,
  detailJson: '',
  messagesJson: ''
})

const stageOptions = computed(() => {
  if (!selectedOpeningKey.value) return {}
  const opening = openings.value[selectedOpeningKey.value] || {}
  const stages = opening.stages || []
  const options = {}
  stages.forEach(s => {
    options[s.id] = s.name || `Stage ${s.id}`
  })
  if (!filters.value.stage && stages.length) {
    filters.value.stage = String(stages[0].id)
  }
  return options
})

function saveLocal() {
  localStorage.setItem('BASE_TOKEN', accessToken.value)
  localStorage.setItem('LOCAL_PROXY_URL', apiBase.value)
  alert('Đã lưu BASE_TOKEN và LOCAL_PROXY_URL vào LocalStorage.')
}

async function loadOpenings() {
  if (!accessToken.value) return
  loading.value.openings = true
  try {
    const url = `${apiBase.value}/openings`
    const resp = await axios.post(url, null, {
      params: {
        access_token: accessToken.value,
        page: 1,
        num_per_page: 100,
        order_by: 'starred'
      }
    })
    const openingsList = resp.data.openings || []
    const map = {}
    openingsList.forEach(op => {
      map[`${op.id} - ${op.name || 'N/A'}`] = op
    })
    openings.value = map
    const firstKey = Object.keys(map)[0]
    if (firstKey) {
      selectedOpeningKey.value = firstKey
      filters.value.opening_id = String(map[firstKey].id)
    }
  } catch (e) {
    console.error(e)
    alert('Gặp lỗi khi lấy danh sách openings. Hãy đảm bảo FastAPI đang chạy.')
  } finally {
    loading.value.openings = false
  }
}

async function fetchCandidates() {
  if (!accessToken.value || !filters.value.opening_id || !filters.value.stage) {
    alert('Vui lòng nhập token, chọn opening và stage.')
    return
  }
  loading.value.candidates = true
  try {
    const url = `${apiBase.value}/candidates`
    const resp = await axios.post(url, null, {
      params: {
        access_token: accessToken.value,
        opening_id: filters.value.opening_id,
        page: filters.value.page,
        num_per_page: filters.value.num_per_page,
        stage: filters.value.stage
      }
    })
    metrics.value = resp.data.metrics || null
    candidates.value = resp.data.candidates_table || []
    rawJson.value = JSON.stringify(resp.data.raw || resp.data, null, 2)
  } catch (e) {
    console.error(e)
    alert('Lỗi khi lấy danh sách ứng viên.')
  } finally {
    loading.value.candidates = false
  }
}

async function openCandidate(id) {
  modal.value.open = true
  modal.value.candidateId = id
  try {
    const detail = await axios.post(`${apiBase.value}/candidate/${id}`, null, {
      params: { access_token: accessToken.value }
    })
    const messages = await axios.post(`${apiBase.value}/candidate/${id}/messages`, null, {
      params: { access_token: accessToken.value }
    })
    modal.value.detailJson = JSON.stringify(detail.data || {}, null, 2)
    modal.value.messagesJson = JSON.stringify(messages.data || {}, null, 2)
  } catch (e) {
    console.error(e)
    modal.value.detailJson = 'Lỗi khi lấy chi tiết ứng viên.'
    modal.value.messagesJson = 'Lỗi khi lấy tin nhắn ứng viên.'
  }
}

function resetResults() {
  metrics.value = null
  candidates.value = []
  rawJson.value = ''
}

// Auto-load on mount if token exists
if (accessToken.value) {
  loadOpenings()
}
</script>

<template>
  <div class="container">
    <div class="header">
      <div class="title">🎯 Ứng dụng Truy vấn Base.vn (Vue + Vite)</div>
      <div class="caption">Theo dõi ứng viên, xem chi tiết và lịch sử trao đổi một cách trực quan.</div>
      <div class="status">Backend API: {{ apiBase }}</div>
    </div>

    <div class="row">
      <div class="card" style="min-width:340px;">
        <h3>🔑 Tham số API</h3>
        <label>Access Token</label>
        <input v-model.trim="accessToken" placeholder="Nhập BASE_TOKEN" />
        <div class="toolbar">
          <button @click="loadOpenings" :disabled="loading.openings || !accessToken">
            🔄 Tải Openings
          </button>
          <button class="secondary" @click="saveLocal">💾 Lưu Token</button>
        </div>
        <div class="status" v-if="loading.openings">Đang tải danh sách openings...</div>
      </div>

      <div class="card">
        <h3>🗂️ Lọc danh sách ứng viên</h3>
        <label>Chọn Opening</label>
        <select v-model="selectedOpeningKey">
          <option v-for="(opening, key) in openings" :key="key" :value="key">
            {{ key }}
          </option>
        </select>

        <label>Chọn Stage</label>
        <template v-if="Object.keys(stageOptions).length">
          <select v-model="filters.stage">
            <option v-for="(id, name) in stageOptions" :key="id" :value="id">
              {{ name }}
            </option>
          </select>
        </template>
        <template v-else>
          <input v-model="filters.stage" placeholder="Nhập ID stage" />
        </template>

        <div class="row">
          <div style="flex:1; min-width:120px;">
            <label>Trang (page)</label>
            <input type="number" min="1" v-model.number="filters.page" />
          </div>
          <div style="flex:1; min-width:120px;">
            <label>Số lượng mỗi trang</label>
            <input type="number" min="1" max="100" v-model.number="filters.num_per_page" />
          </div>
        </div>
        <div class="toolbar">
          <button @click="fetchCandidates" :disabled="loading.candidates">
            🚀 Gửi yêu cầu API
          </button>
          <button class="secondary" @click="resetResults">♻️ Xóa kết quả</button>
        </div>
      </div>
    </div>

    <div class="row" v-if="metrics">
      <div class="card">
        <h3>📈 Thống kê</h3>
        <div class="metrics">
          <div class="metric" v-for="(v, k) in metrics" :key="k">
            <div class="label">{{ k }}</div>
            <div class="value">{{ v }}</div>
          </div>
        </div>
      </div>
    </div>

    <div class="row" v-if="candidates.length">
      <div class="card" style="flex:1 1 100%;">
        <h3>📋 Danh sách ứng viên ({{ candidates.length }})</h3>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Tên</th>
              <th>Email</th>
              <th>Số điện thoại</th>
              <th>Stage</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in candidates" :key="row.id">
              <td>{{ row.id }}</td>
              <td>{{ row.full_name || row.name }}</td>
              <td>{{ row.email }}</td>
              <td>{{ row.phone }}</td>
              <td>{{ row.stage_name || filters.stage }}</td>
              <td>
                <button
                  @click="openCandidate(row.id)"
                  class="warn"
                  :disabled="row.id === undefined || row.id === null || row.id === ''"
                >
                  Xem chi tiết
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div class="row" v-if="rawJson">
      <div class="card" style="flex:1 1 100%;">
        <h3>🧾 JSON phản hồi thô</h3>
        <div class="json">{{ rawJson }}</div>
      </div>
    </div>

    <div v-if="modal.open" class="modal-backdrop" @click.self="modal.open = false">
      <div class="modal">
        <div class="header">
          <h3>📁 Ứng viên #{{ modal.candidateId }}</h3>
          <button class="secondary" @click="modal.open = false">Đóng</button>
        </div>
        <div class="row">
          <div class="card">
            <h3>Chi tiết ứng viên</h3>
            <div class="json">{{ modal.detailJson }}</div>
          </div>
          <div class="card">
            <h3>Tin nhắn</h3>
            <div class="json">{{ modal.messagesJson }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
