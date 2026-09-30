import Quickshell
import QtQuick
import "dock" as DockModule
import "island" as IslandModule
import "launcher" as LauncherModule
import "powermenu" as PowerMenuModule
import "theme" as ThemeModule
import "stylemenu" as StyleMenuModule

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

        LauncherModule.LauncherCatcher {
            required property var modelData
            screen: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        IslandModule.IslandCatcher {
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

    LauncherModule.LauncherService {
    }

    PowerMenuModule.PowerMenu {
    }

    ThemeModule.ThemeService {
    }

    StyleMenuModule.StyleMenu {
    }
}
