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
    property string query: ""
    property int selected: 0

    function open(): void {
        root.query = "";
        root.selected = 0;
        root.isOpen = true;
    }
    function close(): void {
        root.isOpen = false;
    }
    function toggle(): void {
        if (root.isOpen)
            root.close();
        else
            root.open();
    }

    function launch(entry): void {
        if (!entry)
            return;
        try {
            entry.execute();
        } catch (e) {}
        root.close();
    }

    IpcHandler {
        target: "LauncherMenu"

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

    // Apps instaladas ordenadas por nombre.
    property var allApps: DesktopEntries.applications.values.slice().sort(function(a, b) {
        return String(a.name).localeCompare(String(b.name));
    })

    // Filtro por nombre + comentario + id, sin límite: con query
    // vacía muestra todas las apps.
    property var filtered: {
        var q = root.query.trim().toLowerCase();
        var apps = root.allApps;
        if (q === "")
            return apps;
        var out = [];
        for (var i = 0; i < apps.length; i++) {
            var e = apps[i];
            var hay = (String(e.name || "") + " " + String(e.comment || "") + " " + String(e.id || e.desktopId || "")).toLowerCase();
            if (hay.indexOf(q) !== -1)
                out.push(e);
        }
        return out;
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

            // Ventana flotante a pantalla completa (fondo transparente):
            // no reserva espacio en el compositor.
            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            onVisibleChanged: {
                if (visible)
                    searchInput.forceActiveFocus();
            }

            // Click fuera de la tarjeta cierra el lanzador.
            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }

            // Tarjeta centrada abajo, por encima del dock (dock ~68px + 12px margen).
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 110
                width: 450
                implicitHeight: content.implicitHeight + 24
                radius: Theme.radiusLarge
                color: Theme.bgCard

                // El click dentro no llega al MouseArea de fondo.
                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse => mouse.accepted = true
                }

                ColumnLayout {
                    id: content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 8

                    // Buscador.
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: Theme.radiusMedium
                        color: Theme.bgField

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.textPrimary
                            selectionColor: Theme.accentBlue
                            cursorVisible: true
                            font.pixelSize: Theme.fontBody
                            text: root.query
                            onTextChanged: {
                                if (root.query !== text) {
                                    root.query = text;
                                    root.selected = 0;
                                }
                            }

                            Keys.onPressed: event => {
                                if (event.key === Qt.Key_Down) {
                                    root.selected = Math.min(root.selected + 1, root.filtered.length - 1);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Up) {
                                    root.selected = Math.max(root.selected - 1, 0);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    root.launch(root.filtered[root.selected]);
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_Escape) {
                                    root.close();
                                    event.accepted = true;
                                }
                            }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Buscar aplicación…"
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontBody
                            visible: searchInput.displayText === ""
                        }
                    }

                    // Resultados: solo icono + nombre, con scroll si hay muchas apps.
                    Flickable {
                        id: resultsFlick
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(resultsColumn.implicitHeight, 440)
                        contentHeight: resultsColumn.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        flickableDirection: Flickable.VerticalFlick

                        function ensureVisible(idx): void {
                            var itemH = 46;
                            var y = idx * itemH;
                            if (y < contentY)
                                contentY = y;
                            else if (y + itemH > contentY + height)
                                contentY = y + itemH - height;
                        }

                        onHeightChanged: ensureVisible(root.selected)

                        Column {
                            id: resultsColumn
                            width: parent.width
                            spacing: 2

                            Repeater {
                                model: root.filtered

                                Rectangle {
                                    required property var modelData
                                    required property int index

                                    width: parent.width
                                    height: 44
                                    radius: Theme.radiusMedium
                                    color: index === root.selected ? Theme.bgSelected : "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 12

                                        IconImage {
                                            implicitWidth: 32
                                            implicitHeight: 32
                                            source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            text: modelData.name
                                            color: Theme.textPrimary
                                            font.pixelSize: Theme.fontMain
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onEntered: root.selected = index
                                        onClicked: root.launch(modelData)
                                    }
                                }
                            }
                        }
                    }

                    Connections {
                        target: root
                        function onSelectedChanged(): void {
                            resultsFlick.ensureVisible(root.selected);
                        }
                        function onFilteredChanged(): void {
                            resultsFlick.contentY = 0;
                            resultsFlick.ensureVisible(root.selected);
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        visible: root.filtered.length === 0
                        text: "Sin resultados"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontMain
                    }
                }
            }
        }
    }
}
