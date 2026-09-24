import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../theme"

PanelWindow {
    id: root

    anchors {
        bottom: true
    }

    margins {
        bottom: 10
    }

    implicitHeight: 60
    implicitWidth: dockRow.implicitWidth + 24

    color: "transparent"
    visible: !reallyHidden

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0

    mask: Region {
        item: dockBox
    }

    property int iconSize: 38

    property string screenName: root.screen ? root.screen.name : ""
    property int windowCount: root.workspaceWindowCount()
    readonly property bool shouldShow: DockState.shouldShow(root.screenName, root.windowCount)
    property bool reallyHidden: true

    Timer {
        id: hideTimer
        interval: Theme.animDock
        repeat: false
        onTriggered: {
            if (!root.shouldShow)
                hideAnim.restart();
        }
    }

    onShouldShowChanged: {
        if (root.shouldShow) {
            hideAnim.stop();
            hideTimer.stop();
            root.reallyHidden = false;
        } else {
            hideTimer.restart();
        }
    }

    Component.onCompleted: {
        root.reallyHidden = !root.shouldShow;
    }

    onVisibleChanged: {
        if (visible)
            showAnim.restart();
    }

    ParallelAnimation {
        id: showAnim
        NumberAnimation {
            target: boxSlide
            property: "y"
            from: 24
            to: 0
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: dockBox
            property: "opacity"
            from: 0
            to: 1
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: hideAnim
        NumberAnimation {
            target: boxSlide
            property: "y"
            from: 0
            to: 24
            duration: Theme.animFast
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: dockBox
            property: "opacity"
            from: 1
            to: 0
            duration: Theme.animFast
            easing.type: Easing.InCubic
        }
        onFinished: {
            if (!root.shouldShow)
                root.reallyHidden = true;
        }
    }

    function workspaceWindowCount() {
        try {
            if (!root.screen)
                return 0;
            var mon = Hyprland.monitorFor(root.screen);
            if (!mon || !mon.activeWorkspace || !mon.activeWorkspace.toplevels)
                return 0;
            var tls = mon.activeWorkspace.toplevels;
            if (tls.count !== undefined)
                return tls.count;
            if (tls.values !== undefined)
                return tls.values.length;
            return tls.length || 0;
        } catch (e) {
            return 0;
        }
    }

    property var pinned: [
        { desktopId: "brave-origin", match: "brave", icon: "brave", exec: ["uwsm", "app", "--", "brave"], name: "Brave" },
        { desktopId: "librewolf", match: "librewolf", icon: "librewolf", exec: ["uwsm", "app", "--", "librewolf"], name: "LibreWolf" },
        { desktopId: "kitty", match: "kitty", icon: "kitty", exec: ["uwsm", "app", "--", "kitty"], name: "Kitty" },
        { desktopId: "org.gnome.Nautilus", match: "nautilus", icon: "org.gnome.Nautilus", exec: ["uwsm", "app", "--", "nautilus"], name: "Archivos" },
        { desktopId: "obsidian", match: "obsidian", icon: "obsidian", exec: ["uwsm", "app", "--", "obsidian"], name: "Obsidian" },
        { desktopId: "bitwarden", match: "bitwarden", icon: "bitwarden", exec: ["uwsm", "app", "--", "bitwarden"], name: "Bitwarden" },
        { desktopId: "papers", match: "papers", icon: "papers", exec: ["uwsm", "app", "--", "papers"], name: "Papers" }
    ]

    function lookupEntry(id) {
        var entry = DesktopEntries.byId(id);
        if (!entry)
            entry = DesktopEntries.heuristicLookup(id);
        return entry;
    }

    function allToplevels() {
        if (!Hyprland.toplevels)
            return [];
        if (Hyprland.toplevels.values !== undefined)
            return Hyprland.toplevels.values;
        return Hyprland.toplevels;
    }

    function appIdOf(tl) {
        try {
            return (tl && tl.wayland && tl.wayland.appId) ? String(tl.wayland.appId).toLowerCase() : "";
        } catch (e) {
            return "";
        }
    }

    function matchingToplevels(match) {
        var out = [];
        var tls = allToplevels();
        for (var i = 0; i < tls.length; i++) {
            if (appIdOf(tls[i]).indexOf(match) !== -1)
                out.push(tls[i]);
        }
        return out;
    }

    function taskIcon(tl) {
        var appId = "";
        try {
            appId = (tl && tl.wayland && tl.wayland.appId) ? String(tl.wayland.appId) : "";
        } catch (e) {
            appId = "";
        }
        if (appId !== "") {
            var entry = root.lookupEntry(appId);
            if (entry)
                return entry.icon;
        }
        return appId;
    }

    function taskLabel(tl) {
        try {
            if (tl && tl.title)
                return tl.title;
        } catch (e) {}
        return "Ventana";
    }

    // Fondo flotante centrado.
    Rectangle {
        id: dockBox
        anchors.fill: parent
        radius: Theme.radiusLarge
        color: Theme.bgDock

        transform: Translate {
            id: boxSlide
        }

        RowLayout {
            id: dockRow
            anchors.centerIn: parent
            spacing: 2

            // Lanzadores fijados.
            Repeater {
                model: root.pinned
                DockButton {
                    required property var modelData
                    iconSize: root.iconSize
                    iconName: {
                        var entry = root.lookupEntry(modelData.desktopId);
                        return entry ? entry.icon : modelData.icon;
                    }
                    tooltipText: modelData.name
                    running: root.matchingToplevels(modelData.match).length > 0
                    active: {
                        var tls = root.matchingToplevels(modelData.match);
                        for (var i = 0; i < tls.length; i++) {
                            try {
                                if (tls[i].activated)
                                    return true;
                            } catch (e) {}
                        }
                        return false;
                    }
                    onClicked: {
                        var tls = root.matchingToplevels(modelData.match);
                        if (tls.length > 0 && tls[0].wayland) {
                            tls[0].wayland.activate();
                        } else {
                            var entry = root.lookupEntry(modelData.desktopId);
                            if (entry)
                                entry.execute();
                            else
                                Quickshell.execDetached(modelData.exec);
                        }
                    }
                    onMiddleClicked: {
                        var tls = root.matchingToplevels(modelData.match);
                        if (tls.length > 0 && tls[0].wayland)
                            tls[0].wayland.close();
                    }
                }
            }

            // Tareas abiertas no fijadas.
            Repeater {
                model: Hyprland.toplevels
                DockButton {
                    required property var modelData
                    iconSize: root.iconSize
                    visible: {
                        var appId = "";
                        try {
                            appId = (modelData && modelData.wayland && modelData.wayland.appId) ? String(modelData.wayland.appId).toLowerCase() : "";
                        } catch (e) {}
                        if (appId === "")
                            return false;
                        for (var i = 0; i < root.pinned.length; i++) {
                            if (appId.indexOf(root.pinned[i].match) !== -1)
                                return false;
                        }
                        return true;
                    }
                    iconName: root.taskIcon(modelData)
                    tooltipText: root.taskLabel(modelData)
                    running: true
                    active: {
                        try {
                            return !!modelData.activated;
                        } catch (e) {
                            return false;
                        }
                    }
                    onClicked: {
                        try {
                            if (modelData.wayland)
                                modelData.wayland.activate();
                        } catch (e) {}
                    }
                    onMiddleClicked: {
                        try {
                            if (modelData.wayland)
                                modelData.wayland.close();
                        } catch (e) {}
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            onContainsMouseChanged: DockState.setDockHovered(root.screenName, containsMouse)
        }
    }
}
