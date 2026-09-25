import Quickshell
import QtQuick
import "dock" as DockModule
import "island" as IslandModule
import "launcher" as LauncherModule
import "powermenu" as PowerMenuModule
import "wallpaper" as WallpaperModule

ShellRoot {
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
