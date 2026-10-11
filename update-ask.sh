#!/usr/bin/env bash
# update-ask.sh — Pregunta con una notificación de KDE si quieres actualizar y, si aceptas,
# ejecuta update.sh y te avisa del resultado.
#
# Flujo:
#   1. Muestra una notificación con los botones "Actualizar" / "Ahora no".
#      Si eliges "Ahora no" o la cierras, termina sin hacer nada.
#   2. Si tu llave SSH no está en el agente, pide la passphrase con ksshaskpass
#      (solo la primera vez de cada sesión; si la guardas en KWallet no vuelve a pedirla).
#   3. Ejecuta update.sh y muestra una notificación de éxito o con el error.
#
# Cómo se ejecuta (systemd de usuario, sin root):
#   ~/.config/systemd/user/update-repos.timer    -> 2 min después de iniciar sesión y luego cada día
#   ~/.config/systemd/user/update-repos.service  -> lanza este script (máx. 30 min esperando respuesta)
#
# Comandos útiles:
#   systemctl --user list-timers update-repos.timer      # cuándo será la próxima pregunta
#   systemctl --user start update-repos.service          # preguntar ahora
#   journalctl --user -u update-repos.service -n 50      # ver el log de la última ejecución
#   systemctl --user disable --now update-repos.timer    # desactivar
#   systemctl --user enable --now update-repos.timer     # volver a activar
#
# Para cambiar la frecuencia: edita OnUnitActiveSec en el .timer y ejecuta
#   systemctl --user daemon-reload && systemctl --user restart update-repos.timer

answer=$(notify-send --app-name="Repos" --icon=system-software-update \
  --action=yes=Actualizar --action=no="Ahora no" --wait \
  "Actualizar repositorios" "¿Hacer git pull en $(dirname "$0")?")
[ "$answer" = "yes" ] || exit 0

# Si la llave no está en el agente, pide la passphrase con ksshaskpass (una vez por sesión).
ssh-add -l >/dev/null 2>&1 || SSH_ASKPASS_REQUIRE=force ssh-add "$HOME/.ssh/id_ed25519" </dev/null || {
  notify-send --app-name="Repos" --icon=dialog-error "Actualización cancelada" "No se cargó la llave SSH."
  exit 1
}

if out=$("$(dirname "$0")/update.sh" 2>&1); then
  notify-send --app-name="Repos" --icon=dialog-ok "Repositorios actualizados" "Todo al día."
else
  notify-send --app-name="Repos" --icon=dialog-error "Error al actualizar" "$(tail -n 1 <<<"$out")"
  exit 1
fi
