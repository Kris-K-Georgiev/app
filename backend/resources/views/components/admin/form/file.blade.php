@props([
  'name','label'=>null,'multiple'=>false,'required'=>false,'accept'=>null,'error'=>null,'help'=>null,'icon'=>'upload','placeholder'=>null,'compact'=>false
])
<div class="form-group file-group">
  @if($label)
    <label for="{{ $name }}" class="form-label">{{ $label }} @if($required)<span class="text-danger">*</span>@endif</label>
  @endif
  <div class="file-input @if($error) has-error @endif @if($compact) compact @endif" data-file-input data-max-size="{{ 5 * 1024 * 1024 }}">
    <input id="{{ $name }}" name="{{ $name }}@if($multiple)[]@endif" type="file" @if($multiple) multiple @endif @if($accept) accept="{{ $accept }}" @endif @if($required) required @endif />
    <div class="file-cta">
      <span class="file-icon" aria-hidden="true">
        <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 17v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-2"/><polyline points="7 9 12 4 17 9"/><line x1="12" y1="4" x2="12" y2="16"/></svg>
      </span>
      <span class="file-label" data-file-label>
        @if(!$compact)
          <span class="dd-hint">{{ __('admin.labels.drag_drop') }}</span>
          <span class="dd-action"><strong>{{ $multiple ? __('admin.actions.choose_files') : ($placeholder ?? __('admin.actions.choose_file')) }}</strong></span>
        @else
          <span class="dd-action"><strong>{{ $multiple ? __('admin.actions.choose_files') : ($placeholder ?? __('admin.actions.choose_file')) }}</strong></span>
        @endif
      </span>
      <div class="file-actions" style="display:flex; gap:.35rem; align-items:center;">
        <button type="button" class="btn btn-sm btn-outline-secondary py-1 px-2 file-btn" data-trigger style="font-size:.65rem;">{{ __('admin.actions.choose') }}</button>
        <button type="button" class="btn btn-sm btn-light py-1 px-2 file-clear" data-clear title="Изчисти" style="display:none;font-size:.65rem;">✕</button>
      </div>
    </div>
    <div class="file-meta" data-file-meta style="display:none"></div>
    <div class="file-thumbs" data-file-thumbs style="display:none"></div>
    <div class="file-errors" data-file-errors style="display:none"></div>
  </div>
  @if($help)<div class="form-help">{{ $help }}</div>@endif
  @if($error)<div class="form-error">{{ $error }}</div>@endif
</div>
<script>
document.addEventListener('DOMContentLoaded',()=>{
  document.querySelectorAll('[data-file-input]').forEach(w=>{
    const input=w.querySelector('input[type=file]');
    const meta=w.querySelector('[data-file-meta]');
    const label=w.querySelector('[data-file-label]');
    const btn=w.querySelector('[data-trigger]');
    const thumbs=w.querySelector('[data-file-thumbs]');
    const errs=w.querySelector('[data-file-errors]');
    const clearBtn=w.querySelector('[data-clear]');
    const MAX=w.dataset.maxSize? parseInt(w.dataset.maxSize,10): 5242880;
    function pluralBG(n){
      if(n===1) return ''; // handled separately
      return 'а';
    }
    function resetState(){
      meta.style.display='none'; meta.textContent='';
      thumbs.style.display='none'; thumbs.innerHTML='';
      errs.style.display='none'; errs.innerHTML='';
      clearBtn.style.display='none';
  label.innerHTML= @json($compact) ? '<span class="dd-action"><strong>'+(@json($multiple) ? @json(__('admin.actions.choose_files')) : @json(__('admin.actions.choose_file')) )+'</strong></span>' : '<span class="dd-hint">'+@json(__('admin.labels.drag_drop'))+'</span> <span class="dd-action"><strong>'+(@json($multiple) ? @json(__('admin.actions.choose_files')) : @json(__('admin.actions.choose_file')) )+'</strong></span>';
    }
    function validateFile(f){
      if(f.size>MAX) return 'Размерът на '+f.name+' надвишава '+(MAX/1024/1024).toFixed(1)+'MB';
      return null;
    }
    function update(){
      if(!input.files || !input.files.length){ resetState(); return; }
      const files=Array.from(input.files);
      const errors=[]; files.forEach(f=>{ const e=validateFile(f); if(e) errors.push(e); });
      if(errors.length){
        errs.style.display='block';
        errs.innerHTML=errors.map(e=>'<div class="file-error-item">'+e+'</div>').join('');
      } else { errs.style.display='none'; errs.innerHTML=''; }
      const count=files.length;
      let base;
      if(count===1){ base=files[0].name; }
      else { base=count+' файла'+pluralBG(count)+' '+@json(__('admin.labels.selected_files')); }
      meta.textContent=files.slice(0,4).map(f=>f.name).join(', ')+(count>4?' …':'');
      meta.style.display='block';
      label.textContent=base;
      // thumbnails (only images)
      const imgFiles=files.filter(f=> f.type.startsWith('image/')).slice(0,6);
      if(imgFiles.length){
        thumbs.style.display='grid';
        thumbs.style.gridTemplateColumns='repeat(auto-fill,minmax(46px,1fr))';
        thumbs.style.gap='.4rem';
        thumbs.innerHTML='';
        imgFiles.forEach(f=>{
          const url=URL.createObjectURL(f);
          const div=document.createElement('div');
          div.className='thumb';
            div.style.cssText='position:relative;border:1px solid var(--color-border);border-radius:6px;overflow:hidden;aspect-ratio:1/1;background:var(--color-border-soft);';
          const im=document.createElement('img'); im.src=url; im.style='width:100%;height:100%;object-fit:cover;';
          div.appendChild(im); thumbs.appendChild(div);
        });
      } else { thumbs.style.display='none'; thumbs.innerHTML=''; }
      clearBtn.style.display='inline-flex';
    }
    clearBtn.addEventListener('click', ()=> { input.value=''; resetState(); });
  ['dragenter','dragover'].forEach(ev=> w.addEventListener(ev, e=>{ e.preventDefault(); w.classList.add('drag-over'); }));
  ['dragleave','drop'].forEach(ev=> w.addEventListener(ev, e=>{ if(e.type==='drop'){ const dt=e.dataTransfer; if(dt && dt.files){ input.files=dt.files; update(); } } w.classList.remove('drag-over'); }));
  resetState();
    input.addEventListener('change', update); btn?.addEventListener('click', ()=> input.click());
  });
});
</script>