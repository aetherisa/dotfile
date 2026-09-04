pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property alias screenPicker: adapter.screenPicker
    readonly property alias wallpaper: adapter.wallpaper

    readonly property ShellScreen primaryScreen: {
        const screens = Quickshell.screens

        if (screens.length === 0) {
            console.error("Fatal: no screen was found by Quickshell")
            Qt.quit()
            return null
        }

        const requested = adapter.primaryScreen.trim()
        if (requested === "" || requested.toLowerCase() === "auto") {
            return screens[0]
        }

        for (const screen of screens) {
            if (screen.name === requested)
                return screen
        }

        console.warn(
            `Config option primaryScreen: '${requested}' not found; ` +
            `falling back to '${screens[0].name}'`)
        return screens[0]
    }

    readonly property var secondaryScreens:
        [...Quickshell.screens].filter(
            screen => screen !== root.primaryScreen)

    FileView {
        id: configFile

        path: Qt.resolvedUrl("../config.json")
        watchChanges: true

        onFileChanged: reload()

        JsonAdapter {
            id: adapter

            property string primaryScreen: "auto"
            property JsonObject screenPicker: JsonObject {
                property string screenshot: "base0B"
                property string recording: "base08"
                property string recordingActive: "base00"
                property string alpha: "66"
            }
            property JsonObject wallpaper: JsonObject {
                property string background: "base00"
            }
        }
    }
}
