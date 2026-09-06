import QtQuick
import Quickshell
import Quickshell.Networking
import qs.global as Global
import qs.module.statusbar.popup
import qs.module.statusbar.popup.content as Popup

Item {
    id: root

    required property PopupManager popupManager

    readonly property var connectedDevice: Global.Network.connectedDevice
    readonly property var connectedNetwork: Global.Network.connectedWifi
    readonly property string tag:
        connectedDevice?.type === DeviceType.Wifi
        ? "WFI"
        : connectedDevice?.type === DeviceType.Wired
            ? "ETH"
            : "NET"
    readonly property string content:
        connectedDevice === null
        ? "--"
        : connectedDevice.type === DeviceType.Wifi
            ? connectedNetwork === null
                ? "--"
                : Math.round(connectedNetwork.signalStrength * 100) + "%"
            : "100%"

    implicitWidth: contentRow.implicitWidth
    implicitHeight: Global.Config.statusbar.height

    Row {
        id: contentRow

        anchors.fill: parent
        spacing: 0

        Rectangle {
            implicitWidth: tagText.implicitWidth + 12
            height: root.height
            color: Global.Theme[Global.Config.colors.danger]

            Text {
                id: tagText

                anchors.centerIn: parent
                text: root.tag
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
                text: root.content
                color: Global.Theme[Global.Config.colors.foreground]
                font.family: "monospace"
                font.bold: true
                font.pixelSize: Global.Config.fontSize
            }
        }
    }

    Component {
        id: popupContent

        Popup.NetworkDashboard {}
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
