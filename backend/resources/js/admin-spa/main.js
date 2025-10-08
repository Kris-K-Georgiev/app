import { createApp } from 'vue';
import { createPinia } from 'pinia';
import router from './router';
import AdminShell from './views/AdminShell.vue';
import './styles/base.css';

const app = createApp(AdminShell);
app.use(createPinia());
app.use(router);
app.mount('#admin-spa-root');
