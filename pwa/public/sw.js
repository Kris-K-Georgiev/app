const CACHE = 'pwa-cache-v1'
const APP_SHELL = [
  '/',
  '/index.html',
  '/manifest.webmanifest',
  '/icons/icon-192.png',
  '/offline.html'
]

self.addEventListener('install', (e) => {
  e.waitUntil((async () => {
    const cache = await caches.open(CACHE)
    await cache.addAll(APP_SHELL)
    self.skipWaiting()
  })())
})

self.addEventListener('activate', (e) => {
  e.waitUntil((async () => {
    const keys = await caches.keys()
    await Promise.all(keys.filter(k => k!==CACHE).map(k => caches.delete(k)))
    self.clients.claim()
  })())
})

self.addEventListener('message', (e) => {
  if (e.data?.type === 'SKIP_WAITING') self.skipWaiting()
})

// Network-first for same-origin GET, fallback to cache, then offline page for navigations
self.addEventListener('fetch', (e) => {
  const req = e.request
  if (req.method !== 'GET') return

  if (req.mode === 'navigate') {
    e.respondWith((async () => {
      try {
        const fresh = await fetch(req)
        const cache = await caches.open(CACHE)
        cache.put('/index.html', fresh.clone())
        return fresh
      } catch (err) {
        const cache = await caches.open(CACHE)
        return (await cache.match('/index.html')) || (await cache.match('/offline.html'))
      }
    })())
    return
  }

  const url = new URL(req.url)
  if (url.origin === location.origin) {
    e.respondWith((async () => {
      try {
        const fresh = await fetch(req)
        const cache = await caches.open(CACHE)
        cache.put(req, fresh.clone())
        return fresh
      } catch (err) {
        const cache = await caches.open(CACHE)
        return (await cache.match(req)) || fetch(req)
      }
    })())
  }
})
