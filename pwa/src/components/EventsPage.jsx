import EventsFilters from './EventsFilters.jsx'
import EventsCalendar from './EventsCalendar.jsx'
import EventsList from './EventsList.jsx'

export default function EventsPage() {
  return (
    <div className="max-w-7xl mx-auto space-y-6">
      {/* Page header */}
      <div className="text-center">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
          Събития
        </h1>
        <p className="text-gray-600 dark:text-gray-400">
          Разгледайте предстоящи събития и се регистрирайте
        </p>
      </div>
      
      {/* Filters */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 p-4">
        <h2 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
          Филтри
        </h2>
        <EventsFilters />
      </div>
      
      {/* Main content */}
      <div className="grid gap-6 lg:grid-cols-4">
        {/* Calendar sidebar */}
        <div className="lg:col-span-1">
          <div className="sticky top-4">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
              Календар
            </h3>
            <EventsCalendar />
          </div>
        </div>
        
        {/* Events list */}
        <div className="lg:col-span-3">
          <EventsList />
        </div>
      </div>
    </div>
  )
}
