import { renderLayout } from './shell/Layout.js'
import { routes } from './shell/routes.js'

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
    const ctx = { params, query, navigate: (p) => (window.location.hash = p) }
    const html = await route.component.render(ctx)
    app.innerHTML = renderLayout(html, route)
    queueMicrotask(() => route.component.afterRender?.(ctx))
  }
  window.addEventListener('hashchange', go)
  go()
}
