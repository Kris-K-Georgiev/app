import './main.css'
import 'flowbite'
import { initRouter } from './router.js'
import { initTheme } from './utils/theme.js'
import { registerServiceWorker } from './pwa/sw-register.js'
import { initAuth } from './state/auth.js'
import { seedIfEmpty } from './data/store.js'

// App globals
window.APP = {
  version: '0.1.0'
}

initTheme()
initAuth({ useFirebase: Boolean(import.meta.env.VITE_FIREBASE_API_KEY) })
registerServiceWorker()

// DEBUG: during development unregister existing service workers to avoid cached app shell
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(regs => regs.forEach(r => r.unregister().catch(()=>{}))).catch(()=>{})
}

// Seed demo data once before first route render
;(async ()=>{
  try { await seedIfEmpty() } catch {}
  initRouter()
})()

// Simple scroll reveal
const ro = new IntersectionObserver((entries)=>{
  for (const e of entries) {
    if (e.isIntersecting) e.target.classList.add('in')
  }
},{ threshold: 0.1 })
const attachReveal = () => document.querySelectorAll('.reveal').forEach(el=>ro.observe(el))
window.addEventListener('hashchange', ()=> setTimeout(attachReveal, 0))
window.addEventListener('load', ()=> setTimeout(attachReveal, 0))

// ripple effect for elements with .ripple-container
document.addEventListener('click', (e)=>{
  const el = e.target.closest('.ripple-container')
  if (!el) return
  const rect = el.getBoundingClientRect()
  const span = document.createElement('span')
  const size = Math.max(rect.width, rect.height)
  span.className = 'ripple'
  span.style.width = span.style.height = size + 'px'
  span.style.left = (e.clientX - rect.left - size/2) + 'px'
  span.style.top = (e.clientY - rect.top - size/2) + 'px'
  el.appendChild(span)
  setTimeout(()=> span.remove(), 600)
})

// Simple on-screen debug panel for development (shows logs/errors without DevTools)
window.__debugLog = function(label, msg){
  try {
    if (!document) return
    let panel = document.getElementById('__debug_panel')
    if (!panel) {
      panel = document.createElement('div')
      panel.id = '__debug_panel'
      panel.style.cssText = 'position:fixed;right:12px;top:12px;z-index:99999;max-width:420px;max-height:60vh;overflow:auto;font-family:monospace;font-size:12px;background:rgba(0,0,0,0.7);color:#fff;padding:8px;border-radius:8px;backdrop-filter:blur(6px)'
      const clear = document.createElement('button')
      clear.textContent = '×'
      clear.title = 'Clear'
      clear.style.cssText = 'position:absolute;right:6px;top:6px;background:transparent;border:none;color:#fff;font-size:14px;cursor:pointer'
      clear.addEventListener('click', ()=> panel.innerHTML = '')
      panel.appendChild(clear)
      document.body.appendChild(panel)
    }
    const line = document.createElement('div')
    const time = new Date().toLocaleTimeString()
    line.textContent = `[${time}] ${label}: ${typeof msg === 'string' ? msg : JSON.stringify(msg)}`
    line.style.marginBottom = '6px'
    panel.appendChild(line)
  } catch(e){ /* ignore */ }
}
