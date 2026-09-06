pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var queue: []

    function normalizeUrgency(urgency): string {
        if (urgency === "low" || urgency === "critical")
            return urgency
        return "normal"
    }

    function send(
        summary,
        body = "",
        urgency = "normal",
        timeout = 5000
    ): void {
        const notifications = [...root.queue]
        notifications.push({
            summary: String(summary),
            body: String(body),
            urgency: root.normalizeUrgency(urgency),
            timeout: Math.max(0, Math.round(Number(timeout)))
        })
        root.queue = notifications
        root.startNext()
    }

    function startNext(): void {
        if (sender.running || root.queue.length === 0)
            return

        const notifications = [...root.queue]
        const notification = notifications.shift()
        root.queue = notifications

        sender.command = [
            "notify-send",
            "--app-name", "Quickshell",
            "--urgency", notification.urgency,
            "--expire-time", String(notification.timeout),
            notification.summary,
            notification.body
        ]
        sender.running = true
    }

    Process {
        id: sender

        onExited: Qt.callLater(root.startNext)
    }
}
