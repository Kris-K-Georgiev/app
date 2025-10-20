import { h, render } from 'htm/preact';
import './styles.css'
import { Router } from './router.js';


render(h(Router), document.getElementById('app'));

import { registerSW } from './sw-register.js'

const App = () => h('div', {class: 'min-h-screen flex flex-col'}, [
  h(Router)
])

render(h(App), document.getElementById('app'))

// register service worker
registerSW()
