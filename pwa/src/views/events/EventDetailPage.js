import { getEvent } from '../../data/store.js'
import dayjs from 'dayjs'

export const EventDetailPage = {
  async render(){
    const id = location.hash.split('/').pop()
    const e = await getEvent(id)
    if (!e) return '<div class="max-w-2xl mx-auto card p-4 sm:p-6">Събитието не е намерено.</div>'
    return `
      <article class="w-full max-w-4xl mx-auto space-y-4 sm:space-y-6">
        <div class="card overflow-hidden">
          <img src="${e.photos?.[0]||'https://picsum.photos/seed/ev/800/500'}" class="w-full aspect-video sm:aspect-[16/9] object-cover"/>
        </div>
        <h1 class="text-2xl sm:text-3xl md:text-4xl font-bold leading-tight px-2 sm:px-0">${e.title}</h1>
        <div class="text-sm sm:text-base opacity-70 px-2 sm:px-0">${dayjs(e.date).format('DD MMM YYYY')}</div>
        <p class="card p-4 sm:p-6 text-sm sm:text-base leading-relaxed">${e.description}</p>
        <div class="flex flex-wrap gap-2 text-xs sm:text-sm px-2 sm:px-0">
          <span class="px-3 py-1.5 rounded-lg bg-gray-100 dark:bg-white/10">Тип: ${e.type}</span>
          ${e.limit?`<span class="px-3 py-1.5 rounded-lg bg-gray-100 dark:bg-white/10">Лимит: ${e.limit}</span>`:''}
          <span class="px-3 py-1.5 rounded-lg ${e.active?'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-300':'bg-gray-100 text-gray-700 dark:bg-white/10 dark:text-gray-200'}">${e.active?'Активно':'Неактивно'}</span>
        </div>
      </article>
    `
  }
}
