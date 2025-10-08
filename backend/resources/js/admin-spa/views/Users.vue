<template>
  <div>
    <div class="toolbar">
      <input v-model="search" @keyup.enter="reload" placeholder="Search users" />
      <button @click="reload">Search</button>
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
    <Pagination :page="page" :pages="pages" @update:page="p=>{page=p; load();}" />
  </div>
</template>
<script setup>
import { ref, onMounted, watch } from 'vue';
import { api } from '../lib/apiClient';
import Pagination from '../components/Pagination.vue';
const rows=ref([]); const search=ref(''); const loading=ref(false); const page=ref(1); const pages=ref(1);
async function load(){ loading.value=true; try { const data= await api.users({ page: page.value, search: search.value }); rows.value=data.data||[]; pages.value=data.last_page||1; } finally { loading.value=false; } }
function reload(){ page.value=1; load(); }
onMounted(load);
watch(search, val=> { if(!val) reload(); });
</script>
