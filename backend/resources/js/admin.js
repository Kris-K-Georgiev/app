// Sneat-like admin bootstrap (lightweight) – leverages existing Laravel routes.
window.AdminTheme = (function(){
  const api = {};
  api.toast = function(msg,type='info'){ const wrap = document.querySelector('.toast-stack')||(()=>{const d=document.createElement('div'); d.className='toast-stack'; document.body.appendChild(d); return d;})(); const el=document.createElement('div'); el.className='toast '+type; el.innerHTML='<span style="line-height:1.2">'+msg+'</span><button aria-label="Close">×</button>'; el.querySelector('button').onclick=()=>{ el.remove(); }; wrap.appendChild(el); setTimeout(()=>{ if(document.body.contains(el)){ el.remove(); } },4000); };
  api.toggleTheme = function(){ const html=document.documentElement; const dark=html.getAttribute('data-theme')==='dark'; html.setAttribute('data-theme', dark?'light':'dark'); localStorage.setItem('adminTheme', dark?'light':'dark'); };
  api.applyPersistedTheme = function(){ const saved=localStorage.getItem('adminTheme'); if(saved){ document.documentElement.setAttribute('data-theme', saved); } };
  api.sidebar = { toggle(){ document.querySelector('.sneat-sidebar')?.classList.toggle('open'); } };
  api.loader = {
    show(){ if(document.getElementById('adminLoader')) return; const d=document.createElement('div'); d.id='adminLoader'; d.style.position='fixed'; d.style.inset='0'; d.style.background='rgba(15,18,28,.45)'; d.style.backdropFilter='blur(2px)'; d.style.display='flex'; d.style.alignItems='center'; d.style.justifyContent='center'; d.style.zIndex='120'; d.innerHTML='<div class="spinner-border text-light" role="status" style="width:2.5rem;height:2.5rem;"><span class="visually-hidden">Loading...</span></div>'; document.body.appendChild(d); },
    hide(){ const d=document.getElementById('adminLoader'); if(d) d.remove(); }
  };
  api.bulk = function(opts){
    const { resource, checkboxSelector, bulkBarId, deleteBtnId, exportBtnId, routes } = opts;
    const checkboxes = ()=> Array.from(document.querySelectorAll(checkboxSelector));
    const selected = ()=> checkboxes().filter(c=> c.checked).map(c=> c.value);
    const bulkBar = document.getElementById(bulkBarId);
    function update(){ if(!bulkBar) return; bulkBar.style.display = selected().length? 'flex':'none'; }
    document.addEventListener('change', e=>{ if(e.target.matches(checkboxSelector)) update(); });
    async function doDelete(){
      const ids=selected(); if(!ids.length) return;
      confirmModal('Delete '+ids.length+' '+resource+'?', async ()=> {
        api.loader.show();
        try {
          const r= await fetch(routes.delete,{ method:'POST', headers:{'Content-Type':'application/json','X-CSRF-TOKEN':document.querySelector('meta[name="csrf-token"]').content, 'Accept':'application/json'}, body: JSON.stringify({ids})});
          const j= await r.json();
          if(j.ok){ api.toast('Deleted '+resource,'success'); if(typeof opts.onRefresh === 'function') opts.onRefresh(); } else api.toast('Delete failed','error');
        } catch(e){ api.toast('Error','error'); }
        finally { api.loader.hide(); }
      });
    }
    function doExport(){ const ids=selected(); const qs = typeof opts.queryBuilder==='function'? opts.queryBuilder():''; const extra = qs? (qs+'&'):''; window.location = routes.export + '?' + extra + (ids.length? ('ids='+ids.join(',')):''); }
    if(deleteBtnId) document.getElementById(deleteBtnId)?.addEventListener('click', doDelete);
    if(exportBtnId) document.getElementById(exportBtnId)?.addEventListener('click', doExport);
    update();
    return { refresh:update };
  };
  return api;
})();

function confirmModal(message, onConfirm){
  let modal = document.getElementById('confirmModal');
  if(!modal){
    const wrap=document.createElement('div');
    wrap.innerHTML=`<div id="confirmModal" class="admin-modal" style="display:none;">
      <div class="admin-modal-backdrop" data-modal-close></div>
      <div class="admin-modal-dialog">
        <div class="admin-modal-header d-flex justify-content-between align-items-center mb-2">
          <h6 class="mb-0 small text-uppercase fw-semibold" style="letter-spacing:.06em; font-size:.55rem;">Confirm</h6>
          <button class="btn btn-sm ghost p-0" data-modal-close aria-label="Close" style="width:24px;height:24px;display:flex;align-items:center;justify-content:center;">×</button>
        </div>
        <div class="admin-modal-body mb-3 small" style="font-size:.65rem; line-height:1.3;"></div>
        <div class="admin-modal-footer d-flex justify-content-end gap-2">
          <button type="button" class="btn outline btn-sm" data-modal-close style="font-size:.6rem;">Cancel</button>
          <button type="button" class="btn danger btn-sm" data-modal-confirm style="font-size:.6rem;">Confirm</button>
        </div>
      </div>
    </div>`;
    document.body.appendChild(wrap.firstElementChild);
    modal=document.getElementById('confirmModal');
    modal.addEventListener('click', ev=> { if(ev.target.closest('[data-modal-close]')) { modal.style.display='none'; } });
  }
  modal.querySelector('.admin-modal-body').textContent=message;
  const confirmBtn=modal.querySelector('[data-modal-confirm]');
  confirmBtn.onclick=()=>{ modal.style.display='none'; if(typeof onConfirm==='function') onConfirm(); };
  modal.style.display='block';
}

window.addEventListener('DOMContentLoaded',()=>{
  AdminTheme.applyPersistedTheme();
  document.querySelectorAll('[data-toggle="theme"]').forEach(btn=> btn.addEventListener('click', AdminTheme.toggleTheme));
  document.querySelectorAll('[data-toggle="sidebar"]').forEach(btn=> btn.addEventListener('click', AdminTheme.sidebar.toggle));
  // Auto-close sidebar on link click (mobile)
  const sidebar = document.querySelector('.sneat-sidebar');
  if(sidebar){
    sidebar.querySelectorAll('a.nav-link').forEach(a=> a.addEventListener('click', ()=> {
      if(window.innerWidth < 960 && sidebar.classList.contains('open')) AdminTheme.sidebar.toggle();
    }));
  }
  // Intercept forms with data-confirm
  document.addEventListener('submit', e=> { const f=e.target; if(!(f instanceof HTMLFormElement)) return; const msg=f.getAttribute('data-confirm'); if(msg){ e.preventDefault(); confirmModal(msg, ()=> f.submit()); }});
});
