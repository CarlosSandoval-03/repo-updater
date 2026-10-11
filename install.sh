#!/usr/bin/env bash
# install.sh — Crea el timer de systemd (de usuario) que ejecuta update-ask.sh
# 2 min después de iniciar sesión y luego cada día. Se puede volver a ejecutar sin problema.
#
# Uso:    ./install.sh
# Quitar: systemctl --user disable --now update-repos.timer
#         rm ~/.config/systemd/user/update-repos.{service,timer}

dir=$(cd "$(dirname "$0")" && pwd)
units="$HOME/.config/systemd/user"
mkdir -p "$units"

cat >"$units/update-repos.service" <<EOF
[Unit]
Description=Preguntar y actualizar repos de $dir

[Service]
Type=oneshot
# Si no respondes en 30 min, se descarta hasta la próxima.
TimeoutStartSec=30min
Environment=SSH_ASKPASS=/usr/bin/ksshaskpass
Environment=GIT_SSH_COMMAND="ssh -o BatchMode=yes"
ExecStart=$dir/update-ask.sh
EOF

cat >"$units/update-repos.timer" <<EOF
[Unit]
Description=Preguntar por actualizar repos al iniciar sesión y una vez al día

[Timer]
OnStartupSec=2min
OnUnitActiveSec=1d

[Install]
WantedBy=timers.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now update-repos.timer
echo "Instalado. Próxima ejecución:"
systemctl --user list-timers update-repos.timer --no-pager
