@props(['status'])
@php
  $statusKey = strtolower($status ?? '');
  // Filled variants ("запълнени" цветове)
  $map = [
    'active' => ['cls'=>'badge text-bg-success fw-semibold','label'=>'Активно'],
    'inactive' => ['cls'=>'badge text-bg-secondary fw-semibold','label'=>'Неактивно'],
    'published' => ['cls'=>'badge text-bg-primary fw-semibold','label'=>'Публикувана'],
    'draft' => ['cls'=>'badge text-bg-warning fw-semibold','label'=>'Чернова'],
    'cancelled' => ['cls'=>'badge text-bg-danger fw-semibold','label'=>'Отменено'],
  ];
  $entry = $map[$statusKey] ?? $map['draft'];
  $cls = $entry['cls'];
  $label = $entry['label'];
@endphp
<span class="{{ $cls }}" style="font-size:.55rem; letter-spacing:.05em; text-transform:uppercase;">{{ $label }}</span>
