import { useEffect, useState } from 'react'
import { Card, Badge } from 'flowbite-react'
import { listEvents } from '../services/firestore'

export default function Dashboard() {
  const [events, setEvents] = useState([])
  useEffect(() => { listEvents().then(setEvents).catch(console.error) }, [])
  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {events.map(ev => (
        <Card key={ev.id} imgSrc={ev.cover}>
          <h5 className="text-xl font-bold tracking-tight">{ev.title}</h5>
          <p className="font-normal text-gray-700 dark:text-gray-400">{ev.description?.slice(0,120)}</p>
          <div className="flex gap-2 items-center">
            <Badge color="info">{ev.city}</Badge>
            {ev.audience && <Badge color="purple">{ev.audience}</Badge>}
          </div>
        </Card>
      ))}
      {events.length===0 && (
        <Card>
          <h5 className="text-lg">Няма налични събития</h5>
          <p className="text-sm opacity-75">Добавете данни във Firestore колекцията "events".</p>
        </Card>
      )}
    </div>
  )
}
