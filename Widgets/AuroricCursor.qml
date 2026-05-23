import QtQuick

import qs.Data as Dat

Item {
  id: root

  // Mouse position (updated externally)
  property real cursorX: width / 2
  property real cursorY: height / 2

  // Radius of the auroric glow around the cursor
  property real glowRadius: 180

  // Animation time driver
  property real t: 0

  NumberAnimation on t {
    duration: 9000
    from: 0
    loops: Animation.Infinite
    running: true
    to: 6.2832
  }

  Canvas {
    id: auroraCanvas

    anchors.fill: parent

    onPaint: {
      var ctx = getContext("2d");
      var w = width, h = height;
      ctx.clearRect(0, 0, w, h);

      var time = root.t;
      var mx = root.cursorX;
      var my = root.cursorY;
      var radius = root.glowRadius;
      var step = 10;

      // Only render within the glow area (perf optimisation)
      var x0 = Math.max(0, Math.floor((mx - radius - step) / step) * step);
      var y0 = Math.max(0, Math.floor((my - radius - step) / step) * step);
      var x1 = Math.min(w, mx + radius + step);
      var y1 = Math.min(h, my + radius + step);

      for (var y = y0; y <= y1; y += step) {
        for (var x = x0; x <= x1; x += step) {
          // Distance from cursor
          var dx = x - mx;
          var dy = y - my;
          var dist = Math.sqrt(dx * dx + dy * dy);

          if (dist > radius) continue;

          // Fade factor: 1.0 at cursor, 0.0 at edge
          var fade = 1.0 - (dist / radius);
          fade = fade * fade; // Quadratic falloff for softness

          // Plasma function (from Spectral)
          var nx = x / w, ny = y / h;
          var cx = nx - 0.5 + 0.28 * Math.sin(time * 0.5);
          var cy = ny - 0.5 + 0.28 * Math.cos(time * 0.4);
          var v = Math.sin(nx * 6 + time)
                + Math.sin(ny * 6 + time * 0.7)
                + Math.sin((nx + ny) * 4 + time * 1.3)
                + Math.sin(Math.sqrt(cx * cx + cy * cy) * 8 - time);
          var n = (v + 4) / 8;

          // Lunar aurora palette — deep indigos, silver blues, soft golds
          var r, g, b;
          if (n < 0.33) {
            var f = n / 0.33;
            r = Math.round(15 + f * 50);
            g = Math.round(12 + f * 40);
            b = Math.round(40 + f * 120);
          } else if (n < 0.66) {
            var f = (n - 0.33) / 0.33;
            r = Math.round(65 + f * 80);
            g = Math.round(52 + f * 100);
            b = Math.round(160 + f * 50);
          } else {
            var f = (n - 0.66) / 0.34;
            r = Math.round(145 + f * 65);
            g = Math.round(152 + f * 80);
            b = Math.round(210 - f * 20);
          }

          ctx.globalAlpha = fade * 0.7;
          ctx.fillStyle = "rgb(" + r + "," + g + "," + b + ")";
          ctx.fillRect(x, y, step + 1, step + 1);
        }
      }

      ctx.globalAlpha = 1.0;
    }
  }

  // Repaint whenever cursor moves or time ticks
  onCursorXChanged: auroraCanvas.requestPaint()
  onCursorYChanged: auroraCanvas.requestPaint()
  onTChanged: auroraCanvas.requestPaint()
}
