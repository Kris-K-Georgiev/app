import { useEffect } from 'react'
import { onAuthStateChanged } from 'firebase/auth'
import { auth } from '../services/firebase'
import { useAuthStore } from '../stores/auth'
import { ensureUserProfile } from '../services/firestore'

export function useAuthSync() {
  const setUser = useAuthStore((s: any) => s.setUser)
  useEffect(() => {
    const unsub = onAuthStateChanged(auth, async (u: any) => {
      if (u) {
        setUser({ uid: u.uid, email: u.email, displayName: u.displayName, photoURL: u.photoURL })
        await ensureUserProfile(u.uid, { email: u.email ?? null, name: u.displayName ?? null, photoURL: u.photoURL ?? null })
      } else {
        setUser(null)
      }
    })
    return () => unsub()
  }, [setUser])
}
