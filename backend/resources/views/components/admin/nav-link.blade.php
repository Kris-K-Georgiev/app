@props(['href' => '#','active'=>false])
@php
  $path = ltrim(parse_url($href, PHP_URL_PATH) ?? '', '/');
  $isDashboard = ($path === 'admin' || $path === 'admin/');
  $isActive = $active
    || request()->fullUrlIs($href)
    || request()->url() === $href
    || (!$isDashboard && $path !== '' && request()->is($path.'*'))
    || ($isDashboard && trim(request()->path(),'/') === 'admin');
@endphp
<a href="{{ $href }}" {{ $attributes->class(['nav-link','active'=>$isActive]) }}>
  {{ $slot }}
</a>
