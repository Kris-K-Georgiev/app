import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  build: {
    outDir: 'dist', // папката за билд файловете
  },
  server: {
    port: 5173, // можеш да смениш, ако искаш
  },
});
