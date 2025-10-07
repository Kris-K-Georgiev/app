@extends('admin.layout')
@section('content')
<div class="col-12 col-xl-9 mx-auto">
  <x-admin.card title="Създаване на събитие">
    <x-form :action="route('admin.events.store')" method="POST" files>
  <x-admin.form.section title="Основна информация">
    <x-admin.form.input name="title" label="Заглавие" :error="$errors->first('title')" required />
  <x-admin.form.select name="status" label="Статус" :options="['active'=>__('admin.status.active'),'inactive'=>__('admin.status.inactive')]" :value="old('status','active')" />
    <x-admin.form.select name="event_type_id" label="Тип" :options="\App\Models\EventType::orderBy('name')->pluck('name','id')->toArray()" :value="old('event_type_id')" placeholder="—" />
  </x-admin.form.section>
  <x-admin.form.section title="Дати и време">
    <x-admin.form.input type="date" name="start_date" label="Начална дата" :value="old('start_date')" />
    <x-admin.form.input type="date" name="end_date" label="Крайна дата" :value="old('end_date')" />
    <x-admin.form.input type="time" name="start_time" label="Начален час" :value="old('start_time')" help="24ч" />
    <x-admin.form.input type="time" name="end_time" label="Краен час" :value="old('end_time')" help="24ч" />
  </x-admin.form.section>
  <x-admin.form.section title="Локация">
    <x-admin.form.input name="location" label="Локация" :value="old('location')" />
  </x-admin.form.section>
  <x-admin.form.section title="Изображения">
    <x-admin.form.file name="images" :error="$errors->first('images.*')" multiple placeholder="Добавете изображения" compact />
  </x-admin.form.section>
  <x-admin.form.section title="Описание">
    <x-admin.form.textarea name="description" rows="6" label="Описание" :error="$errors->first('description')" />
  </x-admin.form.section>
      <div class="form-actions-sticky">
        <x-admin.button type="submit" variant="primary">Запази</x-admin.button>
      </div>
    </x-form>
  </x-admin.card>
  @if($errors->any())<div class="toast-stack"><script>AdminTheme.toast('Поправете грешките във формата','error');</script></div>@endif
</div>
@endsection
