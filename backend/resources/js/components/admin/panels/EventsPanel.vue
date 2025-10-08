<template>
  <div>
    <h6 class="fw-semibold mb-2">Events</h6>
    <button class="btn btn-sm btn-primary mb-2" @click="fetchData">Reload</button>
    <table class="table table-sm table-striped align-middle small">
      <thead><tr><th>ID</th><th>Title</th><th>City</th><th>Type</th><th>Start</th><th>Registrations</th></tr></thead>
      <tbody>
        <tr v-for="e in rows" :key="e.id">
          <td>{{ e.id }}</td>
          <td>{{ e.title }}</td>
          <td>{{ e.city }}</td>
          <td>{{ e.type?.name }}</td>
          <td>{{ e.start_date }}</td>
          <td>{{ e.registrations_count }}</td>
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
    const r= await fetch('/api/admin/events?per_page=50');
    const j= await r.json();
    rows.value = j.data || [];
  } finally { loading.value=false; }
}
onMounted(fetchData);
</script>
