#!/usr/bin/env bash

set -euo pipefail

# Colores para salida por terminal (solo decorativo)
RED='\033[38;5;196m'
GREEN='\033[38;5;46m'
PURPLE='\033[38;5;165m'
BLUE='\033[38;5;50m'
NC='\033[0m'

# Mensajes con formato
info() { echo -e "${BLUE} [INFO]${NC} $*"; }
success() { echo -e "${GREEN}[CHIDO]${NC} $*"; }
warning() { echo -e "${PURPLE} [OJO PIOJO]${NC} $*"; }
error() { echo -e "${RED} [ERROR]${NC} $*"; }


# cpu_usage(): calcula el porcentaje de uso de CPU en el intervalo de 1 segundo.
#
# Método:
# - Lee la línea `cpu` de /proc/stat dos veces con 1 segundo de separación.
# - Calcula la diferencia entre totales e inactivos para estimar uso.
# - Devuelve un número con un decimal (p. ej. 12.3)
cpu_usage() {
    local idle1 total1 idle2 total2 idle_delta total_delta

    # Primera lectura de /proc/stat: campos de CPU (user, nice, system, idle, iowait, ...)
    read -r idle1 total1 < <(
        awk '/^cpu / {idle=$5+$6; total=0; for (i=2; i<=NF; i++) total+=$i; print idle, total}' /proc/stat
    )

    # Esperamos 1 segundo para medir el intervalo
    sleep 1

    # Segunda lectura
    read -r idle2 total2 < <(
        awk '/^cpu / {idle=$5+$6; total=0; for (i=2; i<=NF; i++) total+=$i; print idle, total}' /proc/stat
    )

    idle_delta=$((idle2 - idle1))
    total_delta=$((total2 - total1))

    # Evitar división por cero; calculamos porcentaje de uso
    awk -v idle="$idle_delta" -v total="$total_delta" 'BEGIN {
        if (total <= 0) {
            printf "0.0"
        } else {
            printf "%.1f", (1 - (idle / total)) * 100
        }
    }'
}


# active_connections_port80(): cuenta conexiones TCP establecidas hacia/desde el puerto 80.
# Usa `ss` para obtener conexiones y cuenta las líneas.
active_connections_port80() {
    ss -Htn state established '( sport = :80 or dport = :80 )' 2>/dev/null | wc -l | tr -d ' '
}


# fail2ban_status(): intenta leer el estado del jail configurado usando fail2ban-client.
# - Si `fail2ban-client` no está instalado, informa y continúa.
# - Si se ejecuta como root lee directamente; si no, intenta usar `sudo -n` (sin pedir contraseña).
MONITOR_JAIL="${MONITOR_JAIL:-sshd}"

fail2ban_status() {
    local output

    if ! command -v fail2ban-client &>/dev/null; then
        echo "fail2ban-client no disponible"
        return 0
    fi

    # Si somos root, invocamos directamente; si no, intentamos sudo sin pedir contraseña
    if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
        if output="$(fail2ban-client status "$MONITOR_JAIL" 2>&1)"; then
            echo "$output"
        else
            echo "No se pudo leer el jail $MONITOR_JAIL: $output"
        fi
    else
        if output="$(sudo -n fail2ban-client status "$MONITOR_JAIL" 2>/dev/null)"; then
            echo "$output"
        else
            echo "No se pudo leer el jail $MONITOR_JAIL sin privilegios"
        fi
    fi
}


# Iteraciones de monitorizado (0 = bucle infinito). Se puede sobrescribir exportando
# la variable de entorno `MONITOR_ITERATIONS` antes de ejecutar el script.
iterations="${MONITOR_ITERATIONS:-0}"
if [[ ! "$iterations" =~ ^[0-9]+$ ]]; then
    iterations=0
fi

loop_count=0

# Bucle principal: limpia pantalla, muestra fecha/hora, conexiones a puerto 80, CPU y estado de Fail2Ban
while true; do
    # Limpia pantalla y posiciona cursor al inicio
    printf '\033[2J\033[H'

    echo "Fecha y hora: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Conexiones activas al puerto 80: $(active_connections_port80)"
    echo "CPU actual: $(cpu_usage)%"
    echo ""

    echo "Estado del jail $MONITOR_JAIL en Fail2Ban:"
    fail2ban_status
    echo ""

    echo "Actualizacion automatica cada 5 segundos"

    # Contador de iteraciones opcional
    loop_count=$((loop_count + 1))
    if [[ "$iterations" -gt 0 && "$loop_count" -ge "$iterations" ]]; then
        break
    fi

    sleep 5
done
