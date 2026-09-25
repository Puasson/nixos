{ pkgs, ... }:

let
  wallpaper-set = pkgs.writeShellApplication {
    name = "wallpaper-set";
    runtimeInputs = with pkgs; [
      awww
      procps
      libnotify
      coreutils
      findutils
    ];
    text = ''
      WALL_DIR="$HOME/Pictures/Wallpaper"
      CACHE_DIR="$HOME/.cache/quickshell/wallpaper"
      CURRENT="$CACHE_DIR/current"

      ensure_daemon() {
        awww query >/dev/null 2>&1 && return 0
        RUNDIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

        if ! pgrep -f "[a]www-daemon" >/dev/null 2>&1; then
          rm -f "$RUNDIR"/wayland-*-awww-daemon.sock "$RUNDIR"/*-awww-daemon.sock 2>/dev/null || true
        fi

        awww-daemon >/dev/null 2>&1 & disown
        for _ in $(seq 1 80); do
          awww query >/dev/null 2>&1 && return 0
          sleep 0.1
        done
        return 1
      }

      apply() {
        ensure_daemon || return 1
        awww img --transition-type simple -- "$1"
      }

      show() {
        apply "$1"
      }

      persist() {
        mkdir -p "$CACHE_DIR"
        printf '%s' "$1" > "$CURRENT"
      }

      pick_random() {
        find "$WALL_DIR" -maxdepth 1 -type f \
          \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
             -o -iname '*.webp' -o -iname '*.gif' \) \
          | shuf -n 1
      }

      case "''${1:-}" in
        --preview)
          [ -f "$2" ] || exit 1
          show "$2"
          ;;
        --persist)
          [ -f "$2" ] || { notify-send -i dialog-error "Wallpaper" "Archivo no encontrado: $2"; exit 1; }
          show "$2"
          persist "$2"
          notify-send -i preferences-desktop-wallpaper "Wallpaper" "$(basename "$2")"
          ;;
        --restore)
          if [ -f "$CURRENT" ] && [ -f "$(cat "$CURRENT")" ]; then
            show "$(cat "$CURRENT")"
          else
            FALLBACK="$(pick_random)"
            [ -n "$FALLBACK" ] && { show "$FALLBACK"; persist "$FALLBACK"; }
          fi
          ;;
        --random)
          CHOICE="$(pick_random)"
          [ -n "$CHOICE" ] && { show "$CHOICE"; persist "$CHOICE"; notify-send -i preferences-desktop-wallpaper "Wallpaper aleatorio" "$(basename "$CHOICE")"; }
          ;;
        *)
          echo "Uso: wallpaper-set --preview|--persist FILE | --restore | --random" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  home.packages = with pkgs; [
    quickshell
    awww
    wallpaper-set
  ];

  home.file.".config/quickshell".source = ./config;
}
