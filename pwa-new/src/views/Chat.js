import { h } from 'htm/preact'
import { useState } from 'preact/hooks'
import { Card, Button, Badge, TextInput, Avatar } from 'flowbite-react'

const rooms = [
  {id:'students', label:'Ученици'},
  {id:'worship', label:'Прослава'},
  {id:'faith', label:'Въпроси за вярата'},
  {id:'testimonies', label:'Свидетелства'}
]

const sampleMessages = {
  students: [
    {id:1, user:'Иван', avatar:'/icons/icon-192.png', text:'Здравейте! 😊'},
    {id:2, user:'Мария', avatar:'/icons/icon-192.png', text:'Как сте? 🙏'}
  ],
  worship: [
    {id:1, user:'Петър', avatar:'/icons/icon-192.png', text:'Слава на Бога! 🎶'}
  ],
  faith: [],
  testimonies: []
}

export default function Chat() {
  const [activeRoom, setActiveRoom] = useState('students')
  const [messages, setMessages] = useState(sampleMessages)
  const [newMsg, setNewMsg] = useState('')

  function sendMsg() {
    if (!newMsg) return
    setMessages({
      ...messages,
      [activeRoom]: [
        ...messages[activeRoom],
        {id:Date.now(),user:'Вие',avatar:'/icons/icon-192.png',text:newMsg}
      ]
    })
    setNewMsg('')
  }

  return h('div',{},[
    h('div',{class:'mb-4 flex gap-2'},
      rooms.map(r=>h(Button,{
        color:activeRoom===r.id?'warning':'gray',
        onClick:()=>setActiveRoom(r.id),
        size:'xs'
      },r.label))
    ),
    h('div',{class:'mb-4'},
      messages[activeRoom].map(m=>h(Card,{class:'mb-2'},[
        h('div',{class:'flex items-center gap-2 mb-1'},[
          h(Avatar,{img:m.avatar,rounded:true}),
          h('span',{class:'font-bold'},m.user)
        ]),
        h('div',{},m.text)
      ]))
    ),
    h('div',{class:'flex gap-2'},[
      h(TextInput,{
        value:newMsg,
        onChange:e=>setNewMsg(e.target.value),
        placeholder:'Вашето съобщение...'
      }),
      h(Button,{color:'info',onClick:sendMsg},'Изпрати')
    ]),
    h('div',{class:'mt-4 text-xs text-slate-500'},'Поддържа емотикони, снимки (поставете линк), гласови съобщения (placeholder), Firebase integration — пример.')
  ])
}
