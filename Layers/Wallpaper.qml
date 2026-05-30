import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Components as Comp
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

  // Full-screen mouse tracker for parallax + menu trigger
  MouseArea {
    id: mouseTracker

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
  Wid.WallpaperEngine {
      anchors.fill: parent
  }

 /* Wid.VideoWallpaper {
    id: wallpaper

    anchors.fill: parent
  } */
 

  // Dim overlay that intensifies when menu opens — gives a cinematic feel
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
  // Side menu
Comp.SideMenu {
  id: sideMenu
  anchors.bottom: parent.bottom
  anchors.left: parent.left
  anchors.top: parent.top
}
}
