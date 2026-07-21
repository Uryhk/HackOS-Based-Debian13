# hackOS

Distro basada en **Debian 13 (trixie/stable)**, enfocada en **seguridad,
privacidad y anonimato opcional vía Tor**, inspirada en **Whonix** y
**Kicksecure**. Escritorio por defecto: **IceWM**. Alternativas incluidas:
**JWM**, **cwm** (OpenBSD) y **i3**. Terminal por defecto: **sakura**.

Este repo no es una ISO — es un **script de configuración/hardening** que
convierte un Debian 13 recién instalado en hackOS. Es el mismo enfoque que
usa Kicksecure sobre Debian.

## Uso rápido

```bash
git clone <este-repo> hackOS
cd hackOS
sudo bash install.sh
```

Vas a ver un menú (`whiptail`) donde elegís qué instalar con la barra
espaciadora. Cada componente es un módulo independiente en `modules/`, así
que también podés correrlos sueltos:

```bash
sudo bash modules/01-base.sh
sudo bash modules/02-wm-icewm.sh
```

### "No encuentra ningún módulo" / "Módulo no encontrado"

Si te pasa esto: asegurate de correr `install.sh` **desde adentro** de la
carpeta `hackOS/` (la que tiene `install.sh`, `modules/` y `configs/` como
hermanos), no desde otro lado apuntando con una ruta relativa rota:

```bash
cd hackOS      # <- importante
sudo bash install.sh
```

Ya lo arreglamos para que no dependa de que los `.sh` de `modules/` tengan
el bit de ejecución (`chmod +x`) — antes el instalador exigía eso y, si
descargabas/clonabas el proyecto de una forma que no preservaba permisos
(típico en algunos clientes git, o si copiás archivos sueltos en vez del
proyecto entero), decía "módulo no encontrado" aunque el archivo estuviera
ahí. Ahora `install.sh` repara los permisos solo al arrancar, y de todas
formas ya no depende de ellos. Si el error persiste, `install.sh` te va a
decir exactamente en qué carpeta está buscando (`HACKOS_DIR=...`) para que
puedas confirmar que `modules/` está en el lugar correcto.

## Qué instala cada módulo

Todos los módulos y `install.sh` comparten `lib/common.sh` (logging,
`run_module`, chequeos de root/Debian, y `apply_browser_placeholder` — el
helper que hace que **todos** los WM abran el navegador que elegiste en el
instalador, no uno fijo).

