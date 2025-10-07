<table class="admin-table mb-0">
  <thead>
  <tr class="small text-uppercase fs-2xs ls-wide-2" data-table-sortable>
    <th><input type="checkbox" onclick="document.querySelectorAll('.user-row-checkbox').forEach(c=> c.checked=this.checked);" /></th>
  <th data-sort="id" class="sortable">ID <span class="sort-indicator"></span></th>
  <th data-sort="name" class="sortable">Име <span class="sort-indicator"></span></th>
  <th data-sort="email" class="sortable">Имейл <span class="sort-indicator"></span></th>
  <th data-sort="role" class="sortable">Роля <span class="sort-indicator"></span></th>
  <th data-sort="verified" class="sortable">Потвърден <span class="sort-indicator"></span></th>
  <th data-sort="created_at" class="sortable">Създаден <span class="sort-indicator"></span></th>
    <th></th>
    </tr>
  </thead>
  <tbody>
  @foreach($items as $u)
    <tr>
      <td><input type="checkbox" value="{{ $u->id }}" class="user-row-checkbox" /></td>
  <td class="text-muted tbl-id">{{ $u->id }}</td>
  <td class="tbl-title truncate" data-title="{{ $u->name }}">{{ $u->name }}</td>
  <td class="tbl-meta">{{ $u->email }}</td>
      <td>
  <select data-id="{{ $u->id }}" data-name="{{ $u->name }}" class="user-role-select select select-xs">
          <option value="" @selected(!$u->role)>Потребител</option>
          <option value="admin" @selected($u->role==='admin')>Админ</option>
        </select>
      </td>
  <td class="tbl-meta">@if($u->email_verified_at)<span class="text-success">Да</span>@else<span class="text-secondary opacity-50">Не</span>@endif</td>
  <td class="tbl-meta">{{ bg_date($u->created_at) }}</td>
      <td>
        <div class="tbl-actions">
  <x-admin.button :href="route('admin.users.edit',$u)" size="sm" variant="outline" icon="edit" title="Редакция"></x-admin.button>
  <form method="POST" action="{{ route('admin.users.destroy',$u) }}" data-confirm="{{ __('admin.confirm.user_delete') }}" class="d-inline" title="Изтриване">@csrf @method('DELETE') <x-admin.button size="sm" variant="danger" icon="trash"></x-admin.button></form>
        </div>
      </td>
      </td>
    </tr>
  @endforeach
  </tbody>
</table>
