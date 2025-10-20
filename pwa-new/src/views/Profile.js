
import { h } from 'htm/preact'
import { useState } from 'preact/hooks'
import { Card, Button, Badge, Avatar, TextInput } from 'flowbite-react'

const userData = {
  name: 'Иван Иванов',
  avatar: '/icons/icon-192.png',
  verse: 'Филипяни 4:13',
  bio: 'Вярващ, доброволец, обича да помага.',
  email: 'ivan@example.com',
  phone: '+359887000000',
  city: 'София',
  stats: {
    prayers: 30,
    posts: 12,
    comments: 18
  },
  saved: ['Публикация 1', 'Публикация 2'],
  history: ['Коментар към молитва', 'Молитва за здраве']
}

export default function Profile() {
  const [edit, setEdit] = useState(false)
  const [bio, setBio] = useState(userData.bio)

  return h('div',{},[
    h(Card,{class:'mb-4'},[
      h('div',{class:'flex items-center gap-4'},[
        h(Avatar,{img:userData.avatar,rounded:true,size:'lg'}),
        h('div',{},[
          h('div',{class:'font-bold text-lg'},userData.name),
          h('div',{class:'text-sm text-slate-500'},userData.city),
          h(Badge,{color:'info',class:'mt-2'},userData.verse)
        ])
      ]),
      h('div',{class:'mt-4'},[
        edit
          ? h(TextInput,{value:bio,onChange:e=>setBio(e.target.value),placeholder:'Биография'})
          : h('div',{},bio),
        h('div',{class:'mt-2'},[
          h('span',{class:'font-semibold'},'Email: '),userData.email
        ]),
        h('div',{},[
          h('span',{class:'font-semibold'},'Телефон: '),userData.phone
        ]),
        h(Button,{color:edit?'success':'info',class:'mt-2',onClick:()=>setEdit(!edit)},edit?'Запази':'Редактирай')
      ])
    ]),
    h(Card,{class:'mb-4'},[
      h('div',{class:'font-semibold mb-2'},'Статистика'),
      h(Badge,{color:'warning',class:'mr-2'},`Молитви: ${userData.stats.prayers}`),
      h(Badge,{color:'info',class:'mr-2'},`Публикации: ${userData.stats.posts}`),
      h(Badge,{color:'success',class:'mr-2'},`Коментари: ${userData.stats.comments}`)
    ]),
    h(Card,{class:'mb-4'},[
      h('div',{class:'font-semibold mb-2'},'Запазени публикации'),
      userData.saved.map(s=>h(Badge,{color:'info',class:'mr-2'},s))
    ]),
    h(Card,{class:'mb-4'},[
      h('div',{class:'font-semibold mb-2'},'История'),
      userData.history.map(his=>h('div',{class:'text-sm'},his))
    ])
  ])
}


export default function Profile() {
  const [edit, setEdit] = useState(false)
  const [bio, setBio] = useState(userData.bio)

  return h('div',{},[
    h(Card,{class:'mb-4'},[
      h('div',{class:'flex items-center gap-4'},[
        h(Avatar,{img:userData.avatar,rounded:true,size:'lg'}),
        h('div',{},[
          h('div',{class:'font-bold text-lg'},userData.name),
          h('div',{class:'text-sm text-slate-500'},userData.city),
          h(Badge,{color:'info',class:'mt-2'},userData.verse)
        ])
      ]),
      h('div',{class:'mt-4'},[
        edit
          ? h(TextInput,{value:bio,onChange:e=>setBio(e.target.value),placeholder:'Биография'})
          : h('div',{},bio),
        h('div',{class:'mt-2'},[
          h('span',{class:'font-semibold'},'Email: '),userData.email
        ]),
        h('div',{},[
          h('span',{class:'font-semibold'},'Телефон: '),userData.phone
        ]),
        h(Button,{color:edit?'success':'info',class:'mt-2',onClick:()=>setEdit(!edit)},edit?'Запази':'Редактирай')
      ])
    ]),
    h(Card,{class:'mb-4'},[
      h('div',{class:'font-semibold mb-2'},'Статистика'),
      h(Badge,{color:'warning',class:'mr-2'},`Молитви: ${userData.stats.prayers}`),
      h(Badge,{color:'info',class:'mr-2'},`Публикации: ${userData.stats.posts}`),
      h(Badge,{color:'success',class:'mr-2'},`Коментари: ${userData.stats.comments}`)
    ]),
    h(Card,{class:'mb-4'},[
      h('div',{class:'font-semibold mb-2'},'Запазени публикации'),
      userData.saved.map(s=>h(Badge,{color:'info',class:'mr-2'},s))
    ]),
    h(Card,{class:'mb-4'},[
      h('div',{class:'font-semibold mb-2'},'История'),
      userData.history.map(his=>h('div',{class:'text-sm'},his))
    ])
  ])
}
