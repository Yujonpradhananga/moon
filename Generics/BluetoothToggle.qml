import QtQuick
import qs.Data as Dat
import "."

ToggleRow {
  icon: "◈"
  label: "Bluetooth"
  statusText: Dat.Bluetooth.enabled
    ? (Dat.Bluetooth.connected ? Dat.Bluetooth.deviceName : "On")
    : "Disabled"
  toggled: Dat.Bluetooth.enabled
  visible: Dat.Bluetooth.available
  onClicked: Dat.Bluetooth.toggle()
}
