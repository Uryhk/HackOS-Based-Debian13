#!/bin/sh
# hackOS :: barra de estado liviana para dwm (sin dependencias pesadas)

while true; do
    VOL=$(amixer get Master 2>/dev/null | grep -o '[0-9]*%' | head -1)
    BAT=""
    if [ -d /sys/class/power_supply/BAT0 ]; then
        BAT=" 🔋$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)%"
    fi
    MEM=$(free -m | awk '/Mem:/ {printf "%dMB", $3}')
    DATE=$(date '+%a %d/%m %H:%M')

    xsetroot -name " Vol:${VOL:-N/A}  RAM:${MEM}${BAT}  ${DATE} "
    sleep 5
done
