import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import qs.Data as Dat
import qs.Generics as Gen

Item {
    id: root

    property string uptime: ""
    property string osName: ""
    property string kernel: ""
    property string arch: ""
    property string cpuUsage: ""
    property string ramUsed: ""
    property string ramTotal: ""
    property string diskUsage: ""
    property string swapUsed: ""
    property string swapTotal: ""
    property string runningProcesses: ""
    property string loggedInUsers: ""

    function refresh() {
        uptimeProc.running = true
        osProc.running = true
        kernelProc.running = true
        cpuProc.running = true
        ramProc.running = true
        diskProc.running = true
        swapProc.running = true
        processProc.running = true
        usersProc.running = true
    }

Process { id: uptimeProc; command: ["sh", "-c", "cat /proc/uptime | awk '{s=$1; h=int(s/3600); m=int((s%3600)/60); print h\"h \"m\"m\"}'"]
    stdout: SplitParser { onRead: data => root.uptime = data.trim() } }
    Process { id: osProc; command: ["sh", "-c", ". /etc/os-release && echo $PRETTY_NAME"]
        stdout: SplitParser { onRead: data => root.osName = data.trim() } }
    Process { id: kernelProc; command: ["sh", "-c", "uname -r; uname -m"]
        stdout: SplitParser { onRead: data => {
            const lines = data.trim().split("\n")
            if (lines.length >= 2) { root.kernel = lines[0]; root.arch = lines[1] }
            else root.kernel = data.trim()
        }}}
    Process { id: cpuProc; command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print int($2+$4)}'"]
        stdout: SplitParser { onRead: data => root.cpuUsage = data.trim() + "%" } }
    Process { id: ramProc; command: ["sh", "-c", "free -m | awk '/Mem:/{print $3\"/\"$2}'"]
        stdout: SplitParser { onRead: data => {
            const p = data.trim().split("/")
            root.ramUsed = p[0] || ""; root.ramTotal = p[1] || ""
        }}}
    Process { id: diskProc; command: ["sh", "-c", "df -h / | awk 'NR==2{print $3\"/\"$2}'"]
        stdout: SplitParser { onRead: data => root.diskUsage = data.trim() } }
    Process { id: swapProc; command: ["sh", "-c", "free -m | awk '/Swap:/{print $3\"/\"$2}'"]
        stdout: SplitParser { onRead: data => {
            const p = data.trim().split("/")
            root.swapUsed = p[0] || ""; root.swapTotal = p[1] || ""
        }}}
    Process { id: processProc; command: ["sh", "-c", "ps aux | wc -l"]
        stdout: SplitParser { onRead: data => root.runningProcesses = data.trim() } }
    Process { id: usersProc; command: ["sh", "-c", "who | wc -l"]
        stdout: SplitParser { onRead: data => root.loggedInUsers = data.trim() } }

    Timer {
        interval: 5000
        running: Dat.Globals.sideMenuView === "sysinfo"
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

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
            title: "S Y S T E M"
            onBack: Dat.Globals.sideMenuView = "main"
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                width: parent.width
                spacing: 0

                Repeater {
                    model: [
                        { label: "Uptime",      value: root.uptime,                                         accent: true  },
                        { label: "OS",          value: root.osName,                                         accent: true  },
                        { label: "CPU",         value: root.cpuUsage,                                       accent: false },
                        { label: "RAM",         value: root.ramUsed + " / " + root.ramTotal + " MB",        accent: false },
                        { label: "Disk",        value: root.diskUsage,                                      accent: false },
                        { label: "Swap",        value: root.swapUsed + " / " + root.swapTotal + " MB",      accent: false },
                        { label: "Kernel",      value: root.kernel,                                         accent: false },
                        { label: "Processes",   value: root.runningProcesses,                               accent: true  },
                        { label: "Users",       value: root.loggedInUsers,                                  accent: true  },
                    ]

                    delegate: Item {
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.leftMargin: -12
                            anchors.rightMargin: -12
                            color: rowMouse.containsMouse
                                ? Dat.Colors.withAlpha(Dat.Colors.primary, 0.12)
                                : "transparent"
                            radius: 8
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        Rectangle {
                            anchors.top: parent.top; anchors.topMargin: 14
                            anchors.bottom: parent.bottom; anchors.bottomMargin: 14
                            anchors.left: parent.left; anchors.leftMargin: -16
                            width: 3; radius: 2
                            color: Dat.Colors.secondary
                            opacity: modelData.accent ? 1.0 : 0.0
                        }

                        RowLayout {
                            anchors.fill: parent
                            spacing: 8

                            Text {
                                Layout.preferredWidth: 80
                                text: modelData.label
                                color: modelData.accent
                                    ? Dat.Colors.secondary
                                    : Dat.Colors.foregroundMuted
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Light
                                font.letterSpacing: 1
                            }

                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignRight
                                text: modelData.value || "—"
                                color: Dat.Colors.foreground
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Normal
                                elide: Text.ElideRight
                            }
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
