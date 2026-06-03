pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Particles
import Quickshell
import Quickshell.Wayland

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
    implicitWidth: 470
    implicitHeight: 390

    property bool shown: false
    property bool everShown: false

    // ── Mask ─────────────────────────────────────────────────────────────
    mask: Region {
        regions: root.shown ? [fullRegion] : [hotZoneRegion]
    }
    // Hot zone: 50px tall so mouse doesn't "fall through" the gap on transition
    Region { id: hotZoneRegion; x: 0; y: 0; width: root.implicitWidth; height: 50 }
    Region { id: fullRegion;    x: 0; y: 0; width: root.implicitWidth; height: root.implicitHeight }

    // ── Rope definitions ──────────────────────────────────────────────────
    readonly property var ropeDefs: [
        { ax: 28,  segs: 10, icon: "󰽧", isz: 26 },
        { ax: 78,  segs: 7,  icon: "󱗃",  isz: 22 },
        { ax: 130, segs: 13, icon: "󰽧", isz: 26 },
        { ax: 183, segs: 8,  icon: "󱗃",  isz: 22 },
        { ax: 238, segs: 14, icon: "󰽧", isz: 26 },
        { ax: 292, segs: 6,  icon: "󱗃",  isz: 22 },
        { ax: 345, segs: 11, icon: "󰽧", isz: 26 },
        { ax: 400, segs: 8,  icon: "󱗃",  isz: 22 },
        { ax: 445, segs: 9,  icon: "󰽧", isz: 26 },
    ]

    readonly property real segLen: 24
    readonly property real grav:   0.18   // reduced — less violent drop
    readonly property real damp:   0.80   // increased — settles faster, no runaway
    readonly property real maxV:   8      // velocity cap — prevents instability

    property var _pts: []
    property var tailsX: []
    property var tailsY: []

    function initRopes() {
        var arr = []
        for (var r = 0; r < ropeDefs.length; r++) {
            var d = ropeDefs[r]
            var seg = []
            for (var i = 0; i <= d.segs; i++) {
                // tiny initial nudge so ropes start swaying, not a big random kick
                seg.push({ x: d.ax + (Math.random()-0.5)*1.5,
                            y: i * segLen, vx: 0, vy: 0 })
            }
            arr.push(seg)
        }
        _pts = arr
        _publishTails()
    }

    function _publishTails() {
        var tx = [], ty = []
        for (var r = 0; r < _pts.length; r++) {
            var tip = _pts[r][_pts[r].length - 1]
            tx.push(tip.x); ty.push(tip.y)
        }
        tailsX = tx; tailsY = ty
    }

    function stepPhysics() {
        var pts = _pts
        var MV  = maxV
        for (var r = 0; r < pts.length; r++) {
            var rope = pts[r]
            var d    = ropeDefs[r]
            rope[0].x = d.ax; rope[0].y = 0
            rope[0].vx = 0;   rope[0].vy = 0

            for (var i = 1; i < rope.length; i++) {
                var p    = rope[i]
                var prev = rope[i - 1]

                var dx = prev.x - p.x
                var dy = prev.y - p.y
                var dist = Math.sqrt(dx*dx + dy*dy) || 1
                var ext  = dist - segLen
                var fx   = (dx / dist) * ext * 0.65   // softer spring
                var fy   = (dy / dist) * ext * 0.65 + grav

                // next-segment spring (weaker, for shape)
                if (i < rope.length - 1) {
                    var nx = rope[i+1].x - p.x
                    var ny = rope[i+1].y - p.y
                    var nd = Math.sqrt(nx*nx + ny*ny) || 1
                    var ne = nd - segLen
                    fx += (nx / nd) * ne * 0.25
                    fy += (ny / nd) * ne * 0.25
                }

                var nvx = p.vx * damp + fx
                var nvy = p.vy * damp + fy
                // velocity cap — the key to preventing runaway
                p.vx = Math.max(-MV, Math.min(MV, nvx))
                p.vy = Math.max(-MV, Math.min(MV, nvy))
                p.x += p.vx
                p.y += p.vy
            }
        }
        _publishTails()
    }

    Component.onCompleted: initRopes()

    // ── Single hover area (covers both trigger strip + content) ───────────
    // Bug fix: one MouseArea eliminates the gap between hotZone and ropesArea
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        // only receives events where mask allows (hotZoneRegion or fullRegion)
        onEntered: {
            hideTimer.stop()
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
        // Cancel hide if mouse re-enters while timer is running
        onContainsMouseChanged: {
            if (containsMouse) hideTimer.stop()
        }
    }

    // ── Content ───────────────────────────────────────────────────────────
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
                    // Beads
                    ctx.fillStyle = "rgba(220,190,255,0.55)"
                    for (var j = 1; j < rope.length - 1; j += 3) {
                        ctx.beginPath()
                        ctx.arc(rope[j].x, rope[j].y, 2.2, 0, Math.PI*2)
                        ctx.fill()
                    }
                    // Anchor dot
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
                text: orn.modelData.icon
                font.family: "Symbols Nerd Font"
                font.pointSize: orn.modelData.isz
                color: Qt.rgba(0.88, 0.74, 1.0, 0.92)
                x: (root.tailsX[orn.index] ?? orn.modelData.ax) - width * 0.5
                y: root.tailsY[orn.index] ?? 0
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

    // Longer hide delay (600ms) avoids edge-case flicker on mask transition
    Timer { id: hideTimer; interval: 600; onTriggered: root.shown = false }
}
