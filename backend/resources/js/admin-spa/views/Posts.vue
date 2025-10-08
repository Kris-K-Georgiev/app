<template>
  <div>
    <div class="toolbar"><button @click="reload">Reload</button></div>
    <table class="table-sm">
      <thead><tr><th>ID</th><th>User</th><th>Excerpt</th><th>Likes</th><th>Comments</th><th>Created</th></tr></thead>
      <tbody>
        <tr v-for="p in rows" :key="p.id">
          <td>{{ p.id }}</td>
          <td>{{ p.author?.name }}</td>
          <td>{{ p.content.slice(0,40) }}</td>
          <td>{{ p.likes_count }}</td>
          <td>{{ p.comments_count }}</td>
          <td>{{ p.created_at }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="loading">Loading…</div>
    <Pagination :page="page" :pages="pages" @update:page="p=>{page=p; load();}" />
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
import { api } from '../lib/apiClient';
import Pagination from '../components/Pagination.vue';
const rows=ref([]); const loading=ref(false); const page=ref(1); const pages=ref(1);
async function load(){ loading.value=true; try { const data= await api.posts({ page: page.value }); rows.value=data.data||[]; pages.value=data.last_page||1; } finally { loading.value=false; } }
function reload(){ page.value=1; load(); }
onMounted(load);
</script>
