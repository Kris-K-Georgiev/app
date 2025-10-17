import { register } from '../../state/auth.js'

export const RegisterPage = {
  async render(){
    return `
      <section class="w-full max-w-sm mx-auto card p-4 sm:p-5 space-y-4">
        <h1 class="text-xl sm:text-2xl font-semibold mb-0">Регистрация</h1>
        <form id="register-form" class="space-y-4">
          <div>
            <label class="label">Име</label>
            <input name="name" placeholder="Име" class="input text-sm sm:text-base" required />
          </div>

          <div>
            <label class="label">Имейл</label>
            <input name="email" type="email" placeholder="you@example.com" class="input text-sm sm:text-base" required />
          </div>

          <div>
            <label class="label">Парола</label>
            <input name="password" type="password" placeholder="Парола" class="input text-sm sm:text-base" required />
          </div>

          <div>
            <button class="btn w-full text-sm sm:text-base" type="submit">Създай акаунт</button>
          </div>
        </form>
        <p class="text-xs sm:text-sm">Имате акаунт? <a href="#/login" class="text-primary">Вход</a></p>
      </section>
    `
  },
  afterRender(){
    document.getElementById('register-form')?.addEventListener('submit', e => {
      e.preventDefault()
      const data = Object.fromEntries(new FormData(e.currentTarget).entries())
      register(data)
      alert('Проверете имейл за верификация (демо).')
      location.hash = '#/'
    })
  }
}
