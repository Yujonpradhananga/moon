pragma Singleton
import Quickshell
import QtQuick

// ─────────────────────────────────────────────────────────────────────────────
// Globals — shell-wide shared state
// All properties here are reactive: components bind to them directly.
// ─────────────────────────────────────────────────────────────────────────────
Singleton {
  id: root

  // ── Mouse ─────────────────────────────────────────────────────────────────
  // Normalized (0.0 = left, 1.0 = right), updated by SidePanel's MouseArea
  property real mouseX:       0.5
  property real mouseOffsetX: 0.0  // (-1 to 1) for parallax
  property real mouseOffsetY: 0.0  // (-1 to 1) for parallax

  Behavior on mouseOffsetX {
    NumberAnimation { duration: 800; easing.type: Easing.OutQuart }
  }
  Behavior on mouseOffsetY {
    NumberAnimation { duration: 800; easing.type: Easing.OutQuart }
  }

  // ── Menu trigger ──────────────────────────────────────────────────────────
  // menuOpen is driven ONLY by an explicit click on the edge pill.
  // It is NOT auto-opened by mouse proximity, so it never steals focus from apps.
  property bool menuOpen: false

  // ── Navigation ────────────────────────────────────────────────────────────
  // "main" | "toggles" | "settings"
  property string sideMenuView: "main"

  // ── Overlays ──────────────────────────────────────────────────────────────
  property bool powerScreenVisible: false

  // ── Wallpaper effect (Stage 3 of WallpaperEngine) ─────────────────────────
  // "none"        → parallax only (clean)
  // "motion"      → circular ripple rings on depth-masked lines
  // "waterripple" → scrolling normal-map distortion
  property string shaderMode: "motion"
}
