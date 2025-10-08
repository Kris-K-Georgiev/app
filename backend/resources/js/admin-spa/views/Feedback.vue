<template>
  <div>
    <div class="toolbar">
      <select v-model="filters.status">
        <option value="">All statuses</option>
        <option value="new">New</option>
        <option value="reviewed">Reviewed</option>
        <option value="closed">Closed</option>
      </select>
      <select v-model="filters.sevMin">
        <option value="">Min Sev</option>
        <option v-for="n in 5" :key="'mn'+n" :value="n">{{ n }}</option>
      </select>
      <select v-model="filters.sevMax">
        <option value="">Max Sev</option>
        <option v-for="n in 5" :key="'mx'+n" :value="n">{{ n }}</option>
      </select>
      <input type="date" v-model="filters.from" />
      <input type="date" v-model="filters.to" />
      <input v-model="filters.search" placeholder="Search text / contact / ip" />
      <button @click="load">Apply</button>
    </div>
    <table class="table-sm feedback-table">
      <thead>
        <tr>
          <th>ID</th><th>User</th><th>Message</th><th>Contact</th><th>Status</th><th>Severity</th><th>Handled By</th><th>Created</th><th>Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="f in rows" :key="f.id">
          <td>{{ f.id }}</td>
          <td>{{ f.user?.name || '—' }}</td>
          <td class="message-cell">{{ f.message }}</td>
          <td>{{ f.contact || '—' }}</td>
          <td>
            <select v-model="f._editStatus">
              <option value="new">new</option>
              <option value="reviewed">reviewed</option>
              <option value="closed">closed</option>
            </select>
          </td>
          <td>
            <select v-model.number="f._editSeverity">
              <option :value="null">–</option>
              <option v-for="n in 5" :value="n" :key="'sev'+n">{{ n }}</option>
            </select>
          </td>
          <td>{{ f.handled_by?.name || '—' }}</td>
          <td>{{ f.created_at }}</td>
          <td>
            <button @click="save(f)" :disabled="f._saving">Save</button>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="loading">Loading…</div>
  </div>
</template>
<script setup>
import { ref, reactive, onMounted } from 'vue';
const rows = ref([]); const loading = ref(false);
const filters = reactive({ status:'', sevMin:'', sevMax:'', from:'', to:'', search:'' });
async function load(){
  loading.value=true;
  try {
    const qs = new URLSearchParams();
    if(filters.status) qs.append('status', filters.status);
    if(filters.sevMin) qs.append('sev_min', filters.sevMin);
    if(filters.sevMax) qs.append('sev_max', filters.sevMax);
    if(filters.from) qs.append('from', filters.from);
    if(filters.to) qs.append('to', filters.to);
    if(filters.search) qs.append('search', filters.search);
    const r = await fetch('/api/admin/feedback-items?'+qs.toString());
    const j = await r.json();
    rows.value = (j.data||[]).map(it=> ({...it, _editStatus: it.status, _editSeverity: it.severity, _saving:false }));
  } finally { loading.value=false; }
}
async function save(item){
  item._saving = true;
  try {
    await fetch(`/api/admin/feedback-items/${item.id}/status`, {
      method:'PATCH',
      headers:{ 'Content-Type':'application/json','Accept':'application/json','X-CSRF-TOKEN':document.querySelector('meta[name="csrf-token"]').content },
      body: JSON.stringify({ status: item._editStatus, severity: item._editSeverity || null })
    });
    item.status = item._editStatus;
    item.severity = item._editSeverity;
  } finally { item._saving=false; }
}
onMounted(load);
</script>
<style scoped>
.toolbar { display:flex; flex-wrap:wrap; gap:.4rem; margin-bottom:.6rem; }
.feedback-table { width:100%; border-collapse:collapse; font-size:.68rem; }
.feedback-table th, .feedback-table td { border:1px solid var(--c-border); padding:.35rem .4rem; vertical-align:top; }
.feedback-table th { background:var(--c-surface); font-weight:600; letter-spacing:.04em; font-size:.55rem; text-transform:uppercase; }
.message-cell { max-width:280px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
select, input[type="date"], input[type="text"], input:not([type]) { font-size:.65rem; padding:.25rem .35rem; }
button { font-size:.6rem; padding:.28rem .55rem; border:1px solid var(--c-border); background:var(--c-btn-bg); cursor:pointer; border-radius:4px; }
button:hover { background:var(--c-accent-bg); color:var(--c-accent-fg); }
</style>
