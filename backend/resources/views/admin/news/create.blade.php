@extends('admin.layout')
@section('content')
<div class="col-12 col-xl-8 mx-auto">
  <x-admin.card title="Създаване на новина">
    <x-form :action="route('admin.news.store')" method="POST" files>
  <x-admin.form.section title="Основна информация">
    <x-admin.form.input name="title" label="Заглавие" :error="$errors->first('title')" required />
  <x-admin.form.select name="status" label="Статус" :options="['published'=>__('admin.status.published'),'draft'=>__('admin.status.draft')]" :value="old('status','published')" />
  </x-admin.form.section>
  <x-admin.form.section title="Изображения">
    <x-admin.form.file name="image" :error="$errors->first('image')" placeholder="Изберете основно изображение" compact />
    <x-admin.form.file name="images" :error="$errors->first('images.*')" multiple help="Можете да изберете няколко файла." placeholder="Добавете изображения към галерията" compact />
  </x-admin.form.section>
  <x-admin.form.section title="Съдържание">
    <x-admin.form.textarea name="content" rows="7" label="Съдържание" :error="$errors->first('content')" />
  </x-admin.form.section>
      <div class="form-actions-sticky">
        <x-admin.button type="submit" variant="primary">Запази</x-admin.button>
      </div>
    </x-form>
  </x-admin.card>
  @if($errors->any())<script>AdminTheme.toast('Поправете грешките във формата','error');</script>@endif
</div>
@endsection
