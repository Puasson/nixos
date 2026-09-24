// Entrypoint Quickshell: dock + tira de revelado por pantalla, isla superior,
// lanzador central-abajo + selector de wallpapers.
import Quickshell
import QtQuick
import "dock" as DockModule
import "island" as IslandModule
import "launcher" as LauncherModule
import "powermenu" as PowerMenuModule
import "wallpaper" as WallpaperModule

ShellRoot {
    // Un hijo por Variants: con varios hijos directos solo se instancia
    // uno (el resto se ignora en silencio) y el dock nunca aparecía.
    Variants {
        model: Quickshell.screens

        DockModule.Dock {
            required property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        DockModule.DockTrigger {
            required property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        IslandModule.Island {
            required property var modelData
            screen: modelData
        }
    }

    IslandModule.IslandService {
    }

    LauncherModule.Launcher {
    }

    PowerMenuModule.PowerMenu {
    }

    WallpaperModule.Wallpaper {
    }
}
