pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    signal received(var notification)

    property var unread: []

    function refresh(): void {
        const tracked = [...server.trackedNotifications.values]
        const current = root.unread.filter(
            notification => tracked.includes(notification))
        const added = tracked.filter(
            notification => !current.includes(notification))

        root.unread = [...added.reverse(), ...current]
    }

    function dismiss(notification): void {
        if (notification?.tracked)
            notification.dismiss()
    }

    NotificationServer {
        id: server

        actionsSupported: true
        bodySupported: true
        imageSupported: true
        inlineReplySupported: true
        persistenceSupported: true
        keepOnReload: true

        onNotification: notification => {
            notification.tracked = true
            root.refresh()
            root.received(notification)
        }
    }

    Connections {
        target: server.trackedNotifications

        function onValuesChanged(): void {
            root.refresh()
        }
    }
}
