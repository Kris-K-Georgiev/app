export default function page() {
  return `
    <section class="flex flex-col items-center justify-center min-h-screen bg-gray-50">
      <div class="max-w-lg w-full bg-white rounded-lg shadow-lg p-8">
        <h2 class="text-2xl font-bold mb-4 text-blue-900">Общи условия</h2>
        <p class="mb-4 text-gray-700">Моля, прочетете и приемете Общите условия, за да продължите да използвате приложението.</p>
        <div class="h-40 overflow-y-auto border p-2 mb-4 text-xs bg-gray-100 rounded">Тук ще бъдат поставени Общите условия на платформата...</div>
        <div class="flex flex-col gap-2">
          <button id="accept-terms" class="w-full py-2 px-4 bg-blue-700 text-white rounded hover:bg-blue-800">Приемам</button>
          <button id="contact-admin" class="w-full py-2 px-4 bg-gray-200 text-blue-700 rounded hover:bg-gray-300">Въпроси към администратор</button>
        </div>
      </div>
    </section>
  `;
}
