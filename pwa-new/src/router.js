import { h } from 'htm/preact'
import { useState, useEffect } from 'preact/hooks'
import Home from './views/Home.js'
import Feed from './views/Feed.js'
import Prayers from './views/Prayers.js'
import Verse from './views/Verse.js'
import AppLayout from './layout/AppLayout.js'
import NewsDetail from './views/NewsDetail.js'
import Events from './views/Events.js'
import Chat from './views/Chat.js'
import Profile from './views/Profile.js'
import Settings from './views/Settings.js'
import Auth from './views/Auth.js'
import Admin from './views/Admin.js'

const routes = {
  '': Feed,
  '#/': Feed,
  '#/feed': Feed,
  '#/prayers': Prayers,
  '#/verse': Verse,
  '#/news': Home,
  '#/news/': NewsDetail,
  '#/events': Events,
  '#/chat': Chat,
  '#/profile': Profile,
  '#/settings': Settings,
  '#/auth': Auth,
  '#/admin': Admin
}

export function Router() {
  const [hash, setHash] = useState(location.hash || '#/')

  useEffect(() => {
    const onHash = () => setHash(location.hash || '#/')
    window.addEventListener('hashchange', onHash)
    return () => window.removeEventListener('hashchange', onHash)
  }, [])

  let Comp = routes[hash.split('?')[0]] || Feed
  if (hash.startsWith('#/news/')) Comp = NewsDetail

  return h(AppLayout,{}, h(Comp, {hash}))
}
