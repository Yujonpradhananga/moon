pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
  id: root

  readonly property bool available: Bluetooth.adapters.values.length > 0
  readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false
  readonly property bool connected: Bluetooth.devices.values.some(d => d.connected)
  readonly property string deviceName: {
    var dev = Bluetooth.defaultAdapter?.devices.values.find(d => d.connected);
    return dev ? dev.name : "";
  }

  function toggle() {
    if (Bluetooth.defaultAdapter) {
      Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
    }
  }
}
