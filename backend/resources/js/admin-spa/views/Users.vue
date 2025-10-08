<template>
  <div>
    <div class="toolbar">
      <input v-model="search" @keyup.enter="load" placeholder="Search users" />
      <button @click="load">Search</button>
    </div>
    <table class="table-sm">
      <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Role</th><th>Created</th></tr></thead>
      <tbody>
        <tr v-for="u in rows" :key="u.id">
          <td>{{ u.id }}</td><td>{{ u.name }}</td><td>{{ u.email }}</td><td>{{ u.role }}</td><td>{{ u.created_at }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="loading">Loading…</div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
const rows=ref([]); const search=ref(''); const loading=ref(false);
async function load(){ loading.value=true; try { const r= await fetch('/api/admin/users?search='+encodeURIComponent(search.value)); const j= await r.json(); rows.value=j.data||[]; } finally { loading.value=false; } }
onMounted(load);
</script>
