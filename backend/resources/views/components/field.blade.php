@props([
  'label' => null,
  'for' => null,
  'help' => null,
  'error' => null
])
<div {{ $attributes->merge(['class'=>'space-y-1']) }}>
  @if($label)
    <label @if($for) for="{{ $for }}" @endif class="text-sm font-medium">{{ $label }}</label>
  @endif
  {{ $slot }}
  @if($help)
    <p class="text-xs text-muted-foreground">{{ $help }}</p>
  @endif
  @if($error)
    <p class="text-xs text-destructive">{{ $error }}</p>
  @endif
</div>