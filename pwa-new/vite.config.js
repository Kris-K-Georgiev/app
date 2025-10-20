import { defineConfig } from 'vite';import { defineConfig } from 'vite'

import react from '@vitejs/plugin-react';

export default defineConfig({

export default defineConfig({  server:{

  plugins: [react()],    host: true

  optimizeDeps: {  }

    include: ['flowbite-react'],})

  },
  ssr: {
    noExternal: ['flowbite-react'],
  },
});
