import './main.css'
import 'flowbite'
import { initRouter } from './router.js'
import { initTheme } from './utils/theme.js'
import { registerServiceWorker } from './pwa/sw-register.js'
import { initAuth } from './state/auth.js'

// App globals
window.APP = {
  version: '0.1.0'
}

initTheme()
initAuth({ useFirebase: Boolean(import.meta.env.VITE_FIREBASE_API_KEY) })
registerServiceWorker()

initRouter()
