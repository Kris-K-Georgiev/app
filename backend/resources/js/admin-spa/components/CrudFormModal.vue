<template>
  <div v-if="open" class="modal-backdrop">
    <div class="modal">
      <header>
        <h4>{{ title }}</h4>
        <button class="close" @click="$emit('close')">×</button>
      </header>
      <form @submit.prevent="onSubmit">
        <slot />
        <div class="actions">
          <button type="button" @click="$emit('close')">Cancel</button>
          <button type="submit" :disabled="submitting">{{ submitLabel }}</button>
        </div>
        <div v-if="error" class="error">{{ error }}</div>
      </form>
    </div>
  </div>
</template>
<script setup>
import { ref } from 'vue';
const props = defineProps({ open:Boolean, title:String, submitLabel:{type:String,default:'Save'} });
const submitting = ref(false);
const error = ref('');
const emit = defineEmits(['submit','close','submitted']);
async function onSubmit(){
  submitting.value=true; error.value='';
  try { await emit('submit'); emit('submitted'); } catch(e){ error.value=e.message||'Error'; } finally { submitting.value=false; }
}
</script>
<style scoped>
.modal-backdrop{position:fixed;inset:0;background:#0008;display:flex;align-items:center;justify-content:center;z-index:1000;}
.modal{background:var(--c-surface);border:1px solid var(--c-border);border-radius:8px;padding:1rem;min-width:320px;max-width:560px;width:100%;}
header{display:flex;justify-content:space-between;align-items:center;margin-bottom:.75rem;}
.close{background:none;border:none;font-size:1.1rem;cursor:pointer;}
form{display:flex;flex-direction:column;gap:.65rem;}
.actions{display:flex;justify-content:flex-end;gap:.5rem;margin-top:.25rem;}
.error{color:#c0392b;font-size:.7rem;}
input,textarea,select{width:100%;font-size:.7rem;padding:.4rem .5rem;border:1px solid var(--c-border);border-radius:4px;background:var(--c-input-bg);} 
button{font-size:.65rem;padding:.4rem .75rem;border:1px solid var(--c-border);background:var(--c-btn-bg);cursor:pointer;border-radius:4px;}
button:hover:not(:disabled){background:var(--c-accent-bg);color:var(--c-accent-fg);} 
</style>
