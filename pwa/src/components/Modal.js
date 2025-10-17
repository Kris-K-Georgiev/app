export function showModal({ title = '', content = '', size = 'md' } = {}) {
  const overlay = document.createElement('div')
  overlay.className = 'fixed inset-0 z-50 flex items-center justify-center'
  overlay.innerHTML = `
    <div class="absolute inset-0 bg-black/50 opacity-0 animate-[fadeIn_.2s_ease_forwards]" data-close="1"></div>
    <div class="relative w-full ${size==='lg'?'max-w-3xl':'max-w-xl'} mx-4" role="dialog" aria-modal="true" aria-labelledby="modal-title">
      <div class="card overflow-hidden opacity-0 animate-[popIn_.2s_ease_forwards]">
        <div class="flex items-center justify-between px-4 py-3 border-b border-black/5 dark:border-white/10">
          <h3 id="modal-title" class="font-semibold">${title}</h3>
          <button class="btn-ghost" data-close="1" aria-label="Close">✕</button>
        </div>
        <div class="p-4" id="modal-content">${content}</div>
      </div>
    </div>
  `
  const close = () => overlay.remove()
  overlay.addEventListener('click', (e)=>{ if (e.target.closest('[data-close]')) close() })
  // focus trap: focus first focusable element
  setTimeout(()=>{
    const focusable = overlay.querySelector('button, [href], input, textarea, select, [tabindex]:not([tabindex="-1"])')
    focusable?.focus()
  }, 30)
  document.body.appendChild(overlay)
  return { close, el: overlay }
}

export function alertModal(title, message){
  const { close, el } = showModal({ title, content: `<div class='space-y-4'>${message}<div class='flex justify-end'><button class='btn' id='modal-ok'>OK</button></div></div>` })
  el.querySelector('#modal-ok')?.addEventListener('click', close)
  return { close }
}

// modal animations keyframes via CSS-in-JS injection (once)
if (!document.getElementById('modal-anim')){
  const style = document.createElement('style')
  style.id = 'modal-anim'
  style.textContent = `@keyframes fadeIn{to{opacity:1}}@keyframes popIn{from{transform:translateY(6px);opacity:0}to{transform:translateY(0);opacity:1}}`
  document.head.appendChild(style)
}