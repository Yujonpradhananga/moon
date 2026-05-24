import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Data as Dat
import "../Generics" as Gen

Item {
  id: root
  clip: true

  ColumnLayout {
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 60
    anchors.left: parent.left
    anchors.leftMargin: 40
    anchors.right: parent.right
    anchors.rightMargin: 40
    anchors.top: parent.top
    anchors.topMargin: 80
    spacing: 8

    Item {
      Layout.bottomMargin: 40
      Layout.fillWidth: true
      Layout.preferredHeight: headerCol.height

      ColumnLayout {
        id: headerCol
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        RowLayout {
          Layout.fillWidth: true
          spacing: 12

          Item {
            Layout.preferredHeight: 32
            Layout.preferredWidth: 32

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              hoverEnabled: true
              onClicked: Dat.Globals.sideMenuView = "main"

              Rectangle {
                anchors.fill: parent
                color: parent.containsMouse ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.12) : "transparent"
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

          Text {
            Layout.fillWidth: true
            color: Dat.Colors.secondaryBright
            font.pixelSize: 36
            text: "☽"
          }
        }

        Text {
          Layout.fillWidth: true
          color: Dat.Colors.foreground
          font.family: "Inter"
          font.letterSpacing: 4
          font.pixelSize: 14
          font.weight: Font.Light
          text: "Q U I C K  T O G G L E S"
        }

        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 1
          Layout.topMargin: 12
          color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.3)
        }
      }
    }

    Gen.WifiToggle { Layout.fillWidth: true }
    Gen.BluetoothToggle { Layout.fillWidth: true }
    Gen.NightLightToggle { Layout.fillWidth: true }
    Gen.DndToggle { Layout.fillWidth: true }

    Item {
      Layout.fillHeight: true
      Layout.fillWidth: true
    }

    Text {
      Layout.alignment: Qt.AlignHCenter
      Layout.bottomMargin: 20
      color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.25)
      font.pixelSize: 28
      text: "🌙"
    }
  }
}
