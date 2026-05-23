pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property bool wifiEnabled: false
  property string wifiStatus: "disconnected"
  property string networkName: ""
  property int networkStrength: 0

  function toggleWifi() {
    enableWifiProc.command = ["nmcli", "radio", "wifi", wifiEnabled ? "off" : "on"];
    enableWifiProc.running = true;
  }

  function rescanWifi() {
    rescanProc.running = true;
  }

  // Monitor network changes
  Process {
    id: subscriber

    command: ["nmcli", "monitor"]
    running: true

    stdout: SplitParser {
      onRead: root.update()
    }
  }

  function update() {
    wifiStatusProc.running = true;
    networkNameProc.running = true;
    networkStrengthProc.running = true;
  }

  Process {
    id: enableWifiProc
  }

  Process {
    id: rescanProc

    command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
  }

  Process {
    id: wifiStatusProc

    command: ["nmcli", "radio", "wifi"]
    running: true

    environment: ({
      LANG: "C",
      LC_ALL: "C"
    })

    stdout: StdioCollector {
      onStreamFinished: {
        root.wifiEnabled = text.trim() === "enabled";
      }
    }
  }

  Process {
    id: networkNameProc

    command: ["sh", "-c", "nmcli -t -f NAME c show --active | head -1"]
    running: true

    stdout: SplitParser {
      onRead: data => {
        root.networkName = data;
      }
    }
  }

  Process {
    id: networkStrengthProc

    command: ["sh", "-c", "nmcli -f IN-USE,SIGNAL,SSID device wifi | awk '/^\\*/{if (NR!=1) {print $2}}'"]
    running: true

    stdout: SplitParser {
      onRead: data => {
        root.networkStrength = parseInt(data);
      }
    }
  }

  // Connection type detection
  Process {
    id: connectionTypeProc

    property string buffer: ""

    command: ["sh", "-c", "nmcli -t -f TYPE,STATE d status"]
    running: true

    stdout: SplitParser {
      onRead: data => {
        connectionTypeProc.buffer += data + "\n";
      }
    }

    onExited: {
      var lines = buffer.trim().split('\n');
      var status = "disconnected";
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].includes("wifi")) {
          if (lines[i].includes("disconnected")) status = "disconnected";
          else if (lines[i].includes("connected")) status = "connected";
          else if (lines[i].includes("connecting")) status = "connecting";
          else if (lines[i].includes("unavailable")) status = "disabled";
        }
      }
      root.wifiStatus = status;
      buffer = "";
    }
  }

  Component.onCompleted: update()
}
