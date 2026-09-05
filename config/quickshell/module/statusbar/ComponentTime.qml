import QtQuick
import "../../global"

Row {
    id: root

    property date currentTime: new Date()

    height: Config.statusbar.height
    spacing: 0

    Rectangle {
        implicitWidth: tagText.implicitWidth + 12
        height: root.height
        color: Theme[Config.statusbar.component.tagColor]

        Text {
            id: tagText

            anchors.centerIn: parent
            text: "TIM"
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
            text: Qt.formatDateTime(root.currentTime, "HH:mm")
            color: Theme.base05
            font.bold: true
            font.family: "monospace"
            font.pixelSize: 12
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }
}
