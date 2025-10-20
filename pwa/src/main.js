
import 'flowbite';
import './main.css';

// SPA routes
const routes = {
  '': () => import('./views/home.js'),
  '#feed': () => import('./views/feed.js'),
  '#events': () => import('./views/events.js'),
  '#profile': () => import('./views/profile.js'),
  '#splash': () => import('./views/splash.js'),
  '#onboarding': () => import('./views/onboarding.js'),
  '#terms': () => import('./views/terms.js'),
  '#login': () => import('./views/login.js'),
  '#register': () => import('./views/register.js'),
  '#password-recovery': () => import('./views/password-recovery.js'),
  '#guest-info': () => import('./views/guest-info.js'),
  '#offline': () => import('./views/offline.js'),
  '#error': () => import('./views/error.js'),
};

function isOnline() {
  return window.navigator.onLine;
}

function isLoggedIn() {
  // TODO: Replace with Firebase auth check
  return !!localStorage.getItem('user');
}

function hasAcceptedTerms() {
  return localStorage.getItem('termsAccepted') === 'true';
}

function hasSeenOnboarding() {
  return localStorage.getItem('hasSeenOnboarding') === 'true';
}

async function renderRoute() {
  if (!isOnline()) {
    const { default: page } = await routes['#offline']();
    document.getElementById('app').innerHTML = page();
    return;
  }

  // Splash logic: always show splash on load, then redirect
  if (location.hash === '' || location.hash === '#splash') {
    const { default: page } = await routes['#splash']();
    document.getElementById('app').innerHTML = page();
    setTimeout(() => {
      if (!hasSeenOnboarding()) {
        location.hash = '#onboarding';
      } else if (!hasAcceptedTerms()) {
        location.hash = '#terms';
      } else if (!isLoggedIn()) {
        location.hash = '#login';
      } else {
        location.hash = '#feed';
      }
    }, 1200);
    return;
  }

  // Onboarding
  if (location.hash === '#onboarding') {
    const { default: page } = await routes['#onboarding']();
    document.getElementById('app').innerHTML = page();
    document.getElementById('onboarding-finish')?.addEventListener('click', () => {
      localStorage.setItem('hasSeenOnboarding', 'true');
      location.hash = '#terms';
    });
    return;
  }

  // Terms
  if (location.hash === '#terms') {
    const { default: page } = await routes['#terms']();
    document.getElementById('app').innerHTML = page();
    document.getElementById('accept-terms')?.addEventListener('click', () => {
      localStorage.setItem('termsAccepted', 'true');
      location.hash = '#login';
    });
    document.getElementById('contact-admin')?.addEventListener('click', () => {
      window.open('mailto:info@example.com');
    });
    return;
  }

  // Guest info
  if (location.hash === '#guest-info') {
    const { default: page } = await routes['#guest-info']();
    document.getElementById('app').innerHTML = page();
    return;
  }

  // Auth screens
  if (location.hash === '#login') {
    const { default: page } = await routes['#login']();
    document.getElementById('app').innerHTML = page();
    document.getElementById('guest-login')?.addEventListener('click', () => {
      localStorage.setItem('guest', 'true');
      location.hash = '#guest-info';
    });
    // TODO: Add login logic
    return;
  }
  if (location.hash === '#register') {
    const { default: page } = await routes['#register']();
    document.getElementById('app').innerHTML = page();
    // TODO: Add registration logic
    return;
  }
  if (location.hash === '#password-recovery') {
    const { default: page } = await routes['#password-recovery']();
    document.getElementById('app').innerHTML = page();
    // TODO: Add password recovery logic
    return;
  }

  // Main app routes (require auth)
  if (!isLoggedIn() && !localStorage.getItem('guest')) {
    location.hash = '#login';
    return;
  }

  // Default: render route
  const view = routes[location.hash] || routes[''];
  const { default: page } = await view();
  document.getElementById('app').innerHTML = page();
}

window.addEventListener('hashchange', renderRoute);
window.addEventListener('DOMContentLoaded', renderRoute);
