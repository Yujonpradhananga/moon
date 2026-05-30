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
        visible: false
    }

    Image {
        id: normalMap
        source: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/waterripplenormal.png"
        anchors.fill: parent
        smooth: true
        mipmap: false
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    ShaderEffect {
        id: shader
        anchors.fill: parent
        property variant source: wallpaperImage
        property variant normalMapSource: normalMap
        property real time: 0
        property real rippleStrength: 0.1
        property real rippleX: 0.2
        property real rippleY: 0.2
        property real rippleAge: 999.0

        NumberAnimation on time {
            from: 0
            to: 1000
            duration: 100000
            loops: Animation.Infinite
            running: true
        }

        Timer {
            interval: 16
            running: true
            repeat: true
            onTriggered: shader.rippleAge += 0.016
        }

        vertexShader: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/waterripple.vert.qsb"
        fragmentShader: "file:///home/yujon/Projects/quickshell/moon/Assets/mahoraga/waterripple.frag.qsb"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton  // don't capture clicks, just track position

        onPositionChanged: (mouse) => {
            shader.rippleX = mouse.x / width
            shader.rippleY = mouse.y / height
            shader.rippleAge = 0.0
        }
    }
}
