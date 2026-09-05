import QtQuick
import Quickshell
import Quickshell.Networking
import "../../global"

Row {
    id: root

    readonly property var wifiDevice:
        Networking.devices.values.find(
            device => device.type === DeviceType.Wifi) ?? null
    readonly property var connectedDevice:
        Networking.devices.values.find(
            device => device.connected && device.type === DeviceType.Wifi)
        ?? Networking.devices.values.find(device => device.connected)
        ?? null
    readonly property var connectedNetwork:
        connectedDevice?.type === DeviceType.Wifi
        ? connectedDevice.networks.values.find(network => network.connected) ?? null
        : null
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

    height: Config.statusbar.height
    spacing: 0

    Binding {
        target: root.wifiDevice
        property: "scannerEnabled"
        value: true
        when: root.wifiDevice !== null
    }

    Rectangle {
        implicitWidth: tagText.implicitWidth + 12
        height: root.height
        color: Theme[Config.statusbar.component.tagColor]

        Text {
            id: tagText

            anchors.centerIn: parent
            text: root.tag
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
            text: root.content
            color: Theme.base05
            font.family: "monospace"
            font.bold: true
            font.pixelSize: 12
        }
    }
}
