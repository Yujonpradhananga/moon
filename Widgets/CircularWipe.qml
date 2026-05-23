import QtQuick

import qs.Data as Dat

Item {
  id: root

  // The circular wipe progress: 0.0 = fully transparent, 1.0 = fully covered
  property real wipeProgress: 0.0
  // Center of the wipe circle (defaults to screen center)
  property real wipeCenterX: width / 2
  property real wipeCenterY: height / 2
  // Max radius needed to cover the entire screen from center
  readonly property real maxRadius: Math.sqrt(width * width + height * height) / 2

  // Canvas draws the circular wipe mask
  Canvas {
    id: wipeCanvas

    anchors.fill: parent

    onPaint: {
      var ctx = getContext("2d");
      ctx.reset();

      if (root.wipeProgress <= 0.0) return;

      var radius = root.maxRadius * root.wipeProgress;

      // Draw full-screen dark fill
      ctx.fillStyle = Dat.Colors.background;
      ctx.globalAlpha = 1.0;
      ctx.fillRect(0, 0, width, height);

      // Cut out the inverse — we want the circle to REVEAL darkness
      // So we fill the screen and leave a hole that shrinks
      // Actually: circular wipe = circle grows from center covering the screen
      ctx.reset();
      ctx.fillStyle = Dat.Colors.background;
      ctx.globalAlpha = 1.0;

      // Draw the expanding circle
      ctx.beginPath();
      ctx.arc(root.wipeCenterX, root.wipeCenterY, radius, 0, 2 * Math.PI);
      ctx.fill();
    }
  }

  // Repaint whenever progress changes
  onWipeProgressChanged: wipeCanvas.requestPaint()
  onWidthChanged: wipeCanvas.requestPaint()
  onHeightChanged: wipeCanvas.requestPaint()
}
