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
      <Card>
        <h5 className="text-lg">Няма налични събития</h5>
        <p className="text-sm opacity-75">Добавете данни във Firestore колекцията "events".</p>
      </Card>
    )
  }
  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {filtered.map(ev => (
        <Card key={ev.id} imgSrc={ev.cover}>
          <h5 className="text-xl font-bold tracking-tight">{ev.title}</h5>
          <p className="font-normal text-gray-700 dark:text-gray-400">{(ev.description||'').slice(0,120)}</p>
          <div className="flex gap-2 items-center">
            {ev.city && <Badge color="info">{ev.city}</Badge>}
            {ev.audience && <Badge color="purple">{ev.audience}</Badge>}
          </div>
        </Card>
      ))}
    </div>
  )
}
