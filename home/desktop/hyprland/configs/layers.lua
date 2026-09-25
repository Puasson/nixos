-- Reglas de capa para la shell Quickshell.
-- Las animaciones las dirige QML (morph de la isla, show/hide del dock);
-- si el compositor tambien anima la layer (p. ej. animate_manual_resizes
-- ante un resize brusco, o fade al mapear), aparecen restos negros y
-- tearing durante la expansion. Por eso se desactiva la animacion del
-- compositor en todas las layers de la shell.
-- Los namespaces se definen en cada PanelWindow (WlrLayershell.namespace).
hl.layer_rule({ name = "qs-noanim-island", match = { namespace = "^quickshell-island$" }, no_anim = true })
hl.layer_rule({ name = "qs-noanim-dock", match = { namespace = "^quickshell-dock$" }, no_anim = true })
hl.layer_rule({ name = "qs-noanim-dock-trigger", match = { namespace = "^quickshell-dock-trigger$" }, no_anim = true })
hl.layer_rule({ name = "qs-noanim-launcher", match = { namespace = "^quickshell-launcher$" }, no_anim = true })
hl.layer_rule({ name = "qs-noanim-powermenu", match = { namespace = "^quickshell-powermenu$" }, no_anim = true })
hl.layer_rule({ name = "qs-noanim-wallpaper", match = { namespace = "^quickshell-wallpaper$" }, no_anim = true })
