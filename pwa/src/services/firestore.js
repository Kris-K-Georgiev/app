import { db } from './firebase'
import { collection, doc, setDoc, getDoc, getDocs, query, where, addDoc, serverTimestamp, orderBy, limit } from 'firebase/firestore'

// Example collections based on Laravel models:
// users -> handled by Firebase Auth; profile fields stored under users/{uid}
// events -> events/{id} with typeRef, createdBy, registrations_count
// event_types -> event_types/{id}
// event_registrations -> events/{eventId}/registrations/{uid}
// news -> news/{id} with images subcollection and likes/comments subcollections

export async function ensureUserProfile(uid, data) {
  const ref = doc(db, 'users', uid)
  const snap = await getDoc(ref)
  if (!snap.exists()) {
    await setDoc(ref, { ...data, createdAt: serverTimestamp() })
  }
}

export async function listEvents() {
  const qs = query(collection(db, 'events'), orderBy('start_date', 'desc'), limit(20))
  const sn = await getDocs(qs)
  return sn.docs.map(d => ({ id: d.id, ...d.data() }))
}

export async function registerForEvent(eventId, uid) {
  const regCol = collection(db, 'events', eventId, 'registrations')
  await addDoc(regCol, { uid, status: 'registered', createdAt: serverTimestamp() })
}
