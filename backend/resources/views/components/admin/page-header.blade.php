@props(['title','subtitle'=>null])
<div {{ $attributes->merge(['class'=>'page-header mb-4']) }}>
  <div class="ph-main">
    <h1 class="ph-title m-0">{{ $title }}</h1>
    @if($subtitle)<p class="ph-sub m-0">{{ $subtitle }}</p>@endif
  </div>
  @isset($actions)
    @if(trim($actions) !== '')
      <div class="ph-actions">{!! $actions !!}</div>
    @endif
  @endisset
</div>
