import QtQuick
import Quickshell
import qs.global

Item {
    id: root

    readonly property date currentTime: systemClock.date

    implicitWidth: 150
    implicitHeight: 150

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.base01
    }

    Rectangle {
        id: face

        anchors.fill: parent
        anchors.margins: 8
        radius: width / 2
        color: Theme.base01
        border.width: Config.statusbar.border.width
        border.color: Theme[Config.statusbar.border.color]

        Repeater {
            model: 60

            Item {
                required property int index

                anchors.fill: parent
                rotation: index * 6

                Rectangle {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        topMargin: 8
                    }
                    width: index % 5 === 0 ? 2 : 1
                    height: index % 5 === 0 ? 8 : 4
                    radius: width / 2
                    color: index % 5 === 0 ? Theme.base05 : Theme.base03
                }
            }
        }

        Rectangle {
            width: 4
            height: face.height * 0.23
            radius: width / 2
            color: Theme.base05
            x: (face.width - width) / 2
            y: face.height / 2 - height
            transformOrigin: Item.Bottom
            rotation: (root.currentTime.getHours() % 12) * 30
                + root.currentTime.getMinutes() * 0.5
        }

        Rectangle {
            width: 3
            height: face.height * 0.34
            radius: width / 2
            color: Theme.base05
            x: (face.width - width) / 2
            y: face.height / 2 - height
            transformOrigin: Item.Bottom
            rotation: root.currentTime.getMinutes() * 6
                + root.currentTime.getSeconds() * 0.1
        }

        Rectangle {
            width: 1
            height: face.height * 0.39
            color: Theme.base0B
            x: (face.width - width) / 2
            y: face.height / 2 - height
            transformOrigin: Item.Bottom
            rotation: root.currentTime.getSeconds() * 6
        }

        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            color: Theme.base0B
        }
    }
}
