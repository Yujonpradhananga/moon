// WallpaperEngine.qml
// Shader pipeline:
//   Stage 1 → moon.png (base image)
//   Stage 2 → Parallax (always on, mouse-driven via internal MouseArea)
//   Stage 3 → Optional effect: "motion" | "waterripple"
//   Stage 4 → Circles overlay
//   Stage 5 → Final water-ripple pass

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

    // ─────────────────────────────────────────────────────────────────────────
    // Assets — invisible, used only as sampler inputs
    // ─────────────────────────────────────────────────────────────────────────

    Image {
        id: img_depth
        source: Qt.resolvedUrl("../Assets/mahoraga/moondepth.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true; visible: false
    }

    Image {
        id: img_circles
        source: Qt.resolvedUrl("../Assets/mahoraga/circle.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true; visible: false
    }

    Image {
        id: img_normal
        source: Qt.resolvedUrl("../Assets/mahoraga/waterripplenormal.png")
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true; visible: false
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Stage 1 — Base image (moon.png only)
    // ─────────────────────────────────────────────────────────────────────────

    Image {
        id: s1_moon
        source: Qt.resolvedUrl("../Assets/mahoraga/moon.png")
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

    // ─────────────────────────────────────────────────────────────────────────
    // Stage 2 — Parallax (always active)
    // IMPORTANT: driven by internal mouse tracking, NOT SidePanel.
    // WallpaperEngine is at WlrLayer.Background so its MouseArea always
    // receives hover events regardless of SidePanel's input mask.
    // ─────────────────────────────────────────────────────────────────────────

    ShaderEffect {
        id: s2_parallax
        anchors.fill: parent
        visible: false

        property var  source:           s1_out
        property real offsetX:          Dat.Globals.mouseOffsetX
        property real offsetY:          Dat.Globals.mouseOffsetY
        property real parallaxStrength: 0.30
        property real aspectRatio:      width / height

        vertexShader:   Qt.resolvedUrl("../Assets/mahoraga/parallax.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../Assets/mahoraga/parallax.frag.qsb")
    }

    ShaderEffectSource {
        id: s2_out
        sourceItem: s2_parallax
        anchors.fill: parent
        visible: false
        hideSource: true
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Stage 3 — Optional effect stacked on top of parallax
    // "motion"      → expanding concentric ripple rings, depth-masked
    // "waterripple" → scrolling normal-map distortion, depth-masked
    // ─────────────────────────────────────────────────────────────────────────

    ShaderEffect {
        id: s3_motion
        anchors.fill: parent
        visible: false

        property var  source:    s2_out
        property var  depthMask: img_depth
        property real time:      0
        property real strength:  0.006
        property real speed:     2.5
        property real frequency: 1.0

        NumberAnimation on time {
            from: 0; to: 1000; duration: 500000
            loops: Animation.Infinite; running: true
        }

        vertexShader:   Qt.resolvedUrl("../Assets/mahoraga/motion.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../Assets/mahoraga/motion.frag.qsb")
    }

    ShaderEffect {
        id: s3_waterripple
        anchors.fill: parent
        visible: false

        property var  source:          s2_out
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

        vertexShader:   Qt.resolvedUrl("../Assets/mahoraga/waterripple.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../Assets/mahoraga/waterripple.frag.qsb")
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
                default:            return s2_parallax;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Stage 4 — Circle overlay
    // ─────────────────────────────────────────────────────────────────────────

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

        vertexShader:   Qt.resolvedUrl("../Assets/mahoraga/waterripple.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../Assets/mahoraga/circles.frag.qsb")
    }

    ShaderEffectSource {
        id: s4_out
        sourceItem: s4_circles
        anchors.fill: parent
        visible: false
        hideSource: true
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Trail canvas — cursor trail glyph, sampled by Stage 5
    // ─────────────────────────────────────────────────────────────────────────

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

    // ─────────────────────────────────────────────────────────────────────────
    // Stage 5 — Final water-ripple pass (rendered to screen)
    // ─────────────────────────────────────────────────────────────────────────

    ShaderEffect {
        id: s5_final
        anchors.fill: parent

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

        vertexShader:   Qt.resolvedUrl("../Assets/mahoraga/waterripple.vert.qsb")
        fragmentShader: Qt.resolvedUrl("../Assets/mahoraga/waterripple.frag.qsb")
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Mouse tracking — MUST stay here in WallpaperEngine (Background layer).
    // SidePanel has an input mask so it can't track mouse when menu is closed.
    // This MouseArea always fires, updating parallax offsets continuously.
    // ─────────────────────────────────────────────────────────────────────────

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onPositionChanged: (mouse) => {
            // Stage 2: parallax offset (smoothed via Behavior in Globals)
            Dat.Globals.mouseOffsetX = (mouse.x / width  - 0.5) * 2.0;
            Dat.Globals.mouseOffsetY = (mouse.y / height - 0.5) * 2.0;
            // Stage 5: cursor trail
            s_trail.addPoint(mouse.x, mouse.y);
        }
    }
}
