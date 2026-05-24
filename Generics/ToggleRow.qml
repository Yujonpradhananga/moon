import QtQuick
import QtQuick.Layouts
import qs.Data as Dat
import "."

Item {
  id: root

  required property string icon
  required property string label
  property string statusText: ""
  property bool toggled: false

  signal clicked

  implicitHeight: 52

  MouseArea {
    id: itemMouse
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onClicked: root.clicked()
  }

  Rectangle {
    anchors.fill: parent
    anchors.leftMargin: -12
    anchors.rightMargin: -12
    color: itemMouse.containsMouse ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.12) : "transparent"
    radius: 8
    Behavior on color { ColorAnimation { duration: 200 } }
  }

  Rectangle {
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10
    anchors.left: parent.left
    anchors.leftMargin: -16
    anchors.top: parent.top
    anchors.topMargin: 10
    color: Dat.Colors.secondary
    opacity: (root.toggled || itemMouse.containsMouse) ? 1.0 : 0.0
    radius: 2
    width: 3
    Behavior on opacity { NumberAnimation { duration: 200 } }
  }

  RowLayout {
    anchors.fill: parent
    spacing: 16

    Text {
      Layout.alignment: Qt.AlignVCenter
      Layout.preferredWidth: 24
      color: (root.toggled || itemMouse.containsMouse) ? Dat.Colors.secondaryBright : Dat.Colors.primaryDim
      font.pixelSize: 16
      horizontalAlignment: Text.AlignHCenter
      text: root.icon
      Behavior on color { ColorAnimation { duration: 200 } }
    }

    ColumnLayout {
      Layout.alignment: Qt.AlignVCenter
      Layout.fillWidth: true
      spacing: 1

      Text {
        Layout.fillWidth: true
        color: (root.toggled || itemMouse.containsMouse) ? Dat.Colors.foreground : Dat.Colors.foregroundMuted
        font.family: "Inter"
        font.letterSpacing: 1.5
        font.pixelSize: 15
        font.weight: (root.toggled || itemMouse.containsMouse) ? Font.Normal : Font.Light
        text: root.label
        Behavior on color { ColorAnimation { duration: 200 } }
      }

      Text {
        Layout.fillWidth: true
        color: Dat.Colors.foregroundMuted
        font.family: "Inter"
        font.pixelSize: 11
        font.weight: Font.Light
        opacity: 0.7
        text: root.statusText
        visible: root.statusText.length > 0
      }
    }
  }
}
