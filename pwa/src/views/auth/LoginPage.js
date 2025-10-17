import { login, setupBiometrics, biometricsEnabled, getAuth } from '../../state/auth.js'

export const LoginPage = {
  async render(){
    const { user } = getAuth()
    if (user) return `<div class="max-w-xl mx-auto card p-4">Вече сте влезли. <a class="text-primary" href="#/">Към началото</a></div>`
    return `
      <section class="max-w-sm mx-auto card p-5 space-y-4">
        <h1 class="section-title mb-0">Вход</h1>
        <form id="login-form" class="space-y-3">
          <input name="email" type="email" placeholder="Имейл" class="input" required />
          <input name="password" type="password" placeholder="Парола" class="input" required />
          <button class="btn w-full">Вход</button>
        </form>
        <button id="setup-bio" class="btn-outline w-full">Биометричен вход</button>
        <p class="text-sm">Нямате акаунт? <a href="#/register" class="text-primary">Регистрация</a></p>
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
