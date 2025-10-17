import { getEvent } from '../../data/store.js'
import dayjs from 'dayjs'

export const EventDetailPage = {
  async render(){
    const id = location.hash.split('/').pop()
    const e = await getEvent(id)
    if (!e) return '<p>Събитието не е намерено.</p>'
    return `
      <article class="max-w-3xl mx-auto space-y-4">
        <img src="${e.photos?.[0]||'https://picsum.photos/seed/ev/800/500'}" class="w-full rounded"/>
        <h1 class="text-3xl font-semibold">${e.title}</h1>
        <div class="opacity-70">${dayjs(e.date).format('DD MMM YYYY')}</div>
        <p>${e.description}</p>
        <div class="flex gap-2 text-sm">
          <span class="px-2 py-1 rounded bg-gray-100 dark:bg-white/10">Тип: ${e.type}</span>
          ${e.limit?`<span class="px-2 py-1 rounded bg-gray-100 dark:bg-white/10">Лимит: ${e.limit}</span>`:''}
          <span class="px-2 py-1 rounded ${e.active?'bg-green-100 text-green-700':'bg-gray-100 text-gray-700'}">${e.active?'Активно':'Неактивно'}</span>
        </div>
      </article>
    `
  }
}
