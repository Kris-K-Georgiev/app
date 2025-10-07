@props([
  'action',
  'method' => 'POST',
  'files' => false,
  'class' => ''
])
@php
  $spoof = strtoupper($method) !== 'GET' && strtoupper($method) !== 'POST';
  $http = $spoof ? 'POST' : strtoupper($method);
@endphp
<form method="{{ $http }}" action="{{ $action }}" @if($files) enctype="multipart/form-data" @endif class="{{ $class }}">
  @csrf
  @if($spoof) @method($method) @endif
  {{ $slot }}
</form>