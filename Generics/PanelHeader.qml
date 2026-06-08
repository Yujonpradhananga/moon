import QtQuick
import QtQuick.Layouts
import qs.Data as Dat

Item {
  id: root

  property string title: ""
  signal back

  implicitHeight: col.height

  ColumnLayout {
    id: col
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: 8

    // Back button row
    RowLayout {
      Layout.fillWidth: true
      spacing: 12

      Item {
        Layout.preferredHeight: 36
        Layout.preferredWidth: 36

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          hoverEnabled: true
          onClicked: root.back()

          Rectangle {
            anchors.fill: parent
            color: parent.containsMouse
              ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.12)
              : "transparent"
            radius: 8
            Behavior on color { ColorAnimation { duration: 200 } }
          }
        }

        Text {
          anchors.centerIn: parent
          color: Dat.Colors.foreground
          font.pixelSize: 18
          text: "◂"
        }
      }

      // Crescent icon
      Text {
        Layout.fillWidth: true
        color: Dat.Colors.secondaryBright
        font.pixelSize: 36
        text: "☽"
      }
    }

    // Panel title
    Text {
      Layout.fillWidth: true
      color: Dat.Colors.foreground
      font.family: "Inter"
      font.letterSpacing: 4
      font.pixelSize: 14
      font.weight: Font.Light
      text: root.title
    }

    // Divider
    Rectangle {
      Layout.fillWidth: true
      Layout.preferredHeight: 1
      Layout.topMargin: 12
      color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.3)
    }
  }
}
