<table class="admin-table mb-0">
  <thead>
  <tr class="small text-uppercase fs-2xs ls-wide-2" data-table-sortable>
    <th><input type="checkbox" onclick="document.querySelectorAll('.events-row-checkbox').forEach(c=> c.checked=this.checked); document.dispatchEvent(new Event('updateEventsBulk'));" /></th>
  <th data-sort="id" class="sortable">ID <span class="sort-indicator"></span></th>
  <th>Корица</th>
  <th data-sort="title" class="sortable">Заглавие <span class="sort-indicator"></span></th>
  <th data-sort="start_date" class="sortable">Дата <span class="sort-indicator"></span></th>
  <th data-sort="status" class="sortable">Статус <span class="sort-indicator"></span></th>
  <th data-sort="type" class="sortable">Тип <span class="sort-indicator"></span></th>
  <th data-sort="author" class="sortable">Автор <span class="sort-indicator"></span></th>
  <th data-sort="registrations" class="sortable">Регистрации <span class="sort-indicator"></span></th>
  <th>Действия</th>
    </tr>
  </thead>
  <tbody>
  @forelse($items as $e)
    <tr>
      <td><input type="checkbox" value="{{ $e->id }}" class="events-row-checkbox" /></td>
  <td class="text-muted tbl-id">{{ $e->id }}</td>
  <td>
        @if($e->cover)
          <img src="{{ $e->cover }}" class="tbl-cover" />
        @else
          <span class="text-secondary opacity-50 fs-sm">–</span>
        @endif
      </td>
      <td style="max-width:220px;">
        <div class="d-flex flex-column gap-1">
          <span class="tbl-title truncate" data-title="{{ $e->title }}">{{ $e->title }}</span>
          <span class="text-secondary tbl-dim">ID: {{ $e->id }}</span>
        </div>
      </td>
  <td class="tbl-meta">
    @php($start=$e->start_date ? bg_date($e->start_date) : null)
    @php($end=$e->end_date ? bg_date($e->end_date) : null)
    @if($start && $end && $start !== $end)
      {{ $start }} – {{ $end }}
    @elseif($start)
      {{ $start }}
    @else
      —
    @endif
  </td>
      <td>
        <x-admin.status-badge :status="$e->status ?? 'active'" />
      </td>
  <td class="tbl-meta">{{ $e->type?->name ?? '—' }}</td>
  <td class="tbl-meta">{{ $e->author?->name ?? '—' }}</td>
  <td class="tbl-meta">
        <span class="{{ $e->registrations_count ? 'fw-semibold' : 'text-secondary' }}">
          {{ $e->registrations_count ?: 0 }}@if($e->limit)/{{ $e->limit }}@endif
        </span>
      </td>
      <td>
        <div class="tbl-actions">
          <x-admin.button :href="route('admin.events.edit',$e)" size="sm" variant="outline" icon="edit" title="Редакция"></x-admin.button>
          <form method="POST" action="{{ route('admin.events.destroy',$e) }}" data-confirm="{{ __('admin.confirm.event_delete') }}" class="d-inline" title="Изтриване">@csrf @method('DELETE') <x-admin.button size="sm" variant="danger" icon="trash"></x-admin.button></form>
        </div>
      </td>
    </tr>
  @empty
  <tr><td colspan="10" class="table-empty">Няма събития.</td></tr>
  @endforelse
  </tbody>
</table>
