@extends('admin.layout')
@section('content')
<div class="mx-auto w-full max-w-sm space-y-6">
  <div class="text-center space-y-1">
    <h1 class="text-xl font-semibold tracking-tight">Admin Login</h1>
    <p class="text-sm text-muted-foreground">Enter your credentials to access the panel.</p>
  </div>
  <form method="POST" action="{{ route('admin.login.submit') }}" class="space-y-4">@csrf
    <div class="space-y-2">
      <label class="text-sm font-medium" for="email">Email</label>
      <input id="email" type="email" name="email" required class="w-full rounded-md border px-3 py-2 bg-white dark:bg-neutral-900" />
    </div>
    <div class="space-y-2">
      <label class="text-sm font-medium" for="password">Password</label>
      <input id="password" type="password" name="password" required class="w-full rounded-md border px-3 py-2 bg-white dark:bg-neutral-900" />
    </div>
    <label class="flex items-center gap-2 text-sm"><input type="checkbox" name="remember" class="rounded" /> Remember</label>
    @error('email')<div class="text-sm text-destructive">{{ $message }}</div>@enderror
    <button class="w-full inline-flex items-center justify-center rounded-md border px-3 py-2 text-sm font-medium bg-primary text-primary-foreground hover:opacity-90 transition">Login</button>
  </form>
</div>
@endsection