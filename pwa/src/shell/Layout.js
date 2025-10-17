import { Nav } from '../components/Nav.js'
import { Sidebar } from '../components/Sidebar.js'

export function renderLayout(content, route) {
  return `
  <div class="min-h-screen grid grid-rows-[auto_1fr_auto] lg:grid-rows-[auto_1fr] lg:grid-cols-[16rem_1fr]">
    <header class="sticky top-0 z-40 backdrop-blur border-b border-gray-200/50 dark:border-gray-800/50 bg-white/70 dark:bg-black/50">
      <div class="mx-auto max-w-7xl px-4 py-3 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <img src="/icons/icon-96.png" alt="logo" class="w-8 h-8 rounded" />
          <span class="font-semibold">PWA App</span>
        </div>
        <div class="text-sm opacity-60">v${window.APP.version}</div>
      </div>
    </header>

    <aside class="hidden lg:block border-r border-gray-200/50 dark:border-gray-800/50">
      ${Sidebar(route)}
    </aside>

    <main class="p-4 lg:p-8">
      ${content}
    </main>

    <nav class="lg:hidden sticky bottom-0 border-t border-gray-200/50 dark:border-gray-800/50 bg-white/90 dark:bg-black/80 backdrop-blur">
      ${Nav(route)}
    </nav>
  </div>
  `
}
