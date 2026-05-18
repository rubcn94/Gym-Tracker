# Cómo hacer una app instalable desde Chrome (PWA)

Para que Chrome muestre la opción de instalar necesitas 3 archivos y unas líneas en el HTML.

---

## 1. `manifest.json`

Crea este archivo en la raíz del proyecto:

```json
{
  "name": "Nombre de la App",
  "short_name": "App",
  "start_url": "./index.html",
  "display": "standalone",
  "background_color": "#0a0a0a",
  "theme_color": "#0a0a0a",
  "icons": [
    { "src": "./icon-192.png", "sizes": "192x192", "type": "image/png" },
    { "src": "./icon-512.png", "sizes": "512x512", "type": "image/png" }
  ]
}
```

---

## 2. `sw.js` — Service Worker

Crea este archivo en la raíz. Usa estrategia **Network First para HTML** (siempre descarga la versión más reciente cuando hay conexión) y **Cache First para assets estáticos**:

```javascript
const CACHE_NAME = 'mi-app-v1';
const STATIC_ASSETS = [
  './manifest.json',
  './icon-192.png',
  './icon-512.png'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(STATIC_ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(names =>
      Promise.all(names.filter(n => n !== CACHE_NAME).map(n => caches.delete(n)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', event => {
  const url = new URL(event.request.url);
  const isHTML = event.request.mode === 'navigate' ||
                 url.pathname.endsWith('.html') ||
                 url.pathname === '/' ||
                 url.pathname.endsWith('/');

  if (isHTML) {
    // Network First: siempre descarga HTML fresco, sin necesidad de borrar caché
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
    // Cache First: assets estáticos van rápido desde caché
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
```

> **Importante:** Con Network First para HTML, los cambios en el código se ven automáticamente al recargar sin necesidad de borrar la caché del navegador ni reimportar datos.

---

## 3. `index.html` — Añadir en el `<head>`

```html
<link rel="manifest" href="./manifest.json">
<meta name="theme-color" content="#0a0a0a">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
```

## 3b. `index.html` — Añadir al final del `<script>`

```javascript
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('./sw.js')
      .then(() => console.log('SW registrado'))
      .catch(err => console.log('SW error:', err));
  });
}
```

---

## 4. Iconos

Necesitas dos PNGs cuadrados:

| Archivo | Tamaño | Uso |
|---------|--------|-----|
| `icon-192.png` | 192×192 px | Android home screen |
| `icon-512.png` | 512×512 px | Splash screen / Play Store |

Puedes generarlos con cualquier imagen cuadrada usando [squoosh.app](https://squoosh.app) o similar.

---

## 5. Hosting con HTTPS

Chrome solo muestra la opción de instalar si la app está en **HTTPS**. Opciones gratuitas:

| Opción | HTTPS automático |
|--------|-----------------|
| GitHub Pages | ✅ |
| Netlify | ✅ |
| Vercel | ✅ |
| Cloudflare Pages | ✅ |

Para GitHub Pages: Settings → Pages → Branch: main → Save. La URL será `https://usuario.github.io/repo`.

---

## Resultado

Una vez configurado, en Chrome (Android o escritorio):

- **Android:** menú ⋮ → *Añadir a pantalla de inicio*
- **Escritorio:** icono de instalación (⊕) en la barra de direcciones

La app se instala como una aplicación nativa: icono propio, sin barra de Chrome, funciona offline.
