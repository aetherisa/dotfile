import QtQuick
import Quickshell.Hyprland

Item {
    id: root

    readonly property var activeWorkspace: Hyprland.focusedWorkspace
    readonly property int activeWorkspaceId:
        activeWorkspace?.id >= 1 && activeWorkspace?.id <= 10
        ? activeWorkspace.id
        : 1
    readonly property int activeIndex: 10 + activeWorkspaceId - 1

    implicitWidth: 32
    implicitHeight: 112

    function roman(number): string {
        return [
            "I", "II", "III", "IV", "V",
            "VI", "VII", "VIII", "IX", "X"
        ][number - 1]
    }

    Rectangle {
        id: recess

        anchors.fill: parent
        radius: 8
        color: Theme.base01

        Rectangle {
            id: paper

            anchors {
                fill: parent
                margins: 4
            }

            radius: 5
            color: Theme.base05
            clip: true

            Column {
                id: workspaceStrip

                width: paper.width
                y: -root.activeIndex * paper.height

                Behavior on y {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }

                Repeater {
                    model: 30

                    Item {
                        required property int index

                        readonly property int workspaceId: index % 10 + 1
                        readonly property bool active:
                            index === root.activeIndex

                        width: workspaceStrip.width
                        height: paper.height

                        Rectangle {
                            anchors {
                                fill: parent
                                margins: 3
                            }

                            radius: 3
                            color: Theme.base0B

                            Text {
                                id: label

                                anchors.centerIn: parent
                                text: root.roman(parent.parent.workspaceId)
                                color: Theme.base00
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                }
            }
        }
    }
}
