pragma Singleton
import Quickshell
import QtQuick

// Tema centralizado: paleta, radios, tipografía y animaciones.
QtObject {
    // Fondos
    readonly property color bgDock: Qt.rgba(0.13, 0.13, 0.16, 0.85)
    readonly property color bgCard: Qt.rgba(0.13, 0.13, 0.16, 0.92)
    readonly property color bgField: Qt.rgba(1, 1, 1, 0.07)
    readonly property color bgSelected: Qt.rgba(1, 1, 1, 0.12)
    readonly property color bgHover: Qt.rgba(1, 1, 1, 0.16)
    readonly property color overlayDim: Qt.rgba(0.02, 0.03, 0.08, 0.55)
    readonly property color thumbBg: "#11111b"
    // Texto
    readonly property color textPrimary: "white"
    readonly property color textMain: "#cdd6f4"
    readonly property color textMuted: "#6c7086"
    // Acentos
    readonly property color accentBlue: "#89b4fa"
    readonly property color accentGreen: "#a6e3a1"
    readonly property color accentYellow: "#f9e2af"
    readonly property color badgeRed: "#f38ba8"
    // Franja lateral de la isla extendida
    readonly property color islandSide: "#0a0a0d"
    // Gráficas vista sistema (ref 2.png: CPU rosa, Memory lila, Network azul)
    readonly property color graphCpu: "#f38ba8"
    readonly property color graphMem: "#cba6f7"
    readonly property color graphNet: "#89b4fa"
    // Radios
    readonly property int radiusLarge: 16
    readonly property int radiusMedium: 10
    readonly property int radiusButton: 9
    readonly property int radiusDot: 6
    readonly property int radiusDotSmall: 3
    // Tipografía
    readonly property int fontTitle: 17
    readonly property int fontBody: 15
    readonly property int fontMain: 14
    readonly property int fontSmall: 13
    readonly property int fontTiny: 12
    // Animaciones
    readonly property int animFast: 180
    readonly property int animNormal: 200
    readonly property int animDock: 400
}
