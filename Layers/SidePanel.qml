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

  // Input mask — only accept input over the SideMenu area when open
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
