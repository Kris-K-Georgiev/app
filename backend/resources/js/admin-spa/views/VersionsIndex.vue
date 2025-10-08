<template>
  <div>
    <div class="toolbar">
      <button @click="openCreate">New Version</button>
      <button @click="load">Reload</button>
    </div>
    <table class="table-sm">
      <thead><tr><th>ID</th><th>Code</th><th>Name</th><th>Mandatory</th><th></th></tr></thead>
      <tbody>
        <tr v-for="v in rows" :key="v.id">
          <td>{{ v.id }}</td>
          <td>{{ v.version_code }}</td>
          <td>{{ v.version_name }}</td>
          <td>{{ v.is_mandatory ? 'Y':'N' }}</td>
          <td>
            <button @click="edit(v)">Edit</button>
            <button @click="del(v)">Delete</button>
          </td>
        </tr>
      </tbody>
    </table>
    <Pagination :page="page" :pages="pages" @update:page="p=>{page=p; load();}" />
    <CrudFormModal :open="modalOpen" :title="modalTitle" :submit-label="modalMode==='create'?'Create':'Save'" @close="closeModal" @submit="submit">
      <input v-model.number="form.version_code" placeholder="Version Code" type="number" required />
      <input v-model="form.version_name" placeholder="Version Name" required />
      <textarea v-model="form.release_notes" placeholder="Release Notes" rows="4" />
      <input v-model="form.download_url" placeholder="Download URL" />
      <label><input type="checkbox" v-model="form.is_mandatory" /> Mandatory</label>
    </CrudFormModal>
  </div>
</template>
<script setup>
import { ref, reactive, onMounted } from 'vue';
import { api } from '../lib/apiClient';
import Pagination from '../components/Pagination.vue';
import CrudFormModal from '../components/CrudFormModal.vue';
const rows=ref([]); const page=ref(1); const pages=ref(1);
const modalOpen=ref(false); const modalMode=ref('create'); const modalTitle=ref('');
const form=reactive({ id:null,version_code:'',version_name:'',release_notes:'',download_url:'',is_mandatory:false });
function openCreate(){ modalMode.value='create'; modalTitle.value='Create Version'; Object.assign(form,{id:null,version_code:'',version_name:'',release_notes:'',download_url:'',is_mandatory:false}); modalOpen.value=true; }
function edit(v){ modalMode.value='edit'; modalTitle.value='Edit Version'; Object.assign(form,{id:v.id,version_code:v.version_code,version_name:v.version_name,release_notes:v.release_notes||'',download_url:v.download_url||'',is_mandatory:!!v.is_mandatory}); modalOpen.value=true; }
function closeModal(){ modalOpen.value=false; }
async function load(){ const data=await api.crud.list('versions',{ page:page.value }); rows.value=data.data||[]; pages.value=data.last_page||1; }
function reload(){ page.value=1; load(); }
async function submit(){ const payload={ version_code:form.version_code, version_name:form.version_name, release_notes:form.release_notes, download_url:form.download_url||null, is_mandatory:form.is_mandatory }; if(modalMode.value==='create'){ await api.crud.create('versions',payload); } else { await api.crud.update('versions',form.id,payload); } closeModal(); load(); }
async function del(v){ if(!confirm('Delete version?')) return; await api.crud.destroy('versions',v.id); load(); }
onMounted(load);
</script>
