pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Data as Dat

PanelWindow {
    id: root
    required property ShellScreen modelData

    screen: modelData
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "moon.bar"

    anchors { top: true }
    implicitWidth: 460
    implicitHeight: 46

    readonly property HyprlandMonitor hyprMonitor: Hyprland.monitorFor(root.screen)
    readonly property bool hasWindows: (root.hyprMonitor?.activeWorkspace?.lastIpcObject?.windows ?? 0) > 0

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

    // Only pill receives input — everything else is click-through
    mask: Region { item: pill }

    // ── Time ──────────────────────────────────────────────────────────────
    property string timeStr: Qt.formatDateTime(new Date(), "hh:mm")
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.timeStr = Qt.formatDateTime(new Date(), "hh:mm")
    }

    // ── Volume (wpctl, polled every 2s) ───────────────────────────────────
    property int volume: 0
    property bool muted: false

    Process {
        id: volProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                root.muted = line.includes("[MUTED]")
                const m = line.match(/Volume:\s+([\d.]+)/)
                if (m) root.volume = Math.round(parseFloat(m[1]) * 100)
            }
        }
    }
    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: volProc.running = true
    }

    // ── Battery (sysfs, polled every 30s) ─────────────────────────────────
    property int battery: 100
    property bool charging: false
    property string batDevice: ""

    Process {
        command: ["sh", "-c", "ls /sys/class/power_supply | grep -iE 'bat|acad' | grep -iv 'ac' | head -n 1"]
        running: true
        stdout: SplitParser {
            onRead: data => { if (data.trim()) root.batDevice = data.trim() }
        }
    }

    FileView {
        id: batCap
        path: root.batDevice ? "/sys/class/power_supply/" + root.batDevice + "/capacity" : ""
        onLoaded: { var v = parseInt(text().trim()); if (!isNaN(v)) root.battery = v }
    }
    FileView {
        id: batStatus
        path: root.batDevice ? "/sys/class/power_supply/" + root.batDevice + "/status" : ""
        onLoaded: { var s = text().trim(); root.charging = s === "Charging" || s === "Full" }
    }
    Timer {
        interval: 30000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { batCap.reload(); batStatus.reload() }
    }

    // ── Pill ──────────────────────────────────────────────────────────────
    Rectangle {
        id: pill

        anchors.horizontalCenter: parent.horizontalCenter
        // Slides up (-height-4) when windows open, drops to y:7 on desktop
        y: root.hasWindows ? -(height + 4) : 7
        width: 460
        height: 32
        radius: 16
        color: Qt.rgba(0, 0, 0, 0)
        clip: true

        Behavior on y {
            NumberAnimation { duration: 380; easing.type: Easing.OutCubic }
        }

        // Glass border
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: Qt.rgba(0.75, 0.6, 1.0, 0.18)
            border.width: 1
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 0

            // ── Left: Volume ─────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: root.muted   ? "󰖁"
                        : root.volume > 60 ? "󰕾"
                        : root.volume > 0  ? "󰖀"
                        :                    "󰕿"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: Qt.rgba(1, 1, 1, 0.6)
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: root.muted ? "muted" : (root.volume + "%")
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Qt.rgba(1, 1, 1, root.muted ? 0.3 : 0.68)
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // ── Center: Time ─────────────────────────────────────────────
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    anchors.centerIn: parent
                    text: root.timeStr
                    font.family: "Inter"
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    font.letterSpacing: 1.5
                    color: Qt.rgba(1, 1, 1, Dat.Globals.shanglesOpen ? 0.5 : 0.92)
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Dat.Globals.shanglesOpen = !Dat.Globals.shanglesOpen
                    }
                }
            }

            // ── Right: Battery ────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                layoutDirection: Qt.RightToLeft
                spacing: 5

                Text {
                    text: root.battery + "%"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Qt.rgba(1, root.battery < 20 ? 0.35 : 1, root.battery < 20 ? 0.35 : 1, 0.68)
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: root.charging    ? "󰂄"
                        : root.battery > 80 ? "󰁹"
                        : root.battery > 60 ? "󰂁"
                        : root.battery > 40 ? "󰁿"
                        : root.battery > 20 ? "󰁽"
                        :                     "󰁺"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: root.battery < 20
                        ? Qt.rgba(1, 0.38, 0.38, 0.9)
                        : Qt.rgba(1, 1, 1, 0.6)
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
