import QtQuick
import qs.global
import qs.module.statusbar.popup
import qs.module.statusbar.popup.content as Popup

Item {
    id: root

    required property PopupManager popupManager

    property date currentDate: new Date()

    implicitWidth: contentRow.implicitWidth
    implicitHeight: Config.statusbar.height

    Row {
        id: contentRow

        anchors.fill: parent
        spacing: 0

        Rectangle {
            implicitWidth: tagText.implicitWidth + 12
            height: root.height
            color: Theme[Config.statusbar.component.tagColor]

            Text {
                id: tagText

                anchors.centerIn: parent
                text: "DAT"
                color: Theme.base00
                font.family: "monospace"
                font.bold: true
                font.pixelSize: Config.statusbar.fontSize
            }
        }

        Rectangle {
            implicitWidth: contentText.implicitWidth + 12
            height: root.height
            color: Theme[Config.statusbar.component.contentColor]

            Text {
                id: contentText

                anchors.centerIn: parent
                text: Qt.formatDateTime(root.currentDate, "MM-dd")
                color: Theme.base05
                font.bold: true
                font.family: "monospace"
                font.pixelSize: Config.statusbar.fontSize
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentDate = new Date()
    }

    Component {
        id: popupContent

        Popup.Calendar {}
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
