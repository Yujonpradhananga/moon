//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import qs.Layers as Lay
import qs.Widgets as Wid

ShellRoot {
  Variants {
    model: Quickshell.screens
    Scope {
      id: scopeRoot
      required property ShellScreen modelData

      // Wallpaper engine (WlrLayershell at Background level)
      Wid.WallpaperEngine {
        modelData: scopeRoot.modelData
      }

      // Side panel — mouse tracking + menu (Top level)
      Lay.SidePanel {
        modelData: scopeRoot.modelData
      }

      // Power screen overlay
      Lay.PowerScreen {
        modelData: scopeRoot.modelData
      }

      // Cava visualizer
      Lay.Cava {
        modelData: scopeRoot.modelData
      }

      Connections {
        function onReloadCompleted() {
          Quickshell.inhibitReloadPopup();
        }
        function onReloadFailed() {
          Quickshell.inhibitReloadPopup();
        }
        target: Quickshell
      }
    }
  }
}
