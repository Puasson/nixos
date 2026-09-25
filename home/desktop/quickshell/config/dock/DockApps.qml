pragma Singleton
import Quickshell
import QtQuick

// Lista de apps fijadas al dock.
// AÑADIR UN PROGRAMA = añadir una línea con su desktopId, nada más.
// El icono, nombre y lanzamiento se resuelven solos vía DesktopEntries.
//
// Cómo averiguar el desktopId:
//   ls /run/current-system/sw/share/applications/ ~/.nix-profile/share/applications/
//   o abre el Launcher (Super+Espacio) y busca la app.
// Ejemplos: "kitty", "brave-origin", "org.gnome.Nautilus", "gimp"
QtObject {
    property var apps: [
        "brave-origin",
        "audacity",
        "kitty",
        "org.gnome.Nautilus",
        "obsidian",
        "gimp",
        "papers"
    ]
}
