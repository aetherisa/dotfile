pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    property list<PwNode> streams: []

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool available: !!sink?.audio
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0

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

    Component.onCompleted: root.refreshStreams()

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
