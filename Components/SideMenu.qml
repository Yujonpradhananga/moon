import QtQuick
import QtQuick.Layouts
import QtQuick.Particles
import Caelestia.Blobs
import Qt5Compat.GraphicalEffects
import qs.Data as Dat
import qs.Widgets as Wid
import qs.Generics as Gen

Item {
  id: root
Timer {
  id: filesOpenTimer
  interval: 1
  repeat: false
  onTriggered: Dat.Globals.sideMenuView = "files"
}
  readonly property bool isOpen: Dat.Globals.menuOpen
  readonly property string currentView: Dat.Globals.sideMenuView
  readonly property real menuWidth: 320

  clip: true
  height: parent.height
  width: isOpen ? menuWidth : 0
  Behavior on width {
    NumberAnimation { duration: 480; easing.type: Easing.OutCubic }
  }
  x: 0
  opacity: 1.0
  visible: irisRadius > 0 || opacity > 0
  readonly property real irisMax: Math.sqrt(menuWidth * menuWidth + height * height) / 2 + 10
  property real irisRadius: 0
  onIsOpenChanged: {
    if (isOpen) {
      root.opacity = 1.0
      irisOpenAnim.restart()
    } else {
      irisCloseAnim.restart()
      Dat.Globals.sideMenuView = "main"
    }
  }
  NumberAnimation {
    id: irisOpenAnim
    target: root
    property: "irisRadius"
    from: 0
    to: root.irisMax
    duration: 480
    easing.bezierCurve: Dat.Easing.emphasizedDecel
  }
  ParallelAnimation {
    id: irisCloseAnim
    NumberAnimation {
      target: root; property: "irisRadius"
      from: root.irisMax; to: 0
      duration: 340; easing.bezierCurve: Dat.Easing.emphasizedAccel
    }
    NumberAnimation {
      target: root; property: "opacity"
      from: 1.0; to: 0.0
      duration: 280; easing.type: Easing.OutCubic
    }
  }

  Canvas {
    id: irisCanvas
    anchors.fill: parent
    visible: false
    property real radius: root.irisRadius
    onRadiusChanged: requestPaint()
    onPaint: {
      const ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)
      ctx.fillStyle = "black"
      ctx.beginPath()
      ctx.arc(width / 2, height / 2, radius, 0, Math.PI * 2)
      ctx.fill()
    }
  }

  layer.enabled: true
  layer.effect: OpacityMask {
    maskSource: irisCanvas
  }

  MouseArea {
    id: dismissArea
    anchors.fill: parent
    enabled: root.isOpen
    z: -1
    onClicked: Dat.Globals.menuOpen = false
  }

  Rectangle {
    id: backdrop
    anchors.fill: parent
    color: "transparent"
    Rectangle {
      anchors.fill: parent
color: Dat.Colors.withAlpha(Dat.Colors.background, 0.60)
      radius: 0
      Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.top: parent.top
        color: "transparent"
        width: 2
        gradient: Gradient {
          GradientStop { color: "#00ffffff"; position: 0.0 }
          GradientStop { color: "#55ffffff"; position: 0.3 }
          GradientStop { color: "#88ffffff"; position: 0.5 }
          GradientStop { color: "#55ffffff"; position: 0.7 }
          GradientStop { color: "#00ffffff"; position: 1.0 }
        }
      }
    }
  }

  BlobGroup {
    id: menuBlobGroup
    color: Dat.Colors.withAlpha(Dat.Colors.background, 0.60)
    smoothing: 8
  }

  // Main menu panel
