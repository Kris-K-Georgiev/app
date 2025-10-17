import { useEffect, useState } from 'react'
import { Card, Badge, Button } from 'flowbite-react'
import { Link } from 'react-router-dom'
import { listEvents } from '../services/firestore'
import { useContentStore } from '../stores/content'

export default function Dashboard() {
  const [events, setEvents] = useState([])
  const [loading, setLoading] = useState(true)
  const news = useContentStore(s => s.news)
  
  useEffect(() => { 
    listEvents()
      .then(setEvents)
      .catch(console.error)
      .finally(() => setLoading(false))
  }, [])
  
  // Get recent news (first 3)
  const recentNews = news.slice(0, 3)
  
  // Get upcoming events (first 4)
  const upcomingEvents = events.slice(0, 4)
  
  if (loading) {
    return (
      <div className="max-w-7xl mx-auto space-y-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 dark:bg-gray-700 rounded w-48 mb-4"></div>
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {[1,2,3].map(i => (
              <div key={i} className="h-48 bg-gray-200 dark:bg-gray-700 rounded"></div>
            ))}
          </div>
        </div>
      </div>
    )
  }
  
  return (
    <div className="max-w-7xl mx-auto space-y-8">
      {/* Welcome section */}
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-2">
          Добре дошли
        </h1>
        <p className="text-lg text-gray-600 dark:text-gray-400">
          Управлявайте събития, новини и файлове от едно място
        </p>
      </div>
      
      {/* Quick stats */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <div className="text-center">
            <div className="text-3xl font-bold text-blue-600 dark:text-blue-400">
              {events.length}
            </div>
            <div className="text-sm text-gray-500 dark:text-gray-400">
              Общо събития
            </div>
          </div>
        </Card>
        <Card>
          <div className="text-center">
            <div className="text-3xl font-bold text-green-600 dark:text-green-400">
              {news.length}
            </div>
            <div className="text-sm text-gray-500 dark:text-gray-400">
              Общо новини
            </div>
          </div>
        </Card>
        <Card>
          <div className="text-center">
            <div className="text-3xl font-bold text-purple-600 dark:text-purple-400">
              {upcomingEvents.filter(ev => new Date(ev.start_date) > new Date()).length}
            </div>
            <div className="text-sm text-gray-500 dark:text-gray-400">
              Предстоящи събития
            </div>
          </div>
        </Card>
      </div>
      
      {/* Recent news section */}
      <div className="space-y-4">
        <div className="flex justify-between items-center">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
            Последни новини
          </h2>
          <Button as={Link} to="/news" color="light" size="sm">
            Виж всички →
          </Button>
        </div>
        
        {recentNews.length > 0 ? (
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {recentNews.map(n => (
              <Card key={n.id} imgSrc={n.cover || n.image}>
                <h5 className="text-lg font-semibold line-clamp-2">{n.title}</h5>
                <p className="text-sm text-gray-700 dark:text-gray-400 line-clamp-3">
                  {(n.content || '').replace(/<[^>]+>/g, '').slice(0, 100)}...
                </p>
                <Button as={Link} to={`/news/${n.id}`} color="blue" size="sm">
                  Прочети
                </Button>
              </Card>
            ))}
          </div>
        ) : (
          <Card>
            <div className="text-center py-4">
              <p className="text-gray-500 dark:text-gray-400">Няма налични новини</p>
            </div>
          </Card>
        )}
      </div>
      
      {/* Upcoming events section */}
      <div className="space-y-4">
        <div className="flex justify-between items-center">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
            Предстоящи събития
          </h2>
          <Button as={Link} to="/events" color="light" size="sm">
            Виж всички →
          </Button>
        </div>
        
        {upcomingEvents.length > 0 ? (
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            {upcomingEvents.map(ev => (
              <Card key={ev.id} imgSrc={ev.cover}>
                <h5 className="text-lg font-semibold line-clamp-2">{ev.title}</h5>
                <p className="text-sm text-gray-700 dark:text-gray-400 line-clamp-2">
                  {(ev.description || '').slice(0, 80)}...
                </p>
                <div className="space-y-2">
                  {ev.start_date && (
                    <div className="text-xs text-gray-600 dark:text-gray-300">
                      📅 {new Date(ev.start_date).toLocaleDateString('bg-BG')}
                    </div>
                  )}
                  <div className="flex gap-1 flex-wrap">
                    {ev.city && <Badge color="info" size="sm">{ev.city}</Badge>}
                    {ev.audience && <Badge color="purple" size="sm">{ev.audience}</Badge>}
                  </div>
                </div>
              </Card>
            ))}
          </div>
        ) : (
          <Card>
            <div className="text-center py-4">
              <p className="text-gray-500 dark:text-gray-400">
                Няма налични събития. Добавете данни във Firestore колекцията "events".
              </p>
            </div>
          </Card>
        )}
      </div>
      
      {/* Quick actions */}
      <div className="space-y-4">
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
          Бързи действия
        </h2>
        <div className="grid gap-4 md:grid-cols-4">
          <Button as={Link} to="/events" color="blue" size="lg" className="h-20">
            <div className="text-center">
              <div className="text-2xl mb-1">📅</div>
              <div>Събития</div>
            </div>
          </Button>
          <Button as={Link} to="/news" color="green" size="lg" className="h-20">
            <div className="text-center">
              <div className="text-2xl mb-1">📰</div>
              <div>Новини</div>
            </div>
          </Button>
          <Button as={Link} to="/files" color="purple" size="lg" className="h-20">
            <div className="text-center">
              <div className="text-2xl mb-1">📁</div>
              <div>Файлове</div>
            </div>
          </Button>
          <Button as={Link} to="/profile" color="gray" size="lg" className="h-20">
            <div className="text-center">
              <div className="text-2xl mb-1">👤</div>
              <div>Профил</div>
            </div>
          </Button>
        </div>
      </div>
    </div>
  )
}
