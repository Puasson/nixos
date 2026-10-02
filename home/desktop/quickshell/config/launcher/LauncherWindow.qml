import Quickshell
import Quickshell.Wayland
import QtQuick
import "../theme"

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
    focusable: true
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-launcher"

    property int cardW: 470
    property int cardH: 420

    property int focusAttempts: 0
    Timer {
        id: focusTimer
        interval: 120
        repeat: false
        onTriggered: {
            if (!LauncherState.isOpen)
                return;
            searchPanel.focusSearch();
            if (!searchPanel.searchHasFocus && root.focusAttempts < 3) {
                root.focusAttempts++;
                focusTimer.restart();
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            root.focusAttempts = 0;
            focusTimer.restart();
            showAnim.restart();
        } else {
            focusTimer.stop();
        }
    }

    Connections {
        target: LauncherState
        function onIsOpenChanged(): void {
            if (LauncherState.isOpen)
                searchPanel.focusSearch();
        }
    }

    ParallelAnimation {
        id: showAnim
        NumberAnimation {
            target: boxSlide
            property: "y"
            from: 24
            to: 0
            duration: Theme.animNormal
            easing.type: Theme.easeOut
        }
        NumberAnimation {
            target: launcherBox
            property: "opacity"
            from: 0
            to: 1
            duration: Theme.animNormal
            easing.type: Theme.easeOut
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: LauncherState.close()
    }

    Rectangle {
        id: launcherBox
        anchors.centerIn: parent
        width: root.cardW
        height: root.cardH
        radius: Theme.radiusLarge
        color: Theme.bgDock
        clip: true
        focus: true

        transform: Translate {
            id: boxSlide
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

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => mouse.accepted = true
        }

        LauncherPanel {
            id: searchPanel
            anchors.fill: parent
            anchors.margins: 14
        }
    }
}
