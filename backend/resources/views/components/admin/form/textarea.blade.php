@props(['name','rows'=>5,'value'=>null,'required'=>false,'placeholder'=>null,'error'=>null,'help'=>null,'label'=>null])
<x-admin.form.group :label="$label" :for="$name" :help="$help" :error="$error" :required="$required">
  <textarea id="{{ $name }}" name="{{ $name }}" rows="{{ $rows }}" @if($placeholder) placeholder="{{ $placeholder }}" @endif @if($required) required @endif class="form-control form-control-sm @if($error) is-invalid @endif">{{ old($name,$value) }}</textarea>
</x-admin.form.group>
