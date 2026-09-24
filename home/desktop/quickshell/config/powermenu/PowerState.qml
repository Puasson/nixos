pragma Singleton
import Quickshell
import QtQuick

// Estado compartido del menú de energía (una sola instancia global).
QtObject {
    id: root

    property bool isOpen: false

    function toggle(): void {
        root.isOpen = !root.isOpen;
    }

    function open(): void {
        root.isOpen = true;
    }

    function close(): void {
        root.isOpen = false;
    }
}
