import QtQuick
import Quickshell
import Quickshell.Wayland

WlrLayershell {
    id: layerRoot
    required property ShellScreen modelData
    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: false
    layer: WlrLayer.Background
    namespace: "wallpaper.engine"
    screen: modelData

Image {
    id: wallpaperImage
    source: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/raga.jpg"
    anchors.fill: parent
    smooth: true
    mipmap: true
    fillMode: Image.PreserveAspectCrop
    opacity: 0
}

Image {
    id: normalMap
    source: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/waterripplenormal.png"
    anchors.fill: parent
    smooth: true
    mipmap: false
    fillMode: Image.PreserveAspectCrop
    opacity: 0
}

ShaderEffect {
    anchors.fill: parent
    property variant source: wallpaperImage
    property variant normalMapSource: normalMap
    property real time: 0
    property real rippleStrength: 0.5

    NumberAnimation on time {
        from: 0
        to: 1000
        duration: 100000
        loops: Animation.Infinite
        running: true
    }

    vertexShader: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/waterripple.vert.qsb"
    fragmentShader: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/waterripple.frag.qsb"
}
}
