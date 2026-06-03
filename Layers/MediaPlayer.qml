pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Services.Mpris

PanelWindow {
    id: root
    required property ShellScreen modelData
    screen: modelData
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "moon.media"

    anchors {
        right: true
        bottom: true
    }

    implicitWidth: 190
    implicitHeight: 240

    // ── Window-presence detection (hide when any windows are open) ──────────
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

    // ── Wrapper — fades out when windows are open ────────────────────────────
    Item {
        id: content
        anchors.fill: parent
        opacity: root.hasWindows ? 0.0 : 1.0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
        }

        // ── No-player placeholder ────────────────────────────────────────────
        Item {
            anchors.fill: parent
            visible: Mpris.players.values.length === 0

            AnimatedImage {
                anchors.centerIn: parent
                width: 90
                height: 90
                fillMode: Image.PreserveAspectFit
                playing: true
                source: Qt.resolvedUrl("../Assets/ranni.gif")
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                color: Qt.rgba(1, 1, 1, 0.4)
                font.family: "Inter"
                font.pixelSize: 10
                font.letterSpacing: 1.5
                text: "no music playing"
            }
        }

        // ── Player cards ─────────────────────────────────────────────────────
        SwipeView {
            id: playerList
            anchors.fill: parent
            visible: Mpris.players.values.length > 0
            orientation: Qt.Vertical

            Repeater {
                model: ScriptModel {
                    values: [...Mpris.players.values]
                }

                Rectangle {
                    id: card

                    required property MprisPlayer modelData
                    required property int index
                    property MprisPlayer player: modelData

                    clip: true
                    color: "transparent"
                    radius: 20

                    // ── Vinyl disk (album art) ───────────────────────────────
                    Image {
                        id: imgDisk

                        anchors.horizontalCenter: card.horizontalCenter
                        fillMode: Image.PreserveAspectCrop
                        height: this.width
                        layer.enabled: true
                        layer.smooth: true
                        mipmap: true
                        smooth: true
                        source: card.player.trackArtUrl
                        width: card.width - 30
                        y: 44

                        layer.effect: MultiEffect {
                            antialiasing: true
                            maskEnabled: true
                            maskSpreadAtMin: 1.0
                            maskThresholdMax: 1.0
                            maskThresholdMin: 0.5
                            maskSource: Image {
                                layer.smooth: true
                                mipmap: true
                                smooth: true
                                source: Qt.resolvedUrl("../Assets/AlbumCover-by-Squirrel-Modeller.svg")
                            }
                        }

                        Behavior on rotation {
                            NumberAnimation {
                                duration: rotateTimer.interval
                                easing.type: Easing.Linear
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: 400
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    // Click disk area to toggle play/pause
                    MouseArea {
                        anchors.bottom: card.bottom
                        anchors.left: card.left
                        anchors.right: card.right
                        height: card.height * 0.40
                        hoverEnabled: true
                        onClicked: card.player.togglePlaying()
                        onEntered: imgDisk.scale = 0.85
                        onExited: imgDisk.scale = 1.0
                    }

                    Timer {
                        id: rotateTimer
                        interval: 500
                        repeat: true
                        running: card.player.isPlaying
                        onRunningChanged: imgDisk.rotation += rotateTimer.running ? 3 : 0
                        onTriggered: imgDisk.rotation += 3
                    }

                    // ── Title & artist ───────────────────────────────────────
                    ColumnLayout {
                        anchors {
                            bottom: imgDisk.top
                            bottomMargin: 4
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 8
                        }
                        spacing: 0

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.preferredHeight: 2

                            Text {
                                anchors.fill: parent
                                color: Qt.rgba(1, 1, 1, 0.95)
                                elide: Text.ElideRight
                                font.bold: true
                                font.pointSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                text: card.player.trackTitle
                                verticalAlignment: Text.AlignBottom
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Text {
                                anchors.fill: parent
                                color: Qt.rgba(1, 1, 1, 0.55)
                                elide: Text.ElideRight
                                font.bold: true
                                font.pointSize: 8
                                horizontalAlignment: Text.AlignHCenter
                                text: card.player.trackArtist
                                verticalAlignment: Text.AlignTop
                            }
                        }
                    }

                    // ── Previous button ──────────────────────────────────────
                    Item {
                        anchors.left: card.left
                        anchors.leftMargin: 14
                        anchors.verticalCenter: card.verticalCenter
                        height: 28
                        width: 28

                        Text {
                            id: prevIcon
                            property real iconFill: 0
                            anchors.centerIn: parent
                            color: Qt.rgba(1, 1, 1, 0.75)
                            font.bold: true
                            font.pixelSize: 26
                            font.family: "Material Symbols Rounded"
                            font.variableAxes: ({"FILL": prevIcon.iconFill})
                            text: "arrow_circle_left"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: card.player.previous()
                            onEntered: prevIcon.iconFill = 1
                            onExited: prevIcon.iconFill = 0
                        }
                    }

                    // ── Next button ──────────────────────────────────────────
                    Item {
                        anchors.right: card.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: card.verticalCenter
                        height: 28
                        width: 28

                        Text {
                            id: nextIcon
                            property real iconFill: 0
                            anchors.centerIn: parent
                            color: Qt.rgba(1, 1, 1, 0.75)
                            font.bold: true
                            font.pixelSize: 26
                            font.family: "Material Symbols Rounded"
                            font.variableAxes: ({"FILL": nextIcon.iconFill})
                            text: "arrow_circle_right"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: card.player.next()
                            onEntered: nextIcon.iconFill = 1
                            onExited: nextIcon.iconFill = 0
                        }
                    }
                }
            }
        }

        // ── Multi-player page indicator ──────────────────────────────────────
        PageIndicator {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            count: playerList.count
            currentIndex: playerList.currentIndex
            interactive: false
            rotation: 90
            visible: count > 1

            delegate: Rectangle {
                id: dot
                required property int index
                color: (index === playerList.currentIndex) ? "white" : Qt.rgba(1, 1, 1, 0.5)
                height: width
                radius: 6
                width: 6

                Behavior on color {
                    ColorAnimation { duration: 500 }
                }
            }
        }
    }
}
