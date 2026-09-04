import Quickshell
import "../module/screenPicker"
import "../module/wallpaper"

Scope {
    id: root

    required property ShellScreen screen

    Wallpaper3D {
        screen: root.screen
    }

    ScreenPicker {
        screen: root.screen
    }
}
