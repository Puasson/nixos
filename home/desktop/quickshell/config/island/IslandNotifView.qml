// Vista de notificaciones: última recibida + badge gestionado en IslandState.
import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "notifications"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 22
                color: IslandState.notifUnread ? Theme.badgeRed : Theme.accentBlue
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: "Notificaciones"
                font.pixelSize: Theme.fontMain
                font.bold: true
                color: Theme.textPrimary
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                visible: IslandState.notifTime !== ""
                text: IslandState.notifTime
                font.pixelSize: Theme.fontSmall
                color: Theme.textMuted
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                visible: IslandState.notifTitle !== ""
                text: "close"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 20
                color: Theme.textMuted
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandState.clearNotification()
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: IslandState.notifTitle === ""
            text: "Sin notificaciones recientes"
            font.pixelSize: Theme.fontSmall
            color: Theme.textMuted
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: IslandState.notifTitle !== ""
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: IslandState.notifTitle
                font.pixelSize: Theme.fontMain
                font.bold: true
                color: Theme.textPrimary
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: IslandState.notifBody !== "" ? IslandState.notifBody : "Sin contenido"
                font.pixelSize: Theme.fontSmall
                color: Theme.textMain
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: 4
            }
        }
    }
}
