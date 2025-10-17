import { useMemo } from 'react'
import { DayPicker } from 'react-day-picker'
import 'react-day-picker/dist/style.css'
import { useContentStore } from '../stores/content'

export default function EventsCalendar() {
  const events = useContentStore(s => s.events)
  const days = useMemo(() => {
    const result = new Set()
    events.forEach(ev => {
      const d = ev.start_date || ev.date || ev.created_at
      if (d) result.add(new Date(d).toDateString())
    })
    return result
  }, [events])

  const setSelectedDate = useContentStore(s => s.setSelectedDate)
  const modifiers = { hasEvent: (day) => days.has(day.toDateString()) }
  function onDayClick(day) {
    const iso = new Date(day).toISOString().slice(0,10)
    setSelectedDate(iso)
  }

  return (
    <div className="rounded-xl border border-slate-200 dark:border-slate-700 p-2">
  <DayPicker onDayClick={onDayClick} modifiers={modifiers} modifiersClassNames={{ hasEvent: 'bg-sky-500 text-white rounded-full' }} />
    </div>
  )
}
