import { h, render } from 'htm/preact';
import './styles.css';
import { Router } from './router.js';
import 'flowbite-react';
import 'idb-keyval';

const App = () => h('div', {class: 'min-h-screen flex flex-col'}, [
  h(Router)
]);

render(h(App), document.getElementById('app'));
