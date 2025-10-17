import EventsFilters from './EventsFilters.jsx'
import EventsCalendar from './EventsCalendar.jsx'
import EventsList from './EventsList.jsx'

export default function EventsPage() {
  return (
    <div className="space-y-4">
      <EventsFilters />
      <div className="grid gap-4 md:grid-cols-2">
        <EventsCalendar />
        <div>
          <EventsList />
        </div>
      </div>
    </div>
  )
}
