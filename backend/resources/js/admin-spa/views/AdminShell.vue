<template>
  <div class="admin-spa" :class="theme">
    <aside class="sidebar" :class="{open: sidebarOpen}">
      <div class="brand">BHSS Admin</div>
      <nav class="nav">
        <RouterLink to="/" class="nav-item" exact-active-class="active">🏠 <span>Dashboard</span></RouterLink>
        <RouterLink to="/users" class="nav-item" exact-active-class="active">👥 <span>Users</span></RouterLink>
        <RouterLink to="/posts" class="nav-item" exact-active-class="active">📝 <span>Posts</span></RouterLink>
        <RouterLink to="/prayers" class="nav-item" exact-active-class="active">🙏 <span>Prayers</span></RouterLink>
        <RouterLink to="/feedback" class="nav-item" exact-active-class="active">💬 <span>Feedback</span></RouterLink>
        <RouterLink to="/events" class="nav-item" exact-active-class="active">📅 <span>Events</span></RouterLink>
        <RouterLink to="/news" class="nav-item" exact-active-class="active">📰 <span>News</span></RouterLink>
        <RouterLink to="/versions" class="nav-item" exact-active-class="active">⬆ <span>Versions</span></RouterLink>
      </nav>
      <div class="sidebar-footer small">© {{ year }} BHSS</div>
    </aside>
    <div class="main">
      <header class="topbar">
        <button class="icon-btn" @click="sidebarOpen=!sidebarOpen">☰</button>
        <div class="flex-grow" />
        <button class="icon-btn" @click="toggleTheme" :title="theme==='dark'?'Light':'Dark'">🌓</button>
        <form method="POST" action="/admin/logout" class="logout-form">
          <input type="hidden" name="_token" :value="csrf" />
          <button class="icon-btn" title="Logout">⏻</button>
        </form>
      </header>
      <main class="content">
        <RouterView />
      </main>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
const theme = ref(localStorage.getItem('adminTheme')||'light');
function toggleTheme(){ theme.value = theme.value==='light'?'dark':'light'; localStorage.setItem('adminTheme', theme.value); }
const sidebarOpen = ref(false);
const year = new Date().getFullYear();
const csrf = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '';
onMounted(()=> document.documentElement.setAttribute('data-theme', theme.value));
</script>
<style scoped>
.admin-spa { display:flex; min-height:100vh; font-family: Inter, system-ui, sans-serif; }
.sidebar { width:220px; background:var(--c-sidebar-bg); color:var(--c-fg); display:flex; flex-direction:column; transition:transform .25s ease; }
.sidebar .brand { font-weight:600; letter-spacing:.04em; padding:.9rem 1rem; font-size: .95rem; border-bottom:1px solid var(--c-border); }
.nav { flex:1; padding:.5rem .35rem; }
.nav-item { display:flex; align-items:center; gap:.5rem; font-size:.7rem; padding:.55rem .65rem; margin:.15rem 0; border-radius:6px; color:var(--c-fg-muted); text-decoration:none; font-weight:500; letter-spacing:.03em; }
.nav-item.active, .nav-item:hover { background:var(--c-accent-bg); color:var(--c-accent-fg); }
.sidebar-footer { padding:.65rem .75rem; font-size:.6rem; color:var(--c-fg-muted); border-top:1px solid var(--c-border); }
.main { flex:1; display:flex; flex-direction:column; background:var(--c-app-bg); }
.topbar { display:flex; align-items:center; gap:.5rem; padding:.4rem .7rem; border-bottom:1px solid var(--c-border); background:var(--c-surface); }
.icon-btn { background:var(--c-btn-bg); color:var(--c-fg); border:1px solid var(--c-border); padding:.35rem .55rem; border-radius:6px; font-size:.75rem; cursor:pointer; line-height:1; }
.icon-btn:hover { background:var(--c-accent-bg); color:var(--c-accent-fg); }
.content { padding:1rem 1.2rem 2rem; font-size:.75rem; }
:root, .admin-spa.light { --c-sidebar-bg:#0f1821; --c-app-bg:#f5f7fa; --c-surface:#ffffff; --c-fg:#1b2733; --c-fg-muted:#5a6672; --c-border:#e2e8f0; --c-accent-bg:#edf5ff; --c-accent-fg:#0b5ed7; --c-btn-bg:#f1f5f9; }
.admin-spa.dark { --c-sidebar-bg:#10161d; --c-app-bg:#0d1115; --c-surface:#182028; --c-fg:#e2e8f0; --c-fg-muted:#8896a3; --c-border:#2a3642; --c-accent-bg:#203247; --c-accent-fg:#59a8ff; --c-btn-bg:#243040; }
@media (max-width: 880px){ .sidebar { position:fixed; inset:0 auto 0 0; transform:translateX(-100%); z-index:60; box-shadow:0 0 0 100vmax rgba(0,0,0,.0); } .sidebar.open { transform:translateX(0); box-shadow:0 0 0 100vmax rgba(0,0,0,.35); } }
</style>
