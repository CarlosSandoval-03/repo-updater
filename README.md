# repo-updater

Hace `git pull` a todos los repos que estén dentro de una carpeta. Una vez al día te pregunta con una notificación de KDE si quieres actualizar.

La carpeta en la que trabaja es **la misma donde están estos scripts**. Cada subcarpeta que tenga `.git` se actualiza, y si clonas un repo nuevo ahí se incluye automáticamente. El `.gitignore` ignora todas las subcarpetas, así que este repo solo guarda los scripts y nunca los repos que actualiza.

```
mi-carpeta/          <- este repo
├── update.sh
├── update-ask.sh
├── install.sh
├── repo-a/          <- se actualiza (ignorado por este repo)
└── repo-b/          <- se actualiza (ignorado por este repo)
```

## Requisitos

- Linux con systemd y KDE Plasma (`notify-send` con botones y `ksshaskpass`).
- Llave SSH con acceso a GitHub en `~/.ssh/id_ed25519`. Si usas otra, cambia la ruta en `update-ask.sh`.

## Instalación

### En una carpeta nueva

```bash
git clone git@github.com:<usuario>/repo-updater.git ~/ruta/a/mi-carpeta
cd ~/ruta/a/mi-carpeta
git clone git@github.com:<org>/repo-a.git    # clona aquí los repos que quieras
./install.sh
```

### En una carpeta que ya tiene repos

`git clone` no funciona en una carpeta que no esté vacía, así que trae los scripts así:

```bash
cd ~/ruta/a/mi-carpeta
git init -b main
git remote add origin git@github.com:<usuario>/repo-updater.git
git pull origin main
./install.sh
```

Esto no toca los repos que ya están ahí, porque el `.gitignore` los ignora.

## Cambiar de carpeta

Los scripts siempre trabajan sobre la carpeta donde están. Para usar otra carpeta, mueve el repo (o instálalo allí como se explica arriba) y vuelve a ejecutar `./install.sh`, que hace que el timer apunte a la nueva ubicación.

> Solo hay un timer por usuario (`update-repos`). Si ejecutas `install.sh` desde otra carpeta, la nueva reemplaza a la anterior.

## Uso

| Qué | Comando |
|-----|---------|
| Actualizar ahora, sin preguntar | `./update.sh` |
| Mostrar la pregunta ahora | `systemctl --user start update-repos.service` |
| Ver cuándo será la próxima pregunta | `systemctl --user list-timers update-repos.timer` |
| Ver el log de la última ejecución | `journalctl --user -u update-repos.service -n 50` |
| Desactivar | `systemctl --user disable --now update-repos.timer` |
| Desinstalar | lo anterior + `rm ~/.config/systemd/user/update-repos.{service,timer}` |

`update.sh` usa `git pull --ff-only`, así que nunca crea merges ni pisa tus cambios locales. Si un repo tiene cambios que chocan, ramas divergentes o no hay red, ese repo se salta y al final se muestra en la lista de los que fallaron.

Para cambiar la frecuencia, edita `OnUnitActiveSec` en `install.sh` y vuelve a ejecutarlo.
