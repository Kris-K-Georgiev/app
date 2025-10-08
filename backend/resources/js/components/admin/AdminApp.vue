<template>
  <div class="admin-vue-wrapper">
    <h5 class="mb-3">Admin Vue Panel</h5>
    <div class="row g-3">
      <div class="col-md-3">
        <ul class="list-group small">
          <li v-for="m in modules" :key="m.key" @click="current=m.key" :class="['list-group-item','list-group-item-action', {active: current===m.key}]" style="cursor:pointer">{{ m.label }}</li>
        </ul>
      </div>
      <div class="col-md-9">
        <component :is="activeComp" />
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed } from 'vue';
import UsersPanel from './panels/UsersPanel.vue';
import PostsPanel from './panels/PostsPanel.vue';
import PrayersPanel from './panels/PrayersPanel.vue';
import FeedbackPanel from './panels/FeedbackPanel.vue';
import EventsPanel from './panels/EventsPanel.vue';
import NewsPanel from './panels/NewsPanel.vue';

const modules = [
  { key:'users', label:'Users', comp: UsersPanel },
  { key:'posts', label:'Posts', comp: PostsPanel },
  { key:'prayers', label:'Prayers', comp: PrayersPanel },
  { key:'feedback', label:'Feedback', comp: FeedbackPanel },
  { key:'events', label:'Events', comp: EventsPanel },
  { key:'news', label:'News', comp: NewsPanel },
];
const current = ref('users');
const activeComp = computed(()=> modules.find(m=>m.key===current.value)?.comp || 'div');
</script>
<style scoped>
.admin-vue-wrapper { font-size: .8rem; }
</style>
