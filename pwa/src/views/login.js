export default function page() {
  return `
    <section class="flex flex-col items-center justify-center min-h-screen bg-gradient-to-b from-blue-100 to-blue-900">
      <div class="max-w-md w-full bg-white rounded-lg shadow-lg p-8">
        <h2 class="text-2xl font-bold mb-6 text-blue-900">Вход</h2>
        <form id="login-form" class="space-y-4">
          <input type="email" name="email" placeholder="Email" required class="w-full px-4 py-2 border rounded" />
          <input type="password" name="password" placeholder="Парола" required class="w-full px-4 py-2 border rounded" />
          <div class="flex justify-between items-center">
            <button type="submit" class="bg-blue-700 text-white px-4 py-2 rounded hover:bg-blue-800">Вход</button>
            <a href="#password-recovery" class="text-sm text-blue-700 hover:underline">Забравена парола?</a>
          </div>
        </form>
        <div class="my-4 flex flex-col gap-2">
          <button class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700">Вход с Google</button>
          <button class="bg-blue-800 text-white px-4 py-2 rounded hover:bg-blue-900">Вход с Facebook</button>
          <button class="bg-black text-white px-4 py-2 rounded hover:bg-gray-900">Вход с Apple</button>
        </div>
        <button id="guest-login" class="w-full py-2 px-4 bg-gray-200 text-blue-700 rounded hover:bg-gray-300 mb-2">Продължи като гост</button>
        <div class="text-center text-sm mt-2">
          Нямате акаунт? <a href="#register" class="text-blue-700 hover:underline">Регистрация</a>
        </div>
      </div>
    </section>
  `;
}
