import { create } from 'zustand'

export type AuthUser = { uid: string; email?: string|null; displayName?: string|null; photoURL?: string|null }
interface AuthState { 
  user: AuthUser | null; 
  setUser: (u: AuthUser | null) => void 
}

export const useAuthStore = create<AuthState>((set: any) => ({
  user: null,
  setUser: (u: AuthUser | null) => set({ user: u })
}))
