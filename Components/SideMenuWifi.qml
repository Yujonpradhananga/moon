import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Caelestia.Blobs
import qs.Data as Dat
import qs.Generics as Gen

BlobRect {
  id: root

  required property real menuWidth
  required property string currentView

  width: menuWidth
  height: parent.height
  x: currentView === "wifi" ? 0 : menuWidth
  radius: 0
  stiffness: 0
  damping: 24
  deformScale: 1.0002

  Behavior on x {
    NumberAnimation { duration: 450; easing.type: Easing.InOutCubic }
  }

  property string selectedSsid: ""
  property bool showPassword: selectedSsid !== ""

  ColumnLayout {
    anchors {
      fill: parent
      leftMargin: 40; rightMargin: 40
      topMargin: 80;  bottomMargin: 60
    }
    spacing: 8

    Gen.PanelHeader {
      Layout.fillWidth: true
      Layout.bottomMargin: 24
      title: "W I - F I"
      onBack: Dat.Globals.sideMenuView = "toggles"
    }

    ScrollView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true

      ColumnLayout {
        width: parent.width
        spacing: 0

        Repeater {
          model: Dat.Network.networks

          delegate: Item {
            id: netItem
            required property var modelData
            Layout.fillWidth: true
            Layout.preferredHeight: 52

            MouseArea {
              id: netMouse
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              hoverEnabled: true
              onClicked: {
                if (netItem.modelData.inUse) return
                root.selectedSsid = netItem.modelData.ssid
              }
            }

            Rectangle {
              anchors.fill: parent
              anchors.leftMargin: -12
              anchors.rightMargin: -12
              color: netMouse.containsMouse
                ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.12)
                : "transparent"
              radius: 8
              Behavior on color { ColorAnimation { duration: 200 } }
            }

            Rectangle {
              anchors.top: parent.top; anchors.topMargin: 10
              anchors.bottom: parent.bottom; anchors.bottomMargin: 10
              anchors.left: parent.left; anchors.leftMargin: -16
              width: 3; radius: 2
              color: Dat.Colors.secondary
              opacity: netItem.modelData.inUse ? 1.0 : 0.0
              Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            RowLayout {
              anchors.fill: parent
              spacing: 16

              Text {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 24
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 16
                color: netItem.modelData.inUse
                  ? Dat.Colors.secondaryBright
                  : Dat.Colors.primaryDim
                text: netItem.modelData.signal > 66 ? "▲"
                    : netItem.modelData.signal > 33 ? "△"
                    : "▽"
                Behavior on color { ColorAnimation { duration: 200 } }
              }

              ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                spacing: 1

                Text {
                  Layout.fillWidth: true
                  font.family: "Inter"
                  font.letterSpacing: 1.5
                  font.pixelSize: 15
                  font.weight: netItem.modelData.inUse ? Font.Normal : Font.Light
                  color: netItem.modelData.inUse
                    ? Dat.Colors.foreground
                    : Dat.Colors.foregroundMuted
                  text: netItem.modelData.ssid
                  Behavior on color { ColorAnimation { duration: 200 } }
                }

                Text {
                  Layout.fillWidth: true
                  font.family: "Inter"
                  font.pixelSize: 11
                  font.weight: Font.Light
                  color: Dat.Colors.foregroundMuted
                  opacity: 0.7
                  text: netItem.modelData.inUse ? "Connected"
                      : netItem.modelData.security ? "Secured"
                      : "Open"
                }
              }
            }
          }
        }
      }
    }

    // Password overlay
    Item {
      Layout.fillWidth: true
      visible: root.showPassword
      Layout.preferredHeight: visible ? 100 : 0
      Behavior on Layout.preferredHeight {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
      }

      ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 40
          color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.1)
          radius: 8
          border.width: 1
          border.color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.3)

          TextField {
            id: passwordInput
            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
            verticalAlignment: TextInput.AlignVCenter
            font.family: "Inter"
            font.pixelSize: 14
            color: Dat.Colors.foreground
            echoMode: TextInput.Password
            placeholderText: "Password for " + root.selectedSsid
            background: Item {}
            Keys.onReturnPressed: connectBtn.connectNow()
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 8

          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 36

            MouseArea {
              id: cancelBtn
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              hoverEnabled: true
              onClicked: {
                root.selectedSsid = ""
                passwordInput.text = ""
              }
            }
            Rectangle {
              anchors.fill: parent
              radius: 8
              color: cancelBtn.containsMouse
                ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.12)
                : "transparent"
              Behavior on color { ColorAnimation { duration: 200 } }
            }
            Text {
              anchors.centerIn: parent
              text: "Cancel"
              color: Dat.Colors.foregroundMuted
              font.family: "Inter"
              font.pixelSize: 13
            }
          }

          Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 36

            MouseArea {
              id: connectBtn
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              hoverEnabled: true
              function connectNow() {
                Quickshell.execDetached([
                  "nmcli", "dev", "wifi", "connect", root.selectedSsid,
                  "password", passwordInput.text
                ])
                root.selectedSsid = ""
                passwordInput.text = ""
              }
              onClicked: connectNow()
            }
            Rectangle {
              anchors.fill: parent
              radius: 8
              color: connectBtn.containsMouse
                ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.2)
                : Dat.Colors.withAlpha(Dat.Colors.primary, 0.1)
              Behavior on color { ColorAnimation { duration: 200 } }
            }
            Text {
              anchors.centerIn: parent
              text: "Connect"
              color: Dat.Colors.secondaryBright
              font.family: "Inter"
              font.pixelSize: 13
              font.weight: Font.Medium
            }
          }
        }
      }
    }

    Text {
      Layout.alignment: Qt.AlignHCenter
      Layout.bottomMargin: 20
      color: Dat.Colors.withAlpha(Dat.Colors.primary, 0.25)
      font.pixelSize: 28
      text: "🌙"
    }
  }
}
