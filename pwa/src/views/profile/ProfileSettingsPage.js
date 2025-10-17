import { getAuth } from '../../state/auth.js'
import { toggleTheme } from '../../utils/theme.js'

export const ProfileSettingsPage = {
  async render(){
    const { user } = getAuth()
    if (!user) return `<div class="max-w-xl mx-auto card p-4">Моля, <a class="text-primary" href="#/login">влезте</a>.</div>`
    return `
      <section class="w-full max-w-2xl mx-auto space-y-3 sm:space-y-4">
        <div class="flex items-center gap-2 sm:gap-3 px-2 sm:px-0">
          <a href="#/profile" class="btn-ghost text-xs sm:text-sm px-2 py-1">← Назад</a>
          <h1 class="text-lg sm:text-xl font-semibold">Настройки</h1>
        </div>
        <div class="card p-4 sm:p-5 space-y-2 sm:space-y-3">
          <button id="toggle-theme" class="btn-outline w-full text-left text-sm sm:text-base px-3 sm:px-4 py-2 sm:py-2.5">Смени тема</button>
          <button id="check-update" class="btn-outline w-full text-left text-sm sm:text-base px-3 sm:px-4 py-2 sm:py-2.5">Провери за обновления</button>
          <label class="flex items-center gap-2 sm:gap-3 py-2">
            <input id="notif-toggle" type="checkbox" class="rounded border-gray-300 w-4 h-4" />
            <span class="text-sm sm:text-base">Нотификации (браузър)</span>
          </label>
          <div class="text-[10px] sm:text-xs opacity-70 pl-6 sm:pl-7" id="notif-status"></div>
        </div>
      </section>
    `
  },
  afterRender(){
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
