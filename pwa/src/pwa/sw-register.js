export function registerServiceWorker() {
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('/sw.js').then(reg => {
        // Listen for updates
        if (reg.waiting) notifyUpdate(reg)
        reg.addEventListener('updatefound', () => {
          const nw = reg.installing
          if (!nw) return
          nw.addEventListener('statechange', () => {
            if (nw.state === 'installed' && navigator.serviceWorker.controller) {
              notifyUpdate(reg)
            }
          })
        })
      }).catch(console.error)
    })
  }
}

function notifyUpdate(reg) {
  const toast = document.createElement('div')
  toast.className = 'fixed bottom-4 left-1/2 -translate-x-1/2 z-50 card p-3 flex items-center gap-3'
  toast.innerHTML = `
    <span>Налична е нова версия.</span>
    <button id="sw-refresh" class="px-3 py-1 rounded bg-primary text-white">Обнови</button>
  `
  document.body.appendChild(toast)
  toast.querySelector('#sw-refresh').addEventListener('click', async () => {
    await reg.update()
    reg.waiting?.postMessage({ type: 'SKIP_WAITING' })
    setTimeout(() => window.location.reload(), 300)
  })
}
