import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }

    color: Theme.base00
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Bottom
}
