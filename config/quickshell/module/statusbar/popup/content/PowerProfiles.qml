import QtQuick
import qs.global as Global

Item {
    id: root

    readonly property int buttonWidth: 52
    readonly property int profileCount: Global.Battery.profiles.length

    implicitWidth: buttonWidth * profileCount
        + Global.Config.statusbar.padding * Math.max(0, profileCount - 1)
    implicitHeight: Global.Config.statusbar.height * 2

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
                color: Global.Theme.base0B
                opacity: active || profileMouse.containsMouse ? 1 : 0.65

                Behavior on opacity {
                    NumberAnimation { duration: 120 }
                }

                Text {
                    id: profileTag

                    anchors.centerIn: parent
                    text: Global.Battery.profileTag(profileButton.modelData)
                    color: Global.Theme.base00
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
