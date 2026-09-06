import QtQuick
import Quickshell
import Quickshell.Networking
import qs.global as Global

Item {
    id: root

    readonly property int unit: Global.Config.statusbar.popup.unit
    property bool wifiSelected: true
    property var expandedNetwork: null

    implicitWidth: unit * 10
    implicitHeight: unit * 8

    Rectangle {
        anchors.fill: parent
        color: Global.Theme.base01
    }

    Row {
        id: header

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: root.unit

        Rectangle {
            width: root.wifiSelected ? root.unit * 2.5 : root.unit * 1.5
            height: parent.height
            color: root.wifiSelected
                ? Global.Theme.base05
                : Global.Theme.base02

            Behavior on width {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }

            Text {
                anchors.centerIn: parent
                text: "WIFI"
                color: root.wifiSelected ? Global.Theme.base00 : Global.Theme.base05
                font.family: "monospace"
                font.bold: true
                font.pixelSize: Global.Config.statusbar.fontSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.wifiSelected = true
            }
        }

        Rectangle {
            width: root.wifiSelected ? root.unit * 1.5 : root.unit * 2.5
            height: parent.height
            color: root.wifiSelected
                ? Global.Theme.base02
                : Global.Theme.base05

            Behavior on width {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }

            Text {
                anchors.centerIn: parent
                text: "BT"
                color: root.wifiSelected ? Global.Theme.base05 : Global.Theme.base00
                font.family: "monospace"
                font.bold: true
                font.pixelSize: Global.Config.statusbar.fontSize
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.wifiSelected = false
            }
        }

        Item { width: Math.max(0, header.width - root.unit * 8); height: 1 }

        Row {
            id: powerControl

            readonly property bool available: root.wifiSelected
                ? Global.Network.wifiAvailable
                : Global.Network.bluetoothAvailable
            readonly property bool enabledState: root.wifiSelected
                ? Global.Network.wifiEnabled
                : Global.Network.bluetoothEnabled

            width: root.unit * 4
            height: parent.height
            opacity: available ? 1 : 0.5

            Repeater {
                model: [true, false]

                Rectangle {
                    required property bool modelData
                    readonly property bool selected:
                        modelData === powerControl.enabledState

                    width: selected ? root.unit * 2.5 : root.unit * 1.5
                    height: powerControl.height
                    color: selected
                        ? modelData
                            ? Global.Theme.base0B
                            : Global.Theme.base08
                        : Global.Theme.base02

                    Behavior on width {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: parent.modelData ? "ON" : "OFF"
                        color: parent.selected
                            ? Global.Theme.base00
                            : Global.Theme.base05
                        font.family: "monospace"
                        font.bold: true
                        font.pixelSize: Global.Config.statusbar.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: powerControl.available
                        cursorShape: enabled
                            ? Qt.PointingHandCursor
                            : Qt.ArrowCursor
                        onClicked: {
                            if (root.wifiSelected) {
                                Global.Network.setWifiEnabled(parent.modelData)
                            } else {
                                Global.Network.setBluetoothEnabled(
                                    parent.modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        anchors {
            left: parent.left
            right: parent.right
            top: header.bottom
            bottom: parent.bottom
        }

        Text {
            anchors.centerIn: parent
            visible: !root.wifiSelected && (!Global.Network.bluetoothEnabled
                || Global.Network.bluetoothDevices.length === 0)
            text: Global.Network.bluetoothEnabled
                ? "No Bluetooth devices found"
                : "Bluetooth is off"
            color: Global.Theme.base03
            font.family: "monospace"
            font.bold: true
            font.pixelSize: Global.Config.statusbar.fontSize
        }

        Text {
            anchors.centerIn: parent
            visible: root.wifiSelected && (!Global.Network.wifiEnabled
                || Global.Network.wifiNetworks.length === 0)
            text: Global.Network.wifiEnabled ? "No networks found" : "Wi-Fi is off"
            color: Global.Theme.base03
            font.family: "monospace"
            font.bold: true
            font.pixelSize: Global.Config.statusbar.fontSize
        }

        ListView {
            id: networkList

            anchors.fill: parent
            visible: root.wifiSelected
                && Global.Network.wifiEnabled
                && Global.Network.wifiNetworks.length > 0
            clip: true
            model: ScriptModel {
                values: Global.Network.wifiNetworks
                objectProp: "name"
            }

            delegate: Item {
                id: networkRow

                required property var modelData
                readonly property bool expanded:
                    root.expandedNetwork === modelData
                readonly property bool passwordRequired:
                    !modelData.known
                    && modelData.security !== WifiSecurityType.Open
                readonly property bool supported:
                    !passwordRequired || Global.Network.acceptsPsk(modelData)

                width: networkList.width
                height: root.unit + passwordPanel.height

                Rectangle {
                    anchors.fill: parent
                    color: networkMouse.containsMouse
                        ? Global.Theme.base02
                        : "transparent"
                }

                Text {
                    id: networkName

                    anchors {
                        left: parent.left
                        leftMargin: Global.Config.statusbar.padding
                        verticalCenter: actionRow.verticalCenter
                    }
                    width: root.unit * 4
                    text: networkRow.modelData.name || "Hidden network"
                    elide: Text.ElideRight
                    color: networkRow.modelData.connected
                        ? Global.Theme[Global.Config.statusbar.popup.color]
                        : Global.Theme.base05
                    font.family: "monospace"
                    font.bold: true
                    font.pixelSize: Global.Config.statusbar.fontSize
                }

                Text {
                    anchors {
                        right: actionRow.left
                        rightMargin: Global.Config.statusbar.padding
                        verticalCenter: actionRow.verticalCenter
                    }
                    text: Math.round(networkRow.modelData.signalStrength * 100) + "%"
                    color: Global.Theme.base04
                    font.family: "monospace"
                    font.bold: true
                    font.pixelSize: Global.Config.statusbar.fontSize
                }

                Row {
                    id: actionRow

                    anchors {
                        right: parent.right
                        rightMargin: Global.Config.statusbar.padding
                        top: parent.top
                    }
                    height: root.unit
                    spacing: 4

                    Repeater {
                        model: networkRow.modelData.connected
                            ? ["DSC", "FGT"]
                            : networkRow.modelData.known
                                ? ["CON", "FGT"]
                                : ["CON"]

                        Rectangle {
                            id: actionButton

                            required property string modelData

                            width: root.unit * 1.25
                            height: Global.Config.statusbar.height
                            anchors.verticalCenter: parent.verticalCenter
                            color: actionMouse.containsMouse
                                ? Global.Theme.base06
                                : Global.Theme.base05

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: parent.modelData
                                color: Global.Theme.base00
                                font.family: "monospace"
                                font.bold: true
                                font.pixelSize: Global.Config.statusbar.fontSize
                            }

                            MouseArea {
                                id: actionMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const action = parent.modelData
                                    if (action === "FGT") {
                                        Global.Network.forget(networkRow.modelData)
                                    } else if (action === "DSC") {
                                        Global.Network.disconnect(networkRow.modelData)
                                    } else if (!networkRow.supported) {
                                        root.expandedNetwork = networkRow.modelData
                                    } else if (networkRow.passwordRequired) {
                                        root.expandedNetwork = networkRow.expanded
                                            ? null : networkRow.modelData
                                    } else {
                                        Global.Network.connect(networkRow.modelData)
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: networkMouse

                    anchors {
                        left: parent.left
                        right: actionRow.left
                        top: parent.top
                    }
                    height: root.unit
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }

                Rectangle {
                    id: passwordPanel

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        topMargin: root.unit
                    }
                    height: networkRow.expanded ? root.unit : 0
                    visible: networkRow.expanded || height > 0
                    opacity: networkRow.expanded ? 1 : 0
                    clip: true
                    color: Global.Theme.base00

                    Behavior on height {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation { duration: 140 }
                    }

                    TextInput {
                        id: passwordInput

                        anchors {
                            left: parent.left
                            right: submitButton.left
                            leftMargin: Global.Config.statusbar.padding
                            rightMargin: Global.Config.statusbar.padding
                            verticalCenter: parent.verticalCenter
                        }
                        visible: networkRow.supported
                        focus: visible && networkRow.expanded
                        echoMode: TextInput.Password
                        passwordCharacter: "•"
                        color: Global.Theme.base05
                        selectionColor:
                            Global.Theme[Global.Config.statusbar.popup.color]
                        selectedTextColor: Global.Theme.base00
                        font.family: "monospace"
                        font.bold: true
                        font.pixelSize: Global.Config.statusbar.fontSize
                        Keys.onReturnPressed: submitButton.submit()

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: passwordInput.text.length === 0
                            text: "Password"
                            color: Global.Theme.base03
                            font: passwordInput.font
                        }
                    }

                    Text {
                        anchors {
                            left: parent.left
                            leftMargin: Global.Config.statusbar.padding
                            verticalCenter: parent.verticalCenter
                        }
                        visible: !networkRow.supported
                        text: "Unsupported security type"
                        color: Global.Theme.base08
                        font.family: "monospace"
                        font.bold: true
                        font.pixelSize: Global.Config.statusbar.fontSize
                    }

                    Rectangle {
                        id: submitButton

                        function submit(): void {
                            if (!networkRow.supported || passwordInput.text.length === 0)
                                return
                            Global.Network.connect(
                                networkRow.modelData,
                                passwordInput.text)
                            passwordInput.text = ""
                            root.expandedNetwork = null
                        }

                        anchors {
                            right: parent.right
                            rightMargin: Global.Config.statusbar.padding
                            verticalCenter: parent.verticalCenter
                        }
                        width: root.unit * 1.25
                        height: Global.Config.statusbar.height
                        visible: networkRow.supported
                        color: Global.Theme[Global.Config.statusbar.popup.color]

                        Text {
                            anchors.centerIn: parent
                            text: "SUB"
                            color: Global.Theme.base00
                            font.family: "monospace"
                            font.bold: true
                            font.pixelSize: Global.Config.statusbar.fontSize
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: submitButton.submit()
                        }
                    }
                }
            }
        }

        ListView {
            id: bluetoothList

            anchors.fill: parent
            visible: !root.wifiSelected
                && Global.Network.bluetoothEnabled
                && Global.Network.bluetoothDevices.length > 0
            clip: true
            model: ScriptModel {
                values: Global.Network.bluetoothDevices
                objectProp: "dbusPath"
            }

            delegate: Item {
                id: bluetoothRow

                required property var modelData

                width: bluetoothList.width
                height: root.unit

                Rectangle {
                    anchors.fill: parent
                    color: bluetoothMouse.containsMouse
                        ? Global.Theme.base02
                        : "transparent"
                }

                Text {
                    anchors {
                        left: parent.left
                        leftMargin: Global.Config.statusbar.padding
                        right: bluetoothActions.left
                        rightMargin: Global.Config.statusbar.padding
                        verticalCenter: parent.verticalCenter
                    }
                    text: bluetoothRow.modelData.name || "Unknown device"
                    elide: Text.ElideRight
                    color: bluetoothRow.modelData.connected
                        ? Global.Theme[Global.Config.statusbar.popup.color]
                        : Global.Theme.base05
                    font.family: "monospace"
                    font.bold: true
                    font.pixelSize: Global.Config.statusbar.fontSize
                }

                Row {
                    id: bluetoothActions

                    anchors {
                        right: parent.right
                        rightMargin: Global.Config.statusbar.padding
                        verticalCenter: parent.verticalCenter
                    }
                    height: Global.Config.statusbar.height
                    spacing: 4

                    Repeater {
                        model: bluetoothRow.modelData.connected
                            ? ["DSC", "FGT"]
                            : bluetoothRow.modelData.paired
                                ? ["CON", "FGT"]
                                : ["PAR"]

                        Rectangle {
                            required property string modelData

                            width: root.unit * 1.25
                            height: bluetoothActions.height
                            color: bluetoothActionMouse.containsMouse
                                ? Global.Theme.base06
                                : Global.Theme.base05

                            Behavior on color {
                                ColorAnimation { duration: 120 }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: parent.modelData
                                color: Global.Theme.base00
                                font.family: "monospace"
                                font.bold: true
                                font.pixelSize: Global.Config.statusbar.fontSize
                            }

                            MouseArea {
                                id: bluetoothActionMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const action = parent.modelData
                                    if (action === "PAR") {
                                        Global.Network.pairBluetooth(
                                            bluetoothRow.modelData)
                                    } else if (action === "CON") {
                                        Global.Network.connectBluetooth(
                                            bluetoothRow.modelData)
                                    } else if (action === "DSC") {
                                        Global.Network.disconnectBluetooth(
                                            bluetoothRow.modelData)
                                    } else {
                                        Global.Network.forgetBluetooth(
                                            bluetoothRow.modelData)
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: bluetoothMouse

                    anchors {
                        left: parent.left
                        right: bluetoothActions.left
                        top: parent.top
                        bottom: parent.bottom
                    }
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }
            }
        }
    }
}
