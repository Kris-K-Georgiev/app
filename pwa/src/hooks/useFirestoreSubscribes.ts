import { useEffect } from 'react'
import { db } from '../services/firebase'
import { collection, onSnapshot, orderBy, query } from 'firebase/firestore'
import { useContentStore } from '../stores/content'

export function useSubscribeEvents() {
  const setEvents = useContentStore((s: any) => s.setEvents)
  useEffect(() => {
    const q = query(collection(db, 'events'), orderBy('start_date', 'desc'))
    const unsub = onSnapshot(q, (snap: any) => {
      const items = snap.docs.map((d: any) => ({ id: d.id, ...d.data() }))
      setEvents(items)
    })
    return () => unsub()
  }, [setEvents])
}

export function useSubscribeNews() {
  const setNews = useContentStore((s: any) => s.setNews)
  useEffect(() => {
    const q = query(collection(db, 'news'), orderBy('created_at', 'desc'))
    const unsub = onSnapshot(q, (snap: any) => {
      const items = snap.docs.map((d: any) => ({ id: d.id, ...d.data() }))
      setNews(items)
    })
    return () => unsub()
  }, [setNews])
}
