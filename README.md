#SIMULACIÓN DE ATAQUES POR SATURACIÓN Y MITIGACIÓN MEDIANTE REGLAS DE FIREWALL

## Resumen
Este proyecto instala y configura un firewall en AlmaLinux 9 usando **Fail2Ban** e **iptables/firewalld**, posteriormente se simula un ataque SYN flood.

## Requerimientos
| Requerimientos | Versión |
|---|---|
| Sistema Operativo | AlmaLinux 9.x |
| Privilegios | se necesita tener acceso root|
| Internet | Se requiere durante el montaje |

> **Software de MV:** UTM (Mac M1..M4) O VirtualBox (Windows)
---
## Instalación rapida
```bash
# 1. Clona el repositorio
git clone https://github.com/TU_USERNAME/firewall-project.git
cd firewall-project

# 2. Ejecuta el script de configuración (instala todas las dependencias a usar)
sudo bash setup/setup_env.sh
```
## ¿Qué instala setup_env.sh?

| Herramienta | Propósito |
|---|---|
| `httpd` | Servidor web Apache — el servicio que protegemos |
| `firewalld` | Administra las reglas de iptables/nftables |
| `fail2ban` | Monitorea logs y bloquea IPs atacantes automáticamente |
| `hping3` | Simula el ataque SYN Flood para probar el firewall |
| `tcpdump` | Captura tráfico de red desde la terminal |
| `wireshark-cli` | Análisis de paquetes — las capturas se abren en Wireshark GUI |
| `net-tools` | Provee ifconfig y netstat |
| `openssl` | Herramientas de cifrado y certificados |




https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
