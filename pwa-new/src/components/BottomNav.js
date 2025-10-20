import { h } from 'htm/preact'
const navs = [
  {icon:'🏠',label:'Начало',href:'#/'},
  {icon:'🙏',label:'Молитви',href:'#/prayers'},
  {icon:'📖',label:'Стих',href:'#/verse'},
  {icon:'🗓️',label:'Събития',href:'#/events'},
  {icon:'💬',label:'Чат',href:'#/chat'},
  {icon:'👤',label:'Профил',href:'#/profile'}
]
export default function BottomNav(){
  return h('nav',{class:'fixed bottom-0 left-0 right-0 bg-white dark:bg-black border-t flex justify-around items-center h-16 z-50'},
    navs.map(n=>h('a',{href:n.href,class:'flex flex-col items-center text-xs font-medium'},[h('span',{class:'text-2xl'},n.icon),n.label]))
  )
}
