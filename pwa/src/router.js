import { renderLayout } from './shell/Layout.js'
import { routes } from './shell/routes.js'

function resolveRoute() {
  const hash = window.location.hash || '#/'
  const [path, query] = hash.slice(1).split('?')
  const route = routes.find(r => r.path === path) || routes[0]
  return { route, query: Object.fromEntries(new URLSearchParams(query)) }
}

export function initRouter() {
  const app = document.getElementById('app')
  const go = async () => {
    const { route, query } = resolveRoute()
    const ctx = { query, navigate: (p) => (window.location.hash = p) }
    const html = await route.component.render(ctx)
    app.innerHTML = renderLayout(html, route)
    queueMicrotask(() => route.component.afterRender?.(ctx))
  }
  window.addEventListener('hashchange', go)
  go()
}
