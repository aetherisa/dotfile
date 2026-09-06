pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking

Singleton {
    id: root

    property int discoveryAttempts: 0

    readonly property var wifiDevice:
        Networking.devices.values.find(
            device => device.type === DeviceType.Wifi) ?? null
    readonly property var bluetoothAdapter: Bluetooth.defaultAdapter
    readonly property var connectedDevice:
        Networking.devices.values.find(
            device => device.connected && device.type === DeviceType.Wifi)
        ?? Networking.devices.values.find(device => device.connected)
        ?? null
    readonly property var connectedWifi:
        root.wifiDevice?.networks.values.find(network => network.connected)
        ?? null
    readonly property var wifiNetworks: root.sortedWifiNetworks()
    readonly property var bluetoothDevices: root.sortedBluetoothDevices()

    readonly property bool wifiAvailable: root.wifiDevice !== null
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool bluetoothAvailable: root.bluetoothAdapter !== null
    readonly property bool bluetoothEnabled:
        root.bluetoothAdapter?.enabled ?? false

    function sortedWifiNetworks(): var {
        if (root.wifiDevice === null)
            return []

        const networks = []
        for (const network of root.wifiDevice.networks.values) {
            const index = networks.findIndex(
                candidate => candidate.name === network.name)
            const previous = index < 0 ? null : networks[index]
            if (previous === null
                    || network.connected
                    || network.signalStrength > previous.signalStrength) {
                if (index < 0)
                    networks.push(network)
                else
                    networks[index] = network
            }
        }

        return networks.sort((left, right) => {
            if (left.connected !== right.connected)
                return left.connected ? -1 : 1
            if (left.known !== right.known)
                return left.known ? -1 : 1
            return right.signalStrength - left.signalStrength
        })
    }

    function setWifiEnabled(enabled): void {
        if (Networking.wifiHardwareEnabled)
            Networking.wifiEnabled = enabled
    }

    function setBluetoothEnabled(enabled): void {
        if (root.bluetoothAdapter !== null)
            root.bluetoothAdapter.enabled = enabled
    }

    function scheduleBluetoothDiscovery(): void {
        if (!root.bluetoothAdapter?.enabled
                || root.bluetoothAdapter.discovering) {
            discoveryTimer.stop()
            return
        }

        root.discoveryAttempts = 0
        discoveryTimer.restart()
    }

    function sortedBluetoothDevices(): var {
        if (root.bluetoothAdapter === null)
            return []

        return [...root.bluetoothAdapter.devices.values].sort((left, right) => {
            if (left.connected !== right.connected)
                return left.connected ? -1 : 1
            if (left.paired !== right.paired)
                return left.paired ? -1 : 1
            return left.name.localeCompare(right.name)
        })
    }

    function connect(network, password = ""): void {
        if (network === null)
            return

        if (network.known || network.security === WifiSecurityType.Open) {
            network.connect()
            return
        }

        if (root.acceptsPsk(network) && password.length > 0)
            network.connectWithPsk(password)
    }

    function acceptsPsk(network): bool {
        return network !== null && (
            network.security === WifiSecurityType.WpaPsk
            || network.security === WifiSecurityType.Wpa2Psk
            || network.security === WifiSecurityType.Sae
        )
    }

    function disconnect(network): void {
        if (network !== null)
            network.disconnect()
    }

    function forget(network): void {
        if (network !== null)
            network.forget()
    }

    function pairBluetooth(device): void {
        if (device !== null && !device.paired && !device.pairing)
            device.pair()
    }

    function connectBluetooth(device): void {
        if (device !== null && device.paired && !device.connected)
            device.connect()
    }

    function disconnectBluetooth(device): void {
        if (device !== null && device.connected)
            device.disconnect()
    }

    function forgetBluetooth(device): void {
        if (device !== null)
            device.forget()
    }

    Binding {
        target: root.wifiDevice
        property: "scannerEnabled"
        value: true
        when: root.wifiDevice !== null
    }

    Timer {
        id: discoveryTimer

        interval: 300
        repeat: true

        onTriggered: {
            if (!root.bluetoothAdapter?.enabled
                    || root.bluetoothAdapter.discovering
                    || root.discoveryAttempts >= 10) {
                stop()
                return
            }

            root.discoveryAttempts++
            root.bluetoothAdapter.discovering = true
        }
    }

    onBluetoothAdapterChanged: {
        discoveryTimer.stop()
        root.scheduleBluetoothDiscovery()
    }

    Component.onCompleted: root.scheduleBluetoothDiscovery()

    Connections {
        target: root.bluetoothAdapter

        function onEnabledChanged(): void {
            root.scheduleBluetoothDiscovery()
        }

        function onDiscoveringChanged(): void {
            if (root.bluetoothAdapter?.discovering) {
                discoveryTimer.stop()
                root.discoveryAttempts = 0
            } else {
                root.scheduleBluetoothDiscovery()
            }
        }
    }
}
