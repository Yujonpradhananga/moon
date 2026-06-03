import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Data as Dat
import qs.Widgets as Wid

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
  namespace: "moon.powerscreen"
  screen: modelData
  visible: Dat.Globals.powerScreenVisible

  property string animState: "idle"
  property real wipeProgress: 0.0

  onVisibleChanged: {
    if (visible) {
      animState = "wipe_in"
      wipeInAnim.start()
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
      Dat.Globals.powerScreenVisible = false
    }
  }

  Wid.CircularWipe {
    id: circularWipe
    anchors.fill: parent
    wipeProgress: layerRoot.wipeProgress
  }

  Item {
    id: contentArea
    anchors.fill: parent
    opacity: layerRoot.animState === "open" ? 1.0 : 0.0
    Behavior on opacity {
      NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
    }

    Rectangle {
      anchors.fill: parent
      color: Dat.Colors.background
    }

    Wid.AuroricCursor {
      id: auroricEffect
      anchors.fill: parent
      cursorX: powerMouseArea.mouseX
      cursorY: powerMouseArea.mouseY
      glowRadius: 200
    }

    Canvas {
      anchors.fill: parent
      opacity: 0.04
      Component.onCompleted: requestPaint()
      onPaint: {
        var ctx = getContext("2d")
        ctx.fillStyle = "#000000"
        for (var y = 0; y < height; y += 4)
          ctx.fillRect(0, y, width, 1)
      }
    }

    ColumnLayout {
      anchors.centerIn: parent
      spacing: 8
      z: 1

      Text {
        Layout.alignment: Qt.AlignHCenter
        color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.6)
        font.pixelSize: 80
        text: "☽"
      }

      Repeater {
        model: ListModel {
          ListElement { icon: "⏻"; label: "Power Off"; cmd: "poweroff" }
          ListElement { icon: "↺"; label: "Restart";   cmd: "reboot" }
          ListElement { icon: "⏾"; label: "Sleep";     cmd: "systemctl suspend" }
        }

        delegate: Item {
          id: powerItem
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
            onClicked: Quickshell.execDetached(["sh", "-c", powerItem.cmd])
          }

          Rectangle {
            anchors.fill: parent
            anchors.leftMargin: -12
            anchors.rightMargin: -12
            color: itemMouse.containsMouse
              ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.12)
              : "transparent"
            radius: 8
            Behavior on color { ColorAnimation { duration: 200 } }
          }

          Rectangle {
            anchors.top: parent.top; anchors.topMargin: 10
            anchors.bottom: parent.bottom; anchors.bottomMargin: 10
            anchors.left: parent.left; anchors.leftMargin: -16
            width: 3; radius: 2
            color: Dat.Colors.secondary
            opacity: itemMouse.containsMouse ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
          }

RowLayout {
  anchors.centerIn: parent
  spacing: 16

  Text {
    Layout.alignment: Qt.AlignVCenter
    color: itemMouse.containsMouse ? Dat.Colors.secondaryBright : Dat.Colors.primaryDim
    font.pixelSize: 20
    text: powerItem.icon
    Behavior on color { ColorAnimation { duration: 200 } }
  }

  Text {
    Layout.alignment: Qt.AlignVCenter
    color: itemMouse.containsMouse ? Dat.Colors.foreground : Dat.Colors.foregroundMuted
    font.family: "Inter"
    font.letterSpacing: 1.5
    font.pixelSize: 18
    font.weight: itemMouse.containsMouse ? Font.Normal : Font.Light
    text: powerItem.label
    Behavior on color { ColorAnimation { duration: 200 } }
  }
}
        }
      }
    }

    MouseArea {
      id: powerMouseArea
      anchors.fill: parent
      cursorShape: Qt.ArrowCursor
      hoverEnabled: true
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
