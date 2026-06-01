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
    WlrLayershell.namespace: "moon.phasebar"
    mask: Region {}
    anchors {
      top: true
      right: true
    }
    margins.top:20
    implicitWidth: 160
    implicitHeight: 200

    property string backlightDevice: ""
    property int current: -1
    property int maxVal: 1
    property int brightness: 0
    property bool initialized: false
    property bool visible_: false

    Process {
        command: ["sh", "-c", "ls /sys/class/backlight | head -n 1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let d = data.trim()
                if (d) root.backlightDevice = d
            }
        }
    }

    Timer {
        interval: 100
        running: root.backlightDevice !== ""
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            currentFile.reload()
            maxFile.reload()
        }
    }

    FileView {
        id: currentFile
        path: root.backlightDevice
            ? "/sys/class/backlight/" + root.backlightDevice + "/brightness"
            : ""
        onLoaded: {
            var val = parseInt(text().trim())
            if (isNaN(val)) return
            if (root.current !== val) {
                if (root.initialized) {
                    root.visible_ = true
                    hideTimer.restart()
                }
                root.current = val
                if (root.maxVal > 0)
                    root.brightness = Math.round((val / root.maxVal) * 100)
                root.initialized = true
            }
        }
    }

    FileView {
        id: maxFile
        path: root.backlightDevice
            ? "/sys/class/backlight/" + root.backlightDevice + "/max_brightness"
            : ""
        onLoaded: {
            var val = parseInt(text().trim())
            if (!isNaN(val)) root.maxVal = val
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.visible_ = false
    }

    readonly property int currentPhase: Math.round((1 - root.brightness / 100) * 4) + 1

    Item {
        id: container
        width: 140
        height: 180
        // slide in from the right edge
        x: root.visible_ ? parent.width - width - 12 : parent.width + 10
        y: 16
        opacity: root.visible_ ? 1.0 : 0.0

        Behavior on x {
            NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        Image {
            id: moonImage
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            width: 120
            height: 120
            fillMode: Image.PreserveAspectFit
            source: Qt.resolvedUrl("../Assets/Moon_Phases/Moon_Phase_" + root.currentPhase + ".png")
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
            text: root.brightness + "%"
            color: "#ffffff"
            font.pixelSize: 18
            font.family: "Montserrat Light"
            font.weight: Font.Bold
            style: Text.Outline
            styleColor: "#40000000"
        }
    }
}
