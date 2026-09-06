import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.global

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
                fillColor: Theme[Config.colors.background]
                strokeColor: Theme[Config.colors.border]
                strokeWidth: Config.borderWidth
                fillRule: ShapePath.OddEvenFill

                startX: -Config.borderWidth
                startY: -Config.borderWidth

                PathLine {
                    x: frame.width + Config.borderWidth
                    y: -Config.borderWidth
                }
                PathLine {
                    x: frame.width + Config.borderWidth
                    y: frame.height + Config.borderWidth
                }
                PathLine {
                    x: -Config.borderWidth
                    y: frame.height + Config.borderWidth
                }
                PathLine {
                    x: -Config.borderWidth
                    y: -Config.borderWidth
                }

                PathMove {
                    x: Config.padding
                    y: Config.padding
                }

                PathLine {
                    x: frame.width - Config.padding
                    y: Config.padding
                }
                PathLine {
                    x: frame.width - Config.padding
                    y: frame.height - Config.padding
                }
                PathLine {
                    x: Config.padding
                    y: frame.height - Config.padding
                }
                PathLine {
                    x: Config.padding
                    y: Config.padding
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

        implicitHeight: Config.padding
        color: "transparent"
        exclusiveZone: implicitHeight
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

        implicitHeight: Config.padding
        color: "transparent"
        exclusiveZone: implicitHeight
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

        implicitWidth: Config.padding
        color: "transparent"
        exclusiveZone: implicitWidth
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

        implicitWidth: Config.padding
        color: "transparent"
        exclusiveZone: implicitWidth
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Top
    }
}
