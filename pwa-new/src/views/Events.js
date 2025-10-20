
import { useState } from 'preact/hooks'
import { Card, Button, Badge, TextInput } from 'flowbite-react'

const sampleEvents = [
  {id:1, title:'Молитвена вечер', date:'2025-10-25', type:'духовна', active:true, joined:false},
  {id:2, title:'Онлайн среща', date:'2025-11-02', type:'онлайн', active:true, joined:true}
]

export default function Events() {
  const [events, setEvents] = useState(sampleEvents)
  const [newTitle, setNewTitle] = useState('')
  const [newDate, setNewDate] = useState('2025-10-30')
  const [newType, setNewType] = useState('духовна')

  function joinEvent(id) {
    setEvents(events.map(e=>e.id===id?{...e,joined:true}:e))
    // TODO: trigger push notification (PWA API)
    alert('Напомняне добавено!')
  }

  function addEvent() {
    if (!newTitle) return
    setEvents([{id:Date.now(),title:newTitle,date:newDate,type:newType,active:true,joined:false},...events])
    setNewTitle('')
  }

  return h('div',{},[
    h('h2',{class:'text-xl font-bold mb-4'},'Събития и срещи'),
    h('div',{class:'mb-4'},'Календар (placeholder) — интегрирайте FullCalendar или друг календарен компонент'),
    h(Card,{class:'mb-4'},[
      h('div',{class:'mb-2 font-semibold'},'Добави събитие (админ)'),
      h(TextInput,{
        value:newTitle,
        onChange:e=>setNewTitle(e.target.value),
        placeholder:'Заглавие на събитието'
      }),
      h(TextInput,{
        value:newDate,
        onChange:e=>setNewDate(e.target.value),
        placeholder:'Дата (YYYY-MM-DD)'
      }),
      h(TextInput,{
        value:newType,
        onChange:e=>setNewType(e.target.value),
        placeholder:'Тип'
      }),
      h(Button,{color:'success',class:'mt-2',onClick:addEvent},'Добави')
    ]),
    h('div',{},
      events.map(ev=>h(Card,{class:'mb-4'},[
        h('div',{class:'font-bold mb-1'},ev.title),
        h('div',{class:'mb-2'},ev.date),
        h(Badge,{color:'info',class:'mb-2'},ev.type),
        h(Button,{
          color:ev.joined?'gray':'warning',size:'xs',onClick:()=>joinEvent(ev.id),disabled:ev.joined
        },ev.joined?'Присъединен':'Присъедини се'),
        h(Badge,{color:ev.active?'success':'failure',class:'ml-2'},ev.active?'Активно':'Неактивно')
      ]))
    )
  ])
}
