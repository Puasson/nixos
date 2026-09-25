import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    property date baseDate: new Date()
    property int monthOffset: 0

    readonly property var mesesFull: ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"]
    readonly property var diasShort: ["Lu", "Ma", "Mi", "Ju", "Vi", "Sá", "Do"]

    readonly property date shownMonth: {
        var d = new Date(root.baseDate.getFullYear(), root.baseDate.getMonth() + root.monthOffset, 1);
        return d;
    }
    readonly property int firstWeekday: (root.shownMonth.getDay() + 6) % 7
    readonly property int daysInMonth: new Date(root.shownMonth.getFullYear(), root.shownMonth.getMonth() + 1, 0).getDate()
    readonly property int todayDay: root.baseDate.getDate()
    readonly property bool showingCurrentMonth: root.monthOffset === 0

    function cap(s): string {
        try {
            s = String(s);
            return s.charAt(0).toUpperCase() + s.slice(1);
        } catch (e) {
            return "";
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "chevron_left"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 22
                color: Theme.textMuted
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.monthOffset--
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: root.cap(root.mesesFull[root.shownMonth.getMonth()]) + " " + root.shownMonth.getFullYear()
                font.pixelSize: Theme.fontMain
                font.bold: true
                color: Theme.textPrimary
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "chevron_right"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 22
                color: Theme.textMuted
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.monthOffset++
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 2
            columnSpacing: 2

            Repeater {
                model: root.diasShort

                Text {
                    required property string modelData
                    Layout.fillWidth: true
                    text: modelData
                    font.pixelSize: Theme.fontTiny
                    font.bold: true
                    color: Theme.textMuted
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Repeater {
                model: 42

                Rectangle {
                    required property int index

                    property int day: index - root.firstWeekday + 1
                    property bool valid: day >= 1 && day <= root.daysInMonth
                    property bool isToday: valid && root.showingCurrentMonth && day === root.todayDay

                    Layout.fillWidth: true
                    Layout.preferredHeight: 20
                    radius: 6
                    color: isToday ? Theme.accentBlue : "transparent"

                    Text {
                        anchors.centerIn: parent
                        visible: parent.valid
                        text: parent.valid ? parent.day : ""
                        font.pixelSize: Theme.fontTiny
                        font.bold: parent.isToday
                        color: parent.isToday ? "#11111b" : Theme.textMain
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
