import { getAuth } from '../../state/auth.js'
import { getDB } from '../../data/store.js'

export const UserProfilePage = {
  async render(ctx){
    const { id } = ctx.params
    // Users are not fully managed; try to fetch posts by this user for a header context
    const db = await getDB()
    const posts = await db.getAll('posts')
    const first = posts.find(p => p.authorId === id)
    const name = first?.author || 'Потребител'
    const avatar = first?.avatar || 'https://i.pravatar.cc/100'
    const mine = getAuth().user?.id === id
    return `
      <section class="max-w-2xl mx-auto space-y-4">
        <div class="card p-5 flex items-center gap-4">
          <img src="${avatar}" class="w-16 h-16 rounded-full"/>
          <div>
            <div class="text-lg font-semibold">${name}</div>
            <div class="text-sm opacity-70">${mine? 'Това сте вие' : ''}</div>
          </div>
        </div>
        <div class="card p-4">
          <h2 class="font-semibold mb-2">Постове</h2>
          <div class="space-y-3">
            ${posts.filter(p=>p.authorId===id).map(p=>`<div class='text-sm'>${p.text}</div>`).join('')||'<div class="text-sm opacity-70">Няма постове.</div>'}
          </div>
        </div>
      </section>
    `
  }
}
