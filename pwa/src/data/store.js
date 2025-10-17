import { openDB } from 'idb'
import { nanoid } from 'nanoid'

const DB_NAME = 'pwa-demo'
const DB_VERSION = 2

let dbPromise

export function getDB(){
  if (!dbPromise) {
    dbPromise = openDB(DB_NAME, DB_VERSION, {
      upgrade(db){
        if (!db.objectStoreNames.contains('news')) {
          const s = db.createObjectStore('news', { keyPath: 'id' })
          s.createIndex('createdAt', 'createdAt')
        }
        if (!db.objectStoreNames.contains('events')) {
          const s = db.createObjectStore('events', { keyPath: 'id' })
          s.createIndex('date', 'date')
        }
        if (!db.objectStoreNames.contains('users')) {
          db.createObjectStore('users', { keyPath: 'id' })
        }
        if (!db.objectStoreNames.contains('posts')) {
          const s = db.createObjectStore('posts', { keyPath: 'id' })
          s.createIndex('createdAt', 'createdAt')
        }
      }
    })
  }
  return dbPromise
}

export async function seedIfEmpty(){
  const db = await getDB()
  const count = (await db.getAllKeys('news')).length
  if (count === 0) {
    const demoNews = Array.from({length:5}).map((_,i)=>({
      id: nanoid(),
      title: `Демо новина ${i+1}`,
      cover: `https://picsum.photos/seed/news${i}/640/360`,
      content: 'Това е примерен текст за новина. Поддържа HTML и изображения.',
      images: [
        `https://picsum.photos/seed/news${i}a/800/500`,
        `https://picsum.photos/seed/news${i}b/800/500`
      ],
      createdAt: Date.now() - i*86400000
    }))
    const demoEvents = Array.from({length:6}).map((_,i)=>({
      id: nanoid(),
      title: `Събитие ${i+1}`,
      description: 'Описание на събитието',
      date: Date.now() + i*86400000,
      active: i%2===0,
      type: ['местно','национално','лимитирано'][i%3],
      limit: i%3===2? 50 : null,
      photos: [`https://picsum.photos/seed/event${i}/800/500`]
    }))
    // Seed news
    const txNews = db.transaction('news','readwrite')
    const newsStore = txNews.store
    for (const n of demoNews) await newsStore.add(n)
    await txNews.done

    // Seed events
    const txEvents = db.transaction('events','readwrite')
    const eventsStore = txEvents.store
    for (const e of demoEvents) await eventsStore.add(e)
    await txEvents.done

    // Seed posts
    const demoPosts = [
      { id: nanoid(), author: 'Мария', authorId: 'u1', avatar: 'https://i.pravatar.cc/60?img=5', text: 'Здравейте, това е първият ми пост! 😊', image: 'https://picsum.photos/seed/post1/800/450', createdAt: Date.now()-3600_000 },
      { id: nanoid(), author: 'Иван', authorId: 'u2', avatar: 'https://i.pravatar.cc/60?img=11', text: 'Снимка от събитието вчера.', image: 'https://picsum.photos/seed/post2/800/450', createdAt: Date.now()-18_000_000 },
      { id: nanoid(), author: 'Елисавета', authorId: 'u3', avatar: 'https://i.pravatar.cc/60?img=3', text: 'Хубав уикенд на всички!', image: '', createdAt: Date.now()-86_400_000 },
    ]
    const txPosts = db.transaction('posts','readwrite')
    const postsStore = txPosts.store
    for (const p of demoPosts) await postsStore.add(p)
    await txPosts.done
  }
}

export async function listNews(){ const db = await getDB(); return (await db.getAllFromIndex('news','createdAt')).reverse() }
export async function getNews(id){ const db = await getDB(); return db.get('news', id) }
export async function saveNews(item){ const db = await getDB(); if(!item.id) item.id=nanoid(); await db.put('news', item); return item }
export async function deleteNews(id){ const db = await getDB(); await db.delete('news', id) }

export async function listEvents(){ const db = await getDB(); return (await db.getAllFromIndex('events','date')) }
export async function getEvent(id){ const db = await getDB(); return db.get('events', id) }
export async function saveEvent(item){ const db = await getDB(); if(!item.id) item.id=nanoid(); await db.put('events', item); return item }
export async function deleteEvent(id){ const db = await getDB(); await db.delete('events', id) }

// Posts
export async function listPosts(){ const db = await getDB(); return (await db.getAllFromIndex('posts','createdAt')).reverse() }
export async function getPost(id){ const db = await getDB(); return db.get('posts', id) }
export async function savePost(item){ const db = await getDB(); if(!item.id) item.id=nanoid(); item.createdAt = item.createdAt||Date.now(); await db.put('posts', item); return item }
export async function deletePost(id){ const db = await getDB(); await db.delete('posts', id) }
