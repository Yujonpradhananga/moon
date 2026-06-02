import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

PanelWindow {
    id: root
    required property ShellScreen modelData
    screen: modelData
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "moon.volumebar"
    mask: Region {}
    anchors {
        top: true
        right: true
    }
    margins.top: 20
    implicitWidth: 160
    implicitHeight: 200

    property int volume: 0
    property bool muted: false
    property bool initialized: false
    property bool visible_: false

    Process {
        id: volumePoller
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                const mutedMatch = line.includes("[MUTED]")
                const match = line.match(/Volume:\s+([\d.]+)/)
                if (match) {
                    const newVol = Math.round(parseFloat(match[1]) * 100)
                    if (root.initialized && newVol !== root.volume) {
                        root.visible_ = true
                        hideTimer.restart()
                    }
                    root.volume = newVol
                    root.initialized = true
                }
                root.muted = mutedMatch
            }
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: volumePoller.running = true
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.visible_ = false
    }

    Item {
        id: container
        width: 140
        height: 180
        x: root.visible_ ? parent.width - width - 12 : parent.width + 10
        y: 16
        opacity: root.visible_ ? 1.0 : 0.0

        Behavior on x {
            NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        AnimatedImage {
            id: moonImage
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            width: 120
            height: 120
            fillMode: Image.PreserveAspectFit
source: Qt.resolvedUrl("../Assets/ranni.gif")
            smooth: true

            property real floatY: 0
            transform: Translate { y: moonImage.floatY }

            SequentialAnimation on floatY {
                running: root.visible_
                loops: Animation.Infinite
                NumberAnimation { to: -6; duration: 1800; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0;  duration: 1800; easing.type: Easing.InOutSine }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: moonImage.y + moonImage.height + 8
            text: root.muted ? "muted" : root.volume + "%"
            color: "#ffffff"
            font.pixelSize: 18
            font.family: "Montserrat Light"
            font.weight: Font.Bold
            style: Text.Outline
            styleColor: "#40000000"
        }
    }
}
