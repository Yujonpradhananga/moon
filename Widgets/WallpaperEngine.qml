import QtQuick
import Quickshell
import Quickshell.Wayland

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

    Image {
        id: wallpaperImage
        source: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/raga.jpg"
        anchors.fill: parent
        smooth: true
        mipmap: true
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

    // Canvas paints the mouse trail as a fading white glow
    Canvas {
        id: trailCanvas
        anchors.fill: parent
        visible: false

        property var points: []  // recent mouse positions [{x, y, age}]

        function addPoint(x, y) {
            points.push({ x: x, y: y, age: 0.0 })
            if (points.length > 40) points.shift()  // keep last 40 points
        }

        function tick(dt) {
            // Age all points
            for (let i = points.length - 1; i >= 0; i--) {
                points[i].age += dt
                if (points[i].age > 1.0) points.splice(i, 1)  // remove old ones
            }
            requestPaint()
        }

        onPaint: {
            const ctx = getContext("2d")
            // Fade the whole canvas each frame instead of clearing — creates trail smear
            ctx.fillStyle = "rgba(0, 0, 0, 0.12)"
            ctx.fillRect(0, 0, width, height)

            for (let p of points) {
                const alpha = (1.0 - p.age) * 0.9
                const radius = 18 + p.age * 30  // expands as it fades
                const grad = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, radius)
                grad.addColorStop(0, `rgba(255, 255, 255, ${alpha})`)
                grad.addColorStop(1, "rgba(255, 255, 255, 0)")
                ctx.fillStyle = grad
                ctx.beginPath()
                ctx.arc(p.x, p.y, radius, 0, Math.PI * 2)
                ctx.fill()
            }
        }
    }

    ShaderEffect {
        id: shader
        anchors.fill: parent
        property variant source: wallpaperImage
        property variant normalMapSource: normalMap
        property variant trailMap: trailCanvas
        property real time: 0
        property real rippleStrength: 0.5
        property real rippleX: 0.5
        property real rippleY: 0.5
        property real rippleAge: 999.0

        NumberAnimation on time {
            from: 0
            to: 1000
            duration: 100000
            loops: Animation.Infinite
            running: true
        }

        Timer {
            interval: 16
            running: true
            repeat: true
            onTriggered: trailCanvas.tick(0.016)
        }

        vertexShader: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/waterripple.vert.qsb"
        fragmentShader: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/waterripple.frag.qsb"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton

        onPositionChanged: (mouse) => {
            trailCanvas.addPoint(mouse.x, mouse.y)
        }
    }
}
