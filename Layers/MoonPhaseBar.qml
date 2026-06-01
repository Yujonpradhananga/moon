import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root
    required property ShellScreen modelData
    screen: modelData
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "moon.phasebar"

    anchors {
      left: true
      right: true
      bottom: true
    }

    implicitHeight: 300

    readonly property int zoneWidth: 200
    readonly property int zoneX: (width / 2) - (zoneWidth / 2)
    property bool hovered: false
    property int currentPhase: 1

    MouseArea {
      id: tracker
      x: root.zoneX - 50
      y: 0
      width: root.zoneWidth + 100
      height: parent.height
      hoverEnabled: true
      onEntered: root.hovered = true
      onExited: root.hovered = false
      onPositionChanged: mouse => {
        var relX = mouse.x - 50
        var progress = Math.min(Math.max(relX / root.zoneWidth, 0), 1)
        root.currentPhase = Math.round(progress * 4) + 1
      }
    }

    Item {
      id: imageContainer
      x: root.zoneX - 50
      width: root.zoneWidth + 100
      height: 220
      y: root.hovered
        ? parent.height - height - 20
        : parent.height

      opacity: root.hovered ? 1.0 : 0.0
      Behavior on y {
        NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
      }
      Behavior on opacity {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
      }

    Image {
      id: moonImage
      anchors.centerIn: parent
      width: 200
      height: 200
      fillMode: Image.PreserveAspectFit
      source: Qt.resolvedUrl("../Assets/Moon_Phases/Moon_Phase_" + root.currentPhase + ".png")
      smooth: true
      property real floatY: 0
      transform: Translate { y: moonImage.floatY }
      SequentialAnimation on floatY {
        running: root.hovered
        loops: Animation.Infinite
        NumberAnimation { to: -8; duration: 1800; easing.type: Easing.InOutSine }
        NumberAnimation { to: 0; duration: 1800; easing.type: Easing.InOutSine }
      }
    }
  }
}
