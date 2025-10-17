import { routes } from '../shell/routes.js'

export function Sidebar(activeRoute) {
  const items = routes.filter(r => !['/login','/register','/news/:id','/event/:id'].includes(r.path))
  return `
    <div class="p-4 space-y-2">
      ${items.map(i => `
        <a href="#${i.path}" class="block px-3 py-2 rounded hover:bg-gray-100 dark:hover:bg-white/10 ${activeRoute.path===i.path?'bg-gray-100 dark:bg-white/10':''}">
          ${i.name}
        </a>
      `).join('')}
    </div>
  `
}
