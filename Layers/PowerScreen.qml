import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Data as Dat
import qs.Widgets as Wid

WlrLayershell {
  id: layerRoot

  required property ShellScreen modelData

  anchors.bottom: true
  anchors.left: true
  anchors.right: true
  anchors.top: true
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  focusable: true
  layer: WlrLayer.Overlay
  namespace: "moon.powerscreen"
  screen: modelData
  visible: Dat.Globals.powerScreenVisible

  // Track the wipe animation state
  // "idle" = hidden, "wipe_in" = circle expanding, "open" = fully open, "wipe_out" = circle shrinking
  property string animState: "idle"
  property real wipeProgress: 0.0

  // When powerScreenVisible toggles, start the wipe-in
  onVisibleChanged: {
    if (visible) {
      animState = "wipe_in";
      wipeInAnim.start();
    }
  }

  // Wipe-in animation: circle grows from center to cover the screen
  NumberAnimation {
    id: wipeInAnim

    duration: 800
    easing.type: Easing.InOutCubic
    from: 0.0
    property: "wipeProgress"
    target: layerRoot
    to: 1.0

    onFinished: {
      layerRoot.animState = "open";
    }
  }

  // Wipe-out animation: circle shrinks back to nothing
  NumberAnimation {
    id: wipeOutAnim

    duration: 600
    easing.type: Easing.InOutCubic
    from: 1.0
    property: "wipeProgress"
    target: layerRoot
    to: 0.0

    onFinished: {
      layerRoot.animState = "idle";
      Dat.Globals.powerScreenVisible = false;
    }
  }

  // Circular wipe overlay
  Wid.CircularWipe {
    id: circularWipe

    anchors.fill: parent
    wipeProgress: layerRoot.wipeProgress
  }

  // Content that fades in after the wipe completes
  Item {
    id: contentArea

    anchors.fill: parent
    opacity: layerRoot.animState === "open" ? 1.0 : 0.0

    Behavior on opacity {
      NumberAnimation {
        duration: 400
        easing.type: Easing.OutCubic
      }
    }

    // Solid dark background
    Rectangle {
      anchors.fill: parent
      color: Dat.Colors.background
    }

    // Auroric plasma effect that follows the mouse
    Wid.AuroricCursor {
      id: auroricEffect

      anchors.fill: parent
      cursorX: powerMouseArea.mouseX
      cursorY: powerMouseArea.mouseY
      glowRadius: 200
    }

    // Subtle scanlines overlay for texture
    Canvas {
      anchors.fill: parent
      opacity: 0.04

      Component.onCompleted: requestPaint()

      onPaint: {
        var ctx = getContext("2d");
        ctx.fillStyle = "#000000";
        for (var y = 0; y < height; y += 4)
          ctx.fillRect(0, y, width, 1);
      }
    }

    // Decorative: small crescent in the center
    Text {
      anchors.centerIn: parent
      color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.15)
      font.pixelSize: 120
      text: "☽"
    }

    // Mouse area for tracking + dismiss
    MouseArea {
      id: powerMouseArea

      anchors.fill: parent
      cursorShape: Qt.ArrowCursor
      hoverEnabled: true

      onClicked: {
        if (layerRoot.animState === "open") {
          layerRoot.animState = "wipe_out";
          wipeOutAnim.start();
        }
      }
    }
  }

  // Escape key to close
  Keys.onEscapePressed: {
    if (animState === "open") {
      animState = "wipe_out";
      wipeOutAnim.start();
    }
  }
}
