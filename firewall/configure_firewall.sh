#!/bin/bash

cat <<EOF | sudo tee /etc/fail2ban/jail.local

[DEFAULT]
# Tiempo o duración del baneo
bantime = 10m
# Tiempo de búsqueda o donde se cuentan los intentos fallidos
findtime = 10m
# Máximo de intentos fallidos permitidos
maxretry = 3
# Acción de bloqueo a ejecutar: Usa iptables para bloquear la ip
banaction = iptables-multiport

[sshd]
enabled = true
# Puerto estándar que es el 22
port = ssh
# Apunta al archivo de configuración sshd.conf
filter = sshd
# Ruta de donde se encuntra el archivo log donde ssh registra los intentos de inicio de sesión
backend = systemd
#logpath = /var/log/secure
# Sobreescribe el maxretry
maxretry = 3
EOF
