pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    readonly property var focused: Hyprland.focusedWorkspace
    readonly property var focusedMonitor: Hyprland.focusedMonitor
    readonly property int focusedId: focused?.id ?? 0
    readonly property int focusedWindowCount:
        focused?.lastIpcObject?.windows ?? 0
    readonly property bool focusedIsEmpty: focusedWindowCount === 0
    readonly property bool specialVisible:
        (focusedMonitor?.lastIpcObject?.specialWorkspace?.id ?? 0) !== 0

    Connections {
        target: Hyprland

        function onRawEvent(): void {
            Hyprland.refreshWorkspaces()
            Hyprland.refreshMonitors()
        }
    }

    Component.onCompleted: {
        Hyprland.refreshWorkspaces()
        Hyprland.refreshMonitors()
    }
}
