import QtQuick
import QtQuick.Layouts
import qs.Data as Dat
import qs.Layers as Lay

Item {
    id: root

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        Lay.LunarClockFace {
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            color: Dat.Colors.foregroundMuted
            font.family: "Inter"
            font.letterSpacing: 2
            font.pixelSize: 12
            font.weight: Font.Light
            text: "L U N A R"
        }
    }
}
