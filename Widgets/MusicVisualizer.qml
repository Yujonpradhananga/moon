import QtQuick

Item {
    id: root

    property var cavaValues: []
    property real waveHeight: 200
    property real arcDepth: 180

        onCavaValuesChanged: canvas.requestPaint()
    Canvas {
        id: canvas
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
height: parent.height


        onPaint: {
            var ctx = getContext('2d')
            ctx.clearRect(0, 0, width, height)
            drawMountainWave(ctx, root.cavaValues, true)
            drawMountainWave(ctx, root.cavaValues, false)
        }

        function drawMountainWave(ctx, data, isShadow) {
            if (!data || data.length < 2) return

            var gradient = ctx.createLinearGradient(0, 0, width, 0)
            gradient.addColorStop(0.0, '#4158D0')
            gradient.addColorStop(0.3, '#C850C0')
            gradient.addColorStop(0.6, '#FFCC70')
            gradient.addColorStop(1.0, '#ffe53b')

            function arcY(x) {
                var normalized = (x / width) * 2.0 - 1.0
                return height - (normalized * normalized * root.arcDepth)
            }

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

            var barWidth = width / (data.length - 1)
            ctx.moveTo(0, arcY(0))

            for (var i = 0; i < data.length - 1; i++) {
                var xCurr = i * barWidth
                var xNext = (i + 1) * barWidth
                var yCurr = arcY(xCurr) - (data[i]     * root.waveHeight)
                var yNext = arcY(xNext) - (data[i + 1] * root.waveHeight)
                ctx.quadraticCurveTo(xCurr, yCurr, (xCurr + xNext) / 2, (yCurr + yNext) / 2)
            }

            var lastX = (data.length - 1) * barWidth
            ctx.lineTo(lastX, arcY(lastX) - (data[data.length - 1] * root.waveHeight))

            for (var j = data.length - 1; j >= 0; j--) {
                ctx.lineTo(j * barWidth, arcY(j * barWidth))
            }

            ctx.closePath()
            ctx.fill()

            if (isShadow) ctx.restore()
        }
    }
}
