// Vista de reproducción MPRIS (sin like ni impresora).
// Recibe el reproductor activo desde Island.qml.
import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    property var player: null
    property bool hasMedia: false

    // Tics de 1s para refrescar posición aunque el player no notifique.
    property int tick: 0

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.tick++
    }

    function fmtTime(sec): string {
        try {
            var s = Math.max(0, Math.floor(sec));
            var m = Math.floor(s / 60);
            var r = s % 60;
            return m + ":" + String(r).padStart(2, "0");
        } catch (e) {
            return "0:00";
        }
    }

    readonly property string titleText: {
        try {
            return root.player ? String(root.player.trackTitle || "") : "";
        } catch (e) {
            return "";
        }
    }
    readonly property string artistText: {
        try {
            return root.player ? String(root.player.trackArtist || "") : "";
        } catch (e) {
            return "";
        }
    }
    readonly property string artUrl: {
        try {
            return root.player ? String(root.player.trackArtUrl || "") : "";
        } catch (e) {
            return "";
        }
    }
    readonly property real position: {
        root.tick;
        try {
            return root.player ? Number(root.player.position || 0) : 0;
        } catch (e) {
            return 0;
        }
    }
    readonly property real trackLen: {
        try {
            return root.player ? Number(root.player.length || 0) : 0;
        } catch (e) {
            return 0;
        }
    }
    readonly property bool playing: {
        try {
            return !!(root.player && root.player.isPlaying);
        } catch (e) {
            return false;
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 14

        // Columna principal: cabecera + progreso + controles.
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            // Cabecera: volver + título/artista + menú.
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: "arrow_back"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 20
                    color: Theme.textMuted
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandState.collapse()
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: root.titleText !== "" ? root.titleText : (root.hasMedia ? "Reproduciendo" : "Sin reproducción")
                        font.pixelSize: Theme.fontMain
                        font.bold: true
                        color: Theme.textPrimary
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.artistText
                        visible: root.artistText !== ""
                        font.pixelSize: Theme.fontSmall
                        color: Theme.textMuted
                        elide: Text.ElideRight
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    visible: root.playing
                    text: "graphic_eq"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 20
                    color: Theme.accentGreen
                }
            }

            // Progreso: tiempos + barra.
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: root.hasMedia && root.trackLen > 0

                Text {
                    text: root.fmtTime(root.position)
                    font.pixelSize: Theme.fontTiny
                    color: Theme.textMuted
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    height: 4
                    radius: 2
                    color: Theme.bgField

                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.trackLen > 0 ? parent.width * Math.min(1, root.position / root.trackLen) : 0
                        height: parent.height
                        radius: 2
                        color: Theme.accentGreen
                    }
                }

                Text {
                    text: root.fmtTime(root.trackLen)
                    font.pixelSize: Theme.fontTiny
                    color: Theme.textMuted
                }
            }

            // Controles circulares: prev / play-pause / next.
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 14
                visible: root.hasMedia && root.player

                Repeater {
                    model: ["skip_previous", "play", "skip_next"]

                    Rectangle {
                        required property string modelData
                        required property int index

                        property string glyph: {
                            if (modelData === "play")
                                return root.playing ? "pause" : "play_arrow";
                            return modelData;
                        }

                        Layout.alignment: Qt.AlignVCenter
                        width: index === 1 ? 52 : 44
                        height: index === 1 ? 52 : 44
                        radius: index === 1 ? 26 : 22
                        color: Theme.bgField

                        Text {
                            anchors.centerIn: parent
                            text: parent.glyph
                            font.family: "Material Symbols Rounded"
                            font.pixelSize: index === 1 ? 28 : 24
                            color: Theme.textPrimary
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                try {
                                    if (!root.player)
                                        return;
                                    if (parent.index === 0 && root.player.canGoPrevious)
                                        root.player.previous();
                                    else if (parent.index === 1)
                                        root.player.togglePlaying();
                                    else if (parent.index === 2 && root.player.canGoNext)
                                        root.player.next();
                                } catch (e) {}
                            }
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !root.hasMedia
                text: "Abre un reproductor para verlo aquí"
                font.pixelSize: Theme.fontSmall
                color: Theme.textMuted
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Carátula a la derecha (como la referencia 2.jpeg).
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: 128
            height: 128
            radius: 12
            color: Theme.bgField
            clip: true

            Image {
                anchors.fill: parent
                visible: root.artUrl !== ""
                source: root.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
            }

            Text {
                anchors.centerIn: parent
                visible: root.artUrl === ""
                text: "music_note"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 44
                color: Theme.textMuted
            }
        }
    }
}
