import QtQuick
import "../../global"

Row {
    id: root

    height: Config.statusbar.height
    spacing: 0

    Rectangle {
        implicitWidth: tagText.implicitWidth + 12
        height: root.height
        color: Theme[Config.statusbar.component.tagColor]

        Text {
            id: tagText

            anchors.centerIn: parent
            text: "LGT"
            color: Theme.base00
            font.family: "monospace"
            font.bold: true
            font.pixelSize: 12
        }
    }

    Rectangle {
        implicitWidth: contentText.implicitWidth + 12
        height: root.height
        color: Theme[Config.statusbar.component.contentColor]

        Text {
            id: contentText

            anchors.centerIn: parent
            text: Backlight.available ? Backlight.percentage + "%" : "--"
            color: Theme.base05
            font.family: "monospace"
            font.bold: true
            font.pixelSize: 12
        }
    }
}
