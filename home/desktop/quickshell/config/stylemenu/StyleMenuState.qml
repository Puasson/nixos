pragma Singleton
import Quickshell
import QtQuick

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
