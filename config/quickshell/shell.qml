import QtQuick
import Quickshell

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        Scope {
            id: shell

            required property ShellScreen modelData
            readonly property ShellScreen mointor: modelData

            Wallpaper {}
        }
    }
}
