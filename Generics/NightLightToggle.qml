import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Data as Dat
import "."

ToggleRow {
  id: root
  icon: "☾"
  label: "Night Light"
  statusText: toggled ? "On" : "Off"
  toggled: false

  Process {
    id: shaderProc
    stdout: SplitParser {
      onRead: data => console.log("STDOUT:", data)
    }
    stderr: SplitParser {
      onRead: data => console.log("STDERR:", data)
    }
    onExited: (code, status) => console.log("Exited:", code, status)
  }

  Connections {
    target: root
    function onClicked() {
      root.toggled = !root.toggled
      const shader = root.toggled
        ? "/home/yujon/.config/hypr/Shaders/bluelight.frag"
        : "/home/yujon/.config/hypr/Shaders/vibrant.glsl"

      const cmd = "hl.config({ decoration = { screen_shader = \"" + shader + "\" } })"
      console.log("Running:", cmd)
      shaderProc.command = ["hyprctl", "eval", cmd]
      shaderProc.startDetached()
    }
  }
}
