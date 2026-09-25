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
    WlrLayershell.namespace: "quickshell-dock"

    mask: Region {
        item: dockBox
    }

    property int iconSize: 38

    property string screenName: root.screen ? root.screen.name : ""
    // Conteo reactivo: al referenciar monitor/workspace/toplevels en el
    // binding, QML se reevalúa con cada cambio. Antes era una llamada a
    // función pura (workspaceWindowCount) sin dependencias y quedaba fijo.
    readonly property var activeMonitor: Hyprland.monitorFor(root.screen)
    readonly property var tlsArray: {
        try {
            if (!Hyprland.toplevels)
                return [];
            if (Hyprland.toplevels.values !== undefined)
                return Hyprland.toplevels.values;
            return Hyprland.toplevels;
        } catch (e) {
            return [];
        }
    }
    readonly property int windowCount: {
        try {
            if (!root.activeMonitor || !root.activeMonitor.activeWorkspace)
                return 0;
            var tls = root.activeMonitor.activeWorkspace.toplevels;
            if (!tls)
                return 0;
            if (tls.count !== undefined)
                return tls.count;
            if (tls.values !== undefined)
                return tls.values.length;
            return tls.length || 0;
        } catch (e) {
            return 0;
        }
    }
    readonly property bool shouldShow: DockState.shouldShow(root.screenName, root.windowCount)
    property bool reallyHidden: true
    // Retardo antes de ocultar al salir el ratón (evita parpadeo al pasar
    // entre dock y borde). Antes reutilizaba animDock como intervalo.
    readonly property int hideDelay: 350

    Timer {
        id: hideTimer
        interval: root.hideDelay
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
            easing.type: Theme.easeOut
        }
        NumberAnimation {
            target: dockBox
            property: "opacity"
            from: 0
            to: 1
            duration: Theme.animNormal
            easing.type: Theme.easeOut
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
            easing.type: Theme.easeHide
        }
        NumberAnimation {
            target: dockBox
            property: "opacity"
            from: 1
            to: 0
            duration: Theme.animFast
            easing.type: Theme.easeHide
        }
        onFinished: {
            if (!root.shouldShow)
                root.reallyHidden = true;
        }
    }

    // Apps fijadas: se declaran en DockApps.qml (una línea por desktopId).
    // Todo lo demás (icono, nombre, match, lanzamiento) se deriva solo.
    property var pinned: DockApps.apps

    function lookupEntry(id) {
        var entry = DesktopEntries.byId(id);
        if (!entry)
            entry = DesktopEntries.heuristicLookup(id);
        return entry;
    }

    function pinnedIcon(id) {
        var entry = root.lookupEntry(id);
        return entry ? entry.icon : String(id);
    }

    function pinnedName(id) {
        var entry = root.lookupEntry(id);
        return entry ? entry.name : String(id);
    }

    function launchPinned(id) {
        var entry = root.lookupEntry(id);
        if (entry)
            entry.execute();
        else
            Quickshell.execDetached(["uwsm", "app", "--", String(id)]);
    }

    // "brave-origin" debe coincidir con appId "brave-browser", y
    // "org.gnome.Nautilus" con "org.gnome.nautilus": comparación
    // bidireccional + por tokens para no exigir el match exacto.
    function pinnedMatches(appIdLower, pinnedId) {
        var p = String(pinnedId).toLowerCase();
        if (p === "" || appIdLower === "")
            return false;
        if (appIdLower.indexOf(p) !== -1 || p.indexOf(appIdLower) !== -1)
            return true;
        var tokens = p.split(/[^a-z0-9]+/);
        for (var i = 0; i < tokens.length; i++) {
            if (tokens[i].length >= 3 && appIdLower.indexOf(tokens[i]) !== -1)
                return true;
        }
        return false;
    }

    function allToplevels() {
        return root.tlsArray;
    }

    // Cache de matches por app fijada: se calcula UNA vez por cambio de
    // toplevels en vez de N veces (una por botón × una por propiedad
    // running/active/click). Antes cada delegado llamaba a
    // matchingToplevels() en cada binding => O(pinned × tls) en JS por
    // cada actualización.
    readonly property var matchCache: {
        var c = {};
        try {
            var tls = root.tlsArray;
            for (var p = 0; p < root.pinned.length; p++) {
                var pid = String(root.pinned[p]);
                var out = [];
                for (var i = 0; i < tls.length; i++) {
                    if (pinnedMatches(appIdOf(tls[i]), pid))
                        out.push(tls[i]);
                }
                c[pid] = out;
            }
        } catch (e) {}
        return c;
    }

    function appIdOf(tl) {
        try {
            return (tl && tl.wayland && tl.wayland.appId) ? String(tl.wayland.appId).toLowerCase() : "";
        } catch (e) {
            return "";
        }
    }

    function matchingToplevels(pinnedId) {
        try {
            var hit = root.matchCache[String(pinnedId)];
            return hit ? hit : [];
        } catch (e) {
            return [];
        }
    }

    function isPinnedAppId(appIdLower) {
        for (var i = 0; i < root.pinned.length; i++) {
            if (pinnedMatches(appIdLower, root.pinned[i]))
                return true;
        }
        return false;
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

            Repeater {
                model: root.pinned
                DockButton {
                    required property var modelData
                    iconSize: root.iconSize
                    iconName: root.pinnedIcon(modelData)
                    tooltipText: root.pinnedName(modelData)
                    running: root.matchingToplevels(modelData).length > 0
                    active: {
                        var tls = root.matchingToplevels(modelData);
                        for (var i = 0; i < tls.length; i++) {
                            try {
                                if (tls[i].activated)
                                    return true;
                            } catch (e) {}
                        }
                        return false;
                    }
                    onClicked: {
                        var tls = root.matchingToplevels(modelData);
                        if (tls.length > 0 && tls[0].wayland) {
                            tls[0].wayland.activate();
                        } else {
                            root.launchPinned(modelData);
                        }
                    }
                    onMiddleClicked: {
                        var tls = root.matchingToplevels(modelData);
                        if (tls.length > 0 && tls[0].wayland)
                            tls[0].wayland.close();
                    }
                }
            }

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
                        return !root.isPinnedAppId(appId);
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
