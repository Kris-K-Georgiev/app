import { routes } from '../shell/routes.js'

const icons = {
  home: 'M3 12l9-9 9 9v9a3 3 0 0 1-3 3h-2a1 1 0 0 1-1-1v-6H9v6a1 1 0 0 1-1 1H6a3 3 0 0 1-3-3v-9z',
  calendar: 'M6 2v2M18 2v2M3 8h18M5 12h14M5 16h10',
  user: 'M12 12a5 5 0 1 0-5-5 5 5 0 0 0 5 5zm0 2c-5 0-9 2.5-9 5v1h18v-1c0-2.5-4-5-9-5z',
  settings: 'M12 8a4 4 0 1 0 4 4 4 4 0 0 0-4-4z',
  shield: 'M12 2l8 4v6c0 5-3.5 9.5-8 10-4.5-.5-8-5-8-10V6z',
  login: 'M10 17l5-5-5-5M15 12H3',
  register: 'M12 12a5 5 0 1 0-5-5',
}

export function Nav(activeRoute) {
  const items = routes.filter(r => ['/', '/events', '/profile', '/settings'].includes(r.path))
  return `
  <div class="grid grid-cols-4">
    ${items.map(i => `
      <a href="#${i.path}" class="flex flex-col items-center gap-1 p-3 ${activeRoute.path===i.path?'text-primary':'opacity-70'}">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="${icons[i.icon]}"></path></svg>
        <span class="text-xs">${i.name}</span>
      </a>
    `).join('')}
  </div>`
}
