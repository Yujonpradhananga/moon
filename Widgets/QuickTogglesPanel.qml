// QuickTogglesPanel.qml
// Wi-Fi, Bluetooth, and system toggles panel.

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Data as Dat
import "../Generics" as Gen

Item {
  id: root
  clip: true

  ColumnLayout {
    anchors {
      fill: parent
      leftMargin: 40; rightMargin: 40
      topMargin: 80;  bottomMargin: 60
    }
    spacing: 8

    Gen.PanelHeader {
      Layout.fillWidth: true
      Layout.bottomMargin: 40
      title: "Q U I C K  T O G G L E S"
      onBack: Dat.Globals.sideMenuView = "main"
    }

    Gen.ToggleRow {
      Layout.fillWidth: true
      icon:       "◉"
      label:      "Wi-Fi"
      statusText: Dat.Network.wifiEnabled
        ? (Dat.Network.networkName || "Enabled")
        : "Disabled"
      toggled:    Dat.Network.wifiEnabled
      onClicked:  Dat.Network.toggleWifi()
    }

    Gen.ToggleRow {
      Layout.fillWidth: true
      icon:       "◈"
      label:      "Bluetooth"
      statusText: Dat.Bluetooth.enabled
        ? (Dat.Bluetooth.connected ? Dat.Bluetooth.deviceName : "On")
        : "Disabled"
      toggled:    Dat.Bluetooth.enabled
      visible:    Dat.Bluetooth.available
      onClicked:  Dat.Bluetooth.toggle()
    }

    Gen.ToggleRow {
      id: nightLight
      Layout.fillWidth: true
      icon:       "☾"
      label:      "Night Light"
      statusText: toggled ? "On" : "Off"
      toggled:    false
      onClicked: {
        toggled = !toggled;
        Quickshell.execDetached(["hyprctl", "keyword", "decoration:screen_shader",
          toggled ? Qt.resolvedUrl("~/.config/hypr/shaders/nightlight.glsl").toString() : ""]);
      }
    }

    Gen.ToggleRow {
      id: dnd
      Layout.fillWidth: true
      icon:       "◯"
      label:      "Do Not Disturb"
      statusText: toggled ? "On" : "Off"
      toggled:    false
      onClicked: {
        toggled = !toggled;
        Quickshell.execDetached(["bash", "-c",
          toggled
            ? "makoctl set-mode do-not-disturb 2>/dev/null; swaync-client -d 2>/dev/null"
            : "makoctl set-mode default 2>/dev/null; swaync-client -D 2>/dev/null"]);
      }
    }

    Gen.ToggleRow {
      id: idleInhibit
      Layout.fillWidth: true
      icon:       "☀"
      label:      "Idle Inhibitor"
      statusText: toggled ? "Screen stays on" : "Off"
      toggled:    false
      onClicked: {
        toggled = !toggled;
        Quickshell.execDetached(["bash", "-c",
          toggled
            ? "pidof wayland-idle-inhibitor.py || wayland-idle-inhibitor.py &"
            : "pkill -f wayland-idle-inhibitor"]);
      }
    }

    Gen.ToggleRow {
      id: gameMode
      Layout.fillWidth: true
      icon:       "▣"
      label:      "Game Mode"
      statusText: toggled ? "Active" : "Off"
      toggled:    false
      onClicked: {
        toggled = !toggled;
        Quickshell.execDetached(["bash", "-c",
          "gamemoded -" + (toggled ? "r" : "d") + " 2>/dev/null"]);
      }
    }

    Item { Layout.fillHeight: true; Layout.fillWidth: true }

    Text {
      Layout.alignment:    Qt.AlignHCenter
      Layout.bottomMargin: 20
      color:          Dat.Colors.withAlpha(Dat.Colors.primary, 0.25)
      font.pixelSize: 28
      text: "🌙"
    }
  }
}
