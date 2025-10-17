import { getAuth, isAdmin } from '../../state/auth.js'
import { listNews, saveNews, deleteNews, listEvents, saveEvent, deleteEvent } from '../../data/store.js'

export const AdminPage = {
  async render(){
    const { user } = getAuth()
    if (!user) return `<div class="max-w-xl mx-auto card p-4">Моля, <a class="text-primary" href="#/login">влезте</a>.</div>`
    if (!isAdmin()) return `<div class="max-w-xl mx-auto card p-4">Нямате права за достъп.</div>`

    const [news, events] = await Promise.all([listNews(), listEvents()])
    return `
      <section class="space-y-6">
        <h1 class="text-2xl font-semibold">Админ панел</h1>
        <div class="grid gap-6 lg:grid-cols-2">
          <div class="card p-4">
            <div class="flex items-center justify-between mb-3">
              <h2 class="font-semibold">Новини</h2>
              <button id="add-news" class="px-2 py-1 bg-primary text-white rounded">+ Добави</button>
            </div>
            <div class="space-y-2" id="news-list">
              ${news.map(n => `
                <div class="flex items-center justify-between p-2 rounded hover:bg-gray-50 dark:hover:bg-white/10">
                  <span>${n.title}</span>
                  <div class="space-x-2">
                    <button data-id="${n.id}" class="edit-news text-sm text-blue-600">Редакция</button>
                    <button data-id="${n.id}" class="delete-news text-sm text-red-600">Изтрий</button>
                  </div>
                </div>
              `).join('')}
            </div>
          </div>
          <div class="card p-4">
            <div class="flex items-center justify-between mb-3">
              <h2 class="font-semibold">Събития</h2>
              <button id="add-event" class="px-2 py-1 bg-primary text-white rounded">+ Добави</button>
            </div>
            <div class="space-y-2" id="events-list">
              ${events.map(e => `
                <div class="flex items-center justify-between p-2 rounded hover:bg-gray-50 dark:hover:bg-white/10">
                  <span>${e.title}</span>
                  <div class="space-x-2">
                    <button data-id="${e.id}" class="edit-event text-sm text-blue-600">Редакция</button>
                    <button data-id="${e.id}" class="delete-event text-sm text-red-600">Изтрий</button>
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
    function promptNews(existing){
      const title = prompt('Заглавие', existing?.title||'')
      if (!title) return
      const cover = prompt('Корица URL', existing?.cover||'')
      const content = prompt('Съдържание', existing?.content||'')
      return { ...(existing||{}), title, cover, content, images: existing?.images||[] }
    }
    document.getElementById('add-news')?.addEventListener('click', async ()=>{
      const item = promptNews()
      if (item) { await saveNews(item); location.reload() }
    })
    document.querySelectorAll('.edit-news').forEach(el=>el.addEventListener('click', async ()=>{
      const id = el.getAttribute('data-id')
      const existing = (await import('../../data/store.js')).getNews ? await (await import('../../data/store.js')).getNews(id) : null
      const item = promptNews(existing)
      if (item) { item.id = id; await saveNews(item); location.reload() }
    }))
    document.querySelectorAll('.delete-news').forEach(el=>el.addEventListener('click', async ()=>{
      const id = el.getAttribute('data-id')
      if (confirm('Изтриване?')) { await deleteNews(id); location.reload() }
    }))

    function promptEvent(existing){
      const title = prompt('Заглавие', existing?.title||'')
      if (!title) return
      const description = prompt('Описание', existing?.description||'')
      const date = new Date(prompt('Дата (YYYY-MM-DD)', existing? new Date(existing.date).toISOString().slice(0,10) : '')).getTime()
      const type = prompt('Тип (местно/национално/лимитирано)', existing?.type||'местно')
      const active = confirm('Активно?')
      const limit = type==='лимитирано' ? parseInt(prompt('Лимит', existing?.limit||'50')) : null
      return { ...(existing||{}), title, description, date, type, active, limit, photos: existing?.photos||[] }
    }
    document.getElementById('add-event')?.addEventListener('click', async ()=>{
      const item = promptEvent()
      if (item) { await saveEvent(item); location.reload() }
    })
    document.querySelectorAll('.edit-event').forEach(el=>el.addEventListener('click', async ()=>{
      const id = el.getAttribute('data-id')
      const existing = (await import('../../data/store.js')).getEvent ? await (await import('../../data/store.js')).getEvent(id) : null
      const item = promptEvent(existing)
      if (item) { item.id = id; await saveEvent(item); location.reload() }
    }))
    document.querySelectorAll('.delete-event').forEach(el=>el.addEventListener('click', async ()=>{
      const id = el.getAttribute('data-id')
      if (confirm('Изтриване?')) { await deleteEvent(id); location.reload() }
    }))
  }
}
