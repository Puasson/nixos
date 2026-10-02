import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../theme"
import "../launcher"

PanelWindow {
    id: root

    anchors {
        bottom: true
    }

    margins {
        bottom: 10
    }

    readonly property int compactH: 60
    readonly property int compactW: footerRow.implicitWidth + 24

    implicitWidth: root.compactW
    implicitHeight: root.compactH

    color: "transparent"
    visible: !reallyHidden

    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    focusable: false
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-dock"

    mask: Region {
        item: dockBox
    }

    property int iconSize: 38

    property string screenName: root.screen ? root.screen.name : ""
    readonly property var activeMonitor: Hyprland.monitorFor(root.screen)
    readonly property var tlsArray: {
        try {
            if (!Hyprland.toplevels)
                return [];
            if (Hyprland.toplevels.values !== undefined)
                return Hyprland.toplevels.values;
            return Hyprland.toplevels;
        } catch (e) {
            return [];
        }
    }
    readonly property int windowCount: {
        try {
            if (!root.activeMonitor || !root.activeMonitor.activeWorkspace)
                return 0;
            var tls = root.activeMonitor.activeWorkspace.toplevels;
            if (!tls)
                return 0;
            if (tls.count !== undefined)
                return tls.count;
            if (tls.values !== undefined)
                return tls.values.length;
            return tls.length || 0;
        } catch (e) {
            return 0;
        }
    }
    readonly property bool shouldShow: DockState.shouldShow(root.screenName, root.windowCount)
    property bool reallyHidden: true
    readonly property int hideDelay: 350

    Timer {
        id: hideTimer
        interval: root.hideDelay
        repeat: false
        onTriggered: {
            if (!root.shouldShow)
                hideAnim.restart();
        }
    }

    onShouldShowChanged: {
        if (root.shouldShow) {
            hideAnim.stop();
            hideTimer.stop();
            root.reallyHidden = false;
        } else {
            hideTimer.restart();
        }
    }

    Component.onCompleted: {
        root.reallyHidden = !root.shouldShow;
    }

    onVisibleChanged: {
        if (visible)
            showAnim.restart();
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
            target: dockBox
            property: "opacity"
            from: 0
            to: 1
            duration: Theme.animNormal
            easing.type: Theme.easeOut
        }
    }

    ParallelAnimation {
        id: hideAnim
        NumberAnimation {
            target: boxSlide
            property: "y"
            from: 0
            to: 24
            duration: Theme.animFast
            easing.type: Theme.easeHide
        }
        NumberAnimation {
            target: dockBox
            property: "opacity"
            from: 1
            to: 0
            duration: Theme.animFast
            easing.type: Theme.easeHide
        }
        onFinished: {
            if (!root.shouldShow)
                root.reallyHidden = true;
        }
    }

    property var pinned: DockApps.apps

    function lookupEntry(id) {
        var entry = DesktopEntries.byId(id);
        if (!entry)
            entry = DesktopEntries.heuristicLookup(id);
        return entry;
    }

    function pinnedIcon(id) {
        var entry = root.lookupEntry(id);
        return entry ? entry.icon : String(id);
    }

    function pinnedName(id) {
        var entry = root.lookupEntry(id);
        return entry ? entry.name : String(id);
    }

    function launchPinned(id) {
        var entry = root.lookupEntry(id);
        if (entry)
            entry.execute();
        else
            Quickshell.execDetached(["uwsm", "app", "--", String(id)]);
    }

    function pinnedMatches(appIdLower, pinnedId) {
        var p = String(pinnedId).toLowerCase();
        if (p === "" || appIdLower === "")
            return false;
        if (appIdLower.indexOf(p) !== -1 || p.indexOf(appIdLower) !== -1)
            return true;
        var tokens = p.split(/[^a-z0-9]+/);
        for (var i = 0; i < tokens.length; i++) {
            if (tokens[i].length >= 3 && appIdLower.indexOf(tokens[i]) !== -1)
                return true;
        }
        return false;
    }

    function allToplevels() {
        return root.tlsArray;
    }

    readonly property var matchCache: {
        var c = {};
        try {
            var tls = root.tlsArray;
            for (var p = 0; p < root.pinned.length; p++) {
                var pid = String(root.pinned[p]);
                var out = [];
                for (var i = 0; i < tls.length; i++) {
                    if (pinnedMatches(appIdOf(tls[i]), pid))
                        out.push(tls[i]);
                }
                c[pid] = out;
            }
        } catch (e) {}
        return c;
    }

    function appIdOf(tl) {
        try {
            return (tl && tl.wayland && tl.wayland.appId) ? String(tl.wayland.appId).toLowerCase() : "";
        } catch (e) {
            return "";
        }
    }

    function matchingToplevels(pinnedId) {
        try {
            var hit = root.matchCache[String(pinnedId)];
            return hit ? hit : [];
        } catch (e) {
            return [];
        }
    }

    function isPinnedAppId(appIdLower) {
        for (var i = 0; i < root.pinned.length; i++) {
            if (pinnedMatches(appIdLower, root.pinned[i]))
                return true;
        }
        return false;
    }

    function taskIcon(tl) {
        var appId = "";
        try {
            appId = (tl && tl.wayland && tl.wayland.appId) ? String(tl.wayland.appId) : "";
        } catch (e) {
            appId = "";
        }
        if (appId !== "") {
            var entry = root.lookupEntry(appId);
            if (entry)
                return entry.icon;
        }
        return appId;
    }

    function taskLabel(tl) {
        try {
            if (tl && tl.title)
                return tl.title;
        } catch (e) {}
        return "Ventana";
    }

    Rectangle {
        id: dockBox
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.compactW
        height: root.compactH
        radius: Theme.radiusLarge
        color: Theme.bgDock
        clip: true

        transform: Translate {
            id: boxSlide
        }

        Behavior on width {
            NumberAnimation {
                duration: Theme.animIsland
                easing.type: Theme.easeOut
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Theme.animIsland
                easing.type: Theme.easeOut
            }
        }

        Item {
            id: footerZone
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: root.compactH

            RowLayout {
                id: footerRow
                anchors.centerIn: parent
                spacing: 2

                Repeater {
                    model: root.pinned
                    DockButton {
                        required property var modelData
                        iconSize: root.iconSize
                        iconName: root.pinnedIcon(modelData)
                        tooltipText: root.pinnedName(modelData)
                        running: root.matchingToplevels(modelData).length > 0
                        active: {
                            var tls = root.matchingToplevels(modelData);
                            for (var i = 0; i < tls.length; i++) {
                                try {
                                    if (tls[i].activated)
                                        return true;
                                } catch (e) {}
                            }
                            return false;
                        }
                        onClicked: {
                            var tls = root.matchingToplevels(modelData);
                            if (tls.length > 0 && tls[0].wayland) {
                                tls[0].wayland.activate();
                            } else {
                                root.launchPinned(modelData);
                            }
                        }
                        onMiddleClicked: {
                            var tls = root.matchingToplevels(modelData);
                            if (tls.length > 0 && tls[0].wayland)
                                tls[0].wayland.close();
                        }
                    }
                }

                Repeater {
                    model: Hyprland.toplevels
                    DockButton {
                        required property var modelData
                        iconSize: root.iconSize
                        visible: {
                            var appId = "";
                            try {
                                appId = (modelData && modelData.wayland && modelData.wayland.appId) ? String(modelData.wayland.appId).toLowerCase() : "";
                            } catch (e) {}
                            if (appId === "")
                                return false;
                            return !root.isPinnedAppId(appId);
                        }
                        iconName: root.taskIcon(modelData)
                        tooltipText: root.taskLabel(modelData)
                        running: true
                        active: {
                            try {
                                return !!modelData.activated;
                            } catch (e) {
                                return false;
                            }
                        }
                        onClicked: {
                            try {
                                if (modelData.wayland)
                                    modelData.wayland.activate();
                            } catch (e) {}
                        }
                        onMiddleClicked: {
                            try {
                                if (modelData.wayland)
                                    modelData.wayland.close();
                            } catch (e) {}
                        }
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    width: 1
                    height: 28
                    color: Qt.rgba(1, 1, 1, 0.1)
                }

                Item {
                    width: 52
                    height: 48

                    Rectangle {
                        anchors.centerIn: parent
                        width: 40
                        height: 40
                        radius: 12
                        color: gridHover.containsMouse ? Theme.bgHover : "transparent"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "apps"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 24
                        color: LauncherState.isOpen ? Theme.accentBlue : Theme.textPrimary
                    }

                    MouseArea {
                        id: gridHover
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: LauncherState.toggle()
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            hoverEnabled: true
            onContainsMouseChanged: DockState.setDockHovered(root.screenName, containsMouse)
        }
    }
}
