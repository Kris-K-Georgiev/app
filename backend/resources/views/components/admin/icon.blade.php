@php($icons = config('icons'))
@php($name = trim($name, '"\''))
@php($paths = $icons[$name] ?? '')
<svg {{ $attributes->merge(['xmlns'=>'http://www.w3.org/2000/svg','viewBox'=>'0 0 24 24','fill'=>'none','stroke'=>'currentColor','stroke-width'=>'2','stroke-linecap'=>'round','stroke-linejoin'=>'round','width'=>'16','height'=>'16','aria-hidden'=>'true']) }}>{!! $paths !!}</svg>
