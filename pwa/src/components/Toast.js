let toastRoot
export function _ensureRoot(){
  if (!toastRoot){
    toastRoot = document.createElement('div')
    toastRoot.style.cssText = 'position:fixed;right:12px;bottom:12px;z-index:99999;display:flex;flex-direction:column;gap:8px;max-width:360px'
    document.body.appendChild(toastRoot)
  }
  return toastRoot
}

export function toast(message, { duration = 4000 } = {}){
  const root = _ensureRoot()
  const el = document.createElement('div')
  el.className = 'card p-3 shadow-sm'
  el.style.opacity = '0'
  el.innerHTML = `<div class="text-sm">${message}</div>`
  root.appendChild(el)
  requestAnimationFrame(()=> el.style.opacity = '1')
  const t = setTimeout(()=>{ el.style.opacity = '0'; setTimeout(()=> el.remove(), 300) }, duration)
  el.addEventListener('click', ()=>{ clearTimeout(t); el.remove() })
  return { close: ()=> el.remove() }
}
