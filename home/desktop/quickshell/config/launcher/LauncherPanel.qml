import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../theme"

ColumnLayout {
    id: root
    spacing: 8

    readonly property bool searchHasFocus: searchInput.activeFocus
    property int _focusAttempts: 0

    function focusSearch(): void {
        root._focusAttempts = 0;
        searchInput.forceActiveFocus();
        searchInput.cursorPosition = searchInput.text.length;
        focusRetry.restart();
    }

    Timer {
        id: focusRetry
        interval: 60
        repeat: false
        onTriggered: {
            if (!LauncherState.isOpen)
                return;
            if (searchInput.activeFocus)
                return;
            if (root._focusAttempts >= 4)
                return;
            root._focusAttempts++;
            searchInput.forceActiveFocus();
            focusRetry.restart();
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        radius: Theme.radiusMedium
        color: Theme.bgField

        TextInput {
            id: searchInput
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            verticalAlignment: TextInput.AlignVCenter
            color: Theme.textPrimary
            selectionColor: Theme.accentBlue
            focus: true
            activeFocusOnTab: true
            cursorVisible: activeFocus
            font.pixelSize: Theme.fontBody
            text: LauncherState.query
            onTextChanged: {
                if (LauncherState.query !== text) {
                    LauncherState.query = text;
                    LauncherState.selected = 0;
                }
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Down) {
                    LauncherState.selected = Math.min(LauncherState.selected + 1, LauncherState.visibleResults.length - 1);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Up) {
                    LauncherState.selected = Math.max(LauncherState.selected - 1, 0);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    LauncherState.launch(LauncherState.visibleResults[LauncherState.selected]);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Escape) {
                    LauncherState.close();
                    event.accepted = true;
                }
            }
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: "Buscar aplicación…"
            color: Theme.textMuted
            font.pixelSize: Theme.fontBody
            visible: searchInput.displayText === ""
        }
    }

    Flickable {
        id: resultsFlick
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentHeight: resultsColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        function ensureVisible(idx): void {
            var itemH = 46;
            var y = idx * itemH;
            if (y < contentY)
                contentY = y;
            else if (y + itemH > contentY + height)
                contentY = y + itemH - height;
        }

        onHeightChanged: ensureVisible(LauncherState.selected)

        Column {
            id: resultsColumn
            width: parent.width
            spacing: 2

            Repeater {
                model: LauncherState.visibleResults

                Rectangle {
                    required property var modelData
                    required property int index

                    width: parent.width
                    height: 44
                    radius: Theme.radiusMedium
                    color: index === LauncherState.selected ? Theme.bgSelected : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 12

                        IconImage {
                            implicitWidth: 32
                            implicitHeight: 32
                            source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            text: modelData.name
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontMain
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: LauncherState.selected = index
                        onClicked: LauncherState.launch(modelData)
                    }
                }
            }
        }
    }

    Connections {
        target: LauncherState
        function onIsOpenChanged(): void {
            if (LauncherState.isOpen)
                root.focusSearch();
        }
        function onSelectedChanged(): void {
            resultsFlick.ensureVisible(LauncherState.selected);
        }
        function onVisibleResultsChanged(): void {
            resultsFlick.contentY = 0;
            resultsFlick.ensureVisible(LauncherState.selected);
        }
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        visible: LauncherState.isOpen && LauncherState.visibleResults.length === 0
        text: "Sin resultados"
        color: Theme.textMuted
        font.pixelSize: Theme.fontMain
    }

    Text {
        Layout.alignment: Qt.AlignHCenter
        visible: LauncherState.isOpen && LauncherState.filtered.length > LauncherState.maxResults
        text: "Mostrando " + LauncherState.maxResults + " de " + LauncherState.filtered.length + " — sigue escribiendo para afinar"
        color: Theme.textMuted
        font.pixelSize: Theme.fontTiny
    }
}
