// Botón del dock: icono de 38px + indicador de app abierta.
import Quickshell
import Quickshell.Widgets
import QtQuick
import "../theme"

Item {
    id: root

    // Tamaño de icono exigido por configuración.
    property int iconSize: 38
    property string iconName: ""
    property string tooltipText: ""
    property bool running: false
    property bool active: false

    signal clicked
    signal middleClicked

    width: 52
    height: 48

    Column {
        anchors.centerIn: parent
        spacing: 3

        IconImage {
            id: icon
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: root.iconSize
            implicitHeight: root.iconSize
            source: Quickshell.iconPath(root.iconName, "application-x-executable")
        }

        // Punto indicador: visible si la app está abierta, resaltado si enfocada.
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 6
            height: 6
            radius: Theme.radiusDotSmall
            visible: root.running
            color: root.active ? Theme.accentGreen : Theme.textMuted
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton)
                root.middleClicked();
            else
                root.clicked();
        }
    }
}
