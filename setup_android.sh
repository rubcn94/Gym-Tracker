#!/data/data/com.termux/files/usr/bin/bash

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 💪 GymTracker - Configuración automática Android
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Este script configura TODO automáticamente para GymTracker
#
# USO: bash setup_android.sh
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables
PROJECT_DIR="/storage/emulated/0/Documents/Acabado/gym_tracker"
SCRIPT_NAME="iniciar_android.sh"
WIDGET_NAME="GymTracker"
STOP_WIDGET="GymTracker-Stop"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${CYAN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  💪 GymTracker - Configuración Android"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}[1/7]${NC} Verificando instalación de paquetes..."

if ! command -v python &> /dev/null; then
    echo -e "${BLUE}  → Instalando Python...${NC}"
    pkg install python -y
    echo -e "${GREEN}  ✅ Python instalado${NC}"
else
    echo -e "${GREEN}  ✅ Python ya instalado${NC}"
fi

if ! command -v termux-open-url &> /dev/null; then
    echo -e "${BLUE}  → Instalando Termux:API...${NC}"
    pkg install termux-api -y
    echo -e "${GREEN}  ✅ Termux:API instalado${NC}"
else
    echo -e "${GREEN}  ✅ Termux:API ya instalado${NC}"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}[2/7]${NC} Configurando permisos de almacenamiento..."

if [ ! -d "$HOME/storage" ]; then
    echo -e "${BLUE}  → Solicitando permisos...${NC}"
    termux-setup-storage
    sleep 2
    echo -e "${GREEN}  ✅ Permisos configurados${NC}"
else
    echo -e "${GREEN}  ✅ Permisos ya configurados${NC}"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}[3/7]${NC} Verificando carpeta del proyecto..."

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}  ❌ ERROR: Carpeta no encontrada${NC}"
    echo -e "${RED}     $PROJECT_DIR${NC}"
    echo ""
    echo -e "${YELLOW}  → Syncthing aún no ha sincronizado los archivos${NC}"
    exit 1
else
    echo -e "${GREEN}  ✅ Carpeta del proyecto encontrada${NC}"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}[4/7]${NC} Verificando script de inicio..."

if [ ! -f "$PROJECT_DIR/$SCRIPT_NAME" ]; then
    echo -e "${RED}  ❌ ERROR: Script no encontrado${NC}"
    exit 1
else
    echo -e "${GREEN}  ✅ Script de inicio encontrado${NC}"
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}[5/7]${NC} Creando carpeta de widgets..."

mkdir -p ~/.shortcuts
echo -e "${GREEN}  ✅ Carpeta ~/.shortcuts creada${NC}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}[6/7]${NC} Instalando widgets..."

# Widget principal
echo -e "${BLUE}  → Copiando widget de inicio...${NC}"
cp "$PROJECT_DIR/$SCRIPT_NAME" ~/.shortcuts/"$WIDGET_NAME"
chmod +x ~/.shortcuts/"$WIDGET_NAME"
echo -e "${GREEN}  ✅ Widget '$WIDGET_NAME' instalado${NC}"

# Widget de stop
echo -e "${BLUE}  → Creando widget de parada...${NC}"
cat > ~/.shortcuts/"$STOP_WIDGET" << 'EOFSTOP'
#!/data/data/com.termux/files/usr/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛑 Deteniendo GymTracker...${NC}"

pkill -f 'python.*http.server.*8001'

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Servidor detenido correctamente${NC}"
else
    echo -e "${GREEN}ℹ️  No había ningún servidor corriendo${NC}"
fi

sleep 2
EOFSTOP

chmod +x ~/.shortcuts/"$STOP_WIDGET"
echo -e "${GREEN}  ✅ Widget '$STOP_WIDGET' instalado${NC}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}[7/7]${NC} Verificando instalación..."

WIDGETS_COUNT=$(ls ~/.shortcuts/ | wc -l)
echo -e "${GREEN}  ✅ $WIDGETS_COUNT widgets instalados${NC}"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${CYAN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ INSTALACIÓN COMPLETADA"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"

echo -e "${GREEN}Widgets instalados:${NC}"
echo -e "${BLUE}  1. GymTracker${NC}      → Iniciar servidor + abrir navegador"
echo -e "${BLUE}  2. GymTracker-Stop${NC} → Detener servidor"
echo ""

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📱 PRÓXIMOS PASOS:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}1.${NC} Añadir widget a la pantalla de inicio:"
echo -e "   ${BLUE}→${NC} Widgets → Termux:Widget → GymTracker"
echo ""
echo -e "${CYAN}2.${NC} ¡Tap en el widget → Entrenar! 💪"
echo ""

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}🧪 PRUEBA RÁPIDA:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}~/.shortcuts/GymTracker${NC}"
echo ""

echo -e "${CYAN}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${NC}"
