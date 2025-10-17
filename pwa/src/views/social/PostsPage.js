import dayjs from 'dayjs'
import { getAuth } from '../../state/auth.js'
import { listPosts, savePost } from '../../data/store.js'

export const PostsPage = {
  async render(){
    const posts = await listPosts()
    const { user } = getAuth()
    return `
      <section class="space-y-4">
        <h1 class="section-title">Постове</h1>
        <div class="card p-4 space-y-3">
          <div class="flex items-center gap-3">
            <img src="${user?.photoURL||'https://i.pravatar.cc/60'}" class="w-10 h-10 rounded-full" alt="me"/>
            <input id="post-text" class="input" placeholder="Споделете какво ново..."/>
          </div>
          <div class="flex items-center justify-between">
            <div class="text-xs opacity-70">Прикачи снимка (placeholder)</div>
            <button id="post-submit" class="btn">Публикувай</button>
          </div>
        </div>
        <div class="space-y-4" id="posts-list">
          ${posts.map(p => `
            <article class="card overflow-hidden">
              <div class="p-4 flex items-center gap-3">
                <img src="${p.avatar||'https://i.pravatar.cc/60'}" class="w-10 h-10 rounded-full"/>
                <div>
                  <div class="font-medium">${p.author||'Потребител'}</div>
                  <div class="text-xs opacity-70">${dayjs(p.createdAt).fromNow?.() || dayjs(p.createdAt).format('DD.MM.YYYY HH:mm')}</div>
                </div>
              </div>
              ${p.image?`<img src="${p.image}" class="w-full aspect-[16/9] object-cover">`:''}
              <div class="p-4 pt-2 text-sm">${p.text}</div>
            </article>
          `).join('')}
        </div>
      </section>
    `
  },
  afterRender(){
    const submit = document.getElementById('post-submit')
    const input = document.getElementById('post-text')
    if (!submit || !input) return
    submit.addEventListener('click', async ()=>{
      const text = input.value.trim()
      if (!text) return
      const { user } = getAuth()
      const item = {
        author: user?.name || user?.email?.split('@')[0] || 'Потребител',
        authorId: user?.id || 'local',
        avatar: user?.photoURL || 'https://i.pravatar.cc/60',
        text,
        image: '',
      }
      const saved = await savePost(item)
      const list = document.getElementById('posts-list')
      const el = document.createElement('article')
      el.className = 'card overflow-hidden'
      el.innerHTML = `
        <div class="p-4 flex items-center gap-3">
          <img src="${saved.avatar}" class="w-10 h-10 rounded-full"/>
          <div>
            <div class="font-medium">${saved.author}</div>
            <div class="text-xs opacity-70">току-що</div>
          </div>
        </div>
        <div class="p-4 pt-2 text-sm">${saved.text}</div>
      `
      list.prepend(el)
      input.value = ''
    })
  }
}
