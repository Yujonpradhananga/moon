import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.Layers as Lay

PanelWindow {
  required property ShellScreen modelData
  screen: modelData
  anchors { top: true; left: true }
  margins.top: 40
  margins.left: 40
  width: 270
  height: 270
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Top
  WlrLayershell.namespace: "lunarclock"
  color: "transparent"

  Lay.LunarClockFace {}
}
