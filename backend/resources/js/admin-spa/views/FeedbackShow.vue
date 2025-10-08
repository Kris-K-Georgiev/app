<template>
  <div v-if="item" class="feedback-detail">
    <button @click="$router.back()" class="back">← Back</button>
    <h4>Feedback #{{ item.id }}</h4>
    <div class="meta">
      <div><strong>User:</strong> {{ item.user?.name || '—' }}</div>
      <div><strong>Status:</strong> {{ item.status }}</div>
      <div><strong>Severity:</strong> {{ item.severity || '—' }}</div>
      <div><strong>Handled By:</strong> {{ item.handled_by?.name || '—' }}</div>
      <div><strong>Created:</strong> {{ item.created_at }}</div>
      <div><strong>IP:</strong> {{ item.ip }}</div>
      <div><strong>Contact:</strong> {{ item.contact || '—' }}</div>
    </div>
    <h5>Message</h5>
    <pre class="message">{{ item.message }}</pre>
    <h5 v-if="item.context">Context</h5>
    <pre class="context" v-if="item.context">{{ pretty(item.context) }}</pre>
    <div class="actions">
      <label>Status:
        <select v-model="edit.status">
          <option value="new">new</option>
          <option value="reviewed">reviewed</option>
          <option value="closed">closed</option>
        </select>
      </label>
      <label>Severity:
        <select v-model.number="edit.severity">
          <option :value="null">–</option>
          <option v-for="n in 5" :value="n" :key="'sev'+n">{{ n }}</option>
        </select>
      </label>
      <button @click="save" :disabled="saving">Save</button>
    </div>
  </div>
  <div v-else>Loading…</div>
</template>
<script setup>
import { ref, reactive, onMounted } from 'vue';
import { api } from '../lib/apiClient';
import { useRoute } from 'vue-router';
const route = useRoute();
const item = ref(null); const saving=ref(false);
const edit = reactive({ status:'', severity:null });
function pretty(c){ try { return typeof c==='string'?c: JSON.stringify(c,null,2); } catch(e){ return c; } }
async function load(){
  const id = route.params.id;
  const data = await fetch(`/admin/api/feedback-items?ids=${id}`).then(r=>r.json());
  const found = (data.data||[]).find(f=>f.id==id);
  if(found){ item.value=found; edit.status=found.status; edit.severity=found.severity; }
}
async function save(){ saving.value=true; try { await api.updateFeedbackStatus(item.value.id,{ status: edit.status, severity: edit.severity }); item.value.status=edit.status; item.value.severity=edit.severity; } finally { saving.value=false; } }
onMounted(load);
</script>
<style scoped>
.feedback-detail{max-width:800px;}
.meta{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:.4rem;font-size:.65rem;margin-bottom:.75rem;}
pre{background:var(--c-surface);border:1px solid var(--c-border);padding:.6rem .7rem;border-radius:6px;font-size:.6rem;overflow:auto;}
.message{white-space:pre-wrap;}
.actions{display:flex;gap:.6rem;align-items:flex-end;margin-top:.8rem;}
select,button{font-size:.65rem;padding:.35rem .55rem;}
.back{margin-bottom:.6rem;}
</style>
