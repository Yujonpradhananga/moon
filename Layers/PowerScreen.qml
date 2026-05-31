import QtQuick
import QtQuick.Layouts
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

    Lay.LunarClockFace {
      anchors.centerIn: parent
      anchors.verticalCenterOffset: -60
      scale: 1.3
      faceColor: Dat.Colors.primary
      z: 1
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
