import dayjs from 'dayjs'
import { getAuth } from '../../state/auth.js'
import { loadMessages, saveMessages } from './chatStore.js'

export const ChatRoomPage = {
  async render(ctx){
    const room = ctx?.params?.room || 'general'
    const msgs = loadMessages(room)
    return `
      <div class="h-screen flex flex-col">
        <!-- Header -->
        <div class="flex items-center justify-between gap-3 px-3 sm:px-4 md:px-6 py-3 sm:py-4 bg-white dark:bg-gray-900 border-b border-black/5 dark:border-white/10">
          <div class="flex items-center gap-2 sm:gap-3 min-w-0">
            <a href="#/chat" class="btn-ghost p-2 sm:p-2.5 shrink-0">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M15.41 16.59 10.83 12l4.58-4.59L14 6l-6 6 6 6z"/></svg>
            </a>
            <div class="min-w-0">
              <h1 class="text-base sm:text-lg font-semibold truncate">${room}</h1>
              <div class="text-xs opacity-70">${msgs.length} съобщения</div>
            </div>
          </div>
        </div>
        
        <!-- Messages -->
        <div id="chat-list" class="flex-1 overflow-y-auto p-3 sm:p-4 md:p-6 space-y-2 sm:space-y-3">
          ${msgs.map(m => `
            <div class="flex ${m.me? 'justify-end' : 'justify-start'}">
              <div class="max-w-[85%] sm:max-w-[70%] md:max-w-[60%] rounded-2xl px-3 sm:px-4 py-2 sm:py-2.5 text-xs sm:text-sm ${m.me? 'bg-primary text-white' : 'bg-black/5 dark:bg-white/10'}">
                <div class="text-[10px] sm:text-[11px] opacity-80 ${m.me?'text-white/80':'text-gray-600 dark:text-gray-300'}">${m.sender} · ${dayjs(m.at).format('HH:mm')}</div>
                <div class="mt-0.5 sm:mt-1">${m.text}</div>
              </div>
            </div>
          `).join('')}
        </div>
        
        <!-- Input -->
        <form id="chat-form" class="shrink-0 p-3 sm:p-4 md:p-6 bg-white dark:bg-gray-900 border-t border-black/5 dark:border-white/10">
          <div class="flex gap-2 sm:gap-3 max-w-5xl mx-auto">
            <input id="chat-input" class="input text-sm sm:text-base flex-1" placeholder="Напишете съобщение..." autocomplete="off" aria-label="Съобщение" />
            <button type="submit" class="btn text-sm sm:text-base px-4 sm:px-5 py-2 sm:py-2.5" aria-label="Изпрати">Изпрати</button>
          </div>
        </form>
      </div>
    `
  },
  afterRender(ctx){
    const room = ctx?.params?.room || 'general'
    const list = document.getElementById('chat-list')
    const form = document.getElementById('chat-form')
    const input = document.getElementById('chat-input')
    if (!form) return
    form.addEventListener('submit', (e)=>{
      e.preventDefault()
      const text = input.value.trim()
      if (!text) return
      const { user } = getAuth()
      const msgs = loadMessages(room)
      const msg = { text, me: true, at: Date.now(), sender: user?.name || user?.email?.split('@')[0] || 'Аз' }
      msgs.push(msg)
      saveMessages(room, msgs)
      const el = document.createElement('div')
      el.className = 'flex justify-end'
      el.innerHTML = `<div class="max-w-[70%] rounded-2xl px-4 py-2.5 text-sm bg-primary text-white"><div class="text-[11px] text-white/80">${msg.sender} · ${dayjs(msg.at).format('HH:mm')}</div><div class="mt-1">${msg.text}</div></div>`
      list.appendChild(el)
      input.value = ''
      list.scrollTop = list.scrollHeight
    })
    list.scrollTop = list.scrollHeight
  }
}
