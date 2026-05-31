// WallpaperEngine.qml
// Shader pipeline:
//   Stage 1 → moon.png (base image)
//   Stage 2 → Optional effect: "motion" | "waterripple" | "cloudy"
//   Stage 3 → Circles overlay
//   Stage 4 → Final water-ripple pass
//   Stage 5 → Parallax (last, mouse-driven, visible output)

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Data as Dat

WlrLayershell {
    id: root

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
        id: img_depth
        source: Qt.resolvedUrl("../Assets/moondepth.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true; visible: false
    }

    Image {
        id: img_circles
        source: Qt.resolvedUrl("../Assets/circle.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true; visible: false
    }

    Image {
        id: img_normal
        source: Qt.resolvedUrl("../Assets/waterripplenormal.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true; visible: false
    }

    Image {
        id: s1_moon
        source: Qt.resolvedUrl("../Assets/moon.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
        visible: false
    }

    ShaderEffectSource {
        id: s1_out
        sourceItem: s1_moon
        anchors.fill: parent
        visible: false
        hideSource: true
    }

    // Stage 2 — Optional effects, all sourcing from s1_out directly
    ShaderEffect {
        id: s3_motion
        anchors.fill: parent
        visible: false

        property var  source:    s1_out
        property var  depthMask: img_depth
        property real time:      0
        property real strength:  0.006
        property real speed:     2.5
        property real frequency: 1.0

        NumberAnimation on time {
            from: 0; to: 1000; duration: 500000
            loops: Animation.Infinite; running: true
        }

        vertexShader:   Qt.resolvedUrl("../Assets/shaders/motion/motion.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../Assets/shaders/motion/motion.frag.qsb")
    }

    ShaderEffect {
        id: s3_waterripple
        anchors.fill: parent
        visible: false

        property var  source:          s1_out
        property var  normalMapSource: img_normal
        property var  trailMap:        s_trail
        property var  depthMask:       img_depth
        property real time:            0
        property real rippleStrength:  0.8
        property real rippleX:         0.5
        property real rippleY:         0.5
        property real rippleAge:       999.0

        NumberAnimation on time {
            from: 0; to: 1000; duration: 100000
            loops: Animation.Infinite; running: true
        }

        vertexShader:   Qt.resolvedUrl("../Assets/shaders/waterripple/waterripple.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../Assets/shaders/waterripple/waterripple.frag.qsb")
    }

    ShaderEffect {
        id: s3_cloudy
        anchors.fill: parent
        visible: false

        property var  source:    s1_out
        property var  depthMask: img_depth
        property real time:      0
        property real strength:  0.006
        property real speed:     2.5
        property real frequency: 1.0

        NumberAnimation on time {
            from: 0; to: 1000; duration: 500000
            loops: Animation.Infinite; running: true
        }

        vertexShader:   Qt.resolvedUrl("../Assets/shaders/cloudy/cloudy.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../Assets/shaders/cloudy/cloudy.frag.qsb")
    }

    ShaderEffectSource {
        id: s3_out
        anchors.fill: parent
        visible: false
        hideSource: true
        sourceItem: {
            switch (Dat.Globals.shaderMode) {
                case "motion":      return s3_motion;
                case "waterripple": return s3_waterripple;
                case "cloudy":      return s3_cloudy;
                default:            return s1_out;
            }
        }
    }

    // Stage 3 — Circles overlay
    ShaderEffect {
        id: s4_circles
        anchors.fill: parent
        visible: false

        property var  source:     s3_out
        property var  circleMask: img_circles
        property real time:       0

        NumberAnimation on time {
            from: 0; to: 1.0; duration: 3000
            loops: Animation.Infinite; running: true
        }

        vertexShader:   Qt.resolvedUrl("../Assets/shaders/waterripple/waterripple.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../Assets/shaders/circle/circles.frag.qsb")
    }

    ShaderEffectSource {
        id: s4_out
        sourceItem: s4_circles
        anchors.fill: parent
        visible: false
        hideSource: true
    }

    Canvas {
        id: s_trail
        anchors.fill: parent
        visible: false
        property var points: []

        function addPoint(x, y) {
            points.push({ x: x, y: y, age: 0.0 });
            if (points.length > 15) points.shift();
        }

        function tick(dt) {
            for (let i = points.length - 1; i >= 0; i--) {
                points[i].age += dt;
                if (points[i].age > 1.0) points.splice(i, 1);
            }
            requestPaint();
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.fillStyle = "rgba(0,0,0,0.06)";
            ctx.fillRect(0, 0, width, height);
            for (const p of points) {
                const a    = (1.0 - p.age) * 0.5;
                const size = 8 + p.age * 15;
                ctx.save();
                ctx.translate(p.x, p.y);
                ctx.rotate(p.x * 0.05 + p.age * 2.0);
                ctx.beginPath();
                ctx.moveTo(0, -size);
                ctx.lineTo(size * 0.866, size * 0.5);
                ctx.lineTo(-size * 0.866, size * 0.5);
                ctx.closePath();
                const g = ctx.createRadialGradient(0, 0, 0, 0, 0, size);
                g.addColorStop(0, `rgba(255,255,255,${a})`);
                g.addColorStop(1, "rgba(255,255,255,0)");
                ctx.fillStyle = g;
                ctx.fill();
                ctx.restore();
            }
        }
    }

    Timer {
        interval: 16; running: true; repeat: true
        onTriggered: s_trail.tick(0.016)
    }

    // Stage 4 — Water ripple pass
    ShaderEffect {
        id: s5_final
        anchors.fill: parent
        visible: false

        property var  source:          s4_out
        property var  normalMapSource: img_normal
        property var  trailMap:        s_trail
        property var  depthMask:       img_depth
        property real time:            0
        property real rippleStrength:  0.8
        property real rippleX:         0.5
        property real rippleY:         0.5
        property real rippleAge:       999.0

        NumberAnimation on time {
            from: 0; to: 1000; duration: 100000
            loops: Animation.Infinite; running: true
        }

        vertexShader:   Qt.resolvedUrl("../Assets/shaders/waterripple/waterripple.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../Assets/shaders/waterripple/waterripple.frag.qsb")
    }

    ShaderEffectSource {
        id: s5_out
        sourceItem: s5_final
        anchors.fill: parent
        visible: false
        hideSource: true
    }

    // Stage 5 — Parallax (final visible output)
    ShaderEffect {
        id: s2_parallax
        anchors.fill: parent
        visible: true

        property var  source:           s5_out
        property real offsetX:          Dat.Globals.mouseOffsetX
        property real offsetY:          Dat.Globals.mouseOffsetY
        property real parallaxStrength: 0.30
        property real aspectRatio:      width / height

        vertexShader:   Qt.resolvedUrl("../Assets/shaders/parallax/parallax.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../Assets/shaders/parallax/parallax.frag.qsb")
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onPositionChanged: (mouse) => {
            Dat.Globals.mouseOffsetX = (mouse.x / width  - 0.5) * 2.0;
            Dat.Globals.mouseOffsetY = (mouse.y / height - 0.5) * 2.0;
            s_trail.addPoint(mouse.x, mouse.y);
        }
    }
}
