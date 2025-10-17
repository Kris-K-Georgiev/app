import { Route, Routes, Navigate, Link } from 'react-router-dom'
import { Navbar, Button, DarkThemeToggle } from 'flowbite-react'
import Login from './components/Login.jsx'
import Dashboard from './components/Dashboard.jsx'
import FileManager from './components/FileManager.jsx'
import { useAuthState } from './services/auth.js'
import EventsCalendar from './components/EventsCalendar.jsx'
import EventsList from './components/EventsList.jsx'
import EventsPage from './components/EventsPage.jsx'
import NewsList from './components/NewsList.jsx'
import NewsDetail from './components/NewsDetail.jsx'
import Profile from './components/Profile.jsx'
import { useAuthSync } from './hooks/useAuthSync'
import { useSubscribeEvents, useSubscribeNews } from './hooks/useFirestoreSubscribes'

function ProtectedRoute({ children }) {
  const { user, loading } = useAuthState()
  if (loading) return <div className="p-6">Loading...</div>
  if (!user) return <Navigate to="/login" replace />
  return children
}

export default function App() {
  const { user, signOut } = useAuthState()
  useAuthSync()
  useSubscribeEvents()
  useSubscribeNews()
  return (
    <div className="min-h-dvh">
      <Navbar fluid rounded>
        <Navbar.Brand as={Link} to="/">
          <img src="/icons/pwa-192x192.png" className="mr-3 h-6 sm:h-9" alt="App Logo" />
          <span className="self-center whitespace-nowrap text-xl font-semibold">App</span>
        </Navbar.Brand>
        <div className="flex md:order-2 gap-2 items-center">
          <DarkThemeToggle />
          {user ? (
            <Button color="light" onClick={signOut}>Изход</Button>
          ) : (
            <Button as={Link} to="/login">Вход</Button>
          )}
          <Navbar.Toggle />
        </div>
        <Navbar.Collapse>
          <Navbar.Link as={Link} to="/" active>Табло</Navbar.Link>
          <Navbar.Link as={Link} to="/news">Новини</Navbar.Link>
          <Navbar.Link as={Link} to="/events">Събития</Navbar.Link>
          <Navbar.Link as={Link} to="/calendar">Календар</Navbar.Link>
          <Navbar.Link as={Link} to="/files">Файлове</Navbar.Link>
          <Navbar.Link as={Link} to="/profile">Профил</Navbar.Link>
        </Navbar.Collapse>
      </Navbar>

      <main className="p-4">
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/files" element={<ProtectedRoute><FileManager /></ProtectedRoute>} />
          <Route path="/news" element={<ProtectedRoute><NewsList /></ProtectedRoute>} />
          <Route path="/news/:id" element={<ProtectedRoute><NewsDetail /></ProtectedRoute>} />
          <Route path="/events" element={<ProtectedRoute><EventsPage /></ProtectedRoute>} />
          <Route path="/calendar" element={<ProtectedRoute><EventsCalendar /></ProtectedRoute>} />
          <Route path="/profile" element={<ProtectedRoute><Profile /></ProtectedRoute>} />
          <Route path="/" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
        </Routes>
      </main>
    </div>
  )
}
