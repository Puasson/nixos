import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../theme"

// Menu de temas (SUPER+SHIFT+I): 8 familias x claro/oscuro.
// El cambio se aplica en vivo al singleton Theme y se persiste;
// `theme-set` lo propaga a GTK/wallpaper cuando se usa desde CLI.
Scope {
    id: root

    readonly property bool isOpen: ThemeMenuState.isOpen

    function open(): void {
        ThemeMenuState.open();
    }
    function close(): void {
        ThemeMenuState.close();
    }
    function toggle(): void {
        ThemeMenuState.toggle();
    }

    function pick(fam): void {
        Theme.setFamily(String(fam));
    }

    IpcHandler {
        target: "ThemeMenu"

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
            WlrLayershell.namespace: "quickshell-thememenu"

            onVisibleChanged: {
                if (visible)
                    card.forceActiveFocus();
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.close()
            }

            Item {
                anchors.centerIn: parent
                width: Math.min(parent.width - 80, 560)
                height: card.implicitHeight

                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse => mouse.accepted = true
                }

                ColumnLayout {
                    id: card
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 12
                    focus: true

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.close();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_N) {
                            Theme.nextFamily();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_D) {
                            Theme.setMode("dark");
                            event.accepted = true;
                        } else if (event.key === Qt.Key_L) {
                            Theme.setMode("light");
                            event.accepted = true;
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Temas"
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontTitle
                            font.bold: true
                        }
                        Text {
                            text: "  " + Theme.familyLabel(Theme.family) + " · " + (Theme.isDark ? "oscuro" : "claro")
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontSmall
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: 10

                        Repeater {
                            model: Theme.families

                            Rectangle {
                                required property var modelData
                                required property int index

                                property string fam: String(modelData)
                                property bool active: fam === Theme.family
                                property var prev: Theme.preview(fam, Theme.isDark)

                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                radius: Theme.radiusMedium
                                color: active ? Theme.bgSelected : Theme.bgField
                                border.color: active ? Theme.accentBlue : "transparent"
                                border.width: active ? 2 : 0

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 8

                                    Rectangle {
                                        Layout.preferredWidth: 14
                                        Layout.preferredHeight: 14
                                        radius: Theme.radiusDot
                                        color: prev.bg
                                        border.color: Theme.textMuted
                                        border.width: 1
                                    }
                                    Rectangle {
                                        Layout.preferredWidth: 14
                                        Layout.preferredHeight: 14
                                        radius: Theme.radiusDot
                                        color: prev.accent
                                    }
                                    Rectangle {
                                        Layout.preferredWidth: 14
                                        Layout.preferredHeight: 14
                                        radius: Theme.radiusDot
                                        color: prev.text
                                        border.color: Theme.textMuted
                                        border.width: 1
                                    }
                                    Text {
                                        text: Theme.familyLabel(fam)
                                        color: Theme.textPrimary
                                        font.pixelSize: Theme.fontMain
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: active ? "●" : ""
                                        color: Theme.accentGreen
                                        font.pixelSize: Theme.fontSmall
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: {
                                        if (!active)
                                            parent.color = Theme.bgHover;
                                    }
                                    onExited: {
                                        if (!active)
                                            parent.color = Theme.bgField;
                                    }
                                    onClicked: root.pick(fam)
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: Theme.radiusButton
                            color: Theme.isDark ? Theme.bgSelected : Theme.bgField

                            Text {
                                anchors.centerIn: parent
                                text: "Oscuro (D)"
                                color: Theme.textPrimary
                                font.pixelSize: Theme.fontSmall
                                font.bold: Theme.isDark
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Theme.setMode("dark")
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: Theme.radiusButton
                            color: !Theme.isDark ? Theme.bgSelected : Theme.bgField

                            Text {
                                anchors.centerIn: parent
                                text: "Claro (L)"
                                color: Theme.textPrimary
                                font.pixelSize: Theme.fontSmall
                                font.bold: !Theme.isDark
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Theme.setMode("light")
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            radius: Theme.radiusButton
                            color: nextHover.containsMouse ? Theme.bgHover : Theme.bgField

                            Text {
                                anchors.centerIn: parent
                                text: "Siguiente (N)"
                                color: Theme.textPrimary
                                font.pixelSize: Theme.fontSmall
                            }
                            MouseArea {
                                id: nextHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Theme.nextFamily()
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "Enter/click aplica · D oscuro · L claro · N siguiente · Esc cierra"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontTiny
                    }
                }
            }
        }
    }
}
