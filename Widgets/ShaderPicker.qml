import QtQuick
import QtQuick.Layouts
import Quickshell
import Caelestia.Blobs
import qs.Data as Dat
import "../Generics" as Gen

Item {
  id: root
  clip: true

  // ── Effect definitions ────────────────────────────────────────────────────
  readonly property var effects: [
    {
      id:    "motion",
      icon:  "◎",
      label: "Lunar Ripple",
      desc:  "Concentric rings pulse through the moon's surface lines"
    },
    {
      id:    "waterripple",
      icon:  "〰",
      label: "Water Flow",
      desc:  "Scrolling normal-map distortion with depth masking"
    }
  ]

  // Blob group — selection indicator morphs liquidly between options
  BlobGroup {
    id: blobGroup
    color: Dat.Colors.withAlpha(Dat.Colors.background, 0.60)
    smoothing: 20
  }

  ColumnLayout {
    anchors {
      fill: parent
      leftMargin: 40; rightMargin: 40
      topMargin: 80;  bottomMargin: 60
    }
    spacing: 8

    // ── Header ──────────────────────────────────────────────────────────────
    Gen.PanelHeader {
      Layout.fillWidth: true
      Layout.bottomMargin: 40
      title: "B A C K G R O U N D"
      onBack: Dat.Globals.sideMenuView = "main"
    }

    // ── Subtitle ─────────────────────────────────────────────────────────────
    Text {
      Layout.fillWidth: true
      Layout.bottomMargin: 8
      color: Dat.Colors.foregroundMuted
      font.family: "Inter"
      font.pixelSize: 11
      font.weight: Font.Light
      opacity: 0.7
      text: "Select wallpaper effect"
    }

    // ── Effect options ───────────────────────────────────────────────────────
    Repeater {
      model: root.effects

      delegate: Item {
        id: effectRow

        required property var modelData
        required property int index

        Layout.fillWidth: true
        Layout.preferredHeight: 64

        readonly property bool isActive: Dat.Globals.shaderMode === effectRow.modelData.id

        // Blob fill — liquid morph when selection changes
        BlobRect {
          anchors { fill: parent; leftMargin: -12; rightMargin: -12 }
          group:       blobGroup
          radius:      12
          stiffness:   180
          damping:     16
          deformScale: 0.0008
          visible:     effectRow.isActive
        }

        // Hover border when not selected
        Rectangle {
          anchors { fill: parent; leftMargin: -12; rightMargin: -12 }
          color:        hoverArea.containsMouse
            ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.08)
            : "transparent"
          border.color: Dat.Colors.withAlpha(Dat.Colors.outline, 0.18)
          border.width: 1
          radius:       12
          visible:      !effectRow.isActive
          Behavior on color { ColorAnimation { duration: 200 } }
        }

        // Left accent bar
        Rectangle {
          anchors {
            left: parent.left; leftMargin: -16
            top: parent.top;   topMargin: 14
            bottom: parent.bottom; bottomMargin: 14
          }
          color:   Dat.Colors.secondary
          opacity: effectRow.isActive ? 1.0 : 0.0
          radius:  2
          width:   3
          Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        MouseArea {
          id: hoverArea
          anchors.fill: parent
          cursorShape:  Qt.PointingHandCursor
          hoverEnabled: true
          onClicked:    Dat.Globals.shaderMode = effectRow.modelData.id
        }

        RowLayout {
          anchors.fill: parent
          spacing: 16

          // Icon
          Text {
            Layout.alignment:    Qt.AlignVCenter
            Layout.preferredWidth: 24
            horizontalAlignment: Text.AlignHCenter
            color: (effectRow.isActive || hoverArea.containsMouse)
              ? Dat.Colors.secondaryBright : Dat.Colors.primaryDim
            font.pixelSize: 18
            text: effectRow.modelData.icon
            Behavior on color { ColorAnimation { duration: 200 } }
          }

          // Label + description
          ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            spacing: 3

            Text {
              Layout.fillWidth: true
              color: (effectRow.isActive || hoverArea.containsMouse)
                ? Dat.Colors.foreground : Dat.Colors.foregroundMuted
              font.family:      "Inter"
              font.letterSpacing: 1.5
              font.pixelSize:   15
              font.weight: (effectRow.isActive || hoverArea.containsMouse)
                ? Font.Normal : Font.Light
              text: effectRow.modelData.label
              Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
              Layout.fillWidth: true
              color:       Dat.Colors.foregroundMuted
              font.family: "Inter"
              font.pixelSize: 10
              font.weight: Font.Light
              opacity:     0.6
              text:        effectRow.modelData.desc
              wrapMode:    Text.WordWrap
            }
          }

          // Active indicator dot
          Rectangle {
            Layout.alignment:       Qt.AlignVCenter
            Layout.preferredHeight: 8
            Layout.preferredWidth:  8
            color:   Dat.Colors.secondary
            opacity: effectRow.isActive ? 1.0 : 0.0
            radius:  4
            Behavior on opacity { NumberAnimation { duration: 200 } }
          }
        }
      }
    }

    Item { Layout.fillHeight: true; Layout.fillWidth: true }

    Text {
      Layout.alignment:  Qt.AlignHCenter
      Layout.bottomMargin: 20
      color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.25)
      font.pixelSize: 28
      text: "🌙"
    }
  }
}
