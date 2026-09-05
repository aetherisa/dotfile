import Quickshell
import "../module/screenPicker"
import "../module/wallpaper"
import "../module/statusbar"

Scope {
    id: root

    required property ShellScreen screen

    Wallpaper3D {
        screen: root.screen
    }

    ScreenPicker {
        screen: root.screen
    }

    StatusBar {
        screen: root.screen
    }
}
