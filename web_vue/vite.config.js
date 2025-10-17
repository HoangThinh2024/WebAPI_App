import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vite.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173,
    host: '0.0.0.0', // Listen on all network interfaces
    strictPort: false,
    cors: true,
    proxy: {
      '/api': {
        target: process.env.VITE_API_TARGET || 'http://localhost:3000',
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api/, '/api'),
        configure: (proxy, options) => {
          proxy.on('error', (err, req, res) => {
            console.log('Proxy error:', err)
          })
          proxy.on('proxyReq', (proxyReq, req, res) => {
            // Log proxy requests for debugging
            if (process.env.DEBUG) {
              console.log('Proxying:', req.method, req.url, '->', options.target + req.url)
            }
          })
        }
      }
    },
    // Network access configuration
    hmr: {
      host: 'localhost', // Use localhost for HMR to avoid network issues
      protocol: 'ws'
    }
  },
  preview: {
    port: 4173,
    host: true,
    strictPort: false
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    minify: 'terser',
    chunkSizeWarningLimit: 1000,
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['vue', 'axios']
        }
      }
    }
  }
})
