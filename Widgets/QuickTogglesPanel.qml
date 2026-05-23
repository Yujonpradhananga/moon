import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.Data as Dat

Item {
  id: root

  clip: true

  // ── Toggle rows ──
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

    // Header — back + title
    Item {
      Layout.bottomMargin: 40
      Layout.fillWidth: true
      Layout.preferredHeight: headerCol.height

      ColumnLayout {
        id: headerCol

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        // Back arrow row
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

              onClicked: {
                Dat.Globals.sideMenuView = "main";
              }

              Rectangle {
                anchors.fill: parent
                color: parent.containsMouse ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.12) : "transparent"
                radius: 8

                Behavior on color {
                  ColorAnimation { duration: 200 }
                }
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

        // Title
        Text {
          Layout.fillWidth: true
          color: Dat.Colors.foreground
          font.family: "Inter"
          font.letterSpacing: 4
          font.pixelSize: 14
          font.weight: Font.Light
          text: "Q U I C K  T O G G L E S"
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

    // ── Wi-Fi ──
    ToggleRow {
      Layout.fillWidth: true
      icon: "◉"
      label: "Wi-Fi"
      statusText: Dat.Network.wifiEnabled
        ? (Dat.Network.networkName || "Enabled")
        : "Disabled"
      toggled: Dat.Network.wifiEnabled

      onClicked: Dat.Network.toggleWifi()
    }

    // ── Bluetooth ──
    ToggleRow {
      Layout.fillWidth: true
      icon: "◈"
      label: "Bluetooth"
      statusText: Dat.Bluetooth.enabled
        ? (Dat.Bluetooth.connected ? Dat.Bluetooth.deviceName : "On")
        : "Disabled"
      toggled: Dat.Bluetooth.enabled
      visible: Dat.Bluetooth.available

      onClicked: Dat.Bluetooth.toggle()
    }

    // ── Night Light ──
    ToggleRow {
      id: nightLightToggle

      Layout.fillWidth: true
      icon: "☾"
      label: "Night Light"
      statusText: toggled ? "On" : "Off"
      toggled: false

      onClicked: {
        toggled = !toggled;
        if (toggled)
          Quickshell.execDetached(["bash", "-c", "hyprctl keyword decoration:screen_shader ~/.config/hypr/shaders/nightlight.glsl"]);
        else
          Quickshell.execDetached(["bash", "-c", "hyprctl keyword decoration:screen_shader ''"]);
      }
    }

    // ── Do Not Disturb ──
    ToggleRow {
      id: dndToggle

      Layout.fillWidth: true
      icon: "◯"
      label: "Do Not Disturb"
      statusText: toggled ? "On" : "Off"
      toggled: false

      onClicked: {
        toggled = !toggled;
        if (toggled)
          Quickshell.execDetached(["bash", "-c", "makoctl set-mode do-not-disturb 2>/dev/null; swaync-client -d 2>/dev/null"]);
        else
          Quickshell.execDetached(["bash", "-c", "makoctl set-mode default 2>/dev/null; swaync-client -D 2>/dev/null"]);
      }
    }

    // ── Idle Inhibitor ──
    ToggleRow {
      id: idleToggle

      Layout.fillWidth: true
      icon: "☀"
      label: "Idle Inhibitor"
      statusText: toggled ? "Screen stays on" : "Off"
      toggled: false

      onClicked: {
        toggled = !toggled;
        if (toggled)
          Quickshell.execDetached(["bash", "-c", "pidof wayland-idle-inhibitor.py || wayland-idle-inhibitor.py &"]);
        else
          Quickshell.execDetached(["bash", "-c", "pkill -f wayland-idle-inhibitor"]);
      }
    }

    // ── Game Mode ──
    ToggleRow {
      id: gameModeToggle

      Layout.fillWidth: true
      icon: "▣"
      label: "Game Mode"
      statusText: toggled ? "Active" : "Off"
      toggled: false

      onClicked: {
        toggled = !toggled;
        Quickshell.execDetached(["bash", "-c", "gamemoded -" + (toggled ? "r" : "d") + " 2>/dev/null"]);
      }
    }

    // Spacer
    Item {
      Layout.fillHeight: true
      Layout.fillWidth: true
    }

    // Bottom crescent
    Text {
      Layout.alignment: Qt.AlignHCenter
      Layout.bottomMargin: 20
      color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.25)
      font.pixelSize: 28
      text: "🌙"
    }
  }

  // ── Toggle row component — matches SideMenu item styling exactly ──
  component ToggleRow: Item {
    id: toggleRow

    required property string icon
    required property string label
    property string statusText: ""
    property bool toggled: false

    signal clicked

    implicitHeight: 52

    // Hover detection
    MouseArea {
      id: itemMouse

      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: true

      onClicked: toggleRow.clicked()
    }

    // Background highlight on hover — same as SideMenu
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

    // Left accent bar — same as SideMenu (shows when toggled OR hovered)
    Rectangle {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.left: parent.left
      anchors.leftMargin: -16
      anchors.top: parent.top
      anchors.topMargin: 10
      color: Dat.Colors.secondary
      opacity: (toggleRow.toggled || itemMouse.containsMouse) ? 1.0 : 0.0
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

      // Icon — same colors as SideMenu
      Text {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 24
        color: (toggleRow.toggled || itemMouse.containsMouse) ? Dat.Colors.secondaryBright : Dat.Colors.primaryDim
        font.pixelSize: 16
        horizontalAlignment: Text.AlignHCenter
        text: toggleRow.icon

        Behavior on color {
          ColorAnimation {
            duration: 200
          }
        }
      }

      // Label + status column
      ColumnLayout {
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: true
        spacing: 1

        // Label — same font as SideMenu
        Text {
          Layout.fillWidth: true
          color: (toggleRow.toggled || itemMouse.containsMouse) ? Dat.Colors.foreground : Dat.Colors.foregroundMuted
          font.family: "Inter"
          font.letterSpacing: 1.5
          font.pixelSize: 15
          font.weight: (toggleRow.toggled || itemMouse.containsMouse) ? Font.Normal : Font.Light
          text: toggleRow.label

          Behavior on color {
            ColorAnimation {
              duration: 200
            }
          }
        }

        // Status text (smaller, dim)
        Text {
          Layout.fillWidth: true
          color: Dat.Colors.foregroundMuted
          font.family: "Inter"
          font.pixelSize: 11
          font.weight: Font.Light
          opacity: 0.7
          text: toggleRow.statusText
          visible: toggleRow.statusText.length > 0
        }
      }
    }
  }
}
