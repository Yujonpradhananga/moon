import QtQuick
import Quickshell.Io

Item {
  Process {
    id: test
    command: ["bash", "-c", "touch /tmp/qs_works"]
    running: true
  }
}
