pragma Singleton
import Quickshell
import QtQuick

Singleton {
  id: root

  // Deep space backgrounds
  readonly property string background: "#0a0e1a"
  readonly property string surface: "#0f1428"
  readonly property string surfaceContainer: "#141a32"
  readonly property string surfaceContainerHigh: "#1a2240"
  readonly property string surfaceBright: "#222c50"

  // Silver / pearl text & foreground
  readonly property string foreground: "#e8ecf4"
  readonly property string foregroundDim: "#c0c8e0"
  readonly property string foregroundMuted: "#8892b0"

  // Crescent glow — primary accent
  readonly property string primary: "#8fa4d4"
  readonly property string primaryBright: "#b8c8f0"
  readonly property string primaryDim: "#6b7db3"

  // Moonlight gold — secondary accent
  readonly property string secondary: "#d4a843"
  readonly property string secondaryBright: "#f0d080"
  readonly property string secondaryDim: "#a07830"

  // Subtle cosmic purple — tertiary
  readonly property string tertiary: "#9b7ec8"
  readonly property string tertiaryDim: "#7a5eaa"

  // Utility
  readonly property string outline: "#3a4468"
  readonly property string outlineVariant: "#2a3250"
  readonly property string scrim: "#000000"
  readonly property string shadow: "#000000"
  readonly property string error: "#ffb4ab"

  function withAlpha(hex: string, alpha: real): color {
    var c = Qt.color(hex);
    return Qt.rgba(c.r, c.g, c.b, alpha);
  }
}
