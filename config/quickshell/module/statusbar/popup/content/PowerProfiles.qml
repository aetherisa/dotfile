import QtQuick
import qs.global as Global

Item {
    id: root

    readonly property int unit: Global.Config.statusbar.popup.unit
    readonly property int buttonWidth: unit * 2
    readonly property int profileCount: Global.Battery.profiles.length

    implicitWidth: buttonWidth * profileCount
        + Global.Config.statusbar.padding * Math.max(0, profileCount - 1)
    implicitHeight: unit

    Rectangle {
        anchors.fill: parent
        color: Global.Theme.base01
    }

    Row {
        id: profileRow

        height: parent.height
        spacing: Global.Config.statusbar.padding

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
                    ? Global.Theme.base05
                    : profileMouse.containsMouse
                        ? Global.Theme.base06
                        : Global.Theme.base02

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    id: profileTag

                    anchors.centerIn: parent
                    text: Global.Battery.profileTag(profileButton.modelData)
                    color: profileButton.active
                        || profileMouse.containsMouse
                        ? Global.Theme.base00
                        : Global.Theme.base05
                    font.family: "monospace"
                    font.bold: true
                    font.pixelSize: Global.Config.statusbar.fontSize
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
