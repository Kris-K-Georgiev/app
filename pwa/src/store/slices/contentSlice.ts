import { createSlice, PayloadAction } from '@reduxjs/toolkit'

export type EventItem = {
  id: string; title: string; description?: string; start_date?: string; end_date?: string; start_time?: string;
  location?: string; cover?: string; city?: string; audience?: string; limit?: number|null; registrations_count?: number|null;
  images?: string[]; status?: string; event_type_id?: string|null; created_by?: string|null
}

export type NewsItem = {
  id: string; title: string; content: string; image?: string|null; cover?: string|null; images?: string[]; created_at?: string; created_by?: string|null;
  likes_count?: number; comments_count?: number
}

type ContentState = { events: EventItem[]; news: NewsItem[]; loading: boolean }
const initialState: ContentState = { events: [], news: [], loading: false }

const contentSlice = createSlice({
  name: 'content',
  initialState,
  reducers: {
    setEvents(s: ContentState, a: PayloadAction<EventItem[]>) { s.events = a.payload },
    setNews(s: ContentState, a: PayloadAction<NewsItem[]>) { s.news = a.payload },
    setLoading(s: ContentState, a: PayloadAction<boolean>) { s.loading = a.payload }
  }
})

export const { setEvents, setNews, setLoading } = contentSlice.actions
export default contentSlice.reducer
