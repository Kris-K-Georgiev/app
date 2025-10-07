@extends('admin.layout')
@section('content')
<x-admin.page-header title="Потребители" />
<div class="mb-2"><span class="text-secondary tbl-meta" id="usersCounts">Общо: {{ $counts['total'] }} / Админи: {{ $counts['admins'] }}</span></div>
<x-admin.table>
  <div class="row g-2 align-items-end w-100">
    <div class="col-auto">
      <label for="userSearch" class="form-label small mb-1">{{ __('admin.labels.search') }}</label>
      <div class="input-group input-group-sm">
        <input id="userSearch" type="text" value="{{ request('search') }}" placeholder="{{ __('admin.placeholders.user_search') }}" class="form-control" />
        <button class="btn btn-outline-secondary" type="button" id="usersClearSearch" title="{{ __('admin.filters.clear') }}" {{ request('search')?'':'disabled' }}>✕</button>
      </div>
    </div>
    <div class="col-auto">
      <label for="userRole" class="form-label small mb-1">{{ __('admin.labels.role') }}</label>
      <select id="userRole" class="form-select form-select-sm">
        <option value="">{{ __('admin.labels.all') }}</option>
        <option value="admin" @selected(request('role')==='admin')>{{ __('admin.labels.role') }}: Admin</option>
      </select>
    </div>
    <div class="col d-flex align-items-end gap-2">
      <div class="d-flex align-items-center gap-2 w-100">
        <span id="usersFilterBadge" class="badge text-bg-secondary" style="display:none"></span>
	    <button type="button" id="usersClearFilters" class="btn btn-sm btn-warning ms-auto" disabled>{{ __('admin.filters.clear') }}</button>
      </div>
    </div>
  </div>
  <x-slot:table>
    <div id="usersTableWrapper">
      @include('admin.users._table',[ 'items'=>$items ])
    </div>
  </x-slot:table>
  <x-slot:pagination>{{ $items->links() }}</x-slot:pagination>
</x-admin.table>
<script>
function initSortableUsers(){
  const headerRow=document.querySelector('#usersTableWrapper thead tr[data-table-sortable]'); if(!headerRow) return;
  headerRow.addEventListener('click', e=>{
    const th=e.target.closest('th.sortable'); if(!th) return; const field=th.getAttribute('data-sort');
    let dir=th.getAttribute('data-sort-dir'); dir = dir === 'asc' ? 'desc' : (dir === 'desc' ? null : 'asc');
    headerRow.querySelectorAll('th.sortable').forEach(h=> h.removeAttribute('data-sort-dir'));
    if(dir) th.setAttribute('data-sort-dir', dir);
    const p=new URLSearchParams(window.location.search); if(dir){ p.set('sort', field); p.set('dir', dir); } else { p.delete('sort'); p.delete('dir'); }
    history.replaceState({}, '', window.location.pathname + (p.toString()?('?'+p.toString()):''));
    loadUsers();
  });
  const params=new URLSearchParams(window.location.search); const sf=params.get('sort'); const sd=params.get('dir');
  if(sf && sd){ const target=headerRow.querySelector(`th.sortable[data-sort="${sf}"]`); if(target){ target.setAttribute('data-sort-dir', sd); }}
}
function updateUsersFilterBadge(){
  const params=new URLSearchParams(usersQuery()); let count=0; ['search','role'].forEach(k=>{ if(params.get(k)) count++; });
  let badge=document.getElementById('usersFilterBadge');
  if(!badge){ const fb=document.querySelector('.filter-bar'); if(!fb) return; badge=document.createElement('span'); badge.id='usersFilterBadge'; badge.className='filter-badge'; fb.appendChild(badge);} 
  badge.textContent = count? (count+' филтър'+(count>1?'а':'')) : '';
  badge.style.display = count? 'inline-flex':'none';
  const clearBtn=document.getElementById('usersClearFilters');
  if(clearBtn) clearBtn.disabled = count===0;
}
const usersWrapper=document.getElementById('usersTableWrapper');
const userSearch=document.getElementById('userSearch');
const usersClearSearch=document.getElementById('usersClearSearch');
const userRole=document.getElementById('userRole'); const usersClear=document.getElementById('usersClearFilters');
const usersCounts=document.getElementById('usersCounts');
let usersRefreshing=false;
function usersQuery(){ const p=new URLSearchParams(); if(userSearch.value.trim()) p.set('search', userSearch.value.trim()); if(userRole.value) p.set('role', userRole.value); return p.toString(); }
async function loadUsers(silent=false){ if(usersRefreshing) return; usersRefreshing=true; if(!silent){ usersWrapper.innerHTML=@json(view('components.admin.skeleton.table',['rows'=>6,'cols'=>8])->render()); }
  try{ const qs=usersQuery(); const res= await fetch(window.location.pathname + (qs?('?'+qs):''), { headers:{'Accept':'application/json'} }); if(!res.ok) throw new Error('HTTP '+res.status); const data= await res.json(); usersWrapper.innerHTML = data.html; usersCounts.textContent='Общо: '+data.counts.total+' / Админи: '+data.counts.admins; initSortableUsers(); updateUsersFilterBadge(); }catch(e){ if(!silent) AdminTheme.toast('Users load failed','error'); } finally { usersRefreshing=false; }}
const debouncedUsers=(()=>{ let t; return ()=>{ clearTimeout(t); t=setTimeout(()=> loadUsers(true),350); };})();
userSearch.addEventListener('input', ()=> { if(usersClearSearch) usersClearSearch.disabled=!userSearch.value.trim(); debouncedUsers(); updateUsersFilterBadge(); });
userRole.addEventListener('change', ()=> { loadUsers(); updateUsersFilterBadge(); });
usersClearSearch?.addEventListener('click', ()=> { userSearch.value=''; usersClearSearch.disabled=true; loadUsers(); updateUsersFilterBadge(); });
usersClear.addEventListener('click', ()=> { userSearch.value=''; userRole.value=''; history.replaceState({},'', window.location.pathname); loadUsers(); updateUsersFilterBadge(); });
setInterval(()=> loadUsers(true), 28000);
initSortableUsers(); updateUsersFilterBadge();
AdminTheme.bulk({
  resource:'users',
  checkboxSelector:'.user-row-checkbox',
  bulkBarId:'userBulkBar',
  deleteBtnId:'userBulkDelete',
  exportBtnId:'userExport',
  routes:{ delete:@json(route('admin.users.bulkDelete')), export:@json(route('admin.users.export')) },
  queryBuilder: usersQuery,
  onRefresh: loadUsers
});
// inline role select handling (kept outside bulk abstraction)
document.addEventListener('change', async (e)=>{
  if(e.target.matches('.user-role-select')){
    const sel=e.target; const id=sel.dataset.id; const form=new FormData(); form.append('name', sel.dataset.name); form.append('role', sel.value); form.append('_method','PUT');
    try{ const res= await fetch(@json(url('/admin/users')) + '/' + id, { method:'POST', headers:{'Accept':'application/json','X-CSRF-TOKEN':document.querySelector('meta[name="csrf-token"]').content }, body: form }); if(res.ok){ AdminTheme.toast('Updated role','success'); } else { AdminTheme.toast('Role update failed','error'); } }catch(err){ AdminTheme.toast('Role update error','error'); }
  }
});
</script>
@endsection
