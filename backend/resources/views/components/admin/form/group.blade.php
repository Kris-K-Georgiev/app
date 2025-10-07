@props(['label'=>null,'for'=>null,'help'=>null,'error'=>null,'required'=>false])
<div {{ $attributes->merge(['class'=>'mb-3']) }}>
  @if($label)
    <label @if($for) for="{{ $for }}" @endif class="form-label">{{ $label }} @if($required)<span class="text-danger">*</span>@endif</label>
  @endif
  {{ $slot }}
  @if($help)<div class="form-text">{{ $help }}</div>@endif
  @if($error)<div class="invalid-feedback d-block small">{{ $error }}</div>@endif
</div>
