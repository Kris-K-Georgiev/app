<template>
  <div>
    <h6 class="fw-semibold mb-2">Users</h6>
    <div class="d-flex gap-2 mb-2">
      <input v-model="search" @keyup.enter="fetchData" class="form-control form-control-sm" placeholder="Search name/email" />
      <button class="btn btn-sm btn-primary" @click="fetchData">Reload</button>
    </div>
    <table class="table table-sm table-striped align-middle small">
      <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Role</th><th>Created</th></tr></thead>
      <tbody>
        <tr v-for="u in rows" :key="u.id">
          <td>{{ u.id }}</td>
          <td>{{ u.name }}</td>
          <td>{{ u.email }}</td>
          <td>{{ u.role }}</td>
          <td>{{ u.created_at }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="loading" class="text-muted small">Loading...</div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
const rows = ref([]);
const search = ref('');
const loading = ref(false);

async function fetchData(){
  loading.value=true;
  try {
    const r = await fetch(`/api/admin/users?search=${encodeURIComponent(search.value)}`);
    const j = await r.json();
    rows.value = j.data || [];
  } finally { loading.value=false; }
}

onMounted(fetchData);
</script>
