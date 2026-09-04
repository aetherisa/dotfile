import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    required property ShellScreen screen

    readonly property int width: 48
    readonly property int radius: 10

    PanelWindow {
        screen: root.screen

        anchors {
            left: true
            top: true
            bottom: true
        }

        implicitWidth: root.width
        exclusionMode: ExclusionMode.Auto
        color: "transparent"
        WlrLayershell.namespace: "status-bar-reservation"
    }

    PanelWindow {
        id: overlay

        screen: root.screen

        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "status-bar"

        mask: Region {
            x: 0
            y: 0
            width: root.width
            height: overlay.height
        }

        Shape {
            id: background

            anchors.fill: parent

            ShapePath {
                fillColor: Theme.base00
                strokeColor: "transparent"
                fillRule: ShapePath.OddEvenFill
                startX: 0
                startY: 0

                PathLine { x: background.width; y: 0 }
                PathLine { x: background.width; y: background.height }
                PathLine { x: 0; y: background.height }
                PathLine { x: 0; y: 0 }

                PathMove { x: root.width + root.radius; y: 0 }
                PathLine { x: background.width; y: 0 }
                PathLine { x: background.width; y: background.height }
                PathLine { x: root.width + root.radius; y: background.height }
                PathArc {
                    x: root.width
                    y: background.height - root.radius
                    radiusX: root.radius
                    radiusY: root.radius
                }
                PathLine { x: root.width; y: root.radius }
                PathArc {
                    x: root.width + root.radius
                    y: 0
                    radiusX: root.radius
                    radiusY: root.radius
                }
            }
        }

        ColumnLayout {
            id: components

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }

            width: root.width
            spacing: 0
        }
    }
}
