<script setup>
import { ref, computed, watch } from 'vue'
import axios from 'axios'

const cachedBase = localStorage.getItem('LOCAL_PROXY_URL')

const defaultApiBase = (() => {
  if (cachedBase && cachedBase.includes('8000')) {
    return 'http://localhost:3000/api'
  }
  if (cachedBase) {
    return cachedBase
  }
  if (typeof window !== 'undefined' && window.location.origin.includes('localhost:5173')) {
    return 'http://localhost:3000/api'
  }
  return '/api'
})()

const apiBase = ref(defaultApiBase)
const accessToken = ref(localStorage.getItem('BASE_TOKEN') || '')
const openings = ref([])
const selectedOpeningId = ref('')
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
  loading: false,
  candidateId: null,
  detailJson: '',
  messagesJson: ''
})

const sanitizedApiBase = computed(() => {
  const base = apiBase.value || ''
  return base.endsWith('/') ? base.slice(0, -1) : base
})

const backendStatusLabel = computed(() => sanitizedApiBase.value || 'Chưa cấu hình')

const stageOptions = computed(() => {
  const currentOpening = openings.value.find(
    (op) => String(op.id) === String(selectedOpeningId.value)
  )
  if (!currentOpening || !Array.isArray(currentOpening.stages)) {
    return []
  }
  return currentOpening.stages.map((stage) => ({
    id: String(stage?.id ?? ''),
    name: stage?.name || `Stage ${stage?.id}`
  }))
})

watch(selectedOpeningId, (newId) => {
  filters.value.opening_id = newId ? String(newId) : ''
  const firstStage = stageOptions.value[0]
  if (firstStage) {
    filters.value.stage = firstStage.id
  } else {
    filters.value.stage = ''
  }
  filters.value.page = 1
})

function buildUrl(path) {
  return `${sanitizedApiBase.value}${path}`
}

function saveLocal() {
  localStorage.setItem('BASE_TOKEN', accessToken.value)
  localStorage.setItem('LOCAL_PROXY_URL', sanitizedApiBase.value)
  alert('Đã lưu Access Token và Backend URL vào LocalStorage.')
}

async function loadOpenings() {
  if (!accessToken.value) {
    alert('Vui lòng nhập Access Token trước khi tải openings.')
    return
  }

  loading.value.openings = true
  try {
    const resp = await axios.post(buildUrl('/openings'), {
      access_token: accessToken.value,
      page: 1,
      num_per_page: 100,
      order_by: 'starred'
    })

    if (!resp.data?.success) {
      throw new Error(resp.data?.error || 'Không thể lấy danh sách openings.')
    }

    const openingsList = Array.isArray(resp.data.openings) ? resp.data.openings : []
    openings.value = openingsList

    if (openingsList.length) {
      selectedOpeningId.value = String(openingsList[0]?.id ?? '')
    } else {
      selectedOpeningId.value = ''
    }
  } catch (error) {
    console.error(error)
    const message = error?.response?.data?.error || error.message || 'Không thể lấy danh sách openings.'
    alert(message)
  } finally {
    loading.value.openings = false
  }
}

async function fetchCandidates() {
  if (!accessToken.value || !filters.value.opening_id) {
    alert('Vui lòng nhập token và chọn opening.')
    return
  }

  loading.value.candidates = true
  try {
    const resp = await axios.post(buildUrl('/candidates'), {
      access_token: accessToken.value,
      opening_id: filters.value.opening_id,
      page: filters.value.page,
      num_per_page: filters.value.num_per_page,
      stage: filters.value.stage
    })

    if (!resp.data?.success) {
      throw new Error(resp.data?.error || 'Không thể lấy danh sách ứng viên.')
    }

    metrics.value = resp.data.metrics || null
    candidates.value = Array.isArray(resp.data.candidates_table) ? resp.data.candidates_table : []
    rawJson.value = JSON.stringify(resp.data.raw || resp.data, null, 2)
  } catch (error) {
    console.error(error)
    const message = error?.response?.data?.error || error.message || 'Không thể lấy danh sách ứng viên.'
    alert(message)
  } finally {
    loading.value.candidates = false
  }
}

async function openCandidate(id) {
  if (!id) {
    return
  }

  modal.value.open = true
  modal.value.loading = true
  modal.value.candidateId = id
  modal.value.detailJson = ''
  modal.value.messagesJson = ''

  try {
    const [detailResp, messagesResp] = await Promise.all([
      axios.post(buildUrl(`/candidate/${id}`), {
        access_token: accessToken.value
      }),
      axios.post(buildUrl(`/candidate/${id}/messages`), {
        access_token: accessToken.value
      })
    ])

    modal.value.detailJson = JSON.stringify(detailResp.data?.data || detailResp.data || {}, null, 2)
    modal.value.messagesJson = JSON.stringify(
      messagesResp.data?.data || messagesResp.data || {},
      null,
      2
    )
  } catch (error) {
    console.error(error)
    const message = error?.response?.data?.error || error.message || 'Không thể tải thông tin ứng viên.'
    modal.value.detailJson = message
    modal.value.messagesJson = message
  } finally {
    modal.value.loading = false
  }
}

function resetResults() {
  metrics.value = null
  candidates.value = []
  rawJson.value = ''
  modal.value.open = false
  modal.value.loading = false
  modal.value.candidateId = null
  modal.value.detailJson = ''
  modal.value.messagesJson = ''
}

if (accessToken.value) {
  loadOpenings()
}
</script>

<template>
  <div class="container">
    <div class="header">
      <div class="title">🎯 Ứng dụng Truy vấn Base.vn (Vue + Vite)</div>
      <div class="caption">Theo dõi ứng viên, xem chi tiết và lịch sử trao đổi một cách trực quan.</div>
      <div class="status">Backend API: {{ backendStatusLabel }}</div>
    </div>

    <div class="row">
      <div class="card" style="min-width:340px;">
        <h3>🔑 Tham số API</h3>
        <label>Access Token</label>
        <input v-model.trim="accessToken" placeholder="Nhập BASE_TOKEN" />
        <label>Backend API URL</label>
        <input v-model.trim="apiBase" placeholder="http://localhost:3000/api" />
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
        <select v-model="selectedOpeningId">
          <option v-for="opening in openings" :key="opening.id" :value="String(opening.id)">
            {{ opening.id }} - {{ opening.name || 'N/A' }}
          </option>
        </select>

        <label>Chọn Stage</label>
        <template v-if="stageOptions.length">
          <select v-model="filters.stage">
            <option v-for="stage in stageOptions" :key="stage.id" :value="stage.id">
              {{ stage.name }}
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
        <div class="table-container">
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Tên</th>
                <th>Email</th>
                <th class="hide-mobile">Số điện thoại</th>
                <th class="hide-mobile">Stage</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in candidates" :key="row.id">
                <td>{{ row.id }}</td>
                <td>{{ row.full_name || row.name }}</td>
                <td>{{ row.email }}</td>
                <td class="hide-mobile">{{ row.phone }}</td>
                <td class="hide-mobile">{{ row.stage_name || filters.stage || '-' }}</td>
                <td>
                  <button
                    @click="openCandidate(row.id)"
                    class="warn"
                    :disabled="row.id === undefined || row.id === null || row.id === '' || modal.loading"
                  >
                    Xem chi tiết
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
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
        <div class="status" v-if="modal.loading">Đang tải dữ liệu ứng viên...</div>
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
