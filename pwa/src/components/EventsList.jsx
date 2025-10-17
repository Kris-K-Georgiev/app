import { Card, Badge } from 'flowbite-react'
import { useContentStore } from '../stores/content'

export default function EventsList() {
  const { events, selectedDate, selectedType, selectedCity } = useContentStore(s => ({
    events: s.events,
    selectedDate: s.selectedDate,
    selectedType: s.selectedType,
    selectedCity: s.selectedCity
  }))
  
  const filtered = events.filter(ev => {
    let ok = true
    if (selectedDate) {
      const d = (ev.start_date || ev.date || '').slice(0,10)
      ok = ok && d === selectedDate
    }
    if (selectedType) ok = ok && (ev.event_type_id === selectedType || ev.type?.slug === selectedType)
    if (selectedCity) ok = ok && (ev.city === selectedCity)
    return ok
  })
  
  if (!filtered.length) {
    return (
      <div className="w-full">
        <Card>
          <div className="text-center py-8">
            <h5 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
              Няма налични събития
            </h5>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              Добавете данни във Firestore колекцията "events" или променете филтрите.
            </p>
          </div>
        </Card>
      </div>
    )
  }
  
  return (
    <div className="w-full">
      <div className="grid gap-4 sm:grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        {filtered.map(ev => (
          <Card key={ev.id} className="overflow-hidden" imgSrc={ev.cover}>
            <div className="p-4">
              <h5 className="text-xl font-bold tracking-tight text-gray-900 dark:text-white mb-2 line-clamp-2">
                {ev.title}
              </h5>
              <p className="font-normal text-gray-700 dark:text-gray-400 mb-4 line-clamp-3">
                {(ev.description || '').slice(0,120)}
                {(ev.description || '').length > 120 && '...'}
              </p>
              
              {/* Event details */}
              <div className="space-y-2 mb-4 text-sm">
                {ev.start_date && (
                  <div className="flex items-center text-gray-600 dark:text-gray-300">
                    <span className="font-medium">Дата:</span>
                    <span className="ml-2">{new Date(ev.start_date).toLocaleDateString('bg-BG')}</span>
                  </div>
                )}
                {ev.start_time && (
                  <div className="flex items-center text-gray-600 dark:text-gray-300">
                    <span className="font-medium">Час:</span>
                    <span className="ml-2">{ev.start_time}</span>
                  </div>
                )}
                {ev.location && (
                  <div className="flex items-center text-gray-600 dark:text-gray-300">
                    <span className="font-medium">Място:</span>
                    <span className="ml-2 line-clamp-1">{ev.location}</span>
                  </div>
                )}
              </div>

              {/* Badges */}
              <div className="flex flex-wrap gap-2 items-center">
                {ev.city && (
                  <Badge color="info" size="sm">{ev.city}</Badge>
                )}
                {ev.audience && (
                  <Badge color="purple" size="sm">{ev.audience}</Badge>
                )}
                {ev.status && ev.status !== 'active' && (
                  <Badge color="warning" size="sm">{ev.status}</Badge>
                )}
                {ev.registrations_count !== null && ev.limit && (
                  <Badge color="gray" size="sm">
                    {ev.registrations_count}/{ev.limit}
                  </Badge>
                )}
              </div>
            </div>
          </Card>
        ))}
      </div>
      
      {/* Results count */}
      <div className="mt-4 text-center">
        <p className="text-sm text-gray-500 dark:text-gray-400">
          Показани {filtered.length} от {events.length} събития
        </p>
      </div>
    </div>
  )
}
