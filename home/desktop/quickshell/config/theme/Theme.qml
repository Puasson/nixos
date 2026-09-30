pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property string family: "abyss-blue"
    property bool isDark: true

    readonly property var families: ["abyss-blue", "forest-green", "violet-haze", "holst-red", "holst-amber", "mono", "sakura"]
    readonly property var familyLabels: ({
        "abyss-blue": "Abyss Blue",
        "forest-green": "Forest Green",
        "violet-haze": "Violet Haze",
        "holst-red": "Holst Red",
        "holst-amber": "Holst Amber",
        mono: "Mono",
        sakura: "Sakura"
    })

    readonly property string cacheDir: "/home/sora/.cache/quickshell/theme"
    readonly property string familyFile: "/home/sora/.cache/quickshell/theme/family"
    readonly property string modeFile: "/home/sora/.cache/quickshell/theme/mode"

    function familyLabel(fam): string {
        var l = root.familyLabels[fam];
        return l !== undefined ? String(l) : String(fam);
    }

    function modeName(): string {
        return root.isDark ? "dark" : "light";
    }

    function isValidFamily(fam): bool {
        return root.families.indexOf(String(fam)) !== -1;
    }

    function setFamily(fam): bool {
        fam = String(fam);
        if (!root.isValidFamily(fam))
            return false;
        if (root.family === fam)
            return true;
        root.family = fam;
        root._persist();
        root._queueSysSync();
        return true;
    }

    function setMode(mode): bool {
        var dark = root.isDark;
        if (mode === true || mode === "dark" || mode === "oscuro")
            dark = true;
        else if (mode === false || mode === "light" || mode === "claro")
            dark = false;
        else if (mode === "toggle")
            dark = !root.isDark;
        else
            return false;
        if (root.isDark === dark)
            return true;
        root.isDark = dark;
        root._persist();
        root._queueSysSync();
        return true;
    }

    function toggleMode(): bool {
        return root.setMode("toggle");
    }

    function nextFamily(): string {
        var i = root.families.indexOf(root.family);
        var next = root.families[(i + 1 + root.families.length) % root.families.length];
        root.setFamily(next);
        return next;
    }

    function preview(fam, dark): var {
        var b = root._base(String(fam), dark ? true : false);
        return {
            bg: b.bg,
            accent: b.blue,
            text: dark ? "white" : b.text
        };
    }

    function _persist(): void {
        try {
            Quickshell.execDetached(["sh", "-c", "mkdir -p '" + root.cacheDir + "' && printf '%s' '" + root.family + "' > '" + root.familyFile + "' && printf '%s' '" + root.modeName() + "' > '" + root.modeFile + "'"]);
        } catch (e) {}
    }

    function _queueSysSync(): void {
        sysSyncTimer.restart();
    }

    Timer {
        id: sysSyncTimer
        interval: 350
        repeat: false
        onTriggered: {
            try {
                Quickshell.execDetached(["theme-apply", root.family, root.modeName()]);
            } catch (e) {}
        }
    }

    function _a(hex, alpha): color {
        try {
            var h = String(hex).replace("#", "");
            if (h.length === 3)
                h = h[0] + h[0] + h[1] + h[1] + h[2] + h[2];
            var r = parseInt(h.substr(0, 2), 16) / 255;
            var g = parseInt(h.substr(2, 2), 16) / 255;
            var b = parseInt(h.substr(4, 2), 16) / 255;
            return Qt.rgba(r, g, b, alpha);
        } catch (e) {
            return hex;
        }
    }

    function _base(fam, dark): var {
        if (fam === "abyss-blue") {
            if (dark)
                return { bg: "#021024", side: "#010913", thumb: "#052659", text: "#C1E8FF", main: "#7DA0CA", muted: "#5E84AD", blue: "#7DA0CA", green: "#5483B3", yellow: "#C1E8FF", red: "#4A7BA8", violet: "#9ABEDD" };
            return { bg: "#C1E8FF", side: "#A9CCE8", thumb: "#A9CCE8", text: "#021024", main: "#052659", muted: "#4E6E96", blue: "#16406E", green: "#2F5D8A", yellow: "#5B7FA6", red: "#0B2F57", violet: "#3E6E9E" };
        }
        if (fam === "forest-green") {
            if (dark)
                return { bg: "#051F20", side: "#020E0F", thumb: "#0B2B26", text: "#DAF1DE", main: "#BEB69B", muted: "#7BA493", blue: "#9DC4B0", green: "#BEB69B", yellow: "#DAF1DE", red: "#5E8A7A", violet: "#8AB5A3" };
            return { bg: "#DAF1DE", side: "#C2DCC7", thumb: "#C2DCC7", text: "#051F20", main: "#0B2B26", muted: "#4E7367", blue: "#163832", green: "#235347", yellow: "#4A7A62", red: "#0B2B26", violet: "#386153" };
        }
        if (fam === "violet-haze") {
            if (dark)
                return { bg: "#49225B", side: "#2A1237", thumb: "#6E3482", text: "#F5EBFA", main: "#E7DBEF", muted: "#B48AC9", blue: "#A56ABD", green: "#C49BD8", yellow: "#F5EBFA", red: "#8A4FA3", violet: "#D0B3E3" };
            return { bg: "#F5EBFA", side: "#E7DBEF", thumb: "#E7DBEF", text: "#2A1237", main: "#49225B", muted: "#7E5A94", blue: "#49225B", green: "#6E3482", yellow: "#8A68A8", red: "#331640", violet: "#7A4E94" };
        }
        if (fam === "holst-red") {
            if (dark)
                return { bg: "#4B0F1E", side: "#24060E", thumb: "#6D1D32", text: "#F7D6DC", main: "#E07A94", muted: "#C06A80", blue: "#E07A94", green: "#CC5671", yellow: "#F7D6DC", red: "#B23C59", violet: "#D98AA0" };
            return { bg: "#F7D6DC", side: "#EAC0C7", thumb: "#EAC0C7", text: "#2E0812", main: "#4B0F1E", muted: "#8A5560", blue: "#4B0F1E", green: "#6D1D32", yellow: "#8E4A5A", red: "#2E0812", violet: "#8E2B44" };
        }
        if (fam === "holst-amber") {
            if (dark)
                return { bg: "#2A2206", side: "#1A1504", thumb: "#5A4A0D", text: "#FFF3D8", main: "#F3D789", muted: "#D0A94E", blue: "#F3D789", green: "#E8B84A", yellow: "#FFF3D8", red: "#CC961F", violet: "#DDBB6A" };
            return { bg: "#FFF3D8", side: "#F0DC9F", thumb: "#F0DC9F", text: "#2A2206", main: "#5A4A0D", muted: "#8A6E22", blue: "#5A4A0D", green: "#7A5E12", yellow: "#8A6E22", red: "#2A2206", violet: "#A67917" };
        }
        if (fam === "mono") {
            if (dark)
                return { bg: "#06151E", side: "#02090D", thumb: "#2A3438", text: "#FFFFFF", main: "#D6D6D6", muted: "#898A8C", blue: "#D6D6D6", green: "#9AA0A2", yellow: "#FFFFFF", red: "#7E8587", violet: "#B8BDC0" };
            return { bg: "#FFFFFF", side: "#D6D6D6", thumb: "#D6D6D6", text: "#06151E", main: "#2A3438", muted: "#6E7375", blue: "#06151E", green: "#2E383C", yellow: "#545A5B", red: "#1A2A33", violet: "#3E4A50" };
        }
        if (fam === "sakura") {
            if (dark)
                return { bg: "#240B0E", side: "#150608", thumb: "#4A222B", text: "#FFDADD", main: "#FAA3AF", muted: "#B07A86", blue: "#C9CCEC", green: "#FAA3AF", yellow: "#FFDADD", red: "#E07A94", violet: "#C48A99" };
            return { bg: "#FFDADD", side: "#EFC2C8", thumb: "#EFC2C8", text: "#240B0E", main: "#5A2E38", muted: "#8A6470", blue: "#4A5A9E", green: "#7F4D5E", yellow: "#A86A78", red: "#5A1A26", violet: "#8A4E62" };
        }
        // Fallback: abyss-blue dark (nunca deberia alcanzarse, families valida antes)
        if (dark)
            return { bg: "#021024", side: "#010913", thumb: "#052659", text: "#C1E8FF", main: "#7DA0CA", muted: "#5E84AD", blue: "#7DA0CA", green: "#5483B3", yellow: "#C1E8FF", red: "#4A7BA8", violet: "#9ABEDD" };
        return { bg: "#C1E8FF", side: "#A9CCE8", thumb: "#A9CCE8", text: "#021024", main: "#052659", muted: "#4E6E96", blue: "#16406E", green: "#2F5D8A", yellow: "#5B7FA6", red: "#0B2F57", violet: "#3E6E9E" };
    }

    function _resolve(fam, dark): var {
        var p = root._base(fam, dark);
        return {
            bgDock: root._a(p.bg, dark ? 0.85 : 0.88),
            bgCard: root._a(p.bg, dark ? 0.92 : 0.95),
            bgField: dark ? Qt.rgba(1, 1, 1, 0.07) : Qt.rgba(0, 0, 0, 0.06),
            bgSelected: dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.10),
            bgHover: dark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.15),
            overlayDim: dark ? Qt.rgba(0.02, 0.03, 0.08, 0.55) : Qt.rgba(0.30, 0.31, 0.35, 0.45),
            thumbBg: p.thumb,
            textPrimary: dark ? "white" : p.text,
            textMain: p.main,
            textMuted: p.muted,
            accentBlue: p.blue,
            accentGreen: p.green,
            accentYellow: p.yellow,
            badgeRed: p.red,
            islandSide: p.side,
            graphCpu: p.red,
            graphMem: p.violet,
            graphNet: p.blue
        };
    }

    property var current: root._resolve(root.family, root.isDark)

    readonly property color bgDock: root.current.bgDock
    readonly property color bgCard: root.current.bgCard
    readonly property color bgField: root.current.bgField
    readonly property color bgSelected: root.current.bgSelected
    readonly property color bgHover: root.current.bgHover
    readonly property color overlayDim: root.current.overlayDim
    readonly property color thumbBg: root.current.thumbBg
    readonly property color textPrimary: root.current.textPrimary
    readonly property color textMain: root.current.textMain
    readonly property color textMuted: root.current.textMuted
    readonly property color accentBlue: root.current.accentBlue
    readonly property color accentGreen: root.current.accentGreen
    readonly property color accentYellow: root.current.accentYellow
    readonly property color badgeRed: root.current.badgeRed
    readonly property color islandSide: root.current.islandSide
    readonly property color graphCpu: root.current.graphCpu
    readonly property color graphMem: root.current.graphMem
    readonly property color graphNet: root.current.graphNet
    readonly property int radiusLarge: 16
    readonly property int radiusMedium: 10
    readonly property int radiusButton: 9
    readonly property int radiusDot: 6
    readonly property int radiusDotSmall: 3
    readonly property int fontTitle: 17
    readonly property int fontBody: 15
    readonly property int fontMain: 14
    readonly property int fontSmall: 13
    readonly property int fontTiny: 12
    readonly property int animFast: 150
    readonly property int animNormal: 220
    readonly property int animIsland: 280
    readonly property int animDock: 350
    readonly property int easeOut: Easing.OutExpo
    readonly property int easeHide: Easing.OutQuad
    readonly property int easeMove: Easing.OutCubic

    // Restore de la ultima seleccion (theme-set / ThemeMenu): al completar
    // ambos ficheros se hace UN sync al sistema via _queueSysSync, para que
    // las apps converjan tambien al reiniciar el shell. Sin loop:
    // theme-apply no toca family/mode.
    property bool _famDone: false
    property bool _modeDone: false
    property bool _restoreSynced: false

    function _maybeRestoreSync(): void {
        if (root._restoreSynced || !root._famDone || !root._modeDone)
            return;
        root._restoreSynced = true;
        root._queueSysSync();
    }

    Process {
        id: familyProc
        command: ["cat", root.familyFile]
        stdout: StdioCollector {
            onStreamFinished: {
                var v = String(this.text || "").replace(/\r?\n$/, "").trim();
                if (v !== "" && root.isValidFamily(v))
                    root.family = v;
                root._famDone = true;
                root._maybeRestoreSync();
            }
        }
    }

    Process {
        id: modeProc
        command: ["cat", root.modeFile]
        stdout: StdioCollector {
            onStreamFinished: {
                var v = String(this.text || "").replace(/\r?\n$/, "").trim();
                if (v === "dark" || v === "light")
                    root.isDark = (v === "dark");
                root._modeDone = true;
                root._maybeRestoreSync();
            }
        }
    }

    // Respaldo: si algun restore no dispara onStreamFinished, converger
    // igual una vez (no-op si _maybeRestoreSync ya corrio).
    Timer {
        id: restoreFallback
        interval: 3000
        repeat: false
        running: true
        onTriggered: {
            root._famDone = true;
            root._modeDone = true;
            root._maybeRestoreSync();
        }
    }

    Component.onCompleted: {
        familyProc.running = true;
        modeProc.running = true;
    }
}
