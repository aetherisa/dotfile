import QtQuick
import qs.global as Global

Item {
    id: root

    readonly property int unit: Global.Config.unit
    readonly property int buttonWidth: unit * 2
    readonly property int profileCount: Global.Battery.profiles.length

    implicitWidth: buttonWidth * profileCount
        + Global.Config.padding * Math.max(0, profileCount - 1)
    implicitHeight: unit

    Rectangle {
        anchors.fill: parent
        color: Global.Theme[Global.Config.colors.surface]
    }

    Row {
        id: profileRow

        height: parent.height
        spacing: Global.Config.padding

        Repeater {
            model: Global.Battery.profiles

            Rectangle {
                id: profileButton

                required property var modelData
                readonly property bool active:
                    modelData === Global.Battery.activeProfile

                width: root.buttonWidth
                height: profileRow.height
                color: active
                    ? Global.Theme[Global.Config.colors.foreground]
                    : profileMouse.containsMouse
                        ? Global.Theme.base06
                        : Global.Theme[Global.Config.colors.surfaceAlt]

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    id: profileTag

                    anchors.centerIn: parent
                    text: Global.Battery.profileTag(profileButton.modelData)
                    color: profileButton.active
                        || profileMouse.containsMouse
                        ? Global.Theme[Global.Config.colors.background]
                        : Global.Theme[Global.Config.colors.foreground]
                    font.family: "monospace"
                    font.bold: true
                    font.pixelSize: Global.Config.fontSize
                }

                MouseArea {
                    id: profileMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                        Global.Battery.activateProfile(profileButton.modelData)
                }
            }
        }
    }
}
