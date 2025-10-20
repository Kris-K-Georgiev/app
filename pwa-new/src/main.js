import { h, render } from 'htm/preact';
import './styles.css';
import { Router } from './router.js';
import { registerSW } from './sw-register.js';

// Главният компонент
const App = () => h('div', { class: 'min-h-screen flex flex-col' }, [
  h(Router)
]);

// Рендериране в #app
render(h(App), document.getElementById('app'));

// Регистриране на Service Worker
registerSW();
