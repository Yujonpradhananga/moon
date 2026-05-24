import QtQuick
import Quickshell
import qs.Data as Dat
import "."

ToggleRow {
  id: root
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
