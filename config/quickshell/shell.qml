import QtQuick
import Quickshell
import qs.global
import qs.screen

ShellRoot {
    Component.onCompleted: IpcManager.initialize()

    PrimaryScreen {
        screen: Config.primaryScreen
    }

    Variants {
        model: Config.secondaryScreens

        SecondaryScreen {
            required property ShellScreen modelData

            screen: modelData
        }
    }
}
