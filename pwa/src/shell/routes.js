import { HomePage } from '../views/home/HomePage.js'
import { NewsDetailPage } from '../views/home/NewsDetailPage.js'
import { EventsPage } from '../views/events/EventsPage.js'
import { EventDetailPage } from '../views/events/EventDetailPage.js'
import { PostsPage } from '../views/social/PostsPage.js'
import { ChatPage } from '../views/chat/ChatPage.js'
import { ProfilePage } from '../views/profile/ProfilePage.js'
import { UserProfilePage } from '../views/profile/UserProfilePage.js'
import { AdminPage } from '../views/admin/AdminPage.js'
import { LoginPage } from '../views/auth/LoginPage.js'
import { RegisterPage } from '../views/auth/RegisterPage.js'

export const routes = [
  { path: '/', name: 'Начало', icon: 'home', component: HomePage },
  { path: '/events', name: 'Събития', icon: 'calendar', component: EventsPage },
  { path: '/posts', name: 'Постове', icon: 'posts', component: PostsPage, meta: { requiresAuth: true } },
  { path: '/chat', name: 'Чат', icon: 'chat', component: ChatPage, meta: { requiresAuth: true } },
  { path: '/profile', name: 'Профил', icon: 'user', component: ProfilePage, meta: { requiresAuth: true } },
  { path: '/admin', name: 'Админ', icon: 'shield', component: AdminPage, meta: { requiresAdmin: true } },
  { path: '/login', name: 'Вход', icon: 'login', component: LoginPage },
  { path: '/register', name: 'Регистрация', icon: 'register', component: RegisterPage },
  // hidden detail routes
  { path: '/news/:id', name: 'Новина', icon: 'news', component: NewsDetailPage },
  { path: '/event/:id', name: 'Събитие', icon: 'calendar', component: EventDetailPage },
  { path: '/user/:id', name: 'Потребител', icon: 'user', component: UserProfilePage },
]
