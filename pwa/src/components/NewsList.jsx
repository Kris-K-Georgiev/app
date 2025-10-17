import { Card } from 'flowbite-react'
import { useContentStore } from '../stores/content'
import { Link } from 'react-router-dom'

export default function NewsList() {
  const news = useContentStore(s => s.news)
  if (!news.length) return (
    <Card>
      <h5 className="text-lg">Няма новини</h5>
      <p className="text-sm opacity-75">Добавете документи в колекцията "news".</p>
    </Card>
  )
  return (
    <div className="space-y-4">
      {news.map(n => (
        <Card key={n.id} imgSrc={n.cover || n.image}>
          <h5 className="text-xl font-semibold">{n.title}</h5>
          <p className="line-clamp-3">{(n.content||'').replace(/<[^>]+>/g,'').slice(0,240)}</p>
          <div>
            <Link className="text-sky-500" to={`/news/${n.id}`}>Виж повече</Link>
          </div>
        </Card>
      ))}
    </div>
  )
}
