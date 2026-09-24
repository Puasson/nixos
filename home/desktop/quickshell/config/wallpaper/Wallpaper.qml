import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../theme"

Scope {
    id: root

    property bool isOpen: false
    property int selected: 0
    property var wallpapers: []
    property string currentPath: ""
    property string lastPreview: ""
    property string openedPath: ""
    property string pendingPreview: ""

    readonly property string wallDir: "/home/edu/Pictures/Wallpaper"
    readonly property string cacheFile: "/home/edu/.cache/quickshell/wallpaper/current"

    function open(): void {
        root.openedPath = root.currentPath;
        root.isOpen = true;
        listProc.running = true;
        currentProc.running = true;
    }
    function close(): void {
        root.isOpen = false;
    }
    function toggle(): void {
        if (root.isOpen)
            root.cancel();
        else
            root.open();
    }
    // Cerrar sin guardar: restaura el fondo que había al abrir.
    function cancel(): void {
        previewTimer.stop();
        root.pendingPreview = "";
        if (root.openedPath !== "" && root.lastPreview !== root.openedPath)
            Quickshell.execDetached(["wallpaper-set", "--preview", root.openedPath]);
        root.lastPreview = root.openedPath;
        root.close();
    }
    function preview(path): void {
        if (!path || path === root.lastPreview)
            return;
        root.lastPreview = path;
        Quickshell.execDetached(["wallpaper-set", "--preview", path]);
    }
    // Debounce de preview (actualmente sin llamadas: hover/teclado solo
    // resaltan; se conserva por si se quiere reactivar preview al hover).
    function requestPreview(path): void {
        if (!path || path === root.lastPreview)
            return;
        root.pendingPreview = path;
        previewTimer.restart();
    }
    function applySelected(): void {
        previewTimer.stop();
        root.pendingPreview = "";
        if (root.wallpapers.length === 0)
            return;
        var item = root.wallpapers[root.selected];
        if (!item)
            return;
        root.currentPath = item.path;
        root.lastPreview = item.path;
        root.openedPath = item.path;
        Quickshell.execDetached(["wallpaper-set", "--persist", item.path]);
        root.close();
    }
    function applyRandom(): void {
        if (root.wallpapers.length === 0)
            return;
        root.selected = Math.floor(Math.random() * root.wallpapers.length);
        root.applySelected();
    }
    // Hover/teclado solo resaltan: el fondo solo cambia con click/Enter (applySelected).
    function move(delta): void {
        if (root.wallpapers.length === 0)
            return;
        var n = root.wallpapers.length;
        root.selected = (root.selected + delta + n) % n;
    }

    function isImage(name): bool {
        var l = name.toLowerCase();
        return l.endsWith(".jpg") || l.endsWith(".jpeg") || l.endsWith(".png")
            || l.endsWith(".webp") || l.endsWith(".gif") || l.endsWith(".mp4")
            || l.endsWith(".mkv") || l.endsWith(".webm") || l.endsWith(".mov");
    }

    Timer {
        id: previewTimer
        interval: 120
        repeat: false
        onTriggered: root.preview(root.pendingPreview)
    }

    // Lista el directorio en vivo ( Tolera espacios: separa solo por \n ).
    Process {
        id: listProc
        command: ["ls", "-1", root.wallDir]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = [];
                var lines = String(this.text || "").split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var name = lines[i].replace(/\r$/, "");
                    if (name === "" || !root.isImage(name))
                        continue;
                    out.push({ name: name, path: root.wallDir + "/" + name });
                }
                out.sort(function(a, b) {
                    return String(a.name).localeCompare(String(b.name));
                });
                root.wallpapers = out;
                // Re-sincroniza la selección con el fondo persistido.
                var idx = -1;
                for (var j = 0; j < out.length; j++) {
                    if (out[j].path === root.currentPath) {
                        idx = j;
                        break;
                    }
                }
                root.selected = idx === -1 ? 0 : idx;
            }
        }
    }

    // Lee el fondo persistido para preseleccionarlo al abrir.
    Process {
        id: currentProc
        command: ["cat", root.cacheFile]
        stdout: StdioCollector {
            onStreamFinished: {
                var p = String(this.text || "").replace(/\r?\n$/, "");
                if (p !== "")
                    root.currentPath = p;
                root.openedPath = root.currentPath;
                root.lastPreview = root.currentPath;
                for (var j = 0; j < root.wallpapers.length; j++) {
                    if (root.wallpapers[j].path === root.currentPath) {
                        root.selected = j;
                        break;
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "WallpaperMenu"

        function toggle(): void {
            root.toggle();
        }
        function open(): void {
            root.open();
        }
        function close(): void {
            root.close();
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: root.isOpen

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            color: Theme.overlayDim
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            onVisibleChanged: {
                if (visible)
                    card.forceActiveFocus();
            }

            // Click fuera de la tarjeta = cancelar (restaura preview).
            MouseArea {
                anchors.fill: parent
                onClicked: root.cancel()
            }

            // Contenedor de la tarjeta: traga los clicks de su área para no
            // cancelar al pulsar huecos del layout (no tiene cromo visual,
            // la tira flota como en la referencia).
            Item {
                anchors.centerIn: parent
                width: Math.min(parent.width - 80, 1180)
                height: card.implicitHeight

                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse => mouse.accepted = true
                }

                ColumnLayout {
                    id: card
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 10
                    focus: true

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Left || event.key === Qt.Key_Down) {
                            root.move(-1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Up) {
                            root.move(1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.applySelected();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            root.cancel();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_R) {
                            root.applyRandom();
                            event.accepted = true;
                        }
                    }

                    // Encabezado: título + contador + botón aleatorio.
                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Fondos"
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontTitle
                            font.bold: true
                        }
                        Text {
                            text: root.wallpapers.length > 0 ? ("  " + (root.selected + 1) + " / " + root.wallpapers.length) : ""
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontSmall
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            Layout.preferredWidth: 130
                            Layout.preferredHeight: 32
                            radius: Theme.radiusButton
                            color: randomHover.containsMouse ? Theme.bgHover : Theme.bgField

                            Text {
                                anchors.centerIn: parent
                                text: "Aleatorio (R)"
                                color: Theme.textPrimary
                                font.pixelSize: Theme.fontSmall
                            }
                            MouseArea {
                                id: randomHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.applyRandom()
                            }
                        }
                    }

                    // Nombre del fondo seleccionado.
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: root.wallpapers.length > 0 ? root.wallpapers[root.selected].name : "Sin fondos en ~/Pictures/Wallpaper"
                        color: Theme.textMain
                        font.pixelSize: Theme.fontMain
                        elide: Text.ElideMiddle
                    }

                    // Tira coverflow: ListView horizontal, delegados solapados
                    // con shear para el efecto paralelogramo. La selección se
                    // maneja en root.selected; el centrado es animado (Behavior
                    // en contentX) y el hover solo resalta, sin preview.
                    ListView {
                        id: strip
                        Layout.fillWidth: true
                        Layout.preferredHeight: 330
                        orientation: ListView.Horizontal
                        clip: false
                        spacing: -34
                        model: root.wallpapers
                        boundsBehavior: Flickable.StopAtBounds
                        currentIndex: root.selected
                        highlightRangeMode: ListView.StrictlyEnforceRange
                        preferredHighlightBegin: width / 2 - 100
                        preferredHighlightEnd: width / 2 + 100
                        highlightMoveDuration: Theme.animNormal

                        Behavior on contentX {
                            enabled: !strip.moving && !strip.flicking
                            SmoothedAnimation {
                                velocity: 1200
                                duration: Theme.animNormal
                            }
                        }

                        // Centrado diferido: evita la cascada hover -> recentrar
                        // -> nuevo hover -> ... que saltaba de extremo a extremo.
                        Timer {
                            id: centerTimer
                            interval: 90
                            repeat: false
                            onTriggered: strip.positionViewAtIndex(root.selected, ListView.Center)
                        }

                        Connections {
                            target: root
                            function onSelectedChanged() {
                                centerTimer.restart();
                            }
                        }

                        onCountChanged: {
                            if (count > 0)
                                strip.positionViewAtIndex(root.selected, ListView.Center);
                        }

                        delegate: Item {
                            required property var modelData
                            required property int index

                            width: 200
                            height: 320

                            property bool isSelected: index === root.selected

                            scale: isSelected ? 1.06 : 0.92
                            opacity: isSelected ? 1.0 : 0.72
                            z: isSelected ? 10 : 0

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Theme.animFast
                                    easing.type: Easing.InOutQuad
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Theme.animFast
                                }
                            }

                            // Shear horizontal: x' = x - 0.18*y + 27 (compensa
                            // el desplazamiento para mantener el centro).
                            transform: Matrix4x4 {
                                matrix: Qt.matrix4x4(1, -0.18, 0, 27, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 164
                                height: 300
                                radius: Theme.radiusMedium
                                color: Theme.thumbBg
                                border.color: Theme.accentBlue
                                border.width: isSelected ? 3 : 0
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    // encodeURI: los nombres contienen espacios
                                    // ("Anime Girl.jpg"); sin codificar Qt no
                                    // resuelve el file:// y falla la miniatura.
                                    source: encodeURI("file://" + modelData.path)
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    sourceSize.width: 360
                                }

                                // Indicador de fondo activo (persistido).
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 8
                                    width: 12
                                    height: 12
                                    radius: Theme.radiusDot
                                    color: Theme.accentGreen
                                    visible: modelData.path === root.currentPath
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: {
                                    // Ignora hovers generados por el propio scroll
                                    // (el ítem se mueve bajo el cursor) y por drags:
                                    // solo el movimiento real del mouse resalta.
                                    if (strip.moving || strip.flicking || strip.dragging)
                                        return;
                                    if (root.selected !== index)
                                        root.selected = index;
                                }
                                onClicked: {
                                    root.selected = index;
                                    root.applySelected();
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "←/→ navegar · hover resalta · Enter/click aplica · R aleatorio · Esc cancela"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontTiny
                    }
                }
            }
        }
    }
}
