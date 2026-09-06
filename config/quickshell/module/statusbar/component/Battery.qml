import QtQuick
import qs.global as Global
import qs.module.statusbar.popup
import qs.module.statusbar.popup.content as Popup

Item {
    id: root

    required property PopupManager popupManager

    readonly property string content: Global.Battery.available
        ? Global.Battery.percentage + "%"
        : "--"

    implicitWidth: contentRow.implicitWidth
    implicitHeight: Global.Config.statusbar.height

    Row {
        id: contentRow

        anchors.fill: parent
        spacing: 0

        Rectangle {
            implicitWidth: tagText.implicitWidth + 12
            height: root.height
            color: Global.Theme[
                Global.Config.statusbar.component.tagColor
            ]

            Text {
                id: tagText

                anchors.centerIn: parent
                text: "BAT"
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
                text: root.content
                color: Global.Theme.base05
                font.family: "monospace"
                font.bold: true
                font.pixelSize: Global.Config.statusbar.fontSize
            }
        }
    }

    Component {
        id: popupContent

        Popup.PowerProfiles {}
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const pos = root.mapToItem(null, 0, 0)
            root.popupManager.open(
                pos.x,
                root.width,
                popupContent
            )
        }
    }
}
