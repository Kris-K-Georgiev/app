import { h, render } from 'htm/preact';
import './styles.css';
import 'flowbite';

// Тук можеш да инициализираш SPA логиката си с HTM/Preact или чист JS
import { Router } from './router.js';
render(h(Router), document.getElementById('app'));
