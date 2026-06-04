pragma Singleton
import Quickshell
import QtQuick

Singleton {
  id: root

  property real mouseX:       0.5
  property real mouseOffsetX: 0.0
  property real mouseOffsetY: 0.0
  Behavior on mouseOffsetX {
    NumberAnimation { duration: 800; easing.type: Easing.OutQuart }
  }
  Behavior on mouseOffsetY {
    NumberAnimation { duration: 800; easing.type: Easing.OutQuart }
  }

  property bool menuOpen: false
  property string sideMenuView: "main"
  property bool powerScreenVisible: false
  property string shaderMode: "motion"
  property bool shanglesOpen: false
}
