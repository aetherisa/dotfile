pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    signal themeReloadRequested()
    signal pickerStartRequested()
    signal pickerStopRequested()
    signal pickerDismissRequested()

    function initialize(): void {}

    function dismissPicker(): void {
        root.pickerDismissRequested()
    }

    IpcHandler {
        target: "theme"

        function reload(): void {
            root.themeReloadRequested()
        }
    }

    IpcHandler {
        target: "picker"

        function start(): void {
            root.pickerStartRequested()
        }

        function stop(): void {
            root.pickerStopRequested()
        }
    }
}
