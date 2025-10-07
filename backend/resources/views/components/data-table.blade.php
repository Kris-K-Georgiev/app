@props([
  'title' => null,
  'description' => null,
  'id' => 'dt-' . uniqid(),
  'refreshInterval' => 0,
])
<div {{ $attributes->merge(['class'=>'rounded-lg border shadow-card bg-white dark:bg-neutral-900']) }} x-data="{ lastUpdated: null }" x-init="lastUpdated = new Date()">
  <div class="p-4 border-b flex flex-col sm:flex-row sm:items-center gap-3">
    <div class="flex-1 min-w-0">
      @if($title)<h2 class="text-lg font-semibold leading-tight">{{ $title }}</h2>@endif
      @if($description)<p class="text-xs text-muted-foreground mt-0.5">{{ $description }}</p>@endif
    </div>
    <div class="flex items-center gap-2" id="{{ $id }}-actions">
      {{ $actions ?? '' }}
      <button type="button" class="inline-flex items-center rounded-md border px-3 py-1.5 text-xs font-medium bg-white dark:bg-neutral-800 hover:bg-secondary dark:hover:bg-neutral-700 transition" data-refresh>Refresh</button>
    </div>
  </div>
  @if(isset($filters))
    <div class="p-3 border-b bg-muted/40 flex flex-wrap gap-3 items-end" id="{{ $id }}-filters">
      {{ $filters }}
    </div>
  @endif
  <div id="{{ $id }}-wrapper" class="overflow-x-auto">
    {{ $slot }}
  </div>
  <div id="{{ $id }}-pagination" class="p-3 border-t">
    {{ $pagination ?? '' }}
  </div>
</div>
