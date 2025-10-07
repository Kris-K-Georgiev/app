@extends('admin.layout')
@section('content')
<div class="col-12 col-xl-9 mx-auto">
  <x-admin.card :title="'Редакция на новина #'.$news->id">
    <x-form :action="route('admin.news.update',$news)" method="PUT" files>
  <x-admin.form.section title="Основна информация">
    <x-admin.form.input name="title" label="Заглавие" :value="old('title',$news->title)" :error="$errors->first('title')" required />
  <x-admin.form.select name="status" label="Статус" :options="['published'=>__('admin.status.published'),'draft'=>__('admin.status.draft')]" :value="old('status',$news->status)" />
  </x-admin.form.section>
  <x-admin.form.section title="Изображения" description="Управление на основно изображение и галерия.">
    @if($news->cover)
      <div>
        <label class="form-label ls-wide-2">Текуща корица</label>
        <div class="image-frame"><img src="{{ asset('storage/'.$news->cover) }}" alt="cover" style="max-width:220px; max-height:160px; object-fit:cover; border-radius:8px;" /></div>
      </div>
    @elseif($news->image)
      <div>
        <label class="form-label ls-wide-2">Текущо основно изображение</label>
        <div class="image-frame"><img src="{{ asset('storage/'.$news->image) }}" alt="cover" style="max-width:220px; max-height:160px; object-fit:cover; border-radius:8px;" /></div>
      </div>
    @endif
    <div>
  <x-admin.form.file name="image" :error="$errors->first('image')" placeholder="Избор на ново изображение" compact />
    </div>
  <div class="gallery-group" style="grid-column:1 / -1;">
      <x-admin.form.group label="Галерия изображения" help="Влачете за пренареждане">
        @if($news->images && $news->images->count())
          <div class="gallery-grid" id="galleryItems">
            @foreach($news->images as $img)
              <div class="draggable" data-id="{{ $img->id }}">
                <img src="{{ asset('storage/'.$img->path) }}" alt="img" style="max-width:110px; max-height:80px; object-fit:cover; border-radius:6px;" />
              </div>
            @endforeach
          </div>
        @else
          <div class="table-empty" style="padding:1rem 0;">Няма изображения в галерията.</div>
        @endif
        <div class="mt-2">
          <x-admin.form.file name="images" multiple placeholder="Изберете файлове" compact />
        </div>
      </x-admin.form.group>
    </div>
  </x-admin.form.section>
  <x-admin.form.section title="Съдържание">
    <x-admin.form.textarea name="content" rows="8" label="Съдържание" :error="$errors->first('content')" :value="old('content',$news->content)" />
  </x-admin.form.section>
      <div class="form-actions-sticky">
        <x-admin.button type="submit" variant="primary">Обнови</x-admin.button>
      </div>
    </x-form>
  </x-admin.card>
  @if($errors->any())<script>AdminTheme.toast('Поправете грешките във формата','error');</script>@endif
</div>
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.2/Sortable.min.js"></script>
<script>
  const el=document.getElementById('galleryItems');
  if(el){
    new Sortable(el, {
      animation:150,
      onEnd: async function(){
        const order=Array.from(el.querySelectorAll('[data-id]')).map((c,i)=>({id:c.dataset.id, position:i}));
        try{ await fetch('{{ route('admin.news.index') }}/reorder', {method:'POST', headers:{'Content-Type':'application/json','X-CSRF-TOKEN':'{{ csrf_token() }}'}, body: JSON.stringify({order})}); }
        catch(e){ console.warn('Reorder failed', e); }
      }
    });
  }
</script>
@endsection
