{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wayscriber
  ];

  home.file.".config/wayscriber/config.toml".text = ''
    # Perfil orientado a presentar/enseñar: baja latencia, presets y
    # persistencia de sesión activas. Todo es opcional; borrar para defaults.

    [performance]
    buffer_count = 3
    enable_vsync = false
    max_fps_no_vsync = 144
    ui_animation_fps = 60

    [ui]
    theme = "dark"
    reduced_motion = "auto"
    status_bar_interactive = true

    [ui.toolbar]
    layout_mode = "regular" # simple | regular | advanced
    side_layout = "pill" # pill (actual) | panel (legacy)
    top_display_mode = "full" # full | micro
    show_presets = true
    show_zoom_actions = true
    show_tool_preview = false

    [drawing]
    default_color = "red"
    default_thickness = 3.0
    polygon_sides = 5

    [presets]
    slot_count = 5

    [presets.slot_1]
    name = "Rojo fino"
    tool = "pen"
    color = "red"
    size = 3.0

    [presets.slot_2]
    name = "Amarillo marcador"
    tool = "marker"
    color = "yellow"
    size = 8.0

    [presets.slot_3]
    name = "Azul flecha"
    tool = "arrow"
    color = "blue"
    size = 3.0

    [session]
    persist_transparent = true
    persist_history = true
    restore_tool_state = true
    per_output = true
    storage = "auto"
    max_file_size_mb = 50
  '';
}
