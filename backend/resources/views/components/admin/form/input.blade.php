@props([
  'name', 'type' => 'text', 'value' => null, 'required' => false, 'placeholder'=>null,
  'error'=>null, 'help'=>null, 'label'=>null
])
<div class="mb-3">
  @if($label)
    <label for="{{ $name }}" class="form-label text-uppercase small fw-semibold mb-1">{{ $label }} @if($required)<span class="text-danger">*</span>@endif</label>
  @endif
  <input id="{{ $name }}" name="{{ $name }}" type="{{ $type }}" @if($placeholder) placeholder="{{ $placeholder }}" @endif value="{{ old($name,$value) }}" @if($required) required @endif class="form-control form-control-sm @if($error) is-invalid @endif" />
  @if($help)<div class="form-text">{{ $help }}</div>@endif
  @if($error)<div class="invalid-feedback d-block small">{{ $error }}</div>@endif
</div>
