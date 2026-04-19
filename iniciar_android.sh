#!/data/data/com.termux/files/usr/bin/bash

# Script para toggle GymTracker en Android
# Uso: Termux:Widget o ejecutar manualmente en Termux

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Ruta al proyecto y archivo de estado
PROJECT_DIR="/storage/emulated/0/Documents/GymTracker"
LOCK_FILE="$HOME/.gymtracker.lock"

# Verificar si el servidor ya está corriendo
if [ -f "$LOCK_FILE" ] && pgrep -f "python.*iniciar.py" > /dev/null; then
    # Servidor corriendo: detenerlo
    echo -e "${YELLOW}🛑 Deteniendo GymTracker...${NC}"
    pkill -f "python.*iniciar.py"
    rm -f "$LOCK_FILE"
    sleep 1
    echo -e "${GREEN}✅ Servidor detenido${NC}"
    exit 0
fi

# Limpiar lock file si existe pero no hay proceso
rm -f "$LOCK_FILE"

# Si no está corriendo, iniciarlo
echo -e "${BLUE}🚀 Iniciando GymTracker...${NC}"

# Verificar que existe la carpeta
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}❌ Carpeta no encontrada: $PROJECT_DIR${NC}"
    exit 1
fi

# Verificar que existe el HTML
if [ ! -f "$PROJECT_DIR/gymtracker.html" ]; then
    echo -e "${RED}❌ Archivo HTML no encontrado${NC}"
    exit 1
fi

# Cambiar al directorio del proyecto
cd "$PROJECT_DIR" || exit 1

# Crear archivo de bloqueo
touch "$LOCK_FILE"

# Iniciar servidor HTTP con API en background
python "$PROJECT_DIR/iniciar.py" > "$HOME/gymtracker.log" 2>&1 &
SERVER_PID=$!

# Esperar a que el servidor esté listo
sleep 4

# Verificar que el servidor está corriendo
if ps -p $SERVER_PID > /dev/null 2>&1; then
    # Detectar puerto real del log
    PORT=$(grep -oE '[0-9]+' "$HOME/gymtracker.log" 2>/dev/null | head -1)
    [ -z "$PORT" ] && PORT=8000

    echo -e "${GREEN}✅ Servidor corriendo en puerto $PORT${NC}"

    # Abrir SOLO en Chrome
    am start -a android.intent.action.VIEW -d "http://localhost:$PORT/gymtracker.html" -n com.android.chrome/com.google.android.apps.chrome.Main 2>/dev/null

    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}💪 GymTracker iniciado!${NC}"
    echo -e "${BLUE}ℹ️  Vuelve a tocar el widget para DETENER${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
else
    echo -e "${RED}❌ Error al iniciar el servidor${NC}"
    echo -e "${YELLOW}Ver log: cat $HOME/gymtracker.log${NC}"
    rm -f "$LOCK_FILE"
    exit 1
fi
