// Vista de red según ref 1.png: cabecera Network + close,
// tarjeta Current Connection (iface + IP + desconectar) y
// tarjeta Wi-Fi (rescan + toggle + lista / "No networks in range").
import Quickshell.Networking
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    // ---- Dispositivos ----
    readonly property var deviceList: {
        try {
            var devs = Networking.devices ? Networking.devices.values : [];
            return devs || [];
        } catch (e) {
            return [];
        }
    }

    // Activa: primera conectada que no sea loopback.
    readonly property var activeDevice: {
        try {
            for (var i = 0; i < root.deviceList.length; i++) {
                var d = root.deviceList[i];
                try {
                    if (d && d.connected && String(d.name || "") !== "lo")
                        return d;
                } catch (e2) {}
            }
        } catch (e) {}
        return null;
    }

    readonly property string activeIface: {
        try {
            return root.activeDevice ? String(root.activeDevice.name || "") : "";
        } catch (e) {
            return "";
        }
    }

    // Red conectada dentro del dispositivo activo (para desconectar fino).
    readonly property var activeNetwork: {
        try {
            if (!root.activeDevice || !root.activeDevice.networks)
                return null;
            var nets = root.activeDevice.networks.values;
            if (!nets)
                return null;
            for (var i = 0; i < nets.length; i++) {
                try {
                    if (nets[i] && nets[i].connected)
                        return nets[i];
                } catch (e) {}
            }
        } catch (e) {}
        return null;
    }

    // Wi-Fi: primer dispositivo con pinta de inalámbrico.
    readonly property var wifiDevice: {
        try {
            for (var i = 0; i < root.deviceList.length; i++) {
                var d = root.deviceList[i];
                if (!d)
                    continue;
                try {
                    // WifiDevice expone scannerEnabled; el resto no.
                    var s = d.scannerEnabled;
                    if (s !== undefined)
                        return d;
                } catch (e1) {}
                try {
                    var ns = d.networks ? d.networks.values : null;
                    if (ns && ns.length > 0 && ns[0] && ns[0].signalStrength !== undefined)
                        return d;
                } catch (e2) {}
                try {
                    var nm = String(d.name || "");
                    if (nm.indexOf("wl") === 0 || nm.indexOf("wifi") >= 0)
                        return d;
                } catch (e3) {}
            }
        } catch (e) {}
        return null;
    }

    readonly property bool wifiOn: {
        try {
            return !!Networking.wifiEnabled;
        } catch (e) {
            return false;
        }
    }

    // Redes wifi visibles: ssid no vacío, deduplicadas, ordenadas por señal.
    readonly property var wifiNetworks: {
        var out = [];
        try {
            if (!root.wifiOn || !root.wifiDevice || !root.wifiDevice.networks)
                return out;
            var nets = root.wifiDevice.networks.values || [];
            var seen = {};
            for (var i = 0; i < nets.length; i++) {
                try {
                    var n = nets[i];
                    if (!n)
                        continue;
                    var ssid = String(n.ssid || n.name || "");
                    if (ssid === "" || seen[ssid])
                        continue;
                    seen[ssid] = true;
                    out.push(n);
                } catch (e) {}
            }
            out.sort(function (a, b) {
                try {
                    return Number(b.signalStrength || 0) - Number(a.signalStrength || 0);
                } catch (e) {
                    return 0;
                }
            });
        } catch (e) {}
        return out;
    }

    function wifiIcon(sig): string {
        // Material Symbols: degradado por intensidad.
        try {
            if (sig >= 0.75)
                return "wifi";
            if (sig >= 0.5)
                return "wifi_2_bar";
            return "wifi_1_bar";
        } catch (e) {
            return "wifi";
        }
    }

    function disconnectActive(): void {
        try {
            if (root.activeNetwork && root.activeNetwork.disconnect)
                root.activeNetwork.disconnect();
            else if (root.activeDevice && root.activeDevice.disconnect)
                root.activeDevice.disconnect();
        } catch (e) {}
    }

    // ---- IP vía `ip -4 -o addr show` (Networking no expone IP) ----
    property var ipMap: ({})

    function parseIpOut(text): void {
        try {
            var m = {};
            var lines = String(text || "").split("\n");
            for (var i = 0; i < lines.length; i++) {
                // "3: wlp2s0    inet 10.26.29.23/24 ..."
                var parts = lines[i].trim().split(/\s+/);
                if (parts.length < 4)
                    continue;
                var iface = parts[1] || "";
                var inetIdx = parts.indexOf("inet");
                if (inetIdx < 0 || inetIdx + 1 >= parts.length)
                    continue;
                var cidr = String(parts[inetIdx + 1] || "");
                if (iface === "" || iface === "lo" || cidr === "")
                    continue;
                m[iface] = cidr.split("/")[0];
            }
            root.ipMap = m;
        } catch (e) {}
    }

    readonly property string activeIp: {
        try {
            var ip = root.ipMap[root.activeIface];
            return ip ? String(ip) : "";
        } catch (e) {
            return "";
        }
    }

    Process {
        id: ipProc
        command: ["sh", "-c", "ip -4 -o addr show"]
        stdout: StdioCollector {
            onStreamFinished: root.parseIpOut(text)
        }
    }

    Process {
        id: rescanProc
        command: ["sh", "-c", "nmcli dev wifi rescan 2>/dev/null || true"]
    }

    Timer {
        id: ipTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (!ipProc.running)
                ipProc.running = true;
        }
    }

    Component.onCompleted: {
        ipProc.running = true;
    }

    // ---- Layout ----
    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Cabecera: Network + close (ref 1.png).
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: "Network"
                font.pixelSize: Theme.fontMain
                font.bold: true
                color: Theme.accentYellow
            }

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 28
                height: 28
                radius: 8
                color: Theme.bgField

                Text {
                    anchors.centerIn: parent
                    text: "close"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 16
                    color: Theme.textMuted
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandState.collapse()
                }
            }
        }

        // Tarjeta 1: Current Connection.
        Rectangle {
            Layout.fillWidth: true
            radius: Theme.radiusMedium
            color: Theme.bgField
            border.color: Qt.rgba(1, 1, 1, 0.08)
            border.width: 1

            implicitHeight: ccCol.implicitHeight + 20

            ColumnLayout {
                id: ccCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    text: "Current Connection"
                    font.pixelSize: Theme.fontMain
                    font.bold: true
                    color: Theme.textPrimary
                    elide: Text.ElideRight
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: root.activeIface !== "" ? (root.activeIface + (root.activeIp !== "" ? "  " + root.activeIp : "")) : "Not connected"
                        font.pixelSize: Theme.fontSmall
                        color: Theme.textMuted
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        width: 30
                        height: 30
                        radius: 7
                        color: Theme.badgeRed
                        visible: root.activeDevice !== null
                        enabled: root.activeDevice !== null

                        Text {
                            anchors.centerIn: parent
                            text: "close"
                            font.family: "Material Symbols Rounded"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#11111b"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.disconnectActive()
                        }
                    }
                }
            }
        }

        // Tarjeta 2: Wi-Fi.
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Theme.radiusMedium
            color: Theme.bgField
            border.color: Qt.rgba(1, 1, 1, 0.08)
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: "Wi-Fi"
                        font.pixelSize: Theme.fontMain
                        font.bold: true
                        color: Theme.textPrimary
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: "refresh"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 18
                        color: Theme.textMuted

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!rescanProc.running)
                                    rescanProc.running = true;
                                if (!ipProc.running)
                                    ipProc.running = true;
                            }
                        }
                    }

                    // Toggle estilo ref (píldora amarilla en ON).
                    Rectangle {
                        id: wifiToggle
                        Layout.alignment: Qt.AlignVCenter
                        width: 40
                        height: 22
                        radius: 11
                        color: root.wifiOn ? Theme.accentYellow : Qt.rgba(1, 1, 1, 0.14)

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animFast
                            }
                        }

                        Rectangle {
                            id: knob
                            anchors.verticalCenter: parent.verticalCenter
                            x: root.wifiOn ? parent.width - width - 3 : 3
                            width: 16
                            height: 16
                            radius: 8
                            color: root.wifiOn ? "#11111b" : Theme.textMuted

                            Behavior on x {
                                NumberAnimation {
                                    duration: Theme.animFast
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                try {
                                    Networking.wifiEnabled = !Networking.wifiEnabled;
                                } catch (e) {}
                            }
                        }
                    }
                }

                // Lista o vacío.
                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: root.wifiNetworks.length === 0
                    visible: root.wifiNetworks.length === 0
                    text: "No networks in range"
                    font.pixelSize: Theme.fontSmall
                    color: Theme.textMuted
                    verticalAlignment: Text.AlignVCenter
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.wifiNetworks.length > 0
                    spacing: 2

                    Repeater {
                        model: root.wifiNetworks

                        Item {
                            id: netRow
                            required property var modelData
                            required property int index

                            visible: index < 4
                            Layout.fillWidth: true
                            implicitHeight: 22

                            RowLayout {
                                anchors.fill: parent
                                spacing: 8

                                Text {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    text: {
                                        try {
                                            return String(netRow.modelData.ssid || netRow.modelData.name || "");
                                        } catch (e) {
                                            return "";
                                        }
                                    }
                                    font.pixelSize: Theme.fontSmall
                                    color: {
                                        try {
                                            return netRow.modelData.connected ? Theme.textPrimary : Theme.textMain;
                                        } catch (e) {
                                            return Theme.textMain;
                                        }
                                    }
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: {
                                        try {
                                            return root.wifiIcon(Number(netRow.modelData.signalStrength || 0));
                                        } catch (e) {
                                            return "wifi";
                                        }
                                    }
                                    font.family: "Material Symbols Rounded"
                                    font.pixelSize: 16
                                    color: {
                                        try {
                                            return netRow.modelData.connected ? Theme.accentYellow : Theme.textMuted;
                                        } catch (e) {
                                            return Theme.textMuted;
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    try {
                                        if (netRow.modelData && !netRow.modelData.connected)
                                            netRow.modelData.connect();
                                    } catch (e) {}
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
