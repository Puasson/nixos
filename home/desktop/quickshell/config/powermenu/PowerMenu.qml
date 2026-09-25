import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../theme"

Scope {
    id: root

    readonly property bool isOpen: PowerState.isOpen

    function open(): void {
        PowerState.open();
    }
    function close(): void {
        PowerState.close();
    }
    function toggle(): void {
        PowerState.toggle();
    }

    function run(cmd): void {
        try {
            Quickshell.execDetached(cmd);
        } catch (e) {}
        root.close();
    }

    readonly property var actions: [
        { icon: "lock", label: "Bloquear", cmd: ["hyprlock"] },
        { icon: "power_settings_new", label: "Apagar", cmd: ["systemctl", "poweroff"] },
        { icon: "restart_alt", label: "Reiniciar", cmd: ["systemctl", "reboot"] },
        { icon: "logout", label: "Cerrar sesión", cmd: ["uwsm", "stop"] },
        { icon: "bedtime", label: "Suspender", cmd: ["systemctl", "suspend"] }
    ]

    IpcHandler {
        target: "PowerMenu"

        function toggle(): void {
            root.toggle();
        }
        function open(): void {
            root.open();
        }
        function close(): void {
            root.close();
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            visible: root.isOpen

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            focusable: true
            color: Theme.overlayDim
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "quickshell-powermenu"

            onVisibleChanged: {
                if (visible)
                    cardRow.forceActiveFocus();
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }

            Item {
                anchors.centerIn: parent
                width: cardRow.implicitWidth
                height: cardRow.implicitHeight

                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse => mouse.accepted = true
                }

                RowLayout {
                    id: cardRow
                    anchors.fill: parent
                    spacing: 28
                    focus: true

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.close();
                            event.accepted = true;
                        }
                    }

                    Repeater {
                        model: root.actions

                        PowerMenuButton {
                            required property var modelData
                            icon: modelData.icon
                            label: modelData.label
                            onClicked: root.run(modelData.cmd)
                        }
                    }
                }
            }
        }
    }
}
