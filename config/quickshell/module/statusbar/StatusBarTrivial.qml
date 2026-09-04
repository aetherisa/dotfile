import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import "../../global"

Scope {
    id: root

    required property ShellScreen screen

    PanelWindow {
        id: frame

        screen: root.screen
        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "qs-trivial-statusbar"

        Shape {
            anchors.fill: parent

            ShapePath {
                fillColor: Theme[Config.statusbar.color]
                strokeColor: Theme[Config.statusbar.border.color]
                strokeWidth: Config.statusbar.border.width
                fillRule: ShapePath.OddEvenFill

                startX: 0
                startY: 0

                PathLine { x: frame.width; y: 0 }
                PathLine { x: frame.width; y: frame.height }
                PathLine { x: 0; y: frame.height }
                PathLine { x: 0; y: 0 }

                PathMove {
                    x: Config.statusbar.width
                    y: Config.statusbar.width
                }
                PathLine {
                    x: frame.width - Config.statusbar.width
                    y: Config.statusbar.width
                }
                PathLine {
                    x: frame.width - Config.statusbar.width
                    y: frame.height - Config.statusbar.width
                }
                PathLine {
                    x: Config.statusbar.width
                    y: frame.height - Config.statusbar.width
                }
                PathLine {
                    x: Config.statusbar.width
                    y: Config.statusbar.width
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
        }

        implicitHeight: Config.statusbar.width
        color: "transparent"
        exclusiveZone: Config.statusbar.width
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Top
    }

    PanelWindow {
        screen: root.screen
        anchors {
            left: true
            right: true
            bottom: true
        }

        implicitHeight: Config.statusbar.width
        color: "transparent"
        exclusiveZone: Config.statusbar.width
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Top
    }

    PanelWindow {
        screen: root.screen
        anchors {
            left: true
            top: true
            bottom: true
        }

        implicitWidth: Config.statusbar.width
        color: "transparent"
        exclusiveZone: Config.statusbar.width
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Top
    }

    PanelWindow {
        screen: root.screen
        anchors {
            right: true
            top: true
            bottom: true
        }

        implicitWidth: Config.statusbar.width
        color: "transparent"
        exclusiveZone: Config.statusbar.width
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Top
    }
}
