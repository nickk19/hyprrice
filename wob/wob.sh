#!/bin/sh

# Utilizza la variabile esportata da Hyprland o definisce un fallback
WOBSOCK="${WOBSOCK:-$XDG_RUNTIME_DIR/wob.sock}"

# Verifica l'esistenza della pipe, altrimenti la crea
[ -p "$WOBSOCK" ] || mkfifo "$WOBSOCK"

case "$1" in
    vol_up)
        wpctl set-volume @DEFAULT_SINK@ 5%+
        wpctl get-volume @DEFAULT_SINK@ | awk '{print int($2 * 100)}' > "$WOBSOCK"
        ;;
    vol_down)
        wpctl set-volume @DEFAULT_SINK@ 5%-
        wpctl get-volume @DEFAULT_SINK@ | awk '{print int($2 * 100)}' > "$WOBSOCK"
        ;;
    vol_mute)
        wpctl set-mute @DEFAULT_SINK@ toggle
        # Verifica lo stato di muto in modo POSIX-compliant
        if wpctl get-volume @DEFAULT_SINK@ | grep -q '\[MUTED\]'; then
            echo 0 > "$WOBSOCK"
        else
            wpctl get-volume @DEFAULT_SINK@ | awk '{print int($2 * 100)}' > "$WOBSOCK"
        fi
        ;;
    mic_mute)
        wpctl set-mute @DEFAULT_SOURCE@ toggle
        if wpctl get-volume @DEFAULT_SOURCE@ | grep -q '\[MUTED\]'; then
            echo 0 > "$WOBSOCK"
        else
            wpctl get-volume @DEFAULT_SOURCE@ | awk '{print int($2 * 100)}' > "$WOBSOCK"
        fi
        ;;
    bri_up)
        brightnessctl set 5%+ | sed -En 's/.*\(([0-9]+)%\).*/\1/p' > "$WOBSOCK"
        ;;
    bri_down)
        brightnessctl set 5%- | sed -En 's/.*\(([0-9]+)%\).*/\1/p' > "$WOBSOCK"
        ;;
    *)
        echo "Utilizzo: $0 {vol_up|vol_down|vol_mute|mic_mute|bri_up|bri_down}"
        exit 1
        ;;
esac
