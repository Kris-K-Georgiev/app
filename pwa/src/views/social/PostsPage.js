import dayjs from 'dayjs'
import { getAuth } from '../../state/auth.js'
import { listPosts, savePost, deletePost, getPost } from '../../data/store.js'
import { showModal, alertModal } from '../../components/Modal.js'

export const PostsPage = {
  async render(){
    const posts = await listPosts()
    const { user } = getAuth()
    return `
  <section class="w-full space-y-4 reveal">
        <h1 class="section-title text-xl sm:text-2xl">Постове</h1>
  <div class="card p-3 sm:p-4 space-y-3 card-hover">
            <div class="flex items-center gap-2 sm:gap-3">
            <img src="${user?.photoURL||'https://i.pravatar.cc/60'}" class="w-9 h-9 sm:w-10 sm:h-10 rounded-full" alt="me"/>
            <input id="post-text" class="input text-sm sm:text-base" placeholder="Споделете какво ново..." aria-label="Ново съдържание"/>
          </div>
          <div class="flex items-center justify-between flex-wrap gap-2">
            <div class="flex items-center gap-2 sm:gap-3">
              <input id="post-image" type="file" accept="image/*" class="hidden"/>
              <button id="pick-image" class="btn-ghost ripple-container text-xs sm:text-sm px-2 sm:px-3 py-1.5 sm:py-2" type="button" aria-label="Добави снимка">📷 Снимка</button>
              <img id="post-preview" class="hidden w-8 h-8 sm:w-10 sm:h-10 rounded object-cover"/>
            </div>
            <button id="post-submit" class="btn ripple-container text-xs sm:text-sm px-3 sm:px-4 py-1.5 sm:py-2" type="button" aria-label="Публикувай">Публикувай</button>
          </div>
        </div>
        <div class="space-y-3 sm:space-y-4" id="posts-list">
          ${posts.map(p => `
            <article class="card overflow-hidden reveal" data-id="${p.id}">
              <div class="p-3 sm:p-4 flex items-center gap-2 sm:gap-3 relative">
                <a href="#/user/${p.authorId||'unknown'}"><img src="${p.avatar||'https://i.pravatar.cc/60'}" class="w-9 h-9 sm:w-10 sm:h-10 rounded-full"/></a>
                <div class="min-w-0 flex-1">
                  <div class="font-medium text-sm sm:text-base truncate"><a class="hover:underline" href="#/user/${p.authorId||'unknown'}">${p.author||'Потребител'}</a></div>
                  <div class="text-[10px] sm:text-xs opacity-70">${dayjs(p.createdAt).fromNow?.() || dayjs(p.createdAt).format('DD.MM.YYYY HH:mm')}</div>
                </div>
                ${user && user.id===p.authorId ? `<div class="ml-auto">
                  <button class="btn-ghost ripple-container p-1.5 sm:p-2" data-menu="${p.id}" title="Опции">
                    <svg width="16" height="16" class="sm:w-[18px] sm:h-[18px]" viewBox="0 0 24 24" fill="currentColor"><circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg>
                  </button>
                </div>`:''}
              </div>
              ${p.image?`<img src="${p.image}" class="w-full aspect-video sm:aspect-[16/9] object-cover">`:''}
              <div class="p-3 sm:p-4 pt-2 text-xs sm:text-sm leading-relaxed">${p.text}</div>
              <div class="px-3 sm:px-4 pb-3 sm:pb-4 flex items-center gap-3 sm:gap-4 text-xs sm:text-sm">
                <button type="button" class="btn-ghost ripple-container text-xs sm:text-sm px-2 py-1" data-like="${p.id}" aria-label="Харесай">
                  <svg width="16" height="16" class="sm:w-[18px] sm:h-[18px]" viewBox="0 0 24 24" fill="currentColor"><path d="M12.1 8.64 12 8.77l-.1-.13C10.14 6.6 7.1 6.24 5.28 8.05c-1.73 1.72-1.73 4.5 0 6.22L12 21l6.72-6.73c1.73-1.72 1.73-4.5 0-6.22-1.82-1.81-4.86-1.45-6.62.81Z"/></svg>
                  <span>${p.likes||0}</span>
                </button>
                <button type="button" class="btn-ghost ripple-container text-xs sm:text-sm px-2 py-1" data-comment="${p.id}" aria-label="Коментар">
                  <svg width="16" height="16" class="sm:w-[18px] sm:h-[18px]" viewBox="0 0 24 24" fill="currentColor"><path d="M20 16a4 4 0 0 1-4 4H9l-5 3 1.5-4.5A4 4 0 0 1 4 16V8a4 4 0 0 1 4-4h8a4 4 0 0 1 4 4Z"/></svg>
                  Коментар
                </button>
                <button type="button" class="btn-ghost ripple-container text-xs sm:text-sm px-2 py-1" data-share="${p.id}" aria-label="Сподели">
                    <svg width="16" height="16" class="sm:w-[18px] sm:h-[18px]" viewBox="0 0 24 24" fill="currentColor"><path d="M16 8a3 3 0 1 0-2.83-4H13A3 3 0 1 0 16 8ZM6 14a3 3 0 1 0 2.83 4H9A3 3 0 1 0 6 14Zm8-4-4 2 4 2 4-2-4-2Z"/></svg>
                    Сподели
                </button>
              </div>
            </article>
          `).join('')}
        </div>
      </section>
    `
  },
  afterRender(){
    const submit = document.getElementById('post-submit')
    const input = document.getElementById('post-text')
    const fileInput = document.getElementById('post-image')
    const pickBtn = document.getElementById('pick-image')
    const preview = document.getElementById('post-preview')
    let imageData = ''
    pickBtn?.addEventListener('click', ()=> fileInput?.click())
    fileInput?.addEventListener('change', ()=>{
      const f = fileInput.files?.[0]
      if (!f) return
      const reader = new FileReader()
      reader.onload = (e)=>{
        imageData = e.target.result
        if (preview) { preview.src = imageData; preview.classList.remove('hidden') }
      }
      reader.readAsDataURL(f)
    })
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
        image: imageData,
        likes: 0,
        likedBy: [],
        comments: [],
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
        ${saved.image? `<img src="${saved.image}" class="w-full aspect-[16/9] object-cover">` : ''}
        <div class="p-4 pt-2 text-sm">${saved.text}</div>
      `
      list.prepend(el)
      input.value = ''
      imageData = ''
      if (preview) { preview.classList.add('hidden'); preview.src = '' }
    })

    // Delegated actions: like/comment/share/menu/edit/delete
    document.getElementById('posts-list')?.addEventListener('click', async (e)=>{
      const t = e.target.closest('button')
      if (!t) return
      const id = t.getAttribute('data-like')||t.getAttribute('data-comment')||t.getAttribute('data-share')||t.getAttribute('data-edit')||t.getAttribute('data-delete')||t.getAttribute('data-menu')
      if (!id) return
      const card = e.target.closest('article[data-id]')
      if (t.hasAttribute('data-like')) {
        // Toggle like with persistence
        const p = await getPost(id)
        const { user } = getAuth()
        const uid = user?.id||'anon'
        p.likedBy = p.likedBy||[]
        const i = p.likedBy.indexOf(uid)
        if (i>=0) {
          p.likedBy.splice(i,1)
        } else {
          p.likedBy.push(uid)
        }
        p.likes = p.likedBy.length
        await savePost(p)
        const span = t.querySelector('span')
        span.textContent = p.likes
      } else if (t.hasAttribute('data-comment')) {
        const p = await getPost(id)
        p.comments = p.comments||[]
        const body = `
          <div class='space-y-3'>
            <div class='max-h-60 overflow-auto space-y-2'>
              ${p.comments.map(c=>`<div class='text-sm'><span class='font-medium'>${c.author}</span>: ${c.text}</div>`).join('')||'<div class="text-sm opacity-70">Няма коментари</div>'}
            </div>
            <form id='cform' class='flex gap-2'>
              <input id='ctext' class='input flex-1' placeholder='Напишете коментар...'>
              <button class='btn'>Изпрати</button>
            </form>
          </div>
        `
        const { el } = showModal({ title: 'Коментари', content: body })
        el.querySelector('#cform')?.addEventListener('submit', async (ev)=>{
          ev.preventDefault()
          const text = el.querySelector('#ctext').value.trim()
          if (!text) return
          const { user } = getAuth()
          p.comments.push({ text, author: user?.name||'Аз', at: Date.now() })
          await savePost(p)
          el.querySelector('#modal-content .max-h-60').insertAdjacentHTML('beforeend', `<div class='text-sm'><span class='font-medium'>${user?.name||'Аз'}</span>: ${text}</div>`)        
          el.querySelector('#ctext').value = ''
        })
      } else if (t.hasAttribute('data-share')) {
        if (navigator.share) {
          navigator.share({ title: 'Пост', text: 'Виж този пост', url: location.href })
        } else {
          navigator.clipboard?.writeText(location.href)
          alert('Връзката е копирана.')
        }
      } else if (t.hasAttribute('data-menu')) {
        const { el } = showModal({ title: 'Опции', content: `
          <div class='space-y-2'>
            <button class='btn w-full' data-edit='${id}'>Редакция</button>
            <button class='btn-ghost w-full text-red-600' data-delete='${id}'>Изтрий</button>
          </div>
        `})
        el.addEventListener('click', (ev)=>{ const b = ev.target.closest('button[data-edit],[data-delete]'); if (b) el.remove() })
      } else if (t.hasAttribute('data-edit')) {
        const post = await getPost(id)
        const form = `
          <form id='pform' class='space-y-3'>
            <label class='label'>Текст</label>
            <textarea class='input min-h-[120px]' name='text'>${post.text||''}</textarea>
            <label class='label'>Снимка</label>
            <input class='input' name='imageUrl' placeholder='URL (по избор)' value='${post.image||''}'/>
            <input type='file' id='edit-image' accept='image/*'/>
            <div class='flex justify-end'><button class='btn'>Запази</button></div>
          </form>
        `
        const { el, close } = showModal({ title: 'Редакция на пост', content: form })
        let editImageData = ''
        el.querySelector('#edit-image')?.addEventListener('change', (ev)=>{
          const f = ev.target.files?.[0]; if (!f) return
          const reader = new FileReader(); reader.onload = (e)=>{ editImageData = e.target.result }; reader.readAsDataURL(f)
        })
        el.querySelector('#pform')?.addEventListener('submit', async (ev)=>{
          ev.preventDefault()
          const data = Object.fromEntries(new FormData(ev.currentTarget).entries())
          post.text = data.text
          post.image = editImageData || data.imageUrl || post.image
          await savePost(post)
          // Update UI card
          card.querySelector('.p-4.pt-2').textContent = data.text
          if (post.image) {
            if (card.querySelector('img')) card.querySelector('img').src = post.image
            else card.insertAdjacentHTML('beforeend', `<img src='${post.image}' class='w-full aspect-[16/9] object-cover'>`)
          }
          close()
        })
      } else if (t.hasAttribute('data-delete')) {
        const { el } = showModal({ title: 'Потвърждение', content: `
          <div class='space-y-3'>
            <p>Сигурни ли сте, че искате да изтриете поста?</p>
            <div class='flex justify-end gap-2'>
              <button class='btn-ghost' data-close='1'>Отказ</button>
              <button class='btn' id='confirm-del'>Изтрий</button>
            </div>
          </div>
        `})
        el.querySelector('#confirm-del')?.addEventListener('click', async ()=>{
          await deletePost(id)
          card.remove()
          el.remove()
        })
      }
    })
  }
}
