@extends('admin.layout')
@section('content')
<x-admin.page-header :title="__('admin.nav.events')">
  <x-slot:actions>
  <x-admin.button :href="route('admin.events.create')" variant="primary" size="sm">{{ __('admin.actions.create') }}</x-admin.button>
  </x-slot:actions>
</x-admin.page-header>
<x-admin.table>
  <div class="row g-2 align-items-end w-100">
    <div class="col-auto">
      <label for="eventsSearch" class="form-label small mb-1">{{ __('admin.labels.search') }}</label>
      <div class="input-group input-group-sm">
        <input id="eventsSearch" type="text" value="{{ request('search') }}" placeholder="{{ __('admin.placeholders.events_search') }}" class="form-control" />
        <button class="btn btn-outline-secondary" type="button" id="eventsClearSearch" title="{{ __('admin.filters.clear') }}" {{ request('search')?'':'disabled' }}>✕</button>
      </div>
    </div>
    <div class="col-auto">
      <label for="eventsFrom" class="form-label small mb-1">{{ __('admin.labels.from') }}</label>
      <input id="eventsFrom" type="date" value="{{ request('from') }}" class="form-control form-control-sm" />
    </div>
    <div class="col-auto">
      <label for="eventsTo" class="form-label small mb-1">{{ __('admin.labels.to') }}</label>
      <input id="eventsTo" type="date" value="{{ request('to') }}" class="form-control form-control-sm" />
    </div>
    <div class="col-auto">
      <label for="eventsStatus" class="form-label small mb-1">{{ __('admin.labels.status') }}</label>
      <select id="eventsStatus" class="form-select form-select-sm">
        <option value="">{{ __('admin.labels.all') }}</option>
        <option value="active" {{ request('status')==='active' ? 'selected':'' }}>{{ __('admin.status.active') }}</option>
        <option value="inactive" {{ request('status')==='inactive' ? 'selected':'' }}>{{ __('admin.status.inactive') }}</option>
      </select>
    </div>
    <div class="col-auto">
      <label for="eventsType" class="form-label small mb-1">{{ __('admin.labels.type') }}</label>
      <select id="eventsType" class="form-select form-select-sm">
        <option value="">{{ __('admin.labels.all') }}</option>
      @foreach(\App\Models\EventType::orderBy('name')->get() as $t)
        <option value="{{ $t->id }}" {{ request('type')==$t->id ? 'selected':'' }}>{{ $t->name }}</option>
      @endforeach
      </select>
    </div>
    <div class="col d-flex align-items-end gap-2">
      <div class="d-flex align-items-center gap-2 w-100">
        <span id="eventsFilterBadge" class="badge text-bg-secondary" style="display:none"></span>
	    <button type="button" id="eventsClearFilters" class="btn btn-sm btn-warning ms-auto" disabled>{{ __('admin.filters.clear') }}</button>
      </div>
    </div>
  </div>
  <x-slot:table>
    <div id="eventsTableWrapper">
      @include('admin.events._table',[ 'items'=>$items ])
    </div>
  </x-slot:table>
  <x-slot:pagination>{{ $items->links() }}</x-slot:pagination>
