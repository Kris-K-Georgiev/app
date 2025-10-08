import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';
import vue from '@vitejs/plugin-vue';

// We keep Tailwind for the public / existing styles (app.css) and add a minimal
// separate admin bundle (admin.css / admin.js) that relies on Bootstrap + Sneat via CDN.
export default defineConfig({
    plugins: [
        laravel({
            input: [
                'resources/css/app.css',
                'resources/js/app.js',
                'resources/css/admin.css',
                'resources/js/admin.js',
                'resources/js/admin-vue.js'
            ],
            refresh: true,
        }),
        vue(),
        tailwindcss(),
    ],
});
