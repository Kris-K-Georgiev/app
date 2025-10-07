@extends('admin.layout')
@section('content')
<div class="col-12 col-xl-9 mx-auto">
  <x-admin.card :title="'Редакция на събитие #'.$event->id">
    <x-form :action="route('admin.events.update',$event)" method="PUT" files>
  <x-admin.form.section title="Основна информация">
    <x-admin.form.input name="title" label="Заглавие" :value="old('title',$event->title)" :error="$errors->first('title')" required />
  <x-admin.form.select name="status" label="Статус" :options="['active'=>__('admin.status.active'),'inactive'=>__('admin.status.inactive')]" :value="old('status',$event->status)" />
    <x-admin.form.select name="event_type_id" label="Тип" :options="\App\Models\EventType::orderBy('name')->pluck('name','id')->toArray()" :value="old('event_type_id',$event->event_type_id)" placeholder="—" />
  </x-admin.form.section>
  <x-admin.form.section title="Дати и време">
    <x-admin.form.input type="date" name="start_date" label="Начална дата" :value="old('start_date', optional($event->start_date)->format('Y-m-d'))" />
    <x-admin.form.input type="date" name="end_date" label="Крайна дата" :value="old('end_date', optional($event->end_date)->format('Y-m-d'))" />
    <x-admin.form.input type="time" name="start_time" label="Начален час" :value="old('start_time',$event->start_time)" />
    <x-admin.form.input type="time" name="end_time" label="Краен час" :value="old('end_time',$event->end_time)" />
  </x-admin.form.section>
  <x-admin.form.section title="Локация">
    <x-admin.form.input name="location" label="Локация" :value="old('location',$event->location)" />
  </x-admin.form.section>
  <x-admin.form.section title="Изображения">
    @php $imgs = $event->images ?? []; @endphp
    @if(!empty($imgs))
      <div class="gallery-grid mb-2">
        @foreach($imgs as $img)
          <div class="draggable">
            <img src="{{ $img }}" style="width:100%;height:100%;object-fit:cover;" />
          </div>
        @endforeach
      </div>
    @else
      <div class="table-empty" style="padding:.75rem 0;">Няма изображения.</div>
    @endif
  <x-admin.form.file name="images" multiple placeholder="Добавяне на изображения" compact />
  </x-admin.form.section>
  <x-admin.form.section title="Описание">
    <x-admin.form.textarea name="description" rows="7" label="Описание" :error="$errors->first('description')" :value="old('description',$event->description)" />
  </x-admin.form.section>
      <div class="form-actions-sticky">
        <x-admin.button type="submit" variant="primary">Обнови</x-admin.button>
      </div>
    </x-form>
  </x-admin.card>
  @if($errors->any())<script>AdminTheme.toast('Поправете грешките във формата','error');</script>@endif
</div>
@endsection
