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
          <td><router-link :to="{name:'feedback.show', params:{id:f.id}}">{{ f.id }}</router-link></td>
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
    <Pagination :page="page" :pages="pages" @update:page="p=>{page=p; load();}" />
  </div>
</template>
<script setup>
import { ref, reactive, onMounted } from 'vue';
import { api } from '../lib/apiClient';
import Pagination from '../components/Pagination.vue';
const rows = ref([]); const loading = ref(false); const page=ref(1); const pages=ref(1);
const filters = reactive({ status:'', sevMin:'', sevMax:'', from:'', to:'', search:'' });
function buildParams(){
  return {
    page: page.value,
    status: filters.status || undefined,
    sev_min: filters.sevMin || undefined,
    sev_max: filters.sevMax || undefined,
    from: filters.from || undefined,
    to: filters.to || undefined,
    search: filters.search || undefined,
  };
}
async function load(){
  loading.value=true;
  try {
    const data = await api.feedback(buildParams());
    rows.value = (data.data||[]).map(it=> ({...it, _editStatus: it.status, _editSeverity: it.severity, _saving:false }));
    pages.value = data.last_page || 1;
  } finally { loading.value=false; }
}
function applyFilters(){ page.value=1; load(); }
async function save(item){
  item._saving = true;
  try {
    await api.updateFeedbackStatus(item.id, { status: item._editStatus, severity: item._editSeverity || null });
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
