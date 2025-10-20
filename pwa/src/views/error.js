export default function page({ message = 'Възникна грешка.' } = {}) {
  return `
    <section class="flex flex-col items-center justify-center min-h-screen bg-gradient-to-b from-yellow-200 to-blue-900">
      <div class="max-w-md w-full bg-white rounded-lg shadow-lg p-8 text-center">
        <h2 class="text-2xl font-bold mb-4 text-yellow-600">Грешка</h2>
        <p class="mb-4">${message}</p>
        <a href="#" class="w-full py-2 px-4 bg-blue-700 text-white rounded hover:bg-blue-800 inline-block">Към начална страница</a>
      </div>
    </section>
  `;
}
