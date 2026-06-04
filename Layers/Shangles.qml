pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Particles
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

WlrLayershell {
    id: root
    required property ShellScreen modelData

    screen: modelData
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    layer: WlrLayer.Top
    namespace: "moon.shangles"
    focusable: false
    surfaceFormat.opaque: false

    anchors.top: true
    anchors.right: true
    implicitWidth: 500
    implicitHeight: 390

    property bool shown: false
    property bool everShown: false
    property real ropeOffsetY: 0

    Behavior on ropeOffsetY {
        NumberAnimation { duration: 350; easing.type: Easing.InCubic }
    }

    onShownChanged: {
        ropeOffsetY = shown ? 0 : -implicitHeight
    }

    mask: Region {
        regions: root.shown ? [fullRegion] : [hotZoneRegion]
    }
    Region { id: hotZoneRegion; x: 0; y: 0; width: root.implicitWidth; height: 50 }
    Region { id: fullRegion;    x: 0; y: 0; width: root.implicitWidth; height: root.implicitHeight }

    readonly property var ropeDefs: [
        { ax: 88,  segs: 12, icon: "󰽧", isz: 26 },
        { ax: 118, segs: 9,  icon: "★",  isz: 26 },
        { ax: 170, segs: 15, icon: "󰽧", isz: 26 },
        { ax: 223, segs: 10, icon: "★",  isz: 26 },
        { ax: 278, segs: 16, icon: "",   isz: 26 },
        { ax: 332, segs: 8,  icon: "★",  isz: 26 },
        { ax: 385, segs: 13, icon: "󰽧", isz: 26 },
        { ax: 440, segs: 10, icon: "★",  isz: 26 },
        { ax: 485, segs: 11, icon: "󰽧", isz: 26 },
    ]

    readonly property real segLen: 20
    readonly property real grav:   1
    readonly property real damp:   0.97
    readonly property real maxV:   50

    readonly property real swayAmp:   0.12
    readonly property real swaySpeed: 0.0008
    property real swayT: 0.0

    property var _pts: []
    property var tailsX: []
    property var tailsY: []
    property var tailAngles: []

    function initRopes() {
        var arr = []
        for (var r = 0; r < ropeDefs.length; r++) {
            var d = ropeDefs[r]
            var seg = []
            for (var i = 0; i <= d.segs; i++) {
                seg.push({ x: d.ax, y: root.ropeOffsetY, vx: 0, vy: 0, px: d.ax, py: root.ropeOffsetY })
            }
            arr.push(seg)
        }
        _pts = arr
        _publishTails()
    }

    function _publishTails() {
        var tx = [], ty = [], ta = []
        for (var r = 0; r < _pts.length; r++) {
            var rope = _pts[r]
            var tip  = rope[rope.length - 1]
            var prev = rope[rope.length - 2]
            tx.push(tip.x)
            ty.push(tip.y)
            var adx = tip.x - prev.x
            var ady = tip.y - prev.y
            ta.push(Math.atan2(adx, -ady) * 180 / Math.PI)
        }
        tailsX = tx
        tailsY = ty
        tailAngles = ta
    }

    function stepPhysics() {
        var pts = _pts
        var MV  = maxV
        var SL  = segLen

        swayT += 1

        for (var r = 0; r < pts.length; r++) {
            var rope = pts[r]
            var d    = ropeDefs[r]

            rope[0].x  = d.ax; rope[0].y  = root.ropeOffsetY
            rope[0].vx = 0;    rope[0].vy = 0
            rope[0].px = d.ax; rope[0].py = root.ropeOffsetY

            var phase = r * 0.7

            for (var i = 1; i < rope.length; i++) {
                var p = rope[i]
                var windFactor = i / rope.length
                var wind = Math.sin(swayT * swaySpeed * 1000 + phase) * swayAmp * windFactor
                p.vx += wind
                p.vy += grav
                p.vx *= damp
                p.vy *= damp
                p.vx = Math.max(-MV, Math.min(MV, p.vx))
                p.vy = Math.max(-MV, Math.min(MV, p.vy))
                p.px = p.x
                p.py = p.y
                p.x += p.vx
                p.y += p.vy
            }

            for (var pass = 0; pass < 8; pass++) {
                rope[0].x = d.ax; rope[0].y = root.ropeOffsetY
                for (var i = 1; i < rope.length; i++) {
                    var p    = rope[i]
                    var prev = rope[i - 1]
                    var dx   = p.x - prev.x
                    var dy   = p.y - prev.y
                    var dist = Math.sqrt(dx * dx + dy * dy)
                    if (dist < 0.0001) continue
                    var diff = (dist - SL) / dist
                    if (i === 1) {
                        p.x -= dx * diff
                        p.y -= dy * diff
                    } else {
                        var half = diff * 0.5
                        p.x    -= dx * half
                        p.y    -= dy * half
                        prev.x += dx * half
                        prev.y += dy * half
                    }
                }
            }

            rope[0].x = d.ax; rope[0].y = root.ropeOffsetY

            for (var i = 1; i < rope.length; i++) {
                var p = rope[i]
                p.vx = Math.max(-MV, Math.min(MV, p.x - p.px))
                p.vy = Math.max(-MV, Math.min(MV, p.y - p.py))
            }
        }

        _publishTails()
    }

    Component.onCompleted: initRopes()

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        property real lastMouseX: 0

        onEntered: {
            hideTimer.stop()
            lastMouseX = mouseX
            if (!root.shown) {
                root.initRopes()
                root.shown = true
                if (!root.everShown) {
                    root.everShown = true
                    burstSystem.running = true
                    burstEmitter.burst(55)
                    burstStop.restart()
                }
            }
        }
        onExited: hideTimer.restart()
        onContainsMouseChanged: {
            if (containsMouse) hideTimer.stop()
        }
        onMouseXChanged: {
            var dx = mouseX - lastMouseX
            lastMouseX = mouseX
            var pts = root._pts
            for (var r = 0; r < pts.length; r++) {
                var rope = pts[r]
                var d = root.ropeDefs[r]
                var dist = Math.abs(mouseX - d.ax)
                if (dist < 80) {
                    var influence = (1.0 - dist / 80.0) * 0.4
                    for (var i = 1; i < rope.length; i++) {
                        var factor = (i / rope.length) * influence
                        rope[i].vx += dx * factor
                    }
                }
            }
            root._pts = pts
        }
    }

    Item {
        id: ropesArea
        anchors.fill: parent
        opacity: root.shown ? 1.0 : 0.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

        Timer {
            running: root.shown
            interval: 16; repeat: true
            onTriggered: { root.stepPhysics(); ropeCanvas.requestPaint() }
        }

        Rectangle {
            anchors { top: parent.top; left: parent.left; right: parent.right }
            height: 2; radius: 1
            color: Qt.rgba(0.75, 0.6, 1.0, 0.5)
        }

        Canvas {
            id: ropeCanvas
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var pts = root._pts
                if (!pts || !pts.length) return
                ctx.lineWidth = 2.5; ctx.lineCap = "round"; ctx.lineJoin = "round"

                for (var r = 0; r < pts.length; r++) {
                    var rope = pts[r]
                    if (rope.length < 2) continue
                    ctx.beginPath()
                    ctx.strokeStyle = "rgba(195,158,255,0.75)"
                    ctx.moveTo(rope[0].x, rope[0].y)
                    for (var i = 1; i < rope.length - 1; i++) {
                        var mx = (rope[i].x + rope[i+1].x) * 0.5
                        var my = (rope[i].y + rope[i+1].y) * 0.5
                        ctx.quadraticCurveTo(rope[i].x, rope[i].y, mx, my)
                    }
                    ctx.lineTo(rope[rope.length-1].x, rope[rope.length-1].y)
                    ctx.stroke()
                    ctx.fillStyle = "rgba(220,190,255,0.55)"
                    for (var j = 1; j < rope.length - 1; j += 3) {
                        ctx.beginPath()
                        ctx.arc(rope[j].x, rope[j].y, 2.2, 0, Math.PI*2)
                        ctx.fill()
                    }
                    ctx.beginPath(); ctx.fillStyle = "rgba(200,170,255,0.85)"
                    ctx.arc(rope[0].x, rope[0].y, 3.5, 0, Math.PI*2); ctx.fill()
                }
            }
        }

        Repeater {
            model: root.ropeDefs
            Text {
                id: orn
                required property var modelData
                required property int index
                text: orn.index === 4
                    ? (Hyprland.focusedMonitor?.activeWorkspace?.id ?? "?").toString()
                    : orn.modelData.icon
                font.family: orn.index === 4 ? "" : "Symbols Nerd Font"
                font.pixelSize: orn.modelData.isz * 3
                color: Qt.rgba(0.88, 0.74, 1.0, 0.92)
                x: (root.tailsX[orn.index] ?? orn.modelData.ax) - width * 0.5
                y: (root.tailsY[orn.index] ?? 0) - height * 0.5
                rotation: (root.tailAngles[orn.index] ?? 0) + (orn.index === 4 ? 180 : 0)
                transformOrigin: Item.Center
            }
        }

        ParticleSystem {
            id: burstSystem
            anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width; height: 8; running: false
            ImageParticle {
                groups: ["b"]; source: "qrc:///particleresources/star.png"
                color: "#d4b0ff"; colorVariation: 0.45; alpha: 0.9
                rotationVariation: 360; autoRotation: true; entryEffect: ImageParticle.Fade
            }
            Emitter {
                id: burstEmitter; group: "b"; anchors.fill: parent
                emitRate: 0; lifeSpan: 900; lifeSpanVariation: 400
                size: 22; sizeVariation: 12; endSize: 3
                velocity: AngleDirection { angle: 90; angleVariation: 72; magnitude: 200; magnitudeVariation: 80 }
                acceleration: AngleDirection { angle: 90; magnitude: 50 }
            }
            Timer { id: burstStop; interval: 1500; onTriggered: burstSystem.running = false }
        }
    }

    Timer { id: hideTimer; interval: 600; onTriggered: root.shown = false }
}
