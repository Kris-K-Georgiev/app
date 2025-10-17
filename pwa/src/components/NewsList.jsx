import { Card, Button } from 'flowbite-react'
import { useContentStore } from '../stores/content'
import { Link } from 'react-router-dom'

export default function NewsList() {
  const news = useContentStore(s => s.news)
  
  if (!news.length) {
    return (
      <div className="max-w-4xl mx-auto">
        <Card>
          <div className="text-center py-8">
            <h5 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
              Няма новини
            </h5>
            <p className="text-sm text-gray-500 dark:text-gray-400">
              Добавете документи в колекцията "news" за да видите новини тук.
            </p>
          </div>
        </Card>
      </div>
    )
  }
  
  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="text-center mb-8">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white">Новини</h1>
        <p className="text-gray-600 dark:text-gray-400 mt-2">
          Последни новини и актуализации
        </p>
      </div>
      
      <div className="space-y-6">
        {news.map(n => (
          <Card key={n.id} className="overflow-hidden hover:shadow-lg transition-shadow duration-200">
            <div className="md:flex">
              {/* Image section */}
              {(n.cover || n.image) && (
                <div className="md:w-1/3 h-48 md:h-auto">
                  <img 
                    src={n.cover || n.image} 
                    alt={n.title}
                    className="w-full h-full object-cover"
                  />
                </div>
              )}
              
              {/* Content section */}
              <div className={`p-6 ${(n.cover || n.image) ? 'md:w-2/3' : 'w-full'}`}>
                <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-3 line-clamp-2">
                  {n.title}
                </h2>
                
                {/* Meta information */}
                <div className="flex items-center gap-4 text-sm text-gray-500 dark:text-gray-400 mb-3">
                  {n.created_at && (
                    <span>
                      {new Date(n.created_at).toLocaleDateString('bg-BG')}
                    </span>
                  )}
                  {n.created_by && (
                    <span>
                      от {n.created_by}
                    </span>
                  )}
                </div>
                
                {/* Article excerpt */}
                <p className="text-gray-700 dark:text-gray-300 mb-4 line-clamp-3 leading-relaxed">
                  {(n.content || '').replace(/<[^>]+>/g, '').slice(0, 240)}
                  {(n.content || '').replace(/<[^>]+>/g, '').length > 240 && '...'}
                </p>
                
                {/* Read more button */}
                <div className="flex justify-between items-center">
                  <Button as={Link} to={`/news/${n.id}`} color="blue" size="sm">
                    Прочети повече →
                  </Button>
                  
                  {/* Engagement info */}
                  <div className="flex gap-4 text-sm text-gray-500 dark:text-gray-400">
                    {n.likes_count != null && (
                      <span>❤️ {n.likes_count}</span>
                    )}
                    {n.comments_count != null && (
                      <span>💬 {n.comments_count}</span>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </Card>
        ))}
      </div>
      
      {/* Results count */}
      <div className="text-center mt-8">
        <p className="text-sm text-gray-500 dark:text-gray-400">
          Показани {news.length} новини
        </p>
      </div>
    </div>
  )
}
