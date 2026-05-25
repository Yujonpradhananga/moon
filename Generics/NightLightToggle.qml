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
      Quickshell.execDetached(["hyprctl", "keyword", "decoration:screen_shader",
        "/home/yujon/.config/hypr/Shaders/bluelight.frag"]);
    else
      Quickshell.execDetached(["hyprctl", "keyword", "decoration:screen_shader",
        "/home/yujon/.config/hypr/Shaders/vibrant.glsl"]);
  }
}
