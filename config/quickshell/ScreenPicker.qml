import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    visible: false
    WlrLayershell.keyboardFocus:
        visible
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None
    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "screen-picker"

    property real startX: 0
    property real startY: 0
    property real currentX: 0
    property real currentY: 0
    property string captureGeometry: ""
    property string capturePath: ""

    Rectangle {
        // top
        x: 0
        y: 0
        width: parent.width
        height: selection.y
        color: "#66000000"
    }

    Rectangle {
        // bottom
        x: 0
        y: selection.y + selection.height
        width: parent.width
        height: parent.height - y
        color: "#66000000"
    }

    Rectangle {
        // left
        x: 0
        y: selection.y
        width: selection.x
        height: selection.height
        color: "#66000000"
    }

    Rectangle {
        // right
        x: selection.x + selection.width
        y: selection.y
        width: parent.width - x
        height: selection.height
        color: "#66000000"
    }

    Rectangle {
        id: selection

        x: Math.min(root.startX, root.currentX)
        y: Math.min(root.startY, root.currentY)

        width: Math.abs(root.currentX - root.startX)
        height: Math.abs(root.currentY - root.startY)

        color: "#00000000"
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton

        onPressed: mouse => {
            root.startX = mouse.x
            root.startY = mouse.y
            root.currentX = mouse.x
            root.currentY = mouse.y
        }

        onReleased: {
            console.log(selection.x, selection.y, selection.width, selection.height)
            root.captureGeometry = 
                `${Math.round(root.screen.x + selection.x)},` +
                `${Math.round(root.screen.y + selection.y)} ` +
                `${Math.round(selection.width)}x${Math.round(selection.height)}`
        }

        onPositionChanged: mouse => {
            if (!pressed)
                return

            root.currentX = mouse.x
            root.currentY = mouse.y
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.visible = false
    }

    Shortcut {
        sequence: "Return"
        enabled: selection.width >= 10 && selection.height >= 5
        onActivated: {
            root.capturePath = Quickshell.cachePath(
                "screenshot-" +
                Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss-zzz") +
                ".png"
            )
            root.visible = false
            captureDelay.restart()
        }
    }

    Shortcut {
        sequence: "Ctrl+C"
        enabled: selection.width >= 10 && selection.height >= 5
        onActivated: {
            root.visible = false
            clipboardDelay.restart()
        }
    }

    Timer {
        id: captureDelay
        interval: 50
        repeat: false

        onTriggered: screenshot.running = true
    }

    Process {
        id: screenshot
        command: [
            "grim",
            "-g",
            root.captureGeometry,
            root.capturePath
        ]
    }
    
    Timer {
        id: clipboardDelay
        interval: 50
        repeat: false

        onTriggered: clipboardScreenshot.running = true
    }

    Process {
        id: clipboardScreenshot

        command: [
            "sh",
            "-c",
            "grim -g '" + root.captureGeometry + "' - | wl-copy --type image/png",
        ]
    }

    IpcHandler {
        target: "picker"

        function open(): void {
            root.startX = 0
            root.startY = 0
            root.currentX = 0
            root.currentY = 0
            root.captureGeometry = ""
            root.capturePath = ""
            root.visible = true
        }
    }
}
