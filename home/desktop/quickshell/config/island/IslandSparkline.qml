// Sparkline minimalista estilo 2.png: 1-2 series sobre fondo transparente.
import QtQuick

Item {
    id: root

    property var values: []
    property var values2: []
    property color lineColor: "#f38ba8"
    property color lineColor2: "#a6e3a1"
    // 0 = auto-escala al pico de los datos; >0 fija el máximo (ej. 1.0 para %).
    property real maxValue: 0
    property real lineWidth: 1.5

    readonly property real peak: {
        try {
            var m = 0;
            var a = root.values || [];
            var b = root.values2 || [];
            for (var i = 0; i < a.length; i++)
                if (a[i] > m)
                    m = a[i];
            for (var j = 0; j < b.length; j++)
                if (b[j] > m)
                    m = b[j];
            if (root.maxValue > 0)
                return root.maxValue;
            return Math.max(m, 0.000001);
        } catch (e) {
            return 1;
        }
    }

    function _drawSeries(ctx, arr, color): void {
        try {
            if (!arr || arr.length === 0)
                return;
            var w = root.width;
            var h = root.height;
            var pad = 2;
            ctx.strokeStyle = color;
            ctx.lineWidth = root.lineWidth;
            ctx.lineJoin = "round";
            ctx.lineCap = "round";
            ctx.beginPath();
            if (arr.length === 1) {
                var y0 = h - pad - (Math.max(0, arr[0]) / root.peak) * (h - pad * 2);
                ctx.moveTo(0, y0);
                ctx.lineTo(w, y0);
            } else {
                for (var i = 0; i < arr.length; i++) {
                    var x = (i / (arr.length - 1)) * w;
                    var v = Math.max(0, arr[i]) / root.peak;
                    v = Math.max(0, Math.min(1, v));
                    var y = h - pad - v * (h - pad * 2);
                    if (i === 0)
                        ctx.moveTo(x, y);
                    else
                        ctx.lineTo(x, y);
                }
            }
            ctx.stroke();
        } catch (e) {}
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        renderTarget: Canvas.FramebufferObject
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            // Línea base tenue como en 2.png.
            try {
                ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.12);
                ctx.lineWidth = 1;
                ctx.beginPath();
                ctx.moveTo(0, height - 1.5);
                ctx.lineTo(width, height - 1.5);
                ctx.stroke();
            } catch (e) {}
            root._drawSeries(ctx, root.values, root.lineColor);
            if (root.values2 && root.values2.length > 0)
                root._drawSeries(ctx, root.values2, root.lineColor2);
        }
    }

    onValuesChanged: canvas.requestPaint()
    onValues2Changed: canvas.requestPaint()
    onPeakChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()
    onLineColorChanged: canvas.requestPaint()
    onLineColor2Changed: canvas.requestPaint()
}
