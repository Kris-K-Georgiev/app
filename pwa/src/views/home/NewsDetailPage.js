import { getNews } from '../../data/store.js'

export const NewsDetailPage = {
  async render(ctx){
    const id = location.hash.split('/').pop()
    const n = await getNews(id)
    if (!n) return '<div class="max-w-2xl mx-auto card p-4 sm:p-6">Новината не е намерена.</div>'
    return `
      <article class="w-full max-w-4xl mx-auto space-y-4 sm:space-y-6">
        <div class="card overflow-hidden">
          <img src="${n.cover}" alt="cover" class="w-full aspect-video sm:aspect-[16/9] object-cover"/>
        </div>
        <h1 class="text-2xl sm:text-3xl md:text-4xl font-bold leading-tight px-2 sm:px-0">${n.title}</h1>
        <div class="prose prose-sm sm:prose lg:prose-lg dark:prose-invert card p-4 sm:p-6 max-w-none">${n.content}</div>
        ${n.images?.length?`<div class="grid gap-3 sm:gap-4 grid-cols-1 sm:grid-cols-2">${n.images.map(src => `<img src="${src}" alt="news image" class="w-full rounded-lg shadow"/>`).join('')}</div>`:''}
        <div class="flex gap-2">
          <button class="btn-ghost" type="button" onclick="window.print()">Печат</button>
          <button class="btn-ghost" type="button" onclick="navigator.clipboard?.writeText(location.href).then(()=>alert('Копирано'))">Копирай линк</button>
        </div>
      </article>
    `
  }
}
