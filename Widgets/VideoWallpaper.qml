import QtQuick
import QtMultimedia

import qs.Data as Dat

Item {
  id: root

  // The overscan: how many extra pixels exist on each side
  // With zoom 1.2 on a 1920px screen, the video is 2304px wide
  // Extra = 2304 - 1920 = 384px total, so 192px on each side
  readonly property real extraWidth: (videoOutput.width - root.width)
  readonly property real extraHeight: (videoOutput.height - root.height)

  // Dead zone: the center portion of the screen where no panning occurs.
  // edgeZone = 0.20 means the outer 20% on each side triggers panning.
  readonly property real edgeZone: 0.20

  // Parallax offset with dead zone:
  // mouseX in [0, edgeZone]         → pan left  (shift goes from +max to 0)
  // mouseX in [edgeZone, 1-edgeZone] → dead zone (shift = 0)
  // mouseX in [1-edgeZone, 1]       → pan right (shift goes from 0 to -max)
  readonly property real parallaxX: {
    var mx = Dat.Globals.mouseX;
    var shift = 0;
    if (mx < edgeZone) {
      // Left edge: remap [0, edgeZone] → [1, 0]
      shift = (1.0 - mx / edgeZone) * 0.5;
    } else if (mx > 1.0 - edgeZone) {
      // Right edge: remap [1-edgeZone, 1] → [0, -1]
      shift = -((mx - (1.0 - edgeZone)) / edgeZone) * 0.5;
    }
    return shift * extraWidth * Dat.Globals.parallaxIntensity;
  }

  clip: true

  MediaPlayer {
    id: player

    audioOutput: AudioOutput {
      muted: true
    }
    loops: MediaPlayer.Infinite
    source: Qt.resolvedUrl("../Assets/moon.mp4")

    onErrorOccurred: (error, errorString) => {
      console.log("[MoonShell] Video error: " + errorString);
    }

    Component.onCompleted: {
      player.play();
    }
  }

  VideoOutput {
    id: videoOutput

    height: root.height * Dat.Globals.videoZoom
    width: root.width * Dat.Globals.videoZoom
    x: (root.width - width) / 2 + root.parallaxX
    y: (root.height - height) / 2

    Behavior on x {
      NumberAnimation {
        duration: Dat.Easing.smoothTime
        easing.bezierCurve: Dat.Easing.smooth
      }
    }
  }

  // Bind the player to the output
  Binding {
    property: "videoOutput"
    target: player
    value: videoOutput
  }
}
