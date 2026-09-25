import QtQuick
import QtQuick.Layouts
import "../theme"

ColumnLayout {
    id: root

    property string icon: ""
    property string label: ""

    signal clicked

    spacing: 10

    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 76
        Layout.preferredHeight: 76
        radius: 38
        color: btnHover.containsMouse ? Theme.bgHover : Theme.bgField
        border.color: Theme.bgSelected
        border.width: 1

        Behavior on color {
            ColorAnimation {
                duration: Theme.animFast
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.icon
            font.family: "Material Symbols Rounded"
            font.pixelSize: 30
            color: Theme.textPrimary
        }

        MouseArea {
            id: btnHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clicked()
        }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        text: root.label
        font.pixelSize: Theme.fontSmall
        color: Theme.textMain
    }
}
