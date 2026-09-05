import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
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
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "qs-statusbar"
        mask: Region {
            x: components.x
            y: components.y
            width: components.width
            height: components.height
        }

        Shape {
            anchors.fill: parent

            ShapePath {
                fillColor: Theme[Config.statusbar.color]
                strokeColor: Theme[Config.statusbar.border.color]
                strokeWidth: Config.statusbar.border.width
                fillRule: ShapePath.OddEvenFill

                startX: -Config.statusbar.border.width
                startY: -Config.statusbar.border.width

                PathLine {
                    x: frame.width + Config.statusbar.border.width
                    y: -Config.statusbar.border.width
                }
                PathLine {
                    x: frame.width + Config.statusbar.border.width
                    y: frame.height + Config.statusbar.border.width
                }
                PathLine {
                    x: -Config.statusbar.border.width
                    y: frame.height + Config.statusbar.border.width
                }
                PathLine {
                    x: -Config.statusbar.border.width
                    y: -Config.statusbar.border.width
                }

                PathMove {
                    x: Config.statusbar.padding
                    y: Config.statusbar.padding
                }

                PathLine {
                    x: frame.width - Config.statusbar.padding
                    y: Config.statusbar.padding
                }
                PathLine {
                    x: frame.width - Config.statusbar.padding
                    y: frame.height
                        - Config.statusbar.padding * 2
                        - Config.statusbar.height
                }
                PathLine {
                    x: Config.statusbar.padding
                    y: frame.height
                        - Config.statusbar.padding * 2
                        - Config.statusbar.height
                }
                PathLine {
                    x: Config.statusbar.padding
                    y: Config.statusbar.padding
                }
            }
        }

        RowLayout {
            id: components

            x: Config.statusbar.padding
            y: frame.height
                - Config.statusbar.padding
                - Config.statusbar.height
            width: frame.width - Config.statusbar.padding * 2
            height: Config.statusbar.height
            spacing: Config.statusbar.padding

            ComponentNetwork {
                Layout.fillHeight: true
            }

            ComponentBacklight {
                Layout.fillHeight: true
            }

            Item {
                Layout.fillWidth: true
            }

            ComponentTime {
                Layout.fillHeight: true
            }

            ComponentDate {
                Layout.fillHeight: true
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

        implicitHeight: Config.statusbar.padding
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

        implicitHeight:
            Config.statusbar.padding * 2
            + Config.statusbar.height
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

        implicitWidth: Config.statusbar.padding
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

        implicitWidth: Config.statusbar.padding
        color: "transparent"
        exclusiveZone: implicitWidth
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Top
    }
}
