import { login, setupBiometrics, biometricsEnabled, getAuth } from '../../state/auth.js'

export const LoginPage = {
  async render(){
    const { user } = getAuth()
    if (user) return `<div class="w-full max-w-xl mx-auto card p-4 sm:p-6 text-sm sm:text-base">Вече сте влезли. <a class="text-primary" href="#/">Към началото</a></div>`
    return `
      <section class="w-full max-w-sm mx-auto card p-4 sm:p-5 space-y-4">
        <h1 class="text-xl sm:text-2xl font-semibold mb-0">Вход</h1>
        <form id="login-form" class="space-y-4">
          <div>
            <label class="label">Имейл</label>
            <input name="email" type="email" placeholder="you@example.com" class="input text-sm sm:text-base" required />
          </div>

          <div>
            <label class="label">Парола</label>
            <input name="password" type="password" placeholder="Парола" class="input text-sm sm:text-base" required />
          </div>

          <div>
            <button class="btn w-full text-sm sm:text-base" type="submit">Вход</button>
          </div>
        </form>

        <div class="flex gap-3">
          <button id="setup-bio" class="btn-outline w-full text-sm sm:text-base" type="button">Биометричен вход</button>
        </div>

        <p class="text-xs sm:text-sm">Нямате акаунт? <a href="#/register" class="text-primary">Регистрация</a></p>
      </section>
    `
  },
  afterRender(){
    document.getElementById('login-form')?.addEventListener('submit', e => {
      e.preventDefault()
      const data = Object.fromEntries(new FormData(e.currentTarget).entries())
      login(data)
      location.hash = '#/'
    })
    const bioBtn = document.getElementById('setup-bio')
    bioBtn?.addEventListener('click', async ()=>{
      try{ await setupBiometrics(); alert('Биометричният вход е активиран.'); }catch(e){ alert('Не се поддържа на това устройство.') }
    })
    if (biometricsEnabled()) {
      bioBtn?.classList.add('bg-green-100')
      bioBtn.textContent = 'Биометричен вход активиран'
    }
  }
}
