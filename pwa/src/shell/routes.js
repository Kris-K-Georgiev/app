import { HomePage } from '../views/home/HomePage.js'
import { NewsDetailPage } from '../views/home/NewsDetailPage.js'
import { EventsPage } from '../views/events/EventsPage.js'
import { EventDetailPage } from '../views/events/EventDetailPage.js'
import { ProfilePage } from '../views/profile/ProfilePage.js'
import { SettingsPage } from '../views/settings/SettingsPage.js'
import { AdminPage } from '../views/admin/AdminPage.js'
import { LoginPage } from '../views/auth/LoginPage.js'
import { RegisterPage } from '../views/auth/RegisterPage.js'

export const routes = [
  { path: '/', name: 'Начало', icon: 'home', component: HomePage },
  { path: '/events', name: 'Събития', icon: 'calendar', component: EventsPage },
  { path: '/profile', name: 'Профил', icon: 'user', component: ProfilePage },
  { path: '/settings', name: 'Настройки', icon: 'settings', component: SettingsPage },
  { path: '/admin', name: 'Админ', icon: 'shield', component: AdminPage },
  { path: '/login', name: 'Вход', icon: 'login', component: LoginPage },
  { path: '/register', name: 'Регистрация', icon: 'register', component: RegisterPage },
  // hidden detail routes
  { path: '/news/:id', name: 'Новина', icon: 'news', component: NewsDetailPage },
  { path: '/event/:id', name: 'Събитие', icon: 'calendar', component: EventDetailPage },
]
