@props([
  'id',
  'title' => null,
  'confirmText' => 'Confirm',
  'cancelText' => 'Cancel',
])
<div id="{{ $id }}" class="admin-modal" style="display:none;">
  <div class="admin-modal-backdrop" data-modal-close></div>
  <div class="admin-modal-dialog">
    <div class="admin-modal-header d-flex justify-content-between align-items-center mb-2">
      <h6 class="mb-0 small text-uppercase fw-semibold" style="letter-spacing:.06em; font-size:.55rem;">{{ $title }}</h6>
      <button class="btn btn-sm ghost p-0" data-modal-close aria-label="Close" style="width:24px;height:24px;display:flex;align-items:center;justify-content:center;">×</button>
    </div>
    <div class="admin-modal-body mb-3 small" style="font-size:.65rem; line-height:1.3;">
      {{ $slot }}
    </div>
    <div class="admin-modal-footer d-flex justify-content-end gap-2">
      <x-admin.button size="sm" variant="outline" data-modal-close>{{ $cancelText }}</x-admin.button>
      <x-admin.button size="sm" variant="danger" data-modal-confirm>{{ $confirmText }}</x-admin.button>
    </div>
  </div>
</div>
