<template>
  <div>
    <div class="toolbar">
      <input v-model="search" @keyup.enter="reload" placeholder="Search content" />
      <label><input type="checkbox" v-model="withDeleted" @change="reload" /> with deleted</label>
      <button @click="openCreate">New Post</button>
      <button @click="load">Reload</button>
    </div>
    <table class="table-sm">
      <thead><tr><th>ID</th><th>User</th><th>Excerpt</th><th>Status</th><th></th></tr></thead>
      <tbody>
        <tr v-for="p in rows" :key="p.id">
          <td>{{ p.id }}</td>
          <td>{{ p.user?.name }}</td>
          <td>{{ p.content.slice(0,60) }}</td>
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
    </CrudFormModal>
  </div>
</template>
<script setup>
import { ref, reactive, onMounted } from 'vue';
import { api } from '../lib/apiClient';
import Pagination from '../components/Pagination.vue';
import CrudFormModal from '../components/CrudFormModal.vue';
import DeletedBadge from '../components/DeletedBadge.vue';
const rows=ref([]); const page=ref(1); const pages=ref(1); const search=ref(''); const withDeleted=ref(false);
const modalOpen=ref(false); const modalMode=ref('create'); const modalTitle=ref('');
const form=reactive({ id:null,user_id:'',content:'' });
function openCreate(){ modalMode.value='create'; modalTitle.value='Create Post'; Object.assign(form,{id:null,user_id:'',content:''}); modalOpen.value=true; }
function edit(p){ modalMode.value='edit'; modalTitle.value='Edit Post'; Object.assign(form,{id:p.id,user_id:p.user?.id || '',content:p.content}); modalOpen.value=true; }
function closeModal(){ modalOpen.value=false; }
async function load(){ const data=await api.crud.list('posts',{ page:page.value, search:search.value, with_deleted: withDeleted.value?1:0 }); rows.value=data.data||[]; pages.value=data.last_page||1; }
function reload(){ page.value=1; load(); }
async function submit(){ if(modalMode.value==='create'){ await api.crud.create('posts',form); } else { await api.crud.update('posts',form.id,{ content:form.content }); } closeModal(); load(); }
async function del(p){ if(!confirm('Delete post?')) return; await api.crud.destroy('posts',p.id); load(); }
async function restore(p){ await api.crud.restore('posts',p.id); load(); }
onMounted(load);
</script>
