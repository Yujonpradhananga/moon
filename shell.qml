//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import qs.Layers as Lay

ShellRoot {
  Variants {
    model: Quickshell.screens
    Scope {
      id: scopeRoot
      required property ShellScreen modelData

      // Mouse tracker — feeds Globals.mouseX for all components
      Lay.MouseTracker {
        modelData: scopeRoot.modelData
      }

      // Wallpaper — rendering only (WallpaperEngine + dim + clock)
      Lay.Wallpaper {
        modelData: scopeRoot.modelData
      }

      // Side panel — modular, triggers via Globals.mouseX
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
