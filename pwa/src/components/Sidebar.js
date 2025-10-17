import { routes } from '../shell/routes.js'

export function Sidebar(activeRoute) {
  const items = routes.filter(r => !['/login','/register','/news/:id','/event/:id'].includes(r.path))
  return `
    <nav class="space-y-1">
      ${items.map(i => {
        const active = activeRoute.path===i.path
        const base = 'flex items-center gap-2 px-3 py-2 rounded-lg transition-colors'
        const state = active ? 'bg-black/5 dark:bg-white/10 text-gray-900 dark:text-white' : 'text-gray-700 dark:text-gray-300 hover:bg-black/5 dark:hover:bg-white/10'
        return `<a href="#${i.path}" class="${base} ${state}">${i.name}</a>`
      }).join('')}
    </nav>
  `
}
