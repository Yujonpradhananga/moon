import QtQuick
import QtQuick.Layouts
import Caelestia.Blobs

import qs.Data as Dat
import qs.Widgets as Wid

Item {
  id: root

  readonly property bool isOpen: Dat.Globals.menuOpen
  readonly property string currentView: Dat.Globals.sideMenuView
  readonly property real menuWidth: 320

  height: parent.height
  opacity: isOpen ? 1.0 : 0.0
  width: menuWidth
  x: isOpen ? 0 : -menuWidth

  // Reset view to main when menu closes
  onIsOpenChanged: {
    if (!isOpen) {
      Dat.Globals.sideMenuView = "main";
    }
  }

  Behavior on x {
    NumberAnimation {
      duration: Dat.Easing.emphasizedTime
      easing.bezierCurve: Dat.Easing.emphasized
    }
  }

  Behavior on opacity {
    NumberAnimation {
      duration: Dat.Easing.emphasizedTime * 0.6
      easing.bezierCurve: Dat.Easing.emphasizedDecel
    }
  }

  // Backdrop — semi-transparent gradient panel
  Rectangle {
    id: backdrop

    anchors.fill: parent
    color: "transparent"

    Rectangle {
      anchors.fill: parent
      color: Dat.Colors.withAlpha(Dat.Colors.background, 0.60)
      radius: 0

      // White shining tint on the right edge
      Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.top: parent.top
        color: "transparent"
        width: 2

        gradient: Gradient {
          GradientStop {
            color: "#00ffffff"
            position: 0.0
          }

          GradientStop {
            color: "#55ffffff"
            position: 0.3
          }

          GradientStop {
            color: "#88ffffff"
            position: 0.5
          }

          GradientStop {
            color: "#55ffffff"
            position: 0.7
          }

          GradientStop {
            color: "#00ffffff"
            position: 1.0
          }
        }
      }
    }
  }

  // Blob group for liquid morph transition between views
  BlobGroup {
    id: menuBlobGroup

    color: Dat.Colors.withAlpha(Dat.Colors.background, 0.60)
    smoothing: 28
  }

  // ── Main menu content ──
  BlobRect {
    id: mainMenuBlob

    group: menuBlobGroup
    width: root.menuWidth
    height: parent.height
    x: root.currentView === "main" ? 0 : -root.menuWidth
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

  // Menu content
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

    // Title area — crescent icon + title
    Item {
      Layout.bottomMargin: 40
      Layout.fillWidth: true
      Layout.preferredHeight: titleColumn.height

      ColumnLayout {
        id: titleColumn

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        // Crescent moon symbol
        Text {
          Layout.fillWidth: true
          color: Dat.Colors.secondaryBright
          font.pixelSize: 48
          text: "☽"

          // Subtle glow via shadow
          layer.enabled: true
          layer.effect: null
        }

        // Title
        Text {
          Layout.fillWidth: true
          color: Dat.Colors.foreground
          font.family: "Inter"
          font.letterSpacing: 4
          font.pixelSize: 14
          font.weight: Font.Light
          text: "M O O N S H E L L"
        }

        // Divider line
        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 1
          Layout.topMargin: 12
          color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.3)
        }
      }
    }

    // Menu items
    Repeater {
      model: ListModel {
        ListElement {
          icon: "▸"
          label: "Continue"
        }

        ListElement {
          icon: "◈"
          label: "Settings"
        }

        ListElement {
          icon: "◫"
          label: "Files"
        }

        ListElement {
          icon: "♫"
          label: "Music"
        }

        ListElement {
          icon: "▣"
          label: "Terminal"
        }

        ListElement {
          icon: "◉"
          label: "Power"
        }
      }

      delegate: Item {
        id: menuItem

        required property int index
        required property string icon
        required property string label

        Layout.fillWidth: true
        Layout.preferredHeight: 52

        // Hover detection
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

        // Background highlight on hover
        Rectangle {
          anchors.fill: parent
          anchors.leftMargin: -12
          anchors.rightMargin: -12
          color: itemMouse.containsMouse ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.12) : "transparent"
          radius: 8

          Behavior on color {
            ColorAnimation {
              duration: 200
            }
          }
        }

        // Left accent bar on hover
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
            NumberAnimation {
              duration: 200
            }
          }
        }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 0
          spacing: 16

          // Icon
          Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 24
            color: itemMouse.containsMouse ? Dat.Colors.secondaryBright : Dat.Colors.primaryDim
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            text: menuItem.icon

            Behavior on color {
              ColorAnimation {
                duration: 200
              }
            }
          }

          // Label
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
              ColorAnimation {
                duration: 200
              }
            }
          }
        }
      }
    }

    // Spacer
    Item {
      Layout.fillHeight: true
      Layout.fillWidth: true
    }

    // Bottom decorative crescent
    Text {
      Layout.alignment: Qt.AlignHCenter
      Layout.bottomMargin: 20
      color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.25)
      font.pixelSize: 28
      text: "🌙"
    }
  }
  } // end main menu BlobRect

  // Content inside main menu — fades with position
  Item {
    id: mainMenuContent
    x: mainMenuBlob.x
    y: 0
    width: root.menuWidth
    height: parent.height
    opacity: root.currentView === "main" ? 1.0 : 0.0
    visible: opacity > 0

    Behavior on opacity {
      NumberAnimation {
        duration: 300
        easing.type: Easing.OutCubic
      }
    }
  }

  // ── Quick Toggles panel ──
  BlobRect {
    id: togglesBlob

    group: menuBlobGroup
    width: root.menuWidth
    height: parent.height
    x: root.currentView === "toggles" ? 0 : root.menuWidth
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

    Wid.QuickTogglesPanel {
      anchors.fill: parent
      opacity: root.currentView === "toggles" ? 1.0 : 0.0
      visible: opacity > 0

      Behavior on opacity {
        NumberAnimation {
          duration: 300
          easing.type: Easing.OutCubic
        }
      }
    }
  }
}