| Módulo | Qué hace |
|---|---|
| `01-base.sh` | Paquetes esenciales, kernel endurecido (si hay `linux-image-*-hardened` disponible, si no usa `linux-image-amd64` + sysctl hardening manual), AppArmor en enforce, UFW deny-in/allow-out, blacklist de módulos de kernel poco usados, zram, usuario `hackos` |
| `02-wm-icewm.sh` | IceWM como escritorio por defecto, tema oscuro `hackos`, `picom` para sombras/transparencia livianas, `Super+T` abre terminal |
| `03-wm-jwm.sh` | JWM con estética y atajos coherentes |
| `04-wm-cwm.sh` | `cwm` (OpenBSD), empaquetado en Debian — no hace falta compilar. Config validada con `cwm -n` y contra el man page oficial (`Super+T` abre sakura) |
| `05-wm-i3.sh` | i3 en mosaico, barra `i3status`, mismos atajos y paleta de colores |
| `06-ly.sh` | Login manager principal: **`ly` (TUI) en modo Matrix** — lluvia de caracteres nativa de ly, reloj, paleta de marca hackOS |
| `06b-regreet-avatar.sh` | Alternativa opcional a Matrix: `greetd` + `regreet` (GTK) con **foto/avatar circular real + wallpaper de imagen** |
| `07-apps.sh` | `pcmanfm`, `Pluma`, `sakura` (terminal, con la paleta de marca), `rofi`, `flatpak` + Flathub |
| `08-browser.sh` | Un solo navegador **a elección** (LibreWolf o Mullvad Browser, lo pregunta el instalador) + ProtonVPN |
| `09-privacy-tor.sh` | Tor + Tor Browser launcher, DNS cifrado (`dnscrypt-proxy`), randomización de MAC, script `hackos-torify-toggle` para enrutar todo el tráfico TCP por Tor a nivel sistema |
| `10-audit.sh` | `lynis`, `rkhunter`, `chkrootkit`, `aide` + auditoría semanal automática (`hackos-audit`) |
| `11-fastfetch.sh` | `fastfetch` con el **logo real de hackOS renderizado en ANSI truecolor**, se muestra al abrir cada terminal |
| `12-nomad.sh` | Instala Docker + [Project N.O.M.A.D](https://github.com/Crosstalk-Solutions/project-nomad) (Crosstalk-Solutions): "computadora de supervivencia offline" con panel web (Command Center) en `http://localhost:8080` — Kiwix, mapas offline, asistente IA local, apps instalables vía "Supply Depot" |
| `13-branding.sh` | Íconos hicolor del logo hackOS, tema de íconos **Papirus-Dark**, wallpapers en `/usr/share/backgrounds/hackos`, **boot splash Plymouth** (negro + logo + spinner) |
| `14-essentials.sh` | Lo que trae cualquier sistema operativo normal: **LibreOffice** (Writer/Calc/Impress), **Bluetooth** (bluez + blueman), herramientas WiFi + firmware, visor de PDF (`zathura`), reproductor multimedia (`mpv`), visor de imágenes (`viewnior`), calculadora, soporte NTFS/exFAT para discos externos, impresión (CUPS) |

## Notas técnicas importantes (léelas antes de instalar)

0. **⚠️ UFW puede cortarte el acceso remoto si instalás dentro de un
   contenedor (LXC/Docker/Proxmox CT)**: lo comprobamos nosotros mismos —
   correr `ufw --force enable` (el comando exacto de `01-base.sh`) dentro
   de un contenedor de pruebas tumbó por completo el acceso a esa sandbox,
   probablemente porque reescribe reglas de `iptables` que chocan con las
   que usa la capa de virtualización por fuera del contenedor. **En una VM
   completa (VirtualBox, KVM/QEMU, VMware, o metal real) esto no debería
   pasar** porque tenés tu propio kernel y namespace de red — pero si vas a
   instalar hackOS en un contenedor o en un servidor remoto por SSH, probá
   primero `ufw` en modo `--dry-run` o asegurate de tener acceso por
   consola/KVM antes de habilitarlo, no solo SSH.

1. **ly en modo Matrix**: `ly` es una interfaz de terminal (TUI), pero tiene
   soporte **nativo** para una animación de lluvia estilo Matrix
   (`animation = matrix` en su `config.ini`) — es justo lo que pediste, y es
   una función real de ly, no una simulación. Lo que sigue siendo cierto es
   que ly (por ser TUI) **no puede mostrar fotos ni un avatar circular real**
   — si en algún momento preferís eso en vez de Matrix, instalá
   `06b-regreet-avatar.sh` (greetd + regreet, GTK), que reemplaza a ly y sí
   soporta imágenes reales.
2. **`hackos-torify-toggle`** enruta el tráfico TCP de todo el sistema por
   Tor (similar en espíritu a una Whonix-Workstation), pero **no es
   equivalente a la arquitectura real de Whonix** (Gateway + Workstation en
   dos VMs separadas, que aísla la IP real incluso si la Workstation se
   compromete). Para anonimato serio de verdad, correr **Whonix en VMs** o
   usar **Tails** sigue siendo más robusto que torificar un sistema único.
   Esta distro te da las herramientas (Tor, DNS cifrado, MAC random,
   hardening) pero no reemplaza ese modelo de aislamiento por VMs.
3. **Kernel "hardened"**: Debian 13 stable no siempre tiene
   `linux-image-*-hardened` empaquetado en sus repos oficiales. El script
   lo intenta y si no está disponible, aplica **hardening por sysctl**
   (ASLR completo, `ptrace_scope`, restricción de `dmesg`/`kptr`, etc. —
   los mismos parámetros que usa Kicksecure) sobre el kernel estándar de
   Debian. Si querés un kernel realmente hardened (grsecurity-style),
   se puede compilar con el patchset de `linux-hardened` (Arch) portado a
   Debian, pero eso es trabajo adicional que no está en el script todavía.
4. **~700MB de RAM en reposo con IceWM**: es una meta realista con
   IceWM + picom + sakura/rofi/dunst livianos, pero depende del hardware,
   drivers de video y cuántos daemons de fondo tengas activos (NetworkManager,
   dnscrypt-proxy, Tor, etc. suman). Si necesitás bajar aún más, desactivá
   `dnscrypt-proxy` y usá `06b-ly-tui-fallback.sh` en vez de greetd/regreet.
5. **Project N.O.M.A.D pesa en recursos**: instala Docker Engine + el
   Command Center como servicio siempre activo. Eso choca directamente con
   el objetivo de "~700MB en reposo" — Docker por sí solo ya suma bastante
   RAM, y si después instalás apps del "Supply Depot" (mapas offline,
   modelos de IA locales, Kiwix) el disco usado puede crecer mucho (los
   mapas completos son 120GB+, aunque hay versiones regionales más chicas).
   Por eso lo dejé como módulo aparte y no dentro del set "base" — instalalo
   solo si de verdad lo vas a usar, o desactivá el servicio cuando no lo
   necesites (`sudo systemctl stop docker`).
6. **Boot splash Plymouth**: el script (`configs/plymouth/hackos.script`)
   está escrito siguiendo la sintaxis típica de temas Plymouth, pero **no lo
   pude probar en un boot real** desde acá — probá primero en una VM. Si algo
   no renderiza bien (por ejemplo el spinner), el logo y el fondo negro solos
   ya deberían andar, y podés simplificar el script quitando el bloque del
   spinner sin romper nada más.
7. **ProtonVPN y Mullvad Browser** dependen de que sus repos/paquetes
   oficiales no hayan cambiado de URL — el script tiene *fallbacks* que
   avisan si algo falla, en vez de romper toda la instalación.
8. **`14-essentials.sh` pesa bastante** (LibreOffice + CUPS son la parte
   más grande): si tu prioridad es el consumo mínimo, desmarcalo en el menú
   e instalá a mano solo lo que necesites — por ejemplo, si no vas a
   imprimir nunca, salteate CUPS (`sudo systemctl disable cups` después de
   instalar, o comentá esa parte del módulo antes de correrlo).
9. **dwm → cwm, xterm → sakura**: las primeras versiones de hackOS traían
   dwm (compilado desde fuente) y xterm. Los reemplazamos por pedido
   explícito: `cwm` (OpenBSD) ya viene empaquetado en Debian — no hay que
   compilar nada — y `sakura` da más opciones de theming que xterm.
   `cwm` es deliberadamente más minimalista que dwm: no tiene tags con
   nombre (solo grupos numerados 1-9) ni barra/tray propios, a diferencia
   de IceWM/JWM/i3.

## Identidad visual (branding)

- **Logo**: el logo real de hackOS (sombrero + espiral Debian, gradiente
  celeste→rosa) vive en `configs/branding/hackos-logo.png`, con variantes
  ya generadas en varios tamaños (`hackos-logo-16.png` … `hackos-logo-512.png`)
  y una versión circular (`hackos-logo-circle.png`) usada como avatar por
  defecto en `06b-regreet-avatar.sh`.
- **Paleta de marca**: extraída del logo real y disponible en
  `configs/branding/palette.sh` — negro `#0A0A0A`, rosa `#EA0057`, celeste
  `#2E9FDB`. Todos los temas (IceWM, JWM, cwm, i3, rofi, sakura, ly, regreet)
  usan esta misma paleta, así que todo se ve consistente sin importar qué
  WM elijas.
- **fastfetch**: usa `configs/fastfetch/hackos-logo-ansi.txt`, que es el
  logo real renderizado en ANSI truecolor (no un dibujo ASCII genérico) —
  se ve prácticamente como la imagen del logo dentro de la terminal.
- **Íconos**: `13-branding.sh` instala Papirus-Dark como tema de íconos del
  sistema y coloca el logo hackOS en las rutas estándar de `hicolor` para
  que aparezca en menús, rofi y la barra de tareas.
- **Wallpapers**: además de los que ya vienen (`configs/wallpapers/`,
  generados con la paleta de marca — incluye una variante `hackos-matrix.jpg`
  a tono con el login), `13-branding.sh` los deja también en
  `/usr/share/backgrounds/hackos/` como ruta estable a nivel sistema.
- **Boot splash**: tema Plymouth simple (`configs/plymouth/`) — fondo negro,
  logo centrado, spinner de puntos en rosa de marca. Se activa agregando
  `quiet splash` a GRUB (ya lo hace `01-base.sh`).
- **Referencia de estilo**: `configs/branding/inspiration-ml4w-reference.png`
  es la captura que nos pasaste (rice estilo ML4W/Hyprland) — quedó guardada
  como referencia de la estética general (esquinas redondeadas, paneles
  translúcidos, selector de wallpapers) que fuimos aplicando en los temas.

## Personalización rápida

- **Wallpapers**: poné imágenes en `/etc/hackos/theme/wallpapers/` (greeter)
  y en `~/Pictures/hackos-wallpapers/` (sesión). Se elige una al azar en
  cada arranque/login.
- **Avatar**: `hackos-set-avatar ~/Pictures/mi-foto.jpg` (la recorta en
  círculo automáticamente y la deja lista para el greeter).
- **Atajos**: todos los WM usan la misma convención —
  `Super+T` terminal, `Super+E` archivos, `Super+D` rofi, `Super+W` navegador,
  `Super+C` editor, `Super+Q`/`Super+Shift+Q` cerrar ventana/sesión.
- **Auditoría manual**: `sudo hackos-audit` (reporte en `/var/log/hackos-audit/`).
- **Torificación total**: `sudo hackos-torify-toggle on` / `off` / `status`.

## Estructura del repo

```
hackOS/
├── install.sh                 # instalador principal (menú whiptail)
├── lib/
│   └── common.sh               # logging, run_module, checks, browser placeholder
├── modules/                   # un script por componente, idempotentes
└── configs/
    ├── icewm/                 # preferences, keys, tema, startup
    ├── jwm/jwmrc
    ├── cwm/cwmrc                # validado con 'cwm -n' + man page oficial
    ├── i3/config, i3status.conf
    ├── sakura/sakura.conf        # terminal por defecto, claves confirmadas contra el binario real
    ├── picom/picom.conf           # compositor compartido por todos los WM
    ├── dunst/dunstrc                # notificaciones compartidas
    ├── ly/                     # config.ini (Matrix), regreet.toml, css
    ├── rofi/hackos.rasi
    ├── fastfetch/              # config.jsonc + logo ANSI real
    ├── branding/                # logo en todos los tamaños + paleta de marca
    ├── plymouth/               # boot splash: hackos.plymouth + hackos.script
    └── wallpapers/             # wallpapers de marca, listos para usar
```

## Roadmap sugerido (no implementado todavía)

- ISO instalable (Calamares/debootstrap) en vez de script post-instalación.
- Kernel realmente hardened compilado con patchset dedicado.
- Perfiles AppArmor específicos por app (LibreWolf, Tor Browser, etc.),
  al estilo Kicksecure.
- Integración de `sandbox-app-launcher` tipo Kicksecure para aislar apps
  individuales con `bubblewrap`/`firejail`.
