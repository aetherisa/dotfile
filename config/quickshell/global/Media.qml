pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    property var preferredPlayer: null
    readonly property var players: [...Mpris.players.values]
    readonly property var activePlayer:
        root.players.includes(root.preferredPlayer)
        ? root.preferredPlayer
        : root.players.find(player => player.isPlaying)
            ?? root.players[0]
            ?? null

    readonly property bool available: root.activePlayer !== null
    readonly property bool playing: root.activePlayer?.isPlaying ?? false
    readonly property real position:
        root.activePlayer?.positionSupported
        ? root.activePlayer.position
        : 0
    readonly property real length:
        root.activePlayer?.lengthSupported
        ? root.activePlayer.length
        : 0

    function select(player): void {
        if (root.players.includes(player))
            root.preferredPlayer = player
    }

    function formatTime(seconds): string {
        if (!Number.isFinite(seconds) || seconds < 0)
            return "--"

        const value = Math.floor(seconds)
        const hours = Math.floor(value / 3600)
        const minutes = Math.floor(value % 3600 / 60)
        const remainingSeconds = value % 60

        if (hours > 0) {
            return hours
                + ":" + String(minutes).padStart(2, "0")
                + ":" + String(remainingSeconds).padStart(2, "0")
        }

        return String(minutes).padStart(2, "0")
            + ":" + String(remainingSeconds).padStart(2, "0")
    }

    function toggle(): void {
        if (root.activePlayer?.canTogglePlaying)
            root.activePlayer.togglePlaying()
    }

    function previous(): void {
        if (root.activePlayer?.canGoPrevious)
            root.activePlayer.previous()
    }

    function next(): void {
        if (root.activePlayer?.canGoNext)
            root.activePlayer.next()
    }

    function seek(fraction): void {
        const player = root.activePlayer
        if (player?.canSeek && player.positionSupported
                && player.lengthSupported && player.length > 0) {
            player.position = Math.max(0, Math.min(1, fraction)) * player.length
        }
    }

    Timer {
        interval: 1000
        running: root.playing
        repeat: true
        onTriggered: root.activePlayer?.positionChanged()
    }
}
