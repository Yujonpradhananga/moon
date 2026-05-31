import QtQuick
import QtQuick.Layouts
import QtMultimedia
import Quickshell
import Quickshell.Wayland
import qs.Data as Dat
import qs.Widgets as Wid
import qs.Layers as Lay

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
  namespace: "moon.systemtray"
  screen: modelData
  visible: Dat.Globals.sideMenuView === "files" && Dat.Globals.menuOpen

  property string animState: "idle"
  property real wipeProgress: 0.0

  onVisibleChanged: {
    if (visible) {
      animState = "wipe_in"
      wipeInAnim.start()
    } else {
      animState = "idle"
      wipeProgress = 0.0
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


  Item {
    id: contentArea
    anchors.fill: parent
    opacity: layerRoot.wipeProgress

    Video {
      id: bgVideo
      source: Qt.resolvedUrl("../Assets/videos/raani.mp4")
      anchors.fill: parent
      fillMode: VideoOutput.PreserveAspectCrop
      loops: MediaPlayer.Infinite
      volume: 0
      autoPlay: true
      z: -1
    }

    ColumnLayout {
      anchors.centerIn: parent
      anchors.verticalCenterOffset: -150
      spacing: 15
      z: 1

      Text {
        Layout.alignment: Qt.AlignHCenter
        color: "black"
        font.pixelSize: 100  // was 80
        text: "☽"
      }

      Repeater {
        model: ListModel {
          ListElement { icon: "⏻"; label: "Power Off";  cmd: "poweroff" }
          ListElement { icon: "↺"; label: "Restart";    cmd: "reboot" }
          ListElement { icon: "⏾"; label: "Sleep";      cmd: "systemctl suspend" }
        }

        delegate: Item {
          id: powerItem
          required property int index
          required property string icon
          required property string label
          required property string cmd

          Layout.preferredWidth: 280
          Layout.preferredHeight: 56

          MouseArea {
            id: itemMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
              console.log("[MoonShell] Power action: " + powerItem.cmd)
              Qt.callLater(() => {
                const proc = Qt.createQmlObject(
                  'import Quickshell.Io; Process { command: ["sh", "-c", "' + powerItem.cmd + '"]; running: true }',
                  layerRoot
                )
              })
            }
          }

          Rectangle {
            anchors.fill: parent
            anchors.leftMargin: -12
            anchors.rightMargin: -12
            color: itemMouse.containsMouse ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.12) : "transparent"
            radius: 8
            Behavior on color { ColorAnimation { duration: 200 } }
          }

          Rectangle {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: -16
            anchors.top: parent.top
            anchors.topMargin: 10
            color: Dat.Colors.secondary
            opacity: itemMouse.containsMouse ? 1.0 : 0.0
            radius: 2
            width: 3
            Behavior on opacity { NumberAnimation { duration: 200 } }
          }

          RowLayout {
            anchors.fill: parent
            spacing: 16

            Text {
              Layout.alignment: Qt.AlignVCenter
              Layout.preferredWidth: 24
              color: "black"
              font.pixelSize: 22
              horizontalAlignment: Text.AlignHCenter
              text: powerItem.icon
              Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
              Layout.alignment: Qt.AlignVCenter
              Layout.fillWidth: true
              horizontalAlignment: Text.AlignHCenter
              font.family: "Inter"
              font.letterSpacing: 1.5
              color: "black"
              font.pixelSize: 22
              font.weight: itemMouse.containsMouse ? Font.Normal : Font.Light
              text: powerItem.label
              Behavior on color { ColorAnimation { duration: 200 } }
            }
          }
        }
      }
    }

    MouseArea {
      id: bgMouseArea
      anchors.fill: parent
      z: -1
      onClicked: {
        if (layerRoot.animState === "open") {
          layerRoot.animState = "wipe_out"
          wipeOutAnim.start()
        }
      }
    }
  }

  Keys.onEscapePressed: {
    if (animState === "open") {
      animState = "wipe_out"
      wipeOutAnim.start()
    }
  }
}
