import QtQuick
import Quickshell
import Quickshell.Wayland

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
  focusable: false
  layer: WlrLayer.Bottom
  namespace: "moon.mousetracker"
  screen: modelData

  // Invisible full-screen mouse tracker
  // Updates Globals.mouseX so any component can react to mouse position
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    hoverEnabled: true
    propagateComposedEvents: true

    onPositionChanged: mouse => {
      if (layerRoot.width > 0) {
        Dat.Globals.mouseX = mouse.x / layerRoot.width;
      }
    }
  }
}
