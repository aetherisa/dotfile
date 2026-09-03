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
    property string geometry: ""
    property string path: ""
    property bool shouldRecord: false
    property bool shouldCopyToClipboard: false

    function reset(): void {
        root.startX = 0
        root.startY = 0
        root.currentX = 0
        root.currentY = 0
        root.geometry = ""
        root.path = ""
        root.shouldRecord = false
        root.shouldCopyToClipboard = false
    }

    function newScreenshotPath(): string {
        return Quickshell.cachePath(
            "screenshot-" +
            Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss-zzz") +
            ".png")
    }

    function newRecordingPath(): string {
        return Quickshell.cachePath(
            "recording-" +
            Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss-zzz") +
            ".webm")
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
        exclusionMode: ExclusionMode.Ignore
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
                root.shouldRecord = mouse.button === Qt.RightButton
                root.startX = mouse.x
                root.startY = mouse.y
                root.currentX = mouse.x
                root.currentY = mouse.y
            }

            onReleased: {
                root.geometry =
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
            onActivated: {
                picker.visible = false
                root.shouldCopyToClipboard = false
                if (!root.shouldRecord) {
                    root.path = root.newScreenshotPath()
                    screenshotDelay.restart()
                } else {
                    root.path = root.newRecordingPath()
                    recordingDelay.restart()
                }
            }
        }

        Shortcut {
            sequence: "Ctrl+C"
            enabled: selection.width >= 10 && selection.height >= 5
            onActivated: {
                picker.visible = false
                root.shouldCopyToClipboard = true
                if (!root.shouldRecord) {
                    root.path = root.newScreenshotPath()
                    screenshotDelay.restart()
                } else {
                    root.path = root.newRecordingPath()
                    recordingDelay.restart()
                }
            }
        }
    }

    PanelWindow {
        screen: root.screen
        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }

        visible: takeRecording.running
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "screen-picker"

        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: selection.y
            color: Theme.withAlpha(Theme.base0B, "66")
        }

        Rectangle {
            x: 0
            y: selection.y + selection.height
            width: parent.width
            height: parent.height - y
            color: Theme.withAlpha(Theme.base0B, "66")
        }

        Rectangle {
            x: 0
            y: selection.y
            width: selection.x
            height: selection.height
            color: Theme.withAlpha(Theme.base0B, "66")
        }

        Rectangle {
            x: selection.x + selection.width
            y: selection.y
            width: parent.width - x
            height: selection.height
            color: Theme.withAlpha(Theme.base0B, "66")
        }
    }

    Timer {
        id: screenshotDelay
        interval: 50
        repeat: false
        onTriggered: takeScreenshot.running = true
    }

    Process {
        id: takeScreenshot
        command: ["grim", "-g", root.geometry, root.path]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && root.shouldCopyToClipboard) 
                copyScreenshot.running = true
        }
    }

    Process {
        id: copyScreenshot
        command: [
            "sh", "-c", "wl-copy --type image/png < \"$1\"", 
            "screen-picker-copy", root.path
        ]
    }

    Timer {
        id: recordingDelay
        interval: 50
        repeat: false
        onTriggered: takeRecording.running = true
    }

    Process {
        id: takeRecording
        command: [
            "wf-recorder",
            "-g", root.geometry,
            "-c", "libvpx-vp9",
            "-m", "webm",
            "-f", root.path
        ]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && root.shouldCopyToClipboard)
                copyRecording.running = true
        }
    }

    Process {
        id: copyRecording
        command: [
            "sh", "-c",
            "printf 'file://%s\\r\\n' \"$1\" | wl-copy --type text/uri-list",
            "screen-picker-copy", root.path
        ]
    }

    IpcHandler {
        target: "picker"

        function start(): void {
            if (
                takeRecording.running
                || takeScreenshot.running
                || copyRecording.running
                || copyScreenshot.running
                || screenshotDelay.running
                || recordingDelay.running
                || picker.visible
            ) {
                return
            }

            root.reset()
            picker.visible = true
        }

        function stop(): void {
            if (takeRecording.running)
                takeRecording.signal(2)
            picker.visible = false
        }
    }
}
