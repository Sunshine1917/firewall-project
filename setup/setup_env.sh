#! /usr/bin/env bash

set -euo pipefail # detiene si comando falla/ variables no definidas son tratadas como error/ si algun pipe falla, todo falla

RED='\033[38:5;196m' # \033[38;5;{id}m
GREEN='\033[38;5;46m'
PURPLE='\033[38;5;165m'
BLUE='\033[38;5;50m'
NC='\033[0m'

info() { echo -e "${BLUE} [INFO]${NC} $*";}
success() { echo -e "${GREEN}[CHIDO]${NC} $*";}
warning() { echo -e "${PURPLE} [OJO PIOJO]${NC} $*";}
error() { echo -e "${RED} [ERROR]${NC} $*"; exit 1;}

if [[ "$EUID" -ne 0 ]]; then # Verificamos que sea root el que lo ejecuta
	error "Se necesita ejecutar esto como root"
fi	

echo ""
echo "============================================================"
echo "  INSTALACIÓN DE DEPENDENCIAS NECESARIAS "
echo "============================================================"
echo ""

# ======= BLOQUE DE VERIFICACIÓN DEL SO ======= #
info "Verificando SO..."
cat << 'EOF'
  ,-.       _,---._ __  / \
 /  )    .-'       `./ /   \
(  (   ,'            `/    /|
 \  `-"             \'\   / |
  `.              ,  \ \ /  |
   /`.          ,'-`----Y   |
  (            ;        |   '
  |  ,-.    ,-'         |  /
  |  | (   |        hjw | /
  )  |  \  `.___________|/
  `--'   `--'
EOF
sleep 2

if [[ ! -f /etc/os-release ]]; then
	error "No se pudo detectar el SO"
fi

source /etc/os-release

if [[ "$ID" != "almalinux" ]]; then
	error "Necesitas el SO AlmaLinux y tu tienes: $VERSION_ID"
fi

MAJOR_VERSION=$(echo "$VERSION_ID" | cut -d. -f1)
if [[ "$MAJOR_VERSION" != "9" ]]; then
	error "Se requiere AlmaLinux 9 y tu versión es $VERSION_ID"
fi

success "SO verificado: $PRETTY_NAME"
sleep 1
# ===================================================== #

# ======= BLOQUE DE ACTUALIZACIÓN DEL SISTEMA ======= #
info "Atualizando paquetes del sistema porque seguramente tu no lo haces"
cat << 'EOF'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣶⣿⠟⠉⠉⠻⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣾⠿⠉⠀⠀⠀⠀⠀⠹⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⢿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣾⡿⠛⠉⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣾⡿⠟⠁⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣴⣿⡿⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣷⣶⣶⣦⣤⣤⣄⡀⠀⢀⣠⣾⣿⠿⠋⠀⠀⠀⠀⠀⣠⣿
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣤⠶⠞⣿⠟⠋⠉⠉⠙⣻⠿⢿⣿⣿⣿⠟⠁⠀⠀⠀⠀⠀⢀⣿⣯⠋
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⠁⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠟⠁⢠⡞⠁⠀⠀⠀⢀⡴⠋⠀⢀⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⣾⣷⡟⠁
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣼⣿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠃⠀⢠⠏⠀⠀⠀⠀⣰⠏⠀⠀⣠⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡽⣿⣿⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣇⠀⣠⡏⠀⠀⠀⠀⣼⠁⠀⠀⣰⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣏⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣄⣄⣼⣿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡶⠋⠀⠀⠀⠀⢸⣧⠀⠀⣴⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢿⣷⡀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⠀⠀⠀⠀⣾⡿⠿⣿⡿⠁⠀⠀⠀⠀⠀⠀⣠⣶⣶⣶⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⠃
⠀⠀⠀⠀⠀⠀⢀⣾⠿⠛⢿⣿⣷⣄⡀⣿⠃⠀⠈⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣠⣤⣦⣼⣿⠀⠀⠀⣿⣿⣿⣿⣿⣦⣀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⡿⠀⠀⠀⢀⣀⣀⣀⣤⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀ ⠀⣤⣾⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⣠⣾⡿⠋⠉⠉⠁⠀⠀⠀⠀⠉⢯⡙⠻⣿⣿⣷⣤⡀⠀⠀⠀⠀⢿⣿⣿⣿⣿⡿⠃⣠⡾⠟⠋⠉⠉⠉⠉⠉⠉⠛⠿⣦⠀⠀⠀  ⢠⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀
⣾⣿⠋⠀⠀⠀⠀⣀⣀⠀⠀⠀⠀⠀⠙⢦⣄⠉⠻⢿⣿⣷⣦⡀⠀⠈⠙⠛⠛⠋⠀⣼⠟⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⣕⣆⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀
⣿⡇⠀⠀⠀⣴⠟⣫⣿⣿⣄⠀⠀⠀⠀⡶⢌⡙⠶⣤⡈⠛⠿⣿⣷⣦⣀⠀⠀⠀⠀⡿⠀⢻⣷⠤⠤⣼⢷⣄⠀⠀⠀⢠⣷⠀⠘⡟⣧⠀⠻⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀
⣿⡇⠀⠀⢸⣟⢸⣿⣿⣿⣿⠀⠀⠀⠀⡇⠀⠈⠛⠦⣝⡳⢤⣈⠛⠻⣿⣷⣦⣀⠀⠁⠀⠀⠈⠙⠋⠁⠀⠛⠯⠭⠭⠛⠁⠀⠀⢻⠁⠀⠀⠈⠛⠿⠿⠿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀
⣿⡇⠀⠀⠈⢿⣞⣿⣿⣿⠏⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠙⠳⢬⣛⠦⠀⠙⢻⣿⣷⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⡇⠀⠀⠀⠀⠉⠛⠋⠁⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠈⣿⠉⢻⣿⣷⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠏⠀⠀⠀⠀⠀⠀⠀⠀
⣿⡇⠀⠀⠀⠀⠀⣠⣄⠀⠀⢰⠶⠒⠒⢧⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⢸⡇⢸⡟⢿⣷⣦⣴⣶⣶⣶⣶⣤⣔⠋⠀⠀⠀⠀⠀⠀
⣿⡇⠀⠀⣤⠀⠀⠿⠿⠁⢀⡿⠀⠀⠀⡄⠈⠙⡷⢦⣄⡀⠀⠀⠀⠀⠀⠀⠀⣿⠀⢸⡇⢸⡇⠀⣿⠙⣿⣿⣉⠉⠙⠿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⡇⠀⠀⠙⠷⢤⣀⣠⠴⠛⠁⠀⠀⠀⠇⠀⠀⡇⢸⡏⢹⡷⢦⣄⡀⠀⠀⠀⣿⡀⢸⡇⢸⡇⠀⡟⠀⢸⠀⢹⡷⢦⣄⣘⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⣿⣿⠢⣤⡀⠀⠀⠀⠀⠀⠀⣠⠾⣿⣿⡷⣤⣀⡇⠸⡇⢸⡇⢸⠉⠙⠳⢦⣄⡻⢿⣾⣧⣸⣧⠀⡇⠀⢸⠀⢸⡇⢤⣈⠙⠻⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⢹⣿⣷⣌⡉⠛⠲⢶⣶⠖⠛⠛⢶⣄⡉⠛⠿⣽⣿⣶⣧⣸⡇⢸⠀⠀⠀⠀⠈⠙⠲⢮⣝⠻⣿⣷⣷⣄⣸⠀⢸⡇⠀⠈⠁⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠈⠙⠻⢿⣷⣶⣤⣉⡻⢶⣄⣀⠈⠙⠳⢦⣈⡉⠻⢿⣿⣷⣾⣦⡀⠀⠀⠀⠀⠀⠀⠈⠙⠲⢭⣛⠿⣿⣷⣼⡇⠀⠀⠀⠀⠈⣿⡇⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀
⠀⠀⠀⠀⠀⠈⠙⠻⢿⣿⣷⣶⣽⣻⡦⠀⠀⠈⠙⠷⣦⣌⡙⠻⢿⣟⣷⣤⣀⠀⠀⠀⠀⠀⠀⠀⠈⠙⠳⢯⣻⡇⠀⠀⠀⠀⠀⢸⣿⠀⣀⠀⠀⠀⠀⠈⠳⣄⣀⡀⠀⢀⣏⣽⡿⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠻⢿⣿⣿⣿⣶⣤⣤⣤⣀⣈⠛⠷⣤⣈⡛⠷⢽⡻⢶⣄⣀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠳⢤⣀⠀⠀⢸⣿⡙⠿⣷⣤⣄⣠⣶⡿⠉⠛⠿⠷⠿⠛⠁⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⣿⡿⠛⠉⠙⠛⠛⠻⢷⣦⣄⣩⣿⠶⠖⠛⠛⠛⠛⠛⠛⠿⢷⣶⣦⣄⠀⠀⠀⠀⠉⢻⣶⣿⣿⠇⠀⠀⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⠁⠀⠀⠀⠀⠀⠀⠀⣿⣿⠋⠀⠀⠀⠀⠀⣠⣶⡆⠀⠀⠀⠈⠙⠿⣿⣦⡄⠀⠀⣸⣿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⣰⣪⠏⠁⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣶⣄⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣧⠀⠀⢀⣾⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⡶⠙⢿⣿⣇⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡿⠿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡿⠦⠹⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⠷⠤⠄⠙⡿⠿⠦⠤⠤⠤⠤⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
EOF
sleep 2
dnf update -y -q
success "Sistema actualizado"
sleep 1

# ===================================================== #

# ======= BLOQUE DE INSTALACIÓN DE PAQUETES PRINCIPALES ======= #
info "Instalando los paquetes ..."

PACKAGES=(
	httpd
	mod_ssl
	openssl
	firewalld
	fail2ban
	wireshark-cli
	tcpdump
	net-tools
	hping3
	curl
	vim
)

dnf install -y -q "${PACKAGES[@]}"
sleep 1
success "Paquetes instalados"
sleep 1

# ======= BLOQUE DE HABILITACIÓN DE SERVIDORES ======= #
info "Habilitando servicios"
systemctl enable --now httpd
success "Apache habilitado"

systemctl enable --now firewalld
success "Firewalld habilidato"

systemctl enable --now fail2ban
success "Fail2Ban habilitado"

echo "Verificación de servidores"

if [[ $(systemctl is-active httpd) == "active" ]]; then
  success "httpd corriendo"
else
  warning "httpd no está corriendo"
fi

if [[ $(systemctl is-active firewalld) == "active" ]]; then
	success "firewalld corriendo a toda maquina"
else
	warning "firewalld no esta corriendo"
fi

if [[ $(systemctl is-active fail2ban) == "active" ]]; then
	success "fail2ban funcionando ajuaaa"
else
	warning "fail2ban no esta corriendo"
fi

echo " Verificar comandos"
if command -v hping3 &>/dev/null; then
  success "hping3 encontrado en $(command -v hping3)"
else
  warning "hping3 no encontrado"
fi

if command -v tcpdump &>/dev/null; then
	success "tcpdump encontrado en $(command -v tcpdump)"
else
	warning "tcpdump no encontrado UnU"
fi

if command -v fail2ban-client &>/dev/null; then
	success "fail2ban-client encontrado en $(command -v fail2ban-client)"
else
	warning "fail2ban-client no encontrado, esto ya corrigelo tu por favor"
fi

if command -v curl &>/dev/null; then
	success "curl encontrado en $(command -v curl)"
else
	warning "curl no encontrado, buscalo y arreglalo"
fi

# ===================================================== #
cat << 'EOF'
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡶⠓⢷⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⠃⠀⠀⠘⣦⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢠⣴⣶⣶⣤⣠⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣛⠇⠀⠀⠀⠀⣏⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢻⠀⠀⠈⠉⠻⣟⣾⣤⡀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣺⣟⡳⢿⠐⠠⡀⠀⠀⢸⡅⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢨⡟⠀⠀⠀⠀⠀⠈⠳⣭⢟⡷⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣾⠷⣭⣛⢧⡈⠅⡒⠄⠀⢸⡁⠀⠀⠁⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢸⣇⠀⠀⠀⠀⠀⠀⠀⠸⣿⣾⣿⣿⣦⡄⡀⠀⡀⣤⣴⣴⣿⠿⠷⠿⠿⠿⠿⠿⣶⣿⣿⣤⠸⣤⢻⡄⢸⡇⠀⠀⠀⠀⠀⠀
⠀⠀⡀⠀⠀⠀⠀⠈⣿⠀⠀⠀⠀⠀⠀⣀⠠⠘⣯⡟⣯⢟⣿⣧⡤⠟⠛⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⢧⣀⠏⡁⢘⡧⠀⠀⠀⠀⠀⠀
⠀⠀⠐⠃⠀⠀⠀⠐⢿⠀⠀⠀⠀⢀⠰⢀⠣⢁⡿⡽⣎⣿⡾⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣻⣧⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣼⠀⠀⠀⠀⠆⢡⠊⢄⠃⣸⡗⣯⡛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣴⣦⣝⢯⣄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠹⡆⠀⠀⢈⠰⠁⡌⠢⢌⣷⢯⡓⠀⠀⣀⣤⣶⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣧⣽⣿⣿⡟⠀⣷⣤⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠰⢧⠀⠀⠠⡁⠎⡠⢑⡾⣝⣾⠀⠀⣾⣷⣤⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⠿⠿⠟⠋⠠⠄⠷⢿⣶⡀⠀⠀
⠀⠀⠀⠐⠀⠀⠀⠀⠀⠹⣇⠀⠀⠁⢂⣡⣾⢻⡜⣿⠀⠀⠙⠻⠿⢿⣿⣿⣿⣿⠇⠀⠀⠀⠀⡄⣠⢠⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⡷⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠩⣻⡗⣶⢫⡟⣮⢷⡹⣽⠲⠒⠀⠀⠀⠀⠢⡀⠀⠀⠀⠀⠀⠀⠀⠀⢣⠏⠀⠀⠀⠀⢀⣨⠰⠛⠁⠀⠀⠈⣛⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢹⣾⡝⣾⡱⣏⡷⣹⢇⠀⠀⠀⠀⠀⢔⡴⢀⢀⣀⣀⡀⣀⡤⠰⠁⠙⠡⠶⠜⠃⠁⠀⠀⠀⠀⠀⠂⠀⣯⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⢟⣾⡽⣎⢷⣭⣛⠷⣦⠀⠀⠀⠀⠀⠈⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⣸⠅⠀⠀
⠀⠀⠀⠀⠀⠐⠅⠀⠀⠀⠀⠀⠀⠀⢽⡿⣼⡹⣞⢶⣫⢟⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀⣰⠏⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⣿⢳⢧⣻⢼⣫⢞⠝⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠔⠁⠀⠀⠀⡸⠇⠀⠀⠀⠀
⡤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣯⣛⢮⡳⣏⡾⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⢶⣫⢏⡷⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡏⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣟⣮⠳⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡄⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣂⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣨⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣯⡀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣧⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣘⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢷⠄⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣽⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡗⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣇⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢘⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣏⡀
⠀⠀⠀⠀⠀⠀⠀⢀⣽⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⡁
⠀⠀⠀⠀⠀⠀⠀⠈⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣷
⠀⠀⠀⠀⠀⠀⠀⣾⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡧
⠀⠀⠀⠀⠀⠀⠀⣾⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣷
EOF
echo "Todo Listo !"
