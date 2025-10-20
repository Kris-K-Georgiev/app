export default function page() {
  return `
    <section class="max-w-xl mx-auto mt-8">
      <h2 class="text-2xl font-bold mb-4">Feed</h2>
      <div class="space-y-4">
        <div class="p-4 bg-white rounded-lg shadow flex items-center gap-4">
          <span class="inline-block w-10 h-10 bg-blue-100 rounded-full"></span>
          <div>
            <p class="font-semibold">User 1</p>
            <p class="text-gray-500">This is a sample post in the feed.</p>
          </div>
        </div>
        <div class="p-4 bg-white rounded-lg shadow flex items-center gap-4">
          <span class="inline-block w-10 h-10 bg-green-100 rounded-full"></span>
          <div>
            <p class="font-semibold">User 2</p>
            <p class="text-gray-500">Another example post, styled with Tailwind and Flowbite classes.</p>
          </div>
        </div>
      </div>
    </section>
  `;
}
