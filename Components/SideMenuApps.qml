import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import QtMultimedia
import qs.Data as Dat

WlrLayershell {
  id: layerRoot
  required property ShellScreen modelData
  anchors.bottom: true
  anchors.left: true
  anchors.right: true
  anchors.top: true
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  focusable: true
  layer: WlrLayer.Overlay
  namespace: "moon.files"
  screen: modelData
visible: Dat.Globals.sideMenuView === "files"

  property string animState: "idle"
  property real wipeProgress: 0.0

  onVisibleChanged: {
if (visible) {
  wipeProgress = 0.0
  animState = "wipe_in"
  wipeInAnim.start()
  searchInput.text = ""
  searchInput.forceActiveFocus()
  carousel.currentIndex = 0
}
  }

  NumberAnimation {
    id: wipeInAnim
    duration: 800
    easing.type: Easing.InOutCubic
    from: 0.0
    property: "wipeProgress"
    target: layerRoot
    to: 1.0
    onFinished: layerRoot.animState = "open"
  }

  NumberAnimation {
    id: wipeOutAnim
    duration: 600
    easing.type: Easing.InOutCubic
    from: 1.0
    property: "wipeProgress"
    target: layerRoot
    to: 0.0
    onFinished: {
      layerRoot.animState = "idle"
      Dat.Globals.sideMenuView = "main"
    }
  }

  Keys.onEscapePressed: {
    if (animState === "open") {
      animState = "wipe_out"
      wipeOutAnim.start()
    }
  }

  Item {
    id: contentArea
    anchors.fill: parent
    opacity: layerRoot.wipeProgress

    // Background video
    Video {
      id: bgVideo
      source: Qt.resolvedUrl("../Assets/videos/output.mp4")
      anchors.fill: parent
      fillMode: VideoOutput.PreserveAspectCrop
      loops: MediaPlayer.Infinite
      volume: 0
      autoPlay: true
      z: -1
    }

    // Dismiss on background click
    MouseArea {
      anchors.fill: parent
      z: 0
      onClicked: {
        if (layerRoot.animState === "open") {
          layerRoot.animState = "wipe_out"
          wipeOutAnim.start()
        }
      }
    }

    // Semicircle carousel centered on screen
    Item {
      id: carousel
      anchors.centerIn: parent
      width: parent.width
      height: parent.height
      z: 1

      property int currentIndex: 0
      property real arcRadius: 480
      property real arcAngleSpan: 18

      property var filteredApps: {
        const stxt = searchInput.text.toLowerCase()
        if (stxt === "") return DesktopEntries.applications.values
        return DesktopEntries.applications.values.filter(app => {
          const ntxt = app.name.toLowerCase()
          let ni = 0
          for (let si = 0; si < stxt.length; si++) {
            const sc = stxt[si]
            while (ni < ntxt.length) {
              if (ntxt[ni++] === sc) break
              if (ni === ntxt.length) return false
            }
          }
          return true
        })
      }

      // Scroll wheel to navigate
      MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        hoverEnabled: true
        onWheel: wheel => {
          if (wheel.angleDelta.y > 0)
            carousel.currentIndex = Math.max(0, carousel.currentIndex - 1)
          else
            carousel.currentIndex = Math.min(carousel.filteredApps.length - 1, carousel.currentIndex + 1)
          wheel.accepted = true
        }
      }

      Repeater {
        model: carousel.filteredApps

        Item {
          id: appDelegate
          required property var modelData
          required property int index

          property int relativePos: index - carousel.currentIndex
          visible: Math.abs(relativePos) <= 4

          property real angle: relativePos * carousel.arcAngleSpan
          property real angleRad: angle * Math.PI / 180

          // Position in semicircle to the left of center
          x: carousel.width / 2 + carousel.arcRadius * Math.sin(angleRad) - 45
          y: carousel.height * 0.55 - carousel.arcRadius * Math.cos(angleRad) - 45

          Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
          Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

          width: 90
          height: 90

          property bool isHovered: false
          property bool isCenter: relativePos === 0
          property real baseScale: isCenter ? 1.3 : Math.max(0.6, 1.0 - Math.abs(relativePos) * 0.12)
          property real hoverScale: isHovered ? 1.15 : 1.0

          // App button
          Rectangle {
            id: appButton
            anchors.centerIn: parent
            width: 80
            height: 80
            radius: 24
property real floatY: 0
            color: appDelegate.isCenter
              ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.15)
              : Dat.Colors.withAlpha(Dat.Colors.background, 0.15)
                        border.width: appDelegate.isCenter ? 2 : 1
            border.color: appDelegate.isCenter
              ? Dat.Colors.withAlpha(Dat.Colors.secondary, 0.4)
              : Dat.Colors.withAlpha(Dat.Colors.primary, 0.1)
              z: 1
rotation: appDelegate.isCenter ? 5 : appDelegate.angle * 1.5
Behavior on rotation { NumberAnimation { duration: 200 } }

SequentialAnimation on y {
  running: appDelegate.isCenter
  loops: Animation.Infinite
  NumberAnimation { to: -4; duration: 900; easing.type: Easing.InOutSine }
  NumberAnimation { to: 0;  duration: 900; easing.type: Easing.InOutSine }
}
transform: [
  Scale {
    origin.x: appButton.width / 2
    origin.y: appButton.height / 2
    xScale: appDelegate.baseScale * appDelegate.hoverScale
    yScale: appDelegate.baseScale * appDelegate.hoverScale
    Behavior on xScale { NumberAnimation { duration: 150 } }
    Behavior on yScale { NumberAnimation { duration: 150 } }
  },
  Translate { y: appButton.floatY }
]
SequentialAnimation on floatY {
  running: appDelegate.isCenter
  loops: Animation.Infinite
  NumberAnimation { to: -4; duration: 900; easing.type: Easing.InOutSine }
  NumberAnimation { to: 0;  duration: 900; easing.type: Easing.InOutSine }
}

            // Fallback initial letter
            Text {
              anchors.centerIn: parent
              visible: appIcon.status !== Image.Ready
              text: appDelegate.modelData.name
                ? appDelegate.modelData.name.charAt(0).toUpperCase()
                : "?"
              color: Dat.Colors.foreground
              font.pixelSize: 22
              font.weight: Font.Bold
              z: 1
            }

            Image {
              id: appIcon
              anchors.centerIn: parent
              width: 48
              height: 48
              source: appDelegate.modelData.icon
                ? "image://icon/" + appDelegate.modelData.icon
                : ""
              sourceSize.width: 56
              sourceSize.height: 56
              fillMode: Image.PreserveAspectFit
              visible: status === Image.Ready
              smooth: true
              z: 2
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor

              onClicked: {
                clickAnim.start()
                Qt.callLater(() => {
                  appDelegate.modelData.execute()
                  layerRoot.animState = "wipe_out"
                  wipeOutAnim.start()
                })
              }
              onEntered: {
                appDelegate.isHovered = true
                carousel.currentIndex = appDelegate.index
              }
              onExited: appDelegate.isHovered = false
            }

            SequentialAnimation {
              id: clickAnim
              NumberAnimation { target: appButton; property: "scale"; to: 0.85; duration: 80; easing.type: Easing.OutQuad }
              NumberAnimation { target: appButton; property: "scale"; to: 1.0;  duration: 80; easing.type: Easing.OutQuad }
            }
          }

          // Tooltip for center app
          Rectangle {
            visible: appDelegate.isCenter
            color: Dat.Colors.withAlpha(Dat.Colors.background, 0.85)
            border.width: 1
            border.color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.3)
            radius: 8
            width: tooltipText.width + 20
            height: tooltipText.height + 12
            z: 10
            anchors {
              right: parent.left
              rightMargin: 60
              verticalCenter: parent.verticalCenter
            }
            Text {
              id: tooltipText
              anchors.centerIn: parent
              text: appDelegate.modelData.name || ""
              color: Dat.Colors.foreground
              font.family: "Inter"
              font.pixelSize: 13
              font.weight: Font.Light
              font.letterSpacing: 1
            }
          }
        }
      }
    }


