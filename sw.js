// Service Worker para GymTracker PWA
const CACHE_NAME = 'gymtracker-v6';
const STATIC_ASSETS = [
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  'https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(STATIC_ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(cacheNames =>
      Promise.all(cacheNames.filter(n => n !== CACHE_NAME).map(n => caches.delete(n)))
    )
  );
  self.clients.claim();
});

// Timer de notificación en background (sobrevive pantalla bloqueada)
// event.waitUntil() mantiene el SW vivo hasta que se muestre la notificación
let _notifTimer = null;
let _notifReject = null;
self.addEventListener('message', event => {
  if (event.data.type === 'SCHEDULE_NOTIFICATION') {
    // Cancelar timer anterior si existe
    if (_notifTimer) { clearTimeout(_notifTimer); _notifTimer = null; }
    if (_notifReject) { _notifReject(); _notifReject = null; }
    const delay = Math.max(0, event.data.endTime - Date.now());
    const exName = event.data.exName;
    // waitUntil impide que el OS mate el SW hasta que la promesa resuelva
    event.waitUntil(
      new Promise((resolve, reject) => {
        _notifReject = reject;
        _notifTimer = setTimeout(() => {
          _notifTimer = null;
          _notifReject = null;
          resolve(self.registration.showNotification('⏰ ¡Descanso terminado!', {
            body: exName ? `${exName} — ¡Siguiente serie!` : '¡Es hora de entrenar!',
            icon: './icon-192.png',
            badge: './icon-192.png',
            vibrate: [300, 100, 300, 100, 500],
            tag: 'rest-timer',
            renotify: true,
            silent: false
          }));
        }, delay);
      })
    );
  } else if (event.data.type === 'CANCEL_NOTIFICATION') {
    if (_notifTimer) { clearTimeout(_notifTimer); _notifTimer = null; }
    if (_notifReject) { _notifReject(); _notifReject = null; }
  }
});

self.addEventListener('notificationclick', event => {
  event.notification.close();
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(list => {
      const client = list.find(c => c.url.includes('index.html') || c.url.endsWith('/'));
      if (client) { client.focus(); return; }
      clients.openWindow('./index.html');
    })
  );
});

self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  const isHTML = event.request.mode === 'navigate' ||
                 url.pathname.endsWith('.html') ||
                 url.pathname === '/' ||
                 url.pathname.endsWith('/');

  if (isHTML) {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          const clone = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
          return response;
        })
        .catch(() => caches.match(event.request))
    );
  } else {
    event.respondWith(
      caches.match(event.request).then(response => {
        if (response) return response;
        return fetch(event.request).then(res => {
          if (res && res.status === 200 && res.type === 'basic') {
            caches.open(CACHE_NAME).then(cache => cache.put(event.request, res.clone()));
          }
          return res;
        });
      })
    );
  }
});
