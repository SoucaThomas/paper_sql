import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// dev: Vite on :5173 proxies API + websockets to the Bun server on :3000
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': 'http://localhost:3000',
      '/ws': { target: 'ws://localhost:3000', ws: true },
    },
  },
})
