{ pkgs, lib, ... }:

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

  theme-apply = pkgs.writeShellApplication {
    name = "theme-apply";
    runtimeInputs = with pkgs; [
      dconf
      glib
      coreutils
    ];
    text = ''
      CACHE_DIR="$HOME/.cache/quickshell/theme"
      MODE_FILE="$CACHE_DIR/mode"
      NVIM_BG_FILE="$CACHE_DIR/nvim-background"
      NVIM_FLAVOUR_FILE="$CACHE_DIR/nvim-flavour"
      GTK3_INI="$HOME/.config/gtk-3.0/settings.ini"
      GTK4_INI="$HOME/.config/gtk-4.0/settings.ini"

      usage() {
        echo "Uso: theme-apply [FAMILIA] {dark|light} | theme-apply --cached" >&2
        exit 1
      }

      upsert_ini() {
        local file="$1" key="$2" value="$3"
        if [ -L "$file" ]; then
          return 0
        fi
        mkdir -p "$(dirname "$file")" || true
        if [ -e "$file" ] && [ ! -w "$file" ]; then
          chmod u+w "$file" || true
        fi
        if [ ! -f "$file" ]; then
          printf '[Settings]\n' > "$file" || true
        fi
        if ! grep -q "^\[Settings\]" "$file" 2>/dev/null; then
          {
            printf '[Settings]\n'
            cat "$file" 2>/dev/null
          } > "$file.tmp" && mv "$file.tmp" "$file" || true
        fi
        if grep -q "^$key=" "$file" 2>/dev/null; then
          sed -i "s|^$key=.*|$key=$value|" "$file" || true
        else
          printf '%s=%s\n' "$key" "$value" >> "$file" || true
        fi
      }

      apply_gtk() {
        local gtk_theme icon_theme prefer_dark
        if [ "$1" = "light" ]; then
          gtk_theme="adw-gtk3"
          icon_theme="WhiteSur-light"
          prefer_dark="false"
          dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'" 2>/dev/null || true
        else
          gtk_theme="adw-gtk3-dark"
          icon_theme="WhiteSur-dark"
          prefer_dark="true"
          dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'" 2>/dev/null || true
        fi
        gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme" 2>/dev/null || true
        gsettings set org.gnome.desktop.interface icon-theme "$icon_theme" 2>/dev/null || true
        for ini in "$GTK3_INI" "$GTK4_INI"; do
          upsert_ini "$ini" "gtk-theme-name" "$gtk_theme"
          upsert_ini "$ini" "gtk-icon-theme-name" "$icon_theme"
          upsert_ini "$ini" "gtk-application-prefer-dark-theme" "$prefer_dark"
        done
      }

      apply_nvim() {
        mkdir -p "$CACHE_DIR" || true
        if [ "$1" = "light" ]; then
          printf 'light' > "$NVIM_BG_FILE" || true
          printf 'latte' > "$NVIM_FLAVOUR_FILE" || true
        else
          printf 'dark' > "$NVIM_BG_FILE" || true
          printf 'mocha' > "$NVIM_FLAVOUR_FILE" || true
        fi
      }

      MODE=""
      if [ "''${1:-}" = "--cached" ]; then
        [ -f "$MODE_FILE" ] && MODE="$(cat "$MODE_FILE")" || MODE="dark"
      elif [ $# -eq 2 ]; then
        MODE="$2"
      elif [ $# -eq 1 ]; then
        MODE="$1"
      else
        usage
      fi

      [ "$MODE" = "dark" ] || [ "$MODE" = "light" ] || usage

      apply_gtk "$MODE"
      apply_nvim "$MODE"
    '';
  };

  theme-set = pkgs.writeShellApplication {
    name = "theme-set";
    runtimeInputs = with pkgs; [
      quickshell
      libnotify
      coreutils
      findutils
      wallpaper-set
      theme-apply
    ];
    text = ''
      FAMILIES="catppuccin nord gruvbox tokyonight dracula everforest kanagawa rosepine"
      CACHE_DIR="$HOME/.cache/quickshell/theme"
      FAMILY_FILE="$CACHE_DIR/family"
      MODE_FILE="$CACHE_DIR/mode"
      WALL_BASE="$HOME/Pictures/Wallpaper"

      cur_family() {
        if [ -f "$FAMILY_FILE" ]; then
          cat "$FAMILY_FILE"
        else
          printf 'catppuccin'
        fi
      }

      cur_mode() {
        if [ -f "$MODE_FILE" ]; then
          cat "$MODE_FILE"
        else
          printf 'dark'
        fi
      }

      valid_family() {
        case " $FAMILIES " in
          *" $1 "*) return 0 ;;
          *) return 1 ;;
        esac
      }

      next_family() {
        local cur="$1" first="" f found=0
        for f in $FAMILIES; do
          [ -z "$first" ] && first="$f"
          if [ "$found" -eq 1 ]; then
            printf '%s' "$f"
            return 0
          fi
          [ "$f" = "$cur" ] && found=1
        done
        printf '%s' "$first"
      }

      set_gtk() {
        theme-apply "$1" "$2" || true
      }

      set_qs() {
        mkdir -p "$CACHE_DIR" || true
        printf '%s' "$1" > "$FAMILY_FILE" || true
        printf '%s' "$2" > "$MODE_FILE" || true
        qs ipc call Theme setFamily "$1" >/dev/null 2>&1 || true
        qs ipc call Theme setMode "$2" >/dev/null 2>&1 || true
      }

      set_wallpaper() {
        local dir=""
        for d in "$WALL_BASE/$1/$2" "$WALL_BASE/$1" "$WALL_BASE"; do
          if [ -d "$d" ]; then
            dir="$d"
            break
          fi
        done
        [ -n "$dir" ] || return 0
        local img
        img="$(find "$dir" -maxdepth 1 -type f \
          \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
             -o -iname '*.webp' -o -iname '*.gif' \) \
          | shuf -n 1)" || true
        [ -n "$img" ] && wallpaper-set --persist "$img" >/dev/null 2>&1 || true
      }

      apply() {
        set_gtk "$1" "$2"
        set_qs "$1" "$2"
        set_wallpaper "$1" "$2"
        notify-send -i preferences-desktop-theme "Tema" "$1 · $2" || true
      }

      FAMILY="$(cur_family)"
      MODE="$(cur_mode)"
      WANT_FAMILY=""
      WANT_MODE=""
      ACTION=""

      while [ $# -gt 0 ]; do
        case "$1" in
          --family)
            WANT_FAMILY="$2"
            shift 2
            ;;
          --mode)
            WANT_MODE="$2"
            shift 2
            ;;
          --toggle) ACTION="toggle"; shift ;;
          --next) ACTION="next"; shift ;;
          --list) for f in $FAMILIES; do printf '%s\n' "$f"; done; exit 0 ;;
          --status) printf '%s %s\n' "$FAMILY" "$MODE"; exit 0 ;;
          *) echo "Uso: theme-set [--family F] [--mode dark|light] | --toggle | --next | --list | --status" >&2; exit 1 ;;
        esac
      done

      if [ "$ACTION" = "toggle" ]; then
        [ "$MODE" = "dark" ] && MODE="light" || MODE="dark"
      elif [ "$ACTION" = "next" ]; then
        FAMILY="$(next_family "$FAMILY")"
      fi
      [ -n "$WANT_FAMILY" ] && FAMILY="$WANT_FAMILY"
      [ -n "$WANT_MODE" ] && MODE="$WANT_MODE"

      valid_family "$FAMILY" || { echo "Familia desconocida: $FAMILY" >&2; exit 1; }
      [ "$MODE" = "dark" ] || [ "$MODE" = "light" ] || { echo "Modo desconocido: $MODE" >&2; exit 1; }

      apply "$FAMILY" "$MODE"
    '';
  };
in
{
  home.packages = with pkgs; [
    quickshell
    awww
    wallpaper-set
    theme-apply
    theme-set
  ];

  home.activation.themeApplyCached =
    lib.hm.dag.entryAfter
      [
        "writeBoundary"
        "linkGeneration"
        "dconfSettings"
        "installPackages"
      ]
      ''
        $DRY_RUN_CMD ${theme-apply}/bin/theme-apply --cached 2>/dev/null || true
      '';

  home.file.".config/quickshell".source = ./config;
}
