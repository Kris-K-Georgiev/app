import { create } from 'zustand'

export type EventItem = {
  id: string; title: string; description?: string; start_date?: string; end_date?: string; start_time?: string;
  location?: string; cover?: string; city?: string; audience?: string; limit?: number|null; registrations_count?: number|null;
  images?: string[]; status?: string; event_type_id?: string|null; created_by?: string|null
}

export type NewsItem = {
  id: string; title: string; content: string; image?: string|null; cover?: string|null; images?: string[]; created_at?: string; created_by?: string|null;
  likes_count?: number; comments_count?: number
}

type State = {
  events: EventItem[]; news: NewsItem[]; loading: boolean;
  selectedDate: string | null; selectedType: string | null; selectedCity: string | null;
  setEvents: (v: EventItem[]) => void;
  setNews: (v: NewsItem[]) => void;
  setLoading: (v: boolean) => void;
  setSelectedDate: (iso: string | null) => void;
  setSelectedType: (slug: string | null) => void;
  setSelectedCity: (city: string | null) => void;
}

type SetFn = (partial: Partial<State> | ((state: State) => Partial<State>), replace?: boolean) => void

export const useContentStore = create<State>((set: SetFn) => ({
  events: [], news: [], loading: false,
  selectedDate: null, selectedType: null, selectedCity: null,
  setEvents: (v: EventItem[]) => set({ events: v }),
  setNews: (v: NewsItem[]) => set({ news: v }),
  setLoading: (v: boolean) => set({ loading: v }),
  setSelectedDate: (iso: string | null) => set({ selectedDate: iso }),
  setSelectedType: (slug: string | null) => set({ selectedType: slug }),
  setSelectedCity: (city: string | null) => set({ selectedCity: city })
}))
