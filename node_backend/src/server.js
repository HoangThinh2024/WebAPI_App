const express = require('express');
const cors = require('cors');
const axios = require('axios');
const qs = require('qs');
const dotenv = require('dotenv');

dotenv.config();

const PORT = Number(process.env.PORT || 3000);
const API_TIMEOUT_MS = Number(process.env.API_TIMEOUT_MS || 30000);
const LOG_LEVEL = (process.env.LOG_LEVEL || 'info').toLowerCase();
const CORS_ALLOWED_ORIGINS = process.env.CORS_ALLOWED_ORIGINS
  ? process.env.CORS_ALLOWED_ORIGINS.split(',').map((origin) => origin.trim()).filter(Boolean)
  : true;

const BASE_HEADERS = {
  'Content-Type': 'application/x-www-form-urlencoded',
  Accept: '*/*',
  'Accept-Encoding': 'gzip, deflate, br',
  'User-Agent': 'BaseVN-Node-Proxy/1.0',
  Connection: 'keep-alive',
};

const ENDPOINTS = {
  openingsList: 'https://hiring.base.vn/publicapi/v2/opening/list',
  openingDetail: 'https://hiring.base.vn/publicapi/v2/opening/get',
  candidatesList: 'https://hiring.base.vn/publicapi/v2/candidate/list',
  candidateDetail: 'https://hiring.base.vn/publicapi/v2/candidate/get',
  candidateMessages: 'https://hiring.base.vn/publicapi/v2/candidate/messages',
};

const app = express();

