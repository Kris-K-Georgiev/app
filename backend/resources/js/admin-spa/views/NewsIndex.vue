<template>
  <div>
    <div class="toolbar">
      <input v-model="search" @keyup.enter="reload" placeholder="Search title" />
      <select v-model="status" @change="reload"><option value="">All status</option><option value="draft">draft</option><option value="published">published</option></select>
      <button @click="openCreate">New News</button>
      <button @click="load">Reload</button>
    </div>
    <table class="table-sm">
      <thead><tr><th>ID</th><th>Title</th><th>Status</th><th></th></tr></thead>
      <tbody>
        <tr v-for="n in rows" :key="n.id">
          <td>{{ n.id }}</td>
            <td>{{ n.title }}</td>
          <td>{{ n.status }}</td>
          <td>
            <button @click="edit(n)">Edit</button>
            <button @click="del(n)">Delete</button>
          </td>
        </tr>
      </tbody>
    </table>
    <Pagination :page="page" :pages="pages" @update:page="p=>{page=p; load();}" />
    <CrudFormModal :open="modalOpen" :title="modalTitle" :submit-label="modalMode==='create'?'Create':'Save'" @close="closeModal" @submit="submit">
      <input v-model="form.title" placeholder="Title" required />
      <textarea v-model="form.content" placeholder="Content" rows="6" required />
      <select v-model="form.status"><option value="draft">draft</option><option value="published">published</option></select>
    </CrudFormModal>
  </div>
</template>
<script setup>
import { ref, reactive, onMounted } from 'vue';
import { api } from '../lib/apiClient';
import Pagination from '../components/Pagination.vue';
import CrudFormModal from '../components/CrudFormModal.vue';
const rows=ref([]); const page=ref(1); const pages=ref(1); const search=ref(''); const status=ref('');
const modalOpen=ref(false); const modalMode=ref('create'); const modalTitle=ref('');
const form=reactive({ id:null,title:'',content:'',status:'draft' });
function openCreate(){ modalMode.value='create'; modalTitle.value='Create News'; Object.assign(form,{id:null,title:'',content:'',status:'draft'}); modalOpen.value=true; }
function edit(n){ modalMode.value='edit'; modalTitle.value='Edit News'; Object.assign(form,{id:n.id,title:n.title,content:n.content||'',status:n.status||'draft'}); modalOpen.value=true; }
function closeModal(){ modalOpen.value=false; }
async function load(){ const data=await api.crud.list('news',{ page:page.value, search:search.value, status: status.value }); rows.value=data.data||[]; pages.value=data.last_page||1; }
function reload(){ page.value=1; load(); }
async function submit(){ if(modalMode.value==='create'){ await api.crud.create('news',form); } else { await api.crud.update('news',form.id,{ title:form.title, content:form.content, status:form.status }); } closeModal(); load(); }
async function del(n){ if(!confirm('Delete news item?')) return; await api.crud.destroy('news',n.id); load(); }
onMounted(load);
</script>
