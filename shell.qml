//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import qs.Layers as Lay
import qs.Components as Comp

ShellRoot {
  Variants {
    model: Quickshell.screens
    Scope {
      id: scopeRoot
      required property ShellScreen modelData
      Lay.Wallpaper {
        modelData: scopeRoot.modelData
      }
      Lay.PowerScreen {
        modelData: scopeRoot.modelData
      }
      Comp.SideMenu {
        parent: scopeRoot
      }
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
