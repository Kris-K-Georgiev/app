<template>
  <div>
    <h6 class="fw-semibold mb-2">News</h6>
    <button class="btn btn-sm btn-primary mb-2" @click="fetchData">Reload</button>
    <table class="table table-sm table-striped align-middle small">
      <thead><tr><th>ID</th><th>Title</th><th>Status</th><th>Author</th><th>Created</th></tr></thead>
      <tbody>
        <tr v-for="n in rows" :key="n.id">
          <td>{{ n.id }}</td>
          <td>{{ n.title }}</td>
          <td>{{ n.status }}</td>
          <td>{{ n.author?.name }}</td>
          <td>{{ n.created_at }}</td>
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
    const r= await fetch('/api/admin/news?per_page=50');
    const j= await r.json();
    rows.value = j.data || [];
  } finally { loading.value=false; }
}
onMounted(fetchData);
</script>
