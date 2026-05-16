# GymTracker PWA - App de Entrenamiento

Aplicación web progresiva (PWA) para registrar entrenamientos de calistenia y fuerza.

## ✨ Características

- **📱 App nativa**: Se instala como app real en tu móvil/PC
- **🔌 Funciona offline**: No necesita internet después de instalarse
- **💾 Datos locales**: Todo se guarda en tu dispositivo (localStorage)
- **📊 Gráficos de progreso**: Visualiza tu evolución
- **⏱️ Cronómetros**: Temporizadores para descansos
- **📅 Calendario**: Historial visual de entrenamientos
- **💪 Plan completo**: 6 días/semana de entrenamiento estructurado

## 🚀 Instalación

### Opción 1: Abrir directamente (sin servidor)

1. **Abrir el archivo HTML:**
   ```
   Doble click en: gymtracker.html
   ```

2. **Instalar como PWA:**
   - En **Chrome/Edge**: Click en el icono `+` (o ⋮) → "Instalar app"
   - En **Firefox**: Click en ⋮ → "Instalar"
   - En **Safari iOS**: Compartir → "Añadir a pantalla de inicio"

3. **¡Listo!** La app aparecerá como aplicación nativa

### Opción 2: Con servidor local (opcional)

Si prefieres usar servidor (para desarrollo):

```bash
python iniciar.py
```

Luego abre: http://localhost:8000/gymtracker.html

## 📂 Estructura de Archivos

```
GymTracker/
├── gymtracker.html      # App principal (PWA)
├── manifest.json        # Configuración PWA
├── sw.js                # Service Worker (offline)
├── icon-192.png         # Icono pequeño
├── icon-512.png         # Icono grande
├── icon.svg             # Icono fuente
├── iniciar.py           # Servidor Python (opcional)
└── README_PWA.md        # Este archivo
```

## 💾 Gestión de Datos

### Backup Manual

1. Ve a **Config** (⚙️)
2. Click en **"📤 Exportar backup"**
3. Guarda el archivo JSON en lugar seguro

### Importar Datos

1. Ve a **Config**
2. Click en **"📥 Importar backup"**
3. Selecciona el archivo JSON guardado

### Sincronización entre dispositivos

**No hay sincronización automática** (los datos están solo en tu dispositivo).

Para sincronizar manualmente:
1. Exporta backup en dispositivo A
2. Pásalo a dispositivo B (email, Drive, etc.)
3. Importa en dispositivo B

## 🏋️ Plan de Entrenamiento

### Lunes - Espalda + Bíceps
- Peso muerto en máquina (4×4-5 • 180s)
- Remo en polea baja (4×8-10 • 90s)
- Dominadas lastradas (3×8-10 • 90s)
- Face pull (3×15 • 60s)
- Curl bíceps (3×12-15 • 75s)

### Martes - Pecho + Tríceps
- Press de pecho máquina (4×4-5 • 180s)
- Press inclinado mancuernas (3×8-10 • 90s)
- Fondos paralelas (3×10-12 • 90s)
- Extensiones tríceps (3×15 • 75s)

### Miércoles - Hombros + Core
- Press hombros máquina (3×8-10 • 90s)
- Elevaciones laterales (5×12-15 • 75s)
- Pájaros inclinado (3×15 • 75s)
- Plancha, Dead bug, Bird dog (4 series c/u)

### Jueves - Piernas
- Sentadilla goblet profunda (5×4-5 • 120s)
- Hip thrust máquina (4×10-12 • 90s)
- Zancadas mancuernas (3×12 • 90s)
- Extensión cuádriceps (3×15 • 60s)
- Femoral tumbado (3×15 • 60s)
- Gemelos sentado (3×15-20 • 60s)

### Viernes - Full Body Fuerza
- Extensión de cuádriceps (5×3 • 120s)
- Press pecho pesado (5×3 • 180s)
- Remo pesado (5×3 • 180s)
- Peso muerto rumano (3×5 • 150s)
- Superserie: Curl + Tríceps (3×10 • 0s/90s)

### Sábado - Cardio + Isométricos
- HIIT en bici (8 intervalos • + km totales)
- Dead Hang (3×20-40s • 90s)
- Pike Push-up ISO (3×15-30 • 90s)
- Plancha lateral + Hollow hold (3 series c/u)

### Domingo - Descanso Total
¡Recupera y vuelve más fuerte!

## 🔧 Desarrollo

### Regenerar iconos

```bash
python generate_icons_simple.py
```

### Actualizar versión del Service Worker

Edita `sw.js` y cambia:
```javascript
const CACHE_NAME = 'gymtracker-v2'; // Incrementar número
```

## 📝 Notas

- **Autoguardado**: Los datos se guardan automáticamente al completar sets
- **Cronómetro**: Se detiene automáticamente al cambiar de página
- **Ejercicios Core**: Solo checkbox (sin input de segundos)
- **HIIT**: Campo especial para km totales
- **Offline**: Funciona completamente sin internet después de instalar

## 🐛 Solución de Problemas

### La app no se instala
- Usa Chrome, Edge o Safari (Firefox tiene soporte limitado)
- Asegúrate de abrir desde HTTPS o localhost
- Verifica que manifest.json y sw.js existan

### Los datos se perdieron
- **Exporta backups regularmente**
- Si limpias el navegador, los datos se borran
- Usa siempre la misma app instalada (no múltiples navegadores)

### La app no funciona offline
- Recarga la página con Ctrl+F5 para forzar actualización
- Verifica en DevTools → Application → Service Workers

---

**¡Disfruta de tu entrenamiento! 💪**
