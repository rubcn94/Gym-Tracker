#!/data/data/com.termux/files/usr/bin/bash

# GymTracker - Toggle servidor (iniciar/parar)
PROJECT_DIR="/storage/emulated/0/Documents/Acabado/gym_tracker"

# Verificar si está corriendo
if pgrep -f "python.*iniciar.py" > /dev/null; then
    # Está corriendo → PARAR
    pkill -f "python.*iniciar.py"
    rm -f "$HOME/gymtracker.log"
    termux-toast "🛑 GymTracker detenido"
else
    # No está corriendo → INICIAR

    # Verificar proyecto existe
    if [ ! -d "$PROJECT_DIR" ]; then
        termux-toast "⚠️ Proyecto no encontrado"
        exit 1
    fi

    # Cambiar a directorio
    cd "$PROJECT_DIR" || exit 1

    # Iniciar servidor en background
    LOG_FILE="$HOME/gymtracker.log"
    python "$PROJECT_DIR/iniciar.py" > "$LOG_FILE" 2>&1 &
    sleep 3

    # Detectar puerto
    PORT=$(grep "puerto" "$LOG_FILE" 2>/dev/null | grep -oP '\d+' | head -1)
    [ -z "$PORT" ] && PORT=8000

    # Abrir navegador
    termux-open-url "http://localhost:$PORT/gymtracker.html"

    # Notificación
    termux-toast "💪 GymTracker en puerto $PORT"
fi
