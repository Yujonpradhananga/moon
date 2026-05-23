import QtQuick
import QtQuick.Shapes

import qs.Data as Dat

Rectangle {
  id: ropeRect

  property int anchorX: 0
  property int anchorY: 0
  property int pullX: 100
  property int pullY: 100
  property int segments: 12
  property int segmentLength: 8
  property string ropeColor: Dat.Colors.primary

  color: "transparent"

  Shape {
    id: rope

    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    Instantiator {
      model: ropeRect.segments

      delegate: PathCurve {
        property int index: model.index

        x: 500
        y: 500
      }

      onObjectAdded: (index, pathCurve) => {
        pathCurves.pathElements.push(pathCurve);
      }
    }

    ShapePath {
      id: pathCurves

      fillColor: "transparent"
      startX: ropeRect.anchorX
      startY: ropeRect.anchorY
      strokeColor: ropeRect.ropeColor
      strokeWidth: 3
    }

    ShapePath {
      id: dotPath

      PathAngleArc {
        id: startPoint

        property int index: -1
        property double dx: 0
        property double dy: 0
        property double vx: 0
        property double vy: 0

        centerX: ropeRect.anchorX
        centerY: ropeRect.anchorY
        radiusX: 2
        radiusY: 2
        startAngle: 0
        sweepAngle: 360

        onCenterXChanged: {
          pathCurves.startX = centerX;
        }

        onCenterYChanged: {
          pathCurves.startY = centerY;
        }
      }
    }

    // Physics simulation timer
    Timer {
      interval: 1000 / 60
      repeat: true
      running: true

      onTriggered: {
        for (var i = ropeRect.segments; i > 0; i--) {
          var point = dotPath.pathElements[i];
          var line = pathCurves.pathElements[i - 1];
          var prev = dotPath.pathElements[i - 1];

          var prevDx = prev.centerX - point.centerX;
          var prevDy = prev.centerY - point.centerY;
          var prevDist = Math.sqrt(Math.pow(prevDx, 2) + Math.pow(prevDy, 2));
          var prevExtend = prevDist - ropeRect.segmentLength;

          var vx = (prevDx / prevDist) * prevExtend;
          var vy = (prevDy / prevDist) * prevExtend + 9.8;

          if (isNaN(vx)) vx = 0;
          if (isNaN(vy)) vy = 0;

          if (i < ropeRect.segments - 3) {
            var next = dotPath.pathElements[i + 1];
            var nextDx = next.centerX - point.centerX;
            var nextDy = next.centerY - point.centerY;
            var nextDist = Math.sqrt(Math.pow(nextDx, 2) + Math.pow(nextDy, 2));
            var nextExtend = nextDist - ropeRect.segmentLength;

            vx += (nextDx / nextDist) * nextExtend;
            vy += (nextDy / nextDist) * nextExtend;
          } else {
            point.centerX = ropeRect.pullX;
            point.centerY = ropeRect.pullY;
          }

          point.vx = point.vx * 0.5 + vx * 0.45;
          point.vy = point.vy * 0.5 + vy * 0.45;

          point.centerX += point.vx;
          point.centerY += point.vy;
        }
      }
    }

    Instantiator {
      model: ropeRect.segments

      delegate: PathAngleArc {
        id: points

        property int index: model.index
        property double dx: 0
        property double dy: 0
        property double vx: 0
        property double vy: 0

        centerX: ropeRect.anchorX + index
        centerY: ropeRect.anchorY + index
        radiusX: 1
        radiusY: 1
        startAngle: 0
        sweepAngle: 360

        Component.onCompleted: {
          pathCurves.pathElements[index].x = centerX;
          pathCurves.pathElements[index].y = centerY;
        }

        onCenterXChanged: {
          pathCurves.pathElements[index].x = centerX;
        }

        onCenterYChanged: {
          pathCurves.pathElements[index].y = centerY;
        }
      }

      onObjectAdded: (index, pathCurve) => {
        dotPath.pathElements.push(pathCurve);
      }
    }
  }
}