app.use(cors({
  origin: CORS_ALLOWED_ORIGINS,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

function log(message, meta) {
  if (LOG_LEVEL === 'silent') {
    return;
  }
  const payload = meta ? `${message} ${JSON.stringify(meta)}` : message;
  console.log(payload);
}

function getParam(req, key, fallback) {
  const bodyValue = req.body && req.body[key] !== undefined ? req.body[key] : undefined;
  if (bodyValue !== undefined && bodyValue !== null && bodyValue !== '') {
    return bodyValue;
  }
  const queryValue = req.query && req.query[key] !== undefined ? req.query[key] : undefined;
  if (queryValue !== undefined && queryValue !== null && queryValue !== '') {
    return queryValue;
  }
  return fallback;
}

async function postForm(url, payload, description) {
  try {
    const response = await axios.post(url, qs.stringify(payload), {
      headers: BASE_HEADERS,
      timeout: API_TIMEOUT_MS,
    });
    log(`Proxy success: ${description}`, { status: response.status });
    return response.data || {};
  } catch (error) {
    log(`Proxy error: ${description}`, { message: error.message });
    throw error;
  }
}

function extractAxiosError(error) {
  if (!axios.isAxiosError(error)) {
    return {
      status: 500,
      message: error.message || 'Unexpected server error',
    };
  }

  const status = error.response?.status || 500;
  const responseData = error.response?.data;
  const message = responseData?.message
    || responseData?.error
    || error.message
    || 'Unexpected API error';

  return {
    status,
    message,
    details: responseData,
  };
}

function buildCandidateMetrics(rawData, defaults) {
  const total = rawData?.total;
  const count = rawData?.count;
  const page = rawData?.page;
  const numPerPage = rawData?.num_per_page;
  return {
    total: total !== undefined ? total : null,
    count: count !== undefined ? count : null,
    page: page !== undefined ? page : defaults.page,
    num_per_page: numPerPage !== undefined ? numPerPage : defaults.num_per_page,
  };
}

function buildCandidateTable(rawCandidates) {
  if (!Array.isArray(rawCandidates)) {
    return [];
  }
  return rawCandidates.map((candidate) => ({
    id: candidate?.id ?? null,
    full_name: candidate?.name ?? '',
    email: candidate?.email ?? '',
    phone: candidate?.phone ?? '',
    stage_id: candidate?.stage ?? null,
    stage_name: candidate?.stage_name ?? '',
    opening_id: candidate?.opening_id ?? null,
    opening_name: candidate?.opening_export?.name ?? '',
    source: candidate?.source ?? '',
    cv_link: Array.isArray(candidate?.cvs) && candidate.cvs.length > 0 ? candidate.cvs[0] : null,
  }));
}

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

app.post('/api/openings', async (req, res) => {
  const accessToken = getParam(req, 'access_token');
  if (!accessToken) {
    return res.status(400).json({ success: false, error: 'Parameter "access_token" is required.' });
  }

  const page = Number(getParam(req, 'page', 1));
  const numPerPage = Number(getParam(req, 'num_per_page', 50));
  const orderBy = getParam(req, 'order_by', 'starred');

  try {
    const payload = {
      access_token: accessToken,
      page,
      num_per_page: numPerPage,
      order_by: orderBy,
    };

    const data = await postForm(ENDPOINTS.openingsList, payload, 'opening/list');

    return res.json({
      success: true,
      openings: Array.isArray(data?.openings) ? data.openings : [],
      pagination: {
        page: data?.page ?? page,
        num_per_page: data?.num_per_page ?? numPerPage,
        total: data?.total ?? null,
        count: data?.count ?? null,
      },
      raw: data,
    });
  } catch (error) {
    const err = extractAxiosError(error);
    return res.status(err.status).json({ success: false, error: err.message, details: err.details });
  }
});

app.post('/api/openings/:id', async (req, res) => {
  const accessToken = getParam(req, 'access_token');
  const openingId = req.params.id || getParam(req, 'id');
  if (!accessToken || !openingId) {
    return res.status(400).json({ success: false, error: 'Parameters "access_token" and "id" are required.' });
  }

  try {
    const payload = {
      access_token: accessToken,
      id: openingId,
    };
    const data = await postForm(ENDPOINTS.openingDetail, payload, 'opening/get');
    return res.json({ success: true, data });
  } catch (error) {
    const err = extractAxiosError(error);
    return res.status(err.status).json({ success: false, error: err.message, details: err.details });
  }
});

app.post('/api/candidates', async (req, res) => {
  const accessToken = getParam(req, 'access_token');
  const openingId = getParam(req, 'opening_id');
  if (!accessToken || !openingId) {
    return res.status(400).json({ success: false, error: 'Parameters "access_token" and "opening_id" are required.' });
  }

  const page = Number(getParam(req, 'page', 1));
  const numPerPage = Number(getParam(req, 'num_per_page', 50));
  const stage = getParam(req, 'stage', '');

  try {
    const payload = {
      access_token: accessToken,
      opening_id: openingId,
      page,
      num_per_page: numPerPage,
      stage,
    };

    const data = await postForm(ENDPOINTS.candidatesList, payload, 'candidate/list');
    const metrics = buildCandidateMetrics(data, { page, num_per_page: numPerPage });
    const candidatesTable = buildCandidateTable(data?.candidates);

    return res.json({
      success: true,
      metrics,
      candidates_table: candidatesTable,
      raw: data,
    });
  } catch (error) {
    const err = extractAxiosError(error);
    return res.status(err.status).json({ success: false, error: err.message, details: err.details });
  }
});

app.post('/api/candidate/:id', async (req, res) => {
  const accessToken = getParam(req, 'access_token');
  const candidateId = req.params.id || getParam(req, 'id');
  if (!accessToken || !candidateId) {
    return res.status(400).json({ success: false, error: 'Parameters "access_token" and "id" are required.' });
  }

  try {
    const payload = {
      access_token: accessToken,
      id: candidateId,
    };
    const data = await postForm(ENDPOINTS.candidateDetail, payload, 'candidate/get');
    return res.json({ success: true, data });
  } catch (error) {
    const err = extractAxiosError(error);
    return res.status(err.status).json({ success: false, error: err.message, details: err.details });
  }
});

app.post('/api/candidate/:id/messages', async (req, res) => {
  const accessToken = getParam(req, 'access_token');
  const candidateId = req.params.id || getParam(req, 'id');
  if (!accessToken || !candidateId) {
    return res.status(400).json({ success: false, error: 'Parameters "access_token" and "id" are required.' });
  }

  try {
    const payload = {
      access_token: accessToken,
      id: candidateId,
    };
    const data = await postForm(ENDPOINTS.candidateMessages, payload, 'candidate/messages');
    return res.json({ success: true, data });
  } catch (error) {
    const err = extractAxiosError(error);
    return res.status(err.status).json({ success: false, error: err.message, details: err.details });
  }
});

app.use((_, res) => {
  res.status(404).json({ success: false, error: 'Route not found' });
});

app.listen(PORT, '0.0.0.0', () => {
  log(`Node backend listening on 0.0.0.0:${PORT}`);
  log(`Access from other devices: http://YOUR_IP:${PORT}`);
});
