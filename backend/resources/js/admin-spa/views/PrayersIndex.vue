<template>
  <div>
    <div class="toolbar">
      <input v-model="search" @keyup.enter="reload" placeholder="Search content" />
      <label><input type="checkbox" v-model="withDeleted" @change="reload" /> with deleted</label>
      <label><input type="checkbox" v-model="answeredFilter" @change="reload" /> answered only</label>
      <button @click="openCreate">New Prayer</button>
      <button @click="load">Reload</button>
    </div>
    <table class="table-sm">
      <thead><tr><th>ID</th><th>User</th><th>Excerpt</th><th>Anon</th><th>Ans</th><th>Status</th><th></th></tr></thead>
      <tbody>
        <tr v-for="p in rows" :key="p.id">
          <td>{{ p.id }}</td>
          <td>{{ p.user?.name }}</td>
          <td>{{ p.content.slice(0,60) }}</td>
          <td>{{ p.is_anonymous ? 'Y':'N' }}</td>
          <td>{{ p.answered ? 'Y':'N' }}</td>
          <td><DeletedBadge :when="p.deleted_at" /></td>
          <td>
            <button @click="edit(p)">Edit</button>
            <button v-if="!p.deleted_at" @click="del(p)">Delete</button>
            <button v-else @click="restore(p)">Restore</button>
          </td>
        </tr>
      </tbody>
    </table>
    <Pagination :page="page" :pages="pages" @update:page="p=>{page=p; load();}" />
    <CrudFormModal :open="modalOpen" :title="modalTitle" :submit-label="modalMode==='create'?'Create':'Save'" @close="closeModal" @submit="submit">
      <input v-model.number="form.user_id" placeholder="User ID" type="number" required />
      <textarea v-model="form.content" placeholder="Content" required rows="4" />
      <label><input type="checkbox" v-model="form.is_anonymous" /> Anonymous</label>
      <label><input type="checkbox" v-model="form.answered" /> Answered</label>
    </CrudFormModal>
  </div>
</template>
<script setup>
import { ref, reactive, onMounted } from 'vue';
import { api } from '../lib/apiClient';
import Pagination from '../components/Pagination.vue';
import CrudFormModal from '../components/CrudFormModal.vue';
import DeletedBadge from '../components/DeletedBadge.vue';
const rows=ref([]); const page=ref(1); const pages=ref(1); const search=ref(''); const withDeleted=ref(false); const answeredFilter=ref(false);
const modalOpen=ref(false); const modalMode=ref('create'); const modalTitle=ref('');
const form=reactive({ id:null,user_id:'',content:'',is_anonymous:false,answered:false });
function openCreate(){ modalMode.value='create'; modalTitle.value='Create Prayer'; Object.assign(form,{id:null,user_id:'',content:'',is_anonymous:false,answered:false}); modalOpen.value=true; }
function edit(p){ modalMode.value='edit'; modalTitle.value='Edit Prayer'; Object.assign(form,{id:p.id,user_id:p.user?.id||'',content:p.content,is_anonymous:p.is_anonymous,answered:p.answered}); modalOpen.value=true; }
function closeModal(){ modalOpen.value=false; }
async function load(){ const data=await api.crud.list('prayers',{ page:page.value, search:search.value, with_deleted: withDeleted.value?1:0, answered: answeredFilter.value?1:undefined }); rows.value=data.data||[]; pages.value=data.last_page||1; }
function reload(){ page.value=1; load(); }
async function submit(){ if(modalMode.value==='create'){ await api.crud.create('prayers',form); } else { await api.crud.update('prayers',form.id,{ content:form.content,is_anonymous:form.is_anonymous,answered:form.answered }); } closeModal(); load(); }
async function del(p){ if(!confirm('Delete prayer?')) return; await api.crud.destroy('prayers',p.id); load(); }
async function restore(p){ await api.crud.restore('prayers',p.id); load(); }
onMounted(load);
</script>
