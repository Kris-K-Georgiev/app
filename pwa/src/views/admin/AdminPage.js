import { getAuth, isAdmin } from '../../state/auth.js'
import { listNews, saveNews, deleteNews, listEvents, saveEvent, deleteEvent } from '../../data/store.js'

export const AdminPage = {
  async render(){
    const { user } = getAuth()
    if (!user) return `<div class="w-full max-w-xl mx-auto card p-4 sm:p-6 text-sm sm:text-base">Моля, <a class="text-primary" href="#/login">влезте</a>.</div>`
    if (!isAdmin()) return `<div class="w-full max-w-xl mx-auto card p-4 sm:p-6 text-sm sm:text-base">Нямате права за достъп.</div>`

    const [news, events] = await Promise.all([listNews(), listEvents()])
    return `
      <section class="w-full space-y-4 sm:space-y-6">
        <h1 class="section-title text-xl sm:text-2xl">Админ панел</h1>
        <div class="grid gap-4 sm:gap-6 grid-cols-1 lg:grid-cols-2">
          <div class="card p-4 sm:p-5">
            <div class="flex items-center justify-between mb-3">
              <h2 class="font-semibold text-base sm:text-lg">Новини</h2>
              <button id="add-news" class="btn text-xs sm:text-sm px-3 py-1.5">+ Добави</button>
            </div>
            <div class="divide-y divide-black/5 dark:divide-white/10" id="news-list">
              ${news.map(n => `
                <div class="flex items-center justify-between py-2 gap-2">
                  <span class="text-sm sm:text-base truncate flex-1">${n.title}</span>
                  <div class="flex gap-1 sm:gap-2 flex-shrink-0">
                    <button data-id="${n.id}" class="edit-news btn-ghost text-blue-600 dark:text-blue-400 text-xs sm:text-sm px-2 py-1">Редакция</button>
                    <button data-id="${n.id}" class="delete-news btn-ghost text-red-600 dark:text-red-400 text-xs sm:text-sm px-2 py-1">Изтрий</button>
                  </div>
                </div>
              `).join('')}
            </div>
          </div>
          <div class="card p-4 sm:p-5">
            <div class="flex items-center justify-between mb-3">
              <h2 class="font-semibold text-base sm:text-lg">Събития</h2>
              <button id="add-event" class="btn text-xs sm:text-sm px-3 py-1.5">+ Добави</button>
            </div>
            <div class="divide-y divide-black/5 dark:divide-white/10" id="events-list">
              ${events.map(e => `
                <div class="flex items-center justify-between py-2 gap-2">
                  <span class="text-sm sm:text-base truncate flex-1">${e.title}</span>
                  <div class="flex gap-1 sm:gap-2 flex-shrink-0">
                    <button data-id="${e.id}" class="edit-event btn-ghost text-blue-600 dark:text-blue-400 text-xs sm:text-sm px-2 py-1">Редакция</button>
                    <button data-id="${e.id}" class="delete-event btn-ghost text-red-600 dark:text-red-400 text-xs sm:text-sm px-2 py-1">Изтрий</button>
                  </div>
                </div>
              `).join('')}
            </div>
          </div>
        </div>
      </section>
    `
  },
  afterRender(){
    
    document.getElementById('add-news')?.addEventListener('click', async ()=>{
      const form = `
        <form id='addnews' class='space-y-3'>
          <label class='label'>Заглавие</label>
          <input name='title' class='input w-full' required />
          <label class='label'>Корица URL</label>
          <input name='cover' class='input w-full' />
          <label class='label'>Съдържание</label>
          <textarea name='content' class='input min-h-[120px] w-full'></textarea>
          <div class='flex justify-end'><button class='btn' type='submit'>Запази</button></div>
        </form>`
  const m = await import('../../components/Modal.js')
  const { el, close } = m.showModal({ title: 'Добави новина', content: form })
      el.querySelector('#addnews')?.addEventListener('submit', async (e)=>{
        e.preventDefault(); const data = Object.fromEntries(new FormData(e.currentTarget).entries()); await saveNews(data); close(); location.reload()
      })
    })
    document.querySelectorAll('.edit-news').forEach(el=>el.addEventListener('click', async ()=>{
      const id = el.getAttribute('data-id')
      const existing = (await import('../../data/store.js')).getNews ? await (await import('../../data/store.js')).getNews(id) : null
      const form = `
        <form id='editnews' class='space-y-3'>
          <label class='label'>Заглавие</label>
          <input name='title' class='input w-full' value='${existing?.title||''}' required />
          <label class='label'>Корица URL</label>
          <input name='cover' class='input w-full' value='${existing?.cover||''}' />
          <label class='label'>Съдържание</label>
          <textarea name='content' class='input min-h-[120px] w-full'>${existing?.content||''}</textarea>
          <div class='flex justify-end'><button class='btn' type='submit'>Запази</button></div>
        </form>`
  const m2 = await import('../../components/Modal.js')
  const { el: modal, close } = m2.showModal({ title: 'Редакция на новина', content: form })
      modal.querySelector('#editnews')?.addEventListener('submit', async (e)=>{
        e.preventDefault(); const data = Object.fromEntries(new FormData(e.currentTarget).entries()); data.id = id; await saveNews(data); close(); location.reload()
      })
    }))
    document.querySelectorAll('.delete-news').forEach(el=>el.addEventListener('click', async ()=>{
      const id = el.getAttribute('data-id')
  const m3 = await import('../../components/Modal.js')
  const { el: modal, close } = m3.showModal({ title: 'Потвърждение', content: `
        <div class='space-y-3'>
          <p>Сигурни ли сте, че искате да изтриете новината?</p>
          <div class='flex justify-end gap-2'>
            <button class='btn-ghost' data-close='1' type='button'>Отказ</button>
            <button class='btn' id='confirm-del' type='button'>Изтрий</button>
          </div>
  </div>` })
      modal.querySelector('#confirm-del')?.addEventListener('click', async ()=>{ await deleteNews(id); close(); location.reload() })
    }))

    
    document.getElementById('add-event')?.addEventListener('click', async ()=>{
      const form = `
        <form id='addevt' class='space-y-3'>
          <label class='label'>Заглавие</label>
          <input name='title' class='input w-full' required />
          <label class='label'>Описание</label>
          <textarea name='description' class='input min-h-[100px] w-full'></textarea>
          <label class='label'>Дата (YYYY-MM-DD)</label>
          <input name='date' class='input w-full' placeholder='2025-10-17' />
          <label class='label'>Тип</label>
          <input name='type' class='input w-full' placeholder='местно' />
          <label class='label'>Активно</label>
          <label class='flex items-center gap-2'><input type='checkbox' name='active'/> Активно</label>
          <div class='flex justify-end'><button class='btn' type='submit'>Запази</button></div>
        </form>`
  const m4 = await import('../../components/Modal.js')
  const { el, close } = m4.showModal({ title: 'Добави събитие', content: form })
      el.querySelector('#addevt')?.addEventListener('submit', async (e)=>{
        e.preventDefault(); const data = Object.fromEntries(new FormData(e.currentTarget).entries()); data.date = new Date(data.date).getTime(); data.active = !!data.active; await saveEvent(data); close(); location.reload()
      })
    })
    document.querySelectorAll('.edit-event').forEach(el=>el.addEventListener('click', async ()=>{
      const id = el.getAttribute('data-id')
      const existing = (await import('../../data/store.js')).getEvent ? await (await import('../../data/store.js')).getEvent(id) : null
      const form = `
        <form id='editev' class='space-y-3'>
          <label class='label'>Заглавие</label>
          <input name='title' class='input w-full' value='${existing?.title||''}' required />
          <label class='label'>Описание</label>
          <textarea name='description' class='input min-h-[100px] w-full'>${existing?.description||''}</textarea>
          <label class='label'>Дата (YYYY-MM-DD)</label>
          <input name='date' class='input w-full' value='${existing? new Date(existing.date).toISOString().slice(0,10):''}' />
          <label class='label'>Тип</label>
          <input name='type' class='input w-full' value='${existing?.type||''}' />
          <label class='label'>Активно</label>
          <label class='flex items-center gap-2'><input type='checkbox' name='active' ${existing?.active? 'checked':''}/> Активно</label>
          <div class='flex justify-end'><button class='btn' type='submit'>Запази</button></div>
        </form>`
  const m5 = await import('../../components/Modal.js')
  const { el: modal, close } = m5.showModal({ title: 'Редакция на събитие', content: form })
      modal.querySelector('#editev')?.addEventListener('submit', async (e)=>{ e.preventDefault(); const data = Object.fromEntries(new FormData(e.currentTarget).entries()); data.id = id; data.date = new Date(data.date).getTime(); data.active = !!data.active; await saveEvent(data); close(); location.reload() })
    }))
    document.querySelectorAll('.delete-event').forEach(el=>el.addEventListener('click', async ()=>{
      const id = el.getAttribute('data-id')
  const m6 = await import('../../components/Modal.js')
  const { el: modal, close } = m6.showModal({ title: 'Потвърждение', content: `
        <div class='space-y-3'>
          <p>Сигурни ли сте, че искате да изтриете събитието?</p>
          <div class='flex justify-end gap-2'>
            <button class='btn-ghost' data-close='1' type='button'>Отказ</button>
            <button class='btn' id='confirm-del' type='button'>Изтрий</button>
          </div>
  </div>` })
      modal.querySelector('#confirm-del')?.addEventListener('click', async ()=>{ await deleteEvent(id); close(); location.reload() })
    }))
  }
}
