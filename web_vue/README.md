# web_vue

Vue 3 + Vite frontend cho Base.vn Candidate Explorer

## Cài đặt

```bash
npm install
```

## Chạy Development Server

```bash
npm run dev
```

Server sẽ chạy tại: http://localhost:5173

## Build cho Production

```bash
npm run build
```

## Preview Production Build

```bash
npm run preview
```

## Cấu trúc

- `src/App.vue` - Component chính
- `src/main.js` - Entry point
- `src/style.css` - Global styles
- `vite.config.js` - Cấu hình Vite (bao gồm proxy đến FastAPI backend)

## Yêu cầu

- Node.js 18+ hoặc mới hơn
- FastAPI backend chạy tại http://127.0.0.1:8000
