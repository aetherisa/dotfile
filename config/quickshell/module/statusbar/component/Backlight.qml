import QtQuick
import qs.global

Row {
    id: root

    height: Config.statusbar.height
    spacing: 0

    Rectangle {
        implicitWidth: tagText.implicitWidth + 12
        height: root.height
        color: Theme[Config.colors.danger]

        Text {
            id: tagText

            anchors.centerIn: parent
            text: "LGT"
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
            text: Backlight.available ? Backlight.percentage + "%" : "--"
            color: Theme[Config.colors.foreground]
            font.family: "monospace"
            font.bold: true
            font.pixelSize: Config.fontSize
        }
    }
}
