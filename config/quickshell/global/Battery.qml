pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

    property bool notificationsReady: false
    property bool lowBatteryNotified: false
    property bool criticalBatteryNotified: false
    property var previousState: UPowerDeviceState.Unknown
    property var previousProfile: PowerProfiles.profile

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool available:
        device.ready && device.isLaptopBattery && device.isPresent
    readonly property int percentage:
        available ? Math.round(device.percentage * 100) : -1
    readonly property var profiles: PowerProfiles.hasPerformanceProfile
        ? [
            PowerProfile.PowerSaver,
            PowerProfile.Balanced,
            PowerProfile.Performance
        ]
        : [
            PowerProfile.PowerSaver,
            PowerProfile.Balanced
        ]
    readonly property var activeProfile: PowerProfiles.profile

    readonly property bool discharging:
        device.state === UPowerDeviceState.Discharging
        || device.state === UPowerDeviceState.PendingDischarge

    onPercentageChanged: root.checkBatteryLevel()

    onActiveProfileChanged: {
        if (!root.notificationsReady) {
            root.previousProfile = root.activeProfile
            return
        }

        if (root.previousProfile === root.activeProfile)
            return

        Notifier.send(
            "Power profile changed",
            root.profileName(root.activeProfile),
            "low"
        )
        root.previousProfile = root.activeProfile
    }

    function profileTag(profile): string {
        if (profile === PowerProfile.PowerSaver)
            return "SAV"
        if (profile === PowerProfile.Performance)
            return "PER"
        return "BAL"
    }

    function profileName(profile): string {
        if (profile === PowerProfile.PowerSaver)
            return "Power saver"
        if (profile === PowerProfile.Performance)
            return "Performance"
        return "Balanced"
    }

    function checkBatteryLevel(): void {
        if (!root.notificationsReady || !root.available)
            return

        if (root.percentage > 12) {
            root.lowBatteryNotified = false
            root.criticalBatteryNotified = false
            return
        }

        if (!root.discharging)
            return

        if (root.percentage <= 5 && !root.criticalBatteryNotified) {
            Notifier.send(
                "Battery critically low",
                root.percentage + "% remaining",
                "critical",
                0
            )
            root.criticalBatteryNotified = true
            root.lowBatteryNotified = true
        } else if (root.percentage <= 10 && !root.lowBatteryNotified) {
            Notifier.send(
                "Battery low",
                root.percentage + "% remaining",
                "critical",
                0
            )
            root.lowBatteryNotified = true
        }
    }

    function activateProfile(profile): void {
        PowerProfiles.profile = profile
    }

    Timer {
        id: notificationInitialization

        interval: 2000
        running: true
        repeat: false
        onTriggered: {
            root.previousState = root.device.state
            root.previousProfile = root.activeProfile
            root.notificationsReady = true
            root.checkBatteryLevel()
        }
    }

    Connections {
        target: root.device

        function onStateChanged(): void {
            const state = root.device.state
            if (!root.notificationsReady) {
                root.previousState = state
                return
            }

            if (state === root.previousState)
                return

            if (state === UPowerDeviceState.Charging
                    || state === UPowerDeviceState.PendingCharge) {
                Notifier.send(
                    "Battery charging",
                    root.percentage + "% charged",
                    "low"
                )
            } else if (state === UPowerDeviceState.Discharging
                    || state === UPowerDeviceState.PendingDischarge) {
                Notifier.send(
                    "Battery discharging",
                    root.percentage + "% remaining",
                    root.percentage <= 10 ? "normal" : "low"
                )
            } else if (state === UPowerDeviceState.FullyCharged) {
                Notifier.send(
                    "Battery fully charged",
                    "The charger can be disconnected",
                    "low"
                )
            }

            root.previousState = state
            root.checkBatteryLevel()
        }
    }
}
