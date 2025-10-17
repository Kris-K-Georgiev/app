import { Nav } from '../components/Nav.js'
import { Sidebar } from '../components/Sidebar.js'
import { getAuth } from '../state/auth.js'

export function renderLayout(content, route) {
  const { user } = getAuth()
  const isChatRoom = route.path === '/chat/:id'
  
  // Full-screen layout for chat room (like Messenger)
  if (isChatRoom) {
    return `
      <div class="h-screen bg-gray-50 dark:bg-black text-gray-900 dark:text-white overflow-hidden">
        ${content}
      </div>
    `
  }
  
  return `
  <div class="min-h-screen grid grid-rows-[auto_1fr_auto] lg:grid-rows-[auto_1fr] lg:grid-cols-[16rem_1fr] xl:grid-cols-[18rem_1fr]">
    <header class="sticky top-0 z-40 bg-white/70 dark:bg-black/40 backdrop-blur border-b border-black/5 dark:border-white/10">
      <div class="w-full max-w-[1400px] mx-auto px-3 sm:px-4 md:px-6 lg:px-8 h-14 sm:h-16 flex items-center justify-between">
        <div class="flex items-center gap-2 sm:gap-3">
          <img src="/icons/icon-96.png" alt="logo" class="w-7 h-7 sm:w-8 sm:h-8 rounded-lg sm:rounded-xl shadow" />
          <span class="font-semibold tracking-tight text-sm sm:text-base">PWA App</span>
        </div>
        <div class="flex items-center gap-1 sm:gap-2">
          <a href="#/posts" class="btn-ghost hidden sm:inline-flex ripple-container spring p-2" data-tooltip="Постове">
            <svg width="16" height="16" class="sm:w-[18px] sm:h-[18px]" viewBox="0 0 24 24" fill="currentColor"><path d="M4 4h16v4H4zm0 6h16v2H4zm0 4h10v2H4z"/></svg>
          </a>
          <a href="#/chat" class="btn-ghost hidden sm:inline-flex ripple-container spring p-2" data-tooltip="Чат">
            <svg width="16" height="16" class="sm:w-[18px] sm:h-[18px]" viewBox="0 0 24 24" fill="currentColor"><path d="M21 15a4 4 0 0 1-4 4H8l-5 3 1.5-4.5A4 4 0 0 1 4 15V7a4 4 0 0 1 4-4h9a4 4 0 0 1 4 4z"/></svg>
          </a>

          <!-- Profile dropdown using Flowbite data attributes -->
          <div class="relative">
            <button type="button" class="flex items-center gap-2 btn-ghost ripple-container spring p-1.5 sm:p-2" id="user-menu-button" data-dropdown-toggle="user-dropdown" aria-expanded="false">
              <img src="${user?.photoURL||'https://i.pravatar.cc/60'}" class="w-7 h-7 sm:w-8 sm:h-8 rounded-full object-cover" alt="profile"/>
            </button>
            <div id="user-dropdown" class="hidden z-50 my-4 text-base list-none bg-white divide-y divide-gray-100 rounded-lg shadow-md dark:bg-gray-800 dark:divide-gray-700" aria-labelledby="user-menu-button">
              <div class="px-4 py-3">
                <span class="block text-sm text-gray-900 dark:text-white">${user?.displayName || 'Потребител'}</span>
                <span class="block text-sm font-medium text-gray-500 truncate dark:text-gray-400">${user?.email || ''}</span>
              </div>
              <ul class="py-2" aria-labelledby="user-menu-button">
                <li>
                  <a href="#/profile" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700">Профил</a>
                </li>
                <li>
                  <a href="#/profile/settings" class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 dark:text-gray-200 dark:hover:bg-gray-700">Настройки</a>
                </li>
                <li>
                  <a href="#/logout" class="block px-4 py-2 text-sm text-red-600 hover:bg-gray-100 dark:hover:bg-gray-700">Изход</a>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </header>

    <aside class="hidden lg:block border-r border-black/5 dark:border-white/10 overflow-y-auto">
      <div class="p-3 xl:p-4">
        ${Sidebar(route)}
      </div>
    </aside>

    <main class="py-4 sm:py-6 overflow-x-hidden">
      <div class="w-full max-w-[1400px] mx-auto px-3 sm:px-4 md:px-6 lg:px-8">
        ${content}
      </div>
    </main>

    <nav class="lg:hidden sticky bottom-0 border-t border-black/5 dark:border-white/10 bg-white/80 dark:bg-black/60 backdrop-blur safe-area-inset-bottom">
      ${Nav(route)}
    </nav>
  </div>
  `
}
