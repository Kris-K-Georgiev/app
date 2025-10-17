import { renderLayout } from './shell/Layout.js'
import { routes } from './shell/routes.js'
import { getAuth, isAdmin } from './state/auth.js'

function match(pathPattern, actualPath) {
  // Supports patterns like /news/:id
  const pp = pathPattern.split('/').filter(Boolean)
  const ap = actualPath.split('/').filter(Boolean)
  if (pp.length !== ap.length) return { ok: false }
  const params = {}
  for (let i = 0; i < pp.length; i++) {
    if (pp[i].startsWith(':')) {
      params[pp[i].slice(1)] = decodeURIComponent(ap[i])
    } else if (pp[i] !== ap[i]) {
      return { ok: false }
    }
  }
  return { ok: true, params }
}

function resolveRoute() {
  const hash = window.location.hash || '#/'
  const [path, query] = hash.slice(1).split('?')
  for (const r of routes) {
    const m = match(r.path, path)
    if (m.ok) {
      return { route: r, params: m.params, query: Object.fromEntries(new URLSearchParams(query)) }
    }
  }
  // default to first route
  return { route: routes[0], params: {}, query: Object.fromEntries(new URLSearchParams(query)) }
}

export function initRouter() {
  const app = document.getElementById('app')
  const go = async () => {
    const { route, params, query } = resolveRoute()
    // Guards
    const meta = route.meta || {}
    const auth = getAuth()
    if (meta.requiresAuth && !auth.user) {
      window.location.hash = '#/login'
      return
    }
    if (meta.requiresAdmin && !isAdmin()) {
      window.location.hash = '#/'
      return
    }
    const ctx = { params, query, navigate: (p) => (window.location.hash = p) }
    try {
      console.log('[router] navigating to', route.path, 'params=', params, 'query=', query)
      window.__debugLog && window.__debugLog('router', `navigating to ${route.path}`)
      const html = await route.component.render(ctx)
      console.log('[router] html length', html ? html.length : 0)
      window.__debugLog && window.__debugLog('router', `html length ${html ? html.length : 0}`)
      app.innerHTML = renderLayout(html, route)
      queueMicrotask(() => route.component.afterRender?.(ctx))
    } catch (err) {
      console.error('[router] render error for', route.path, err)
      window.__debugLog && window.__debugLog('router-error', (err && (err.stack || err.message)) || String(err))
      app.innerHTML = `<div class="p-8"><h2>Грешка при рендер</h2><pre>${(err && err.stack) || err}</pre></div>`
    }
  }
  window.addEventListener('hashchange', go)
  go()
}
