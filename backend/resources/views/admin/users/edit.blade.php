@extends('admin.layout')
@section('content')
<div class="col-12 col-xl-7 mx-auto">
  <x-admin.card :title="'Редакция на потребител #'.$user->id">
    <x-form :action="route('admin.users.update',$user)" method="PUT">
      <x-admin.form.section title="Основна информация">
        <x-admin.form.input name="name" label="Име" :value="old('name',$user->name)" :error="$errors->first('name')" required />
        <x-admin.form.input name="role" label="Роля" :value="old('role',$user->role)" :error="$errors->first('role')" help="Оставете празно за стандартна роля" />
      </x-admin.form.section>
      <div class="form-actions-sticky">
        <x-admin.button type="submit" variant="primary">{{ __('admin.actions.update') }}</x-admin.button>
        <a href="{{ route('admin.users.index') }}" class="btn btn-link ms-2">{{ __('admin.confirm.cancel') }}</a>
      </div>
    </x-form>
    @if($errors->any())<div class="toast-stack"><script>AdminTheme.toast('Поправете грешките във формата','error');</script></div>@endif
  </x-admin.card>
</div>
@endsection
