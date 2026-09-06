pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property list<PwNode> streams: []
    property bool notificationsReady: false
    property var previousSink: null

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool available: !!sink?.audio
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0

    onSinkChanged: {
        if (!root.notificationsReady) {
            root.previousSink = root.sink
            return
        }

        if (root.previousSink === root.sink)
            return

        if (root.sink === null) {
            Notifier.send(
                "Audio output unavailable",
                root.nodeName(root.previousSink),
                "normal"
            )
        } else if (root.previousSink !== null) {
            Notifier.send(
                "Audio output changed",
                root.nodeName(root.sink),
                "low"
            )
        }

        root.previousSink = root.sink
    }

    function nodeName(node): string {
        return node?.description
            || node?.nickname
            || node?.name
            || "Default output"
    }

    function streamName(node): string {
        const properties = node?.properties ?? {}

        return properties["application.name"]
            || properties["media.name"]
            || node?.description
            || node?.nickname
            || node?.name
            || "Audio"
    }

    function setStreamVolume(node, volume): void {
        if (node?.ready && node.audio !== null)
            node.audio.volume = Math.max(0, Math.min(1, volume))
    }

    function refreshStreams(): void {
        const streams = []

        for (const node of Pipewire.nodes.values) {
            if (node.isStream && node.isSink && node.audio !== null)
                streams.push(node)
        }

        root.streams = streams
    }

    Component.onCompleted: {
        root.refreshStreams()
        notificationInitialization.start()
    }

    Timer {
        id: notificationInitialization

        interval: 2000
        repeat: false
        onTriggered: {
            root.previousSink = root.sink
            root.notificationsReady = true
        }
    }

    Connections {
        target: Pipewire.nodes

        function onValuesChanged(): void {
            root.refreshStreams()
        }
    }

    PwObjectTracker {
        objects: [root.sink, ...root.streams].filter(node => node)
    }
}
