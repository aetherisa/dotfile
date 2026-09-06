import QtQuick
import qs.global
import qs.module.statusbar.popup
import qs.module.statusbar.popup.content as Popup

Item {
    id: root

    required property PopupManager popupManager

    readonly property string content: !Audio.available || Audio.muted
        ? "--"
        : Math.round(Audio.volume * 100) + "%"

    implicitWidth: contentRow.implicitWidth
    implicitHeight: Config.statusbar.height

    Row {
        id: contentRow

        anchors.fill: parent
        spacing: 0

        Rectangle {
            implicitWidth: tagText.implicitWidth + 12
            height: root.height
            color: Theme[Config.colors.danger]

            Text {
                id: tagText

                anchors.centerIn: parent
                text: "VOL"
                color: Theme[Config.colors.background]
                font.family: "monospace"
                font.bold: true
                font.pixelSize: Config.fontSize
            }
        }

        Rectangle {
            implicitWidth: contentText.implicitWidth + 12
            height: root.height
            color: Theme[Config.colors.surfaceAlt]

            Text {
                id: contentText

                anchors.centerIn: parent
                text: root.content
                color: Theme[Config.colors.foreground]
                font.family: "monospace"
                font.bold: true
                font.pixelSize: Config.fontSize
            }
        }
    }

    Component {
        id: popupContent

        Popup.Mixer {}
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
