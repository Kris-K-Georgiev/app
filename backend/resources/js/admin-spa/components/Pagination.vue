<template>
  <div class="pager" v-if="pages > 1">
    <button :disabled="page===1" @click="$emit('update:page', page-1)">Prev</button>
    <span>Page {{ page }} / {{ pages }}</span>
    <button :disabled="page===pages" @click="$emit('update:page', page+1)">Next</button>
  </div>
</template>
<script setup>
defineProps({ page:{ type:Number, required:true }, pages:{ type:Number, required:true } });
</script>
<style scoped>
.pager { display:flex; gap:.5rem; align-items:center; font-size:.65rem; margin-top:.6rem; }
button { font-size:.6rem; padding:.28rem .55rem; border:1px solid var(--c-border); background:var(--c-btn-bg); cursor:pointer; border-radius:4px; }
button:disabled { opacity:.4; cursor:default; }
button:not(:disabled):hover { background:var(--c-accent-bg); color:var(--c-accent-fg); }
</style>