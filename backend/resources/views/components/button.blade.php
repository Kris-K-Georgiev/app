@props([
  'variant' => 'default', // default, primary, outline, destructive
  'size' => 'md', // xs, sm, md, lg
  'href' => null,
  'type' => 'button'
])
@php
  $base = 'inline-flex items-center justify-center rounded-md border font-medium transition focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none';
  $variants = [
    'default' => 'bg-white dark:bg-neutral-800 hover:bg-secondary dark:hover:bg-neutral-700 text-foreground border-border px-3 py-2 text-sm',
    'primary' => 'bg-primary text-primary-foreground hover:opacity-90 border-transparent px-3 py-2 text-sm',
    'outline' => 'bg-transparent text-foreground hover:bg-secondary dark:hover:bg-neutral-800 border-border px-3 py-2 text-sm',
    'destructive' => 'bg-destructive text-destructive-foreground hover:opacity-90 border-transparent px-3 py-2 text-sm'
  ];
  $sizes = [
    'xs'=>'text-xs px-2 py-1',
    'sm'=>'text-sm px-2.5 py-1.5',
    'md'=>'text-sm px-3 py-2',
    'lg'=>'text-base px-4 py-2.5'
  ];
  $classes = $base.' '.($variants[$variant] ?? $variants['default']).' '.($sizes[$size] ?? $sizes['md']);
@endphp
@if($href)
  <a href="{{ $href }}" {{ $attributes->merge(['class'=>$classes]) }}>{{ $slot }}</a>
@else
  <button type="{{ $type }}" {{ $attributes->merge(['class'=>$classes]) }}>{{ $slot }}</button>
@endif
