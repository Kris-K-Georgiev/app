import { h } from 'htm/preact'
import { useState } from 'preact/hooks'
import { Card, Button, Badge, TextInput } from 'flowbite-react'

const todayVerse = {
  ref: 'Йоан 3:16',
  text: 'Защото Бог толкова възлюби света, че даде Своя Единороден Син...'
}

const sampleReflections = [
  {id:1, user:'Иван', text:'Този стих ми дава надежда.'},
  {id:2, user:'Мария', text:'Любимият ми стих!'}
]

export default function Verse() {
  const [reflections, setReflections] = useState(sampleReflections)
  const [newReflection, setNewReflection] = useState('')
  const [favorites, setFavorites] = useState([todayVerse.ref])

  function addReflection() {
    if (!newReflection) return
    setReflections([{id:Date.now(),user:'Вие',text:newReflection},...reflections])
    setNewReflection('')
  }

  function addFavorite() {
    if (!favorites.includes(todayVerse.ref)) setFavorites([...favorites, todayVerse.ref])
  }

  return h('div',{},[
    h(Card,{class:'mb-4'},[
      h('div',{class:'font-bold text-lg mb-2'},'Стих на деня'),
      h('div',{class:'italic text-blue-700 mb-2'},todayVerse.ref),
      h('div',{class:'mb-2'},todayVerse.text),
      h(Button,{color:'success',size:'xs',onClick:addFavorite}, favorites.includes(todayVerse.ref)?'Вече е в любими':'Добави в любими')
    ]),
    h('div',{class:'mb-2 font-semibold'},'Вашият размисъл'),
    h(TextInput,{
      value:newReflection,
      onChange:e=>setNewReflection(e.target.value),
      placeholder:'Вашият размисъл...'
    }),
    h(Button,{color:'info',class:'mt-2',onClick:addReflection},'Публикувай'),
    h('div',{class:'mt-4'},
      reflections.map(r=>h(Card,{class:'mb-2'},[
        h('div',{class:'font-bold'},r.user),
        h('div',{},r.text)
      ]))
    ),
    h('div',{class:'mt-4'},[
      h('div',{class:'font-semibold mb-2'},'Любими стихове'),
      favorites.map(f=>h(Badge,{color:'warning',class:'mr-2'},f))
    ])
  ])
}
