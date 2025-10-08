<template>
  <div>
    <div class="toolbar"><button @click="load">Reload</button></div>
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
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
const rows=ref([]); const loading=ref(false);
async function load(){ loading.value=true; try { const r= await fetch('/api/admin/posts'); const j= await r.json(); rows.value=j.data||[]; } finally { loading.value=false; } }
onMounted(load);
</script>
