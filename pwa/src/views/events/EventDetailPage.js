import { getEvent } from '../../data/store.js'
import dayjs from 'dayjs'

export const EventDetailPage = {
  async render(){
    const id = location.hash.split('/').pop()
    const e = await getEvent(id)
    if (!e) return '<p>Събитието не е намерено.</p>'
    return `
      <article class="space-y-4">
        <div class="card overflow-hidden">
          <img src="${e.photos?.[0]||'https://picsum.photos/seed/ev/800/500'}" class="w-full aspect-[16/9] object-cover"/>
        </div>
        <h1 class="section-title">${e.title}</h1>
        <div class="opacity-70">${dayjs(e.date).format('DD MMM YYYY')}</div>
        <p class="card p-4">${e.description}</p>
        <div class="flex flex-wrap gap-2 text-sm">
          <span class="px-2 py-1 rounded bg-gray-100 dark:bg-white/10">Тип: ${e.type}</span>
          ${e.limit?`<span class="px-2 py-1 rounded bg-gray-100 dark:bg-white/10">Лимит: ${e.limit}</span>`:''}
          <span class="px-2 py-1 rounded ${e.active?'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-300':'bg-gray-100 text-gray-700 dark:bg-white/10 dark:text-gray-200'}">${e.active?'Активно':'Неактивно'}</span>
        </div>
      </article>
    `
  }
}
