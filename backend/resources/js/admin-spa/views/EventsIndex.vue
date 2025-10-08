<template>
  <div>
    <div class="toolbar">
      <select v-model="type_id" @change="reload"><option value="">All types</option></select>
      <select v-model="status" @change="reload"><option value="">All status</option><option value="draft">draft</option><option value="published">published</option></select>
      <button @click="openCreate">New Event</button>
      <button @click="load">Reload</button>
    </div>
    <table class="table-sm">
      <thead><tr><th>ID</th><th>Title</th><th>Start</th><th>Type</th><th>Status</th><th></th></tr></thead>
      <tbody>
        <tr v-for="e in rows" :key="e.id">
          <td>{{ e.id }}</td>
          <td>{{ e.title }}</td>
          <td>{{ e.start_date }}</td>
          <td>{{ e.type?.name }}</td>
          <td>{{ e.status }}</td>
          <td>
            <button @click="edit(e)">Edit</button>
            <button @click="del(e)">Delete</button>
          </td>
        </tr>
      </tbody>
    </table>
    <Pagination :page="page" :pages="pages" @update:page="p=>{page=p; load();}" />
    <CrudFormModal :open="modalOpen" :title="modalTitle" :submit-label="modalMode==='create'?'Create':'Save'" @close="closeModal" @submit="submit">
      <input v-model="form.title" placeholder="Title" required />
      <textarea v-model="form.description" placeholder="Description" rows="4" />
      <input type="date" v-model="form.start_date" required />
      <input type="date" v-model="form.end_date" />
      <select v-model="form.status"><option value="draft">draft</option><option value="published">published</option></select>
    </CrudFormModal>
  </div>
</template>
<script setup>
import { ref, reactive, onMounted } from 'vue';
import { api } from '../lib/apiClient';
import Pagination from '../components/Pagination.vue';
import CrudFormModal from '../components/CrudFormModal.vue';
const rows=ref([]); const page=ref(1); const pages=ref(1); const status=ref(''); const type_id=ref('');
const modalOpen=ref(false); const modalMode=ref('create'); const modalTitle=ref('');
const form=reactive({ id:null,title:'',description:'',start_date:'',end_date:'',status:'draft' });
function openCreate(){ modalMode.value='create'; modalTitle.value='Create Event'; Object.assign(form,{id:null,title:'',description:'',start_date:'',end_date:'',status:'draft'}); modalOpen.value=true; }
function edit(e){ modalMode.value='edit'; modalTitle.value='Edit Event'; Object.assign(form,{id:e.id,title:e.title,description:e.description||'',start_date:e.start_date,end_date:e.end_date,status:e.status||'draft'}); modalOpen.value=true; }
function closeModal(){ modalOpen.value=false; }
async function load(){ const data=await api.crud.list('events',{ page:page.value, status: status.value, type_id: type_id.value }); rows.value=data.data||[]; pages.value=data.last_page||1; }
function reload(){ page.value=1; load(); }
async function submit(){ const payload={ title:form.title, description:form.description, start_date:form.start_date, end_date:form.end_date||null, status:form.status }; if(modalMode.value==='create'){ await api.crud.create('events',payload); } else { await api.crud.update('events',form.id,payload); } closeModal(); load(); }
async function del(e){ if(!confirm('Delete event?')) return; await api.crud.destroy('events',e.id); load(); }
onMounted(load);
</script>
