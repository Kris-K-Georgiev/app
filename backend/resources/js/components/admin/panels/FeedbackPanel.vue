<template>
  <div>
    <h6 class="fw-semibold mb-2">Feedback</h6>
    <div class="d-flex gap-2 mb-2">
      <button class="btn btn-sm btn-primary" @click="fetchData">Reload</button>
    </div>
    <table class="table table-sm table-striped align-middle small">
      <thead><tr><th>ID</th><th>User</th><th>Contact</th><th>Excerpt</th><th>IP</th><th>Created</th></tr></thead>
      <tbody>
        <tr v-for="f in rows" :key="f.id">
          <td>{{ f.id }}</td>
          <td>{{ f.user?.name || '—' }}</td>
          <td>{{ f.contact || '—' }}</td>
          <td>{{ f.message.slice(0,50) }}</td>
          <td>{{ f.ip || '—' }}</td>
          <td>{{ f.created_at }}</td>
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
    const r= await fetch('/api/admin/feedback?per_page=50');
    const j= await r.json();
    rows.value = j.data || [];
  } finally { loading.value=false; }
}
onMounted(fetchData);
</script>
