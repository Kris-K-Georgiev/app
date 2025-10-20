export default function page() {
  return `
    <section class="flex flex-col items-center justify-center min-h-screen bg-gradient-to-b from-blue-100 to-blue-900">
      <div class="max-w-md w-full bg-white rounded-lg shadow-lg p-8">
        <h2 class="text-2xl font-bold mb-6 text-blue-900">Регистрация</h2>
        <form id="register-form" class="space-y-4">
          <input type="text" name="name" placeholder="Име и фамилия" required class="w-full px-4 py-2 border rounded" />
          <input type="email" name="email" placeholder="Email" required class="w-full px-4 py-2 border rounded" />
          <input type="password" name="password" placeholder="Парола" required class="w-full px-4 py-2 border rounded" />
          <select name="city" required class="w-full px-4 py-2 border rounded">
            <option value="">Избери град</option>
            <option value="София">София</option>
            <option value="Пловдив">Пловдив</option>
            <option value="Варна">Варна</option>
            <option value="В.Търново">В.Търново</option>
          </select>
          <select name="role" required class="w-full px-4 py-2 border rounded">
            <option value="">Избери роля</option>
            <option value="студент">Студент</option>
            <option value="варнавец">Варнавец</option>
            <option value="работник">Работник</option>
            <option value="директор">Директор</option>
          </select>
          <textarea name="info" placeholder="Допълнителна информация (по избор)" class="w-full px-4 py-2 border rounded"></textarea>
          <button type="submit" class="w-full py-2 px-4 bg-blue-700 text-white rounded hover:bg-blue-800">Регистрация</button>
        </form>
        <div class="text-center text-sm mt-2">
          Вече имате акаунт? <a href="#login" class="text-blue-700 hover:underline">Вход</a>
        </div>
      </div>
    </section>
  `;
}
