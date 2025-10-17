import { register } from '../../state/auth.js'

export const RegisterPage = {
  async render(){
    return `
      <section class="max-w-sm mx-auto card p-4 space-y-4">
        <h1 class="text-xl font-semibold">Регистрация</h1>
        <form id="register-form" class="space-y-3">
          <input name="name" placeholder="Име" class="w-full rounded border-gray-300 dark:bg-white/10" required />
          <input name="email" type="email" placeholder="Имейл" class="w-full rounded border-gray-300 dark:bg-white/10" required />
          <input name="password" type="password" placeholder="Парола" class="w-full rounded border-gray-300 dark:bg-white/10" required />
          <button class="w-full px-4 py-2 bg-primary text-white rounded">Създай акаунт</button>
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
