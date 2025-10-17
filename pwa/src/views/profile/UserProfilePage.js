import { getAuth } from '../../state/auth.js'
import { getDB } from '../../data/store.js'
import { renderSparkline, lastNDaysCounts } from '../../utils/sparkline.js'

export const UserProfilePage = {
  async render(ctx){
    const { id } = ctx.params
    // Users are not fully managed; try to fetch posts by this user for a header context
    const db = await getDB()
    const posts = await db.getAll('posts')
      const first = posts.find(p => p.authorId === id) || {}
    const name = first?.author || 'Потребител'
    const avatar = first?.avatar || 'https://i.pravatar.cc/100'
    const mine = getAuth().user?.id === id
  const userInfo = { name, email: '', phone: '', city: '', bio: '' }
  const minePosts = posts.filter(p=>p.authorId===id)
  const activity = lastNDaysCounts(minePosts, 30)
      // Initial skeleton while we potentially fetch posts/activity in future
      return `
        <section class="space-y-4">
          <div class="skeleton w-full h-40 rounded-xl"></div>
          <div class="grid gap-4 sm:grid-cols-[10rem_1fr]">
            <div class="skeleton w-40 h-40 rounded-xl"></div>
            <div class="space-y-3">
              <div class="skeleton h-6 w-1/3 rounded"></div>
              <div class="skeleton h-4 w-2/3 rounded"></div>
              <div class="skeleton h-4 w-1/2 rounded"></div>
            </div>
          </div>
        </section>
      `
  }
}
