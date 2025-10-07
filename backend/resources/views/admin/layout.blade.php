<!DOCTYPE html>
<html lang="bg" data-theme="light">
<head>
  <meta charset="UTF-8" />
  <meta name="csrf-token" content="{{ csrf_token() }}" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Админ - BHSS</title>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  {{-- Bootstrap CSS (added for filters/forms/dropdowns) --}}
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
  {{-- Removed lucide CDN; using inline icons via @icon or <x-admin.icon /> --}}
  @vite(['resources/css/admin.css','resources/js/admin.js'])
  <style>body{opacity:0;transition:opacity .15s ease;}body.ready{opacity:1;}</style>
</head>
<body class="sneat-admin">
  <div class="admin-shell">
    <aside class="admin-sidebar" style="padding-top:.25rem;">
      <div class="px-3 py-2 d-flex align-items-center gap-2 border-bottom brand-bar" style="min-height:46px;">
  <span class="fw-semibold" style="font-size:1rem; letter-spacing:.04em; font-weight:700;">BHSS Админ</span>
      </div>
  <nav class="admin-nav py-2" style="--sidebar-gap:.35rem;">
    <div class="nav-section">Основно</div>
  <x-admin.nav-link :href="route('admin.dashboard')">Табло</x-admin.nav-link>
  <x-admin.nav-link :href="route('admin.news.index')">Новини</x-admin.nav-link>
  <x-admin.nav-link :href="route('admin.events.index')">Събития</x-admin.nav-link>
  <x-admin.nav-link :href="route('admin.users.index')">Потребители</x-admin.nav-link>
    <div class="nav-section">Система</div>
        @if(Route::has('admin.versions.index'))
          <x-admin.nav-link :href="route('admin.versions.index')">Версии</x-admin.nav-link>
        @endif
      </nav>
      <div class="sidebar-footer small">© {{ date('Y') }} BHSS</div>
    </aside>
    <div class="admin-content-wrapper">
  <header class="admin-topbar gap-2" style="padding:.35rem .75rem; min-height:50px;">
        <div class="ms-auto d-flex align-items-center gap-2" id="profileMenuRoot">
          <button class="btn btn-sm btn-outline-secondary" data-toggle="theme" aria-label="Смяна на тема" title="Смяна на тема">🌓</button>
          @php($authUser = auth()->user())
          @if($authUser)
            <div class="dropdown">
              <button class="btn btn-sm btn-light d-flex align-items-center gap-2 dropdown-toggle px-2" type="button" id="profileDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                <span class="profile-avatar" style="width:28px;height:28px;display:inline-flex;align-items:center;justify-content:center;border-radius:50%;background:var(--color-border-soft,#e5e7eb);font-weight:600;font-size:.75rem;">{{ mb_substr($authUser->name,0,1) }}</span>
                <span class="d-none d-md-inline" style="font-size:.7rem; font-weight:500; letter-spacing:.03em;">{{ $authUser->name }}</span>
              </button>
              <ul class="dropdown-menu dropdown-menu-end shadow-sm small" aria-labelledby="profileDropdown" style="min-width:180px;">
                <li><a class="dropdown-item d-flex align-items-center gap-2" href="{{ route('admin.users.profile', $authUser) }}">👤 <span>{{ __('admin.profile') }}</span></a></li>
                <li><hr class="dropdown-divider"></li>
                <li>
                  <form method="POST" action="{{ route('admin.logout') }}" class="m-0 p-0">@csrf
                    <button type="submit" class="dropdown-item text-danger d-flex align-items-center gap-2">⏻ <span>{{ __('admin.logout') }}</span></button>
                  </form>
                </li>
              </ul>
            </div>
          @else
            <a href="{{ route('admin.login') }}" class="btn btn-sm btn-primary">Вход</a>
          @endif
        </div>
      </header>
  <main class="admin-main sneat-content">
        @if(session('ok'))
          <script>window.addEventListener('DOMContentLoaded',()=> AdminTheme.toast(@json(session('ok')),'success'));</script>
        @endif
        @yield('content')
      </main>
    </div>
  </div>
  <div class="toast-stack"></div>
  <!-- Unified Confirm Modal -->
  <div class="modal fade" id="confirmModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
      <div class="modal-content">
        <div class="modal-header py-2">
          <h6 class="modal-title mb-0" style="font-size:.85rem; letter-spacing:.04em;">{{ __('admin.confirm.title') }}</h6>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body py-3">
          <p id="confirmModalMessage" class="m-0 small"></p>
        </div>
        <div class="modal-footer py-2 gap-2">
          <button type="button" class="btn btn-sm btn-outline-secondary" data-bs-dismiss="modal">{{ __('admin.confirm.cancel') }}</button>
          <button type="button" class="btn btn-sm btn-danger" id="confirmModalOk">{{ __('admin.confirm.delete') }}</button>
        </div>
      </div>
    </div>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
  <script>document.addEventListener('DOMContentLoaded',()=> { document.body.classList.add('ready');
    // Unified delete confirm
    const modalEl=document.getElementById('confirmModal');
    const msgEl=document.getElementById('confirmModalMessage');
    const okBtn=document.getElementById('confirmModalOk');
    let targetForm=null; let bsModal=null;
    function ensure(){ if(!bsModal) bsModal=new bootstrap.Modal(modalEl); }
    document.addEventListener('submit', e=>{
      const f=e.target;
      if(f.matches('form[data-confirm]')){
        e.preventDefault();
        const text=f.getAttribute('data-confirm') || '{{ __('admin.confirm.default') }}';
        msgEl.textContent=text; targetForm=f; ensure(); bsModal.show();
      }
    });
    okBtn.addEventListener('click', ()=>{ if(targetForm){ targetForm.submit(); targetForm=null; } });
  });</script>
</body>
</html>
