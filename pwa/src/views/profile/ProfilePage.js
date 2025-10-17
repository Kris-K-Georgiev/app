import { getAuth } from '../../state/auth.js'
import { listPosts } from '../../data/store.js'
import { renderSparkline, lastNDaysCounts } from '../../utils/sparkline.js'

export const ProfilePage = {
  render(){
    const { user } = getAuth()
    if (!user) return `<div class="max-w-xl mx-auto card p-4">Моля, <a class="text-primary" href="#/login">влезте</a>.</div>`
    // skeleton initial; data hydrated in afterRender
    const mine = []
    const activity = []
  const since = new Date(user.registeredAt || Date.now())
  const tenureYears = Math.max(1, Math.floor((Date.now() - since.getTime()) / (365*24*60*60*1000)))
  return `
      <section class="w-full max-w-4xl mx-auto space-y-3 sm:space-y-4">
        <div class="card overflow-hidden reveal">
          <div class="h-20 sm:h-24 md:h-28 relative group">
            ${user.coverURL? `<img src="${user.coverURL}" class="w-full h-full object-cover" style="object-position: center ${user.coverMeta?.yPercent||0}%; transform: scale(${user.coverMeta?.zoom||1});"/>` : `<div class="h-full bg-gradient-to-r from-primary/30 to-blue-400/30 dark:from-primary/20 dark:to-blue-500/20"></div>`}
            <a href="#/profile/edit" class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity btn-ghost bg-white/70 dark:bg-black/40 backdrop-blur text-xs sm:text-sm px-2 sm:px-3 py-1">
              Редакция
            </a>
          </div>
          <div class="px-3 sm:px-5 -mt-8 sm:-mt-10 flex items-end gap-2 sm:gap-4">
            <img src="${user.photoURL||'https://i.pravatar.cc/120'}" class="w-16 h-16 sm:w-20 sm:h-20 rounded-xl sm:rounded-2xl ring-2 ring-white dark:ring-black object-cover"/>
            <div class="flex-1 pb-1 sm:pb-2 min-w-0">
              <div class="text-lg sm:text-xl font-semibold truncate">${user.name||'Без име'}</div>
              <div class="text-xs sm:text-sm opacity-70 truncate">${user.email} ${user.city? '· '+user.city: ''}</div>
            </div>
            <div class="pb-1 sm:pb-2 flex items-center gap-1 sm:gap-2">
              <a href="#/profile/edit" class="btn-ghost p-1.5 sm:p-2" data-tooltip="Редакция">
                <svg width="16" height="16" class="sm:w-[18px] sm:h-[18px]" viewBox="0 0 24 24" fill="currentColor"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a1 1 0 0 0 0-1.41l-2.34-2.34a1 1 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>
              </a>
              <a href="#/profile/settings" class="btn-ghost p-1.5 sm:p-2" data-tooltip="Настройки">
                <svg width="16" height="16" class="sm:w-[18px] sm:h-[18px]" viewBox="0 0 24 24" fill="currentColor"><path d="M19.14,12.94a7.43,7.43,0,0,0,.05-.94,7.43,7.43,0,0,0-.05-.94l2.11-1.65a.5.5,0,0,0,.12-.63l-2-3.46a.5.5,0,0,0-.6-.22l-2.49,1a7.28,7.28,0,0,0-1.63-.94l-.38-2.65A.5.5,0,0,0,11.73,2H8.27a.5.5,0,0,0-.49.41L7.4,5.06a7.28,7.28,0,0,0-1.63.94l-2.49-1a.5.5,0,0,0-.6.22l-2,3.46a.5.5,0,0,0,.12.63L3,11.06a7.43,7.43,0,0,0-.05.94,7.43,7.43,0,0,0,.05.94L.86,14.59a.5.5,0,0,0-.12.63l2,3.46a.5.5,0,0,0,.6.22l2.49-1a7.28,7.28,0,0,0,1.63.94l.38,2.65a.5.5,0,0,0,.49.41h3.46a.5.5,0,0,0,.49-.41l.38-2.65a7.28,7.28,0,0,0,1.63-.94l2.49,1a.5.5,0,0,0,.6-.22l2-3.46a.5.5,0,0,0-.12-.63ZM10,15a3,3,0,1,1,3-3A3,3,0,0,1,10,15Z"/></svg>
              </a>
            </div>
          </div>
          <div class="px-3 sm:px-5 pb-3 sm:pb-4 grid grid-cols-3 gap-2 text-xs sm:text-sm mt-3">
            <div class="card bg-black/5 dark:bg-white/10 p-2 sm:p-3 rounded-lg sm:rounded-xl card-hover">
              <div class="text-[10px] sm:text-xs opacity-70">Постове</div>
              <div id="stat-posts" class="text-base sm:text-lg font-semibold skeleton h-4 sm:h-5 w-8 sm:w-10 rounded"></div>
            </div>
            <div class="card bg-black/5 dark:bg-white/10 p-2 sm:p-3 rounded-lg sm:rounded-xl card-hover">
              <div class="text-[10px] sm:text-xs opacity-70">Роля</div>
              <div class="text-base sm:text-lg font-semibold truncate">${(user.role||'worker')}</div>
            </div>
            <div class="card bg-black/5 dark:bg-white/10 p-2 sm:p-3 rounded-lg sm:rounded-xl card-hover">
              <div class="text-[10px] sm:text-xs opacity-70">Град</div>
              <div class="text-base sm:text-lg font-semibold truncate">${user.city||'—'}</div>
            </div>
          </div>
        </div>
        <div class="grid gap-3 sm:gap-4 grid-cols-1 md:grid-cols-2">
          <div class="card p-4 sm:p-5 space-y-3">
            <div class="font-semibold text-sm sm:text-base">Информация</div>
            <div class="flex flex-wrap gap-1.5 sm:gap-2 text-[10px] sm:text-xs">
              <span class="px-2 py-1 rounded-full bg-blue-100 text-blue-700 dark:bg-blue-500/20 dark:text-blue-300 hover:scale-[1.02] transition">Роля: ${user.role||'worker'}</span>
              <span class="px-2 py-1 rounded-full bg-emerald-100 text-emerald-700 dark:bg-emerald-500/20 dark:text-emerald-300" title="Регистриран: ${since.toLocaleDateString()}">Стаж: ${tenureYears}г+</span>
              <span id="badge-activity" class="px-2 py-1 rounded-full bg-purple-100 text-purple-700 dark:bg-purple-500/20 dark:text-purple-300" title="Общ брой постове">Активност: —</span>
            </div>
            <div class="space-y-2 text-xs sm:text-sm">
              <div><span class="opacity-70">Име:</span> ${user.name || '—'}</div>
              <div><span class="opacity-70">Имейл:</span> ${user.email || '—'}</div>
              <div><span class="opacity-70">Телефон:</span> ${user.phone || '—'}</div>
              <div><span class="opacity-70">Град:</span> ${user.city || '—'}</div>
              <div><span class="opacity-70">Био:</span> ${user.bio || '—'}</div>
            </div>
          </div>
          <div class="card p-4 sm:p-5 space-y-3">
            <div class="flex items-center justify-between">
              <div class="font-semibold text-sm sm:text-base">Активност</div>
              <div class="opacity-70 text-[10px] sm:text-xs">последни 30 дни</div>
            </div>
            <div id="activity-spark" class="overflow-x-auto"><div class="h-8 sm:h-10 skeleton rounded"></div></div>
            <div id="activity-list" class="space-y-2 sm:space-y-3">
              ${[1,2,3].map(()=>`<div class='flex items-start gap-2 sm:gap-3'>
                <div class='w-8 h-8 sm:w-10 sm:h-10 rounded-lg sm:rounded-xl skeleton'></div>
                <div class='flex-1 space-y-1.5 sm:space-y-2'>
                  <div class='h-3 sm:h-4 skeleton rounded w-1/3'></div>
                  <div class='h-3 sm:h-4 skeleton rounded w-2/3'></div>
                </div>
              </div>`).join('')}
            </div>
          </div>
        </div>
      </section>
    `
  },
  async afterRender(){
    const { user } = getAuth()
    const posts = await listPosts()
    const mine = posts.filter(p=>p.authorId===user.id)
    const activity = lastNDaysCounts(mine, 30)

    const stat = document.getElementById('stat-posts')
    if (stat) { stat.classList.remove('skeleton'); stat.textContent = String(mine.length) }
    const badge = document.getElementById('badge-activity')
    if (badge) badge.textContent = `Активност: ${mine.length}`
    const spark = document.getElementById('activity-spark')
    if (spark) spark.innerHTML = renderSparkline(activity, { width: 240, height: 40 })
    const list = document.getElementById('activity-list')
    if (list) list.innerHTML = mine.length ? mine.slice(0,5).map(p=>`
      <div class='flex items-start gap-3'>
        <div class='w-10 h-10 rounded-xl bg-black/5 dark:bg-white/10 flex items-center justify-center'>📝</div>
        <div class='flex-1'>
          <div class='text-sm opacity-70'>${new Date(p.createdAt).toLocaleString()}</div>
          <div>${p.text}</div>
        </div>
      </div>
    `).join('') : '<div class="text-sm opacity-70">Няма активност.</div>'
  }
}
