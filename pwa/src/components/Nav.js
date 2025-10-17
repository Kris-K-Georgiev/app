import { routes } from '../shell/routes.js'

const icons = {
  home: 'M4 10.5 12 4l8 6.5V19a3 3 0 0 1-3 3H7a3 3 0 0 1-3-3v-8.5Z',
  calendar: 'M7 3h10a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Zm0 5h10',
  user: 'M12 12a5 5 0 1 0-5-5 5 5 0 0 0 5 5Zm0 3c-4 0-8 2-8 5v2h16v-2c0-3-4-5-8-5Z',
  shield: 'M12 2 20 6v6c0 5-3.5 9.5-8 10-4.5-.5-8-5-8-10V6Z',
  login: 'M10 17l5-5-5-5M15 12H3',
  register: 'M12 12a5 5 0 1 0-5-5',
  posts: 'M5 5h14a1 1 0 0 1 1 1v3H4V6a1 1 0 0 1 1-1Zm-1 7h16v2H4Zm0 4h12v2H4Z',
  chat: 'M20 16a4 4 0 0 1-4 4H9l-5 3 1.5-4.5A4 4 0 0 1 4 16V8a4 4 0 0 1 4-4h8a4 4 0 0 1 4 4Z',
}

export function Nav(activeRoute) {
  const items = routes.filter(r => ['/', '/events', '/posts', '/chat'].includes(r.path))
  return `
  <div class="container-pro">
    <div class="grid grid-cols-4 pb-[env(safe-area-inset-bottom)]">
      ${items.map(i => {
        const active = activeRoute.path===i.path || (i.path==='/chat' && activeRoute.path.startsWith('/chat'))
        const base = 'flex flex-col items-center gap-1 p-3 rounded-xl transition-colors ripple-container spring'
        const state = active ? 'text-primary bg-black/5 dark:bg-white/10' : 'text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white'
        return `
          <a href="#${i.path}" class="${base} ${state}" role="button" aria-pressed="${active}" aria-label="${i.name}" data-tooltip="${i.name}">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="${icons[i.icon]}"></path></svg>
            <span class="text-[11px] leading-none">${i.name}</span>
          </a>
        `
      }).join('')}
    </div>
  </div>`
}
