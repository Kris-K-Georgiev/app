export default function page() {
  return `
    <section class="flex flex-col items-center justify-center min-h-screen bg-gradient-to-b from-yellow-200 to-blue-900">
      <div class="max-w-md w-full bg-white rounded-lg shadow-lg p-8 text-center">
        <h2 class="text-2xl font-bold mb-4 text-blue-900">Няма връзка с интернет</h2>
        <p class="mb-4">Моля, проверете връзката си и опитайте отново.</p>
        <button id="retry-offline" class="w-full py-2 px-4 bg-yellow-400 text-blue-900 rounded hover:bg-yellow-500">Опитай отново</button>
      </div>
    </section>
  `;
}
