import { create } from 'zustand'

export type AuthUser = { uid: string; email?: string|null; displayName?: string|null; photoURL?: string|null }
type State = { user: AuthUser | null; setUser: (u: AuthUser | null) => void }

type SetFn = (partial: Partial<State> | ((state: State) => Partial<State>), replace?: boolean) => void

export const useAuthStore = create<State>((set: SetFn) => ({
  user: null,
  setUser: (u: AuthUser | null) => set({ user: u })
}))
