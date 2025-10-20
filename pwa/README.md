# PWA WebApp (Vanilla JS + TailwindCSS + Flowbite)

A modern Progressive Web App starter using only vanilla JavaScript, TailwindCSS, and Flowbite (JS, not React). No React or flowbite-react dependencies. SPA navigation, PWA manifest, and service worker included. Ready for static deploy (e.g. Render.com).

## Features
- ⚡ Vite build tool
- 🎨 TailwindCSS utility-first styling
- 💎 Flowbite JS UI components
- 🚦 SPA navigation (hash-based, vanilla JS)
- 📱 PWA manifest & service worker
- 🏁 Ready for static hosting (dist/)

## Getting Started

```sh
npm install
npm run dev
```

- Visit [http://localhost:5173](http://localhost:5173) to view the app.

## Build for Production

```sh
npm run build
```
- Output is in `dist/` (ready for static deploy)

## Deploy
- Deploy the `dist/` folder to any static host (e.g. Render.com, Netlify, Vercel).

## Key Decisions
- **No React**: Only vanilla JS, Flowbite JS, and TailwindCSS.
- **SPA**: Navigation is handled with hash-based routing in JS.
- **PWA**: Includes manifest and service worker for offline support.

## Folder Structure
- `src/` - JS, CSS, and view templates
- `public/` - Static assets, manifest, service worker

## Credits
- [Vite](https://vitejs.dev/)
- [TailwindCSS](https://tailwindcss.com/)
- [Flowbite](https://flowbite.com/docs/getting-started/introduction/)
