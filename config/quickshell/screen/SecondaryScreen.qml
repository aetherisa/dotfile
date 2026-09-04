import Quickshell
import "../module/screenPicker"
import "../module/wallpaper"

Scope {
    id: root

    required property ShellScreen screen

    WallpaperTrivial {
        screen: root.screen
    }

    ScreenPicker {
        screen: root.screen
    }
}
