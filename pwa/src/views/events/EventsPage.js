import dayjs from 'dayjs'
import { listEvents } from '../../data/store.js'

export const EventsPage = {
  async render(){
    const events = await listEvents()
    const grouped = events.reduce((acc,e)=>{ const d=dayjs(e.date).format('YYYY-MM-DD'); (acc[d]=acc[d]||[]).push(e); return acc },{})
    const days = Object.keys(grouped).sort()
    return `
      <section class="grid gap-6 lg:grid-cols-[20rem_1fr]">
        <div class="card p-4">
          <h2 class="font-semibold mb-3">Календар</h2>
          <div class="text-sm space-y-1">
            ${days.map(d => `<div class="flex items-center gap-2"><span class="w-28 opacity-60">${d}</span><span class="inline-flex items-center gap-2">${grouped[d].map(()=>'<span class=\'w-2 h-2 rounded-full bg-primary inline-block\'></span>').join('')}</span></div>`).join('')}
          </div>
        </div>
        <div class="space-y-3">
          ${events.map(e => `
            <a href="#/event/${e.id}" class="card p-4 block">
              <div class="flex items-center justify-between">
                <div>
                  <div class="font-medium">${e.title}</div>
                  <div class="text-sm opacity-70">${dayjs(e.date).format('DD.MM.YYYY')}</div>
                </div>
                <span class="text-xs px-2 py-1 rounded-full ${e.active?'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-300':'bg-gray-100 text-gray-700 dark:bg-white/10 dark:text-gray-200'}">${e.active?'Активно':'Неактивно'}</span>
              </div>
              <div class="text-sm mt-2 opacity-80">Тип: ${e.type}${e.limit?`, лимит: ${e.limit}`:''}</div>
            </a>
          `).join('')}
        </div>
      </section>
    `
  }
}
