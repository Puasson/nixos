import Quickshell
import Quickshell.Wayland
import QtQuick

// Atrapa clicks fuera del panel expandido para colapsarlo. El dock ya no
// usa overlay fullscreen, así que esta ventana lo sustituye: capa Bottom
// (por encima de las apps, por debajo del dock en Top) con máscara total,
// visible solo mientras el lanzador está abierto.
PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    visible: LauncherState.isOpen

    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-dock-catcher"

    MouseArea {
        anchors.fill: parent
        onClicked: LauncherState.close()
    }
}
