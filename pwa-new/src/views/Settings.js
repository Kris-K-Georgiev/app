
import { h } from 'htm/preact'
import { useState } from 'preact/hooks'
import { Card, Button, Badge, Select } from 'flowbite-react'

const languages = [
  {label:'Български', value:'bg'},
  {label:'English', value:'en'}
]

export default function Settings() {
  const [theme, setTheme] = useState(document.documentElement.getAttribute('data-theme')||'light')
  const [lang, setLang] = useState('bg')
  const [notifications, setNotifications] = useState(true)

  function toggleTheme() {
    const el = document.documentElement
    if(theme==='dark') {
      el.removeAttribute('data-theme')
      setTheme('light')
    } else {
      el.setAttribute('data-theme','dark')
      setTheme('dark')
    }
  }

  function toggleNotifications() {
    setNotifications(!notifications)
    // TODO: implement push notification subscription
    alert(notifications ? 'Известията са изключени.' : 'Известията са включени.')
  }

  function changeLang(e) {
    setLang(e.target.value)
    // TODO: implement i18n
    alert('Езикът е сменен на '+languages.find(l=>l.value===e.target.value).label)
  }

  return h('div',{},[
    h(Card,{class:'mb-4'},[
      h('div',{class:'font-bold mb-2'},'Тема'),
      h(Button,{color:theme==='dark'?'info':'warning',onClick:toggleTheme},theme==='dark'?'Светъл режим':'Тъмен режим')
    ]),
    h(Card,{class:'mb-4'},[
      h('div',{class:'font-bold mb-2'},'Език'),
      h(Select,{value:lang,onChange:changeLang},languages.map(l=>h('option',{value:l.value},l.label)))
    ]),
    h(Card,{class:'mb-4'},[
      h('div',{class:'font-bold mb-2'},'Известия'),
      h(Button,{color:notifications?'success':'gray',onClick:toggleNotifications},notifications?'Включени':'Изключени'),
      h('div',{class:'mt-2 text-xs text-slate-500'},'Push известия от Firebase: нова молитвена нужда, отговор на коментар, напомняне за събитие (пример).')
    ])

  ])
}

