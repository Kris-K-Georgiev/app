import { h } from 'htm/preact'
import { useState } from 'preact/hooks'
import { Card, Button, Badge, TextInput, Select } from 'flowbite-react'

const categories = [
  {label:'Всички', value:'all'},
  {label:'Здраве', value:'health'},
  {label:'Семейство', value:'family'},
  {label:'Работа', value:'work'},
  {label:'Вяра', value:'faith'}
]

const samplePrayers = [
  {id:1, user:'Иван', category:'health', text:'Моля се за изцеление.', count:12},
  {id:2, user:'Мария', category:'family', text:'Благодаря за подкрепата.', count:7}
]

export default function Prayers() {
  const [filter, setFilter] = useState('all')
  const [prayers, setPrayers] = useState(samplePrayers)
  const [newPrayer, setNewPrayer] = useState('')
  const [newCat, setNewCat] = useState('health')

  const filtered = filter==='all' ? prayers : prayers.filter(p=>p.category===filter)

  function addPrayer() {
    if (!newPrayer) return
    setPrayers([{id:Date.now(),user:'Вие',category:newCat,text:newPrayer,count:0},...prayers])
    setNewPrayer('')
  }

  return h('div',{},[
    h('h2',{class:'text-xl font-bold mb-4'},'Молитвени нужди'),
    h('div',{class:'mb-4 flex gap-2'},
      categories.map(c=>h(Button,{
        color:filter===c.value?'warning':'gray',
        onClick:()=>setFilter(c.value),
        size:'xs'
      },c.label))
    ),
    h(Card,{class:'mb-4'},[
      h('div',{class:'mb-2 font-semibold'},'Публикувай нужда или благодарност'),
      h(TextInput,{
        value:newPrayer,
        onChange:e=>setNewPrayer(e.target.value),
        placeholder:'Вашата молитва...'
      }),
      h(Select,{
        value:newCat,
        onChange:e=>setNewCat(e.target.value),
        class:'mt-2'
      },categories.filter(c=>c.value!=='all').map(c=>h('option',{value:c.value},c.label))),
      h(Button,{color:'success',class:'mt-2',onClick:addPrayer},'Публикувай')
    ]),
    h('div',{},
      filtered.map(prayer=>h(Card,{class:'mb-4'},[
        h('div',{class:'font-bold mb-1'},prayer.user),
        h('div',{class:'mb-2'},prayer.text),
        h(Badge,{color:'info',class:'mb-2'},categories.find(c=>c.value===prayer.category)?.label),
        h(Button,{
          color:'warning',size:'xs',onClick:()=>setPrayers(prayers.map(p=>p.id===prayer.id?{...p,count:p.count+1}:p))
        },`Моля се за теб (${prayer.count})`)
      ]))
    )
  ])
}
