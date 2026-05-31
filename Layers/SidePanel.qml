import QtQuick
import QtQuick.Particles
import Quickshell
import Quickshell.Wayland

import qs.Components as Comp
import qs.Data as Dat

WlrLayershell {
  id: layerRoot

  required property ShellScreen modelData

  anchors.top: true
  anchors.bottom: true
  anchors.left: true
  implicitWidth: Dat.Globals.menuOpen
    ? (circleSize / 2) + menuWidth + 20
    : circleSize + 80

  Behavior on implicitWidth {
    NumberAnimation { duration: 50 }
  }

  readonly property real circleSize: 56
  readonly property real menuWidth: 320
  readonly property real dragThreshold: 40

  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  focusable: false
  layer: WlrLayer.Top
  namespace: "moon.sidepanel"
  screen: modelData
  surfaceFormat.opaque: false

  MouseArea {
    id: globalTracker
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    hoverEnabled: true
    propagateComposedEvents: true

    onPositionChanged: mouse => {
      const fullW = layerRoot.screen.width
      if (fullW > 0) {
        Dat.Globals.mouseX       = mouse.x / fullW
        Dat.Globals.mouseOffsetX = (mouse.x / fullW - 0.5) * 2.0
        Dat.Globals.mouseOffsetY = (mouse.y / layerRoot.height - 0.5) * 2.0
      }
    }
  }

  mask: Region {
    regions: [menuRegion, circleRegion]
  }

  Region { id: menuRegion; item: sideMenu }

  // Tight mask — only covers the 8px edge strip + visible circle extent
  Region {
    id: circleRegion
    x: 0
    y: circleZone.y + (circleZone.height - layerRoot.circleSize) / 2 - 20
    width: Math.max(8, circle.x + circleZone.dragX + layerRoot.circleSize + 16)
    height: layerRoot.circleSize + 40
  }

  Comp.SideMenu {
    id: sideMenu
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: parent.left
  }

  Item {
    id: circleZone

    readonly property real r: layerRoot.circleSize
    property real dragX: 0
    property bool dragging: false
    property bool hidden: false
    readonly property real dragProgress: Math.min(dragX / layerRoot.dragThreshold, 1.0)

    clip: false
    width:  r + 24 + layerRoot.dragThreshold + 20
    height: r + 120
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left

    Connections {
      target: Dat.Globals
      function onMenuOpenChanged() {
        if (!Dat.Globals.menuOpen) {
          circle.completing = false
          circleZone.hidden = false
        }
      }
    }

    Rectangle {
      id: circle

      property bool completing: false

      width:  circleZone.r
      height: circleZone.r
      radius: circleZone.r / 2

      readonly property real hiddenX: -(circleZone.r) - 10
      readonly property real shownX:  (circleZone.r + 24 - circleZone.r) / 2
      readonly property real baseX:   (hoverArea.containsMouse || circleZone.dragging) && !Dat.Globals.menuOpen
                                        ? shownX
                                        : hiddenX

      x: circleZone.dragging ? (shownX + circleZone.dragX) : baseX

      Behavior on x {
        enabled: !circleZone.dragging
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
      }

      anchors.verticalCenter: parent.verticalCenter

      opacity: (completing || Dat.Globals.menuOpen || circleZone.hidden) ? 0.0 : 1.0
      Behavior on opacity {
        enabled: !circleZone.hidden
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
      }

      gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop {
          position: 0.0
          color: Qt.rgba(
            0.6 + 0.2 * circleZone.dragProgress,
            0.47 + 0.1 * circleZone.dragProgress,
            0.93,
            1.0
          )
        }
        GradientStop { position: 1.0; color: "#3d2875" }
      }

      border.width: hoverArea.containsMouse || circleZone.dragging ? 2 : 0
      border.color: Qt.rgba(0.73, 0.6, 1.0, 0.5 + 0.5 * circleZone.dragProgress)
      Behavior on border.width {
        NumberAnimation { duration: 200 }
      }

      scale: circleZone.dragging
               ? (1.0 + 0.12 * circleZone.dragProgress)
               : hoverArea.containsMouse ? 1.05
               : 1.0
      Behavior on scale {
        enabled: !circleZone.dragging
        NumberAnimation { duration: 180; easing.type: Easing.OutBack; easing.overshoot: 0.55 }
      }

      Text {
        anchors.centerIn: parent
        text: "☽"
        font.pixelSize: 22
        color: "#f0e8ff"
        opacity: hoverArea.containsMouse ? 1.0 : 0.6
        Behavior on opacity { NumberAnimation { duration: 200 } }

        SequentialAnimation on scale {
          running: hoverArea.containsMouse && !circleZone.dragging && !Dat.Globals.menuOpen
          loops: Animation.Infinite
          NumberAnimation { to: 1.12; duration: 850; easing.type: Easing.InOutSine }
          NumberAnimation { to: 1.00; duration: 850; easing.type: Easing.InOutSine }
        }
      }

      Rectangle {
        id: dragTrail
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.left
        anchors.rightMargin: 2
        height: 2
        width: circleZone.dragging ? circleZone.dragX * 0.8 : 0
        radius: 1
        opacity: circleZone.dragProgress * 0.7
        gradient: Gradient {
          orientation: Gradient.Horizontal
          GradientStop { position: 0.0; color: "transparent" }
          GradientStop { position: 1.0; color: "#bb99ff" }
        }
        Behavior on width {
          enabled: !circleZone.dragging
          NumberAnimation { duration: 200 }
        }
      }

      Rectangle {
        id: ripple
        anchors.centerIn: parent
        width: 0; height: 0
        radius: width / 2
        color: "#55ffffff"
        opacity: 0

        ParallelAnimation {
          id: rippleAnim
          NumberAnimation { target: ripple; property: "width";   from: 0; to: circleZone.r * 2.4; duration: 280; easing.type: Easing.OutCubic }
          NumberAnimation { target: ripple; property: "height";  from: 0; to: circleZone.r * 2.4; duration: 280; easing.type: Easing.OutCubic }
          NumberAnimation { target: ripple; property: "opacity"; from: 0.55; to: 0;               duration: 280; easing.type: Easing.OutCubic }
        }
      }
    }

    Text {
      id: dragText
      anchors.left: circle.right
      anchors.leftMargin: 8
      anchors.verticalCenter: circle.verticalCenter
      text: circleZone.dragProgress > 0.15 ? "›" : "DRAG"
      font.family: "Inter"
      font.pixelSize: circleZone.dragProgress > 0.15 ? 20 : 9
      font.letterSpacing: circleZone.dragProgress > 0.15 ? 0 : 2.5
      font.weight: Font.Medium
      color: "#c8b8ff"
opacity: (hoverArea.containsMouse || circleZone.dragging) && !Dat.Globals.menuOpen && !circleZone.hidden && !circle.completing
           ? (0.5 + 0.5 * circleZone.dragProgress)
           : 0.0
Behavior on opacity {
  enabled: !circleZone.hidden && !circle.completing
  NumberAnimation { duration: 200 }
}
      Behavior on font.pixelSize { NumberAnimation { duration: 150 } }
    }

    MouseArea {
      id: hoverArea
      hoverEnabled: true
      cursorShape: circleZone.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor
      visible: !Dat.Globals.menuOpen

      // Vertically centered on the circle, not filling the whole circleZone
      x: 0
      y: (circleZone.height - circleZone.r - 40) / 2
      height: circleZone.r + 40

      // Key fix: only 8px wide at the left edge when idle so it doesn't
      // block the top-left corner of the screen. Expands rightward while
      // dragging to avoid losing the gesture mid-movement.
      width: circleZone.dragging
              ? (circle.shownX + circleZone.dragX + circleZone.r + 8)
              : hoverArea.containsMouse
                  ? (circle.shownX + circleZone.r + 16)
                  : 8
      Behavior on width {
        enabled: !circleZone.dragging
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
      }

      property real startX: 0

      onPressed: mouse => {
        circleZone.dragging = true
        circleZone.dragX = 0
        startX = mouse.x
      }

      onPositionChanged: mouse => {
        if (!circleZone.dragging) return
        circleZone.dragX = Math.max(0, mouse.x - startX)
      }

      onReleased: mouse => {
        if (circleZone.dragX >= layerRoot.dragThreshold) {
          circle.completing = true
          rippleAnim.restart()
          sparkSystem.running = true
          sparkEmitter.emitRate = 120
          burstTimer.restart()
          menuOpenDelay.restart()
          resetCircle.restart()
        } else {
          circleZone.dragging = false
          circleZone.dragX = 0
        }
      }

      onCanceled: {
        circleZone.dragging = false
        circleZone.dragX = 0
      }
    }

    Timer {
      id: resetCircle
      interval: 400
      repeat: false
      onTriggered: {
        circleZone.dragging = false
        circleZone.dragX = 0
        circleZone.hidden = true
      }
    }

    ParticleSystem {
      id: sparkSystem
      anchors.centerIn: circle
      width: circleZone.r * 3
      height: circleZone.r * 3
      running: false

      ImageParticle {
        groups: ["spark"]
        source: "qrc:///particleresources/star.png"
        color: "#d4b8ff"
        colorVariation: 0.3
        alpha: 0.95
        alphaVariation: 0.1
        rotationVariation: 360
        autoRotation: true
        entryEffect: ImageParticle.Fade
      }

      Emitter {
        id: sparkEmitter
        group: "spark"
        anchors.centerIn: parent
        width: 8; height: 8
        emitRate: 0
        lifeSpan: 350
        lifeSpanVariation: 100
        size: 24
        sizeVariation: 14
        endSize: 3

        velocity: AngleDirection {
          angle: 0
          angleVariation: 360
          magnitude: 130
          magnitudeVariation: 60
        }

        acceleration: AngleDirection {
          angle: 90
          magnitude: 35
        }
      }

      Timer {
        id: burstTimer
        interval: 200
        repeat: false
        onTriggered: sparkEmitter.emitRate = 0
      }

      Timer {
        interval: 600
        running: burstTimer.triggered
        repeat: false
        onTriggered: sparkSystem.running = false
      }
    }

    Timer {
      id: menuOpenDelay
      interval: 100
      repeat: false
      onTriggered: Dat.Globals.menuOpen = true
    }
  }
}
