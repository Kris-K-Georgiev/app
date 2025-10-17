import { getAuth, updateProfile } from '../../state/auth.js'

export const ProfilePage = {
  async render(){
    const { user } = getAuth()
    if (!user) return `<div class="max-w-xl mx-auto card p-4">Моля, <a class="text-primary" href="#/login">влезте</a>.</div>`
    return `
      <section class="max-w-xl mx-auto card p-4 space-y-4">
        <div class="flex items-center gap-4">
          <img src="${user.photoURL||'https://i.pravatar.cc/100'}" class="w-16 h-16 rounded-full"/>
          <div>
            <div class="text-lg font-semibold">${user.name||'Без име'}</div>
            <div class="text-sm opacity-70">${user.email}</div>
          </div>
        </div>
        <form id="profile-form" class="space-y-3">
          <div>
            <label class="block text-sm mb-1">Име</label>
            <input name="name" class="w-full rounded border-gray-300 dark:bg-white/10" value="${user.name||''}"/>
          </div>
          <div>
            <label class="block text-sm mb-1">Град</label>
            <input name="city" class="w-full rounded border-gray-300 dark:bg-white/10" value="${user.city||''}"/>
          </div>
          <div>
            <label class="block text-sm mb-1">Био</label>
            <textarea name="bio" class="w-full rounded border-gray-300 dark:bg-white/10">${user.bio||''}</textarea>
          </div>
          <div class="grid grid-cols-2 gap-3">
            <div>
              <label class="block text-sm mb-1">Имейл</label>
              <input name="email" class="w-full rounded border-gray-300 dark:bg-white/10" value="${user.email||''}" disabled />
            </div>
            <div>
              <label class="block text-sm mb-1">Телефон</label>
              <input name="phone" class="w-full rounded border-gray-300 dark:bg-white/10" value="${user.phone||''}"/>
            </div>
          </div>
          <button class="px-4 py-2 bg-primary text-white rounded">Запази</button>
        </form>
      </section>
    `
  },
  afterRender(){
    const form = document.getElementById('profile-form')
    if (!form) return
    form.addEventListener('submit', (e)=>{
      e.preventDefault()
      const data = Object.fromEntries(new FormData(form).entries())
      updateProfile(data)
      alert('Профилът е обновен')
    })
  }
}
