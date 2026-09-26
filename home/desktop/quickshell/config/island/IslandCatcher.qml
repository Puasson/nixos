import Quickshell
import Quickshell.Wayland
import QtQuick

// Atrapa clicks fuera de la isla expandida para colapsarla. Espejo de
// LauncherCatcher: la isla ya no usa overlay fullscreen, así que esta
// ventana lo sustituye: capa Bottom (por encima del fondo, por debajo de
// la isla en Top) con máscara total, visible solo mientras está expandida.
// Los clicks sobre ventanas de apps los gestiona el cambio de
// activeToplevel en Island.qml; aquí caen los del escritorio vacío.
PanelWindow {
    id: root

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    visible: IslandState.manualExpanded

    color: "transparent"

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-island-catcher"

    MouseArea {
        anchors.fill: parent
        onClicked: IslandState.collapse()
    }
}
