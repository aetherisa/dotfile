pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property alias screenPicker: adapter.screenPicker
    readonly property alias statusbar: adapter.statusbar
    readonly property alias launcher: adapter.launcher
    readonly property alias colors: adapter.colors
    readonly property alias unit: adapter.unit
    readonly property alias padding: adapter.padding
    readonly property alias fontSize: adapter.fontSize
    readonly property alias borderWidth: adapter.borderWidth

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
            property int unit: 32
            property int padding: 10
            property int fontSize: 12
            property int borderWidth: 3
            property JsonObject colors: JsonObject {
                property string background: "base00"
                property string surface: "base01"
                property string surfaceAlt: "base02"
                property string muted: "base03"
                property string foreground: "base05"
                property string accent: "base0B"
                property string danger: "base08"
                property string border: "base02"
            }
            property JsonObject screenPicker: JsonObject {
                property string alpha: "66"
            }
            property JsonObject statusbar: JsonObject {
                property int height: 20
            }
            property JsonObject launcher: JsonObject {
                property int width: 16
                property int maximumRows: 5
            }
        }
    }
}
