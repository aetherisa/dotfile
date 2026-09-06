pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int cpuPercentage: -1
    property int memoryPercentage: -1
    property int temperature: -1
    property real previousCpuTotal: -1
    property real previousCpuIdle: -1
    property string temperaturePath: ""

    function parseCpu(content): void {
        const line = content.split("\n")[0]?.trim()
        if (!line?.startsWith("cpu "))
            return

        const values = line.split(/\s+/).slice(1).map(Number)
        if (values.length < 5 || values.some(value => !Number.isFinite(value)))
            return

        const idle = values[3] + values[4]
        const total = values.reduce((sum, value) => sum + value, 0)

        if (root.previousCpuTotal >= 0) {
            const totalDelta = total - root.previousCpuTotal
            const idleDelta = idle - root.previousCpuIdle
            if (totalDelta > 0) {
                root.cpuPercentage = Math.round(
                    (1 - idleDelta / totalDelta) * 100)
            }
        }

        root.previousCpuTotal = total
        root.previousCpuIdle = idle
    }

    function parseMemory(content): void {
        const totalMatch = content.match(/^MemTotal:\s+(\d+)/m)
        const availableMatch = content.match(/^MemAvailable:\s+(\d+)/m)
        if (totalMatch === null || availableMatch === null)
            return

        const total = Number(totalMatch[1])
        const available = Number(availableMatch[1])
        if (total > 0)
            root.memoryPercentage = Math.round((1 - available / total) * 100)
    }

    function parseTemperature(content): void {
        const value = Number(content.trim())
        root.temperature = Number.isFinite(value)
            ? Math.round(value / 1000)
            : -1
    }

    FileView {
        id: cpuFile

        path: "/proc/stat"
        onLoaded: root.parseCpu(text())
    }

    FileView {
        id: memoryFile

        path: "/proc/meminfo"
        onLoaded: root.parseMemory(text())
    }

    FileView {
        id: temperatureFile

        path: root.temperaturePath
        printErrors: false
        onLoaded: root.parseTemperature(text())
        onLoadFailed: root.temperature = -1
    }

    Process {
        id: temperatureSensor

        command: [
            "sh", "-c",
            "for d in /sys/class/hwmon/hwmon*; do "
                + "read -r n < \"$d/name\" || continue; "
                + "case \"$n\" in k10temp|coretemp) "
                + "for f in \"$d\"/temp*_input; do "
                + "if [ -r \"$f\" ]; then printf '%s\\n' \"$f\"; exit; fi; "
                + "done;; esac; done; "
                + "for f in /sys/class/thermal/thermal_zone*/temp; do "
                + "if [ -r \"$f\" ]; then printf '%s\\n' \"$f\"; exit; fi; "
                + "done"
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished:
                root.temperaturePath = text.trim()
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true

        onTriggered: {
            cpuFile.reload()
            memoryFile.reload()
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true

        onTriggered: {
            if (root.temperaturePath !== "")
                temperatureFile.reload()
        }
    }
}
