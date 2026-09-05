import Quickshell
import qs.module.screenPicker
import qs.module.wallpaper
import qs.module.statusbar

Scope {
    id: root

    required property ShellScreen screen

    WallpaperTrivial {
        screen: root.screen
    }

    ScreenPicker {
        screen: root.screen
    }

    StatusBarTrivial {
        screen: root.screen
    }
}
