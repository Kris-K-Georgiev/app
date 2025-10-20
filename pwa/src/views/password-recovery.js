export default function page() {
  return `
    <section class="flex flex-col items-center justify-center min-h-screen bg-gradient-to-b from-blue-100 to-blue-900">
      <div class="max-w-md w-full bg-white rounded-lg shadow-lg p-8">
        <h2 class="text-2xl font-bold mb-6 text-blue-900">Забравена парола</h2>
        <form id="recovery-form" class="space-y-4">
          <input type="email" name="email" placeholder="Email" required class="w-full px-4 py-2 border rounded" />
          <button type="submit" class="w-full py-2 px-4 bg-blue-700 text-white rounded hover:bg-blue-800">Изпрати линк за възстановяване</button>
        </form>
        <div class="text-center text-sm mt-2">
          <a href="#login" class="text-blue-700 hover:underline">Обратно към вход</a>
        </div>
      </div>
    </section>
  `;
}
