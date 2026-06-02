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

Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 52

    MouseArea {
        id: wifiMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
onClicked: {
    console.log("[wifi] clicked, setting view to wifi")
    Dat.Network.scanNetworks()
    Dat.Globals.sideMenuView = "wifi"
}
    }

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: -12
        anchors.rightMargin: -12
        color: wifiMouse.containsMouse
            ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.12)
            : "transparent"
        radius: 8
        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Rectangle {
        anchors.top: parent.top; anchors.topMargin: 10
        anchors.bottom: parent.bottom; anchors.bottomMargin: 10
        anchors.left: parent.left; anchors.leftMargin: -16
        width: 3; radius: 2
        color: Dat.Colors.secondary
        opacity: wifiMouse.containsMouse ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 16

        Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 24
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 16
            color: wifiMouse.containsMouse ? Dat.Colors.secondaryBright : Dat.Colors.primaryDim
            text: "◉"
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                font.family: "Inter"
                font.letterSpacing: 1.5
                font.pixelSize: 15
                font.weight: wifiMouse.containsMouse ? Font.Normal : Font.Light
                color: wifiMouse.containsMouse ? Dat.Colors.foreground : Dat.Colors.foregroundMuted
                text: "Wi-Fi"
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
                Layout.fillWidth: true
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.Light
                color: Dat.Colors.foregroundMuted
                opacity: 0.7
                text: Dat.Network.wifiEnabled
                    ? (Dat.Network.networkName || "Enabled")
                    : "Disabled"
            }
        }
    }
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
        toggled = !toggled
        const shader = toggled
          ? "/home/yujon/.config/hypr/Shaders/bluelight.frag"
          : "/home/yujon/.config/hypr/Shaders/vibrant.glsl"
        Quickshell.execDetached(["hyprctl", "eval",
          "hl.config({ decoration = { screen_shader = \"" + shader + "\" } })"])
      }
    }
    Gen.ToggleRow {
      id: grayscale
      Layout.fillWidth: true
      icon: "◑"
      label: "Grayscale"
      statusText: toggled ? "On" : "Off"
      toggled: false
      onClicked: {
        toggled = !toggled
        const shader = toggled
          ? "/home/yujon/.config/hypr/Shaders/grey.glsl"
          : "/home/yujon/.config/hypr/Shaders/vibrant.glsl"
        Quickshell.execDetached(["hyprctl", "eval",
          "hl.config({ decoration = { screen_shader = \"" + shader + "\" } })"])
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
