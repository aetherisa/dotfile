import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    required property ShellScreen screen

    property real startX: 0
    property real startY: 0
    property real currentX: 0
    property real currentY: 0
    property string captureGeometry: ""
    property string capturePath: ""
    property bool recordSelection: false
    property bool copyRecording: false

    function resetSelection(): void {
        root.startX = 0
        root.startY = 0
        root.currentX = 0
        root.currentY = 0
        root.captureGeometry = ""
        root.capturePath = ""
        root.recordSelection = false
    }

    function capture(copyToClipboard): void {
        picker.visible = false

        if (root.recordSelection) {
            root.capturePath = Quickshell.cachePath(
                "recording-" +
                Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss-zzz") +
                ".webm"
            )
            root.copyRecording = copyToClipboard
            recordDelay.restart()
        } else if (copyToClipboard) {
            clipboardDelay.restart()
        } else {
            root.capturePath = Quickshell.cachePath(
                "screenshot-" +
                Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss-zzz") +
                ".png"
            )
            captureDelay.restart()
        }
    }

    function stopRecording(): void {
        if (screenRecorder.running)
            screenRecorder.signal(2)
    }

    PanelWindow {
        id: picker

        screen: root.screen
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

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: selection.y
            color: "#66000000"
        }

        Rectangle {
            x: 0
            y: selection.y + selection.height
            width: parent.width
            height: parent.height - y
            color: "#66000000"
        }

        Rectangle {
            x: 0
            y: selection.y
            width: selection.x
            height: selection.height
            color: "#66000000"
        }

        Rectangle {
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
            color: "transparent"
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onPressed: mouse => {
                root.recordSelection = mouse.button === Qt.RightButton
                root.startX = mouse.x
                root.startY = mouse.y
                root.currentX = mouse.x
                root.currentY = mouse.y
            }

            onReleased: {
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
            onActivated: picker.visible = false
        }

        Shortcut {
            sequence: "Return"
            enabled: selection.width >= 10 && selection.height >= 5
            onActivated: root.capture(false)
        }

        Shortcut {
            sequence: "Ctrl+C"
            enabled: selection.width >= 10 && selection.height >= 5
            onActivated: root.capture(true)
        }
    }

    PanelWindow {
        id: recordingIndicator

        screen: root.screen
        anchors {
            right: true
            top: true
        }
        implicitWidth: 32
        implicitHeight: 32
        visible: screenRecorder.running
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "screen-picker-recording"

        Rectangle {
            anchors.centerIn: parent
            width: 12
            height: 12
            radius: width / 2
            color: Theme.base08
            opacity: 0.75
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.stopRecording()
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
        command: ["grim", "-g", root.captureGeometry, root.capturePath]
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
            "grim -g \"$1\" - | wl-copy --type image/png",
            "screen-picker-copy",
            root.captureGeometry
        ]
    }

    Timer {
        id: recordDelay
        interval: 50
        repeat: false
        onTriggered: screenRecorder.running = true
    }

    Process {
        id: screenRecorder
        command: [
            "wf-recorder",
            "-g", root.captureGeometry,
            "-c", "libvpx-vp9",
            "-m", "webm",
            "-f", root.capturePath
        ]

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && root.copyRecording)
                clipboardRecording.running = true
            else if (exitCode !== 0)
                console.error("wf-recorder failed:", exitCode)

            root.copyRecording = false
        }
    }

    Process {
        id: clipboardRecording
        command: [
            "sh",
            "-c",
            "wl-copy --type video/webm < \"$1\"",
            "screen-picker-copy",
            root.capturePath
        ]
    }

    IpcHandler {
        target: "picker"

        function open(): void {
            if (screenRecorder.running) {
                root.stopRecording()
                return
            }

            root.resetSelection()
            picker.visible = true
        }

        function stop(): void {
            root.stopRecording()
        }
    }
}
