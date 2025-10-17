import { getAuth, updateProfile } from '../../state/auth.js'

export const ProfilePage = {
  async render(){
    const { user } = getAuth()
    if (!user) return `<div class="max-w-xl mx-auto card p-4">Моля, <a class="text-primary" href="#/login">влезте</a>.</div>`
    const tab = (new URLSearchParams(location.hash.split('?')[1]||''))?.get('tab')||'profile'
    return `
      <section class="max-w-2xl mx-auto space-y-4">
        <div class="card p-5 flex items-center justify-between">
          <div class="flex items-center gap-4">
            <img src="${user.photoURL||'https://i.pravatar.cc/100'}" class="w-16 h-16 rounded-full"/>
            <div>
              <div class="text-lg font-semibold">${user.name||'Без име'}</div>
              <div class="text-sm opacity-70">${user.email}</div>
            </div>
          </div>
          <nav class="flex gap-2">
            <a href="#/profile?tab=profile" class="btn-ghost ${tab==='profile'?'bg-black/5 dark:bg-white/10':''}">Профил</a>
            <a href="#/profile?tab=settings" class="btn-ghost ${tab==='settings'?'bg-black/5 dark:bg-white/10':''}">Настройки</a>
          </nav>
        </div>
        ${tab==='profile' ? `
          <div class="card p-5">
            <form id="profile-form" class="space-y-4">
              <div>
                <label class="label">Име</label>
                <input name="name" class="input" value="${user.name||''}"/>
              </div>
              <div>
                <label class="label">Град</label>
                <input name="city" class="input" value="${user.city||''}"/>
              </div>
              <div>
                <label class="label">Био</label>
                <textarea name="bio" class="input min-h-[96px]">${user.bio||''}</textarea>
              </div>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label class="label">Имейл</label>
                  <input name="email" class="input opacity-70" value="${user.email||''}" disabled />
                </div>
                <div>
                  <label class="label">Телефон</label>
                  <input name="phone" class="input" value="${user.phone||''}"/>
                </div>
              </div>
              <div class="flex justify-end">
                <button class="btn">Запази</button>
              </div>
            </form>
          </div>
        ` : `
          <div class="card p-5 space-y-3">
            <button id="toggle-theme" class="btn-outline w-full text-left">Смени тема</button>
            <button id="check-update" class="btn-outline w-full text-left">Провери за обновления</button>
            <label class="flex items-center gap-2">
              <input id="notif-toggle" type="checkbox" class="rounded border-gray-300" />
              Нотификации (браузър)
            </label>
            <div class="text-xs opacity-70" id="notif-status"></div>
          </div>
        `}
      </section>
    `
  },
  afterRender(){
    const form = document.getElementById('profile-form')
    if (form) {
      form.addEventListener('submit', (e)=>{
        e.preventDefault()
        const data = Object.fromEntries(new FormData(form).entries())
        updateProfile(data)
        alert('Профилът е обновен')
      })
    }
    // Settings handlers
    const { toggleTheme } = require('../../utils/theme.js')
    document.getElementById('toggle-theme')?.addEventListener('click', toggleTheme)
    document.getElementById('check-update')?.addEventListener('click', ()=>{
      if (navigator.serviceWorker?.ready) {
        navigator.serviceWorker.ready.then(reg=>reg.update())
        alert('Проверка за обновления...')
      }
    })
    const status = document.getElementById('notif-status')
    const toggle = document.getElementById('notif-toggle')
    if (status && toggle) {
      const updateStatus = () => {
        status.textContent = `Състояние: ${Notification?.permission||'unsupported'}`
        if (Notification?.permission === 'granted') toggle.checked = true
      }
      updateStatus()
      toggle.addEventListener('change', async () => {
        if (!('Notification' in window)) { alert('Нотификациите не се поддържат.'); return }
        if (Notification.permission === 'granted') { status.textContent = 'Състояние: granted'; return }
        const perm = await Notification.requestPermission()
        if (perm === 'granted') new Notification('Нотификациите са активирани!')
        updateStatus()
      })
    }
  }
}
