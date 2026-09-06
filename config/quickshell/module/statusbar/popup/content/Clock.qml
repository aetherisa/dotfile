import QtQuick
import Quickshell
import qs.global

Item {
    id: root

    readonly property date currentTime: systemClock.date

    implicitHeight: Config.unit * 61 / 8
    implicitWidth: implicitHeight

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    Rectangle {
        anchors.fill: parent
        color: Theme[Config.colors.surface]
    }

    Rectangle {
        id: face

        anchors.fill: parent
        anchors.margins: Config.padding
        radius: width / 2
        color: Theme[Config.colors.surface]
        border.width: Config.borderWidth
        border.color: Theme[Config.colors.border]

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
                        topMargin: Config.padding
                    }
                    width: index % 5 === 0 ? 2 : 1
                    height: index % 5 === 0 ? 8 : 4
                    radius: width / 2
                    color: index % 5 === 0 ? Theme[Config.colors.foreground] : Theme[Config.colors.muted]
                }
            }
        }

        Rectangle {
            width: 4
            height: face.height * 0.23
            radius: width / 2
            color: Theme[Config.colors.foreground]
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
            color: Theme[Config.colors.foreground]
            x: (face.width - width) / 2
            y: face.height / 2 - height
            transformOrigin: Item.Bottom
            rotation: root.currentTime.getMinutes() * 6
                + root.currentTime.getSeconds() * 0.1
        }

        Rectangle {
            width: 1
            height: face.height * 0.39
            color: Theme[Config.colors.accent]
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
            color: Theme[Config.colors.accent]
        }
    }
}
