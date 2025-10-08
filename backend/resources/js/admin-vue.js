import { createApp } from 'vue';
import AdminApp from './components/admin/AdminApp.vue';

const mountEl = document.getElementById('admin-vue-root');
if(mountEl){
  createApp(AdminApp).mount(mountEl);
}
