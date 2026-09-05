pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property bool available: percentage >= 0
    property int percentage: -1

    function refresh(): void {
        if (!reader.running)
            reader.running = true
    }

    Process {
        id: reader

        command: ["brightnessctl", "-m"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.trim().match(/,([0-9]+)%,/)
                root.percentage = match === null
                    ? -1
                    : Number(match[1])
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                root.percentage = -1
        }
    }

    Process {
        id: monitor

        command: [
            "udevadm",
            "monitor",
            "--udev",
            "--subsystem-match=backlight"
        ]
        running: true

        stdout: SplitParser {
            onRead: root.refresh()
        }
    }
}
