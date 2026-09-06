import QtQuick
import qs.global as Global

Row {
    id: root

    height: Global.Config.statusbar.height
    spacing: 0

    Rectangle {
        implicitWidth: tagText.implicitWidth + 12
        height: root.height
        color: Global.Theme[Global.Config.colors.danger]

        Text {
            id: tagText

            anchors.centerIn: parent
            text: "TMP"
            color: Global.Theme[Global.Config.colors.background]
            font.family: "monospace"
            font.bold: true
            font.pixelSize: Global.Config.fontSize
        }
    }

    Rectangle {
        implicitWidth: contentText.implicitWidth + 12
        height: root.height
        color: Global.Theme[Global.Config.colors.surfaceAlt]

        Text {
            id: contentText

            anchors.centerIn: parent
            text: Global.SystemStats.temperature < 0
                ? "--"
                : Global.SystemStats.temperature + "°"
            color: Global.Theme[Global.Config.colors.foreground]
            font.family: "monospace"
            font.bold: true
            font.pixelSize: Global.Config.fontSize
        }
    }
}
