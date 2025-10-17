import dayjs from 'dayjs'
import { getAuth } from '../../state/auth.js'
import { showModal } from '../../components/Modal.js'
function storageKey(room){ return `chatMessages:${room||'general'}` }
function loadMessages(room='general'){
  try { return JSON.parse(localStorage.getItem(storageKey(room))||'[]') } catch { return [] }
}
function saveMessages(room, list){ localStorage.setItem(storageKey(room), JSON.stringify(list)) }
function loadRooms(){ try { return JSON.parse(localStorage.getItem('chatRooms')||'["general","events","support"]') } catch { return ['general','events','support'] } }
function saveRooms(list){ localStorage.setItem('chatRooms', JSON.stringify(list)) }

export const ChatPage = {
  async render(){
    const params = new URLSearchParams(location.hash.split('?')[1]||'')
    const room = params.get('room')||'general'
    const msgs = loadMessages(room)
    const rooms = loadRooms()
    return `
      <section class="grid gap-4 lg:grid-cols-[18rem_1fr]">
        <div class="card p-4 space-y-2">
          <div class="flex items-center justify-between">
            <h2 class="font-semibold">Групи</h2>
            <button id="add-room" class="btn-ghost">+ Нова</button>
          </div>
          <div id="room-list" class="space-y-1">
            ${rooms.map(r=>`<a href="#/chat?room=${encodeURIComponent(r)}" class="block px-3 py-2 rounded ${r===room?'bg-black/5 dark:bg-white/10':''}">${r}</a>`).join('')}
          </div>
        </div>
        <div class="card p-0 overflow-hidden">
          <div class="flex items-center justify-between px-4 py-3 border-b border-black/5 dark:border-white/10">
            <h1 class="section-title mb-0">${room}</h1>
          </div>
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
        location.hash = `#/chat?room=${encodeURIComponent(name)}`
        el.remove()
      })
    })
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
      el.innerHTML = `<div class="max-w-[75%] rounded-2xl px-3 py-2 text-sm bg-primary text-white"><div class="text-[11px] text-white/80">${msg.sender} · ${dayjs(msg.at).format('HH:mm')}</div><div>${msg.text}</div></div>`
      list.appendChild(el)
      input.value = ''
      list.scrollTop = list.scrollHeight
    })
    list.scrollTop = list.scrollHeight
  }
}
