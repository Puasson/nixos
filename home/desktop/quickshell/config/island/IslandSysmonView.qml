// Vista de sistema estilo 2.png (compacto 548x232):
// tarjetas CPU | Memory + Network full-width con sparklines (SysStats).
import QtQuick
import QtQuick.Layouts
import "../theme"

Item {
    id: root

    function pctText(v): string {
        return Math.round(v * 100) + "%";
    }

    function rateText(b): string {
        try {
            var v = Math.max(0, b);
            if (v < 1024)
                return Math.round(v) + " B/s";
            if (v < 1024 * 1024) {
                var k = v / 1024;
                return (k >= 100 ? Math.round(k) : (Math.round(k * 10) / 10)) + " KiB/s";
            }
            var m = v / (1024 * 1024);
            return (m >= 100 ? Math.round(m) : (Math.round(m * 10) / 10)) + " MiB/s";
        } catch (e) {
            return "—";
        }
    }

    function memShort(): string {
        // SysStats.memText = "usado / total MiB" → "x.x GiB · NN%"
        try {
            var parts = String(SysStats.memText).split("/");
            if (parts.length !== 2)
                return root.pctText(SysStats.memPct);
            var usedMiB = parseFloat(parts[0]);
            var gib = usedMiB / 1024;
            var gibTxt = gib >= 10 ? (Math.round(gib * 10) / 10) + " GiB" : (Math.round(gib * 100) / 100) + " GiB";
            return gibTxt + " · " + root.pctText(SysStats.memPct);
        } catch (e) {
            return root.pctText(SysStats.memPct);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // Fila superior: CPU | Memory (~60% de 196px útiles)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 118
            spacing: 8

            // Tarjeta CPU
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusMedium
                color: Theme.bgField

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            Layout.fillWidth: true
                            text: "CPU"
                            font.pixelSize: Theme.fontSmall
                            font.bold: true
                            color: Theme.textPrimary
                        }
                        Text {
                            text: root.pctText(SysStats.cpuPct)
                            font.pixelSize: Theme.fontSmall
                            font.bold: true
                            color: Theme.graphCpu
                        }
                    }

                    IslandSparkline {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        values: SysStats.cpuHist
                        lineColor: Theme.graphCpu
                        maxValue: 1
                    }
                }
            }

            // Tarjeta Memory
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.radiusMedium
                color: Theme.bgField

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            Layout.fillWidth: true
                            text: "Memory"
                            font.pixelSize: Theme.fontSmall
                            font.bold: true
                            color: Theme.textPrimary
                            elide: Text.ElideRight
                        }
                        Text {
                            text: root.memShort()
                            font.pixelSize: Theme.fontTiny
                            color: Theme.graphMem
                            elide: Text.ElideRight
                        }
                    }

                    IslandSparkline {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        values: SysStats.memHist
                        lineColor: Theme.graphMem
                        maxValue: 1
                    }
                }
            }
        }

        // Fila inferior: Network full-width (~40%)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 70
            radius: Theme.radiusMedium
            color: Theme.bgField

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        Layout.fillWidth: true
                        text: "Network"
                        font.pixelSize: Theme.fontSmall
                        font.bold: true
                        color: Theme.textPrimary
                    }
                    Text {
                        text: "↓ " + root.rateText(SysStats.netDown) + "  ↑ " + root.rateText(SysStats.netUp)
                        font.pixelSize: Theme.fontTiny
                        color: Theme.graphNet
                    }
                }

                IslandSparkline {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    values: SysStats.netDownHist
                    values2: SysStats.netUpHist
                    lineColor: Theme.graphNet
                    lineColor2: Theme.accentGreen
                    maxValue: 0
                }
            }
        }
    }
}
