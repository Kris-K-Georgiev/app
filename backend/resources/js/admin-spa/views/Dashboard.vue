<template>
  <div>
    <h4 class="mb-3" style="font-size:1rem;">Dashboard</h4>
    <div class="grid">
      <div class="card" v-for="m in metrics" :key="m.key">
        <div class="label">{{ m.label }}</div>
        <div class="value">{{ m.value }}</div>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
const metrics = ref([
  { key:'users', label:'Users', value:'…' },
  { key:'posts', label:'Posts', value:'…' },
  { key:'prayers', label:'Prayers', value:'…' },
  { key:'events', label:'Events', value:'…' },
  { key:'news', label:'News', value:'…' },
  { key:'feedback', label:'Feedback', value:'…' },
]);
async function load(){
  try { const r = await fetch('/api/admin/metrics'); const j = await r.json(); metrics.value = metrics.value.map(m=> ({...m, value: j[m.key] ?? 0})); } catch(e) {}
}
onMounted(load);
</script>
<style scoped>
.grid { display:grid; gap:.8rem; grid-template-columns: repeat(auto-fill,minmax(140px,1fr)); }
.card { background:var(--c-surface); border:1px solid var(--c-border); padding:.75rem .8rem; border-radius:10px; display:flex; flex-direction:column; gap:.25rem; }
.card .label { font-size:.55rem; text-transform:uppercase; letter-spacing:.07em; color:var(--c-fg-muted); font-weight:600; }
.card .value { font-size:1.1rem; font-weight:600; letter-spacing:.03em; }
</style>
