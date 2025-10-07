<table class="admin-table mb-0">
  <thead>
  <tr class="small text-uppercase fs-2xs ls-wide-2" data-table-sortable>
    <th><input type="checkbox" onclick="document.querySelectorAll('.news-row-checkbox').forEach(c=> c.checked=this.checked); document.dispatchEvent(new Event('updateNewsBulk'));" /></th>
  <th data-sort="id" class="sortable">ID <span class="sort-indicator"></span></th>
  <th>Корица</th>
  <th data-sort="title" class="sortable">Заглавие <span class="sort-indicator"></span></th>
  <th>Изобр.</th>
  <th data-sort="status" class="sortable">Статус <span class="sort-indicator"></span></th>
  <th data-sort="author" class="sortable">Автор <span class="sort-indicator"></span></th>
  <th data-sort="created_at" class="sortable">Създадена <span class="sort-indicator"></span></th>
  <th>Действия</th>
    </tr>
  </thead>
  <tbody>
  @foreach($items as $n)
    <tr>
      <td><input type="checkbox" value="{{ $n->id }}" class="news-row-checkbox" /></td>
  <td class="text-muted tbl-id">{{ $n->id }}</td>
      <td>
        @if($n->cover)
          <img src="{{ asset('storage/'.$n->cover) }}" class="tbl-cover" style="max-width:48px; max-height:38px; object-fit:cover; border-radius:6px;" />
        @elseif($n->image)
          <img src="{{ asset('storage/'.$n->image) }}" class="tbl-cover" style="max-width:48px; max-height:38px; object-fit:cover; border-radius:6px;" />
        @else
          <span class="text-secondary opacity-50 fs-sm">–</span>
        @endif
      </td>
      <td style="max-width:260px;">
          <span class="tbl-title truncate" data-title="{{ $n->title }}">{{ $n->title }}</span>
      </td>
      <td>
        @if($n->images && $n->images->count())
          @php($cnt=$n->images->count())
          <span class="badge text-bg-secondary fw-semibold" style="font-size:.55rem; letter-spacing:.05em;">@choice('admin.media.images_count',$cnt,['count'=>$cnt])</span>
        @else
          <span class="text-secondary opacity-50">—</span>
        @endif
      </td>
      <td>
        <x-admin.status-badge :status="$n->status ?? 'draft'" />
      </td>
  <td class="tbl-meta">{{ $n->author?->name ?? '—' }}</td>
  <td class="tbl-meta">{{ bg_date($n->created_at) }}</td>
    <td>
      <div class="tbl-actions">
        <x-admin.button :href="route('admin.news.edit',$n)" size="sm" variant="outline" icon="edit" title="Редакция"></x-admin.button>
  <form method="POST" action="{{ route('admin.news.destroy',$n) }}" class="d-inline" data-confirm="{{ __('admin.confirm.news_delete') }}" title="Изтриване">@csrf @method('DELETE') <x-admin.button size="sm" variant="danger" icon="trash"></x-admin.button></form>
      </div>
    </td>
    </tr>
  @endforeach
  </tbody>
</table>
