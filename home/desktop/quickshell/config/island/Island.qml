import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../theme"
import "../powermenu"

PanelWindow {
    id: root

    anchors {
        top: true
    }

    margins {
        top: 2
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 28
    focusable: root.expanded
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: root.expanded ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-island"

    // La mascara sigue al contenido animado (topZone), no al booleano
    // expanded: asi la region de input acompana al morph sin saltos.
    mask: Region {
        item: topZone
    }

    // Foco diferido: el teclado Exclusive lo concede Hyprland de forma
    // asíncrona y expandedLayer aún anima su fade, así que el
    // forceActiveFocus síncrono se perdía y Esc no funcionaba sin click.
    property int focusAttempts: 0
    Timer {
        id: focusTimer
        interval: 120
        repeat: false
        onTriggered: {
            if (!root.expanded)
                return;
            islandBody.forceActiveFocus();
            if (!islandBody.activeFocus && root.focusAttempts < 3) {
                root.focusAttempts++;
                focusTimer.restart();
            }
        }
    }

    onExpandedChanged: {
        if (root.expanded) {
            root.expandedFrom = Hyprland.activeToplevel;
            root.focusAttempts = 0;
            focusTimer.restart();
        } else {
            focusTimer.stop();
        }
    }

    // Click fuera sobre una ventana: al enfocar otra app la isla se contrae.
    // Se ignora null porque el foco Exclusive de la propia isla puede
    // reportar activeToplevel null al expandir (evita auto-colapso).
    // Los clicks sobre el escritorio vacío los atrapa IslandCatcher.
    property var expandedFrom: null

    Connections {
        target: Hyprland
        function onActiveToplevelChanged(): void {
            if (!root.expanded)
                return;
            var cur = Hyprland.activeToplevel;
            if (cur && cur !== root.expandedFrom)
                IslandState.collapse();
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    readonly property string timeText: Qt.formatDateTime(clock.date, "HH:mm")

    readonly property var mprisValues: Mpris.players.values
    readonly property var activePlayer: {
        var vals = root.mprisValues;
        if (!vals || vals.length === 0)
            return null;
        for (var i = 0; i < vals.length; i++) {
            try {
                if (vals[i] && vals[i].isPlaying)
                    return vals[i];
            } catch (e) {}
        }
        return vals[0];
    }
    readonly property bool hasMedia: {
        try {
            return !!(root.activePlayer && root.activePlayer.trackTitle);
        } catch (e) {
            return false;
        }
    }
    readonly property bool isPlaying: {
        try {
            return !!(root.activePlayer && root.activePlayer.isPlaying);
        } catch (e) {
            return false;
        }
    }

    readonly property bool expanded: IslandState.manualExpanded
    readonly property string currentView: IslandState.currentView

    // Bindings reactivos: al referenciar las propiedades de Hyprland dentro
    // del binding, QML se re-suscribe a sus señales. Antes checkFullscreen()
    // y workspaceLabel() eran funciones puras llamadas una vez (sin
    // dependencia reactiva) y nunca se actualizaban.
    readonly property var activeMonitor: Hyprland.monitorFor(root.screen)
    readonly property var activeWs: root.activeMonitor ? root.activeMonitor.activeWorkspace : null
    readonly property var wsToplevels: {
        try {
            var tls = root.activeWs ? root.activeWs.toplevels : null;
            if (!tls)
                return [];
            if (tls.values !== undefined)
                return tls.values;
            return tls;
        } catch (e) {
            return [];
        }
    }
    readonly property bool isFullscreen: {
        try {
            var arr = root.wsToplevels;
            for (var i = 0; i < arr.length; i++) {
                try {
                    if (arr[i] && arr[i].fullscreen)
                        return true;
                } catch (e2) {}
            }
            return false;
        } catch (e) {
            return false;
        }
    }

    // Geometría del morph: la píldora central (80x26) crece al panel (548x266).
    // El alto total 266 = 26 (header) + 8 (separador) + 232 (contenido),
    // conserva la altura total anterior (26 + 8 + 232) para no mover exclusiveZone.
    readonly property int pillW: 80
    readonly property int pillH: 26
    readonly property int panelW: 548
    readonly property int panelH: 266
    readonly property int side: 26
    readonly property int gap: 6

    function workspaceLabel(): string {
        try {
            var ws = root.activeWs;
            if (!ws)
                return "–";
            if (ws.id !== undefined && ws.id !== null) {
                var num = Number(ws.id);
                if (!isNaN(num) && num > 0)
                    return String(num);
            }
            if (ws.name)
                return String(ws.name);
            return "–";
        } catch (e) {
            return "–";
        }
    }

    // La ventana LayerShell NUNCA cambia de tamano: siempre mide lo del
    // panel expandido. Antes saltaba de 144x26 a 612x266 en 1 frame y
    // las regiones recien ampliadas se mostraban en negro varios frames
    // (fotos 1.png/3.png). El morph lo anima solo el rectangulo interior.
    readonly property int fullW: root.panelW + (root.side + root.gap) * 2
    implicitWidth: root.fullW
    implicitHeight: root.panelH

    MouseArea {
        id: outsideClick
        anchors.fill: parent
        visible: root.expanded
        acceptedButtons: Qt.LeftButton
        onClicked: IslandState.collapse()
    }

    Item {
        id: topZone
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.expanded ? (root.panelW + (root.side + root.gap) * 2) : (root.pillW + (root.side + root.gap) * 2)
        height: root.expanded ? root.panelH : root.pillH

        // Respaldo de teclado: si el foco cae en un hijo en vez de islandBody,
        // Esc sigue colapsando. Lo aceptado por islandBody no burbujea aquí.
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape && root.expanded) {
                IslandState.collapse();
                event.accepted = true;
            }
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

        // Círculo lateral izquierdo: workspace. Queda en la esquina exterior,
        // se desliza hacia fuera al crecer topZone pero siempre visible.
        Rectangle {
            id: wsCircle
            anchors.left: parent.left
            anchors.top: parent.top
            width: root.side
            height: root.side
            radius: root.side / 2
            color: Theme.bgDock
            opacity: root.isFullscreen ? 0.55 : 1.0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Theme.easeHide
                }
            }

            Text {
                anchors.centerIn: parent
                text: root.workspaceLabel()
                font.pixelSize: 13
                font.bold: true
                color: Theme.textPrimary
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Círculo lateral derecho: power. Igual que workspace.
        Rectangle {
            id: powerCircle
            anchors.right: parent.right
            anchors.top: parent.top
            width: root.side
            height: root.side
            radius: root.side / 2
            color: powerHover.containsMouse ? Theme.bgHover : Theme.bgDock
            opacity: root.isFullscreen ? 0.55 : 1.0

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Theme.easeHide
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.animFast
                }
            }

            Text {
                anchors.centerIn: parent
                text: "power_settings_new"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 14
                color: Theme.textPrimary
            }

            MouseArea {
                id: powerHover
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: PowerState.toggle()
            }
        }

        // La píldora del medio SE TRANSFORMA en el panel extendido:
        // mismo Rectangle, anima width 80->548, height 26->266, radius 13->16.
        Rectangle {
            id: islandBody
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.expanded ? root.panelW : root.pillW
            height: root.expanded ? root.panelH : root.pillH
            radius: root.expanded ? Theme.radiusLarge : root.pillH / 2
            color: Theme.bgDock
            clip: true
            opacity: root.isFullscreen ? 0.55 : 1.0
            focus: true

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
            Behavior on radius {
                NumberAnimation {
                    duration: Theme.animIsland
                    easing.type: Theme.easeOut
                }
            }
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animFast
                    easing.type: Theme.easeHide
                }
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape && root.expanded) {
                    IslandState.collapse();
                    event.accepted = true;
                }
            }

            // Click en zona compacta: expandir. En expandido el fondo bloquea
            // clicks hacia fuera (el outsideClick de la ventana colapsa).
            MouseArea {
                id: pillToggle
                anchors.fill: parent
                visible: !root.expanded
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: IslandState.toggleExpanded()
            }
            MouseArea {
                anchors.fill: parent
                visible: root.expanded
                acceptedButtons: Qt.LeftButton
                onClicked: mouse => mouse.accepted = true
            }

            // Capa compacta: hora + indicadores. Crossfade + escala al expandir.
            Item {
                id: compactLayer
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: root.pillW
                height: root.pillH
                opacity: root.expanded ? 0.0 : 1.0
                scale: root.expanded ? 0.8 : 1.0
                visible: opacity > 0.01
                transformOrigin: Item.Center

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animFast
                        easing.type: Theme.easeHide
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.animFast
                        easing.type: Theme.easeHide
                    }
                }

                RowLayout {
                    id: compactRow
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        visible: root.isPlaying
                        text: "graphic_eq"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: Theme.accentGreen
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        visible: !root.isPlaying && IslandState.notifUnread
                        text: "notifications"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: Theme.badgeRed
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: root.timeText
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Capa expandida: header (misma franja de 26px de la píldora) +
            // contenido 232px. Entra con fade + escala 0.95->1.
            Item {
                id: expandedLayer
                anchors.fill: parent
                opacity: root.expanded ? 1.0 : 0.0
                scale: root.expanded ? 1.0 : 0.95
                visible: opacity > 0.01
                transformOrigin: Item.Top

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animFast
                        easing.type: Theme.easeHide
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.animFast
                        easing.type: Theme.easeHide
                    }
                }

                // Header: ocupa la franja de la píldora original, da continuidad.
                // Click colapsa (la píldora "vuelve").
                Item {
                    id: expandedHeader
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: root.pillH

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandState.collapse()
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "expand_less"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 18
                        color: Theme.textMuted
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.timeText
                        font.pixelSize: 13
                        font.bold: true
                        color: Theme.textPrimary
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        visible: root.isPlaying
                        text: "graphic_eq"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: Theme.accentGreen
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !root.isPlaying && IslandState.notifUnread
                        text: "notifications"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: Theme.badgeRed
                    }
                }

                Rectangle {
                    anchors.top: expandedHeader.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                RowLayout {
                    anchors.top: expandedHeader.bottom
                    anchors.topMargin: 8
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    spacing: 0

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 64
                        Layout.fillWidth: false
                        color: Theme.islandSide
                        radius: Theme.radiusLarge

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.topMargin: 8
                            anchors.bottomMargin: 8
                            spacing: 4

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }

                            IslandSideButton {
                                icon: "calendar_month"
                                active: root.currentView === "calendar"
                                onClicked: IslandState.setView("calendar")
                            }

                            IslandSideButton {
                                icon: "music_note"
                                active: root.currentView === "music"
                                onClicked: IslandState.setView("music")
                            }

                            IslandSideButton {
                                icon: "notifications"
                                active: root.currentView === "notif"
                                badge: IslandState.notifUnread
                                onClicked: IslandState.setView("notif")
                            }

                            IslandSideButton {
                                icon: "memory"
                                active: root.currentView === "sysmon"
                                onClicked: IslandState.setView("sysmon")
                            }

                            IslandSideButton {
                                icon: "wifi"
                                active: root.currentView === "network"
                                onClicked: IslandState.setView("network")
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Vistas pesadas (timers, canvas, imágenes, Networking)
                        // solo se instancian cuando están visibles. Antes las 5
                        // vivían siempre: 1s Timer de música + 5s Timer de red
                        // + 3 canvas repintando cada 2s aunque el panel
                        // estuviera colapsado. Loader activo = LazyLoader de
                        // la guía de Quickshell (carga diferida, ahorra memoria
                        // y evita trabajo en background).
                        Loader {
                            anchors.fill: parent
                            anchors.margins: 14
                            active: root.expanded && root.currentView === "music"
                            sourceComponent: musicComp
                        }
                        Component {
                            id: musicComp
                            IslandMusicView {
                                player: root.activePlayer
                                hasMedia: root.hasMedia
                            }
                        }

                        IslandNotifView {
                            anchors.fill: parent
                            anchors.margins: 14
                            visible: root.currentView === "notif"
                        }

                        Loader {
                            anchors.fill: parent
                            anchors.margins: 14
                            active: root.expanded && root.currentView === "network"
                            sourceComponent: networkComp
                        }
                        Component {
                            id: networkComp
                            IslandNetworkView {
                            }
                        }

                        Loader {
                            anchors.fill: parent
                            anchors.margins: 14
                            active: root.expanded && root.currentView === "sysmon"
                            sourceComponent: sysmonComp
                        }
                        Component {
                            id: sysmonComp
                            IslandSysmonView {
                            }
                        }

                        IslandCalendarView {
                            anchors.fill: parent
                            anchors.margins: 14
                            visible: root.currentView === "calendar"
                            baseDate: clock.date
                        }
                    }
                }
            }
        }
    }
}
