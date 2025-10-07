@props([
  'type' => 'button',
  'variant' => 'default',
  'size' => 'md',
  'href' => null,
  'icon' => null,
  'iconPosition' => 'left',
])
@php
  $base = 'btn';
  $variants = [ 'default'=>'', 'primary'=>'primary','outline'=>'outline','danger'=>'danger','ghost'=>'ghost','subtle'=>'subtle' ];
  $sizes = [ 'xs'=>'btn-xs','sm'=>'btn-sm','md'=>'' ];
  $variantClass = $variants[$variant] ?? $variants['default'];
  $sizeClass = $sizes[$size] ?? '';
  $isIconOnly = $icon && trim($slot) === '';
  $classes = trim($base.' '.$variantClass.' '.$sizeClass.($isIconOnly ? ' btn-icon' : ''));
  $iconHtml = $icon ? view('components.admin.icon',[ 'name'=>$icon, 'attributes'=>new Illuminate\View\ComponentAttributeBag(['class'=>'icon']) ])->render() : '';
@endphp
@php($content = $icon ? ($iconPosition==='right' ? trim($slot).' '.$iconHtml : $iconHtml.' '.trim($slot)) : $slot)
@if($href)
  <a href="{{ $href }}" {{ $attributes->merge(['class'=>$classes]) }}>{!! $content !!}</a>
@else
  <button type="{{ $type }}" {{ $attributes->merge(['class'=>$classes]) }}>{!! $content !!}</button>
@endif
