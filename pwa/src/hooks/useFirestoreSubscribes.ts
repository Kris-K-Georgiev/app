import { useEffect } from 'react'
import { db } from '../services/firebase'
import { collection, onSnapshot, orderBy, query } from 'firebase/firestore'
import { useContentStore } from '../stores/content'

export function useSubscribeEvents() {
  const setEvents = useContentStore(s => s.setEvents)
  useEffect(() => {
    const q = query(collection(db, 'events'), orderBy('start_date', 'desc'))
    const unsub = onSnapshot(q, snap => {
      const items = snap.docs.map(d => ({ id: d.id, ...d.data() })) as any[]
      setEvents(items)
    })
    return () => unsub()
  }, [setEvents])
}

export function useSubscribeNews() {
  const setNews = useContentStore(s => s.setNews)
  useEffect(() => {
    const q = query(collection(db, 'news'), orderBy('created_at', 'desc'))
    const unsub = onSnapshot(q, snap => {
      const items = snap.docs.map(d => ({ id: d.id, ...d.data() })) as any[]
      setNews(items)
    })
    return () => unsub()
  }, [setNews])
}
