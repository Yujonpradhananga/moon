import QtQuick
import qs.Data as Dat
import "."

ToggleRow {
  icon: "◉"
  label: "Wi-Fi"
  statusText: Dat.Network.wifiEnabled
    ? (Dat.Network.networkName || "Enabled")
    : "Disabled"
  toggled: Dat.Network.wifiEnabled
  onClicked: Dat.Network.toggleWifi()
}
