pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
    id: root

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

    function profileTag(profile): string {
        if (profile === PowerProfile.PowerSaver)
            return "SAV"
        if (profile === PowerProfile.Performance)
            return "PER"
        return "BAL"
    }

    function activateProfile(profile): void {
        PowerProfiles.profile = profile
    }
}
