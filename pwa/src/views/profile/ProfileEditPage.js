import { getAuth, updateProfile } from '../../state/auth.js'

export const ProfileEditPage = {
  async render(){
    const { user } = getAuth()
    if (!user) return `<div class="max-w-xl mx-auto card p-4">Моля, <a class="text-primary" href="#/login">влезте</a>.</div>`
    return `
      <section class="w-full max-w-3xl mx-auto space-y-3 sm:space-y-4">
        <div class="flex items-center gap-2 sm:gap-3 px-2 sm:px-0">
          <a href="#/profile" class="btn-ghost text-xs sm:text-sm px-2 py-1">← Назад</a>
          <h1 class="text-lg sm:text-xl font-semibold">Редакция на профил</h1>
        </div>
        <div class="card p-4 sm:p-5">
          <form id="profile-form" class="space-y-3 sm:space-y-4">
            <div>
              <label class="label text-xs sm:text-sm">Корица</label>
              <div class="h-20 sm:h-24 rounded-xl overflow-hidden bg-black/5 dark:bg-white/10 flex items-center justify-center relative">
                <img id="cover-preview" src="${user.coverURL||''}" class="w-full h-full object-cover ${user.coverURL?'':'hidden'} select-none" style="object-position: center ${user.coverMeta?.yPercent||0}%; transform: scale(${user.coverMeta?.zoom||1});"/>
                <span id="cover-placeholder" class="text-xs sm:text-sm opacity-70 ${user.coverURL?'hidden':''}">Няма избрана корица</span>
              </div>
              <input id="cover-file" type="file" accept="image/*" class="input mt-2 text-xs sm:text-sm" />
              <div class="mt-2 grid grid-cols-1 sm:grid-cols-2 gap-2 sm:gap-3">
                <label class="text-[10px] sm:text-xs flex items-center gap-2">Позиция по Y
                  <input id="cover-y" type="range" min="-50" max="50" step="1" value="${user.coverMeta?.yPercent||0}" class="w-full"/>
                </label>
                <label class="text-[10px] sm:text-xs flex items-center gap-2">Мащаб
                  <input id="cover-zoom" type="range" min="1" max="1.6" step="0.01" value="${user.coverMeta?.zoom||1}" class="w-full" />
                </label>
              </div>
            </div>
            <div class="flex flex-col sm:flex-row items-start sm:items-center gap-3 sm:gap-4">
              <img src="${user.photoURL||'https://i.pravatar.cc/120'}" class="w-16 h-16 sm:w-20 sm:h-20 rounded-xl sm:rounded-2xl object-cover"/>
              <div class="flex-1 w-full">
                <label class="label text-xs sm:text-sm">Снимка</label>
                <input id="avatar-file" type="file" accept="image/*" class="input text-xs sm:text-sm" />
                <div class="text-[10px] sm:text-xs opacity-70 mt-1">Ще се запише като data URL за демо.</div>
              </div>
            </div>
            <div>
              <label class="label text-xs sm:text-sm">Име</label>
              <input name="name" class="input text-sm sm:text-base" value="${user.name||''}"/>
            </div>
            <div>
              <label class="label text-xs sm:text-sm">Град</label>
              <input name="city" class="input text-sm sm:text-base" value="${user.city||''}"/>
            </div>
            <div>
              <label class="label text-xs sm:text-sm">Био</label>
              <textarea name="bio" class="input min-h-[80px] sm:min-h-[96px] text-sm sm:text-base">${user.bio||''}</textarea>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label class="label text-xs sm:text-sm">Имейл</label>
                <input name="email" class="input opacity-70 text-sm sm:text-base" value="${user.email||''}" disabled />
              </div>
              <div>
                <label class="label text-xs sm:text-sm">Телефон</label>
                <input name="phone" class="input text-sm sm:text-base" value="${user.phone||''}"/>
              </div>
            </div>
            <div class="flex justify-end gap-2 pt-2">
              <a href="#/profile" class="btn-outline text-xs sm:text-sm px-3 sm:px-4 py-1.5 sm:py-2">Отказ</a>
              <button class="btn text-xs sm:text-sm px-3 sm:px-4 py-1.5 sm:py-2">Запази</button>
            </div>
          </form>
        </div>
      </section>
    `
  },
  afterRender(){
    const form = document.getElementById('profile-form')
    const coverFileInput = document.getElementById('cover-file')
    const coverPreview = document.getElementById('cover-preview')
    const coverPlaceholder = document.getElementById('cover-placeholder')
    coverFileInput?.addEventListener('change', ()=>{
      const f = coverFileInput.files?.[0]
      if (!f) return
      const reader = new FileReader()
      reader.onload = () => { if (coverPreview && coverPlaceholder){ coverPreview.src = reader.result; coverPreview.classList.remove('hidden'); coverPlaceholder.classList.add('hidden') } }
      reader.readAsDataURL(f)
    })

    const yRange = document.getElementById('cover-y')
    yRange?.addEventListener('input', ()=>{
      if (coverPreview) coverPreview.style.objectPosition = `center ${yRange.value}%`
    })
    const zRange = document.getElementById('cover-zoom')
    zRange?.addEventListener('input', ()=>{
      if (coverPreview) coverPreview.style.transform = `scale(${zRange.value})`
    })

    // Drag to adjust Y position
    let dragging = false, startY = 0, startVal = 0
    coverPreview?.addEventListener('pointerdown', (e)=>{
      dragging = true; startY = e.clientY; startVal = parseFloat(yRange?.value||'0'); coverPreview.setPointerCapture?.(e.pointerId)
    })
    coverPreview?.addEventListener('pointermove', (e)=>{
      if (!dragging) return
      const dy = e.clientY - startY
      const next = Math.max(-50, Math.min(50, startVal + Math.round(-dy/2)))
      if (yRange) { yRange.value = String(next); yRange.dispatchEvent(new Event('input')) }
    })
    coverPreview?.addEventListener('pointerup', ()=>{ dragging = false })

    form?.addEventListener('submit', async (e)=>{
      e.preventDefault()
      const data = Object.fromEntries(new FormData(form).entries())
      // handle avatar file
      const file = document.getElementById('avatar-file')?.files?.[0]
      const coverFile = document.getElementById('cover-file')?.files?.[0]

      const applyAndGo = (patch) => {
        const coverMeta = { yPercent: parseInt(document.getElementById('cover-y')?.value||'0',10), zoom: parseFloat(document.getElementById('cover-zoom')?.value||'1') }
        updateProfile({ ...data, ...patch, coverMeta });
        location.hash = '#/profile'
      }

      if (file || coverFile) {
        const toRead = []
        if (file) toRead.push(new Promise(res=>{ const r=new FileReader(); r.onload=()=>res({ photoURL: r.result }); r.readAsDataURL(file) }))
        if (coverFile) toRead.push(new Promise(res=>{ const r=new FileReader(); r.onload=()=>res({ coverURL: r.result }); r.readAsDataURL(coverFile) }))
        const patches = await Promise.all(toRead)
        const patch = patches.reduce((a,b)=>({ ...a, ...b }), {})
        applyAndGo(patch)
      } else {
        applyAndGo({})
      }
    })
  }
}