BlobRect {
  id: mainMenuBlob
  group: menuBlobGroup
  width: root.menuWidth
  height: parent.height
  x: root.currentView === "main" ? 0 : -root.menuWidth
  radius: 0
  stiffness: 0
  damping: 24
  deformScale: 1.0002
  Behavior on x {
    NumberAnimation { duration: 450; easing.type: Easing.InOutCubic }
  }
    ColumnLayout {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 60
      anchors.left: parent.left
      anchors.leftMargin: 40
      anchors.right: parent.right
      anchors.rightMargin: 40
      anchors.top: parent.top
      anchors.topMargin: 80
      spacing: 8
      Item {
        Layout.bottomMargin: 40
        Layout.fillWidth: true
        Layout.preferredHeight: titleColumn.height
        ColumnLayout {
          id: titleColumn
          anchors.left: parent.left
          anchors.right: parent.right
          spacing: 8
          Text {
            Layout.fillWidth: true
            color: Dat.Colors.secondaryBright
            font.pixelSize: 48
            text: "☽"
            layer.enabled: true
            layer.effect: null
          }
          Text {
            Layout.fillWidth: true
            color: Dat.Colors.foreground
            font.family: "Inter"
            font.letterSpacing: 4
            font.pixelSize: 14
            font.weight: Font.Light
            text: "M O O N S H E L L"
          }
          Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.topMargin: 12
            color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.0)
          }
        }
      }
      Repeater {
        model: ListModel {
          ListElement { icon: "▸"; label: "Continue" }
          ListElement { icon: "◈"; label: "Settings" }
          ListElement { icon: "◫"; label: "Files" }
          ListElement { icon: "♫"; label: "Music" }
          ListElement { icon: "▣"; label: "Terminal" }
          ListElement { icon: "◉"; label: "Power" }
        }
        delegate: Item {
          id: menuItem
          required property int index
          required property string icon
          required property string label
          Layout.fillWidth: true
          Layout.preferredHeight: 52
          MouseArea {
            id: itemMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: {
              console.log("[MoonShell] Menu clicked: " + menuItem.label)
              if (menuItem.label === "Power") {
                Dat.Globals.powerScreenVisible = true
              } else if (menuItem.label === "Continue") {
                Dat.Globals.sideMenuView = "toggles"
              } else if (menuItem.label === "Settings") {
                Dat.Globals.sideMenuView = "settings"
} else if (menuItem.label === "Files") {
  Dat.Globals.menuOpen = false
  filesOpenTimer.restart()

              } else if (menuItem.label === "Terminal") {
                Dat.Globals.sideMenuView = "sysinfo"
              }
            }
          }
          RowLayout {
            anchors.fill: parent
            spacing: 16
            Text {
              Layout.alignment: Qt.AlignVCenter
              Layout.preferredWidth: 24
              color: itemMouse.containsMouse ? Dat.Colors.secondaryBright : Dat.Colors.primaryDim
              font.pixelSize: 16
              horizontalAlignment: Text.AlignHCenter
              text: menuItem.icon
              Behavior on color { ColorAnimation { duration: 200 } }
            }
            Text {
              Layout.alignment: Qt.AlignVCenter
              Layout.fillWidth: true
              color: itemMouse.containsMouse ? Dat.Colors.foreground : Dat.Colors.foregroundMuted
              font.family: "Inter"
              font.letterSpacing: 1.5
              font.pixelSize: 15
              font.weight: itemMouse.containsMouse ? Font.Normal : Font.Light
              text: menuItem.label
              Behavior on color { ColorAnimation { duration: 200 } }
            }
          }
        }
      }
      Item { Layout.fillHeight: true; Layout.fillWidth: true }
      Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: 20
        color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.25)
        font.pixelSize: 28
        text: "🌙"
      }
    }
  }

  Item {
    id: mainMenuContent
    x: mainMenuBlob.x
    y: 0
    width: root.menuWidth
    height: parent.height
    opacity: root.currentView === "main" ? 1.0 : 0.0
    visible: opacity > 0
    Behavior on opacity {
      NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
  }

  // Toggles panel
Item {
  id: togglesBlob
  width: root.menuWidth
  height: parent.height
  x: root.currentView === "toggles" ? 0 : root.menuWidth
  Behavior on x {
    NumberAnimation { duration: 450; easing.type: Easing.InOutCubic }
  }
  Wid.QuickTogglesPanel {
    anchors.fill: parent
    opacity: root.currentView === "toggles" ? 1.0 : 0.0
    visible: opacity > 0
    Behavior on opacity {
      NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
  }
}

  Item {
      id: sysinfoBlob
      width: root.menuWidth
      height: parent.height
      x: root.currentView === "sysinfo" ? 0 : root.menuWidth
      Behavior on x {
          NumberAnimation { duration: 450; easing.type: Easing.InOutCubic }
      }
      SideMenuSystemInfo {
          anchors.fill: parent
          opacity: root.currentView === "sysinfo" ? 1.0 : 0.0
          visible: opacity > 0
          Behavior on opacity {
              NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
          }
      }
    }


  // Settings panel
  SideMenuSettings {
    menuWidth: root.menuWidth
    currentView: root.currentView
  }

  // Wi-Fi panel
  SideMenuWifi {
    menuWidth: root.menuWidth
    currentView: root.currentView
  }

  // Particle system
  ParticleSystem {
    id: starSystem
    anchors.fill: parent
    running: root.isOpen
    ImageParticle {
      groups: ["star"]
      source: "qrc:///particleresources/star.png"
      color: "#c8b8ff"
      colorVariation: 0.25
      alpha: 0.9
      alphaVariation: 0.15
      rotationVariation: 360
      autoRotation: false
      entryEffect: ImageParticle.Fade
    }
    Emitter {
      id: starEmitter
      group: "star"
      x: 0
      y: -4
      width: root.menuWidth
      height: 8
      emitRate: 0
      lifeSpan: 2400
      lifeSpanVariation: 800
      size: 28
      sizeVariation: 20
      endSize: 4
      velocity: AngleDirection {
        angle: 90
        angleVariation: 22
        magnitude: 150
        magnitudeVariation: 60
      }
      acceleration: AngleDirection {
        angle: 90
        magnitude: 50
      }
    }
    Timer {
      id: burstTimer
      interval: 700
      running: false
      repeat: false
      onTriggered: starEmitter.emitRate = 0
    }
    Connections {
      target: root
      function onIsOpenChanged() {
        if (root.isOpen) {
          starEmitter.emitRate = 90
          burstTimer.restart()
        } else {
          burstTimer.stop()
          starEmitter.emitRate = 0
        }
      }
    }
  }
}
