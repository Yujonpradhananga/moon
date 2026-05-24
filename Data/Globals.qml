pragma Singleton
import Quickshell
import QtQuick

Singleton {
  id: root

  // Normalized mouse X position (0.0 = left edge, 1.0 = right edge)
  property real mouseX: 0.5

  // Whether the side menu should be revealed
  readonly property bool menuOpen: mouseX < menuTriggerThreshold


  // How far left the mouse must go to trigger menu (fraction of screen width)
  readonly property real menuTriggerThreshold: 0.10

  // Parallax shift intensity: fraction of the overscan used for shift
  // e.g. 1.0 means full range of the extra zoomed area is used
  readonly property real parallaxIntensity: 1.0

  // Video zoom factor (1.2 = 120% of viewport)
  readonly property real videoZoom: 1.2

  // Power screen state
  property bool powerScreenVisible: false

  // Side menu view: "main" = game menu, "toggles" = wifi/bt quick toggles panel
  property string sideMenuView: "main"
}
