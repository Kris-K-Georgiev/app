import { createSlice, PayloadAction } from '@reduxjs/toolkit'

export type AuthUser = { uid: string; email?: string | null; displayName?: string | null; photoURL?: string | null }

type AuthState = { user: AuthUser | null; status: 'idle'|'loading'|'authenticated'|'error'; error?: string }

const initialState: AuthState = { user: null, status: 'idle' }

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    setUser(state: AuthState, action: PayloadAction<AuthUser | null>) {
      state.user = action.payload
      state.status = action.payload ? 'authenticated' : 'idle'
    },
    setLoading(state: AuthState){ state.status = 'loading' },
    setError(state: AuthState, action: PayloadAction<string>){ state.status = 'error'; state.error = action.payload }
  }
})

export const { setUser, setLoading, setError } = authSlice.actions
export default authSlice.reducer
