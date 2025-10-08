<template>
  <div class="toasts" v-if="items.length">
    <div v-for="t in items" :key="t.id" class="toast" :class="t.type" @click="dismiss(t.id)">
      <strong v-if="t.title">{{ t.title }}</strong>
      <span>{{ t.message }}</span>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue';
import { onToast } from '../lib/apiClient';
const items = ref([]);
function add(t){
  const id = Date.now()+Math.random();
  items.value.push({ id, ...t });
  setTimeout(()=> dismiss(id), t.timeout||4500);
}
function dismiss(id){ items.value = items.value.filter(i=>i.id!==id); }
onMounted(()=>{ onToast(add); });
</script>
<style scoped>
.toasts{position:fixed;top:1rem;right:1rem;display:flex;flex-direction:column;gap:.5rem;z-index:1200;}
.toast{background:var(--c-surface);border:1px solid var(--c-border);padding:.55rem .7rem;border-radius:6px;box-shadow:0 4px 14px -4px rgba(0,0,0,.25);font-size:.65rem;cursor:pointer;display:flex;flex-direction:column;gap:.15rem;min-width:200px;max-width:300px;}
.toast.error{border-color:#b94141;background:#fff2f2;color:#7a1f1f;}
.toast.success{border-color:#27ae60;background:#e6fff2;color:#145a32;}
.toast strong{font-weight:600;font-size:.6rem;letter-spacing:.05em;}
</style>
