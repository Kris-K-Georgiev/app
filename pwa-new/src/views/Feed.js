import { h } from 'htm/preact'
import { useState } from 'preact/hooks'
import { Card, Button, Badge, Avatar } from 'flowbite-react'

const filters = [
  {label:'Всички', value:'all'},
  {label:'Молитви', value:'prayers'},
  {label:'Свидетелства', value:'testimonies'},
  {label:'Вдъхновения', value:'inspirations'}
]

const posts = [
  {id:1, type:'prayers', user:'Иван', avatar:'/icons/icon-192.png', text:'Моля се за здраве.', verse:'Филипяни 4:6', likes:3, comments:2, shares:1},
  {id:2, type:'testimonies', user:'Мария', avatar:'/icons/icon-192.png', text:'Бог ми помогна в труден момент.', verse:'Псалм 23:1', likes:5, comments:1, shares:0}
]

const notifications = [
  'Молитвен час започва след 15 минути',
  'Ново свидетелство публикувано'
]

export default function Feed() {
  const [filter, setFilter] = useState('all')
  const filtered = filter==='all' ? posts : posts.filter(p=>p.type===filter)
  return h('div',{},[
    h('div',{class:'mb-4 flex gap-2'},
      filters.map(f=>h(Button,{
        color:filter===f.value?'warning':'gray',
        onClick:()=>setFilter(f.value),
        size:'xs'
      },f.label))
    ),
    h('div',{class:'mb-4'},
      notifications.map((n,i)=>h(Badge,{color:'info',class:'mr-2'},n))
    ),
    h('div',{},
      filtered.map(post=>h(Card,{class:'mb-4'},[
        h('div',{class:'flex items-center gap-2 mb-2'},[
          h(Avatar,{img:post.avatar,rounded:true}),
          h('span',{class:'font-bold'},post.user)
        ]),
        h('div',{class:'mb-2'},post.text),
        h('div',{class:'italic text-sm text-blue-600 mb-2'},post.verse),
        h('div',{class:'flex gap-4'},[
          h(Button,{color:'failure',size:'xs'},'❤️ '+post.likes),
          h(Button,{color:'info',size:'xs'},'💬 '+post.comments),
          h(Button,{color:'success',size:'xs'},'📤 '+post.shares)
        ])
      ]))
    )
  ])
}
