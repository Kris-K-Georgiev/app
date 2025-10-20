export default function page() {
  return `
    <section class="flex flex-col items-center justify-center min-h-screen bg-gradient-to-b from-blue-100 to-blue-900">
      <div class="max-w-lg w-full bg-white rounded-lg shadow-lg p-8">
        <h2 class="text-2xl font-bold mb-4 text-blue-900">Добре дошли в платформата!</h2>
        <p class="mb-4">Това е място за общност, подкрепа и вдъхновение. Нашата мисия е да свързваме хората и да изграждаме по-добро бъдеще заедно.</p>
        <ul class="mb-6 space-y-2">
          <li>• <b>Feed</b> – Новини и публикации</li>
          <li>• <b>Молитви</b> – Споделяне и подкрепа</li>
          <li>• <b>Чат</b> – Комуникация в реално време</li>
          <li>• <b>Събития</b> – Организация и участие</li>
        </ul>
        <button id="onboarding-finish" class="w-full py-2 px-4 bg-blue-700 text-white rounded hover:bg-blue-800">Започни</button>
      </div>
    </section>
  `;
}
