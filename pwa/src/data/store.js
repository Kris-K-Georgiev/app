import { openDB } from 'idb'
import { nanoid } from 'nanoid'

const DB_NAME = 'pwa-demo'
const DB_VERSION = 1

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
    const tx = db.transaction(['news','events'],'readwrite')
    for (const n of demoNews) await tx.store.add(n)
    const evs = tx.db.transaction('events','readwrite')
    for (const e of demoEvents) await (await evs).store.add(e)
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
