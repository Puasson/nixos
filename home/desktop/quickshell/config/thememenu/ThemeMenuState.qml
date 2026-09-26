pragma Singleton
import Quickshell
import QtQuick

// Estado del menu de temas, espejo de LauncherState/PowerState.
QtObject {
    id: root

    property bool isOpen: false

    function open(): void {
        root.isOpen = true;
    }
    function close(): void {
        root.isOpen = false;
    }
    function toggle(): void {
        root.isOpen = !root.isOpen;
    }
}