</x-admin.table>
<script>
function initSortableEvents(){
  const headerRow=document.querySelector('#eventsTableWrapper thead tr[data-table-sortable]'); if(!headerRow) return;
  headerRow.addEventListener('click', e=>{
    const th=e.target.closest('th.sortable'); if(!th) return; const field=th.getAttribute('data-sort');
    let dir=th.getAttribute('data-sort-dir'); dir = dir === 'asc' ? 'desc' : (dir === 'desc' ? null : 'asc');
    headerRow.querySelectorAll('th.sortable').forEach(h=> h.removeAttribute('data-sort-dir'));
    if(dir) th.setAttribute('data-sort-dir', dir);
    const p=new URLSearchParams(window.location.search); if(dir){ p.set('sort', field); p.set('dir', dir); } else { p.delete('sort'); p.delete('dir'); }
    history.replaceState({}, '', window.location.pathname + (p.toString()?('?'+p.toString()):''));
    loadEvents();
  });
  const params=new URLSearchParams(window.location.search); const sf=params.get('sort'); const sd=params.get('dir');
  if(sf && sd){ const target=headerRow.querySelector(`th.sortable[data-sort="${sf}"]`); if(target){ target.setAttribute('data-sort-dir', sd); }}
}
function updateEventsFilterBadge(){
  const params=new URLSearchParams(eventsQuery()); let count=0; ['search','from','to','status','type'].forEach(k=>{ if(params.get(k)) count++; });
  let badge=document.getElementById('eventsFilterBadge');
  if(!badge){ const fb=document.querySelector('.filter-bar'); if(!fb) return; badge=document.createElement('span'); badge.id='eventsFilterBadge'; badge.className='filter-badge'; fb.appendChild(badge);} 
  badge.textContent = count? (count+' филтър'+(count>1?'а':'')) : '';
  badge.style.display = count? 'inline-flex':'none';
  const clearBtn=document.getElementById('eventsClearFilters');
  if(clearBtn) clearBtn.disabled = count===0;
}
const eventsSearch=document.getElementById('eventsSearch'); const eventsFrom=document.getElementById('eventsFrom'); const eventsTo=document.getElementById('eventsTo'); const eventsStatus=document.getElementById('eventsStatus'); const eventsType=document.getElementById('eventsType'); const eventsClear=document.getElementById('eventsClearFilters'); const eventsClearSearch=document.getElementById('eventsClearSearch'); let eventsRefreshing=false;
function eventsQuery(){ const p=new URLSearchParams(); if(eventsSearch.value.trim()) p.set('search',eventsSearch.value.trim()); if(eventsFrom.value) p.set('from', eventsFrom.value); if(eventsTo.value) p.set('to', eventsTo.value); if(eventsStatus.value) p.set('status', eventsStatus.value); if(eventsType.value) p.set('type', eventsType.value); return p.toString(); }
async function loadEvents(silent=false){ if(eventsRefreshing) return; eventsRefreshing=true; const wrap=document.getElementById('eventsTableWrapper'); if(!silent){ wrap.innerHTML=@json(view('components.admin.skeleton.table',['rows'=>6,'cols'=>10])->render()); }
  try{ const qs=eventsQuery(); const res= await fetch(window.location.pathname + (qs?('?'+qs):''), { headers:{'Accept':'application/json'} }); if(!res.ok) throw new Error('HTTP '+res.status); const data= await res.json(); wrap.innerHTML = data.html; initSortableEvents(); updateEventsFilterBadge(); }catch(e){ if(!silent) AdminTheme.toast('Events load failed','error'); } finally { eventsRefreshing=false; } }
const debouncedEvents=(()=>{ let t; return ()=>{ clearTimeout(t); t=setTimeout(()=> loadEvents(true),350); };})();
eventsSearch.addEventListener('input', ()=> { if(eventsClearSearch) eventsClearSearch.disabled=!eventsSearch.value.trim(); debouncedEvents(); updateEventsFilterBadge(); });
[eventsFrom, eventsTo, eventsStatus, eventsType].forEach(el=> el.addEventListener('change', ()=> { loadEvents(); updateEventsFilterBadge(); }));
eventsClearSearch?.addEventListener('click', ()=> { eventsSearch.value=''; eventsClearSearch.disabled=true; loadEvents(); updateEventsFilterBadge(); });
eventsClear.addEventListener('click', ()=> { eventsSearch.value=''; eventsFrom.value=''; eventsTo.value=''; eventsStatus.value=''; eventsType.value=''; history.replaceState({},'', window.location.pathname); loadEvents(); updateEventsFilterBadge(); });
setInterval(()=> loadEvents(true), 30000);
initSortableEvents(); updateEventsFilterBadge();
AdminTheme.bulk({
  resource:'events',
  checkboxSelector:'.events-row-checkbox',
  bulkBarId:'eventsBulkBar',
  deleteBtnId:'eventsBulkDelete',
  exportBtnId:'eventsExport',
  routes:{ delete:@json(route('admin.events.bulkDelete')), export:@json(route('admin.events.export')) },
  queryBuilder: eventsQuery,
  onRefresh: loadEvents
});
</script>
@endsection
