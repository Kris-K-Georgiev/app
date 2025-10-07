@extends('admin.layout')
@section('content')
<x-admin.page-header title="Нова версия" subtitle="Добавяне на публикувана версия" />
<div class="max-w-xl">
  <x-admin.card title="Данни за версията">
    <x-form :action="route('admin.versions.store')" method="POST">
      <x-admin.form.section title="Основна информация">
        <x-admin.form.input name="version_code" type="number" label="Код версия" :error="$errors->first('version_code')" required />
        <x-admin.form.input name="version_name" label="Име версия" :error="$errors->first('version_name')" required />
        <x-admin.form.input name="download_url" label="URL за изтегляне" :error="$errors->first('download_url')" />
        <x-admin.form.group label="Задължителна актуализация?">
          <div class="form-check form-switch">
            <input class="form-check-input" type="checkbox" id="isMandatory" name="is_mandatory" value="1">
            <label class="form-check-label small" for="isMandatory">Потребителите трябва да обновят</label>
          </div>
        </x-admin.form.group>
        <x-admin.form.textarea name="release_notes" rows="6" label="Бележки" :value="old('release_notes')" />
      </x-admin.form.section>
      <div class="form-actions-sticky">
        <x-admin.button type="submit" variant="primary" icon="save">Запази</x-admin.button>
      </div>
    </x-form>
  </x-admin.card>
</div>
@endsection
