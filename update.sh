#!/usr/bin/env bash
# update.sh — Actualiza todos los repos git que estén en la misma carpeta que este script.
#
# Uso:    ./update.sh
#
# Qué hace:
#   - Recorre cada subcarpeta que tenga .git y ejecuta `git pull --ff-only --recurse-submodules`.
#   - Si clonas un repo nuevo en esta carpeta, se incluye automáticamente.
#   - Si un repo falla (cambios locales que chocan, ramas divergentes, sin red, sin llave SSH),
#     no se toca, se sigue con los demás y al final se listan los que fallaron.
#
# Salida: código 0 si todo se actualizó, 1 si algún repo falló.
#
# Requisitos: llave SSH con acceso a GitHub cargada en el agente (los remotos son git@github.com:...).
#
# Ver también: update-ask.sh, que lo ejecuta automáticamente con confirmación.

cd "$(dirname "$0")" || exit 1

failed=()
for repo in */; do
  [ -d "$repo/.git" ] || continue
  echo "==> ${repo%/}"
  # --ff-only: nunca crea merges ni pisa cambios locales; si diverge, falla y lo reporta.
  git -C "$repo" pull --ff-only --recurse-submodules || failed+=("${repo%/}")
done

if [ ${#failed[@]} -gt 0 ]; then
  echo "Fallaron: ${failed[*]}" >&2
  exit 1
fi
echo "Todo actualizado."
