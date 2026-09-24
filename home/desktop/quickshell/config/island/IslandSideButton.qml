// Botón de la franja lateral: icono Material Symbols + badge opcional.
import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    property string icon: ""
    property bool active: false
    property bool badge: false

    signal clicked

    Layout.fillWidth: true
    implicitWidth: 64
    implicitHeight: 32

    Rectangle {
        anchors.centerIn: parent
        width: 44
        height: 34
        radius: 10
        color: root.active ? Theme.bgSelected : "transparent"
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: "Material Symbols Rounded"
        font.pixelSize: 22
        color: root.active ? Theme.textPrimary : Theme.textMuted
    }

    // Punto de no leído (notificaciones).
    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.top: parent.top
        anchors.topMargin: 4
        width: 8
        height: 8
        radius: 4
        color: Theme.badgeRed
        visible: root.badge
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
