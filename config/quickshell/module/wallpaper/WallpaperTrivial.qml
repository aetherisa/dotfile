import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.global

PanelWindow {
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    color: Theme[Config.colors.background]
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "qs-trivial-wallpaper"
}
