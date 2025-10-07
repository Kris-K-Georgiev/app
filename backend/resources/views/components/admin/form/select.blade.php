@props([
  'name','options'=>[], 'value'=>null, 'required'=>false, 'placeholder'=>null,
  'error'=>null,'help'=>null,'label'=>null
])
<div class="mb-3">
  @if($label)
    <label for="{{ $name }}" class="form-label text-uppercase small fw-semibold mb-1">{{ $label }} @if($required)<span class="text-danger">*</span>@endif</label>
  @endif
  <select id="{{ $name }}" name="{{ $name }}" class="form-select form-select-sm @if($error) is-invalid @endif" @if($required) required @endif>
    @if($placeholder)<option value="">{{ $placeholder }}</option>@endif
    @foreach($options as $k=>$v)
      <option value="{{ $k }}" {{ (string)old($name,$value)===(string)$k ? 'selected':'' }}>{{ $v }}</option>
    @endforeach
  </select>
  @if($help)<div class="form-text">{{ $help }}</div>@endif
  @if($error)<div class="invalid-feedback d-block small">{{ $error }}</div>@endif
</div>