Text {
  anchors.horizontalCenter: parent.horizontalCenter
  anchors.bottom: parent.bottom
  anchors.bottomMargin: 666
  text: "A P P S"
  color: Black
  font.family: "Inter"
  font.pixelSize: 50
  font.letterSpacing: 4
  font.weight: Font.Light
  z: 2
}



    // Search box bottom center
    Item {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 500
      width: 280
      height: 44
      z: 2

      Rectangle {
        anchors.fill: parent
        radius: 22
color: Dat.Colors.withAlpha(Dat.Colors.background, 0.25)
        border.width: 1
        border.color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.3)

        Row {
          anchors {
            fill: parent
            leftMargin: 16; rightMargin: 16
          }
          spacing: 10

          Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "⌕"
            color: Dat.Colors.foregroundMuted
            font.pixelSize: 18
          }

          TextInput {
            id: searchInput
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 40
            color: Dat.Colors.foreground
            font.family: "Inter"
            font.pixelSize: 14
            font.weight: Font.Light

            Keys.onEscapePressed: {
              if (layerRoot.animState === "open") {
                layerRoot.animState = "wipe_out"
                wipeOutAnim.start()
              }
            }
            Keys.onReturnPressed: {
              if (carousel.filteredApps.length > 0) {
                carousel.filteredApps[carousel.currentIndex].execute()
                layerRoot.animState = "wipe_out"
                wipeOutAnim.start()
              }
            }
            Keys.onPressed: event => {
              if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
                carousel.currentIndex = Math.max(0, carousel.currentIndex - 1)
                event.accepted = true
              } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
                carousel.currentIndex = Math.min(carousel.filteredApps.length - 1, carousel.currentIndex + 1)
                event.accepted = true
              }
            }
            onTextChanged: carousel.currentIndex = 0
          }
        }
      }
    }
  }
}
