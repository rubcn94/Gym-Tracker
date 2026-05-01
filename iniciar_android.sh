#!/data/data/com.termux/files/usr/bin/bash

# Script para lanzar GymTracker en Android
# Uso: Termux:Widget o ejecutar manualmente en Termux

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ruta al proyecto (ajusta si es diferente)
PROJECT_DIR="/storage/emulated/0/Documents/Acabado/gym_tracker"

# Verificar que existe la carpeta
if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}⚠️  Carpeta no encontrada: $PROJECT_DIR${NC}"
    echo -e "${YELLOW}Verifica que Syncthing haya sincronizado los archivos${NC}"
    exit 1
fi

# Verificar que existe el HTML
if [ ! -f "$PROJECT_DIR/gymtracker.html" ]; then
    echo -e "${YELLOW}⚠️  Archivo HTML no encontrado${NC}"
    exit 1
fi

# Matar servidor previo si existe
pkill -f "python.*http.server.*8001" 2>/dev/null

# Cambiar al directorio del proyecto
cd "$PROJECT_DIR" || exit 1

# Mostrar info
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}💪 GymTracker - Entrenamiento${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📂 Proyecto:${NC} $PROJECT_DIR"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Iniciar servidor HTTP con API en background
echo -e "${YELLOW}🚀 Iniciando servidor...${NC}"
python "$PROJECT_DIR/iniciar.py" > /tmp/gymtracker.log 2>&1 &
SERVER_PID=$!

# Esperar a que el servidor esté listo
sleep 3

# Verificar que el servidor está corriendo
if ps -p $SERVER_PID > /dev/null 2>&1; then
    # Detectar puerto real del log
    PORT=$(grep "puerto" /tmp/gymtracker.log 2>/dev/null | grep -oP '\d+' | head -1)
    [ -z "$PORT" ] && PORT=8000

    echo -e "${BLUE}🌐 URL:${NC} http://localhost:$PORT/gymtracker.html"
    echo -e "${GREEN}✅ Servidor corriendo (PID: $SERVER_PID, Puerto: $PORT)${NC}"

    # Intentar abrir en navegador
    echo -e "${YELLOW}🌐 Abriendo navegador...${NC}"
    termux-open-url "http://localhost:$PORT/gymtracker.html"

    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Todo listo!${NC}"
    echo -e "${BLUE}ℹ️  El servidor seguirá corriendo en segundo plano${NC}"
    echo -e "${BLUE}ℹ️  Para detenerlo: ${NC}pkill -f 'python.*iniciar.py'"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
else
    echo -e "${YELLOW}❌ Error al iniciar el servidor${NC}"
    exit 1
fi
