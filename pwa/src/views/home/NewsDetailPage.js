import { getNews } from '../../data/store.js'

export const NewsDetailPage = {
  async render(ctx){
    const id = location.hash.split('/').pop()
    const n = await getNews(id)
    if (!n) return '<p>Новината не е намерена.</p>'
    return `
      <article class="max-w-3xl mx-auto space-y-4">
        <img src="${n.cover}" class="w-full rounded"/>
        <h1 class="text-3xl font-semibold">${n.title}</h1>
        <div class="prose dark:prose-invert">${n.content}</div>
        <div class="grid gap-3 md:grid-cols-2">
          ${n.images.map(src => `<img src="${src}" class="w-full rounded"/>`).join('')}
        </div>
      </article>
    `
  }
}
