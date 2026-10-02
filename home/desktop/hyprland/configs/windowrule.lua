hl.window_rule({ match = { class = "^(obsidian|Obsidian)$" }, workspace = "3 silent" })
hl.window_rule({ match = { class = "^(Spotify|spotify)$" }, workspace = "9 silent" })
hl.window_rule({ match = { class = "^(com.obsproject.Studio|obs)$" }, workspace = "6 silent" })

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
-- pinentry nunca debe perder foco
hl.window_rule({ match = { class = "^pinentry-.*$" }, stay_focused = true })
