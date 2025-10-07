@props([
  'variant' => 'info', // info, success, warning, error
  'dismissable' => false
])
@php
  $map = [
    'info' => 'border-sky-400/60 bg-sky-50 text-sky-800 dark:bg-sky-900/40 dark:text-sky-200 dark:border-sky-700/60',
    'success' => 'border-emerald-400/60 bg-emerald-50 text-emerald-800 dark:bg-emerald-900/40 dark:text-emerald-200 dark:border-emerald-700/60',
    'warning' => 'border-amber-400/60 bg-amber-50 text-amber-800 dark:bg-amber-900/40 dark:text-amber-200 dark:border-amber-700/60',
    'error' => 'border-red-400/60 bg-red-50 text-red-800 dark:bg-red-900/40 dark:text-red-200 dark:border-red-700/60'
  ];
  $classes = 'rounded-md border px-4 py-2 text-sm '.$map[$variant];
@endphp
<div {{ $attributes->merge(['class'=>$classes]) }}>
  <div class="flex items-start gap-2">
    <div class="flex-1">{{ $slot }}</div>
    @if($dismissable)
      <button type="button" class="ml-2 text-xs opacity-60 hover:opacity-100" onclick="this.closest('[data-alert]').remove()">✕</button>
    @endif
  </div>
</div>
