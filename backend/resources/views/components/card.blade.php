@props([
  'padding' => 'p-4',
  'title' => null,
  'subtitle' => null
])
<div {{ $attributes->merge(['class'=>'rounded-lg border shadow-card bg-white dark:bg-neutral-900 '.$padding]) }}>
  @if($title || $subtitle)
    <div class="space-y-1 mb-3">
      @if($title)<h2 class="text-lg font-medium tracking-tight">{{ $title }}</h2>@endif
      @if($subtitle)<p class="text-sm text-muted-foreground">{{ $subtitle }}</p>@endif
    </div>
  @endif
  {{ $slot }}
</div>
