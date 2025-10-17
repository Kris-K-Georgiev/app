import { toggleTheme } from '../../utils/theme.js'
import { registerServiceWorker } from '../../pwa/sw-register.js'

export const SettingsPage = {
  async render(){
    return `
      <section class="max-w-xl mx-auto space-y-4">
        <h1 class="section-title">Настройки</h1>
        <div class="card p-5 space-y-3">
          <button id="toggle-theme" class="btn-outline w-full text-left">Смени тема</button>
          <button id="check-update" class="btn-outline w-full text-left">Провери за обновления</button>
          <div>
            <label class="flex items-center gap-2">
              <input id="notif-toggle" type="checkbox" class="rounded border-gray-300" />
              Нотификации (браузър)
            </label>
            <div class="text-xs opacity-70" id="notif-status"></div>
          </div>
          <div class="text-sm opacity-70">Версия: ${window.APP.version}</div>
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
      } else {
        registerServiceWorker()
      }
    })

    const status = document.getElementById('notif-status')
    const toggle = document.getElementById('notif-toggle')
    const updateStatus = () => {
      status.textContent = `Състояние: ${Notification?.permission||'unsupported'}`
      if (Notification?.permission === 'granted') toggle.checked = true
    }
    updateStatus()
    toggle?.addEventListener('change', async () => {
      if (!('Notification' in window)) { alert('Нотификациите не се поддържат.'); return }
      if (Notification.permission === 'granted') { status.textContent = 'Състояние: granted'; return }
      const perm = await Notification.requestPermission()
      if (perm === 'granted') new Notification('Нотификациите са активирани!')
      updateStatus()
    })
  }
}
