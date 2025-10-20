# Copilot Instructions: PWA WebApp Scaffold

## Project Overview
- **Frameworks:** Vite, TailwindCSS, Flowbite (JS only)
- **No React or flowbite-react**
- **SPA navigation:** Vanilla JS (hash-based)
- **PWA:** Manifest + Service Worker
- **Ready for static deploy (Render.com, Netlify, etc.)**

## Setup Steps
1. `npm install` — install dependencies
2. `npm run dev` — start local dev server
3. `npm run build` — build for production (output: `dist/`)
4. Deploy `dist/` to static host

## Key Files
- `src/main.js` — SPA entry, navigation
- `src/views/` — page templates (home, feed, events, profile)
- `src/main.css` — TailwindCSS entry
- `public/index.html` — main HTML, loads Flowbite JS
- `public/manifest.webmanifest` — PWA manifest
- `public/sw.js` — Service worker

## Decisions
- No React, no JSX, no flowbite-react
- All UI with Flowbite JS + Tailwind utility classes
- SPA navigation with vanilla JS
- PWA support for offline use

## Build/Deploy
- Use `npm run build` and deploy `dist/` folder
- No server-side code required
