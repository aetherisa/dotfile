import QtQuick
import Quickshell

ShellRoot {
    id: root

    Wallpaper {
        screen: Quickshell.screens[0]
    }

    ScreenPicker {
        screen: Quickshell.screens[0]
    }

    StatusBar {
        screen: Quickshell.screens[0]
    }

    Variants {
        model: [...Quickshell.screens].slice(1)

        Background {
            required property ShellScreen modelData

            screen: modelData
        }
    }
}
