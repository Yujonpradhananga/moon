import QtQuick
import Quickshell
import Quickshell.Wayland
import CavaMonitor 1.0

WlrLayershell {
    id: layerRoot
    required property ShellScreen modelData
    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    layer: WlrLayer.Background
    namespace: "wallpaper.engine"
    screen: modelData

    // ── Images ───────────────────────────────────────────────────────────────
    Image {
        id: depthMapImage
        source: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/moondepth.png"
        anchors.fill: parent
        smooth: true
        mipmap: false
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    Image {
        id: circleMask
        source: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/circle.png"
        anchors.fill: parent
        smooth: true
        mipmap: false
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    Image {
        id: normalMap
        source: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/waterripplenormal.png"
        anchors.fill: parent
        smooth: true
        mipmap: false
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    // ── CavaMonitor lives outside compositeLayer so it stays active ───────────
    CavaMonitor {
        id: cava
        bars: 40
        active: true
    }

    // ── Mouse tracking ────────────────────────────────────────────────────────
    Item {
        id: mouseTracker
        anchors.fill: parent
        property real offsetX: 0
        property real offsetY: 0

        Behavior on offsetX {
            NumberAnimation { duration: 800; easing.type: Easing.OutQuart }
        }
        Behavior on offsetY {
            NumberAnimation { duration: 800; easing.type: Easing.OutQuart }
        }
    }

    // ── Stage 1: Composite (moon + cava + base.png) ───────────────────────────
    Item {
        id: compositeLayer
        anchors.fill: parent
        visible: true
        z:-1

        Image {
            anchors.fill: parent
            source: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/moon.png"
            smooth: true
            mipmap: true
            fillMode: Image.PreserveAspectCrop
        }

        Loader {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height
            source: "file:///home/yujon/Projects/quickshell/moon/Widgets/MusicVisualizer.qml"
            onLoaded: item.cavaValues = Qt.binding(() => cava.values)
        }

        Image {
            anchors.fill: parent
            source: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/base.png"
            smooth: true
            mipmap: true
            fillMode: Image.PreserveAspectCrop
        }
    }

    ShaderEffectSource {
        id: compositeOutput
        sourceItem: compositeLayer
        anchors.fill: parent
        visible: false
        hideSource: false
    }

    // ── Stage 2: Parallax ────────────────────────────────────────────────────
    ShaderEffect {
        id: parallaxShader
        anchors.fill: parent
        visible: false

        property variant source:        compositeOutput
        property real offsetX:          mouseTracker.offsetX
        property real offsetY:          mouseTracker.offsetY
        property real parallaxStrength: 0.30
        property real aspectRatio:      width / height

        vertexShader:   "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/parallax.vert.qsb"
        fragmentShader: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/parallax.frag.qsb"
    }

    ShaderEffectSource {
        id: parallaxOutput
        sourceItem: parallaxShader
        anchors.fill: parent
        visible: false
        hideSource: true
    }

    // ── Stage 3: Circles ─────────────────────────────────────────────────────
    ShaderEffect {
        id: circleShader
        anchors.fill: parent
        visible: false

        property variant source:     parallaxOutput
        property variant circleMask: circleMask
        property real time: 0

        NumberAnimation on time {
            from: 0; to: 1.0
            duration: 3000
            loops: Animation.Infinite
            running: true
        }

        vertexShader:   "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/waterripple.vert.qsb"
        fragmentShader: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/circles.frag.qsb"
    }

    ShaderEffectSource {
        id: circleOutput
        sourceItem: circleShader
        anchors.fill: parent
        visible: false
        hideSource: true
    }

    // ── Trail Canvas ──────────────────────────────────────────────────────────
    Canvas {
        id: trailCanvas
        anchors.fill: parent
        visible: false

        property var points: []

        function addPoint(x, y) {
            points.push({ x: x, y: y, age: 0.0 })
            if (points.length > 15) points.shift()
        }

        function tick(dt) {
            for (let i = points.length - 1; i >= 0; i--) {
                points[i].age += dt
                if (points[i].age > 1.0) points.splice(i, 1)
            }
            requestPaint()
        }

        onPaint: {
            const ctx = getContext("2d")
            ctx.fillStyle = "rgba(0, 0, 0, 0.06)"
            ctx.fillRect(0, 0, width, height)

            for (let p of points) {
                const alpha = (1.0 - p.age) * 0.5
                const size = 8 + p.age * 15

                ctx.save()
                ctx.translate(p.x, p.y)
                ctx.rotate(p.x * 0.05 + p.age * 2.0)

                ctx.beginPath()
                ctx.moveTo(0, -size)
                ctx.lineTo(size * 0.866, size * 0.5)
                ctx.lineTo(-size * 0.866, size * 0.5)
                ctx.closePath()

                const grad = ctx.createRadialGradient(0, 0, 0, 0, 0, size)
                grad.addColorStop(0, `rgba(255, 255, 255, ${alpha})`)
                grad.addColorStop(1, "rgba(255, 255, 255, 0)")
                ctx.fillStyle = grad
                ctx.fill()
                ctx.restore()
            }
        }
    }

    Timer {
        interval: 16
        running: true
        repeat: true
        onTriggered: trailCanvas.tick(0.016)
    }

    // ── Stage 4: Water Ripple ─────────────────────────────────────────────────
    ShaderEffect {
        id: rippleShader
        anchors.fill: parent

        property variant source:          circleOutput
        property variant normalMapSource: normalMap
        property variant trailMap:        trailCanvas
        property variant depthMask:       depthMapImage
        property real time:           0
        property real rippleStrength: 0.8
        property real rippleX:        0.5
        property real rippleY:        0.5
        property real rippleAge:      999.0

        NumberAnimation on time {
            from: 0; to: 1000
            duration: 100000
            loops: Animation.Infinite
            running: true
        }

        vertexShader:   "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/waterripple.vert.qsb"
        fragmentShader: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/waterripple.frag.qsb"
    }

    // ── Mouse Area ────────────────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onPositionChanged: (mouse) => {
            mouseTracker.offsetX = (mouse.x / width  - 0.5) * 2.0
            mouseTracker.offsetY = (mouse.y / height - 0.5) * 2.0
            trailCanvas.addPoint(mouse.x, mouse.y)
        }
    }
}
