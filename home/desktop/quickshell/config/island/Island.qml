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
        left: root.expanded
        right: root.expanded
        bottom: root.expanded
    }

    margins {
        top: 2
    }

    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 28
    focusable: root.expanded
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Item {
        id: fullMask
        anchors.fill: parent
    }

    mask: Region {
        item: root.expanded ? fullMask : topZone
    }

    onExpandedChanged: {
        if (root.expanded)
            cardBox.forceActiveFocus();
    }

    // ---- Reloj 24h HH:MM ----
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    readonly property string timeText: Qt.formatDateTime(clock.date, "HH:mm")

    // ---- Media (MPRIS): primer reproductor en reproducción, si no el primero ----
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

    // ---- Estados ----
    readonly property bool expanded: IslandState.manualExpanded
    readonly property string currentView: IslandState.currentView
    readonly property bool isFullscreen: root.checkFullscreen()

    function checkFullscreen(): bool {
        try {
            if (!root.screen)
                return false;
            var mon = Hyprland.monitorFor(root.screen);
            if (!mon || !mon.activeWorkspace)
                return false;
            var tls = mon.activeWorkspace.toplevels;
            var arr = (tls && tls.values !== undefined) ? tls.values : tls;
            if (!arr)
                return false;
            for (var i = 0; i < arr.length; i++) {
                try {
                    if (arr[i] && arr[i].fullscreen)
                        return true;
                } catch (e) {}
            }
            return false;
        } catch (e) {
            return false;
        }
    }

    // Etiqueta del workspace activo (solo lectura, sin acción).
    function workspaceLabel(): string {
        try {
            if (!root.screen)
                return "–";
            var mon = Hyprland.monitorFor(root.screen);
            if (!mon || !mon.activeWorkspace)
                return "–";
            var ws = mon.activeWorkspace;
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

    // (IPC en IslandService: instancia única global).

    // Compacto: 26 (ws) + 6 + 110 (píldora) + 6 + 26 (power) = 174.
    // Expandido: fila superior + 8 + tarjeta 232.
    implicitWidth: root.expanded ? 548 : 174
    implicitHeight: root.expanded ? 266 : 26

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    // Fondo clicable fuera de la tarjeta: colapsa a píldora.
    MouseArea {
        id: outsideClick
        anchors.fill: parent
        visible: root.expanded
        acceptedButtons: Qt.LeftButton
        onClicked: IslandState.collapse()
    }

    // ---- Fila superior: círculo workspace + píldora + círculo power ----
    Item {
        id: topZone
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: topRow.implicitWidth
        height: 26

        RowLayout {
            id: topRow
            anchors.fill: parent
            spacing: 6

            // Círculo izquierdo: workspace actual, solo muestra, sin función.
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 13
                color: Theme.bgDock
                opacity: root.isFullscreen ? 0.55 : 1.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animFast
                        easing.type: Easing.OutCubic
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

            // Píldora central: reloj + indicador, clic expande/colapsa.
            Rectangle {
                id: pillBox
                Layout.preferredWidth: 80
                Layout.preferredHeight: 26
                radius: 13
                color: Theme.bgDock
                opacity: root.isFullscreen ? 0.55 : 1.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animFast
                        easing.type: Easing.OutCubic
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandState.toggleExpanded()
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

            // Círculo derecho: botón de power, abre el menú de energía.
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 13
                color: powerHover.containsMouse ? Theme.bgHover : Theme.bgDock
                opacity: root.isFullscreen ? 0.55 : 1.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animFast
                        easing.type: Easing.OutCubic
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
        }
    }

    // ---- Tarjeta extendida: franja lateral + panel de vista ----
    Rectangle {
        id: cardBox
        anchors.top: topZone.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: 548
        height: 232
        visible: root.expanded
        radius: Theme.radiusLarge
        color: Theme.bgDock
        clip: true
        opacity: root.isFullscreen ? 0.55 : 1.0
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape && root.expanded) {
                IslandState.collapse();
                event.accepted = true;
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
                easing.type: Easing.OutCubic
            }
        }

        // Clic dentro de la tarjeta no llega al fondo (no colapsa).
        MouseArea {
            anchors.fill: parent
            visible: root.expanded
            acceptedButtons: Qt.LeftButton
            onClicked: mouse => mouse.accepted = true
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0
            visible: root.expanded

            // Franja lateral oscura: selector de vistas.
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

            // Panel de la vista activa.
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                IslandMusicView {
                    anchors.fill: parent
                    anchors.margins: 14
                    visible: root.currentView === "music"
                    player: root.activePlayer
                    hasMedia: root.hasMedia
                }

                IslandNotifView {
                    anchors.fill: parent
                    anchors.margins: 14
                    visible: root.currentView === "notif"
                }

                IslandNetworkView {
                    anchors.fill: parent
                    anchors.margins: 14
                    visible: root.currentView === "network"
                }

                IslandSysmonView {
                    anchors.fill: parent
                    anchors.margins: 14
                    visible: root.currentView === "sysmon"
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
