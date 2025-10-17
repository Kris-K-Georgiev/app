import { useEffect, useState } from 'react'
import { auth, googleProvider } from './firebase'
import { onAuthStateChanged, signInWithEmailAndPassword, signInWithPopup, createUserWithEmailAndPassword, signOut as fbSignOut } from 'firebase/auth'

export function useAuthState() {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)
  useEffect(() => {
    const unsub = onAuthStateChanged(auth, u => { setUser(u); setLoading(false) })
    return () => unsub()
  }, [])
  return {
    user,
    loading,
    signInEmail: (email, password) => signInWithEmailAndPassword(auth, email, password),
    registerEmail: (email, password) => createUserWithEmailAndPassword(auth, email, password),
    signInGoogle: () => signInWithPopup(auth, googleProvider),
    signOut: () => fbSignOut(auth)
  }
}
