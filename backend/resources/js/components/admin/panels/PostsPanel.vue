<template>
  <div>
    <h6 class="fw-semibold mb-2">Posts</h6>
    <div class="mb-2 d-flex gap-2">
      <button class="btn btn-sm btn-primary" @click="fetchData">Reload</button>
    </div>
    <table class="table table-sm table-striped small align-middle">
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
    <div v-if="loading" class="text-muted small">Loading...</div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
const rows=ref([]); const loading=ref(false);
async function fetchData(){
  loading.value=true; try {
    const r= await fetch('/api/posts?per_page=50');
    const j= await r.json();
    rows.value = j.data || j; // paginator or array fallback
  } finally { loading.value=false; }
}
onMounted(fetchData);
</script>
