@props(['title'=>null,'actions'=>null,'padding'=>true])
<div {{ $attributes->class(['card fade-in']) }}>
  @if($title || $actions)
    <div class="d-flex align-items-center mb-2 gap-2">
      @if($title)
        <h3 class="m-0 small text-uppercase fw-semibold" style="font-size:.7rem; letter-spacing:.07em; opacity:.7;">{{ $title }}</h3>
      @endif
      <div class="ms-auto d-flex align-items-center gap-2">{!! $actions !!}</div>
    </div>
  @endif
  <div @class([ $padding? '' : 'p-0'])>
    {{ $slot }}
  </div>
</div>
