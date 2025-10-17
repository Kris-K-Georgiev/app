import { getNews } from '../../data/store.js'

export const NewsDetailPage = {
  async render(ctx){
    const id = location.hash.split('/').pop()
    const n = await getNews(id)
    if (!n) return '<p>Новината не е намерена.</p>'
    return `
      <article class="space-y-4">
        <div class="card overflow-hidden">
          <img src="${n.cover}" class="w-full aspect-[16/9] object-cover"/>
        </div>
        <h1 class="section-title">${n.title}</h1>
        <div class="prose dark:prose-invert card p-4">${n.content}</div>
        ${n.images?.length?`<div class="grid gap-3 sm:grid-cols-2">${n.images.map(src => `<img src="${src}" class="w-full rounded"/>`).join('')}</div>`:''}
      </article>
    `
  }
}
