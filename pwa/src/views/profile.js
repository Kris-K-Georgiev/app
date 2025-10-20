export default function page() {
  return `
    <section class="max-w-xl mx-auto mt-8">
      <h2 class="text-2xl font-bold mb-4">Profile</h2>
      <div class="flex flex-col items-center">
        <div class="w-24 h-24 rounded-full bg-gray-200 mb-4"></div>
        <p class="font-semibold text-lg">John Doe</p>
        <p class="text-gray-500 mb-4">john@example.com</p>
        <button class="mt-2 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700">Edit Profile</button>
      </div>
    </section>
  `;
}
