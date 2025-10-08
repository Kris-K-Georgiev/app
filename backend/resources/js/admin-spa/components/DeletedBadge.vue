<template><span v-if="when" class="del-badge">DELETED</span></template>
<script setup>
defineProps({ when: { type:[Boolean,String,Date,null], default:false } });
</script>
<style scoped>
.del-badge{background:#b33939;color:#fff;font-size:.55rem;padding:.15rem .4rem;border-radius:4px;font-weight:600;letter-spacing:.05em;}
</style>
