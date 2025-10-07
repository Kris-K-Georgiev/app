@extends('admin.layout')
@section('content')
<x-admin.page-header :title="'Версия #'.$version->id" subtitle="Редакция" />
<div class="max-w-xl">
  <x-admin.card title="Редакция на версията">
    <x-form :action="route('admin.versions.update',$version)" method="PUT">
      <x-admin.form.section title="Основни полета">
        <x-admin.form.input name="version_code" type="number" label="Код версия" :value="old('version_code',$version->version_code)" required />
        <x-admin.form.input name="version_name" label="Име версия" :value="old('version_name',$version->version_name)" required />
        <x-admin.form.input name="download_url" label="URL за изтегляне" :value="old('download_url',$version->download_url)" />
        <x-admin.form.group label="Задължителна актуализация?">
          <div class="form-check form-switch">
            <input class="form-check-input" type="checkbox" id="isMandatory" name="is_mandatory" value="1" {{ old('is_mandatory',$version->is_mandatory)?'checked':'' }}>
            <label class="form-check-label small" for="isMandatory">Потребителите трябва да обновят</label>
          </div>
        </x-admin.form.group>
        <x-admin.form.textarea name="release_notes" rows="6" label="Бележки" :value="old('release_notes',$version->release_notes)" />
      </x-admin.form.section>
      <div class="form-actions-sticky">
        <x-admin.button type="submit" variant="primary" icon="save">Обнови</x-admin.button>
      </div>
    </x-form>
  </x-admin.card>
</div>
@endsection
