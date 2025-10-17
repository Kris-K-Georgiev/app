import { seedIfEmpty, listNews } from '../../data/store.js'

export const HomePage = {
  async render(){
    await seedIfEmpty()
    const news = await listNews()
    return `
      <section class="space-y-4">
        <h1 class="section-title">Новини</h1>
        <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          ${news.map(n => `
            <a href="#/news/${n.id}" class="card card-hover overflow-hidden">
              <img src="${n.cover}" alt="${n.title}" class="w-full h-40 object-cover"/>
              <div class="p-4">
                <h3 class="font-medium">${n.title}</h3>
              </div>
            </a>
          `).join('')}
        </div>
      </section>
    `
  }
}
