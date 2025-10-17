import { nanoid } from 'nanoid'

let state = {
  user: null,
  role: 'worker',
  emailVerified: false,
}

const listeners = new Set()

export function initAuth({ useFirebase }) {
  // Optional Firebase init if env provided
  if (useFirebase) {
    import('../vendors/firebase.js').then(m => m.initFirebase())
  }
  const saved = localStorage.getItem('auth')
  if (saved) {
    state = JSON.parse(saved)
    if (state.user) {
      state.user.registeredAt = state.user.registeredAt || Date.now()
      state.user.coverMeta = state.user.coverMeta || { yPercent: 0, zoom: 1 }
      state.user.coverURL = state.user.coverURL || ''
    }
  }
  notify()
}

export function onAuthChanged(cb) { listeners.add(cb); cb(state); return () => listeners.delete(cb) }
function notify(){ localStorage.setItem('auth', JSON.stringify(state)); listeners.forEach(l=>l(state)) }

export function login({ email, password }) {
  // demo local auth
  state.user = { id: nanoid(), email, name: email.split('@')[0], photoURL: '', coverURL: '', coverMeta: { yPercent: 0, zoom: 1 }, city: 'София', bio: '', phone: '', registeredAt: Date.now() }
  state.role = email.includes('admin') ? 'admin' : email.includes('director') ? 'director' : 'worker'
  state.emailVerified = true // set to false to simulate flow
  notify()
}

export function register({ email, password, name }) {
  state.user = { id: nanoid(), email, name, photoURL: '', coverURL: '', coverMeta: { yPercent: 0, zoom: 1 }, city: '', bio: '', phone: '', registeredAt: Date.now() }
  state.role = 'worker'
  state.emailVerified = false
  notify()
}

export function logout(){ state.user=null; notify() }
export function getAuth(){ return state }
export function updateProfile(patch){ if(!state.user) return; state.user = { ...state.user, ...patch }; notify() }
export function setRole(role){ state.role = role; notify() }
export function isAdmin(){ return ['admin','director'].includes(state.role) }

// WebAuthn (biometrics) demo stub
export async function setupBiometrics(){
  if (!('credentials' in navigator)) throw new Error('WebAuthn not supported')
  localStorage.setItem('webauthn-enabled', '1')
  return true
}
export function biometricsEnabled(){ return localStorage.getItem('webauthn-enabled')==='1' }
