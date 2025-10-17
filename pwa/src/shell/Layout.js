import { Nav } from '../components/Nav.js'
import { Sidebar } from '../components/Sidebar.js'

export function renderLayout(content, route) {
  return `
  <div class="min-h-screen grid grid-rows-[auto_1fr_auto] lg:grid-rows-[auto_1fr] lg:grid-cols-[18rem_1fr]">
    <header class="sticky top-0 z-40 bg-white/70 dark:bg-black/40 backdrop-blur border-b border-black/5 dark:border-white/10">
      <div class="container-pro h-16 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <img src="/icons/icon-96.png" alt="logo" class="w-8 h-8 rounded-xl shadow" />
          <span class="font-semibold tracking-tight">PWA App</span>
        </div>
        <div class="flex items-center gap-2">
          <a href="#/posts" class="btn-ghost hidden sm:inline-flex" title="Постове">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M4 4h16v4H4zm0 6h16v2H4zm0 4h10v2H4z"/></svg>
          </a>
          <a href="#/chat" class="btn-ghost hidden sm:inline-flex" title="Чат">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M21 15a4 4 0 0 1-4 4H8l-5 3 1.5-4.5A4 4 0 0 1 4 15V7a4 4 0 0 1 4-4h9a4 4 0 0 1 4 4z"/></svg>
          </a>
          <a href="#/profile?tab=settings" class="btn-ghost" title="Настройки">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 8a4 4 0 1 0 4 4 4 4 0 0 0-4-4z"/></svg>
          </a>
          <a href="#/profile" class="btn-ghost" title="Профил">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M12 12a5 5 0 1 0-5-5 5 5 0 0 0 5 5zm0 2c-5 0-9 2.5-9 5v1h18v-1c0-2.5-4-5-9-5z"/></svg>
          </a>
        </div>
      </div>
    </header>

    <aside class="hidden lg:block border-r border-black/5 dark:border-white/10">
      <div class="p-4">
        ${Sidebar(route)}
      </div>
    </aside>

    <main class="py-6">
      <div class="container-pro">
        ${content}
      </div>
    </main>

    <nav class="lg:hidden sticky bottom-0 border-t border-black/5 dark:border-white/10 bg-white/85 dark:bg-black/70 backdrop-blur">
      ${Nav(route)}
    </nav>
  </div>
  `
}
