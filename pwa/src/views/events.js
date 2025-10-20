export default function page() {
  return `
    <section class="max-w-xl mx-auto mt-8">
      <h2 class="text-2xl font-bold mb-4">Events</h2>
      <ul class="divide-y divide-gray-200">
        <li class="py-4 flex items-center justify-between">
          <span>Event 1: Community Meetup</span>
          <span class="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">Upcoming</span>
        </li>
        <li class="py-4 flex items-center justify-between">
          <span>Event 2: Online Webinar</span>
          <span class="text-xs bg-green-100 text-green-800 px-2 py-1 rounded">Live</span>
        </li>
        <li class="py-4 flex items-center justify-between">
          <span>Event 3: Hackathon</span>
          <span class="text-xs bg-gray-100 text-gray-800 px-2 py-1 rounded">Past</span>
        </li>
      </ul>
    </section>
  `;
}
