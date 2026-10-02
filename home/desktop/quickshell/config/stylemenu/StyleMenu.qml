import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import "../theme"

Scope {
    id: root

    readonly property bool isOpen: StyleMenuState.isOpen
    property int selected: 0
    property var wallpapers: []
    property string currentPath: ""
    property int holdDir: 0
    property bool instantJump: false

    readonly property string wallDir: "/home/sora/Pictures/Wallpaper"
    readonly property string cacheFile: "/home/sora/.cache/quickshell/wallpaper/current"

    function open(): void {
        holdDelay.stop();
        holdTimer.stop();
        root.holdDir = 0;
        root.instantJump = false;
        StyleMenuState.open();
        listProc.running = true;
        currentProc.running = true;
    }
    function close(): void {
        holdDelay.stop();
        holdTimer.stop();
        root.holdDir = 0;
        StyleMenuState.close();
    }
    function toggle(): void {
        if (root.isOpen)
            root.cancel();
        else
            root.open();
    }
    function cancel(): void {
        root.close();
    }
    function pick(fam): void {
        Theme.setFamily(String(fam));
    }
    function toggleDark(): void {
        Theme.toggleMode();
    }
    function applySelected(): void {
        holdDelay.stop();
        holdTimer.stop();
        root.holdDir = 0;
        if (root.wallpapers.length === 0)
            return;
        var item = root.wallpapers[root.selected];
        if (!item)
            return;
        root.currentPath = item.path;
        Quickshell.execDetached(["wallpaper-set", "--persist", item.path]);
        root.close();
    }
    function randomizeAll(): void {
        var fams = Theme.families;
        if (fams.length > 0) {
            var rf = String(fams[Math.floor(Math.random() * fams.length)]);
            Theme.setFamily(rf);
        }
        if (root.wallpapers.length === 0)
            return;
        holdDelay.stop();
        holdTimer.stop();
        root.holdDir = 0;
        root.selected = Math.floor(Math.random() * root.wallpapers.length);
        var item = root.wallpapers[root.selected];
        if (!item)
            return;
        root.currentPath = item.path;
        Quickshell.execDetached(["wallpaper-set", "--persist", item.path]);
        root.close();
    }
    function move(delta): void {
        if (root.wallpapers.length === 0)
            return;
        var n = root.wallpapers.length;
        var next = (root.selected + delta + n) % n;
        var wrapped = (delta > 0 && next < root.selected) || (delta < 0 && next > root.selected);
        root.instantJump = wrapped;
        root.selected = next;
    }

    function isImage(name): bool {
        var l = name.toLowerCase();
        return l.endsWith(".jpg") || l.endsWith(".jpeg") || l.endsWith(".png")
            || l.endsWith(".webp") || l.endsWith(".gif");
    }

    Timer {
        id: holdDelay
        interval: 350
        repeat: false
        onTriggered: holdTimer.start()
    }
    Timer {
        id: holdTimer
        interval: 140
        repeat: true
        onTriggered: {
            if (root.holdDir !== 0)
                root.move(root.holdDir);
        }
    }

    Process {
        id: listProc
        command: ["ls", "-1", root.wallDir]
        stdout: StdioCollector {
            onStreamFinished: {
                var out = [];
                var lines = String(this.text || "").split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var name = lines[i].replace(/\r$/, "");
                    if (name === "" || !root.isImage(name))
                        continue;
                    out.push({ name: name, path: root.wallDir + "/" + name });
                }
                out.sort(function(a, b) {
                    return String(a.name).localeCompare(String(b.name));
                });
                root.wallpapers = out;
                var idx = -1;
                for (var j = 0; j < out.length; j++) {
                    if (out[j].path === root.currentPath) {
                        idx = j;
                        break;
                    }
                }
                root.selected = idx === -1 ? 0 : idx;
            }
        }
    }

    Process {
        id: currentProc
        command: ["cat", root.cacheFile]
        stdout: StdioCollector {
            onStreamFinished: {
                var p = String(this.text || "").replace(/\r?\n$/, "");
                if (p !== "")
                    root.currentPath = p;
                for (var j = 0; j < root.wallpapers.length; j++) {
                    if (root.wallpapers[j].path === root.currentPath) {
                        root.selected = j;
                        break;
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "StyleMenu"

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

    IpcHandler {
        target: "WallpaperMenu"

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
            WlrLayershell.namespace: "quickshell-stylemenu"

            onVisibleChanged: {
                if (visible)
                    card.forceActiveFocus();
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.cancel()
            }

            Item {
                anchors.centerIn: parent
                width: Math.min(parent.width - 80, 1180)
                height: card.implicitHeight

                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse => mouse.accepted = true
                }

                ColumnLayout {
                    id: card
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 10
                    focus: true

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Left) {
                            if (event.isAutoRepeat) {
                                event.accepted = true;
                                return;
                            }
                            root.holdDir = -1;
                            root.move(-1);
                            holdDelay.restart();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Right) {
                            if (event.isAutoRepeat) {
                                event.accepted = true;
                                return;
                            }
                            root.holdDir = 1;
                            root.move(1);
                            holdDelay.restart();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.applySelected();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            root.cancel();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_R) {
                            root.randomizeAll();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_D) {
                            root.toggleDark();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_N) {
                            Theme.nextFamily();
                            event.accepted = true;
                        } else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_7) {
                            var idx = event.key - Qt.Key_1;
                            if (idx < Theme.families.length)
                                root.pick(Theme.families[idx]);
                            event.accepted = true;
                        }
                    }

                    Keys.onReleased: event => {
                        if (event.key === Qt.Key_Left && root.holdDir === -1) {
                            root.holdDir = 0;
                            holdDelay.stop();
                            holdTimer.stop();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Right && root.holdDir === 1) {
                            root.holdDir = 0;
                            holdDelay.stop();
                            holdTimer.stop();
                            event.accepted = true;
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 28

                        ColumnLayout {
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Color Theme"
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontTiny
                            }

                            Row {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 8

                                Repeater {
                                    model: Theme.families

                                    Rectangle {
                                        required property var modelData
                                        required property int index

                                        property string fam: String(modelData)
                                        property bool active: fam === Theme.family
                                        property var prev: Theme.preview(fam, Theme.isDark)

                                        width: 64
                                        height: 30
                                        radius: 15
                                        color: prev.accent
                                        border.color: active ? Theme.accentBlue : Theme.textMuted
                                        border.width: active ? 3 : 1

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.pick(parent.fam)
                                        }
                                    }
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: Theme.familyLabel(Theme.family)
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontTiny
                            }
                        }

                        ColumnLayout {
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Aleatorio"
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontTiny
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 38
                                height: 38
                                radius: 19
                                color: randomHover.containsMouse ? Theme.bgHover : Theme.bgField
                                border.color: Theme.textMuted
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "R"
                                    color: Theme.textPrimary
                                    font.pixelSize: Theme.fontMain
                                    font.bold: true
                                }
                                MouseArea {
                                    id: randomHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.randomizeAll()
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "tema + fondo"
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontTiny
                            }
                        }

                        ColumnLayout {
                            spacing: 4

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Dark Mode"
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontTiny
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 88
                                height: 34
                                radius: 17
                                color: Theme.bgField
                                border.color: Theme.textMuted
                                border.width: 1

                                Rectangle {
                                    width: 26
                                    height: 26
                                    radius: 13
                                    color: Theme.textPrimary
                                    border.color: Theme.textMuted
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: Theme.isDark ? 4 : parent.width - 30

                                    Behavior on x {
                                        NumberAnimation {
                                            duration: Theme.animFast
                                            easing.type: Theme.easeOut
                                        }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    anchors.horizontalCenterOffset: Theme.isDark ? 12 : -12
                                    text: Theme.isDark ? "ON" : "OFF"
                                    color: Theme.textPrimary
                                    font.pixelSize: Theme.fontSmall
                                    font.bold: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.toggleDark()
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: Theme.isDark ? "oscuro" : "claro"
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontTiny
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Fondos"
                            color: Theme.textPrimary
                            font.pixelSize: Theme.fontTitle
                            font.bold: true
                        }
                        Text {
                            text: root.wallpapers.length > 0 ? ("  " + (root.selected + 1) + " / " + root.wallpapers.length) : ""
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontSmall
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: root.wallpapers.length > 0 ? root.wallpapers[root.selected].name : "Sin fondos en ~/Pictures/Wallpaper"
                        color: Theme.textMain
                        font.pixelSize: Theme.fontMain
                        elide: Text.ElideMiddle
                    }

                    ListView {
                        id: strip
                        Layout.fillWidth: true
                        Layout.preferredHeight: 330
                        orientation: ListView.Horizontal
                        clip: false
                        spacing: -34
                        model: root.wallpapers
                        boundsBehavior: Flickable.StopAtBounds
                        interactive: false
                        keyNavigationEnabled: false
                        focus: false
                        currentIndex: root.selected
                        highlightRangeMode: ListView.StrictlyEnforceRange
                        preferredHighlightBegin: width / 2 - 100
                        preferredHighlightEnd: width / 2 + 100
                        highlightMoveDuration: root.instantJump ? 1 : (holdTimer.running ? 100 : Theme.animNormal)
                        highlightMoveVelocity: holdTimer.running ? 2000 : 1200
                        WheelHandler {
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            orientation: Qt.Vertical
                            onWheel: event => {
                                if (event.angleDelta.y < 0)
                                    root.move(1);
                                else if (event.angleDelta.y > 0)
                                    root.move(-1);
                                event.accepted = true;
                            }
                        }

                        Timer {
                            id: centerTimer
                            interval: 90
                            repeat: false
                            onTriggered: strip.positionViewAtIndex(root.selected, ListView.Center)
                        }

                        Connections {
                            target: root
                            function onSelectedChanged() {
                                if (root.instantJump) {
                                    strip.positionViewAtIndex(root.selected, ListView.Center);
                                    root.instantJump = false;
                                    return;
                                }
                                if (!holdTimer.running)
                                    centerTimer.restart();
                            }
                        }

                        onCountChanged: {
                            if (count > 0)
                                strip.positionViewAtIndex(root.selected, ListView.Center);
                        }

                        delegate: Item {
                            required property var modelData
                            required property int index

                            width: 200
                            height: 320

                            property bool isSelected: index === root.selected

                            scale: isSelected ? 1.06 : 0.92
                            opacity: isSelected ? 1.0 : 0.72
                            z: isSelected ? 10 : 0

                            Behavior on scale {
                                NumberAnimation {
                                    duration: Theme.animFast
                                    easing.type: Theme.easeOut
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Theme.animFast
                                    easing.type: Theme.easeHide
                                }
                            }

                            transform: Matrix4x4 {
                                matrix: Qt.matrix4x4(1, -0.18, 0, 27, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 164
                                height: 300
                                radius: Theme.radiusMedium
                                color: Theme.thumbBg
                                border.color: Theme.accentBlue
                                border.width: isSelected ? 3 : 0
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: encodeURI("file://" + modelData.path)
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    smooth: true
                                    mipmap: true
                                    sourceSize.width: 360
                                }

                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 8
                                    width: 12
                                    height: 12
                                    radius: Theme.radiusDot
                                    color: Theme.accentGreen
                                    visible: modelData.path === root.currentPath
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: {
                                    if (root.holdDir !== 0)
                                        return;
                                    if (root.selected !== index)
                                        root.selected = index;
                                }
                                onClicked: {
                                    holdDelay.stop();
                                    holdTimer.stop();
                                    root.holdDir = 0;
                                    root.selected = index;
                                    root.applySelected();
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "←/→ navegar · 1-7 tema · Enter/click aplica fondo · R aleatorio · D oscuro/claro · N siguiente · Esc cierra"
                        color: Theme.textMuted
                        font.pixelSize: Theme.fontTiny
                    }
                }
            }
        }
    }
}
