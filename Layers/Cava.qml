import Quickshell
import Quickshell.Wayland
import QtQuick
import CavaMonitor 1.0

Scope {
    id: root

    required property ShellScreen modelData

    CavaMonitor {
        id: cava
        bars: 40
        active: true
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            required property var modelData
            screen: modelData
            color: "transparent"
            implicitHeight: 200
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.namespace: "moon.cava"
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors {
                left: true
                right: true
                bottom: true
            }

            Canvas {
                id: canvas
                anchors.fill: parent

                Connections {
                    target: cava
                    function onValuesChanged() {
                        canvas.requestPaint()
                    }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    drawMountainWave(ctx, cava.values, true)
                    drawMountainWave(ctx, cava.values, false)
                }

                function drawMountainWave(ctx, data, isShadow) {
                    if (!data || data.length < 2) return

var gradient = ctx.createLinearGradient(0, 0, width, 0)
gradient.addColorStop(0.0, Qt.rgba(1, 1, 1, 0.15))
gradient.addColorStop(0.3, Qt.rgba(1, 1, 1, 0.25))
gradient.addColorStop(0.6, Qt.rgba(1, 1, 1, 0.20))
gradient.addColorStop(1.0, Qt.rgba(1, 1, 1, 0.15))

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
                    ctx.moveTo(0, height)

                    var startY = height - (data[0] * height)
                    ctx.lineTo(0, startY)

                    var barWidth = width / (data.length - 1)

                    for (var i = 0; i < data.length - 1; i++) {
                        var xCurr = i * barWidth
                        var yCurr = height - (data[i] * height)
                        var xNext = (i + 1) * barWidth
                        var yNext = height - (data[i + 1] * height)
                        var xMid = (xCurr + xNext) / 2
                        var yMid = (yCurr + yNext) / 2
                        ctx.quadraticCurveTo(xCurr, yCurr, xMid, yMid)
                    }

                    var lastX = (data.length - 1) * barWidth
                    var lastY = height - (data[data.length - 1] * height)
                    ctx.lineTo(lastX, lastY)
                    ctx.lineTo(width, height)
                    ctx.closePath()
                    ctx.fill()

                    if (isShadow) {
                        ctx.restore()
                    }
                }
            }
        }
    }
}
