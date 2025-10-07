@extends('admin.layout')
@section('content')
<div class="max-w-2xl space-y-6">
  <div>
    <h1 class="text-2xl font-semibold tracking-tight">Профил: #{{ $user->id }}</h1>
    <p class="text-sm text-slate-500 dark:text-slate-400">Редакция на данни и роля.</p>
  </div>
  <x-form :action="route('admin.users.profile.update',$user)" method="POST" files class="space-y-6">
    @method('PUT')
    <div class="flex items-start gap-6">
      <div>
        <div class="w-28 h-28 rounded-full overflow-hidden border bg-white dark:bg-neutral-800 flex items-center justify-center">
          @if($user->avatar_path)
            <img src="{{ $user->avatar_path }}" class="object-cover w-full h-full" />
          @else
            <span class="text-xs text-slate-400">Няма</span>
          @endif
        </div>
        <label class="block mt-3 text-sm font-medium">Аватар
          <input type="file" name="avatar" class="mt-1 block w-full text-xs" />
        </label>
      </div>
      <div class="flex-1 grid gap-4 sm:grid-cols-2">
        <x-field label="Име" :error="$errors->first('name')">
          <input name="name" value="{{ old('name',$user->name) }}" required class="w-full rounded-md border px-3 py-2 bg-white dark:bg-neutral-900" />
        </x-field>
        <x-field label="Никнейм" :error="$errors->first('nickname')">
          <input name="nickname" value="{{ old('nickname',$user->nickname) }}" class="w-full rounded-md border px-3 py-2 bg-white dark:bg-neutral-900" />
        </x-field>
        <x-field label="Град" :error="$errors->first('city')">
          <select name="city" class="w-full rounded-md border px-3 py-2 bg-white dark:bg-neutral-900">
            <option value="">--</option>
            @foreach($cities as $c)
              <option value="{{ $c }}" @selected(old('city',$user->city)===$c)>{{ $c }}</option>
            @endforeach
          </select>
        </x-field>
        <x-field label="Роля" :error="$errors->first('role')">
          <select name="role" class="w-full rounded-md border px-3 py-2 bg-white dark:bg-neutral-900">
            @foreach($roles as $slug=>$label)
              <option value="{{ $slug }}" @selected(old('role',$user->role)===$slug)>{{ $label }}</option>
            @endforeach
          </select>
        </x-field>
      </div>
    </div>
    <div>
      <x-button variant="primary" type="submit">Запази</x-button>
      <a href="{{ route('admin.users.index') }}" class="ml-3 text-sm text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-200">Назад</a>
    </div>
  </x-form>
  @if(session('ok')) <x-alert variant="success">{{ session('ok') }}</x-alert> @endif
  @if($errors->any()) <x-alert variant="error">Моля коригирай грешките.</x-alert> @endif
</div>
@endsection
