import QtQuick
import qs.global as Global

Row {
    id: root

    height: Global.Config.statusbar.height
    spacing: 0

    Rectangle {
        implicitWidth: tagText.implicitWidth + 12
        height: root.height
        color: Global.Theme[Global.Config.statusbar.component.tagColor]

        Text {
            id: tagText

            anchors.centerIn: parent
            text: "CPU"
            color: Global.Theme.base00
            font.family: "monospace"
            font.bold: true
            font.pixelSize: Global.Config.statusbar.fontSize
        }
    }

    Rectangle {
        implicitWidth: contentText.implicitWidth + 12
        height: root.height
        color: Global.Theme[Global.Config.statusbar.component.contentColor]

        Text {
            id: contentText

            anchors.centerIn: parent
            text: Global.SystemStats.cpuPercentage < 0
                ? "--"
                : Global.SystemStats.cpuPercentage + "%"
            color: Global.Theme.base05
            font.family: "monospace"
            font.bold: true
            font.pixelSize: Global.Config.statusbar.fontSize
        }
    }
}
