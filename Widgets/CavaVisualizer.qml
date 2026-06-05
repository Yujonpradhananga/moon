import QtQuick
import CavaMonitor 1.0

Item {
    id: root
    clip: false

    CavaMonitor {
        id: cava
        bars: 50
        active: true
    }

    Canvas {
        id: canvas
        clip: false
        anchors.fill: parent

        Connections {
            target: cava
            function onValuesChanged() { canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            drawMountainWave(ctx, cava.values, true)
            drawMountainWave(ctx, cava.values, false)
        }

        function drawMountainWave(ctx, data, isShadow) {
            if (!data || data.length < 2) return

            var hPad     = width * 0.03
            var drawW    = width - 2 * hPad
            var barWidth = drawW / (data.length - 1)
            function xOf(i) { return hPad + i * barWidth }

            // Arc baseline: starts at edgeBase at both edges, dips to smileDip
            // at center.  edgeBase > 0 gives the edge bars headroom to grow into
            // without ever going above y=0.
            var edgeBase = height * 0.18   // edge baseline  (18 % from canvas top)
            var smileDip = height * 0.65   // center baseline (65 % from canvas top)

            function smileY(i) {
                var t = i / (data.length - 1)
                return edgeBase + 4 * t * (1 - t) * (smileDip - edgeBase)
            }

            // headroom = smileY (y-pixels above baseline toward canvas top).
            // factor 0.9 < 1  →  barTopY = smileY*(1−data*0.9) ≥ smileY*0.1 > 0
            // clipping is impossible by construction.
            function barTopY(i) {
                return smileY(i) * (1.0 - data[i] * 0.9)
            }

            var gradient = ctx.createLinearGradient(0, 0, width, 0)
            gradient.addColorStop(0.0, Qt.rgba(1, 1, 1, 0.12))
            gradient.addColorStop(0.3, Qt.rgba(1, 1, 1, 0.25))
            gradient.addColorStop(0.5, Qt.rgba(1, 1, 1, 0.30))
            gradient.addColorStop(0.7, Qt.rgba(1, 1, 1, 0.25))
            gradient.addColorStop(1.0, Qt.rgba(1, 1, 1, 0.12))

            ctx.beginPath()

            if (isShadow) {
                ctx.globalAlpha = 0.3
                ctx.save()
                ctx.translate(0, -10)
                ctx.scale(1.02, 1.05)
            } else {
                ctx.globalAlpha = 1.0
            }

            ctx.fillStyle = gradient

            ctx.moveTo(xOf(0), smileY(0))
            ctx.lineTo(xOf(0), barTopY(0))

            for (var i = 0; i < data.length - 1; i++) {
                var xC = xOf(i),     yC = barTopY(i)
                var xN = xOf(i + 1), yN = barTopY(i + 1)
                ctx.quadraticCurveTo(xC, yC, (xC + xN) / 2, (yC + yN) / 2)
            }

            var last = data.length - 1
            ctx.lineTo(xOf(last), barTopY(last))

            for (var j = last; j >= 0; j--)
                ctx.lineTo(xOf(j), smileY(j))

            ctx.closePath()
            ctx.fill()

            if (isShadow) ctx.restore()
        }
    }
}
