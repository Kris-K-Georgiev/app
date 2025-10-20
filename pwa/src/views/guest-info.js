export default function page() {
  return `
    <section class="flex flex-col items-center justify-center min-h-screen bg-gray-50">
      <div class="max-w-lg w-full bg-white rounded-lg shadow-lg p-8">
        <h2 class="text-2xl font-bold mb-4 text-blue-900">Информация за гости</h2>
        <p class="mb-4">Това приложение е създадено с мисия да подкрепя и свързва хората.</p>
        <ul class="mb-4 space-y-2">
          <li>• <b>Мисия:</b> Да изграждаме общност и подкрепа.</li>
          <li>• <b>Визия:</b> Единство, развитие, вдъхновение.</li>
          <li>• <b>Контакти:</b> info@example.com</li>
        </ul>
        <div class="bg-yellow-100 text-yellow-800 p-2 rounded text-center mb-2">За пълен достъп се изисква вход или регистрация</div>
      </div>
    </section>
  `;
}
