import { useMemo } from 'react'
import { useParams, Link } from 'react-router-dom'
import { useContentStore } from '../stores/content'
import { Card, Badge, Button } from 'flowbite-react'

export default function NewsDetail(){
  const { id } = useParams()
  const news = useContentStore(s => s.news)
  const item = useMemo(()=> news.find(n => n.id === id), [news, id])
  
  if(!item) {
    return (
      <div className="max-w-4xl mx-auto">
        <Card>
          <div className="text-center py-8">
            <h5 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
              Новината не е намерена
            </h5>
            <p className="text-sm text-gray-500 dark:text-gray-400 mb-4">
              Възможно е новината да е премахната или адресът да е неправилен.
            </p>
            <Button as={Link} to="/news" color="blue">
              Обратно към новините
            </Button>
          </div>
        </Card>
      </div>
    )
  }
  
  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Back button */}
      <div>
        <Button as={Link} to="/news" color="light" size="sm">
          ← Обратно към новините
        </Button>
      </div>
      
      {/* Main article */}
      <Card className="overflow-hidden">
        {(item.cover || item.image) && (
          <div className="w-full h-64 md:h-96 overflow-hidden">
            <img 
              src={item.cover || item.image} 
              alt={item.title}
              className="w-full h-full object-cover"
            />
          </div>
        )}
        
        <div className="p-6">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-4">
            {item.title}
          </h1>
          
          {/* Meta information */}
          <div className="flex flex-wrap gap-4 items-center mb-6 text-sm text-gray-500 dark:text-gray-400">
            {item.created_at && (
              <span>
                Публикувано: {new Date(item.created_at).toLocaleDateString('bg-BG')}
              </span>
            )}
            {item.created_by && (
              <span>
                Автор: {item.created_by}
              </span>
            )}
          </div>
          
          {/* Article content */}
          <div 
            className="prose prose-lg max-w-none dark:prose-invert prose-blue" 
            dangerouslySetInnerHTML={{ __html: item.content }} 
          />
          
          {/* Engagement badges */}
          <div className="flex flex-wrap gap-3 items-center mt-6 pt-6 border-t border-gray-200 dark:border-gray-700">
            {item.likes_count != null && (
              <Badge color="pink" size="lg">
                ❤️ {item.likes_count} харесвания
              </Badge>
            )}
            {item.comments_count != null && (
              <Badge color="info" size="lg">
                💬 {item.comments_count} коментара
              </Badge>
            )}
          </div>
        </div>
      </Card>
      
      {/* Comments section placeholder */}
      <Card>
        <div className="p-6 text-center">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
            Коментари
          </h3>
          <p className="text-sm text-gray-500 dark:text-gray-400">
            Системата за коментари ще бъде добавена скоро.
          </p>
        </div>
      </Card>
    </div>
  )
}
