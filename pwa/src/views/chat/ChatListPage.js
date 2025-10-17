import { loadRooms, saveRooms } from './chatStore.js'
import { showModal } from '../../components/Modal.js'

export const ChatListPage = {
  async render(){
    const rooms = loadRooms()
    return `
      <section class="w-full space-y-4">
        <div class="flex items-center justify-between flex-wrap gap-2">
          <h1 class="section-title text-xl sm:text-2xl mb-0">Чатове</h1>
          <button id="add-room" class="btn-ghost ripple-container text-xs sm:text-sm px-3 py-1.5" type="button" aria-label="Нова група">+ Нова група</button>
        </div>
        <div class="grid gap-3 sm:gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
          ${rooms.map(r=>`
            <a href="#/chat/${encodeURIComponent(r)}" class="card p-4 card-hover flex items-center justify-between group" role="link">
              <div class="flex items-center gap-3 min-w-0 flex-1">
                <div class="w-10 h-10 sm:w-12 sm:h-12 rounded-full bg-primary/10 dark:bg-primary/20 flex items-center justify-center text-primary font-semibold text-sm sm:text-base">
                  ${r.charAt(0).toUpperCase()}
                </div>
                <div class="min-w-0 flex-1">
                  <div class="font-medium text-sm sm:text-base truncate">${r}</div>
                  <div class="text-xs opacity-70">Чат група</div>
                </div>
              </div>
              <svg class="w-4 h-4 sm:w-5 sm:h-5 opacity-0 group-hover:opacity-70 transition-opacity" viewBox="0 0 24 24" fill="currentColor"><path d="M9 6l6 6-6 6"/></svg>
            </a>
          `).join('')}
        </div>
      </section>
    `
  },
  afterRender(){
    document.getElementById('add-room')?.addEventListener('click', ()=>{
      const { el } = showModal({ title: 'Нова група', content: `
        <form id='rform' class='space-y-3'>
          <input class='input w-full' name='name' placeholder='Име на група' required />
          <div class='flex justify-end'><button class='btn'>Създай</button></div>
        </form>
      `})
      el.querySelector('#rform')?.addEventListener('submit', (e)=>{
        e.preventDefault()
        const name = new FormData(e.currentTarget).get('name')?.toString()||''
        if (!name) return
        const rooms = loadRooms(); if (!rooms.includes(name)) rooms.push(name); saveRooms(rooms)
        location.hash = `#/chat/${encodeURIComponent(name)}`
        el.remove()
      })
    })
  }
}
