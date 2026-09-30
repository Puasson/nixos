hl.window_rule({ match = { class = "^(dev.zed.Zed|Zed|zeditor|zed)$" }, workspace = "2 silent" })
hl.window_rule({ match = { class = "^(org.gnome.Papers|papers|Paper)$" }, workspace = "3 silent" })
hl.window_rule({ match = { class = "^(obsidian|Obsidian)$" }, workspace = "3 silent" })
hl.window_rule({
	match = { class = "^(onlyoffice-desktopeditors|DesktopEditors|ONLYOFFICE.*)$" },
	workspace = "3 silent",
})
-- media / misc (opcional, no estorba)
hl.window_rule({ match = { class = "^(Spotify|spotify)$" }, workspace = "9 silent" })
-- tauon: solo flotante (ver sección B), sin workspace fijo
hl.window_rule({ match = { class = "^(com.obsproject.Studio|obs)$" }, workspace = "6 silent" })

-- B. Flotantes + centrar (diálogos / utilidades)
hl.window_rule({
	match = { class = "^(org.pulseaudio.pavucontrol|pavucontrol|Pavucontrol)$" },
	float = true,
	center = true,
	size = { 800, 600 },
})
hl.window_rule({
	match = { class = "^(org.gnome.Calculator|gnome-calculator)$" },
	float = true,
	center = true,
	size = { 360, 500 },
})
hl.window_rule({
	match = { class = "^(nm-connection-editor|nm-applet|blueman-manager|.*blueman-manager-wrapped.*)$" },
	float = true,
	center = true,
})
hl.window_rule({
	match = { class = "^(polkit-gnome-authentication-agent-1|hyprpolkitagent|.*hyprpolkitagent-wrapped.*)$" },
	float = true,
	center = true,
	stay_focused = true,
})
hl.window_rule({ match = { modal = true }, float = true, center = true })
hl.window_rule({
	match = { class = "^xdg-desktop-portal-gtk$" },
	float = true,
	center = true,
})
-- Brave PiP (el título cambia tras crear la ventana: solo funciona si el PiP nace ya con ese título)
hl.window_rule({
	match = { class = "^(brave-browser|brave|Brave-browser|brave-origin)$", title = ".*[Pp]icture.[Ii]n.[Pp]icture.*" },
	float = true,
	pin = true,
	size = { 480, 270 },
})
-- mpv flotante pequeño tipo PiP
hl.window_rule({
	match = { class = "^(mpv|Mpv)$", title = ".*[Pp]icture.[Ii]n.[Pp]icture.*" },
	float = true,
	pin = true,
})
-- pinentry nunca debe perder foco
hl.window_rule({ match = { class = "^pinentry-.*$" }, stay_focused = true })

-- D. idle inhibit (no suspender / no apagar pantalla)
hl.window_rule({ match = { class = "^(mpv|Mpv)$" }, idle_inhibit = "focus" })
hl.window_rule({ match = { class = "^(brave-browser|brave|Brave-browser|brave-origin)$" }, idle_inhibit = "fullscreen" })
hl.window_rule({ match = { class = "^(com.obsproject.Studio|obs)$" }, idle_inhibit = "fullscreen" })
hl.window_rule({ match = { class = "^(Spotify|spotify|tauon|Tauon.*|Audacity|audacity)$" }, idle_inhibit = "focus" })
