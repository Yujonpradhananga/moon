pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Particles
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Data as Dat
import qs.Widgets as Wid

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
    anchors.left: true
    anchors.right: true
    implicitHeight: 390

    // ── State ──────────────────────────────────────────────────────────────
    property bool shown: false
    property bool everShown: false

    readonly property int  barHeight:    46
    readonly property real centerOffset: (root.width - 460) / 2

    property real ropeOffsetY: -implicitHeight
    onShownChanged: {
        if (shown) ropeOffsetY = barHeight
    }

    // ── Window-presence detection ──────────────────────────────────────────
    readonly property HyprlandMonitor hyprMonitor: Hyprland.monitorFor(root.screen)
    readonly property bool hasWindows: (root.hyprMonitor?.activeWorkspace?.lastIpcObject?.windows ?? 0) > 0

    onHasWindowsChanged: {
        if (hasWindows && root.shown) {
            ropeOffsetY = -implicitHeight
            hideTimer.restart()
            Dat.Globals.shanglesOpen = false
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event: HyprlandEvent): void {
            const n = event.name
            if (n.includes("window") || n.includes("workspace") || n.includes("mon")) {
                Hyprland.refreshWorkspaces()
                Hyprland.refreshMonitors()
            }
        }
    }

    // ── Hide timer ─────────────────────────────────────────────────────────
    Timer {
        id: hideTimer
        interval: 350
        onTriggered: root.shown = false
    }

    // ── Toggle via clock click ─────────────────────────────────────────────
    readonly property bool globallyTriggered: Dat.Globals.shanglesOpen
onGloballyTriggeredChanged: {
    if (globallyTriggered) {
        hideTimer.stop()
        shown = true
        ropePhysics.init()
        burstSystem.running = true
        burstEmitter.burst(55)
        burstStop.restart()
    } else {
        ropeOffsetY = -implicitHeight
        hideTimer.restart()
    }
}

    readonly property var ropeDefs: [
        { ax: 15,  segs: 12, icon: "󰽧", isz: 26 },
        { ax: 65,  segs: 9,  icon: "★",  isz: 26 },
        { ax: 117, segs: 15, icon: "󰽧", isz: 26 },
        { ax: 170, segs: 10, icon: "★",  isz: 26 },
        { ax: 225, segs: 10, icon: "",   isz: 26 },
        { ax: 280, segs: 8,  icon: "★",  isz: 26 },
        { ax: 333, segs: 13, icon: "󰽧", isz: 26 },
        { ax: 388, segs: 10, icon: "★",  isz: 26 },
        { ax: 440, segs: 11, icon: "󰽧", isz: 26 },
    ]

    mask: Region {
        regions: root.shown ? [visibleRegion] : []
    }
    Region {
        id: visibleRegion
        x: root.centerOffset; y: root.barHeight; width: 460; height: root.implicitHeight - root.barHeight
    }

    // ── Content ───────────────────────────────────────────────────────────
    Item {
        id: ropesArea
        anchors.fill: parent
        opacity: root.shown ? 1.0 : 0.0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

        Wid.RopePhysics {
            id: ropePhysics
            anchors.fill: parent
            ropeDefs:     root.ropeDefs
            centerOffset: root.centerOffset
            anchorY:      root.ropeOffsetY
            running:      root.shown
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
                font.family:    orn.index === 4 ? "" : "Symbols Nerd Font"
                font.pixelSize: orn.modelData.isz * 3
                color:          Qt.rgba(0.5, 0.5, 1.0, 0.92)
                x: (ropePhysics.tailsX[orn.index] ?? (orn.modelData.ax + root.centerOffset)) - width * 0.5
                y: (ropePhysics.tailsY[orn.index] ?? 0) - height * 0.5
                rotation: orn.index === 4 ? 0 : (ropePhysics.tailAngles[orn.index] ?? 0)
                transformOrigin: Item.Center
            }
        }

        ParticleSystem {
            id: burstSystem
            x: root.centerOffset; width: 460
            anchors.top: parent.top
            height: 8; running: false

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
}
