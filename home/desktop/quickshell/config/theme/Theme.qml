pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Registro central de temas: 8 familias x claro/oscuro.
// API publica de colores intacta (bgDock, textPrimary, ...): los 13
// archivos consumidores no cambian. Quickshell es la fuente de verdad
// (modo manual): `theme-set` propaga al sistema GTK solo claro/oscuro.
// Root Scope (no QtObject) para poder alojar los Process de restore,
// igual que SysStats.
Scope {
    id: root

    property string family: "catppuccin"
    property bool isDark: true

    readonly property var families: ["catppuccin", "nord", "gruvbox", "tokyonight", "dracula", "everforest", "kanagawa", "rosepine"]
    readonly property var familyLabels: ({
        catppuccin: "Catppuccin",
        nord: "Nord",
        gruvbox: "Gruvbox",
        tokyonight: "Tokyo Night",
        dracula: "Dracula",
        everforest: "Everforest",
        kanagawa: "Kanagawa",
        rosepine: "Rosé Pine"
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

    // Mini-preview para el ThemeMenu (sin cambiar el tema activo).
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

    // Hex con alfa -> color (tintes por familia para bgDock/bgCard).
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

    // Tokens base por familia/modo: bg, side, thumb, text, main, muted,
    // blue, green, yellow, red, violet.
    function _base(fam, dark): var {
        if (fam === "nord") {
            if (dark)
                return { bg: "#2e3440", side: "#232830", thumb: "#3b4252", text: "#eceff4", main: "#e5e9f0", muted: "#7e8aa0", blue: "#88c0d0", green: "#a3be8c", yellow: "#ebcb8b", red: "#bf616a", violet: "#b48ead" };
            return { bg: "#eceff4", side: "#e5e9f0", thumb: "#e5e9f0", text: "#2e3440", main: "#3b4252", muted: "#616e88", blue: "#5e81ac", green: "#7a9a6d", yellow: "#b48a3c", red: "#b3535f", violet: "#8a6fae" };
        }
        if (fam === "gruvbox") {
            if (dark)
                return { bg: "#282828", side: "#1d2021", thumb: "#3c3836", text: "#fbf1c7", main: "#ebdbb2", muted: "#928374", blue: "#83a598", green: "#b8bb26", yellow: "#fabd2f", red: "#fb4934", violet: "#d3869b" };
            return { bg: "#fbf1c7", side: "#ebdbb2", thumb: "#ebdbb2", text: "#3c3836", main: "#504945", muted: "#928374", blue: "#076678", green: "#79740e", yellow: "#b57614", red: "#9d0006", violet: "#8f3f71" };
        }
        if (fam === "tokyonight") {
            if (dark)
                return { bg: "#1a1b26", side: "#16161e", thumb: "#24283b", text: "#c0caf5", main: "#a9b1d6", muted: "#565f89", blue: "#7aa2f7", green: "#9ece6a", yellow: "#e0af68", red: "#f7768e", violet: "#bb9af7" };
            return { bg: "#e1e2e7", side: "#d5d6db", thumb: "#d5d6db", text: "#343b58", main: "#414868", muted: "#6f7392", blue: "#2e7de9", green: "#587539", yellow: "#8c6c3e", red: "#f52a65", violet: "#7048b6" };
        }
        if (fam === "dracula") {
            if (dark)
                return { bg: "#282a36", side: "#21222c", thumb: "#44475a", text: "#f8f8f2", main: "#e8e8f0", muted: "#6272a4", blue: "#8be9fd", green: "#50fa7b", yellow: "#f1fa8c", red: "#ff5555", violet: "#bd93f9" };
            return { bg: "#f8f8f2", side: "#e9e9f2", thumb: "#e9e9f2", text: "#282a36", main: "#44475a", muted: "#6272a4", blue: "#0087bd", green: "#159a4c", yellow: "#7a6d00", red: "#d9374b", violet: "#7158d6" };
        }
        if (fam === "everforest") {
            if (dark)
                return { bg: "#2d353b", side: "#232a2f", thumb: "#3d484d", text: "#d3c6aa", main: "#c9bd9f", muted: "#7a8478", blue: "#7fbbb3", green: "#a7c080", yellow: "#dbbc7f", red: "#e67e80", violet: "#d699b6" };
            return { bg: "#efead4", side: "#e6dfc6", thumb: "#e6dfc6", text: "#5c6a72", main: "#5c6a72", muted: "#939f91", blue: "#3a94c5", green: "#8da101", yellow: "#dfa000", red: "#f85552", violet: "#df69ba" };
        }
        if (fam === "kanagawa") {
            if (dark)
                return { bg: "#1f1f28", side: "#181820", thumb: "#2a2a37", text: "#dcd7ba", main: "#c8c093", muted: "#727169", blue: "#7fb4ca", green: "#98bb6c", yellow: "#e6c384", red: "#e46876", violet: "#957fb8" };
            return { bg: "#f2ecbc", side: "#e7dba0", thumb: "#e7dba0", text: "#545464", main: "#545464", muted: "#837173", blue: "#2574a0", green: "#6f8700", yellow: "#a0712c", red: "#c84053", violet: "#5a4a78" };
        }
        if (fam === "rosepine") {
            if (dark)
                return { bg: "#191724", side: "#11101a", thumb: "#1f1d2e", text: "#e0def4", main: "#e0def4", muted: "#6e6a86", blue: "#c4a7e7", green: "#9ccfd8", yellow: "#f6c177", red: "#eb6f92", violet: "#31748f" };
            return { bg: "#faf4ed", side: "#f2e9e1", thumb: "#fffaf3", text: "#575279", main: "#575279", muted: "#9893a5", blue: "#907aa9", green: "#56949f", yellow: "#ea9d34", red: "#b4637a", violet: "#286983" };
        }
        // catppuccin
        if (dark)
            return { bg: "#1e1e2e", side: "#0a0a0d", thumb: "#11111b", text: "#cdd6f4", main: "#cdd6f4", muted: "#6c7086", blue: "#89b4fa", green: "#a6e3a1", yellow: "#f9e2af", red: "#f38ba8", violet: "#cba6f7" };
        return { bg: "#eff1f5", side: "#e6e9ef", thumb: "#e6e9ef", text: "#4c4f69", main: "#5c5f77", muted: "#9ca0b0", blue: "#1e66f5", green: "#40a02b", yellow: "#df8e1d", red: "#d20f39", violet: "#8839ef" };
    }

    function _resolve(fam, dark): var {
        // Catppuccin oscuro: valores legacy exactos, sin regresion visual.
        if (fam === "catppuccin" && dark) {
            return {
                bgDock: Qt.rgba(0.13, 0.13, 0.16, 0.85),
                bgCard: Qt.rgba(0.13, 0.13, 0.16, 0.92),
                bgField: Qt.rgba(1, 1, 1, 0.07),
                bgSelected: Qt.rgba(1, 1, 1, 0.12),
                bgHover: Qt.rgba(1, 1, 1, 0.16),
                overlayDim: Qt.rgba(0.02, 0.03, 0.08, 0.55),
                thumbBg: "#11111b",
                textPrimary: "white",
                textMain: "#cdd6f4",
                textMuted: "#6c7086",
                accentBlue: "#89b4fa",
                accentGreen: "#a6e3a1",
                accentYellow: "#f9e2af",
                badgeRed: "#f38ba8",
                islandSide: "#0a0a0d",
                graphCpu: "#f38ba8",
                graphMem: "#cba6f7",
                graphNet: "#89b4fa"
            };
        }
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
    // Curvas fluidas 60fps: salida suave (OutExpo) para aparecer/expandir,
    // entrada rápida (OutQuad) para ocultar. Evitar InCubic/InOut que se
    // perciben entrecortadas. Usar en NumberAnimation/SmoothedAnimation.
    readonly property int easeOut: Easing.OutExpo
    readonly property int easeHide: Easing.OutQuad
    readonly property int easeMove: Easing.OutCubic

    // Restaura la ultima seleccion persistida por theme-set / ThemeMenu.
    Process {
        id: familyProc
        command: ["cat", root.familyFile]
        stdout: StdioCollector {
            onStreamFinished: {
                var v = String(this.text || "").replace(/\r?\n$/, "").trim();
                if (v !== "" && root.isValidFamily(v))
                    root.family = v;
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
            }
        }
    }

    Component.onCompleted: {
        familyProc.running = true;
        modeProc.running = true;
    }
}
