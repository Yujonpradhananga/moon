import QtQuick
import QtQuick.Layouts
import Caelestia.Blobs

import qs.Data as Dat

BlobRect {
  id: root

  required property string currentView
  required property var blobGroup

  group: root.blobGroup
  width: 320
  height: parent.height
  x: root.currentView === "main" ? 0 : -320
  radius: 0
  stiffness: 120
  damping: 16
  deformScale: 0.0008

  Behavior on x {
    NumberAnimation {
      duration: 450
      easing.type: Easing.InOutCubic
    }
  }

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
      Layout.preferredHeight: titleColumn.height

      ColumnLayout {
        id: titleColumn

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        Text {
          Layout.fillWidth: true
          color: Dat.Colors.secondaryBright
          font.pixelSize: 48
          text: "☽"
          layer.enabled: true
          layer.effect: null
        }

        Text {
          Layout.fillWidth: true
          color: Dat.Colors.foreground
          font.family: "Inter"
          font.letterSpacing: 4
          font.pixelSize: 14
          font.weight: Font.Light
          text: "M O O N S H E L L"
        }

        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 1
          Layout.topMargin: 12
          color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.3)
        }
      }
    }

    Repeater {
      model: ListModel {
        ListElement { icon: "▸"; label: "Continue" }
        ListElement { icon: "◈"; label: "Settings" }
        ListElement { icon: "◫"; label: "Files" }
        ListElement { icon: "♫"; label: "Music" }
        ListElement { icon: "▣"; label: "Terminal" }
        ListElement { icon: "◉"; label: "Power" }
      }

      delegate: Item {
        id: menuItem

        required property int index
        required property string icon
        required property string label

        Layout.fillWidth: true
        Layout.preferredHeight: 52

        MouseArea {
          id: itemMouse

          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          hoverEnabled: true

          onClicked: {
            console.log("[MoonShell] Menu clicked: " + menuItem.label);
            if (menuItem.label === "Power") {
              Dat.Globals.powerScreenVisible = true;
            } else if (menuItem.label === "Continue") {
              Dat.Globals.sideMenuView = "toggles";
            }
          }
        }

        Rectangle {
          anchors.fill: parent
          color: itemMouse.containsMouse ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.12) : "transparent"
          radius: 8

          Behavior on color {
            ColorAnimation { duration: 200 }
          }
        }

        Rectangle {
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 10
          anchors.left: parent.left
          anchors.leftMargin: -16
          anchors.top: parent.top
          anchors.topMargin: 10
          color: Dat.Colors.secondary
          opacity: itemMouse.containsMouse ? 1.0 : 0.0
          radius: 2
          width: 3

          Behavior on opacity {
            NumberAnimation { duration: 200 }
          }
        }

        RowLayout {
          anchors.fill: parent
          spacing: 16

          Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 24
            color: itemMouse.containsMouse ? Dat.Colors.secondaryBright : Dat.Colors.primaryDim
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            text: menuItem.icon

            Behavior on color {
              ColorAnimation { duration: 200 }
            }
          }

          Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            color: itemMouse.containsMouse ? Dat.Colors.foreground : Dat.Colors.foregroundMuted
            font.family: "Inter"
            font.letterSpacing: 1.5
            font.pixelSize: 15
            font.weight: itemMouse.containsMouse ? Font.Normal : Font.Light
            text: menuItem.label

            Behavior on color {
              ColorAnimation { duration: 200 }
            }
          }
        }
      }
    }

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
