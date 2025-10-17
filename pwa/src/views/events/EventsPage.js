import dayjs from 'dayjs'
import { listEvents, saveRegistration, hasRegistration, getEvent } from '../../data/store.js'
import { showModal } from '../../components/Modal.js'
import { getAuth } from '../../state/auth.js'

export const EventsPage = {
  async render(){
  const raw = await listEvents()
    // Filters
    const params = new URLSearchParams(location.hash.split('?')[1]||'')
    const city = params.get('city')||'all'
    const status = params.get('status')||'all' // all|active|inactive|ongoing
    const currentDay = params.get('day')||dayjs().format('YYYY-MM-DD')
    const cities = ['all','София','Варна','В. Търново','Пловдив','Общи']
    const filtered = raw.filter(e=> (city==='all'||e.city===city) && (status==='all'|| (status==='active'? e.active : status==='inactive'? !e.active : dayjs().isSame(dayjs(e.date), 'day')) ))

    // Build month view for current date
    const ref = dayjs(currentDay)
    const start = ref.startOf('month').startOf('week')
    const end = ref.endOf('month').endOf('week')
    const days = []
    for (let d = start; d.isBefore(end) || d.isSame(end,'day'); d = d.add(1,'day')) days.push(d)
    const byDay = filtered.reduce((acc,e)=>{ const d=dayjs(e.date).format('YYYY-MM-DD'); (acc[d]=acc[d]||[]).push(e); return acc },{})

    return `
  <section class="w-full grid gap-4 sm:gap-6 grid-cols-1 lg:grid-cols-[20rem_1fr] xl:grid-cols-[22rem_1fr] reveal">
        <div class="space-y-3 sm:space-y-4">
          <div class="card p-3 sm:p-4 space-y-3">
            <div class="flex flex-col sm:flex-row gap-2">
              <select id="filter-city" class="input text-sm" aria-label="Филтрирай по град">
                ${cities.map(c=>`<option value="${c}" ${c===city?'selected':''}>${c==='all'?'Всички градове':c}</option>`).join('')}
              </select>
              <select id="filter-status" class="input text-sm" aria-label="Филтрирай по статус">
                <option value="all" ${status==='all'?'selected':''}>Всички</option>
                <option value="active" ${status==='active'?'selected':''}>Активни</option>
                <option value="inactive" ${status==='inactive'?'selected':''}>Неактивни</option>
                <option value="ongoing" ${status==='ongoing'?'selected':''}>В момента</option>
              </select>
            </div>
          </div>
          <div class="card p-3 sm:p-4">
            <div class="flex items-center justify-between mb-3">
              <div class="font-semibold text-sm sm:text-base">${ref.format('MMMM YYYY')}</div>
              <div class="flex gap-1 sm:gap-2">
                <button id="prev" class="btn-ghost ripple-container text-lg sm:text-xl px-2 py-1" aria-label="Минал месец">‹</button>
                <button id="today" class="btn-ghost ripple-container text-xs sm:text-sm px-2 py-1" aria-label="Днес">Днес</button>
                <button id="next" class="btn-ghost ripple-container text-lg sm:text-xl px-2 py-1" aria-label="Следващ месец">›</button>
              </div>
            </div>
            <div class="grid grid-cols-7 gap-0.5 sm:gap-1 text-[10px] sm:text-xs opacity-70 mb-1 sm:mb-2">
              ${['Пн','Вт','Ср','Чт','Пт','Сб','Нд'].map(w=>`<div class='text-center'>${w}</div>`).join('')}
            </div>
            <div class="grid grid-cols-7 gap-0.5 sm:gap-1">
              ${days.map(d=>{
                const key = d.format('YYYY-MM-DD')
                const items = byDay[key]||[]
                const isCur = key===currentDay
                const inMonth = d.month()===ref.month()
                return `<button data-day="${key}" class="rounded p-1 text-left h-12 sm:h-14 md:h-16 text-xs sm:text-sm ${isCur?'bg-primary/10 ring-1 ring-primary':''} ${inMonth?'':'opacity-40'}">
                  <div>${d.date()}</div>
                  <div class="flex gap-0.5 sm:gap-1 mt-1 flex-wrap">${items.slice(0,3).map(e=>`<span class='w-1.5 h-1.5 sm:w-2 sm:h-2 rounded-full ${e.active?'bg-emerald-500':'bg-gray-400'}'></span>`).join('')}</div>
                </button>`
              }).join('')}
            </div>
          </div>
        </div>
        <div class="space-y-3" id="events-list">
          ${((byDay[currentDay]||[]).length===0? `
            <div class='card p-4'>
              <div class='skeleton h-4 sm:h-5 w-2/3 rounded mb-2'></div>
              <div class='skeleton h-3 sm:h-4 w-1/3 rounded'></div>
            </div>
            <div class='card p-4'>
              <div class='skeleton h-4 sm:h-5 w-1/2 rounded mb-2'></div>
              <div class='skeleton h-3 sm:h-4 w-1/4 rounded'></div>
            </div>
          ` : '')}
          ${(byDay[currentDay]||[]).map(e => `
            <div class="card p-3 sm:p-4 cursor-pointer card-hover" data-evt="${e.id}">
              <div class="flex items-center justify-between gap-2">
                <div class="min-w-0">
                  <div class="font-medium text-sm sm:text-base truncate">${e.title}</div>
                  <div class="text-xs sm:text-sm opacity-70">${dayjs(e.date).format('DD.MM.YYYY')} · ${e.city||'Общи'}</div>
                </div>
                <span class="text-[10px] sm:text-xs px-2 py-1 rounded-full whitespace-nowrap ${e.active?'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-300':'bg-gray-100 text-gray-700 dark:bg-white/10 dark:text-gray-200'}">${e.active?'Активно':'Неактивно'}</span>
              </div>
              <div class="text-xs sm:text-sm mt-2 opacity-80">Тип: ${e.type}${e.limit?`, лимит: ${e.limit}`:''}</div>
              <div class="mt-3 flex flex-wrap gap-2">
                <button class="btn-ghost text-xs sm:text-sm" data-open="${e.id}">Детайли</button>
                ${e.city==='Общи'? `<button class="btn text-xs sm:text-sm" data-register="${e.id}" aria-label="Запиши се">Запиши се</button>`:''}
                <button class="btn-ghost text-xs sm:text-sm" data-ics="${e.id}" aria-label="Изтегли напомняне">Напомняне</button>
              </div>
            </div>
          `).join('')}
        </div>
      </section>
    `
  },
  afterRender(){
    const params = new URLSearchParams(location.hash.split('?')[1]||'')
    const setParam = (k,v)=>{ params.set(k,v); location.hash = `#/events?${params.toString()}` }
    document.getElementById('filter-city')?.addEventListener('change', (e)=> setParam('city', e.target.value))
    document.getElementById('filter-status')?.addEventListener('change', (e)=> setParam('status', e.target.value))
    document.getElementById('prev')?.addEventListener('click', ()=>{
      const d = dayjs(params.get('day')||dayjs().format('YYYY-MM-DD')).subtract(1,'month').format('YYYY-MM-DD')
      setParam('day', d)
    })
    document.getElementById('next')?.addEventListener('click', ()=>{
      const d = dayjs(params.get('day')||dayjs()).add(1,'month').format('YYYY-MM-DD')
      setParam('day', d)
    })
    document.getElementById('today')?.addEventListener('click', ()=> setParam('day', dayjs().format('YYYY-MM-DD')))
    document.querySelectorAll('[data-day]')?.forEach(el=> el.addEventListener('click', ()=> setParam('day', el.getAttribute('data-day'))))

    // Register and ICS
    const { user } = getAuth()
    document.querySelectorAll('[data-register]')?.forEach(el=> el.addEventListener('click', async (ev)=>{
      ev.stopPropagation()
      if (!user) { location.hash = '#/login'; return }
      const eventId = el.getAttribute('data-register')
      if (await hasRegistration(eventId, user.id)) { alert('Вече сте записани.'); return }
      const form = `
        <form id='rq' class='space-y-3'>
          <label class='label'>Кратко представяне</label>
          <textarea class='input min-h-[100px]' name='answers' placeholder='Отговори на въпросник'></textarea>
          <div class='flex justify-end gap-2'>
            <button class='btn-ghost' data-close='1' type='button'>Отказ</button>
            <button class='btn'>Запиши се</button>
          </div>
        </form>`
      const { el: modal, close } = showModal({ title: 'Регистрация', content: form })
      modal.querySelector('#rq')?.addEventListener('submit', async (e2)=>{
        e2.preventDefault()
        const answers = new FormData(e2.currentTarget).get('answers')||''
        await saveRegistration({ eventId, userId: user.id, answers, at: Date.now() })
        close()
        alert('Успешна регистрация!')
      })
    }))
    document.querySelectorAll('[data-ics]')?.forEach(el=> el.addEventListener('click', (ev)=>{
      ev.stopPropagation()
      const id = el.getAttribute('data-ics')
      // Minimal ICS placeholder
      const dt = dayjs().format('YYYYMMDDT090000Z')
      const ics = `BEGIN:VCALENDAR\nVERSION:2.0\nBEGIN:VEVENT\nDTSTART:${dt}\nSUMMARY:Събитие\nEND:VEVENT\nEND:VCALENDAR`
      const blob = new Blob([ics], { type: 'text/calendar' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a'); a.href = url; a.download = 'reminder.ics'; a.click(); URL.revokeObjectURL(url)
    }))

    // Open details modal when clicking card or dedicated button
    document.querySelectorAll('[data-open], [data-evt]')?.forEach(el=> el.addEventListener('click', async (ev)=>{
      const id = el.getAttribute('data-open') || el.getAttribute('data-evt')
      if (!id) return
      const e = await getEvent(id)
      const body = `
        <div class='space-y-4'>
          ${e.photos?.[0]? `<img src='${e.photos[0]}' class='w-full aspect-[16/9] object-cover rounded-xl'>` : ''}
          <div class='grid gap-2 sm:grid-cols-2 text-sm'>
            <div><span class='opacity-70'>Дата и час:</span> ${dayjs(e.date).format('DD.MM.YYYY HH:mm')}</div>
            <div><span class='opacity-70'>Град:</span> ${e.city||'Общи'}</div>
            <div><span class='opacity-70'>Тип:</span> ${e.type}</div>
            <div><span class='opacity-70'>Статус:</span> ${e.active?'Активно':'Неактивно'}</div>
            ${e.limit? `<div><span class='opacity-70'>Лимит:</span> ${e.limit}</div>`:''}
          </div>
          <div class='prose dark:prose-invert'>${e.description||''}</div>
          <div class='flex gap-2'>
            ${e.city==='Общи'? `<button class='btn' data-register='${e.id}'>Запиши се</button>`:''}
            <button class='btn-ghost' data-ics='${e.id}'>Напомняне</button>
          </div>
        </div>`
      showModal({ title: e.title, content: body, size: 'lg' })
    }))
  }
}
