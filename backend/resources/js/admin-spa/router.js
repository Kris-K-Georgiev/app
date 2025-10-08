import { createRouter, createWebHistory } from 'vue-router';

import Dashboard from './views/Dashboard.vue';
import Users from './views/UsersIndex.vue';
import Posts from './views/PostsIndex.vue';
import Prayers from './views/PrayersIndex.vue';
import Feedback from './views/Feedback.vue';
import FeedbackShow from './views/FeedbackShow.vue';
import Events from './views/EventsIndex.vue';
import News from './views/NewsIndex.vue';
import Versions from './views/VersionsIndex.vue';

const routes = [
  { path: '/', name: 'dashboard', component: Dashboard },
  { path: '/users', name: 'users', component: Users },
  { path: '/posts', name: 'posts', component: Posts },
  { path: '/prayers', name: 'prayers', component: Prayers },
  { path: '/feedback', name: 'feedback', component: Feedback },
  { path: '/feedback/:id', name: 'feedback.show', component: FeedbackShow },
  { path: '/events', name: 'events', component: Events },
  { path: '/news', name: 'news', component: News },
  { path: '/versions', name: 'versions', component: Versions },
];

const router = createRouter({
  history: createWebHistory('/admin-spa'),
  routes,
});

export default router;
