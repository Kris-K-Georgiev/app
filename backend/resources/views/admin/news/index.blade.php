@extends('admin.layout')
@section('content')
<x-admin.page-header :title="__('admin.nav.news')">
  <x-slot:actions>
  <x-admin.button :href="route('admin.news.create')" variant="primary" size="sm">{{ __('admin.actions.create') }}</x-admin.button>
  </x-slot:actions>
</x-admin.page-header>
<x-admin.table>
  <div class="row g-2 align-items-end w-100">
    <div class="col-auto">
      <label for="newsSearch" class="form-label small mb-1">{{ __('admin.labels.search') }}</label>
      <div class="input-group input-group-sm">
        <input id="newsSearch" type="text" value="{{ request('search') }}" placeholder="{{ __('admin.placeholders.news_search') }}" class="form-control" />
        <button class="btn btn-outline-secondary" type="button" id="newsClearSearch" title="{{ __('admin.filters.clear') }}" {{ request('search')?'':'disabled' }}>✕</button>
      </div>
    </div>
    <div class="col-auto">
      <label for="newsStatus" class="form-label small mb-1">{{ __('admin.labels.status') }}</label>
      <select id="newsStatus" class="form-select form-select-sm">
        <option value="">{{ __('admin.labels.all') }}</option>
        <option value="published" {{ request('status')==='published' ? 'selected':'' }}>{{ __('admin.status.published') }}</option>
        <option value="draft" {{ request('status')==='draft' ? 'selected':'' }}>{{ __('admin.status.draft') }}</option>
      </select>
    </div>
    <div class="col d-flex align-items-end gap-2">
      <div class="d-flex align-items-center gap-2 w-100">
        <span id="newsFilterBadge" class="badge text-bg-secondary" style="display:none"></span>
	    <button type="button" id="newsClearFilters" class="btn btn-sm btn-warning ms-auto" disabled>{{ __('admin.filters.clear') }}</button>
      </div>
    </div>
  </div>
  <x-slot:table>
    <div id="newsTableWrapper">
      @include('admin.news._table',[ 'items'=>$items ])
    </div>
  </x-slot:table>
  <x-slot:pagination>{{ $items->links() }}</x-slot:pagination>
</x-admin.table>
<script>
// Sorting + filter badge logic (news)
function initSortableNews(){
  const headerRow=document.querySelector('#newsTableWrapper thead tr[data-table-sortable]');
  if(!headerRow) return;
  headerRow.addEventListener('click', e=>{
    const th=e.target.closest('th.sortable'); if(!th) return; const field=th.getAttribute('data-sort');
    let dir=th.getAttribute('data-sort-dir'); dir = dir === 'asc' ? 'desc' : (dir === 'desc' ? null : 'asc');
    headerRow.querySelectorAll('th.sortable').forEach(h=> h.removeAttribute('data-sort-dir'));
    if(dir) th.setAttribute('data-sort-dir', dir);
    // store in URL params & reload
    const p=new URLSearchParams(window.location.search); if(dir){ p.set('sort', field); p.set('dir', dir); } else { p.delete('sort'); p.delete('dir'); }
    history.replaceState({}, '', window.location.pathname + (p.toString()?('?'+p.toString()):''));
    loadNews();
  });
  // restore from params
  const params=new URLSearchParams(window.location.search); const sf=params.get('sort'); const sd=params.get('dir');
  if(sf && sd){ const target=headerRow.querySelector(`th.sortable[data-sort="${sf}"]`); if(target){ target.setAttribute('data-sort-dir', sd); }}
}
function updateNewsFilterBadge(){
  const params=new URLSearchParams(newsQuery()); let count=0; ['search','status'].forEach(k=>{ if(params.get(k)) count++; });
  let badge=document.getElementById('newsFilterBadge');
  if(!badge){ const fb=document.querySelector('.filter-bar'); if(!fb) return; badge=document.createElement('span'); badge.id='newsFilterBadge'; badge.className='filter-badge'; fb.appendChild(badge);} 
  badge.textContent = count? (count+' филтър'+(count>1?'а':'')) : '';
  badge.style.display = count? 'inline-flex':'none';
  const clearBtn=document.getElementById('newsClearFilters');
  if(clearBtn) clearBtn.disabled = count===0;
}
const newsSearch=document.getElementById('newsSearch');
const newsClearSearch=document.getElementById('newsClearSearch');
const newsStatus=document.getElementById('newsStatus');
const newsClear=document.getElementById('newsClearFilters');
let newsRefreshing=false;
function newsQuery(){ const p=new URLSearchParams(); if(newsSearch.value.trim()) p.set('search', newsSearch.value.trim()); if(newsStatus.value) p.set('status', newsStatus.value); return p.toString(); }
async function loadNews(silent=false){ if(newsRefreshing) return; newsRefreshing=true; const wrap=document.getElementById('newsTableWrapper'); if(!silent){ wrap.innerHTML=@json(view('components.admin.skeleton.table',['rows'=>6,'cols'=>8])->render()); }
  try{ const qs=newsQuery(); const res= await fetch(window.location.pathname + (qs?('?'+qs):''), { headers:{'Accept':'application/json'} }); if(!res.ok) throw new Error('HTTP '+res.status); const data= await res.json(); wrap.innerHTML = data.html; initSortableNews(); updateNewsFilterBadge(); }catch(e){ if(!silent) AdminTheme.toast('News load failed','error'); } finally { newsRefreshing=false; } }
const debouncedNews=(()=>{ let t; return ()=>{ clearTimeout(t); t=setTimeout(()=> loadNews(true),350); };})();
newsSearch.addEventListener('input', ()=>{ if(newsClearSearch) newsClearSearch.disabled = !newsSearch.value.trim(); debouncedNews(); updateNewsFilterBadge(); });
newsStatus.addEventListener('change', ()=> { loadNews(); updateNewsFilterBadge(); });
newsClearSearch?.addEventListener('click', ()=> { newsSearch.value=''; newsClearSearch.disabled=true; loadNews(); updateNewsFilterBadge(); });
newsClear.addEventListener('click', ()=> { newsSearch.value=''; newsStatus.value=''; history.replaceState({},'', window.location.pathname); loadNews(); updateNewsFilterBadge(); });
setInterval(()=> loadNews(true), 25000);
initSortableNews(); updateNewsFilterBadge();
AdminTheme.bulk({
  resource:'news',
  checkboxSelector:'.news-row-checkbox',
  bulkBarId:'newsBulkBar',
  deleteBtnId:'newsBulkDelete',
  exportBtnId:'newsExport',
  routes:{ delete:@json(route('admin.news.bulkDelete')), export:@json(route('admin.news.export')) },
  queryBuilder: newsQuery,
  onRefresh: loadNews
});
</script>
@endsection
