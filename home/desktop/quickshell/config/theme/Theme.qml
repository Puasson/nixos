pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property string family: "abyss-blue"
    property bool isDark: true

    // Mantener en sync con palettes.nix (families/labels).
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

    // Datos en PaletteData (generado por palettes.nix, fuente única).
    function _base(fam, dark): var {
        return PaletteData.base(String(fam), dark ? true : false);
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
