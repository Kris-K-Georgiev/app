@extends('admin.layout')
@section('content')
<x-admin.page-header title="Версии">
  <x-slot:actions>
    <x-admin.button :href="route('admin.versions.create')" variant="primary" size="sm" icon="plus">{{ __('admin.actions.create') }}</x-admin.button>
  </x-slot:actions>
</x-admin.page-header>

<x-admin.table>
  <div class="w-100">
    <div class="row g-2 align-items-end">
      <div class="col-auto">
        <label for="versionSearch" class="form-label small mb-1">Търсене</label>
        <div class="input-group input-group-sm">
          <input id="versionSearch" type="text" value="{{ request('search') }}" placeholder="Код или име" class="form-control" />
          <button class="btn btn-outline-secondary" type="button" id="clearVersionSearch" title="Изчисти" {{ request('search')?'':'disabled' }}>✕</button>
        </div>
      </div>
      <div class="col d-flex align-items-center gap-2">
        <span id="versionsFilterBadge" class="badge text-bg-secondary" style="display:{{ request('search')?'inline-block':'none' }}">1 активен филтър</span>
        <button type="button" id="versionsClearFilters" class="btn btn-sm btn-warning ms-auto" {{ request('search')?'':'disabled' }}>Изчисти</button>
      </div>
    </div>
  </div>
  <x-slot:table>
    <div id="versionsTableWrapper">
      <table class="admin-table">
        <thead>
          <tr data-table-sortable>
            <th class="sortable" data-sort="id">ID <span class="sort-indicator"></span></th>
            <th class="sortable" data-sort="version_code">Код <span class="sort-indicator"></span></th>
            <th>Име</th>
            <th>Задължителна</th>
            <th class="sortable" data-sort="created_at">Създадена <span class="sort-indicator"></span></th>
            <th class="text-end">Действия</th>
          </tr>
        </thead>
        <tbody>
        @forelse($items as $v)
          <tr>
            <td class="tbl-id">#{{ $v->id }}</td>
            <td class="fs-xs">{{ $v->version_code }}</td>
            <td class="tbl-title">{{ $v->version_name }}</td>
            <td>
              @if($v->is_mandatory)
                <span class="badge text-bg-success fw-semibold" style="font-size:.55rem;letter-spacing:.05em;">Да</span>
              @else
                <span class="badge text-bg-secondary fw-semibold" style="font-size:.55rem;letter-spacing:.05em;">Не</span>
              @endif
            </td>
            <td class="fs-xs">{{ bg_date($v->created_at) }}</td>
            <td class="tbl-actions" style="justify-content:flex-end;">
              <x-admin.button :href="route('admin.versions.edit',$v)" size="xs" variant="outline" icon="edit" title="Редакция"></x-admin.button>
              <form method="POST" action="{{ route('admin.versions.destroy',$v) }}" data-confirm="{{ __('admin.confirm.version_delete') }}" style="display:inline">@csrf @method('DELETE')
                <x-admin.button type="submit" size="xs" variant="danger" icon="trash" title="Изтриване"></x-admin.button>
              </form>
            </td>
          </tr>
        @empty
          <tr><td colspan="6" class="text-center table-empty">Няма версии</td></tr>
        @endforelse
        </tbody>
      </table>
    </div>
  </x-slot:table>
  <x-slot:pagination>{{ $items->links() }}</x-slot:pagination>
</x-admin.table>

<script>
// Sorting (basic client + server param sync)
document.addEventListener('DOMContentLoaded',()=>{
  const header=document.querySelector('#versionsTableWrapper thead tr[data-table-sortable]');
  const search=document.getElementById('versionSearch');
  const clearBtn=document.getElementById('clearVersionSearch');
  const badge=document.getElementById('versionsFilterBadge');
  const clearFilters=document.getElementById('versionsClearFilters');
  function applySorting(th){
    const field=th.getAttribute('data-sort');
    let dir=th.getAttribute('data-sort-dir');
    dir = dir==='asc' ? 'desc' : (dir==='desc' ? null : 'asc');
    header.querySelectorAll('th.sortable').forEach(h=> h.removeAttribute('data-sort-dir'));
    if(dir) th.setAttribute('data-sort-dir',dir);
    const params=new URLSearchParams(window.location.search);
    if(dir){ params.set('sort', field); params.set('dir', dir); } else { params.delete('sort'); params.delete('dir'); }
    if(search.value.trim()) params.set('search', search.value.trim()); else params.delete('search');
    window.location = window.location.pathname + (params.toString()?('?'+params.toString()):'');
  }
  header?.addEventListener('click', e=>{ const th=e.target.closest('th.sortable'); if(th) applySorting(th); });
  const params=new URLSearchParams(window.location.search); const sf=params.get('sort'); const sd=params.get('dir'); if(sf && sd){ const th=header?.querySelector(`th[data-sort="${sf}"]`); if(th) th.setAttribute('data-sort-dir', sd); }
  function applySearch(){
    const params=new URLSearchParams(window.location.search);
    if(search.value.trim()) params.set('search',search.value.trim()); else params.delete('search');
    window.location = window.location.pathname + (params.toString()?('?'+params.toString()):'');
  }
  search?.addEventListener('keydown', e=>{ if(e.key==='Enter'){ applySearch(); }});
  clearBtn?.addEventListener('click', ()=>{ search.value=''; applySearch(); });
  search?.addEventListener('input', ()=>{
    if(clearBtn){ clearBtn.disabled = !search.value.trim(); }
    if(badge){ badge.style.display = search.value.trim()? 'inline-block':'none'; }
    if(clearFilters){ clearFilters.disabled=!search.value.trim(); }
  });
  clearFilters?.addEventListener('click', ()=> { search.value=''; if(clearBtn) clearBtn.disabled=true; if(clearFilters) clearFilters.disabled=true; applySearch(); });
});
</script>
@endsection
