import QtQuick 2.15
import Quickshell 0.1

// ─── Root: one ShellWindow per screen ───────────────────────────────────────
ShellWindow {
    id: root

    // ── Put this behind everything ──────────────────────────────────────────
    WaylandLayer.layer: WaylandLayer.Layer.Background
    WaylandLayer.exclusionMode: WaylandLayer.ExclusionMode.Ignore
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }

    // ── Asset paths – adjust to your actual asset directory ─────────────────
    readonly property string assetDir: Qt.resolvedUrl("Assets/mahoraga/")
    readonly property string baseImage:   assetDir + "base.jpg"
    readonly property string normalImage: assetDir + "waterripplenormal.png"

    // ── Shader effect ────────────────────────────────────────────────────────
    ShaderEffect {
        id: ripple
        anchors.fill: parent

        // ── Uniforms fed into the GLSL ──────────────────────────────────────
        property var  source:      baseTexture      // the wallpaper
        property var  normalMap:   normalTexture     // the ripple normal map
        property real time:        0.0              // grows each frame
        property real rippleX:     0.5              // mouse X in 0-1 space
        property real rippleY:     0.5              // mouse Y in 0-1 space
        property real rippleAge:   999.0            // seconds since last click/move; large = invisible
        property real rippleStrength: 0.04          // max displacement from normal map scroll
        property real mouseRippleStrength: 0.06     // max displacement from mouse ripple

        // ── Vertex shader (pass-through, just gives us texCoord) ─────────────
        vertexShader: "
            uniform   highp mat4 qt_Matrix;
            attribute highp vec4 qt_Vertex;
            attribute highp vec2 qt_MultiTexCoord0;
            varying   highp vec2 texCoord;

            void main() {
                texCoord    = qt_MultiTexCoord0;
                gl_Position = qt_Matrix * qt_Vertex;
            }
        "

        // ── Fragment shader ──────────────────────────────────────────────────
        fragmentShader: "
            varying highp vec2 texCoord;

            uniform sampler2D source;
            uniform sampler2D normalMap;
            uniform lowp  float qt_Opacity;
            uniform highp float time;
            uniform highp float rippleX;
            uniform highp float rippleY;
            uniform highp float rippleAge;
            uniform highp float rippleStrength;
            uniform highp float mouseRippleStrength;

            void main() {
                // ── 1. Ambient scrolling water from the normal map ──────────
                //    We scroll two copies at different speeds and directions
                //    and mix them – gives a more organic look than one layer.
                highp vec2 uv = texCoord;

                highp vec2 scroll1 = uv + vec2( time * 0.03,  time * 0.02);
                highp vec2 scroll2 = uv + vec2(-time * 0.02,  time * 0.03);

                // The normal map stores XY bump directions in the R and G channels.
                // We remap from [0,1] → [-1,1] so (0.5,0.5) = no displacement.
                highp vec2 n1 = texture2D(normalMap, scroll1).rg * 2.0 - 1.0;
                highp vec2 n2 = texture2D(normalMap, scroll2).rg * 2.0 - 1.0;
                highp vec2 normalDisplace = (n1 + n2) * 0.5 * rippleStrength;

                // ── 2. Mouse-driven radial ripple ───────────────────────────
                //    Think of dropping a pebble: waves expand outward in rings.
                //    rippleAge tells us how long ago the pebble dropped.
                highp vec2  delta   = uv - vec2(rippleX, rippleY);
                highp float dist    = length(delta);

                // The wave ring: a sine wave that travels outward over time.
                // As age grows the ring gets wider (dist - age*speed) and fades.
                highp float waveFront = dist - rippleAge * 0.4;
                highp float fade      = exp(-rippleAge * 1.8);          // fades over ~0.5s
                highp float ringFade  = exp(-dist * 5.0);               // falls off with distance
                highp float wave      = sin(waveFront * 30.0) * fade * ringFade;

                // Push in the outward direction from the click point
                highp vec2 mouseDisplace = normalize(delta + vec2(0.0001)) * wave * mouseRippleStrength;

                // ── 3. Sample the base image with combined displacement ──────
                highp vec2 finalUV = uv + normalDisplace + mouseDisplace;
                gl_FragColor = texture2D(source, finalUV) * qt_Opacity;
            }
        "

        // ── Hidden image nodes Qt uses to create GPU textures ────────────────
        Image {
            id: baseTexture
            source:  root.baseImage
            visible: false
            // Fill the screen while preserving ratio; shader will handle the rest
            fillMode: Image.PreserveAspectCrop
            width:  ripple.width
            height: ripple.height
        }
        Image {
            id: normalTexture
            source:  root.normalImage
            visible: false
            // Tile the normal map so it repeats across the whole wallpaper
            fillMode: Image.Tile
            width:  ripple.width
            height: ripple.height
        }
    }

    // ── Animation timer: ~60 fps ─────────────────────────────────────────────
    Timer {
        interval: 16          // ~60fps
        running:  true
        repeat:   true
        onTriggered: {
            ripple.time     += 0.016
            ripple.rippleAge += 0.016
        }
    }

    // ── Mouse tracking ────────────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true      // capture movement without clicking

        onPositionChanged: (mouse) => {
            // Convert pixel position to 0-1 UV space
            ripple.rippleX   = mouse.x / width
            ripple.rippleY   = mouse.y / height
            ripple.rippleAge = 0.0    // restart the ripple wave
        }

        // Also trigger on click for a stronger effect
        onClicked: (mouse) => {
            ripple.rippleX   = mouse.x / width
            ripple.rippleY   = mouse.y / height
            ripple.rippleAge = 0.0
        }
    }
}
