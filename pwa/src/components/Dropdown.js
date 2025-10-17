export function openDropdown(anchor, html, { align = 'end' } = {}) {
  const rect = anchor.getBoundingClientRect()
  const menu = document.createElement('div')
    menu.className = 'fixed z-50'
    const top = rect.bottom + window.scrollY + 6
    const viewportW = document.documentElement.clientWidth
    const approxWidth = 220
    let left = align === 'start' ? rect.left + window.scrollX : rect.right + window.scrollX - approxWidth
    if (left + approxWidth > viewportW) left = Math.max(6, viewportW - approxWidth - 6)
    menu.style.top = `${top}px`
    menu.style.left = `${left}px`
    menu.innerHTML = `
      <div class="card w-[220px] p-1 shadow-lg" role="menu">
        ${html}
      </div>
    `
  const close = () => { document.removeEventListener('click', onDoc); window.removeEventListener('scroll', close, true); window.removeEventListener('resize', close); menu.remove() }
  const onDoc = (e) => { if (!menu.contains(e.target) && e.target !== anchor) close() }
  setTimeout(()=> document.addEventListener('click', onDoc), 0)
  window.addEventListener('scroll', close, true)
  window.addEventListener('resize', close)
    // close on ESC
    const onKey = (ev)=>{ if (ev.key === 'Escape') close() }
    document.addEventListener('keydown', onKey)
    const oldClose = close
    const newClose = ()=>{ document.removeEventListener('keydown', onKey); oldClose() }
  document.body.appendChild(menu)
    return { close: newClose, el: menu }
}