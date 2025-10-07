@props([
  'bulkBarId'=>null,
  'search'=>false,
  'filters'=>[], // array of [id=>['label'=>..., 'type'=>'select|date|text', 'options'=>[value=>label]]] 
  'resource'=>null,
  'selectedClass'=>'selected-row'
])
<div {{ $attributes->class('admin-table-wrapper') }}>
  <div class="d-flex flex-wrap gap-2 mb-3 align-items-end">
    <div class="me-auto d-flex flex-wrap gap-2 filter-bar">
      {{ $slot }}
    </div>
    <div class="d-flex gap-2" id="{{ $bulkBarId }}" style="display:none"></div>
  </div>
  <div class="table-responsive-wrapper"><div class="table-responsive">{{ $table }}</div></div>
  @if(isset($pagination))
    <div class="mt-3">{{ $pagination }}</div>
  @endif
</div>
