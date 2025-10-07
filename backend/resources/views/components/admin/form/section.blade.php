@props(['title'=>null,'description'=>null,'aside'=>null])
<div {{ $attributes->merge(['class'=>'form-section']) }}>
  @if($title || $description)
    <div class="form-section-head">
      @if($title)<h2 class="form-section-title">{{ $title }}</h2>@endif
      @if($description)<p class="form-section-desc">{{ $description }}</p>@endif
    </div>
  @endif
  <div class="form-section-body">
    {{ $slot }}
  </div>
  @if($aside)
    <div class="form-section-aside">{!! $aside !!}</div>
  @endif
</div>