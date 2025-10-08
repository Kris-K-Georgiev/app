import { createRouter, createWebHistory } from 'vue-router';

import Dashboard from './views/Dashboard.vue';
import Users from './views/Users.vue';
import Posts from './views/Posts.vue';
import Prayers from './views/Prayers.vue';
import Feedback from './views/Feedback.vue';
import Events from './views/Events.vue';
import News from './views/News.vue';
import Versions from './views/Versions.vue';

const routes = [
  { path: '/', name: 'dashboard', component: Dashboard },
  { path: '/users', name: 'users', component: Users },
  { path: '/posts', name: 'posts', component: Posts },
  { path: '/prayers', name: 'prayers', component: Prayers },
  { path: '/feedback', name: 'feedback', component: Feedback },
  { path: '/events', name: 'events', component: Events },
  { path: '/news', name: 'news', component: News },
  { path: '/versions', name: 'versions', component: Versions },
];

const router = createRouter({
  history: createWebHistory('/admin-spa'),
  routes,
});

export default router;
