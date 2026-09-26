import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../theme"
import "../launcher" as LauncherModule

// Dock que SE TRANSFORMA en el lanzador (morph estilo isla dinámica):
// Super+A (LauncherMenu toggle) expande la píldora al panel de búsqueda.
// La fila de apps persiste abajo como franja de continuidad, igual que el
// header de 26px de la isla.
//
// La ventana LayerShell NUNCA cambia de tamaño: siempre mide lo del panel
// expandido (truco de Island.qml). El morph lo anima solo el rectángulo
// interior, sin frames negros ni tearing.
PanelWindow {
    id: root

    anchors {
        bottom: true
    }

    margins {
        bottom: 10
    }

    readonly property int panelW: 470
    readonly property int panelH: 480
    readonly property int compactH: 60
    readonly property int compactW: footerRow.implicitWidth + 24

    implicitWidth: Math.max(root.panelW, root.compactW)
    implicitHeight: root.panelH

    color: "transparent"
    visible: !reallyHidden

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    focusable: root.expanded
    WlrLayershell.keyboardFocus: root.expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
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
    // Con el lanzador abierto el dock no se auto-oculta nunca.
    readonly property bool expanded: LauncherModule.LauncherState.isOpen
    readonly property bool shouldShow: root.expanded || DockState.shouldShow(root.screenName, root.windowCount)
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

    // Foco diferido del buscador: el teclado Exclusive lo concede Hyprland de
    // forma asíncrona y searchZone aún anima su fade (animFast 150ms), así que
    // el forceActiveFocus síncrono se perdía y había que hacer click/hover.
    property int focusAttempts: 0
    Timer {
        id: focusTimer
        interval: 120
        repeat: false
        onTriggered: {
            if (!root.expanded)
                return;
            searchPanel.focusSearch();
            if (!searchPanel.searchHasFocus && root.focusAttempts < 3) {
                root.focusAttempts++;
                focusTimer.restart();
            }
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

    onExpandedChanged: {
        if (root.expanded) {
            hideAnim.stop();
            hideTimer.stop();
            root.reallyHidden = false;
            root.focusAttempts = 0;
            focusTimer.restart();
        } else if (!root.shouldShow) {
            focusTimer.stop();
            hideTimer.restart();
        } else {
            focusTimer.stop();
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

    // La píldora SE TRANSFORMA en el panel del lanzador: mismo Rectangle,
    // anima width/height con la curva de la isla (OutExpo 280ms).
    Rectangle {
        id: dockBox
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.expanded ? Math.max(root.panelW, root.compactW) : root.compactW
        height: root.expanded ? root.panelH : root.compactH
        radius: Theme.radiusLarge
        color: Theme.bgDock
        clip: true
        // Respaldo de teclado: si el foco cae fuera del TextInput (p. ej. tras
        // un click en la lista), las flechas/Enter/Esc siguen funcionando. Los
        // eventos aceptados por el TextInput no burbujean hasta aquí.
        focus: true
        Keys.onPressed: event => {
            if (!root.expanded)
                return;
            if (event.key === Qt.Key_Down) {
                LauncherModule.LauncherState.selected = Math.min(LauncherModule.LauncherState.selected + 1, LauncherModule.LauncherState.visibleResults.length - 1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                LauncherModule.LauncherState.selected = Math.max(LauncherModule.LauncherState.selected - 1, 0);
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                LauncherModule.LauncherState.launch(LauncherModule.LauncherState.visibleResults[LauncherModule.LauncherState.selected]);
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                LauncherModule.LauncherState.close();
                event.accepted = true;
            }
        }

        transform: Translate {
            id: boxSlide
        }

        Behavior on width {
            NumberAnimation {
                duration: Theme.animIsland
                easing.type: Theme.easeOut
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Theme.animIsland
                easing.type: Theme.easeOut
            }
        }

        // Zona de búsqueda: entra con fade + escala desde arriba (como
        // expandedLayer de la isla). La fila del dock persiste abajo como
        // franja de continuidad.
        Item {
            id: searchZone
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 12
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            height: root.panelH - root.compactH - 24
            opacity: root.expanded ? 1.0 : 0.0
            scale: root.expanded ? 1.0 : 0.95
            visible: opacity > 0.01
            transformOrigin: Item.Top

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Theme.easeOut
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Theme.easeOut
                }
            }

            LauncherModule.LauncherPanel {
                id: searchPanel
                anchors.fill: parent
            }
        }

        Item {
            id: footerZone
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: root.compactH

            RowLayout {
                id: footerRow
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

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    width: 1
                    height: 28
                    color: Qt.rgba(1, 1, 1, 0.1)
                }

                // Botón lanzador: alterna el morph (equivale a Super+A).
                // Queda resaltado en acento mientras el panel está abierto.
                Item {
                    width: 52
                    height: 48

                    Rectangle {
                        anchors.centerIn: parent
                        width: 40
                        height: 40
                        radius: 12
                        color: gridHover.containsMouse ? Theme.bgHover : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "apps"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 24
                        color: root.expanded ? Theme.accentBlue : Theme.textPrimary
                    }

                    MouseArea {
                        id: gridHover
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: LauncherModule.LauncherState.toggle()
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
