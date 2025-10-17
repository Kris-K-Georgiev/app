import { register } from '../../state/auth.js'

export const RegisterPage = {
  async render(){
    return `
      <section class="max-w-sm mx-auto card p-5 space-y-4">
        <h1 class="section-title mb-0">Регистрация</h1>
        <form id="register-form" class="space-y-3">
          <input name="name" placeholder="Име" class="input" required />
          <input name="email" type="email" placeholder="Имейл" class="input" required />
          <input name="password" type="password" placeholder="Парола" class="input" required />
          <button class="btn w-full">Създай акаунт</button>
        </form>
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
