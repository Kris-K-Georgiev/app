import { useMemo } from 'react'
import { useParams } from 'react-router-dom'
import { useContentStore } from '../stores/content'
import { Card, Badge } from 'flowbite-react'

export default function NewsDetail(){
  const { id } = useParams()
  const news = useContentStore(s => s.news)
  const item = useMemo(()=> news.find(n => n.id === id), [news, id])
  if(!item) return <div>Новината не е намерена.</div>
  return (
    <div className="space-y-4">
      <Card imgSrc={item.cover || item.image}>
        <h1 className="text-2xl font-bold">{item.title}</h1>
        <div className="prose prose-invert max-w-none" dangerouslySetInnerHTML={{ __html: item.content }} />
        <div className="flex gap-2 items-center">
          {item.likes_count!=null && <Badge color="pink">Харесвания: {item.likes_count}</Badge>}
          {item.comments_count!=null && <Badge color="info">Коментари: {item.comments_count}</Badge>}
        </div>
      </Card>
      {/* TODO: Коментари и харесвания – Firestore subcollections */}
    </div>
  )
}
