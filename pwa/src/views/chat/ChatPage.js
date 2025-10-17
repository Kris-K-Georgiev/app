import dayjs from 'dayjs'
import { getAuth } from '../../state/auth.js'
function storageKey(room){ return `chatMessages:${room||'general'}` }
function loadMessages(room='general'){
  try { return JSON.parse(localStorage.getItem(storageKey(room))||'[]') } catch { return [] }
}
function saveMessages(room, list){ localStorage.setItem(storageKey(room), JSON.stringify(list)) }

export const ChatPage = {
  async render(){
    const room = (new URLSearchParams(location.hash.split('?')[1]||'')).get('room')||'general'
    const msgs = loadMessages(room)
    return `
      <section class="space-y-4">
        <div class="flex items-center justify-between">
          <h1 class="section-title mb-0">Чат</h1>
          <select id="chat-room" class="input max-w-40">
            <option value="general" ${room==='general'?'selected':''}>Общ</option>
            <option value="events" ${room==='events'?'selected':''}>Събития</option>
            <option value="support" ${room==='support'?'selected':''}>Поддръжка</option>
          </select>
        </div>
        <div class="card p-0 overflow-hidden">
          <div id="chat-list" class="p-4 space-y-3 max-h-[50vh] overflow-y-auto">
            ${msgs.map(m => `
              <div class="flex ${m.me? 'justify-end' : 'justify-start'}">
                <div class="max-w-[75%] rounded-2xl px-3 py-2 text-sm ${m.me? 'bg-primary text-white' : 'bg-black/5 dark:bg-white/10'}">
                  <div class="text-[11px] opacity-80 ${m.me?'text-white/80':'text-gray-600 dark:text-gray-300'}">${m.sender} · ${dayjs(m.at).format('HH:mm')}</div>
                  <div>${m.text}</div>
                </div>
              </div>
            `).join('')}
          </div>
          <form id="chat-form" class="p-3 border-t border-black/5 dark:border-white/10 flex gap-2">
            <input id="chat-input" class="input" placeholder="Напишете съобщение..." />
            <button class="btn">Изпрати</button>
          </form>
        </div>
      </section>
    `
  },
  afterRender(){
    const params = new URLSearchParams(location.hash.split('?')[1]||'')
    const room = params.get('room')||'general'
    const list = document.getElementById('chat-list')
    const form = document.getElementById('chat-form')
    const input = document.getElementById('chat-input')
    const roomSelect = document.getElementById('chat-room')
    if (!form) return
    roomSelect?.addEventListener('change', ()=>{
      const r = roomSelect.value
      params.set('room', r)
      location.hash = `#/chat?${params.toString()}`
    })
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
      el.innerHTML = `<div class="max-w-[75%] rounded-2xl px-3 py-2 text-sm bg-primary text-white"><div class="text-[11px] text-white/80">${msg.sender} · ${dayjs(msg.at).format('HH:mm')}</div><div>${msg.text}</div></div>`
      list.appendChild(el)
      input.value = ''
      list.scrollTop = list.scrollHeight
    })
    list.scrollTop = list.scrollHeight
  }
}
