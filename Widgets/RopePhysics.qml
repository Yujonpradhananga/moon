import QtQuick

Item {
    id: physics

    // ── Inputs ────────────────────────────────────────────────────────────
    required property var  ropeDefs
    required property real centerOffset
    required property real anchorY
    required property bool running

    // ── Outputs (bind ornaments to these) ─────────────────────────────────
    property var tailsX:     []
    property var tailsY:     []
    property var tailAngles: []

    // ── Constants ─────────────────────────────────────────────────────────
    readonly property real segLen:    20
    readonly property real grav:      1
    readonly property real damp:      0.97
    readonly property real maxV:      50
    readonly property real swayAmp:   0.12
    readonly property real swaySpeed: 0.0008

    property real swayT: 0.0
    property var  _pts:  []

    // ── Public API ────────────────────────────────────────────────────────
    function init() {
        var arr = []
        for (var r = 0; r < ropeDefs.length; r++) {
            var d  = ropeDefs[r]
            var ax = d.ax + centerOffset
            var ay = anchorY
            var seg = []
            for (var i = 0; i <= d.segs; i++)
                seg.push({ x: ax, y: ay, vx: 0, vy: 0, px: ax, py: ay })
            arr.push(seg)
        }
        _pts = arr
        _pub()
    }

    function _pub() {
        var tx = [], ty = [], ta = []
        for (var r = 0; r < _pts.length; r++) {
            var rope = _pts[r]
            var tip  = rope[rope.length - 1]
            var prev = rope[rope.length - 2]
            tx.push(tip.x); ty.push(tip.y)
            ta.push(Math.atan2(tip.x - prev.x, -(tip.y - prev.y)) * 180 / Math.PI)
        }
        tailsX = tx; tailsY = ty; tailAngles = ta
    }

    function step() {
        var pts = _pts, MV = maxV, SL = segLen
        swayT += 1
        for (var r = 0; r < pts.length; r++) {
            var rope = pts[r], d = ropeDefs[r]
            var ax = d.ax + centerOffset, ay = anchorY
            rope[0].x = ax; rope[0].y = ay
            rope[0].vx = 0; rope[0].vy = 0
            rope[0].px = ax; rope[0].py = ay
            var phase = r * 0.7
            for (var i = 1; i < rope.length; i++) {
                var p = rope[i]
                p.vx += Math.sin(swayT * swaySpeed * 1000 + phase) * swayAmp * (i / rope.length)
                p.vy += grav
                p.vx *= damp; p.vy *= damp
                p.vx = Math.max(-MV, Math.min(MV, p.vx))
                p.vy = Math.max(-MV, Math.min(MV, p.vy))
                p.px = p.x; p.py = p.y
                p.x += p.vx; p.y += p.vy
            }
            for (var pass = 0; pass < 8; pass++) {
                rope[0].x = ax; rope[0].y = ay
                for (var i = 1; i < rope.length; i++) {
                    var p = rope[i], prev = rope[i-1]
                    var dx = p.x - prev.x, dy = p.y - prev.y
                    var dist = Math.sqrt(dx*dx + dy*dy)
                    if (dist < 0.0001) continue
                    var diff = (dist - SL) / dist
                    if (i === 1) { p.x -= dx*diff; p.y -= dy*diff }
                    else {
                        var h = diff * 0.5
                        p.x -= dx*h; p.y -= dy*h
                        prev.x += dx*h; prev.y += dy*h
                    }
                }
            }
            rope[0].x = ax; rope[0].y = ay
            for (var i = 1; i < rope.length; i++) {
                var p = rope[i]
                p.vx = Math.max(-MV, Math.min(MV, p.x - p.px))
                p.vy = Math.max(-MV, Math.min(MV, p.y - p.py))
            }
        }
        _pub()
    }

    // ── 60fps timer ───────────────────────────────────────────────────────
    Timer {
        running: physics.running
        interval: 16; repeat: true
        onTriggered: { physics.step(); canvas.requestPaint() }
    }

    // ── Top rail ──────────────────────────────────────────────────────────

    // ── Rope canvas ───────────────────────────────────────────────────────
    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var pts = physics._pts
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
                    ctx.beginPath(); ctx.arc(rope[j].x, rope[j].y, 2.2, 0, Math.PI*2); ctx.fill()
                }
                ctx.beginPath(); ctx.fillStyle = "rgba(200,170,255,0.85)"
                ctx.arc(rope[0].x, rope[0].y, 3.5, 0, Math.PI*2); ctx.fill()
            }
        }
    }

    // ── Mouse perturbation ────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent; hoverEnabled: true
        property real lastX: 0
        onEntered: { lastX = mouseX }
        onMouseXChanged: {
            var dx = mouseX - lastX; lastX = mouseX
            var pts = physics._pts
            for (var r = 0; r < pts.length; r++) {
                var rope = pts[r]
                var dist = Math.abs(mouseX - (physics.ropeDefs[r].ax + physics.centerOffset))
                if (dist < 80) {
                    var infl = (1.0 - dist / 80.0) * 0.4
                    for (var i = 1; i < rope.length; i++)
                        rope[i].vx += dx * (i / rope.length) * infl
                }
            }
            physics._pts = pts
        }
    }

    Component.onCompleted: init()
}
