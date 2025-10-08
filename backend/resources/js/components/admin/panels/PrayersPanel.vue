<template>
  <div>
    <h6 class="fw-semibold mb-2">Prayers</h6>
    <button class="btn btn-sm btn-primary mb-2" @click="fetchData">Reload</button>
    <table class="table table-sm table-striped small align-middle">
      <thead><tr><th>ID</th><th>User</th><th>Anon?</th><th>Answered</th><th>Excerpt</th><th>Created</th></tr></thead>
      <tbody>
        <tr v-for="p in rows" :key="p.id">
          <td>{{ p.id }}</td>
          <td>{{ p.user?.name || '—' }}</td>
          <td>{{ p.is_anonymous? 'Yes':'No' }}</td>
          <td>{{ p.answered? 'Yes':'No' }}</td>
          <td>{{ p.content.slice(0,50) }}</td>
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
    const r= await fetch('/api/admin/prayers?per_page=50');
    const j= await r.json();
    rows.value = j.data || [];
  } finally { loading.value=false; }
}
onMounted(fetchData);
</script>
