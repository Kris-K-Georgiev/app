import { routes } from '../shell/routes.js'
import { getAuth } from '../state/auth.js'

export function Sidebar(activeRoute) {
  const { user } = getAuth()
  const items = routes.filter(r => !['/login','/register','/news/:id','/event/:id'].includes(r.path))
  return `
    <nav class="space-y-1" aria-label="Main navigation">
      ${items.map(i => {
        const active = activeRoute.path===i.path || (i.path==='/chat' && activeRoute.path.startsWith('/chat'))
        const base = 'flex items-center gap-2 px-3 py-2 rounded-lg transition-colors ripple-container spring'
        const state = active ? 'bg-black/5 dark:bg-white/10 ring-1 ring-black/5 dark:ring-white/10 text-gray-900 dark:text-white' : 'text-gray-700 dark:text-gray-300 hover:bg-black/5 dark:hover:bg-white/10'
  const isProfile = i.path === '/profile'
  const icon = isProfile ? `<img src="${user?.photoURL||'https://i.pravatar.cc/60'}" class="w-6 h-6 rounded-full object-cover" alt="avatar"/>` : ''
  return `<a href="#${i.path}" class="${base} ${state}" ${!isProfile?`data-tooltip="${i.name}"`:''}>${icon}${i.name}</a>`
      }).join('')}
    </nav>
  `
}
