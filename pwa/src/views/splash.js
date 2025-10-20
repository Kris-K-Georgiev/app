export default function page() {
  return `
    <section class="flex flex-col items-center justify-center min-h-screen bg-gradient-to-b from-yellow-200 to-blue-900">
      <div class="animate-pulse mb-8">
        <img src="/icons/icon-192x192.png" alt="App Logo" class="w-24 h-24 rounded-full shadow-lg" />
      </div>
      <h1 class="text-3xl font-bold text-white mb-4">Добре дошли!</h1>
      <p class="text-white text-lg mb-8">Зареждане...</p>
    </section>
  `;
}
