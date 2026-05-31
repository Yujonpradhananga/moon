import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Components as Comp
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
  layer: WlrLayer.Top
  namespace: "moon.sidepanel"
  screen: modelData
  surfaceFormat.opaque: false

  // Full-screen mouse tracker — updates Globals.mouseX
  // NoButton + propagateComposedEvents: doesn't steal any clicks
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    hoverEnabled: true
    propagateComposedEvents: true

    onPositionChanged: mouse => {
      if (layerRoot.width > 0) {
        Dat.Globals.mouseX = mouse.x / layerRoot.width;
        Dat.Globals.mouseOffsetX = (mouse.x / layerRoot.width  - 0.5) * 2.0;
        Dat.Globals.mouseOffsetY = (mouse.y / layerRoot.height - 0.5) * 2.0;
      }
    }
  }

  // Input mask — only the open SideMenu area receives clicks
  mask: Region {
    item: sideMenu
  }

  Comp.SideMenu {
    id: sideMenu

    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.top: parent.top
  }
}
