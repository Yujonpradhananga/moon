import QtQuick
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
  focusable: false
  layer: WlrLayer.Bottom
  namespace: "moon.wallpaper"
  screen: modelData

  Wid.WallpaperEngine {
    anchors.fill: parent
  }

  // Dim overlay that intensifies when menu opens
  Rectangle {
    anchors.fill: parent
    color: Dat.Colors.scrim
    opacity: Dat.Globals.menuOpen ? 0.35 : 0.05

    Behavior on opacity {
      NumberAnimation {
        duration: Dat.Easing.emphasizedTime
        easing.bezierCurve: Dat.Easing.emphasized
      }
    }
  }

  Lay.LunarClockFace {
    x: 40
    y: 40

    Behavior on x {
      NumberAnimation {
        duration: Dat.Easing.emphasizedTime
        easing.bezierCurve: Dat.Easing.emphasized
      }
    }
  }
}
