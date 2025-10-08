<template>
  <div>
    <div class="toolbar">
      <input v-model="search" @keyup.enter="reload" placeholder="Search name/email" />
      <select v-model="role" @change="reload"><option value="">All roles</option><option value="admin">Admin</option><option value="user">User</option></select>
      <button @click="openCreate">New User</button>
      <button @click="load">Reload</button>
    </div>
    <table class="table-sm">
      <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Role</th><th></th></tr></thead>
      <tbody>
        <tr v-for="u in rows" :key="u.id">
          <td>{{ u.id }}</td>
          <td>{{ u.name }}</td>
          <td>{{ u.email }}</td>
          <td>{{ u.role }}</td>
          <td>
            <button @click="edit(u)">Edit</button>
            <button v-if="!u.deleted_at" @click="del(u)">Delete</button>
            <button v-else @click="restore(u)">Restore</button>
          </td>
        </tr>
      </tbody>
    </table>
    <Pagination :page="page" :pages="pages" @update:page="p=>{page=p; load();}" />
    <CrudFormModal :open="modalOpen" :title="modalTitle" :submit-label="modalMode==='create'?'Create':'Save'" @close="closeModal" @submit="submit">
      <input v-model="form.name" placeholder="Name" required />
      <input v-model="form.email" placeholder="Email" required type="email" />
      <input v-if="modalMode==='create'" v-model="form.password" placeholder="Password" type="password" required />
      <select v-model="form.role"><option value="user">user</option><option value="admin">admin</option></select>
    </CrudFormModal>
  </div>
</template>
<script setup>
import { ref, reactive, onMounted } from 'vue';
import { api } from '../lib/apiClient';
import Pagination from '../components/Pagination.vue';
import CrudFormModal from '../components/CrudFormModal.vue';
const rows=ref([]); const page=ref(1); const pages=ref(1); const search=ref(''); const role=ref('');
const modalOpen=ref(false); const modalMode=ref('create'); const modalTitle=ref('');
const form=reactive({ id:null,name:'',email:'',password:'',role:'user' });
function openCreate(){ modalMode.value='create'; modalTitle.value='Create User'; Object.assign(form,{id:null,name:'',email:'',password:'',role:'user'}); modalOpen.value=true; }
function edit(u){ modalMode.value='edit'; modalTitle.value='Edit User'; Object.assign(form,{id:u.id,name:u.name,email:u.email,password:'',role:u.role}); modalOpen.value=true; }
function closeModal(){ modalOpen.value=false; }
async function load(){ const data=await api.crud.list('users',{ page:page.value, search:search.value, role:role.value }); rows.value=data.data||[]; pages.value=data.last_page||1; }
function reload(){ page.value=1; load(); }
async function submit(){ if(modalMode.value==='create'){ await api.crud.create('users',form); } else { await api.crud.update('users',form.id,{ name:form.name,email:form.email, role:form.role, ...(form.password?{password:form.password}:{}) }); } closeModal(); load(); }
async function del(u){ if(!confirm('Delete user?')) return; await api.crud.destroy('users',u.id); load(); }
async function restore(u){ await api.crud.restore('users',u.id); load(); }
onMounted(load);
</script>
