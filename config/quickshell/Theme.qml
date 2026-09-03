pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property alias name: adapter.name
    readonly property alias mode: adapter.mode
    readonly property alias base00: adapter.base00
    readonly property alias base01: adapter.base01
    readonly property alias base02: adapter.base02
    readonly property alias base03: adapter.base03
    readonly property alias base04: adapter.base04
    readonly property alias base05: adapter.base05
    readonly property alias base06: adapter.base06
    readonly property alias base07: adapter.base07
    readonly property alias base08: adapter.base08
    readonly property alias base09: adapter.base09
    readonly property alias base0A: adapter.base0A
    readonly property alias base0B: adapter.base0B
    readonly property alias base0C: adapter.base0C
    readonly property alias base0D: adapter.base0D
    readonly property alias base0E: adapter.base0E
    readonly property alias base0F: adapter.base0F

    property int _lutSlot: -1

    readonly property string _nextLutPath:
        Quickshell.cachePath("theme-lut-" + ((_lutSlot + 1) % 2) + ".png")

    readonly property string _rawLutPath:
        Quickshell.cachePath("theme-lut-raw.png")

    readonly property url lutPath:
        _lutSlot < 0
            ? ""
            : "file://" + Quickshell.cachePath("theme-lut-" + _lutSlot + ".png")

    function withAlpha(color, alpha): string {
        return color.slice(0, 1) + alpha + color.slice(1)
    }

    FileView {
        id: themeFile

        path: Qt.resolvedUrl("theme.json")
        watchChanges: true

        onFileChanged: reload()

        onLoaded: {
            if (!lutBuilder.running)
                lutBuilder.running = true
        }

        JsonAdapter {
            id: adapter

            property string name
            property string mode
            property string base00
            property string base01
            property string base02
            property string base03
            property string base04
            property string base05
            property string base06
            property string base07
            property string base08
            property string base09
            property string base0A
            property string base0B
            property string base0C
            property string base0D
            property string base0E
            property string base0F
        }
    }

    IpcHandler {
        target: "theme"

        function reload(): void {
            themeFile.reload()
        }
    }

    Process {
        id: lutBuilder

        command: [
            "lutgen",
            "apply",
            "-P",
            "-o", root._rawLutPath,
            Qt.resolvedUrl("assets/identity.png").toString().replace("file://", ""),
            "--",
            root.base00,
            root.base01,
            root.base02,
            root.base03,
            root.base04,
            root.base05,
            root.base06,
            root.base07,
            root.base08,
            root.base09,
            root.base0A,
            root.base0B,
            root.base0C,
            root.base0D,
            root.base0E,
            root.base0F
        ]

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0)
                lutFlipper.running = true
            else
                console.error("lutgen failed:", exitCode)
        }
    }

    Process {
        id: lutFlipper

        command: [
            "magick",
            root._rawLutPath,
            "-flip",
            root._nextLutPath
        ]

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root._lutSlot = (root._lutSlot + 1) % 2
                console.log("LUT ready:", root.lutPath)
            } else {
                console.error("LUT flip failed:", exitCode)
            }
        }
    }
}
