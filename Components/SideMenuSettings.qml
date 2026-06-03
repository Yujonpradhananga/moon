import QtQuick
import QtQuick.Layouts
import Caelestia.Blobs
import qs.Data as Dat
import qs.Widgets as Wid

BlobRect {
  id: root
  required property var group
  required property real menuWidth
  required property string currentView
  group: root.group
  width: menuWidth
  height: parent.height
  x: currentView === "settings" ? 0 : menuWidth
  radius: 0
  stiffness: 0
  damping: 24
  deformScale: 1.0002
  Behavior on x {
    NumberAnimation { duration: 450; easing.type: Easing.InOutCubic }
  }
  Wid.ShaderPicker {
    anchors.fill: parent
    opacity: root.currentView === "settings" ? 1.0 : 0.0
    visible: opacity > 0
    Behavior on opacity {
      NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
  }
}
