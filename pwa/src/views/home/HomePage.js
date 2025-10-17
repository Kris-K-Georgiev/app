import { seedIfEmpty, listNews } from '../../data/store.js'

export const HomePage = {
  async render(){
    try {
      await seedIfEmpty()
      const news = (await listNews()) || []
      
      return `
        <section class="w-full max-w-2xl mx-auto space-y-4 reveal">
          <div class="flex items-center justify-between px-2 sm:px-0 mb-6">
            <h1 class="text-2xl sm:text-3xl font-bold">Начало</h1>
            <a href="#/events" class="btn-ghost text-sm sm:text-base px-3 py-1.5">Події</a>
          </div>
          
          ${news.length > 0 ? `
            <div class="space-y-0">
              ${news.map((n, idx) => `
                <article role="article" tabindex="0" class="card card-hover cursor-pointer border-b last:border-b-0 rounded-none first:rounded-t-xl last:rounded-b-xl transition-colors" data-news-id="${n.id}">
                  <div class="p-4 sm:p-5">
                    <!-- Header with avatar and author -->
                    <div class="flex items-start gap-3 mb-3">
                      <img src="https://i.pravatar.cc/48?img=${idx % 70}" class="w-10 h-10 sm:w-12 sm:h-12 rounded-full shrink-0" alt="author avatar"/>
                      <div class="min-w-0 flex-1">
                        <div class="flex items-center gap-2 flex-wrap">
                          <span class="font-semibold text-sm sm:text-base">Редакция</span>
                          <span class="text-xs sm:text-sm opacity-50">·</span>
                          <span class="text-xs sm:text-sm opacity-70">${new Date(n.createdAt).toLocaleDateString('bg-BG', { day: 'numeric', month: 'short' })}</span>
                        </div>
                        <h2 class="text-base sm:text-lg font-semibold mt-1 leading-snug">${n.title}</h2>
                      </div>
                    </div>
                    
                    <!-- Content preview -->
                    ${n.content ? `
                      <p class="text-sm sm:text-base opacity-80 leading-relaxed mb-3 line-clamp-3">${n.content.substring(0, 200)}...</p>
                    ` : ''}
                    
                    <!-- Cover image -->
                    ${n.cover ? `
                      <div class="relative overflow-hidden rounded-xl sm:rounded-2xl border border-black/5 dark:border-white/10 mb-3">
                        <img src="${n.cover}" alt="${n.title}" class="w-full aspect-video object-cover"/>
                      </div>
                    ` : ''}
                    
                    <!-- Actions (like Twitter) -->
                    <div class="flex items-center gap-4 sm:gap-6 text-xs sm:text-sm opacity-70 pt-2">
                      <button type="button" class="flex items-center gap-1.5 hover:text-blue-500 transition-colors" data-action="comment" aria-label="Коментари">
                        <svg width="16" height="16" class="sm:w-[18px] sm:h-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                          <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
                        </svg>
                        <span>${n.commentsCount || 0}</span>
                      </button>
                      
                      <button type="button" class="flex items-center gap-1.5 hover:text-green-500 transition-colors" data-action="retweet" aria-label="Споделяния">
                        <svg width="16" height="16" class="sm:w-[18px] sm:h-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                          <path d="M17 1l4 4-4 4"/>
                          <path d="M3 11V9a4 4 0 0 1 4-4h14"/>
                          <path d="M7 23l-4-4 4-4"/>
                          <path d="M21 13v2a4 4 0 0 1-4 4H3"/>
                        </svg>
                        <span>${n.sharesCount || 0}</span>
                      </button>
                      
                      <button type="button" class="flex items-center gap-1.5 hover:text-red-500 transition-colors" data-action="like" aria-label="Харесвания">
                        <svg width="16" height="16" class="sm:w-[18px] sm:h-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                          <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
                        </svg>
                        <span>${n.likesCount || 0}</span>
                      </button>
                      
                      <button type="button" class="flex items-center gap-1.5 hover:text-blue-400 transition-colors ml-auto" data-action="share" aria-label="Сподели">
                        <svg width="16" height="16" class="sm:w-[18px] sm:h-[18px]" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                          <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/>
                          <path d="M16 6l-4-4-4 4"/>
                          <path d="M12 2v13"/>
                        </svg>
                      </button>
                    </div>
                  </div>
                </article>
              `).join('')}
            </div>
          ` : `
            <div class="card p-8 sm:p-12 text-center">
              <svg width="64" height="64" class="mx-auto mb-4 opacity-20" viewBox="0 0 24 24" fill="currentColor">
                <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zM9 17H7v-7h2v7zm4 0h-2V7h2v10zm4 0h-2v-4h2v4z"/>
              </svg>
              <p class="text-base sm:text-lg opacity-70 mb-4">Все още няма новини</p>
              <p class="text-sm opacity-50 mb-6">Бъдете първите, които ще споделят нещо</p>
              <a href="#/admin" class="btn inline-flex items-center gap-2" role="button">Добави новина</a>
            </div>
          `}
        </section>
      `
    } catch (error) {
      console.error('HomePage render error:', error)
      return `
        <section class="w-full max-w-2xl mx-auto space-y-6">
          <div class="card p-8 sm:p-12 text-center">
            <svg width="48" height="48" class="mx-auto mb-3 text-red-500" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
            </svg>
            <p class="text-base opacity-70">Грешка при зареждане</p>
            <p class="text-xs mt-2 opacity-50">${error.message}</p>
          </div>
        </section>
      `
    }
  },
  afterRender(){
    // Click на цялата карта отваря детайлна страница
    document.querySelectorAll('article[data-news-id]').forEach(card => {
      card.addEventListener('click', (e) => {
        // Не навигирай ако е кликнат action бутон
        if (e.target.closest('button[data-action]')) return
        
        const newsId = card.getAttribute('data-news-id')
        window.location.hash = `#/news/${newsId}`
      })
    })
    
    // Action buttons (preventDefault за да не се отваря детайлна страница)
    document.querySelectorAll('button[data-action]').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation()
        const action = btn.getAttribute('data-action')
        const card = btn.closest('article')
        const span = btn.querySelector('span')
        const currentCount = parseInt(span?.textContent || '0')
        
        switch(action) {
          case 'like':
            if (span) span.textContent = currentCount + 1
            btn.classList.add('text-red-500')
            break
          case 'comment':
            const newsId = card.getAttribute('data-news-id')
            window.location.hash = `#/news/${newsId}#comments`
            break
          case 'retweet':
            if (span) span.textContent = currentCount + 1
            btn.classList.add('text-green-500')
            break
          case 'share':
            if (navigator.share) {
              navigator.share({ 
                title: card.querySelector('h2')?.textContent || 'Новина',
                url: window.location.href 
              })
            } else {
              navigator.clipboard?.writeText(window.location.href)
              alert('Връзката е копирана')
            }
            break
        }
      })
    })
  }
}
