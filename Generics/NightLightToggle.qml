import QtQuick
import Quickshell
import qs.Data as Dat
import "."

ToggleRow {
  id: root
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
