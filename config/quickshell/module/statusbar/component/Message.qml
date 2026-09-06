import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.global as Global
import qs.module.statusbar.popup.content as Popup

Item {
    id: root

    required property ShellScreen screen

    readonly property color defaultTagColor: Global.Theme[
        Global.Config.statusbar.component.tagColor
    ]
    property color displayedTagColor: defaultTagColor
    property color attentionColor: Global.Theme.base0A

    onDefaultTagColorChanged: {
        if (!attentionAnimation.running)
            root.displayedTagColor = root.defaultTagColor
    }

    implicitWidth: contentRow.implicitWidth
    implicitHeight: Global.Config.statusbar.height

    function urgencyColor(urgency): color {
        if (urgency === NotificationUrgency.Critical)
            return Global.Theme.base08
        if (urgency === NotificationUrgency.Low)
            return Global.Theme.base0B
        return Global.Theme.base0A
    }

    Connections {
        target: Global.Notifications

        function onReceived(notification): void {
            attentionAnimation.stop()
            root.displayedTagColor = root.defaultTagColor
            root.attentionColor = root.urgencyColor(notification.urgency)
            attentionAnimation.start()
        }
    }

    SequentialAnimation {
        id: attentionAnimation

        loops: 3

        PropertyAction {
            target: root
            property: "displayedTagColor"
            value: root.attentionColor
        }

        PauseAnimation { duration: 180 }

        PropertyAction {
            target: root
            property: "displayedTagColor"
            value: root.defaultTagColor
        }

        PauseAnimation { duration: 180 }
    }

    Row {
        id: contentRow

        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: tagBackground

            implicitWidth: tagText.implicitWidth + 12
            height: root.height
            color: root.displayedTagColor

            Text {
                id: tagText

                anchors.centerIn: parent
                text: "MSG"
                color: Global.Theme.base00
                font.family: "monospace"
                font.bold: true
                font.pixelSize: Global.Config.statusbar.fontSize
            }
        }

        Rectangle {
            implicitWidth: contentText.implicitWidth + 12
            height: root.height
            color: Global.Theme[
                Global.Config.statusbar.component.contentColor
            ]

            Text {
                id: contentText

                anchors.centerIn: parent
                text: String(Global.Notifications.unread.length)
                    .padStart(2, "0")
                color: Global.Theme.base05
                font.family: "monospace"
                font.bold: true
                font.pixelSize: Global.Config.statusbar.fontSize
            }
        }
    }

    Popup.MessageCenter {
        id: messageCenter

        screen: root.screen
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: messageCenter.open()
    }
}
