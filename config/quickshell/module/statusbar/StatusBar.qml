import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.global
import qs.module.statusbar.component as Component
import qs.module.statusbar.popup

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
                    y: frame.height
                        - Config.padding * 2
                        - Config.statusbar.height
                }
                PathLine {
                    x: Config.padding
                    y: frame.height
                        - Config.padding * 2
                        - Config.statusbar.height
                }
                PathLine {
                    x: Config.padding
                    y: Config.padding
                }
            }
        }

        RowLayout {
            id: components

            x: Config.padding
            y: frame.height
                - Config.padding
                - Config.statusbar.height
            width: frame.width - Config.padding * 2
            height: Config.statusbar.height
            spacing: Config.padding

            Component.Network {
                Layout.fillHeight: true
                popupManager: statusbarPopupManager
            }

            Component.Sound {
                Layout.fillHeight: true
                popupManager: statusbarPopupManager
            }

            Component.Backlight {
                Layout.fillHeight: true
            }

            Component.Battery {
                Layout.fillHeight: true
                popupManager: statusbarPopupManager
            }

            Component.Media {
                Layout.fillHeight: true
                popupManager: statusbarPopupManager
            }

            Item {
                Layout.fillWidth: true
            }

            Component.Cpu {
                Layout.fillHeight: true
            }

            Component.Memory {
                Layout.fillHeight: true
            }

            Component.Temperature {
                Layout.fillHeight: true
            }

            Component.Time {
                Layout.fillHeight: true
                popupManager: statusbarPopupManager
            }

            Component.Day {
                Layout.fillHeight: true
                popupManager: statusbarPopupManager
            }

            Component.Message {
                Layout.fillHeight: true
                screen: root.screen
            }
        }
    }

    PopupManager {
        id: statusbarPopupManager

        screen: root.screen
        frameLeft: Config.padding
        frameRight: frame.width - Config.padding
        frameBottom: frame.height
            - Config.padding * 2
            - Config.statusbar.height
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

        implicitHeight:
            Config.padding * 2
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
