import { h } from 'htm/preact'
import { useEffect, useState } from 'preact/hooks'
import BottomNav from '../components/BottomNav.js'
import SidebarNav from '../components/SidebarNav.js'
import HeaderNav from '../components/HeaderNav.js'

export default function AppLayout({children}) {
  const [navType, setNavType] = useState('bottom')

  useEffect(() => {
    function handleResize() {
      const w = window.innerWidth
      const h = window.innerHeight
      if (w >= 1024) setNavType('header')
      else if (w > h) setNavType('sidebar')
      else setNavType('bottom')
    }
    handleResize()
    window.addEventListener('resize', handleResize)
    return () => window.removeEventListener('resize', handleResize)
  }, [])

  return h('div', {class: 'min-h-screen flex flex-col bg-bg'}, [
    navType === 'header' && h(HeaderNav),
    navType === 'sidebar' && h('div', {class:'flex flex-row'}, [h(SidebarNav), h('main', {class:'flex-1'}, children)]),
    navType === 'bottom' && [h('main', {class:'flex-1'}, children), h(BottomNav)],
    navType === 'header' && h('main', {class:'flex-1'}, children)
  ])
}
