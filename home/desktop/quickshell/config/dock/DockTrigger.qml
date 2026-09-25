import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    anchors {
        left: true
        right: true
        bottom: true
    }

    implicitHeight: 4

    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.namespace: "quickshell-dock-trigger"

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        onContainsMouseChanged: DockState.setEdgeHovered(root.screen ? root.screen.name : "", containsMouse)
    }
}
